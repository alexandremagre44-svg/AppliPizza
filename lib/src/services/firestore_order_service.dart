// lib/src/services/firestore_order_service.dart
// Service pour gérer les commandes avec Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';

class FirestoreOrderService {
  static final FirestoreOrderService _instance = FirestoreOrderService._internal();
  factory FirestoreOrderService() => _instance;
  FirestoreOrderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'orders';

  /// Charger toutes les commandes
  Future<List<Order>> loadAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _orderFromFirestore(data);
      }).toList();
    } catch (e) {
      print('Erreur lors du chargement des commandes: $e');
      return [];
    }
  }

  /// Stream pour écouter les commandes en temps réel
  Stream<List<Order>> ordersStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _orderFromFirestore(data);
      }).toList();
    });
  }

  /// Ajouter une nouvelle commande
  Future<bool> addOrder(Order order) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(order.id)
          .set(_orderToFirestore(order));
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout de la commande: $e');
      return false;
    }
  }

  /// Mettre à jour le statut d'une commande
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(orderId)
          .update({'status': newStatus});
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      return false;
    }
  }

  /// Supprimer une commande
  Future<bool> deleteOrder(String orderId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(orderId)
          .delete();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression: $e');
      return false;
    }
  }

  /// Filtrer les commandes par statut
  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('status', isEqualTo: status)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _orderFromFirestore(data);
      }).toList();
    } catch (e) {
      print('Erreur lors du filtrage par statut: $e');
      return [];
    }
  }

  /// Filtrer les commandes par plage de dates
  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _orderFromFirestore(data);
      }).toList();
    } catch (e) {
      print('Erreur lors du filtrage par date: $e');
      return [];
    }
  }

  /// Obtenir les statistiques de ventes
  Future<Map<String, dynamic>> getSalesStats() async {
    try {
      final orders = await loadAllOrders();

      if (orders.isEmpty) {
        return {
          'totalOrders': 0,
          'totalRevenue': 0.0,
          'averageOrderValue': 0.0,
          'todayOrders': 0,
          'todayRevenue': 0.0,
        };
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todayOrders = orders.where((o) {
        final orderDate = DateTime(o.date.year, o.date.month, o.date.day);
        return orderDate.isAtSameMomentAs(today);
      }).toList();

      final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.total);
      final todayRevenue = todayOrders.fold<double>(0, (sum, order) => sum + order.total);

      return {
        'totalOrders': orders.length,
        'totalRevenue': totalRevenue,
        'averageOrderValue': orders.isEmpty ? 0.0 : totalRevenue / orders.length,
        'todayOrders': todayOrders.length,
        'todayRevenue': todayRevenue,
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'averageOrderValue': 0.0,
        'todayOrders': 0,
        'todayRevenue': 0.0,
      };
    }
  }

  /// Obtenir les commandes d'un utilisateur spécifique
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _orderFromFirestore(data);
      }).toList();
    } catch (e) {
      print('Erreur lors du chargement des commandes utilisateur: $e');
      return [];
    }
  }

  /// Conversion Order -> Firestore
  Map<String, dynamic> _orderToFirestore(Order order) {
    return {
      'id': order.id,
      'total': order.total,
      'date': Timestamp.fromDate(order.date),
      'status': order.status,
      'items': order.items.map((item) => {
        'id': item.id,
        'productId': item.productId,
        'productName': item.productName,
        'price': item.price,
        'quantity': item.quantity,
        'imageUrl': item.imageUrl,
        'customDescription': item.customDescription,
        'isMenu': item.isMenu,
      }).toList(),
    };
  }

  /// Conversion Firestore -> Order
  Order _orderFromFirestore(Map<String, dynamic> data) {
    return Order(
      id: data['id'] as String,
      total: (data['total'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] as String,
      items: (data['items'] as List<dynamic>).map((itemData) {
        return CartItem(
          id: itemData['id'] as String,
          productId: itemData['productId'] as String,
          productName: itemData['productName'] as String,
          price: (itemData['price'] as num).toDouble(),
          quantity: itemData['quantity'] as int,
          imageUrl: itemData['imageUrl'] as String,
          customDescription: itemData['customDescription'] as String?,
          isMenu: itemData['isMenu'] as bool? ?? false,
        );
      }).toList(),
    );
  }
}
