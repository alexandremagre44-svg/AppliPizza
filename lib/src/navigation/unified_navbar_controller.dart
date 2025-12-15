/// lib/src/navigation/unified_navbar_controller.dart
///
/// Unified Navigation Bar Controller - White-Label Aware
///
/// This controller centralizes the logic for computing the final list of
/// visible bottom navigation tabs based on:
/// - RestaurantPlanUnified.activeModules (module activation)
/// - Builder page visibility settings (dynamic pages)
/// - System page requirements (runtime needs)
/// - User role (admin-only pages)
///
/// Architecture:
/// UnifiedNavBarController
///  ├─ gathers: system pages (menu, cart)
///  ├─ gathers: builder dynamic pages (including profile)
///  ├─ gathers: WL module pages
///  ├─ filters visibility (WL + builder + role)
///  └─ returns final tab list
///
/// Rules:
/// - If ordering module is OFF → no Cart tab
/// - If loyalty/roulette module is ON → NO new tab (appears inside Profile)
/// - If builder page visibility = false → tab disappears
/// - Builder custom tabs appear first
/// - System pages appear next
/// - Module tabs appear only if explicitly allowed
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../builder/models/models.dart';
import '../../builder/services/builder_navigation_service.dart';
import '../../white_label/core/module_id.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';
import '../providers/restaurant_provider.dart';
import '../providers/restaurant_plan_provider.dart';

/// Represents a navigation bar item with metadata
class NavBarItem {
  /// The route this item navigates to
  final String route;

  /// Display label for the item
  final String label;

  /// Icon name (Material icon name as string)
  final String icon;

  /// Source of this nav item (system/module/builder)
  final NavItemSource source;

  /// Original order/index (for sorting)
  final int order;

  /// Whether this item is a system page
  final bool isSystemPage;

  /// Optional module ID if this item is module-driven
  final ModuleId? moduleId;

  /// Builder page reference (if from builder)
  final BuilderPage? builderPage;

  const NavBarItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.source,
    required this.order,
    this.isSystemPage = false,
    this.moduleId,
    this.builderPage,
  });

  @override
  String toString() {
    return 'NavBarItem(route: $route, label: $label, source: $source, order: $order)';
  }
}

/// Source type for navigation items
enum NavItemSource {
  system,   // System pages (menu, cart only)
  builder,  // Builder dynamic pages (including profile)
  module,   // Module-driven pages
}

/// Controller for unified navigation bar computation
class UnifiedNavBarController {
  /// Private constructor to prevent instantiation
  UnifiedNavBarController._();

  /// Compute the final list of navigation bar items
  ///
  /// This is the main entry point that:
  /// 1. Collects all possible tab entries
  /// 2. Filters them based on module activation and visibility
  /// 3. Orders them correctly
  /// 4. Returns the final list
  ///
  /// Parameters:
  /// - [builderPages]: Pages from Builder B3 system
  /// - [plan]: RestaurantPlanUnified with active modules
  /// - [isAdmin]: Whether current user is admin
  ///
  /// Returns: Ordered list of [NavBarItem] ready for rendering
  static List<NavBarItem> computeNavBarItems({
    required List<BuilderPage> builderPages,
    required RestaurantPlanUnified? plan,
    required bool isAdmin,
  }) {
    debugPrint('[UnifiedNavBarController] Computing nav bar items');
    debugPrint('[UnifiedNavBarController] - Builder pages: ${builderPages.length}');
    debugPrint('[UnifiedNavBarController] - Active modules: ${plan?.activeModules ?? []}');
    debugPrint('[UnifiedNavBarController] - Is admin: $isAdmin');

    // Step 1: Collect all possible entries
    final allItems = <NavBarItem>[];

    // Gather builder pages (visible in bottomBar)
    final builderItems = _gatherBuilderPages(builderPages, plan);
    allItems.addAll(builderItems);

    // Gather system pages
    final systemItems = _gatherSystemPages(plan);
    allItems.addAll(systemItems);

    // Gather module pages (if they need their own tab)
    final moduleItems = _gatherModulePages(plan);
    allItems.addAll(moduleItems);

    // Step 2: Filter by visibility rules
    final filteredItems = _filterByVisibility(allItems, plan, isAdmin);

    // Step 3: Remove duplicates (prefer builder over system)
    final deduplicatedItems = _removeDuplicates(filteredItems);

    // Step 4: Order correctly
    final orderedItems = _orderItems(deduplicatedItems);

    debugPrint('[UnifiedNavBarController] Final nav bar items: ${orderedItems.length}');
    for (final item in orderedItems) {
      debugPrint('[UnifiedNavBarController]   - ${item.label} (${item.route}) [${item.source.name}]');
    }

    return orderedItems;
  }

