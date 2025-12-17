// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/kds/kds_screen.dart
/// 
/// Kitchen Display System Screen
/// Shows orders ready for kitchen preparation
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/pos_order.dart';
import '../../models/pos_order_status.dart';
import '../../models/order_type.dart';
import '../../providers/kds_provider.dart';
import '../../services/selection_formatter.dart';

/// KDS Screen - Main kitchen display
class KdsScreen extends ConsumerWidget {
  const KdsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(kdsOrdersProvider);
    
    return Scaffold(
      backgroundColor: context.colorScheme.surfaceVariant[900],
      appBar: AppBar(
        title: const Text('Cuisine - KDS'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'Aucune commande en cours',
                style: TextStyle(
                  color: context.onPrimary70,
                  fontSize: 20,
                ),
              ),
            );
          }
          
          // Group orders by status
          final paidOrders = orders.where((o) => o.status == PosOrderStatus.paid).toList();
          final preparingOrders = orders.where((o) => o.status == PosOrderStatus.inPreparation).toList();
          final readyOrders = orders.where((o) => o.status == PosOrderStatus.ready).toList();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (paidOrders.isNotEmpty) ...[
                  _buildSectionHeader('Nouvelles commandes', paidOrders.length, Colors.orange),
                  const SizedBox(height: 12),
                  _buildOrderGrid(context, ref, paidOrders),
                  const SizedBox(height: 24),
                ],
                if (preparingOrders.isNotEmpty) ...[
                  _buildSectionHeader('En préparation', preparingOrders.length, Colors.blue),
                  const SizedBox(height: 12),
                  _buildOrderGrid(context, ref, preparingOrders),
                  const SizedBox(height: 24),
                ],
                if (readyOrders.isNotEmpty) ...[
                  _buildSectionHeader('Prêtes', readyOrders.length, AppColors.success),
                  const SizedBox(height: 12),
                  _buildOrderGrid(context, ref, readyOrders),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Erreur: ${error.toString()}',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          color: color,
        ),
        const SizedBox(width: 12),
        Text(
          '$title ($count)',
          style: const TextStyle(
            color: context.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildOrderGrid(BuildContext context, WidgetRef ref, List<PosOrder> orders) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: orders.map((order) => _KdsOrderCard(order: order)).toList(),
    );
  }
}

/// KDS Order Card
class _KdsOrderCard extends ConsumerWidget {
  final PosOrder order;
  
  const _KdsOrderCard({required this.order});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kdsService = ref.watch(kdsServiceProvider);
    
    // Calculate elapsed time
    final elapsedMinutes = DateTime.now().difference(order.date).inMinutes;
    final isUrgent = elapsedMinutes > 15;
    
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceVariant[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUrgent ? AppColors.error : _getStatusColor(order.status),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande #${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    color: context.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${elapsedMinutes}min',
                  style: TextStyle(
                    color: isUrgent ? AppColors.error : context.onPrimary70,
                    fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          
          // Order details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order type
                Row(
                  children: [
                    Icon(
                      _getOrderTypeIcon(order.orderType),
                      color: context.onPrimary70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      OrderType.getLabel(order.orderType),
                      style: const TextStyle(
                        color: context.onPrimary70,
                        fontSize: 14,
                      ),
                    ),
                    if (order.tableNumber != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Table ${order.tableNumber}',
                        style: const TextStyle(
                          color: context.onPrimary70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                
                if (order.customerName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    order.customerName!,
                    style: const TextStyle(
                      color: context.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                const Divider(color: context.onPrimary24),
                const SizedBox(height: 8),
                
                // Items
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.quantity}x ${item.productName}',
                        style: const TextStyle(
                          color: context.onPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.selections.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text(
                            formatSelections(item.selections),
                            style: const TextStyle(
                              color: context.onPrimary70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
                
                if (order.baseOrder.comment != null && order.baseOrder.comment!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(color: context.onPrimary24),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.comment, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.baseOrder.comment!,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Actions
                _buildActions(context, ref, kdsService),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions(BuildContext context, WidgetRef ref, dynamic kdsService) {
    return Row(
      children: [
        if (order.status == PosOrderStatus.paid)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _startPreparation(context, ref, kdsService),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Commencer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: context.onPrimary,
              ),
            ),
          ),
        if (order.status == PosOrderStatus.inPreparation)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _markAsReady(context, ref, kdsService),
              icon: const Icon(Icons.check),
              label: const Text('Prêt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: context.onPrimary,
              ),
            ),
          ),
        if (order.status == PosOrderStatus.ready)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  SizedBox(width: 8),
                  Text(
                    'Prêt pour service',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Future<void> _startPreparation(BuildContext context, WidgetRef ref, dynamic kdsService) async {
    try {
      await kdsService.startPreparation(order.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Préparation démarrée')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _markAsReady(BuildContext context, WidgetRef ref, dynamic kdsService) async {
    try {
      await kdsService.markAsReady(order.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande marquée comme prête')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case PosOrderStatus.paid:
        return Colors.orange;
      case PosOrderStatus.inPreparation:
        return Colors.blue;
      case PosOrderStatus.ready:
        return AppColors.success;
      default:
        return context.colorScheme.surfaceVariant;
    }
  }
  
  IconData _getOrderTypeIcon(String orderType) {
    switch (orderType) {
      case OrderType.dineIn:
        return Icons.restaurant;
      case OrderType.takeaway:
        return Icons.shopping_bag;
      case OrderType.delivery:
        return Icons.delivery_dining;
      case OrderType.clickCollect:
        return Icons.store;
      default:
        return Icons.shopping_cart;
    }
  }
}
