// lib/white_label/core/system_pages.dart
/// System Page Manager
/// 
/// Manages system pages that are activated/deactivated based on the restaurant's
/// White Label plan. These pages are not editable via the Builder.
/// 
/// System pages include:
/// - Menu: Product catalog (always active)
/// - Cart: Shopping cart and checkout
/// - Profile: User profile and settings
/// - Admin: Admin panel access
/// 
/// Each page is configured with:
/// - route: The URL path
/// - title: Display name
/// - icon: Bottom navigation icon
/// - isSystem: Whether this is a non-editable system page
/// - widgetBuilder: Function to build the runtime widget

import 'package:flutter/material.dart';

/// System Page Identifiers
/// 
/// Enum representing all possible system pages in the application.
enum SystemPageId {
  /// Product menu/catalog page (always active)
  menu,
  
  /// Shopping cart and checkout page (requires cart module in plan)
  cart,
  
  /// User profile and settings page (always active)
  profile,
  
  /// Admin panel page (requires admin role)
  admin,
}

/// System Page Configuration
/// 
/// Contains all metadata and configuration for a system page.
class SystemPageConfig {
  /// URL route for this page
  final String route;
  
  /// Display title for the page
  final String title;
  
  /// Icon to display in bottom navigation
  final IconData icon;
  
  /// Whether this is a system page (not editable via Builder)
  final bool isSystem;
  
  /// Function to build the widget for this page
  final Widget Function(BuildContext context) widgetBuilder;
  
  /// Bottom navigation index (optional, null if not in bottom nav)
  final int? bottomNavIndex;
  
  const SystemPageConfig({
    required this.route,
    required this.title,
    required this.icon,
    required this.isSystem,
    required this.widgetBuilder,
    this.bottomNavIndex,
  });
  
  /// Copy with new values
  SystemPageConfig copyWith({
    String? route,
    String? title,
    IconData? icon,
    bool? isSystem,
    Widget Function(BuildContext context)? widgetBuilder,
    int? bottomNavIndex,
  }) {
    return SystemPageConfig(
      route: route ?? this.route,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      isSystem: isSystem ?? this.isSystem,
      widgetBuilder: widgetBuilder ?? this.widgetBuilder,
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
    );
  }
}

/// System Page Manager
/// 
/// Central registry for all system pages.
/// Provides static methods to access page configurations.
class SystemPageManager {
  SystemPageManager._(); // Private constructor to prevent instantiation
  
  /// Static map of all system pages
  /// 
  /// Each page is configured with its route, title, icon, and widget builder.
  /// The actual widgets are imported dynamically to avoid circular dependencies.
  static final Map<SystemPageId, SystemPageConfig> systemPages = {
    SystemPageId.menu: SystemPageConfig(
      route: '/menu',
      title: 'Menu',
      icon: Icons.restaurant_menu,
      isSystem: true,
      widgetBuilder: (context) {
        // Import dynamically to avoid circular dependency
        // This will be replaced with actual import when used
        return const _PlaceholderPage(title: 'Menu');
      },
      bottomNavIndex: 0,
    ),
    
    SystemPageId.cart: SystemPageConfig(
      route: '/cart',
      title: 'Panier',
      icon: Icons.shopping_cart,
      isSystem: true,
      widgetBuilder: (context) {
        // Import dynamically to avoid circular dependency
        return const _PlaceholderPage(title: 'Panier');
      },
      bottomNavIndex: 1,
    ),
    
    SystemPageId.profile: SystemPageConfig(
      route: '/profile',
      title: 'Profil',
      icon: Icons.person,
      isSystem: true,
      widgetBuilder: (context) {
        // Import dynamically to avoid circular dependency
        return const _PlaceholderPage(title: 'Profil');
      },
      bottomNavIndex: 2,
    ),
    
    SystemPageId.admin: SystemPageConfig(
      route: '/admin',
      title: 'Admin',
      icon: Icons.admin_panel_settings,
      isSystem: true,
      widgetBuilder: (context) {
        // Import dynamically to avoid circular dependency
        return const _PlaceholderPage(title: 'Admin');
      },
      bottomNavIndex: 3,
    ),
  };
  
  /// Get a system page configuration by ID
  static SystemPageConfig? getPage(SystemPageId id) {
    return systemPages[id];
  }
  
  /// Get all system pages
  static List<SystemPageConfig> getAllPages() {
    return systemPages.values.toList();
  }
  
  /// Get pages filtered by IDs
  static List<SystemPageConfig> getPages(List<SystemPageId> ids) {
    return ids
        .map((id) => systemPages[id])
        .where((page) => page != null)
        .cast<SystemPageConfig>()
        .toList();
  }
  
  /// Get pages for bottom navigation (sorted by bottomNavIndex)
  static List<SystemPageConfig> getBottomNavPages(List<SystemPageId> enabledIds) {
    return getPages(enabledIds)
        .where((page) => page.bottomNavIndex != null)
        .toList()
      ..sort((a, b) => a.bottomNavIndex!.compareTo(b.bottomNavIndex!));
  }
}

/// Placeholder page widget
/// 
/// Used as a temporary widget builder until actual pages are wired up.
class _PlaceholderPage extends StatelessWidget {
  final String title;
  
  const _PlaceholderPage({required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Page système: $title',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Cette page sera connectée au runtime.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
