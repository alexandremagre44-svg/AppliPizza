// lib/src/providers/popup_provider.dart
// Provider for popup service with multi-tenant support

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/popup_config.dart';
import '../services/popup_service.dart';
import 'restaurant_provider.dart';

/// Provider for PopupService scoped to the current restaurant
final popupServiceProvider = Provider<PopupService>(
  (ref) {
    final config = ref.watch(currentRestaurantProvider);
    final appId = config.isValid ? config.id : 'delizza';
    return PopupService(appId: appId);
  },
  dependencies: [currentRestaurantProvider],
);

/// Stream provider for all popups
final popupsProvider = StreamProvider<List<PopupConfig>>(
  (ref) {
    final service = ref.watch(popupServiceProvider);
    return service.watchPopups();
  },
  dependencies: [popupServiceProvider],
);

/// Provider for active popups
final activePopupsProvider = FutureProvider<List<PopupConfig>>(
  (ref) async {
    final service = ref.watch(popupServiceProvider);
    return await service.getActivePopups();
  },
  dependencies: [popupServiceProvider],
);
