/// lib/white_label/runtime/navbar_module_adapter.dart
/// Phase 4B: Navbar filtering based on active modules
///
/// This file provides NON-INTRUSIVE navbar filtering that respects
/// active modules in RestaurantPlanUnified.
///
/// This layer:
/// - Does NOT modify DynamicNavbarBuilder
/// - Does NOT modify existing navbar implementation
/// - Does NOT modify ScaffoldWithNavBar
///
/// Purpose:
/// - Filter navbar items based on active modules
/// - Remove tabs for disabled modules
/// - Maintain consistency between plan and UI
library;

import '../core/module_id.dart';
import '../core/module_runtime_mapping.dart';
import '../restaurant/restaurant_plan_unified.dart';
import 'module_route_resolver.dart';

/// Represents a navigation item with its associated route.
///
/// This is a simple data class that wraps navigation information
/// for filtering purposes.
class NavItem {
  /// The route this nav item navigates to.
  final String route;

  /// The label displayed for this nav item.
  final String label;

  /// Optional icon name or identifier.
  final String? icon;

  /// Whether this item is currently active/selected.
  final bool isActive;

  /// Additional metadata for this nav item.
  final Map<String, dynamic>? metadata;

  const NavItem({
    required this.route,
    required this.label,
    this.icon,
    this.isActive = false,
    this.metadata,
  });

