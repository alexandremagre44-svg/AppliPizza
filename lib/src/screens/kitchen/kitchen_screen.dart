// lib/src/screens/kitchen/kitchen_screen.dart
// Kitchen Screen with WebSocket integration

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../white_label/widgets/runtime/kitchen_websocket_service.dart';
import '../../providers/restaurant_plan_provider.dart';
import '../../../services/runtime/kitchen_orders_runtime_service.dart';

/// Kitchen Screen with WebSocket integration
/// 
/// Displays orders in real-time using WebSocket for live updates
class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> {
  KitchenWebSocketService? _wsService;
  StreamSubscription<KitchenOrderEvent>? _eventSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // Initialize WebSocket if module is configured
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebSocket();
    });
  }

  Future<void> _initializeWebSocket() async {
    final plan = ref.read(restaurantPlanUnifiedProvider).asData?.value;
    final kitchenConfig = plan?.kitchenTablet;
    
    if (kitchenConfig?.settings['useWebSocket'] == true) {
      final url = kitchenConfig?.settings['webSocketUrl'] as String? ?? 
          'ws://localhost:8080/kitchen';
      
      _wsService = KitchenWebSocketService();
      
      try {
        await _wsService!.connect(url, plan!.restaurantId);
        
        // Listen to order events
        _eventSubscription = _wsService!.orderEvents.listen((event) {
          if (mounted) {
            _handleOrderEvent(event);
          }
        });
        
        // Listen to connection status
        _connectionSubscription = _wsService!.connectionStatus.listen((connected) {
          if (mounted) {
            setState(() {
              _isConnected = connected;
            });
          }
        });
      } catch (e) {
        debugPrint('❌ [KitchenScreen] Failed to connect WebSocket: $e');
      }
    }
  }

  void _handleOrderEvent(KitchenOrderEvent event) {
    switch (event.type) {
      case OrderEventType.newOrder:
        _showNewOrderNotification(event.orderId);
        break;
      case OrderEventType.statusUpdate:
        // UI will update automatically via stream
        break;
      case OrderEventType.orderCancelled:
        _showOrderCancelledNotification(event.orderId);
        break;
    }
  }

  void _showNewOrderNotification(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nouvelle commande : $orderId'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showOrderCancelledNotification(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Commande annulée : $orderId'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, KitchenStatus newStatus) async {
    // Update via WebSocket if connected
    if (_wsService != null && _isConnected) {
      final wsStatus = OrderStatus.values.firstWhere(
        (s) => s.name == newStatus.toOrderStatus(),
        orElse: () => OrderStatus.received,
      );
      await _wsService!.updateOrderStatus(orderId, wsStatus);
    }
    
    // Always update Firestore for persistence
    await ref
        .read(kitchenOrdersRuntimeServiceProvider)
        .updateOrderStatus(orderId, newStatus);
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _connectionSubscription?.cancel();
    _wsService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ordersStream = ref.watch(kitchenOrdersRuntimeServiceProvider).watchKitchenOrders();
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Cuisine'),
            const SizedBox(width: 12),
            // Connection status indicator
            if (_wsService != null) ...[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isConnected ? 'En ligne' : 'Hors ligne',
                style: TextStyle(
                  fontSize: 12,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: StreamBuilder<List<KitchenOrder>>(
        stream: ordersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.kitchen,
                    size: 80,
                    color: colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aucune commande en cours',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, order, colorScheme);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, KitchenOrder order, ColorScheme colorScheme) {
    final statusColor = _getStatusColor(order.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(order.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Items
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item'),
            )),
            
            const SizedBox(height: 12),
            
            // Time info
            if (order.pickupTime != null)
              Text(
                'Retrait: ${_formatTime(order.pickupTime!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Wrap(
              spacing: 8,
              children: [
                if (order.status == KitchenStatus.pending)
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order.id, KitchenStatus.preparing),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Commencer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (order.status == KitchenStatus.preparing)
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order.id, KitchenStatus.ready),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Prêt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (order.status == KitchenStatus.ready)
                  ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order.id, KitchenStatus.delivered),
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Livré'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(KitchenStatus status) {
    switch (status) {
      case KitchenStatus.pending:
        return Colors.orange;
      case KitchenStatus.preparing:
        return Colors.blue;
      case KitchenStatus.ready:
        return Colors.green;
      case KitchenStatus.delivered:
        return Colors.purple;
    }
  }

  String _getStatusLabel(KitchenStatus status) {
    switch (status) {
      case KitchenStatus.pending:
        return 'En attente';
      case KitchenStatus.preparing:
        return 'En préparation';
      case KitchenStatus.ready:
        return 'Prêt';
      case KitchenStatus.delivered:
        return 'Livré';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
