// lib/src/services/firebase_order_service.dart
// Service de gestion des commandes avec Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as app_models;
import '../providers/cart_provider.dart';
import 'loyalty_service.dart';

class FirebaseOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton
  static final FirebaseOrderService _instance = FirebaseOrderService._internal();
  factory FirebaseOrderService() => _instance;
  FirebaseOrderService._internal();

  /// Collection de commandes
  CollectionReference get _ordersCollection => _firestore.collection('orders');

  /// Créer une nouvelle commande
  Future<String> createOrder({
    required List<CartItem> items,
    required double total,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? comment,
    String? pickupDate,
    String? pickupTimeSlot,
    String source = 'client',
    String? paymentMethod,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    // CLIENT-SIDE RATE LIMITING: Prevent order spam (only for client orders, not caisse)
    if (source == 'client') {
      final rateLimitDoc = _firestore.collection('order_rate_limit').doc(user.uid);
      final rateLimitData = await rateLimitDoc.get();
      
      if (rateLimitData.exists) {
        final lastActionAt = (rateLimitData.data()?['lastActionAt'] as Timestamp?)?.toDate();
        if (lastActionAt != null) {
          final timeSinceLastOrder = DateTime.now().difference(lastActionAt);
          if (timeSinceLastOrder.inSeconds < 60) {
            throw Exception('Veuillez attendre avant de créer une nouvelle commande (limite: 1 commande par minute)');
          }
        }
      }
      
      // Update rate limit tracker
      await rateLimitDoc.set({
        'lastActionAt': FieldValue.serverTimestamp(),
      });
    }

    // VALIDATION: Sanitize inputs
    final sanitizedCustomerName = customerName?.trim().substring(0, customerName.length > 100 ? 100 : customerName.length);
    final sanitizedCustomerPhone = customerPhone?.trim().substring(0, customerPhone.length > 20 ? 20 : customerPhone.length);
    final sanitizedComment = comment?.trim().substring(0, comment.length > 500 ? 500 : comment.length);

    // VALIDATION: Check item count
    if (items.isEmpty || items.length > 50) {
      throw Exception('Nombre d\'articles invalide (max: 50)');
    }

    // VALIDATION: Check total is reasonable
    if (total <= 0 || total > 10000) {
      throw Exception('Montant de commande invalide');
    }

    final now = DateTime.now();
    final orderData = {
      'uid': user.uid,
      'customerEmail': customerEmail ?? user.email,
      'customerName': sanitizedCustomerName,
      'customerPhone': sanitizedCustomerPhone,
      'status': app_models.OrderStatus.pending,
      'items': items.map((item) => {
        'id': item.id,
        'productId': item.productId,
        'productName': item.productName,
        'price': item.price,
        'quantity': item.quantity,
        'imageUrl': item.imageUrl,
        'customDescription': item.customDescription,
        'isMenu': item.isMenu,
      }).toList(),
      'total_cents': (total * 100).round(), // Stocker en centimes pour éviter les problèmes de précision
      'total': total, // Garder aussi en euros pour compatibilité
      'createdAt': FieldValue.serverTimestamp(),
      'statusChangedAt': FieldValue.serverTimestamp(),
      'pickupAt': pickupDate != null && pickupTimeSlot != null
          ? '$pickupDate $pickupTimeSlot'
          : null,
      'pickupDate': pickupDate,
      'pickupTimeSlot': pickupTimeSlot,
      'comment': sanitizedComment,
      'seenByKitchen': false,
      'isViewed': false,
      'source': source,
      'paymentMethod': paymentMethod,
      'statusHistory': [
        {
          'status': app_models.OrderStatus.pending,
          'timestamp': now.toIso8601String(),
          'note': 'Commande créée',
        }
      ],
    };

    final docRef = await _ordersCollection.add(orderData);
    
    // Ajouter les points de fidélité après la commande (only for client orders)
    if (source == 'client') {
      await LoyaltyService().addPointsFromOrder(user.uid, total);
    }
    
    return docRef.id;
  }

  /// Stream de toutes les commandes (pour admin/kitchen)
  Stream<List<app_models.Order>> watchAllOrders() {
    return _ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _orderFromFirestore(doc.id, data);
            }).toList());
  }

  /// Stream des commandes d'un utilisateur spécifique
  Stream<List<app_models.Order>> watchUserOrders(String uid) {
    return _ordersCollection
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _orderFromFirestore(doc.id, data);
            }).toList());
  }

  /// Récupérer une commande par ID
  Future<app_models.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      return _orderFromFirestore(doc.id, data);
    } catch (e) {
      print('Erreur lors de la récupération de la commande: $e');
      return null;
    }
  }

  /// Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, String newStatus, {String? note}) async {
    final now = DateTime.now();
    final orderDoc = await _ordersCollection.doc(orderId).get();
    
    if (!orderDoc.exists) {
      throw Exception('Commande non trouvée');
    }

    final data = orderDoc.data() as Map<String, dynamic>;
    final statusHistory = List<Map<String, dynamic>>.from(data['statusHistory'] ?? []);
    
    statusHistory.add({
      'status': newStatus,
      'timestamp': now.toIso8601String(),
      'note': note,
    });

    await _ordersCollection.doc(orderId).update({
      'status': newStatus,
      'statusChangedAt': FieldValue.serverTimestamp(),
      'statusHistory': statusHistory,
    });
  }

  /// Marquer une commande comme vue par la cuisine
  Future<void> markAsSeenByKitchen(String orderId) async {
    await _ordersCollection.doc(orderId).update({
      'seenByKitchen': true,
      'isViewed': true,
      'viewedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marquer une commande comme vue
  Future<void> markOrderAsViewed(String orderId) async {
    await _ordersCollection.doc(orderId).update({
      'isViewed': true,
      'viewedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Obtenir les commandes par statut
  Stream<List<app_models.Order>> watchOrdersByStatus(String status) {
    return _ordersCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _orderFromFirestore(doc.id, data);
            }).toList());
  }

  /// Obtenir les commandes non vues
  Stream<List<app_models.Order>> watchUnviewedOrders() {
    return _ordersCollection
        .where('isViewed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _orderFromFirestore(doc.id, data);
            }).toList());
  }

  /// Supprimer une commande
  Future<void> deleteOrder(String orderId) async {
    await _ordersCollection.doc(orderId).delete();
  }

  /// Convertir un document Firestore en Order
  app_models.Order _orderFromFirestore(String id, Map<String, dynamic> data) {
    // Gérer les timestamps Firestore
    DateTime createdAt = DateTime.now();
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdAt = DateTime.parse(data['createdAt']);
      }
    }

    DateTime? viewedAt;
    if (data['viewedAt'] != null) {
      if (data['viewedAt'] is Timestamp) {
        viewedAt = (data['viewedAt'] as Timestamp).toDate();
      } else if (data['viewedAt'] is String) {
        viewedAt = DateTime.parse(data['viewedAt']);
      }
    }

    // Convertir les items
    final items = (data['items'] as List?)?.map((item) {
      return CartItem(
        id: item['id'] as String,
        productId: item['productId'] as String,
        productName: item['productName'] as String,
        price: (item['price'] as num).toDouble(),
        quantity: item['quantity'] as int,
        imageUrl: item['imageUrl'] as String,
        customDescription: item['customDescription'] as String?,
        isMenu: item['isMenu'] as bool? ?? false,
      );
    }).toList() ?? [];

    // Convertir l'historique de statut
    final statusHistory = (data['statusHistory'] as List?)?.map((h) {
      DateTime timestamp = DateTime.now();
      if (h['timestamp'] is Timestamp) {
        timestamp = (h['timestamp'] as Timestamp).toDate();
      } else if (h['timestamp'] is String) {
        timestamp = DateTime.parse(h['timestamp']);
      }

      return app_models.OrderStatusHistory(
        status: h['status'] as String,
        timestamp: timestamp,
        note: h['note'] as String?,
      );
    }).toList();

    // Calculer le total (en euros depuis total_cents si disponible, sinon utiliser total)
    double total = 0.0;
    if (data['total_cents'] != null) {
      total = (data['total_cents'] as num) / 100.0;
    } else if (data['total'] != null) {
      total = (data['total'] as num).toDouble();
    }

    return app_models.Order(
      id: id,
      total: total,
      date: createdAt,
      items: items,
      status: data['status'] as String? ?? app_models.OrderStatus.pending,
      customerName: data['customerName'] as String?,
      customerPhone: data['customerPhone'] as String?,
      customerEmail: data['customerEmail'] as String?,
      comment: data['comment'] as String?,
      statusHistory: statusHistory,
      isViewed: data['isViewed'] as bool? ?? false,
      viewedAt: viewedAt,
      pickupDate: data['pickupDate'] as String?,
      pickupTimeSlot: data['pickupTimeSlot'] as String?,
      source: data['source'] as String? ?? 'client',
      paymentMethod: data['paymentMethod'] as String?,
    );
  }
}
