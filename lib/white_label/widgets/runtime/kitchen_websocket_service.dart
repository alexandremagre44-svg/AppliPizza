import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Order status enum for kitchen workflow
enum OrderStatus {
  received,
  preparing,
  ready,
  completed,
  cancelled,
}

/// Kitchen order event type
enum OrderEventType {
  newOrder,
  statusUpdate,
  orderCancelled,
}

/// Kitchen order event model
class KitchenOrderEvent {
  final OrderEventType type;
  final String orderId;
  final OrderStatus? status;
  final Map<String, dynamic>? orderData;
  final DateTime timestamp;

  KitchenOrderEvent({
    required this.type,
    required this.orderId,
    this.status,
    this.orderData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory KitchenOrderEvent.fromJson(Map<String, dynamic> json) {
    return KitchenOrderEvent(
      type: OrderEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OrderEventType.newOrder,
      ),
      orderId: json['orderId'] as String,
      status: json['status'] != null
          ? OrderStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => OrderStatus.received,
            )
          : null,
      orderData: json['orderData'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'orderId': orderId,
      if (status != null) 'status': status!.name,
      if (orderData != null) 'orderData': orderData,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Kitchen WebSocket Service
/// 
/// Handles real-time communication for kitchen tablet orders.
/// Centralizes WebSocket connection and order status management.
class KitchenWebSocketService {
  // Stream controllers
  final _orderEventsController = StreamController<KitchenOrderEvent>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // Connection state
  bool _isConnected = false;
  String? _restaurantId;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  // Configuration
  static const int _reconnectDelaySeconds = 5;
  static const int _heartbeatIntervalSeconds = 30;

  /// Whether the service is currently connected
  bool get isConnected => _isConnected;

  /// Stream of order events
  Stream<KitchenOrderEvent> get orderEvents => _orderEventsController.stream;

  /// Stream of connection status changes
  Stream<bool> get connectionStatus => _connectionController.stream;

  /// Current restaurant ID
  String? get restaurantId => _restaurantId;

  /// Connect to the WebSocket server
  /// 
  /// [url] - WebSocket server URL (e.g., 'ws://example.com/kitchen')
  /// [restaurantId] - Restaurant identifier for filtering orders
  /// 
  /// Note: This is a placeholder implementation using polling.
  /// In production, replace with actual WebSocket connection:
  /// ```dart
  /// final channel = WebSocketChannel.connect(Uri.parse(url));
  /// channel.stream.listen(_handleMessage, onError: _handleError);
  /// ```
  Future<void> connect(String url, String restaurantId) async {
    if (_isConnected) {
      debugPrint('⚠️ [KitchenWebSocket] Already connected');
      return;
    }

    try {
      _restaurantId = restaurantId;
      debugPrint('🔌 [KitchenWebSocket] Connecting to $url for restaurant $restaurantId');

      // TODO: Replace with actual WebSocket connection
      // For now, simulate connection
      await Future.delayed(const Duration(milliseconds: 500));

      _isConnected = true;
      _connectionController.add(true);
      debugPrint('✅ [KitchenWebSocket] Connected successfully');

      // Start heartbeat
      _startHeartbeat();

      // In production, WebSocket setup would be:
      // _channel = WebSocketChannel.connect(Uri.parse(url));
      // _channel.stream.listen(
      //   (message) => _handleMessage(message),
      //   onError: (error) => _handleError(error),
      //   onDone: () => _handleDisconnect(),
      // );

    } catch (e, stack) {
      debugPrint('❌ [KitchenWebSocket] Connection failed: $e');
      debugPrint('$stack');
      _isConnected = false;
      _connectionController.add(false);
      _scheduleReconnect(url, restaurantId);
    }
  }

  /// Disconnect from the WebSocket server
  void disconnect() {
    debugPrint('🔌 [KitchenWebSocket] Disconnecting...');

    _isConnected = false;
    _connectionController.add(false);

    // Cancel timers
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();

    // TODO: Close WebSocket connection
    // _channel?.sink.close();

    debugPrint('✅ [KitchenWebSocket] Disconnected');
  }

  /// Send order status update to the server
  /// 
  /// [orderId] - Order identifier
  /// [status] - New status (received, preparing, ready, etc.)
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    if (!_isConnected) {
      debugPrint('⚠️ [KitchenWebSocket] Cannot update status - not connected');
      return;
    }

    try {
      final message = jsonEncode({
        'type': 'order_status_update',
        'restaurantId': _restaurantId,
        'orderId': orderId,
        'status': status.name,
        'timestamp': DateTime.now().toIso8601String(),
      });

      debugPrint('📤 [KitchenWebSocket] Sending status update: $orderId -> ${status.name}');

      // TODO: Send via WebSocket
      // _channel?.sink.add(message);

      // Simulate local event for testing
      _orderEventsController.add(KitchenOrderEvent(
        type: OrderEventType.statusUpdate,
        orderId: orderId,
        status: status,
      ));

    } catch (e) {
      debugPrint('❌ [KitchenWebSocket] Failed to update order status: $e');
    }
  }

  /// Handle incoming WebSocket message
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = KitchenOrderEvent.fromJson(data);

      debugPrint('📥 [KitchenWebSocket] Received event: ${event.type.name} for order ${event.orderId}');

      _orderEventsController.add(event);

    } catch (e, stack) {
      debugPrint('❌ [KitchenWebSocket] Failed to parse message: $e');
      debugPrint('$stack');
    }
  }

  /// Handle WebSocket error
  void _handleError(dynamic error) {
    debugPrint('❌ [KitchenWebSocket] WebSocket error: $error');
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Handle WebSocket disconnection
  void _handleDisconnect() {
    debugPrint('⚠️ [KitchenWebSocket] WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(false);
    
    // Auto-reconnect if restaurant ID is set
    if (_restaurantId != null) {
      _scheduleReconnect('', _restaurantId!);
    }
  }

  /// Schedule automatic reconnection
  void _scheduleReconnect(String url, String restaurantId) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      Duration(seconds: _reconnectDelaySeconds),
      () {
        debugPrint('🔄 [KitchenWebSocket] Attempting to reconnect...');
        connect(url, restaurantId);
      },
    );
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: _heartbeatIntervalSeconds),
      (_) {
        if (_isConnected) {
          // TODO: Send heartbeat via WebSocket
          // _channel?.sink.add(jsonEncode({'type': 'ping'}));
          debugPrint('💓 [KitchenWebSocket] Heartbeat sent');
        }
      },
    );
  }

  /// Dispose of resources
  void dispose() {
    debugPrint('🗑️ [KitchenWebSocket] Disposing service');
    disconnect();
    _orderEventsController.close();
    _connectionController.close();
  }

  // ========== Testing/Development Helpers ==========

  /// Simulate receiving a new order (for testing)
  void simulateNewOrder(String orderId, Map<String, dynamic> orderData) {
    if (kDebugMode) {
      _orderEventsController.add(KitchenOrderEvent(
        type: OrderEventType.newOrder,
        orderId: orderId,
        status: OrderStatus.received,
        orderData: orderData,
      ));
    }
  }

  /// Simulate order cancellation (for testing)
  void simulateCancelOrder(String orderId) {
    if (kDebugMode) {
      _orderEventsController.add(KitchenOrderEvent(
        type: OrderEventType.orderCancelled,
        orderId: orderId,
      ));
    }
  }
}
