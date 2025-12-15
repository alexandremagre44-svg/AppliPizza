// lib/src/providers/kds_provider.dart
/// 
/// Provider for KDS (Kitchen Display System)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pos_order.dart';
import '../models/pos_order_status.dart';
import '../services/kds_service.dart';
import 'restaurant_provider.dart';

/// Provider for KDS service
final kdsServiceProvider = Provider<KdsService>(
  (ref) {
    final appId = ref.watch(currentRestaurantProvider).id;
    return KdsService(appId: appId);
  },
  dependencies: [currentRestaurantProvider],
);

/// Provider for watching all kitchen orders
final kdsOrdersProvider = StreamProvider<List<PosOrder>>(
  (ref) {
    final service = ref.watch(kdsServiceProvider);
    return service.watchKitchenOrders();
  },
  dependencies: [kdsServiceProvider],
);

/// Provider for watching orders by status
final kdsPaidOrdersProvider = StreamProvider<List<PosOrder>>(
  (ref) {
    final service = ref.watch(kdsServiceProvider);
    return service.watchOrdersByStatus(PosOrderStatus.paid);
  },
  dependencies: [kdsServiceProvider],
);

final kdsInPreparationOrdersProvider = StreamProvider<List<PosOrder>>(
  (ref) {
    final service = ref.watch(kdsServiceProvider);
    return service.watchOrdersByStatus(PosOrderStatus.inPreparation);
  },
  dependencies: [kdsServiceProvider],
);

final kdsReadyOrdersProvider = StreamProvider<List<PosOrder>>(
  (ref) {
    final service = ref.watch(kdsServiceProvider);
    return service.watchOrdersByStatus(PosOrderStatus.ready);
  },
  dependencies: [kdsServiceProvider],
);
