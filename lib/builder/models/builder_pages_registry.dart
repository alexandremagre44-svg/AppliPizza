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
}