  /// Gather builder-managed pages that should appear in navbar
  ///
  /// Includes pages where:
  /// - displayLocation == 'bottomBar'
  /// - isActive == true
  /// - isEnabled == true
  static List<NavBarItem> _gatherBuilderPages(
    List<BuilderPage> builderPages,
    RestaurantPlanUnified? plan,
  ) {
    final items = <NavBarItem>[];

    for (final page in builderPages) {
      // Only include pages marked for bottom bar
      if (page.displayLocation != 'bottomBar') continue;
      if (!page.isActive) continue;
      if (!page.isEnabled) continue;

      // Check if this is a system page override from builder
      final isSystemOverride = page.systemId != null;

      items.add(NavBarItem(
        route: page.route,
        label: page.name,
        icon: page.icon,
        source: NavItemSource.builder,
        order: page.bottomNavIndex,
        isSystemPage: isSystemOverride,
        builderPage: page,
      ));
    }

    debugPrint('[UnifiedNavBarController] Gathered ${items.length} builder pages');
    return items;
  }

  /// Gather system pages (menu, cart)
  ///
  /// System pages are core application pages that should appear
  /// in the navbar based on module activation.
  /// 
  /// IMPORTANT: Profile is NOT a system page - it's a BUSINESS page
  /// that should be managed by the Builder (gathered in _gatherBuilderPages).
  /// Only Cart and Menu are true system pages for navigation purposes.
  static List<NavBarItem> _gatherSystemPages(RestaurantPlanUnified? plan) {
    final items = <NavBarItem>[];

    // Menu - always visible
    items.add(const NavBarItem(
      route: '/menu',
      label: 'Menu',
      icon: 'restaurant_menu',
      source: NavItemSource.system,
      order: 100, // System pages have higher order
      isSystemPage: true,
    ));

    // Cart - only if ordering module is active
    if (plan?.activeModules.contains('ordering') ?? false) {
      items.add(const NavBarItem(
        route: '/cart',
        label: 'Panier',
        icon: 'shopping_cart',
        source: NavItemSource.system,
        order: 101,
        isSystemPage: true,
      ));
    }

    // REMOVED: Profile is a BUSINESS page, not a system page.
    // Profile should be managed by the Builder via _gatherBuilderPages().
    // This ensures Profile is rendered by BuilderPageLoader, not system placeholders.

    debugPrint('[UnifiedNavBarController] Gathered ${items.length} system pages');
    return items;
  }

  /// Gather module-driven pages
  ///
  /// Some modules may require their own tab in the navbar.
  /// However, loyalty and roulette should NOT have their own tabs
  /// (they appear inside Profile).
  ///
  /// Currently, no modules have their own tabs outside of system pages.
  /// This is a placeholder for future expansion.
  static List<NavBarItem> _gatherModulePages(RestaurantPlanUnified? plan) {
    final items = <NavBarItem>[];

    if (plan == null) return items;

    // Note: Loyalty and Roulette explicitly DO NOT get tabs here
    // They are accessible from within the Profile page

    // Example future module that might need its own tab:
    // if (plan.hasModule(ModuleId.someModule)) {
    //   items.add(NavBarItem(...));
    // }

    debugPrint('[UnifiedNavBarController] Gathered ${items.length} module pages');
    return items;
  }

  /// Filter items by visibility rules
  ///
  /// Applies filtering based on:
  /// - Module activation status
  /// - Builder page visibility settings
  /// - User role requirements
  static List<NavBarItem> _filterByVisibility(
    List<NavBarItem> items,
    RestaurantPlanUnified? plan,
    bool isAdmin,
  ) {
    final filtered = <NavBarItem>[];

    for (final item in items) {
      // Check module requirements
      if (item.moduleId != null) {
        if (plan == null || !plan.hasModule(item.moduleId!)) {
          debugPrint('[UnifiedNavBarController] Filtered out ${item.label} - module ${item.moduleId!.code} not active');
          continue;
        }
      }

      // Check builder page visibility
      if (item.builderPage != null) {
        final page = item.builderPage!;
        
        // If page is disabled, skip it
        if (!page.isEnabled || !page.isActive) {
          debugPrint('[UnifiedNavBarController] Filtered out ${item.label} - builder page disabled');
          continue;
        }

        // Check if page has module requirements through its modules list
        if (page.modules.isNotEmpty && plan != null) {
          bool hasRequiredModule = false;
          for (final moduleCode in page.modules) {
            if (plan.activeModules.contains(moduleCode)) {
              hasRequiredModule = true;
              break;
            }
          }
          if (!hasRequiredModule) {
            debugPrint('[UnifiedNavBarController] Filtered out ${item.label} - required modules not active');
            continue;
          }
        }
      }

      // Item passed all filters
      filtered.add(item);
    }

    debugPrint('[UnifiedNavBarController] Filtered: ${items.length} → ${filtered.length} items');
    return filtered;
  }

