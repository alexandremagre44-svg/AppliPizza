// lib/src/services/pos_order_service.dart
/// 
/// Service for managing POS orders with complete workflow
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/pos_order.dart';
import '../models/pos_order_status.dart';
import '../models/payment_method.dart';
import '../models/order_type.dart';
import '../providers/cart_provider.dart';
import '../core/firestore_paths.dart';

const _uuid = Uuid();

/// POS Order Service
class PosOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;
  
  PosOrderService({required this.appId});
  
  /// Orders collection
  CollectionReference get _ordersCollection => FirestorePaths.orders(appId);
  
  /// Create a new POS order (draft state)
  Future<String> createDraftOrder({
    required List<CartItem> items,
    required double total,
    required String orderType,
    required String staffId,
    required String staffName,
    required String sessionId,
    String? customerName,
    String? tableNumber,
    String? notes,
  }) async {
    // Validation
    if (items.isEmpty) {
      throw Exception('Le panier ne peut pas être vide');
    }
    
    if (total <= 0) {
      throw Exception('Le montant total doit être supérieur à 0');
    }
    
    // Create base order
    final order = Order.fromCart(
      items,
      total,
      customerName: customerName,
      comment: notes,
      source: 'pos',
    );
    
    // Create POS order
    final posOrder = PosOrder.fromOrder(
      order.copyWith(status: PosOrderStatus.draft),
      orderType: orderType,
      sessionId: sessionId,
      tableNumber: tableNumber,
      staffNotes: notes,
    );
    
    // Save to Firestore
    final docData = posOrder.toJson();
    docData['staffId'] = staffId;
    docData['staffName'] = staffName;
    docData['createdAt'] = FieldValue.serverTimestamp();
    docData['updatedAt'] = FieldValue.serverTimestamp();
    
    final docRef = await _ordersCollection.add(docData);
    return docRef.id;
  }
  
  /// Update order to paid status with payment details
  Future<void> markOrderAsPaid({
    required String orderId,
    required PaymentTransaction payment,
  }) async {
    final orderDoc = await _ordersCollection.doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Commande non trouvée');
    }
    
    final data = orderDoc.data() as Map<String, dynamic>;
    final currentStatus = data['status'] as String?;
    
    // Validate transition
    if (currentStatus != PosOrderStatus.draft) {
      throw Exception('Seules les commandes en brouillon peuvent être payées');
    }
    
    if (payment.status != PaymentStatus.success) {
      throw Exception('Le paiement doit être validé avant de marquer comme payée');
    }
    
    // Update status history
    final statusHistory = List<Map<String, dynamic>>.from(data['statusHistory'] ?? []);
    statusHistory.add({
      'status': PosOrderStatus.paid,
      'timestamp': DateTime.now().toIso8601String(),
      'note': 'Paiement reçu: ${PaymentMethod.getLabel(payment.method)}',
    });
    
    await _ordersCollection.doc(orderId).update({
      'status': PosOrderStatus.paid,
      'payment': payment.toJson(),
      'paymentMethod': payment.method,
      'statusHistory': statusHistory,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Update order status
  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? note,
  }) async {
    final orderDoc = await _ordersCollection.doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Commande non trouvée');
    }
    
    final data = orderDoc.data() as Map<String, dynamic>;
    final currentStatus = data['status'] as String?;
    
    // Validate transition
    final allowedTransitions = PosOrderStatus.getNextStatuses(currentStatus ?? PosOrderStatus.draft);
    if (!allowedTransitions.contains(newStatus)) {
      throw Exception('Transition de statut non autorisée: $currentStatus -> $newStatus');
    }
    
    // Update status history
    final statusHistory = List<Map<String, dynamic>>.from(data['statusHistory'] ?? []);
    statusHistory.add({
      'status': newStatus,
      'timestamp': DateTime.now().toIso8601String(),
      'note': note ?? 'Statut mis à jour',
    });
    
    await _ordersCollection.doc(orderId).update({
      'status': newStatus,
      'statusHistory': statusHistory,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Cancel an order with justification
  Future<void> cancelOrder({
    required String orderId,
    required String reason,
    required String staffId,
  }) async {
    final orderDoc = await _ordersCollection.doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Commande non trouvée');
    }
    
    final data = orderDoc.data() as Map<String, dynamic>;
    final currentStatus = data['status'] as String?;
    
    // Validate cancellation is allowed
    if (!PosOrderStatus.canCancel(currentStatus ?? '')) {
      throw Exception('Cette commande ne peut pas être annulée');
    }
    
    if (reason.trim().isEmpty) {
      throw Exception('Une justification est requise pour annuler une commande');
    }
    
    // Update status history
    final statusHistory = List<Map<String, dynamic>>.from(data['statusHistory'] ?? []);
    statusHistory.add({
      'status': PosOrderStatus.cancelled,
      'timestamp': DateTime.now().toIso8601String(),
      'note': 'Annulée par staff: $reason',
    });
    
    await _ordersCollection.doc(orderId).update({
      'status': PosOrderStatus.cancelled,
      'cancellationReason': reason,
      'cancelledBy': staffId,
      'cancelledAt': FieldValue.serverTimestamp(),
      'statusHistory': statusHistory,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Refund an order with justification
  Future<void> refundOrder({
    required String orderId,
    required String reason,
    required String staffId,
  }) async {
    final orderDoc = await _ordersCollection.doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Commande non trouvée');
    }
    
    final data = orderDoc.data() as Map<String, dynamic>;
    final currentStatus = data['status'] as String?;
    
    // Validate refund is allowed
    if (!PosOrderStatus.canRefund(currentStatus ?? '')) {
      throw Exception('Cette commande ne peut pas être remboursée');
    }
    
    if (reason.trim().isEmpty) {
      throw Exception('Une justification est requise pour rembourser une commande');
    }
    
    // Update status history
    final statusHistory = List<Map<String, dynamic>>.from(data['statusHistory'] ?? []);
    statusHistory.add({
      'status': PosOrderStatus.refunded,
      'timestamp': DateTime.now().toIso8601String(),
      'note': 'Remboursée par staff: $reason',
    });
    
    await _ordersCollection.doc(orderId).update({
      'status': PosOrderStatus.refunded,
      'refundReason': reason,
      'refundedBy': staffId,
      'refundedAt': FieldValue.serverTimestamp(),
      'statusHistory': statusHistory,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Get order by ID
  Future<PosOrder?> getOrderById(String orderId) async {
    final doc = await _ordersCollection.doc(orderId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return PosOrder.fromJson(data);
  }
  
  /// Watch orders for a session
  Stream<List<PosOrder>> watchSessionOrders(String sessionId) {
    return _ordersCollection
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return PosOrder.fromJson(data);
        }).toList());
  }
  
  /// Watch orders by status
  Stream<List<PosOrder>> watchOrdersByStatus(String status) {
    return _ordersCollection
        .where('source', isEqualTo: 'pos')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return PosOrder.fromJson(data);
        }).toList());
  }
  
  /// Validate cart items for required options
  ValidationResult validateCartItems(List<CartItem> items) {
    final errors = <String>[];
    
    for (final item in items) {
      // Check if item has required selections
      // This is a placeholder - actual validation would check against product options
      if (item.selections.isEmpty && item.isMenu) {
        errors.add('Le menu "${item.productName}" nécessite une personnalisation');
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  
  const ValidationResult({
    required this.isValid,
    required this.errors,
  });
}
