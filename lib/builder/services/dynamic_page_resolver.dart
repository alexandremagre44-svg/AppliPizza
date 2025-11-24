// lib/builder/services/dynamic_page_resolver.dart
// Service to resolve Builder pages dynamically from Firestore

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'builder_layout_service.dart';

/// Service to resolve Builder pages dynamically
/// 
/// This service loads BuilderPage instances from Firestore based on:
/// - Route path (e.g., /home, /menu, /page/promo)
/// - Page ID (e.g., BuilderPageId.home, BuilderPageId.menu)
/// - Custom page keys for dynamic pages
/// 
/// Returns the Builder page if it exists, or null to fallback to legacy screens.
class DynamicPageResolver {
  final BuilderLayoutService _layoutService;
  
  DynamicPageResolver({BuilderLayoutService? layoutService})
      : _layoutService = layoutService ?? BuilderLayoutService();

  /// Resolve a BuilderPage by pageId
  /// 
  /// Loads the published version of the page from Firestore.
  /// Returns null if the page doesn't exist, isn't published, or isn't enabled.
  /// 
  /// Note: loadPublished() already returns only published pages (not drafts).
  /// The isEnabled check ensures the page is active.
  /// 
  /// Example:
  /// ```dart
  /// final resolver = DynamicPageResolver();
  /// final homePage = await resolver.resolve(BuilderPageId.home, 'pizza_delizza');
  /// ```
  Future<BuilderPage?> resolve(BuilderPageId pageId, String appId) async {
    try {
      final page = await _layoutService.loadPublished(appId, pageId);
      
      // loadPublished returns only published pages (not drafts)
      // We additionally check isEnabled to ensure the page is active
      if (page != null && page.isEnabled) {
        return page;
      }
      
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error resolving page $pageId for app $appId: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Resolve a BuilderPage by route path
  /// 
  /// Attempts to match the route to a known page:
  /// - /home → BuilderPageId.home
  /// - /menu → BuilderPageId.menu
  /// - /promo → BuilderPageId.promo
  /// - /about → BuilderPageId.about
  /// - /contact → BuilderPageId.contact
  /// 
  /// Returns null if no matching page is found.
  /// 
  /// Example:
  /// ```dart
  /// final page = await resolver.resolveByRoute('/home', 'pizza_delizza');
  /// ```
  Future<BuilderPage?> resolveByRoute(String route, String appId) async {
    try {
      // Normalize route (remove trailing slash, query params)
      final normalizedRoute = _normalizeRoute(route);
      
      // Try to match route to a BuilderPageId
      final pageId = _routeToPageId(normalizedRoute);
      
      if (pageId != null) {
        return await resolve(pageId, appId);
      }
      
      // If not a standard route, try to find by route in all published pages
      final allPages = await _layoutService.loadAllPublishedPages(appId);
      
      for (final page in allPages.values) {
        if (page.route == normalizedRoute && page.isEnabled) {
          return page;
        }
      }
      
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error resolving page by route $route for app $appId: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Resolve a BuilderPage by custom page key
  /// 
  /// For dynamic pages like /page/:pageKey, this method attempts to find
  /// a published page with a matching route or pageId value.
  /// 
  /// Example:
  /// ```dart
  /// final page = await resolver.resolveByKey('promo-du-jour', 'pizza_delizza');
  /// ```
  Future<BuilderPage?> resolveByKey(String pageKey, String appId) async {
    try {
      // Try to match key to a BuilderPageId
      final pageId = _keyToPageId(pageKey);
      if (pageId != null) {
        return await resolve(pageId, appId);
      }
      
      // Try to find by route /page/:pageKey
      final route = '/page/$pageKey';
      final allPages = await _layoutService.loadAllPublishedPages(appId);
      
      for (final page in allPages.values) {
        if (page.route == route && page.isEnabled) {
          return page;
        }
      }
      
      // Try to match by pageId value
      for (final page in allPages.values) {
        if (page.pageId.value == pageKey && page.isEnabled) {
          return page;
        }
      }
      
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error resolving page by key $pageKey for app $appId: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Check if a Builder page exists for a given pageId
  /// 
  /// Useful for determining whether to show Builder content or legacy fallback.
  Future<bool> hasBuilderPage(BuilderPageId pageId, String appId) async {
    final page = await resolve(pageId, appId);
    return page != null;
  }

  /// Get all published pages for an app
  /// 
  /// Returns a map of pageId → BuilderPage for all published pages.
  Future<Map<BuilderPageId, BuilderPage>> getAllPublishedPages(String appId) async {
    try {
      return await _layoutService.loadAllPublishedPages(appId);
    } catch (e, stackTrace) {
      debugPrint('Error loading all published pages for app $appId: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return {};
    }
  }

  // ==================== PRIVATE HELPERS ====================

  /// Normalize route by removing trailing slash and query parameters
  String _normalizeRoute(String route) {
    // Remove query parameters
    final withoutQuery = route.split('?').first;
    
    // Remove trailing slash (except for root /)
    if (withoutQuery.length > 1 && withoutQuery.endsWith('/')) {
      return withoutQuery.substring(0, withoutQuery.length - 1);
    }
    
    return withoutQuery;
  }

  /// Map route path to BuilderPageId
  BuilderPageId? _routeToPageId(String route) {
    switch (route) {
      case '/home':
        return BuilderPageId.home;
      case '/menu':
        return BuilderPageId.menu;
      case '/promo':
        return BuilderPageId.promo;
      case '/about':
        return BuilderPageId.about;
      case '/contact':
        return BuilderPageId.contact;
      default:
        return null;
    }
  }

  /// Map page key to BuilderPageId
  BuilderPageId? _keyToPageId(String key) {
    switch (key.toLowerCase()) {
      case 'home':
        return BuilderPageId.home;
      case 'menu':
        return BuilderPageId.menu;
      case 'promo':
      case 'promotions':
        return BuilderPageId.promo;
      case 'about':
      case 'a-propos':
        return BuilderPageId.about;
      case 'contact':
        return BuilderPageId.contact;
      default:
        return null;
    }
  }
}
