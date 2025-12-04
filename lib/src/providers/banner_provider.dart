// lib/src/providers/banner_provider.dart
// Provider for banner service with multi-tenant support

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/banner_config.dart';
import '../services/banner_service.dart';
import 'restaurant_provider.dart';

/// Provider for BannerService scoped to the current restaurant
final bannerServiceProvider = Provider<BannerService>((ref) {
  final config = ref.watch(currentRestaurantProvider);
  final appId = config.isValid ? config.id : 'delizza';
  return BannerService(appId: appId);
});

/// Stream provider for all banners
final bannersProvider = StreamProvider<List<BannerConfig>>((ref) {
  final service = ref.watch(bannerServiceProvider);
  return service.watchBanners();
});

/// Provider for active banners
final activeBannersProvider = FutureProvider<List<BannerConfig>>((ref) async {
  final service = ref.watch(bannerServiceProvider);
  return await service.getActiveBanners();
});
