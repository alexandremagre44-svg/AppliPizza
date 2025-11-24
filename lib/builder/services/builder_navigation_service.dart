// lib/builder/services/builder_navigation_service.dart
// Service for managing dynamic navigation based on Builder B3 pages

import '../models/models.dart';
import 'builder_layout_service.dart';

/// Service for managing dynamic navigation based on Builder B3 pages
/// 
/// This service filters and organizes pages for different display locations:
/// - bottomBar: Pages that appear in bottom navigation bar
/// - hidden: Pages accessible only via actions (not visible in nav)
/// - internal: Internal system pages (cart, profile, checkout, login)
class BuilderNavigationService {
  final String appId;
  final BuilderLayoutService _layoutService;

  BuilderNavigationService(this.appId, {BuilderLayoutService? layoutService})
      : _layoutService = layoutService ?? BuilderLayoutService();

  /// Get all published pages for bottom navigation bar
  /// 
  /// Returns pages where:
  /// - displayLocation == 'bottomBar'
  /// - isEnabled == true
  /// - Sorted by order ASC
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
      final bottomBarPages = allPages.values
          .where((page) => 
              page.displayLocation == 'bottomBar' && 
              page.isEnabled)
          .toList();
      
      // Sort by order
      bottomBarPages.sort((a, b) => a.order.compareTo(b.order));
      
      return bottomBarPages;
    } catch (e) {
      print('Error loading bottom bar pages: $e');
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
    } catch (e) {
      print('Error loading hidden pages: $e');
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
    } catch (e) {
      print('Error loading internal pages: $e');
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
    } catch (e) {
      print('Error finding page by route $route: $e');
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
    } catch (e) {
      print('Error loading all enabled pages: $e');
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
    } catch (e) {
      print('Error counting pages: $e');
      return {'bottomBar': 0, 'hidden': 0, 'internal': 0};
    }
  }
}
