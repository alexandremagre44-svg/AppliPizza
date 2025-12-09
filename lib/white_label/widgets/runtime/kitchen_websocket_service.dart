import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Order status enum
enum OrderStatus {
  pending('pending', 'En attente'),
  received('received', 'Reçue'),
  preparing('preparing', 'En préparation'),
  ready('ready', 'Prête'),
  completed('completed', 'Terminée'),
  cancelled('cancelled', 'Annulée');

  final String code;
  final String label;
  const OrderStatus(this.code, this.label);

  static OrderStatus fromCode(String code) {
    return OrderStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// Kitchen order model
class KitchenOrder {
  final String id;
  final String restaurantId;
  final int orderNumber;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> items;
  final double total;
  final String? customerName;
  final String? notes;

  KitchenOrder({
    required this.id,
    required this.restaurantId,
    required this.orderNumber,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.items = const {},
    this.total = 0.0,
    this.customerName,
    this.notes,
  });

  factory KitchenOrder.fromJson(Map<String, dynamic> json) {
    return KitchenOrder(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String,
      orderNumber: json['orderNumber'] as int? ?? 0,
      status: OrderStatus.fromCode(json['status'] as String? ?? 'pending'),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      items: json['items'] as Map<String, dynamic>? ?? {},
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      customerName: json['customerName'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'orderNumber': orderNumber,
      'status': status.code,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'items': items,
      'total': total,
      'customerName': customerName,
      'notes': notes,
    };
  }

  KitchenOrder copyWith({
    OrderStatus? status,
    DateTime? updatedAt,
  }) {
    return KitchenOrder(
      id: id,
      restaurantId: restaurantId,
      orderNumber: orderNumber,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items,
      total: total,
      customerName: customerName,
      notes: notes,
    );
  }
}

/// Kitchen WebSocket Service
/// 
/// Handles real-time communication for kitchen tablet orders.
/// Uses Firestore real-time listeners as an alternative to WebSocket
/// for simplicity and Firebase integration.
/// 
/// Features:
/// - Listen for new orders in real-time
/// - Send order status updates
/// - Handle order lifecycle
/// - Automatic reconnection through Firestore
class KitchenWebSocketService {
  final String restaurantId;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;
  final _ordersController = StreamController<List<KitchenOrder>>.broadcast();
  final _statusUpdatesController = StreamController<KitchenOrder>.broadcast();
  bool _isConnected = false;

  KitchenWebSocketService({required this.restaurantId});

  /// Whether the service is currently connected
  bool get isConnected => _isConnected;

  /// Stream of all orders
  Stream<List<KitchenOrder>> get orders => _ordersController.stream;

  /// Stream of status updates
  Stream<KitchenOrder> get statusUpdates => _statusUpdatesController.stream;

  /// Connect to the order stream
  /// 
  /// Listens to Firestore for real-time order updates.
  /// Filters orders by restaurant ID and non-completed status.
  Future<void> connect() async {
    if (_isConnected) {
      debugPrint('[KitchenWebSocket] Already connected');
      return;
    }

    try {
      debugPrint('[KitchenWebSocket] Connecting for restaurant: $restaurantId');

      // Listen to orders collection for this restaurant
      _ordersSubscription = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('orders')
          .where('status', whereIn: [
            'pending',
            'received',
            'preparing',
            'ready'
          ]) // Exclude completed/cancelled
          .orderBy('createdAt', descending: true)
          .limit(50) // Limit to recent orders
          .snapshots()
          .listen(
        (snapshot) {
          final orders = snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  data['id'] = doc.id; // Add document ID
                  return KitchenOrder.fromJson(data);
                } catch (e) {
                  debugPrint('[KitchenWebSocket] Error parsing order ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<KitchenOrder>()
              .toList();

          _ordersController.add(orders);

          // Detect status changes
          for (final change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              try {
                final data = change.doc.data()!;
                data['id'] = change.doc.id;
                final order = KitchenOrder.fromJson(data);
                _statusUpdatesController.add(order);
              } catch (e) {
                debugPrint('[KitchenWebSocket] Error parsing status update: $e');
              }
            }
          }

          debugPrint('[KitchenWebSocket] Received ${orders.length} orders');
        },
        onError: (error) {
          debugPrint('[KitchenWebSocket] Stream error: $error');
          _isConnected = false;
        },
      );

      _isConnected = true;
      debugPrint('[KitchenWebSocket] Connected successfully');
    } catch (e) {
      debugPrint('[KitchenWebSocket] Connection error: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// Disconnect from the order stream
  Future<void> disconnect() async {
    debugPrint('[KitchenWebSocket] Disconnecting');
    await _ordersSubscription?.cancel();
    _ordersSubscription = null;
    _isConnected = false;
  }

  /// Update order status
  /// 
  /// [orderId] - Order identifier
  /// [status] - New status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      debugPrint('[KitchenWebSocket] Updating order $orderId to ${status.code}');

      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': status.code,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[KitchenWebSocket] Order $orderId updated successfully');
    } catch (e) {
      debugPrint('[KitchenWebSocket] Error updating order status: $e');
      rethrow;
    }
  }

  /// Get a single order by ID
  Future<KitchenOrder?> getOrder(String orderId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('orders')
          .doc(orderId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id;
      return KitchenOrder.fromJson(data);
    } catch (e) {
      debugPrint('[KitchenWebSocket] Error getting order: $e');
      return null;
    }
  }

  /// Mark order as received (kitchen acknowledged)
  Future<void> acknowledgeOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.received);
  }

  /// Mark order as preparing
  Future<void> startPreparing(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.preparing);
  }

  /// Mark order as ready for pickup/delivery
  Future<void> markReady(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.ready);
  }

  /// Mark order as completed
  Future<void> completeOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.completed);
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    await updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _ordersController.close();
    _statusUpdatesController.close();
  }
}
