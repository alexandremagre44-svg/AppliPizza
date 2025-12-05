// lib/src/providers/promotion_provider.dart
// Provider for promotion service with multi-tenant support

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/promotion.dart';
import '../services/promotion_service.dart';
import 'restaurant_provider.dart';
import 'restaurant_plan_provider.dart';
import '../../white_label/core/module_id.dart';

/// Provider for PromotionService
final promotionServiceProvider = Provider<PromotionService>(
  (ref) {
    final config = ref.watch(currentRestaurantProvider);
    // Use default 'delizza' if config is invalid (should not happen in normal usage)
    final appId = config.isValid ? config.id : 'delizza';
    return PromotionService(appId: appId);
  },
  dependencies: [currentRestaurantProvider],
);

/// Stream provider for all promotions
/// Module guard: requires promotions module
final promotionsProvider = StreamProvider<List<Promotion>>((ref) {
  // Module guard: promotions module required
  final flags = ref.watch(restaurantFeatureFlagsProvider);
  if (flags != null && !flags.has(ModuleId.promotions)) {
    return Stream.value([]);
  }
  
  final service = ref.watch(promotionServiceProvider);
  return service.watchPromotions();
});

/// Provider for active promotions
/// Module guard: requires promotions module
final activePromotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  // Module guard: promotions module required
  final flags = ref.watch(restaurantFeatureFlagsProvider);
  if (flags != null && !flags.has(ModuleId.promotions)) {
    return [];
  }
  
  final service = ref.watch(promotionServiceProvider);
  return await service.getActivePromotions();
});

/// Provider for home banner promotions
/// Module guard: requires promotions module
final homeBannerPromotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  // Module guard: promotions module required
  final flags = ref.watch(restaurantFeatureFlagsProvider);
  if (flags != null && !flags.has(ModuleId.promotions)) {
    return [];
  }
  
  final service = ref.watch(promotionServiceProvider);
  return await service.getHomeBannerPromotions();
});

/// Provider for promo block promotions
/// Module guard: requires promotions module
final promoBlockPromotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  // Module guard: promotions module required
  final flags = ref.watch(restaurantFeatureFlagsProvider);
  if (flags != null && !flags.has(ModuleId.promotions)) {
    return [];
  }
  
  final service = ref.watch(promotionServiceProvider);
  return await service.getPromoBlockPromotions();
});
