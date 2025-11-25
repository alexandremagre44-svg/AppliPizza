// lib/builder/services/builder_navigation_service.dart
// Service for managing dynamic navigation based on Builder B3 pages
//
// New Firestore structure:
// restaurants/{restaurantId}/pages_system (navigation order)
// restaurants/{restaurantId}/pages_published (content)

import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'builder_layout_service.dart';
import 'builder_autoinit_service.dart';

/// Service for managing dynamic navigation based on Builder B3 pages
/// 
/// This service filters and organizes pages for different display locations:
/// - bottomBar: Pages that appear in bottom navigation bar
/// - hidden: Pages accessible only via actions (not visible in nav)
/// - internal: Internal system pages (cart, profile, checkout, login)
/// 
/// Pages are loaded from:
/// 1. pages_system (defines order and navigation structure)
/// 2. pages_published (provides content/blocks for each page)
class BuilderNavigationService {
  final String appId;
  final BuilderLayoutService _layoutService;
  final BuilderAutoInitService _autoInitService;

  BuilderNavigationService(
    this.appId, {
    BuilderLayoutService? layoutService,
    BuilderAutoInitService? autoInitService,
  })  : _layoutService = layoutService ?? BuilderLayoutService(),
        _autoInitService = autoInitService ?? BuilderAutoInitService();

