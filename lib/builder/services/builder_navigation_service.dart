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
import 'builder_page_service.dart';

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
  final BuilderPageService _pageService;

  BuilderNavigationService(
    this.appId, {
    BuilderLayoutService? layoutService,
    BuilderAutoInitService? autoInitService,
    BuilderPageService? pageService,
  })  : _layoutService = layoutService ?? BuilderLayoutService(),
        _autoInitService = autoInitService ?? BuilderAutoInitService(),
        _pageService = pageService ?? BuilderPageService();

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
  /// **Important:** This method checks total page count (active + inactive)
  /// to decide if auto-init is needed, respecting admin choices to deactivate
  /// pages like "Menu" or "Cart" without recreating them.
  /// 
  /// Example:
  /// ```dart
  /// final service = BuilderNavigationService('delizza');
  /// final pages = await service.getBottomBarPages();
  /// ```
  Future<List<BuilderPage>> getBottomBarPages() async {
    try {
      // Step 1: Load ALL system pages (active AND inactive)
      // This ensures we check total page existence, not just active ones
      final allSystemPages = await _layoutService.loadSystemPages(appId);
      
      // Step 2: Check if we need to create default pages
      // Only trigger auto-init if total pages < 2 (not filtered count)
      // This respects admin choices to deactivate pages
      // Note: We don't use the return value since we reload fresh data in Step 4
      if (allSystemPages.length < 2) {
        await _ensureMinimumPages(allSystemPages);
      }
      
      // Step 3: Fix empty system pages by injecting default content
      await _pageService.fixEmptySystemPages(appId);
      
      // Step 4: Reload and filter for active bottomBar pages only
      // Now apply the isActive filter for the final result
      final pages = await _layoutService.getBottomBarPages(appId: appId);
      
      // Log warning if no active pages (admin may have deactivated all)
      if (pages.isEmpty) {
        debugPrint('[BuilderNavigationService] ⚠️ No active bottomBar pages found');
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
  /// Includes default content modules for system pages to prevent empty pages
  BuilderPage _createDefaultPage({
    required BuilderPageId pageId,
    required String name,
    required String description,
    required String icon,
    required int order,
    required DateTime now,
  }) {
    // Generate default content blocks based on page type
    final defaultBlocks = _getDefaultBlocksForPage(pageId);
    
    return BuilderPage(
      pageId: pageId,
      appId: appId,
      name: name,
      description: description,
      route: '/${pageId.value}',
      blocks: defaultBlocks,
      draftLayout: defaultBlocks,
      publishedLayout: defaultBlocks,
      isEnabled: true,
      isDraft: false,
      displayLocation: 'bottomBar',
      icon: icon,
      order: order,
      isSystemPage: pageId.isSystemPage,
      isActive: true,
      bottomNavIndex: order,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  /// Get default content blocks for a page based on its type
  /// This ensures pages are never empty when auto-initialized
  /// 
  /// Note: This is similar to DefaultPageCreator._buildDefaultBlocks but 
  /// specifically includes SystemBlock modules for system pages (cart, profile, etc.)
  /// which are required for proper runtime rendering. DefaultPageCreator returns
  /// empty blocks for system pages as they were originally meant to use legacy screens.
  List<BuilderBlock> _getDefaultBlocksForPage(BuilderPageId pageId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    switch (pageId) {
      case BuilderPageId.home:
        // Home page gets a hero block and product list
        return [
          BuilderBlock(
            id: 'hero_auto_$timestamp',
            type: BlockType.hero,
            order: 0,
            config: {
              'title': 'Bienvenue',
              'subtitle': 'Découvrez nos délicieuses pizzas',
              'imageUrl': '',
              'buttonLabel': 'Voir le menu',
              'tapAction': 'openPage',
            },
          ),
          BuilderBlock(
            id: 'product_list_auto_$timestamp',
            type: BlockType.productList,
            order: 1,
            config: {
              'title': 'Nos spécialités',
              'mode': 'featured',
              'layout': 'grid',
              'limit': 4,
              'columns': 2,
            },
          ),
        ];
      case BuilderPageId.menu:
        return [
          SystemBlock(
            id: 'menu_catalog_auto_$timestamp',
            moduleType: 'menu_catalog',
            order: 0,
          ),
        ];
      case BuilderPageId.cart:
        return [
          SystemBlock(
            id: 'cart_module_auto_$timestamp',
            moduleType: 'cart_module',
            order: 0,
          ),
        ];
      case BuilderPageId.profile:
        return [
          SystemBlock(
            id: 'profile_module_auto_$timestamp',
            moduleType: 'profile_module',
            order: 0,
          ),
        ];
      case BuilderPageId.roulette:
        return [
          SystemBlock(
            id: 'roulette_module_auto_$timestamp',
            moduleType: 'roulette_module',
            order: 0,
          ),
        ];
      default:
        // For other pages, return empty (they can be customized later)
        return [];
    }
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
