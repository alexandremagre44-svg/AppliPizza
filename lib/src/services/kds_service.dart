// lib/src/services/kds_service.dart
/// 
/// Kitchen Display System Service
/// Manages kitchen operations for both POS and customer orders
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pos_order.dart';
import '../models/pos_order_status.dart';
import '../core/firestore_paths.dart';

/// KDS Service
/// 
/// Handles kitchen operations:
/// - Watch orders ready for preparation (paid status)
/// - Update order status (in_preparation, ready)
/// - NO modification of order content (kitchen cannot edit)
/// - Only status transitions allowed
class KdsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;
  
  KdsService({required this.appId});
  
  /// Orders collection
  CollectionReference get _ordersCollection => FirestorePaths.orders(appId);
  
  /// Watch orders that need kitchen attention
  /// 
  /// Returns orders with status:
  /// - paid (ready to start preparation)
  /// - in_preparation (currently being prepared)
  /// - ready (finished, waiting for pickup/delivery)
  Stream<List<PosOrder>> watchKitchenOrders() {
    return _ordersCollection
        .where('status', whereIn: [
          PosOrderStatus.paid,
          PosOrderStatus.inPreparation,
          PosOrderStatus.ready,
        ])
        .orderBy('createdAt', descending: false) // Oldest first
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return PosOrder.fromJson(data);
        }).toList());
  }
  
  /// Watch orders by specific status
  Stream<List<PosOrder>> watchOrdersByStatus(String status) {
    return _ordersCollection
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return PosOrder.fromJson(data);
        }).toList());
  }
  
  /// Start preparing an order
  /// Transition: paid → in_preparation
  Future<void> startPreparation(String orderId) async {
    final orderDoc = await _ordersCollection.doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Commande non trouvée');
    }
    
    final data = orderDoc.data() as Map<String, dynamic>;
    final currentStatus = data['status'] as String?;
    
    // Validate transition
    if (currentStatus != PosOrderStatus.paid) {
      throw Exception('Seules les commandes payées peuvent être mises en préparation');
    }
    
    // Update status history
    final statusHistory = List<Map<String, dynamic>>.from(data['statusHistory'] ?? []);
    statusHistory.add({
      'status': PosOrderStatus.inPreparation,
      'timestamp': DateTime.now().toIso8601String(),
      'note': 'Préparation démarrée par la cuisine',
    });
    
    await _ordersCollection.doc(orderId).update({
      'status': PosOrderStatus.inPreparation,
      'statusHistory': statusHistory,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  /// Mark order as ready
  /// Transition: in_preparation → ready
  Future<void> markAsReady(String orderId) async {
    final orderDoc = await _ordersCollection.doc(orderId).get();
    if (!orderDoc.exists) {
      throw Exception('Commande non trouvée');
    }
    
    final data = orderDoc.data() as Map<String, dynamic>;
    final currentStatus = data['status'] as String?;
    
    // Validate transition
    if (currentStatus != PosOrderStatus.inPreparation) {
      throw Exception('Seules les commandes en préparation peuvent être marquées comme prêtes');
    }
    
    // Update status history
    final statusHistory = List<Map<String, dynamic>>.from(data['statusHistory'] ?? []);
    statusHistory.add({
      'status': PosOrderStatus.ready,
      'timestamp': DateTime.now().toIso8601String(),
      'note': 'Commande prête',
    });
    
    await _ordersCollection.doc(orderId).update({
      'status': PosOrderStatus.ready,
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
  
  /// Mark order as viewed by kitchen (acknowledges new order)
  Future<void> acknowledgeOrder(String orderId) async {
    await _ordersCollection.doc(orderId).update({
      'kitchenAcknowledged': true,
      'kitchenAcknowledgedAt': FieldValue.serverTimestamp(),
    });
  }
}
