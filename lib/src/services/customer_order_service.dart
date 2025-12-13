// lib/src/services/customer_order_service.dart
/// 
/// Service for managing customer orders (online orders)
/// Reuses the EXACT same PosOrder/Order model as POS
/// Orders flow through the SAME status workflow as POS orders
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
import 'payment/online_payment_provider.dart';

const _uuid = Uuid();

/// Customer Order Service
/// 
/// Handles online customer orders using the SAME workflow as POS:
/// - Creates orders in draft status
/// - Processes online payment
/// - Marks as paid (same as POS)
/// - Enters same pipeline (visible in POS and KDS)
class CustomerOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;
  final OnlinePaymentProvider paymentProvider;
  
  CustomerOrderService({
    required this.appId,
    required this.paymentProvider,
  });
  
  /// Orders collection (SAME as POS)
  CollectionReference get _ordersCollection => FirestorePaths.orders(appId);
  
  /// Create a new customer order with online payment
  /// 
  /// This follows the EXACT same flow as POS but with online payment:
  /// 1. Create draft order
  /// 2. Process online payment
  /// 3. If payment succeeds, mark as paid
  /// 4. Order enters the same pipeline as POS orders
  Future<CustomerOrderResult> createOrderWithPayment({
    required List<CartItem> items,
    required double total,
    required String orderType,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? tableNumber,
    String? comment,
    String? pickupDate,
    String? pickupTimeSlot,
    OrderDeliveryAddress? deliveryAddress,
    String? deliveryAreaId,
    double? deliveryFee,
  }) async {
    // Validation
    if (items.isEmpty) {
      throw Exception('Le panier ne peut pas être vide');
    }
    
    if (total <= 0) {
      throw Exception('Le montant total doit être supérieur à 0');
    }
    
    try {
      // Step 1: Create base order
      final order = Order.fromCart(
        items,
        total,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        comment: comment,
        pickupDate: pickupDate,
        pickupTimeSlot: pickupTimeSlot,
        source: 'client', // Important: distinguish from POS orders
        deliveryMode: orderType == OrderType.delivery 
            ? OrderDeliveryMode.delivery 
            : OrderDeliveryMode.takeAway,
        deliveryAddress: deliveryAddress,
        deliveryAreaId: deliveryAreaId,
        deliveryFee: deliveryFee,
      );
      
      // Step 2: Create POS order in draft status
      final posOrder = PosOrder.fromOrder(
        order.copyWith(status: PosOrderStatus.draft),
        orderType: orderType,
        tableNumber: tableNumber,
        staffNotes: 'Commande en ligne',
      );
      
      // Step 3: Save draft order to Firestore
      final docData = posOrder.toJson();
      docData['createdAt'] = FieldValue.serverTimestamp();
      docData['updatedAt'] = FieldValue.serverTimestamp();
      
      final docRef = await _ordersCollection.add(docData);
      final orderId = docRef.id;
      
      // Step 4: Process online payment
      final paymentResult = await paymentProvider.pay(order);
      
      if (!paymentResult.success) {
        // Payment failed - keep order as draft but mark as failed
        await _ordersCollection.doc(orderId).update({
          'paymentAttemptFailed': true,
          'paymentError': paymentResult.errorMessage,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        return CustomerOrderResult(
          success: false,
          orderId: orderId,
          errorMessage: paymentResult.errorMessage,
        );
      }
      
      // Step 5: Mark order as paid (SAME as POS)
      final payment = PaymentTransaction(
        id: paymentResult.transactionId!,
        orderId: orderId,
        method: PaymentMethod.card, // Online payments are card by default
        amount: total,
        timestamp: DateTime.now(),
        reference: paymentResult.transactionId,
        status: PaymentStatus.success,
      );
      
      // Update status history
      final statusHistory = [
        {
          'status': PosOrderStatus.draft,
          'timestamp': DateTime.now().toIso8601String(),
          'note': 'Commande créée (en ligne)',
        },
        {
          'status': PosOrderStatus.paid,
          'timestamp': DateTime.now().toIso8601String(),
          'note': 'Paiement en ligne reçu',
        },
      ];
      
      await _ordersCollection.doc(orderId).update({
        'status': PosOrderStatus.paid,
        'payment': payment.toJson(),
        'paymentMethod': payment.method,
        'statusHistory': statusHistory,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Order is now paid and will appear in:
      // - POS (for staff to see)
      // - KDS (for kitchen to prepare)
      
      return CustomerOrderResult(
        success: true,
        orderId: orderId,
        transactionId: paymentResult.transactionId,
      );
      
    } catch (e) {
      // Handle any unexpected errors
      return CustomerOrderResult(
        success: false,
        errorMessage: 'Erreur lors de la création de la commande: ${e.toString()}',
      );
    }
  }
  
  /// Get customer order by ID
  Future<PosOrder?> getOrderById(String orderId) async {
    final doc = await _ordersCollection.doc(orderId).get();
    if (!doc.exists) return null;
    
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return PosOrder.fromJson(data);
  }
  
  /// Watch customer orders for a specific customer (by email or phone)
  Stream<List<PosOrder>> watchCustomerOrders({
    String? email,
    String? phone,
  }) {
    Query query = _ordersCollection.where('source', isEqualTo: 'client');
    
    if (email != null) {
      query = query.where('customerEmail', isEqualTo: email);
    } else if (phone != null) {
      query = query.where('customerPhone', isEqualTo: phone);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return PosOrder.fromJson(data);
        }).toList());
  }
}

/// Result of customer order creation
class CustomerOrderResult {
  final bool success;
  final String? orderId;
  final String? transactionId;
  final String? errorMessage;
  
  const CustomerOrderResult({
    required this.success,
    this.orderId,
    this.transactionId,
    this.errorMessage,
  });
}