  /// Remove duplicate routes, preferring builder over system
  ///
  /// If a builder page overrides a system page, keep the builder version.
  static List<NavBarItem> _removeDuplicates(List<NavBarItem> items) {
    final seenRoutes = <String>{};
    final result = <NavBarItem>[];

    // First pass: add all builder items
    for (final item in items) {
      if (item.source == NavItemSource.builder) {
        if (!seenRoutes.contains(item.route)) {
          seenRoutes.add(item.route);
          result.add(item);
        }
      }
    }

    // Second pass: add system and module items that don't conflict
    for (final item in items) {
      if (item.source != NavItemSource.builder) {
        if (!seenRoutes.contains(item.route)) {
          seenRoutes.add(item.route);
          result.add(item);
        } else {
          debugPrint('[UnifiedNavBarController] Removed duplicate: ${item.label} (${item.route}) - builder override exists');
        }
      }
    }

    return result;
  }

  /// Order items correctly
  ///
  /// Ordering rules:
  /// 1. Builder custom tabs appear first (by bottomNavIndex)
  /// 2. System pages appear next (menu, cart only)
  /// 3. Module tabs appear last (if any)
  static List<NavBarItem> _orderItems(List<NavBarItem> items) {
    final sorted = List<NavBarItem>.from(items);
    
    sorted.sort((a, b) {
      // First, sort by source type priority
      final sourcePriority = {
        NavItemSource.builder: 0,
        NavItemSource.system: 1,
        NavItemSource.module: 2,
      };
      
      final aPriority = sourcePriority[a.source] ?? 999;
      final bPriority = sourcePriority[b.source] ?? 999;
      
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      
      // Within same source type, sort by order
      return a.order.compareTo(b.order);
    });

    return sorted;
  }

  /// Check if a specific page should be visible
  ///
  /// This is a helper method for checking individual page visibility.
  static bool isPageVisible({
    required String route,
    required RestaurantPlanUnified? plan,
    List<BuilderPage>? builderPages,
  }) {
    // Check system page visibility
    if (route == '/cart') {
      return plan?.activeModules.contains('ordering') ?? false;
    }

    // Check builder page visibility
    if (builderPages != null) {
      final page = builderPages.firstWhere(
        (p) => p.route == route,
        orElse: () => BuilderPage(
          pageKey: 'not_found',
          route: '',
          name: '',
          appId: '',
          isEnabled: false,
        ),
      );

      if (page.route.isNotEmpty) {
        return page.isEnabled && page.isActive;
      }
    }

    // Default to visible for unknown routes
    return true;
  }
}

/// Provider for computed navigation bar items
///
/// This provider uses UnifiedNavBarController to compute the final
/// list of visible navigation items based on current state.
final navBarItemsProvider = FutureProvider.autoDispose<List<NavBarItem>>(
  (ref) async {
    // Get builder pages
    final restaurantId = ref.watch(currentRestaurantProvider).id;
    final service = BuilderNavigationService(restaurantId);
    final builderPages = await service.getBottomBarPages();

    // Get unified plan
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    // Get admin status
    // Note: We need to import auth_provider for this, but to avoid
    // circular dependencies, we'll check this at the widget level
    final isAdmin = false; // Will be passed from widget

    // Compute final items
    final items = UnifiedNavBarController.computeNavBarItems(
      builderPages: builderPages,
      plan: plan,
      isAdmin: isAdmin,
    );

    return items;
  },
  dependencies: [currentRestaurantProvider, restaurantPlanUnifiedProvider],
);

/// Provider family for checking if a specific page is visible
///
/// Usage:
/// ```dart
/// final isCartVisible = ref.watch(isPageVisibleProvider('/cart'));
/// ```
final isPageVisibleProvider = Provider.family<bool, String>(
  (ref, route) {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;

    return UnifiedNavBarController.isPageVisible(
      route: route,
      plan: plan,
    );
  },
  dependencies: [restaurantPlanUnifiedProvider],
);
