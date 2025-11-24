// lib/builder/services/builder_navigation_service.dart
// Service for managing dynamic navigation based on Builder B3 pages

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
/// If no bottomBar pages exist, this service will auto-create a default "home"
/// page once per appId (using autoInitDone flag in Firestore).
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

  /// Get all published pages for bottom navigation bar
  /// 
  /// Returns pages where:
  /// - displayLocation == 'bottomBar'
  /// - isEnabled == true
  /// - Sorted by order ASC
  /// 
  /// If no bottomBar pages exist and autoInitDone flag is not set,
  /// this method will auto-create a default "home" page.
  /// 
  /// Example:
  /// ```dart
  /// final service = BuilderNavigationService('pizza_delizza');
  /// final pages = await service.getBottomBarPages();
  /// ```
  Future<List<BuilderPage>> getBottomBarPages() async {
    try {
      // Load all published pages for this app
      final allPages = await _layoutService.loadAllPublishedPages(appId);
      
      // Filter pages for bottom bar
      var bottomBarPages = allPages.values
          .where((page) => 
              page.displayLocation == 'bottomBar' && 
              page.isEnabled)
          .toList();
      
      // If no bottomBar pages exist, try auto-create fallback
      if (bottomBarPages.isEmpty) {
        debugPrint('[BuilderNavigationService] ⚠️ No bottomBar pages found for appId: $appId');
        final autoCreatedPage = await _autoCreateIfEmpty();
        if (autoCreatedPage != null) {
          bottomBarPages = [autoCreatedPage];
        }
      }
      
      // Sort by order
      bottomBarPages.sort((a, b) => a.order.compareTo(b.order));
      
      return bottomBarPages;
    } catch (e, stackTrace) {
      debugPrint('[BuilderNavigationService] Error loading bottom bar pages: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Auto-create a default home page if none exists
  /// 
  /// Only runs once per appId (checks autoInitDone flag).
  /// Creates a "home" page with:
  /// - pageId: "home"
  /// - title: "Accueil"
  /// - icon: "home"
  /// - order: 1
  /// - displayLocation: "bottomBar"
  /// - blocks: []
  /// - published = true
  Future<BuilderPage?> _autoCreateIfEmpty() async {
    try {
      // Check if auto-init was already done
      final isAlreadyDone = await _autoInitService.isAutoInitDone(appId);
      if (isAlreadyDone) {
        debugPrint('[BuilderNavigationService] Auto-init already done for appId: $appId, skipping auto-create');
        return null;
      }

      debugPrint('[BuilderNavigationService] 🚀 FALLBACK TRIGGERED: Auto-creating default home page for appId: $appId');

      // Create the default home page
      final now = DateTime.now();
      final defaultPage = BuilderPage(
        pageId: BuilderPageId.home,
        appId: appId,
        name: 'Accueil',
        description: 'Page d\'accueil créée automatiquement',
        route: '/home',
        blocks: [],
        isEnabled: true,
        isDraft: true,
        displayLocation: 'bottomBar',
        icon: 'home',
        order: 1,
        createdAt: now,
        updatedAt: now,
      );

      // Save as draft first
      await _layoutService.saveDraft(defaultPage);
      debugPrint('[BuilderNavigationService] ✓ Draft saved for default home page');

      // Publish immediately (copy draft → published)
      await _layoutService.publishPage(
        defaultPage,
        userId: 'system_autoinit',
        shouldDeleteDraft: false,
      );
      debugPrint('[BuilderNavigationService] ✓ Default home page published');

      // Mark auto-init as done to prevent future auto-creates
      await _autoInitService.markAutoInitDone(appId);
      debugPrint('[BuilderNavigationService] ✓ Auto-init marked as done for appId: $appId');

      // Load and return the published page
      final publishedPage = await _layoutService.loadPublished(appId, BuilderPageId.home);
      
      debugPrint('[BuilderNavigationService] ✅ FALLBACK COMPLETE: Default home page created and returned');
      
      return publishedPage;
    } catch (e, stackTrace) {
      debugPrint('[BuilderNavigationService] ❌ Error in auto-create fallback: $e');
      if (kDebugMode) {
        debugPrint('Stack trace: $stackTrace');
      }
      return null;
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
