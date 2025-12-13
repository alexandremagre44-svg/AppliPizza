// lib/src/screens/admin/pos/providers/pos_order_provider.dart
/// 
/// Provider for managing POS orders
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/pos_order.dart';
import '../../../../models/pos_order_status.dart';
import '../../../../services/pos_order_service.dart';
import '../../../../providers/restaurant_provider.dart';

/// Provider for POS order service
final posOrderServiceProvider = Provider<PosOrderService>((ref) {
  final restaurant = ref.watch(currentRestaurantProvider);
  if (restaurant == null) {
    throw Exception('No active restaurant');
  }
  return PosOrderService(appId: restaurant.id);
});

/// Provider for watching session orders
final sessionOrdersProvider = StreamProvider.family<List<PosOrder>, String>((ref, sessionId) {
  final service = ref.watch(posOrderServiceProvider);
  return service.watchSessionOrders(sessionId);
});

/// Provider for watching orders by status
final ordersByStatusProvider = StreamProvider.family<List<PosOrder>, String>((ref, status) {
  final service = ref.watch(posOrderServiceProvider);
  return service.watchOrdersByStatus(status);
});

/// Provider for current order being processed
final currentPosOrderProvider = StateProvider<PosOrder?>((ref) => null);
