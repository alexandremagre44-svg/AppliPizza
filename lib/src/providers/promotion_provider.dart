// lib/src/providers/promotion_provider.dart
// Provider for promotion service with multi-tenant support

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/promotion.dart';
import '../services/promotion_service.dart';
import 'restaurant_provider.dart';

/// Provider for PromotionService
final promotionServiceProvider = Provider<PromotionService>((ref) {
  final appId = ref.watch(currentRestaurantProvider).id;
  return PromotionService(appId: appId);
});

/// Stream provider for all promotions
final promotionsProvider = StreamProvider<List<Promotion>>((ref) {
  final service = ref.watch(promotionServiceProvider);
  return service.watchPromotions();
});

/// Provider for active promotions
final activePromotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  final service = ref.watch(promotionServiceProvider);
  return await service.getActivePromotions();
});

/// Provider for home banner promotions
final homeBannerPromotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  final service = ref.watch(promotionServiceProvider);
  return await service.getHomeBannerPromotions();
});

/// Provider for promo block promotions
final promoBlockPromotionsProvider = FutureProvider<List<Promotion>>((ref) async {
  final service = ref.watch(promotionServiceProvider);
  return await service.getPromoBlockPromotions();
});