  /// Get all pages for bottom navigation bar
  /// 
  /// Returns pages from pages_system where:
  /// - displayLocation == 'bottomBar'
  /// - isEnabled == true
  /// - Sorted by order ASC
  /// 
  /// The pages_system collection defines the navigation structure,
  /// while pages_published provides the actual content for each page.
  /// 
  /// Example:
  /// ```dart
  /// final service = BuilderNavigationService('delizza');
  /// final pages = await service.getBottomBarPages();
  /// ```
  Future<List<BuilderPage>> getBottomBarPages() async {
    try {
      // Use the layout service's new getBottomBarPages method
      // which loads from pages_system first, then fallback to pages_published
      final pages = await _layoutService.getBottomBarPages();
      
      // Ensure we have at least 2 items (requirement)
      if (pages.length < 2) {
        debugPrint('[BuilderNavigationService] ⚠️ Less than 2 bottomBar pages found');
        // Try auto-create fallback if needed
        final fallbackPages = await _ensureMinimumPages(pages);
        if (fallbackPages.isNotEmpty) {
          return fallbackPages;
        }
      }
      
      return pages;
    } catch (e, stackTrace) {
      debugPrint('[BuilderNavigationService] Error loading bottom bar pages: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Ensure at least 2 pages exist for bottom bar
  /// Creates default home and menu pages if needed
  Future<List<BuilderPage>> _ensureMinimumPages(List<BuilderPage> currentPages) async {
    if (currentPages.length >= 2) {
      return currentPages;
    }
    
    try {
      // Check if auto-init was already done
      final isAlreadyDone = await _autoInitService.isAutoInitDone(appId);
      if (isAlreadyDone) {
        debugPrint('[BuilderNavigationService] Auto-init already done, returning current pages');
        return currentPages;
      }

      debugPrint('[BuilderNavigationService] 🚀 Creating default navigation pages');

      final now = DateTime.now();
      
      // Create default navigation pages using helper
      final defaultPages = [
        _createDefaultPage(
          pageId: BuilderPageId.home,
          name: 'Accueil',
          description: 'Page d\'accueil',
          icon: 'home',
          order: 1,
          now: now,
        ),
        _createDefaultPage(
          pageId: BuilderPageId.menu,
          name: 'Menu',
          description: 'Catalogue de produits',
          icon: 'restaurant_menu',
          order: 2,
          now: now,
        ),
        _createDefaultPage(
          pageId: BuilderPageId.cart,
          name: 'Panier',
          description: 'Votre panier',
          icon: 'shopping_cart',
          order: 3,
          now: now,
        ),
        _createDefaultPage(
          pageId: BuilderPageId.profile,
          name: 'Profil',
          description: 'Votre profil',
          icon: 'person',
          order: 4,
          now: now,
        ),
      ];
      
      // Publish all default pages
      for (final page in defaultPages) {
        await _layoutService.publishPage(page, userId: 'system_autoinit');
      }
      
      // Mark auto-init as done
      await _autoInitService.markAutoInitDone(appId);
      debugPrint('[BuilderNavigationService] ✅ Default navigation pages created');
      
      return defaultPages;
    } catch (e, stackTrace) {
      debugPrint('[BuilderNavigationService] ❌ Error creating default pages: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return currentPages;
    }
  }

  /// Helper to create a default BuilderPage with common parameters
  BuilderPage _createDefaultPage({
    required BuilderPageId pageId,
    required String name,
    required String description,
    required String icon,
    required int order,
    required DateTime now,
  }) {
    return BuilderPage(
      pageId: pageId,
      appId: appId,
      name: name,
      description: description,
      route: '/${pageId.value}',
      blocks: [],
      isEnabled: true,
      isDraft: false,
      displayLocation: 'bottomBar',
      icon: icon,
      order: order,
      isSystemPage: pageId.isSystemPage, // Use enum definition
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Get all hidden pages
  /// 
  /// Returns pages where:
  /// - displayLocation == 'hidden'
  /// - isEnabled == true
  /// 
  /// These pages are accessible via NavigateToPage actions but not visible in navigation.
  Future<List<BuilderPage>> getHiddenPages() async {
    try {
      final allPages = await _layoutService.loadAllPublishedPages(appId);
      
      return allPages.values
          .where((page) => 
              page.displayLocation == 'hidden' && 
              page.isEnabled)
          .toList();
    } catch (e, stackTrace) {
      debugPrint('Error loading hidden pages: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Get all internal pages
  /// 
  /// Returns pages where:
  /// - displayLocation == 'internal'
  /// - isEnabled == true
  /// 
  /// These are internal system pages like cart, profile, checkout, login.
  Future<List<BuilderPage>> getInternalPages() async {
    try {
      final allPages = await _layoutService.loadAllPublishedPages(appId);
      
      return allPages.values
          .where((page) => 
              page.displayLocation == 'internal' && 
              page.isEnabled)
          .toList();
    } catch (e, stackTrace) {
      debugPrint('Error loading internal pages: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Get a specific page by route
  /// 
  /// Useful for navigation and routing logic.
  Future<BuilderPage?> getPageByRoute(String route) async {
    try {
      final allPages = await _layoutService.loadAllPublishedPages(appId);
      
      return allPages.values.firstWhere(
        (page) => page.route == route,
        orElse: () => throw StateError('Page not found'),
      );
    } catch (e, stackTrace) {
      debugPrint('Error finding page by route $route: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
    }
  }

  /// Get all enabled pages (any display location)
  /// 
  /// Useful for admin interfaces and debugging.
  Future<List<BuilderPage>> getAllEnabledPages() async {
    try {
      final allPages = await _layoutService.loadAllPublishedPages(appId);
      
      return allPages.values
          .where((page) => page.isEnabled)
          .toList();
    } catch (e, stackTrace) {
      debugPrint('Error loading all enabled pages: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Get page count by display location
  /// 
  /// Returns a map with counts for each display location.
  Future<Map<String, int>> getPageCounts() async {
    try {
      final allPages = await _layoutService.loadAllPublishedPages(appId);
      final counts = <String, int>{
        'bottomBar': 0,
        'hidden': 0,
        'internal': 0,
      };
      
      for (final page in allPages.values) {
        if (page.isEnabled) {
          counts[page.displayLocation] = (counts[page.displayLocation] ?? 0) + 1;
        }
      }
      
      return counts;
    } catch (e, stackTrace) {
      debugPrint('Error counting pages: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return {'bottomBar': 0, 'hidden': 0, 'internal': 0};
    }
  }
}
