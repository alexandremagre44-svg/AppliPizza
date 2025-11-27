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
  /// a published page with a matching pageKey, route, or Firestore doc ID.
  /// 
  /// Priority:
  /// 1. Try to resolve as a system page (if pageKey matches BuilderPageId)
  /// 2. Try to load directly from Firestore by docId (pageKey)
  /// 3. Try to find by pageKey field in all published pages
  /// 4. Try to find by route /page/:pageKey in all published pages
  /// 
  /// Example:
  /// ```dart
  /// final page = await resolver.resolveByKey('promo_noel', 'pizza_delizza');
  /// ```
  Future<BuilderPage?> resolveByKey(String pageKey, String appId) async {
    try {
      // 1. Try to match key to a known system page BuilderPageId
      final systemPageId = BuilderPageId.tryFromString(pageKey);
      if (systemPageId != null) {
        final resolved = await resolve(systemPageId, appId);
        if (resolved != null) {
          return resolved;
        }
      }
      
      // 2. Try to load directly from Firestore by docId
      final directPage = await _layoutService.loadPublishedByDocId(appId, pageKey);
      if (directPage != null && directPage.isEnabled) {
        return directPage;
      }
      
      // 3. Fallback: search in all published pages by pageKey or route
      final allPages = await _layoutService.loadAllPublishedPages(appId);
      
      // Try to find by pageKey field
      for (final page in allPages.values) {
        if (page.pageKey == pageKey && page.isEnabled) {
          return page;
        }
      }
      
      // Try to find by route /page/:pageKey
      final route = '/page/$pageKey';
      for (final page in allPages.values) {
        if (page.route == route && page.isEnabled) {
          return page;
        }
      }
      
      debugPrint('⚠️ [DynamicPageResolver] Page not found by key: $pageKey');
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
  /// Returns a map of pageKey (String) → BuilderPage for all published pages.
  Future<Map<String, BuilderPage>> getAllPublishedPages(String appId) async {
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
  
  /// Resolve a system page by its string ID
  /// 
  /// System pages: profile, cart, rewards, roulette
  /// 
  /// Returns the Builder page if it exists and is enabled.
  /// Returns null if the page doesn't exist or should use legacy fallback.
  /// 
  /// Example:
  /// ```dart
  /// final page = await resolver.resolveSystemPage('profile', 'pizza_delizza');
  /// if (page != null) {
  ///   // Render Builder page
  /// } else {
  ///   // Use legacy ProfileScreen
  /// }
  /// ```
  Future<BuilderPage?> resolveSystemPage(String pageId, String appId) async {
    try {
      // Map string pageId to BuilderPageId
      final builderPageId = _systemPageIdToBuilderPageId(pageId);
      
      if (builderPageId == null) {
        debugPrint('Unknown system page ID: $pageId');
        return null;
      }
      
      return await resolve(builderPageId, appId);
    } catch (e, stackTrace) {
      debugPrint('Error resolving system page $pageId for app $appId: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }
  
  /// Map string system page ID to BuilderPageId using SystemPages registry
  BuilderPageId? _systemPageIdToBuilderPageId(String pageId) {
    // Try direct mapping from Firestore ID
    final pageIdFromFirestore = SystemPages.getPageIdFromFirestoreId(pageId.toLowerCase());
    if (pageIdFromFirestore != null) {
      return pageIdFromFirestore;
    }
    
    // Fallback for French names
    switch (pageId.toLowerCase()) {
      case 'profil':
        return BuilderPageId.profile;
      case 'panier':
        return BuilderPageId.cart;
      case 'recompenses':
        return BuilderPageId.rewards;
      default:
        return null;
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

  /// Map route path to BuilderPageId using SystemPages registry
  BuilderPageId? _routeToPageId(String route) {
    // Use SystemPages registry for consistent mapping
    final config = SystemPages.getConfigByRoute(route);
    if (config != null) {
      return config.pageId;
    }
    
    // Fallback for custom pages not in system registry
    switch (route) {
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
      // System pages
      case 'profile':
      case 'profil':
        return BuilderPageId.profile;
      case 'cart':
      case 'panier':
        return BuilderPageId.cart;
      case 'rewards':
      case 'recompenses':
        return BuilderPageId.rewards;
      case 'roulette':
        return BuilderPageId.roulette;
      default:
        return null;
    }
  }
}
