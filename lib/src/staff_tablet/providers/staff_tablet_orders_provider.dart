// lib/src/staff_tablet/providers/staff_tablet_orders_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

// =============================================
// STAFF TABLET ORDERS PROVIDERS
// =============================================

/// Provider to get only today's orders from staff tablet
final staffTabletTodayOrdersProvider = Provider<List<Order>>(
  (ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);
    
    return ordersAsync.when(
      data: (orders) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        // Filter orders from staff tablet source created today
        return orders.where((order) {
          final orderDate = DateTime(order.date.year, order.date.month, order.date.day);
          return order.source == OrderSource.staffTablet && orderDate == today;
        }).toList()
          ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
      },
      loading: () => [],
      error: (_, __) => [],
    );
  },
  dependencies: [ordersStreamProvider],
);

/// Provider to get count of today's staff tablet orders
final staffTabletTodayOrdersCountProvider = Provider<int>(
  (ref) {
    final orders = ref.watch(staffTabletTodayOrdersProvider);
    return orders.length;
  },
  dependencies: [staffTabletTodayOrdersProvider],
);

/// Provider to get today's total revenue from staff tablet
final staffTabletTodayRevenueProvider = Provider<double>(
  (ref) {
    final orders = ref.watch(staffTabletTodayOrdersProvider);
    return orders.fold(0.0, (sum, order) => sum + order.total);
  },
  dependencies: [staffTabletTodayOrdersProvider],
);

/// Provider to get orders by status
final staffTabletOrdersByStatusProvider = Provider.family<List<Order>, String>(
  (ref, status) {
    final orders = ref.watch(staffTabletTodayOrdersProvider);
    return orders.where((order) => order.status == status).toList();
  },
  dependencies: [staffTabletTodayOrdersProvider],
);

/// Provider to get pending orders count
final staffTabletPendingOrdersCountProvider = Provider<int>(
  (ref) {
    final orders = ref.watch(staffTabletTodayOrdersProvider);
    return orders.where((order) => order.status == OrderStatus.pending).length;
  },
  dependencies: [staffTabletTodayOrdersProvider],
);

/// Provider to get ready orders count
final staffTabletReadyOrdersCountProvider = Provider<int>(
  (ref) {
    final orders = ref.watch(staffTabletTodayOrdersProvider);
    return orders.where((order) => order.status == OrderStatus.ready).length;
  },
  dependencies: [staffTabletTodayOrdersProvider],
);