  /// Create a copy with modified fields.
  NavItem copyWith({
    String? route,
    String? label,
    String? icon,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return NavItem(
      route: route ?? this.route,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'NavItem(route: $route, label: $label, active: $isActive)';
  }
}

/// Result of navbar filtering operation.
///
/// Contains the filtered items and metadata about the filtering.
class NavbarFilterResult {
  /// The filtered navigation items.
  final List<NavItem> items;

  /// Number of items removed during filtering.
  final int removedCount;

  /// List of routes that were removed.
  final List<String> removedRoutes;

  /// List of modules that caused removal.
  final List<String> disabledModules;

  const NavbarFilterResult({
    required this.items,
    required this.removedCount,
    required this.removedRoutes,
    required this.disabledModules,
  });

  /// Check if any items were removed.
  bool get hasRemovals => removedCount > 0;

  /// Check if the result is empty.
  bool get isEmpty => items.isEmpty;

  /// Get the number of remaining items.
  int get count => items.length;

  @override
  String toString() {
    return 'NavbarFilterResult(items: ${items.length}, removed: $removedCount)';
  }
}

/// Adapter for filtering navbar items based on module status.
///
/// This class provides utilities to filter navigation items according
/// to the active modules in a RestaurantPlanUnified.
class NavbarModuleAdapter {
  /// Private constructor to prevent instantiation.
  /// All methods are static.
  NavbarModuleAdapter._();

  /// Filter navigation items by active modules.
  ///
  /// This is the main filtering function that removes tabs corresponding
  /// to disabled modules.
  ///
  /// Rules:
  /// - System routes (home, menu, cart, profile) are always kept
  /// - Module routes are kept only if the module is active in the plan
  /// - Unknown routes are kept by default (for custom pages)
  ///
  /// Example:
  /// ```dart
  /// final items = [
  ///   NavItem(route: '/home', label: 'Home'),
  ///   NavItem(route: '/rewards', label: 'Rewards'),
  ///   NavItem(route: '/roulette', label: 'Roulette'),
  /// ];
  ///
  /// final result = filterNavItemsByModules(items, plan);
  /// print(result.items.length); // Depends on active modules in plan
  /// ```
  static NavbarFilterResult filterNavItemsByModules(
    List<NavItem> items,
    RestaurantPlanUnified? plan,
  ) {
    // If no plan, return all items (permissive fallback)
    if (plan == null) {
      return NavbarFilterResult(
        items: items,
        removedCount: 0,
        removedRoutes: [],
        disabledModules: [],
      );
    }

    final filteredItems = <NavItem>[];
    final removedRoutes = <String>[];
    final disabledModules = <String>[];

    for (final item in items) {
      if (_shouldKeepNavItem(item, plan)) {
        filteredItems.add(item);
      } else {
        removedRoutes.add(item.route);
        
        // Track which module caused the removal
        final module = ModuleRouteResolver.resolve(item.route);
        if (module != null && !disabledModules.contains(module.code)) {
          disabledModules.add(module.code);
        }
      }
    }

    return NavbarFilterResult(
      items: filteredItems,
      removedCount: items.length - filteredItems.length,
      removedRoutes: removedRoutes,
      disabledModules: disabledModules,
    );
  }

  /// Check if a nav item should be kept based on the plan.
  ///
  /// Returns true if the item should be kept in the navbar.
  static bool _shouldKeepNavItem(NavItem item, RestaurantPlanUnified plan) {
    final route = item.route;
    final result = ModuleRouteResolver.resolveDetailed(route);

    // System routes are always kept
    if (!result.requiresModule) {
      return true;
    }

    // If route belongs to a module, check if module is active
    if (result.moduleId != null) {
      return plan.hasModule(result.moduleId!);
    }

    // Unknown/custom routes are kept by default
    // This allows for custom pages that don't belong to modules
    return true;
  }

  /// Filter items and preserve only those with active modules.
  ///
  /// This is a simpler version that returns just the filtered list.
  ///
  /// Example:
  /// ```dart
  /// final filtered = NavbarModuleAdapter.filterActiveOnly(items, plan);
  /// ```
  static List<NavItem> filterActiveOnly(
    List<NavItem> items,
    RestaurantPlanUnified? plan,
  ) {
    final result = filterNavItemsByModules(items, plan);
    return result.items;
  }

  /// Check if a nav item should be visible for a given plan.
  ///
  /// Returns true if the item should be displayed in the navbar.
  ///
  /// Example:
  /// ```dart
  /// final item = NavItem(route: '/rewards', label: 'Rewards');
  /// final visible = NavbarModuleAdapter.isItemVisible(item, plan);
  /// ```
  static bool isItemVisible(NavItem item, RestaurantPlanUnified? plan) {
    if (plan == null) return true;
    return _shouldKeepNavItem(item, plan);
  }

  /// Get a list of all module routes that should be in the navbar.
  ///
  /// Returns routes for all active modules that have pages.
  ///
  /// Example:
  /// ```dart
  /// final routes = NavbarModuleAdapter.getActiveModuleRoutes(plan);
  /// print(routes); // ["/menu", "/rewards", "/roulette", ...]
  /// ```
  static List<String> getActiveModuleRoutes(RestaurantPlanUnified plan) {
    final routes = <String>[];

    for (final moduleId in plan.enabledModuleIds) {
      // Check if module has a page
      if (ModuleRuntimeMapping.getRuntimePage(moduleId)) {
        final route = ModuleRuntimeMapping.getRuntimeRoute(moduleId);
        if (route != null) {
          routes.add(route);
        }
      }
    }

    return routes;
  }

  /// Get a list of disabled module routes.
  ///
  /// Returns routes for modules that are not active in the plan.
  ///
  /// Example:
  /// ```dart
  /// final disabled = NavbarModuleAdapter.getDisabledModuleRoutes(plan);
  /// print(disabled); // Routes that should be hidden
  /// ```
  static List<String> getDisabledModuleRoutes(RestaurantPlanUnified plan) {
    final disabledRoutes = <String>[];

    for (final moduleId in ModuleId.values) {
      // If module is not in the plan and has a page
      if (!plan.hasModule(moduleId) &&
          ModuleRuntimeMapping.getRuntimePage(moduleId)) {
        final route = ModuleRuntimeMapping.getRuntimeRoute(moduleId);
        if (route != null) {
          disabledRoutes.add(route);
        }
      }
    }

    return disabledRoutes;
  }

  /// Validate that all nav items are compatible with the plan.
  ///
  /// Returns a list of validation errors (empty if valid).
  ///
  /// Example:
  /// ```dart
  /// final errors = NavbarModuleAdapter.validate(items, plan);
  /// if (errors.isNotEmpty) {
  ///   print('Validation errors: $errors');
  /// }
  /// ```
  static List<String> validate(
    List<NavItem> items,
    RestaurantPlanUnified plan,
  ) {
    final errors = <String>[];

    for (final item in items) {
      final result = ModuleRouteResolver.resolveDetailed(item.route);

      // Check if route requires a module
      if (result.requiresModule && result.moduleId != null) {
        // Check if module is active
        if (!plan.hasModule(result.moduleId!)) {
          errors.add(
            'Nav item "${item.label}" (${item.route}) requires inactive module: ${result.moduleId!.code}',
          );
        }

        // Check if module is implemented
        if (!ModuleRuntimeMapping.isImplemented(result.moduleId!)) {
          final status = ModuleRuntimeMapping.isPartiallyImplemented(result.moduleId!)
              ? 'partially implemented'
              : 'not implemented';
          errors.add(
            'Nav item "${item.label}" (${item.route}) uses module "${result.moduleId!.code}" which is $status',
          );
        }
      }

      // Check for phantom routes
      if (result.requiresModule && result.moduleId == null) {
        errors.add(
          'Nav item "${item.label}" has phantom route: ${item.route} (no module owns this route)',
        );
      }
    }

    return errors;
  }

  /// Create a standard set of nav items for a plan.
  ///
  /// Generates a basic navbar structure based on active modules.
  /// This is a helper for Phase 4C integration.
  ///
  /// Example:
  /// ```dart
  /// final items = NavbarModuleAdapter.createStandardNavItems(plan);
  /// ```
  static List<NavItem> createStandardNavItems(RestaurantPlanUnified plan) {
    final items = <NavItem>[];

    // Always include home
    items.add(const NavItem(route: '/home', label: 'Accueil', icon: 'home'));

    // Always include menu
    items.add(const NavItem(route: '/menu', label: 'Menu', icon: 'menu'));

    // Add active module pages
    final activeRoutes = getActiveModuleRoutes(plan);
    for (final route in activeRoutes) {
      final module = ModuleRouteResolver.resolve(route);
      if (module != null) {
        final label = ModuleRuntimeMapping.getLabel(module);
        items.add(NavItem(route: route, label: label));
      }
    }

    // Always include cart
    items.add(const NavItem(route: '/cart', label: 'Panier', icon: 'cart'));

    // Always include profile
    items.add(const NavItem(route: '/profile', label: 'Profil', icon: 'profile'));

    return items;
  }

  /// Get statistics about navbar filtering.
  ///
  /// Returns information about how many items would be kept/removed.
  ///
  /// Example:
  /// ```dart
  /// final stats = NavbarModuleAdapter.getFilterStats(items, plan);
  /// print('Would keep ${stats['kept']} items, remove ${stats['removed']}');
  /// ```
  static Map<String, dynamic> getFilterStats(
    List<NavItem> items,
    RestaurantPlanUnified? plan,
  ) {
    final result = filterNavItemsByModules(items, plan);

    return {
      'total': items.length,
      'kept': result.items.length,
      'removed': result.removedCount,
      'removedRoutes': result.removedRoutes,
      'disabledModules': result.disabledModules,
    };
  }
}
