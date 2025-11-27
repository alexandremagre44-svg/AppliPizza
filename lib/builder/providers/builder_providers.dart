// lib/builder/providers/builder_providers.dart
// Riverpod providers for Builder B3 system

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../../src/providers/restaurant_provider.dart';

/// Service provider for BuilderLayoutService
/// Provides singleton instance of the layout service
final builderLayoutServiceProvider = Provider<BuilderLayoutService>((ref) {
  return BuilderLayoutService();
});

/// Provider for published home page layout
/// Returns null if no published layout exists
/// 
/// Usage:
/// ```dart
/// final homeLayoutAsync = ref.watch(homePagePublishedProvider);
/// homeLayoutAsync.when(
///   data: (page) => page != null ? BuilderRuntimeRenderer(blocks: page.blocks) : LegacyHome(),
///   loading: () => LoadingIndicator(),
///   error: (err, stack) => ErrorWidget(),
/// );
/// ```
final homePagePublishedProvider = FutureProvider<BuilderPage?>((ref) async {
  final service = ref.watch(builderLayoutServiceProvider);
  final appId = ref.watch(currentRestaurantProvider).id;
  return await service.loadPublished(appId, BuilderPageId.home);
});

/// Provider for published menu page layout
final menuPagePublishedProvider = FutureProvider<BuilderPage?>((ref) async {
  final service = ref.watch(builderLayoutServiceProvider);
  final appId = ref.watch(currentRestaurantProvider).id;
  return await service.loadPublished(appId, BuilderPageId.menu);
});

/// Provider for published promo page layout
final promoPagePublishedProvider = FutureProvider<BuilderPage?>((ref) async {
  final service = ref.watch(builderLayoutServiceProvider);
  final appId = ref.watch(currentRestaurantProvider).id;
  return await service.loadPublished(appId, BuilderPageId.promo);
});

/// Generic family provider for any page
/// Uses Riverpod family for proper caching and state management
/// 
/// Usage:
/// ```dart
/// final aboutPage = ref.watch(publishedPageProvider(BuilderPageId.about));
/// ```
final publishedPageProvider = FutureProvider.family<BuilderPage?, BuilderPageId>(
  (ref, pageId) async {
    final service = ref.watch(builderLayoutServiceProvider);
    final appId = ref.watch(currentRestaurantProvider).id;
    return await service.loadPublished(appId, pageId);
  },
);

/// Stream provider for real-time updates of home page
/// Use this if you need live updates when layout changes in Firestore
final homePagePublishedStreamProvider = StreamProvider<BuilderPage?>((ref) {
  final service = ref.watch(builderLayoutServiceProvider);
  final appId = ref.watch(currentRestaurantProvider).id;
  return service.watchPublished(appId, BuilderPageId.home);
});
