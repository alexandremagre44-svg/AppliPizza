// lib/builder/providers/builder_providers.dart
// Riverpod providers for Builder B3 system

import 'package:flutter/foundation.dart';
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

/// Provider for dynamic initial route based on bottom navigation pages
/// 
/// Returns the route of the first page in the bottom navigation bar (position 0).
/// Falls back to '/menu' if no pages are available.
/// 
/// This provider exposes the dynamic landing page logic for use throughout the app.
/// The actual navigation is handled by:
/// - SplashScreen._handleSmartNavigation() on app launch
/// - LoginScreen._navigateToDynamicLandingPage() after authentication
/// 
/// The landing page changes automatically if the order of pages in the Builder changes.
/// 
/// Usage:
/// ```dart
/// final initialRouteAsync = ref.watch(initialRouteProvider);
/// initialRouteAsync.when(
///   data: (route) => context.go(route),
///   loading: () => context.go('/menu'),
///   error: (_, __) => context.go('/menu'),
/// );
/// ```
final initialRouteProvider = FutureProvider<String>((ref) async {
  final appId = ref.watch(currentRestaurantProvider).id;
  final service = BuilderNavigationService(appId);
  
  try {
    final pages = await service.getBottomBarPages();
    
    if (pages.isNotEmpty) {
      final route = pages.first.route;
      // Validate route format
      if (route.isNotEmpty && route.startsWith('/')) {
        debugPrint('[Landing] Initial route = $route (from pages.first)');
        return route;
      }
    }
  } catch (e) {
    debugPrint('[Landing] Error loading initial route: $e');
  }
  
  // Fallback to /menu if no valid pages found
  debugPrint('[Landing] Initial route = /menu (fallback)');
  return '/menu';
});
