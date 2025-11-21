// lib/src/studio/providers/banner_provider.dart
// Riverpod providers for banner management with draft support

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/banner_config.dart';
import '../../services/banner_service.dart';

/// Service provider for banners
final bannerServiceProvider = Provider<BannerService>((ref) {
  return BannerService();
});

/// Stream provider for all banners
final bannersProvider = StreamProvider<List<BannerConfig>>((ref) {
  final service = ref.watch(bannerServiceProvider);
  return service.watchBanners();
});

/// Stream provider for active banners only (enabled + within date range)
final activeBannersProvider = StreamProvider<List<BannerConfig>>((ref) {
  final bannersAsync = ref.watch(bannersProvider);
  return bannersAsync.when(
    data: (banners) => Stream.value(
      banners.where((banner) => banner.isCurrentlyActive).toList(),
    ),
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Future provider for one-time fetch
final bannersFutureProvider = FutureProvider<List<BannerConfig>>((ref) async {
  final service = ref.watch(bannerServiceProvider);
  return await service.getAllBanners();
});

/// State provider for draft banners (local changes before publish)
final draftBannersProvider = StateProvider<List<BannerConfig>?>((ref) => null);

/// State provider for tracking unsaved banner changes
final hasUnsavedBannerChangesProvider = StateProvider<bool>((ref) => false);

/// Provider that returns draft banners if available, otherwise published banners
final effectiveBannersProvider = Provider<AsyncValue<List<BannerConfig>>>((ref) {
  final draftBanners = ref.watch(draftBannersProvider);
  
  if (draftBanners != null) {
    // Return draft banners (wrapped in AsyncValue for consistency)
    return AsyncValue.data(draftBanners);
  }
  
  // Return published banners from stream
  return ref.watch(bannersProvider);
});
