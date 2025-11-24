// lib/builder/models/builder_pages_registry.dart
// Registry for all Builder B3 pages with metadata

import 'builder_enums.dart';

/// Metadata for a Builder page
class BuilderPageMetadata {
  final BuilderPageId pageId;
  final String name;
  final String description;
  final String route;
  final String icon;

  const BuilderPageMetadata({
    required this.pageId,
    required this.name,
    required this.description,
    required this.route,
    required this.icon,
  });
}

/// Global registry of all Builder pages
class BuilderPagesRegistry {
  static const List<BuilderPageMetadata> pages = [
    BuilderPageMetadata(
      pageId: BuilderPageId.home,
      name: 'Accueil',
      description: 'Page d\'accueil principale de l\'application',
      route: '/home',
      icon: '🏠',
    ),
    BuilderPageMetadata(
      pageId: BuilderPageId.menu,
      name: 'Menu',
      description: 'Catalogue de produits et menu',
      route: '/menu',
      icon: '📋',
    ),
    BuilderPageMetadata(
      pageId: BuilderPageId.promo,
      name: 'Promotions',
      description: 'Page des promotions et offres spéciales',
      route: '/promo',
      icon: '🎁',
    ),
    BuilderPageMetadata(
      pageId: BuilderPageId.about,
      name: 'À propos',
      description: 'Informations sur le restaurant',
      route: '/about',
      icon: 'ℹ️',
    ),
    BuilderPageMetadata(
      pageId: BuilderPageId.contact,
      name: 'Contact',
      description: 'Coordonnées et formulaire de contact',
      route: '/contact',
      icon: '📞',
    ),
  ];

  /// Get metadata for a specific page
  static BuilderPageMetadata getMetadata(BuilderPageId pageId) {
    return pages.firstWhere(
      (page) => page.pageId == pageId,
      orElse: () => pages[0],
    );
  }

  /// Get all page IDs
  static List<BuilderPageId> getAllPageIds() {
    return pages.map((p) => p.pageId).toList();
  }

  /// Get all routes
  static List<String> getAllRoutes() {
    return pages.map((p) => p.route).toList();
  }

  /// Get page by route
  static BuilderPageMetadata? getByRoute(String route) {
    try {
      return pages.firstWhere((page) => page.route == route);
    } catch (e) {
      return null;
    }
  }

  /// Filter pages by display location
  /// 
  /// This is a helper for working with page metadata.
  /// For actual page filtering with displayLocation, use BuilderNavigationService.
  static List<BuilderPageMetadata> filterByRoute(bool Function(String route) predicate) {
    return pages.where((page) => predicate(page.route)).toList();
  }

  /// Check if a route exists in the registry
  static bool hasRoute(String route) {
    return pages.any((page) => page.route == route);
  }

  /// Get page by key (pageId value as string)
  /// 
  /// Useful for resolving pages by their string key.
  /// Returns null if no matching page is found.
  /// 
  /// Example:
  /// ```dart
  /// final metadata = BuilderPagesRegistry.getPageByKey('home');
  /// ```
  static BuilderPageMetadata? getPageByKey(String key) {
    try {
      return pages.firstWhere(
        (page) => page.pageId.value == key.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Filter pages by displayLocation type
  /// 
  /// Note: This filters metadata only. For actual BuilderPage instances
  /// with displayLocation filtering, use BuilderNavigationService.
  /// 
  /// Possible displayLocation values: 'bottomBar', 'hidden', 'internal'
  static List<BuilderPageMetadata> filterByDisplayLocation(String displayLocation) {
    // Since metadata doesn't have displayLocation, we return all pages
    // This method is here for API compatibility
    // Real filtering happens in BuilderNavigationService on actual BuilderPage instances
    return pages;
  }
}
