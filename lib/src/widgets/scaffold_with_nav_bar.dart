// lib/src/widgets/scaffold_with_nav_bar.dart
// Dynamic bottom navigation bar controlled by Builder B3
//
// Navigation structure loaded from:
// restaurants/{restaurantId}/pages_system (order)
// restaurants/{restaurantId}/pages_published (content)
//
// WHITE-LABEL ARCHITECTURE (CORRECT SEPARATION):
// ================================================
// Builder B3 (MASTER):
// - Controls which pages appear in navigation
// - Controls the order and visibility of items
// - Decides where modules are placed (home, nav, etc.)
// - Full control over UI presentation
//
// White-Label Modules (VALIDATION):
// - Block route access if module disabled (via guards)
// - Hide Builder blocks if module disabled (via ModuleAwareBlock)
// - NO control over navigation structure
// - NO filtering of Builder B3 pages
//
// This file:
// - Renders navigation exactly as Builder B3 defines it
// - Logs active modules for debugging
// - _applyModuleFiltering provides safety layer for route security
// - Does NOT filter pages based on plan.hasModule()
//
// Result: Builder controls presentation, WL controls access rights

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/restaurant_plan_provider.dart';
import '../core/constants.dart';
import '../navigation/dynamic_navbar_builder.dart';
import '../navigation/unified_navbar_controller.dart';
import '../../builder/models/models.dart';
import '../../builder/services/builder_navigation_service.dart';
import '../../builder/utils/icon_helper.dart';
import '../../white_label/core/module_id.dart';
import '../../white_label/restaurant/restaurant_feature_flags.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';
import '../../white_label/runtime/navbar_module_adapter.dart';

/// Provider for bottom bar pages
/// Loads pages dynamically from Builder B3
/// Uses currentRestaurantProvider for consistent restaurant scoping
final bottomBarPagesProvider = FutureProvider.autoDispose<List<BuilderPage>>(
  (ref) async {
    final appId = ref.watch(currentRestaurantProvider).id;
    final service = BuilderNavigationService(appId);
    return await service.getBottomBarPages();
  },
  dependencies: [currentRestaurantProvider],
);

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalItems = ref.watch(cartProvider.select((cart) => cart.totalItems));
    final isAdmin = ref.watch(authProvider.select((auth) => auth.isAdmin));
    final bottomBarPagesAsync = ref.watch(bottomBarPagesProvider);
    final flags = ref.watch(restaurantFeatureFlagsProvider);
    
    // Phase 3: Load unified plan for dynamic filtering
    final unifiedPlanAsync = ref.watch(restaurantPlanUnifiedProvider);
    final unifiedPlan = unifiedPlanAsync.asData?.value;

    // White-label: Log active modules when plan is loaded
    if (unifiedPlan != null && kDebugMode) {
      debugPrint('[WL NAV] Modules actifs: ${unifiedPlan.activeModules}');
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: bottomBarPagesAsync.when(
        data: (builderPages) {
          // Debug: trace loaded pages (using pageKey instead of pageId)
          debugPrint('📱 [BottomNav] Loaded ${builderPages.length} pages: ${builderPages.map((p) => "${p.pageKey}(route:${p.route}, system:${p.systemId?.value ?? 'null'})").join(", ")}');
          
          // NEW: Use UnifiedNavBarController to compute navigation items
          // This centralizes all visibility logic in one place
          final navBarItems = UnifiedNavBarController.computeNavBarItems(
            builderPages: builderPages,
            plan: unifiedPlan,
            isAdmin: isAdmin,
          );
          
          // Convert NavBarItem list to BottomNavigationBarItem list
          final bottomNavItems = _convertToBottomNavItems(navBarItems, totalItems);
          
          // Runtime safety: If less than 2 items, show fallback navigation
          // This prevents Flutter crash: 'items.length >= 2' assertion
          if (bottomNavItems.length < 2) {
            debugPrint('⚠️ Bottom bar has < 2 items (${bottomNavItems.length}), showing fallback navigation');
            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: 0,
                onTap: (index) {
                  if (index == 0) context.go('/menu');
                  if (index == 1) context.go('/cart');
                  if (index == 2) context.go('/profile');
                },
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_menu_outlined),
                    label: 'Menu',
                  ),
                  BottomNavigationBarItem(
                    icon: badges.Badge(
                      showBadge: totalItems > 0,
                      badgeContent: Text(
                        totalItems.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    label: 'Panier',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profil',
                  ),
                ],
              ),
            );
          }
          
          // Calculate current index based on location
          final currentIndex = _calculateSelectedIndexFromNavBarItems(
            context,
            navBarItems,
          );
          
          // Add admin tab if user is admin
          if (isAdmin) {
            bottomNavItems.add(
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings),
                label: 'Admin',
              ),
            );
          }
          
          // Get adaptive styling based on item count (supports up to 6 items)
          final adaptiveStyle = _BottomNavAdaptiveStyle.forItemCount(bottomNavItems.length);
          
          // Debug: log rendered items count
          debugPrint('[BottomNav] Rendered ${bottomNavItems.length} items (after unified filtering)');

          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
              selectedFontSize: adaptiveStyle.selectedFontSize,
              unselectedFontSize: adaptiveStyle.unselectedFontSize,
              iconSize: adaptiveStyle.iconSize,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              onTap: (int index) => _onItemTappedFromNavBarItems(context, index, navBarItems, isAdmin),
              items: bottomNavItems,
            ),
          );
        },
        loading: () {
          // Show loading state with basic navigation
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  label: 'Chargement...',
                ),
              ],
            ),
          );
        },
        error: (error, stack) {
          // On error, fallback to basic navigation
          debugPrint('Error loading bottom bar pages: $error');
          if (kDebugMode && stack != null) {
            debugPrint('Stack trace: $stack');
          }
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              onTap: (index) {
                if (index == 0) context.go('/menu');
                if (index == 1) context.go('/cart');
                if (index == 2) context.go('/profile');
              },
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  label: 'Menu',
                ),
                BottomNavigationBarItem(
                  icon: badges.Badge(
                    showBadge: totalItems > 0,
                    badgeContent: Text(
                      totalItems.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  label: 'Panier',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profil',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Convert NavBarItem list to BottomNavigationBarItem list
  ///
  /// Converts the unified NavBarItem format to Flutter's BottomNavigationBarItem
  /// with proper icon handling and badge support.
  List<BottomNavigationBarItem> _convertToBottomNavItems(
    List<NavBarItem> navBarItems,
    int cartItemCount,
  ) {
    final items = <BottomNavigationBarItem>[];

    for (final navItem in navBarItems) {
      // Get icon pair (outlined/filled)
      final iconPair = IconHelper.getIconPair(navItem.icon);
      final outlinedIcon = iconPair.$1;
      final filledIcon = iconPair.$2;

      // Special handling for cart page - add badge
      if (navItem.route == '/cart') {
        items.add(
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: cartItemCount > 0,
              badgeContent: Text(
                cartItemCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: Icon(outlinedIcon),
            ),
            activeIcon: Icon(filledIcon),
            label: navItem.label,
          ),
        );
      } else {
        items.add(
          BottomNavigationBarItem(
            icon: Icon(outlinedIcon),
            activeIcon: Icon(filledIcon),
            label: navItem.label,
          ),
        );
      }
    }

    return items;
  }

  /// Calculate selected index from NavBarItem list based on current location
  int _calculateSelectedIndexFromNavBarItems(
    BuildContext context,
    List<NavBarItem> navBarItems,
  ) {
    final String location = GoRouterState.of(context).uri.toString();

    // Find matching item by route
    for (var i = 0; i < navBarItems.length; i++) {
      if (location.startsWith(navBarItems[i].route)) {
        return i;
      }
    }

    // Default to first item
    return 0;
  }

  /// Handle navigation tap from NavBarItem list
  void _onItemTappedFromNavBarItems(
    BuildContext context,
    int index,
    List<NavBarItem> navBarItems,
    bool isAdmin,
  ) {
    // If it's the last item AND user is admin → open AdminStudio
    // (Admin tab is added after nav items)
    if (isAdmin && index == navBarItems.length) {
      context.go(AppRoutes.adminStudio);
      return;
    }

    // Otherwise → normal navigation
    if (index >= 0 && index < navBarItems.length) {
      final route = navBarItems[index].route;

      // Safety check: never navigate to root '/' as it triggers login redirect
      if (route.isEmpty || route == '/') {
        debugPrint('⚠️ Attempted navigation to invalid route: "$route". Navigating to /menu instead.');
        context.go(AppRoutes.menu);
        return;
      }

      context.go(route);
    }
  }

  /// Build navigation items from Builder pages
  /// 
  /// WHITE-LABEL ARCHITECTURE (CORRECTED):
  /// ========================================
  /// Builder B3 is the MASTER - it controls:
  /// - Which pages appear in navigation
  /// - The order of navigation items
  /// - The visibility of modules in the UI
  /// 
  /// White-label modules (plan.hasModule) only control:
  /// - Route access (via guards)
  /// - Block visibility (via ModuleAwareBlock)
  /// 
  /// This function does NOT filter pages - it trusts Builder B3 completely.
  /// The _applyModuleFiltering() in the parent provides a safety layer for
  /// route-level security, but does NOT remove items from navigation.
  _NavigationItemsResult _buildNavigationItems(
    BuildContext context,
    WidgetRef ref,
    List<BuilderPage> builderPages,
    bool isAdmin,
    int totalItems,
    RestaurantFeatureFlags? flags,
  ) {
    final items = <BottomNavigationBarItem>[];
    final pages = <_NavPage>[];

    // Build navigation items for ALL pages from Builder B3
    // No filtering by modules - Builder decides what's visible
    for (final page in builderPages) {
      // Determine the correct route for this page
      String effectiveRoute = page.route;
      
      // Fix: If route is empty or '/', generate appropriate route
      if (effectiveRoute.isEmpty || effectiveRoute == '/') {
        if (page.systemId != null) {
          // System page: use system route
          final systemConfig = SystemPages.getConfig(page.systemId!);
          effectiveRoute = systemConfig?.route ?? '/${page.pageKey}';
        } else {
          // Custom page: always use /page/<pageKey>
          effectiveRoute = '/page/${page.pageKey}';
        }
        if (kDebugMode) {
          debugPrint('[WL NAV] Generated route for ${page.pageKey}: $effectiveRoute');
        }
      }
      
      // Safety check: Skip pages with still-invalid routes
      if (effectiveRoute.isEmpty || effectiveRoute == '/') {
        if (kDebugMode) {
          debugPrint('[WL NAV] ⚠️ Skipping page ${page.pageKey} with invalid route: "$effectiveRoute"');
        }
        continue;
      }
      
      // Try to get system page configuration
      final systemConfig = page.systemId != null ? SystemPages.getConfig(page.systemId!) : null;
      
      // Determine display name
      final displayName = (page.name.isNotEmpty && page.name != 'Page')
          ? page.name 
          : (systemConfig?.defaultName ?? page.pageKey);
      
      // Get icon pair (outlined/filled)
      final iconPair = page.icon.isNotEmpty 
          ? IconHelper.getIconPair(page.icon)
          : (systemConfig != null 
              ? IconHelper.getIconPair(_getIconNameFromIconData(systemConfig.defaultIcon))
              : IconHelper.getIconPair('layers'));
      final outlinedIcon = iconPair.$1;
      final filledIcon = iconPair.$2;

      // Special handling for cart page - add badge
      if (effectiveRoute == '/cart' || page.pageId == BuilderPageId.cart) {
        items.add(
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: totalItems > 0,
              badgeContent: Text(
                totalItems.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: Icon(outlinedIcon),
            ),
            activeIcon: Icon(filledIcon),
            label: displayName,
          ),
        );
      } else {
        items.add(
          BottomNavigationBarItem(
            icon: Icon(outlinedIcon),
            activeIcon: Icon(filledIcon),
            label: displayName,
          ),
        );
      }

      pages.add(_NavPage(route: effectiveRoute, name: displayName));
    }

    // Add admin tab at the end if user is admin
    if (isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
      pages.add(_NavPage(route: AppRoutes.adminStudio, name: 'Admin'));
    }

    if (kDebugMode) {
      debugPrint('[WL NAV] Built ${items.length} navigation items from Builder B3');
    }

    return _NavigationItemsResult(items: items, pages: pages);
  }
  
  /// Helper to convert IconData to icon name string
  /// 
  /// This is a workaround since we need string names for IconHelper.getIconPair().
  /// Used when mapping system page icons from IconData to string names.
  /// 
  /// Note: This function is used indirectly via SystemPages configuration.
  /// It provides a mapping between Flutter's IconData and string icon names
  /// that IconHelper can process to get outlined/filled icon pairs.
  String _getIconNameFromIconData(IconData iconData) {
    if (iconData == Icons.home) return 'home';
    if (iconData == Icons.restaurant_menu) return 'restaurant_menu';
    if (iconData == Icons.shopping_cart) return 'shopping_cart';
    if (iconData == Icons.person) return 'person';
    if (iconData == Icons.card_giftcard) return 'card_giftcard';
    if (iconData == Icons.casino) return 'casino';
    return 'help_outline';
  }

  /// Get the required module for a specific route
  /// Returns null if no module is required (always visible)
  ModuleId? _getRequiredModuleForRoute(String route) {
    switch (route) {
      case '/roulette':
        return ModuleId.roulette;
      case '/rewards':
        return ModuleId.loyalty;
      case '/kitchen':
        return ModuleId.kitchen_tablet;
      case '/staff-tablet':
      case '/staff-tablet/catalog':
      case '/staff-tablet/checkout':
      case '/staff-tablet/history':
        return ModuleId.staff_tablet;
      default:
        return null;
    }
  }

  /// Calculate selected index based on current location
  int _calculateSelectedIndex(BuildContext context, List<_NavPage> pages) {
    final String location = GoRouterState.of(context).uri.toString();

    // Find matching page by route
    for (var i = 0; i < pages.length; i++) {
      if (location.startsWith(pages[i].route)) {
        return i;
      }
    }

    // Default to first page
    return 0;
  }

  /// Handle navigation tap
  void _onItemTapped(
    BuildContext context, 
    int index, 
    List<_NavPage> pages,
    List<BottomNavigationBarItem> items,
    bool isAdmin,
  ) {
    // If it's the last item AND user is admin -> open AdminStudio
    if (isAdmin && index == items.length - 1) {
      context.go(AppRoutes.adminStudio);
      return;
    }
    
    // Otherwise -> normal behavior
    if (index >= 0 && index < pages.length) {
      final route = pages[index].route;
      
      // Safety check: never navigate to root '/' as it triggers login redirect
      if (route.isEmpty || route == '/') {
        debugPrint('⚠️ Attempted navigation to invalid route: "$route". Navigating to /menu instead.');
        context.go(AppRoutes.menu);
        return;
      }
      
      context.go(route);
    }
  }

  /// Phase 4C: Apply module filtering using NavbarModuleAdapter
  /// 
  /// Filters navigation items based on active modules in RestaurantPlanUnified.
  /// Uses the Phase 4B NavbarModuleAdapter for consistent filtering logic.
  /// If plan is null (restaurant without unified plan), returns items as-is for backward compatibility.
  _NavigationItemsResult _applyModuleFiltering(
    _NavigationItemsResult navItems,
    RestaurantPlanUnified? plan,
    int cartItemCount,
  ) {
    // If no plan loaded, return original items (fallback mode)
    if (plan == null) {
      debugPrint('📱 [BottomNav] No unified plan loaded, using all navigation items (fallback mode)');
      return navItems;
    }

    // Phase 4C: Use NavbarModuleAdapter for filtering
    // Convert _NavPage to NavItem for adapter
    final navItemsList = <NavItem>[];
    for (final page in navItems.pages) {
      navItemsList.add(NavItem(
        route: page.route,
        label: page.name,
      ));
    }

    // Apply filtering using NavbarModuleAdapter
    final filterResult = NavbarModuleAdapter.filterNavItemsByModules(
      navItemsList,
      plan,
    );

    // Log filtering results
    if (filterResult.hasRemovals) {
      debugPrint('📱 [BottomNav] Filtered out ${filterResult.removedCount} items: ${filterResult.removedRoutes}');
      debugPrint('📱 [BottomNav] Disabled modules: ${filterResult.disabledModules}');
    }

    // Build filtered result
    final filteredItems = <BottomNavigationBarItem>[];
    final filteredPages = <_NavPage>[];
    
    // Map filtered items back to original items
    for (final filteredNavItem in filterResult.items) {
      // Find matching page in original list
      for (var i = 0; i < navItems.pages.length; i++) {
        if (navItems.pages[i].route == filteredNavItem.route) {
          filteredItems.add(navItems.items[i]);
          filteredPages.add(navItems.pages[i]);
          break;
        }
      }
    }

    // If filtering resulted in too few items, return original
    if (filteredItems.length < 2) {
      debugPrint('📱 [BottomNav] Module filtering resulted in <2 items, using original items');
      return navItems;
    }

    debugPrint('📱 [BottomNav] Module filtering: ${navItems.items.length} → ${filteredItems.length} items');
    
    return _NavigationItemsResult(
      items: filteredItems,
      pages: filteredPages,
    );
  }
}

/// Helper class to store navigation page data
class _NavPage {
  final String route;
  final String name;

  _NavPage({required this.route, required this.name});
}

/// Helper class to return navigation items and pages together
class _NavigationItemsResult {
  final List<BottomNavigationBarItem> items;
  final List<_NavPage> pages;

  _NavigationItemsResult({required this.items, required this.pages});
}

/// Adaptive styling configuration for bottom navigation bar
/// Supports up to 6 items without overflow
/// Maximum supported: 6 items (uses most compact styling for 6+)
class _BottomNavAdaptiveStyle {
  final double iconSize;
  final double selectedFontSize;
  final double unselectedFontSize;
  
  const _BottomNavAdaptiveStyle({
    required this.iconSize,
    required this.selectedFontSize,
    required this.unselectedFontSize,
  });
  
  /// Calculate adaptive styling based on item count
  /// - 1-4 items: standard sizes
  /// - 5 items: slightly reduced sizes
  /// - 6+ items: compact sizes for proper fit (max supported is 6)
  factory _BottomNavAdaptiveStyle.forItemCount(int itemCount) {
    if (itemCount <= 4) {
      // Standard sizing for 1-4 items
      return const _BottomNavAdaptiveStyle(
        iconSize: 24.0,
        selectedFontSize: 13.0,
        unselectedFontSize: 12.0,
      );
    } else if (itemCount == 5) {
      // Slightly reduced for 5 items
      return const _BottomNavAdaptiveStyle(
        iconSize: 22.0,
        selectedFontSize: 11.0,
        unselectedFontSize: 10.0,
      );
    } else {
      // Compact sizing for 6+ items (max recommended is 6)
      // Using most compact sizing to avoid overflow
      return const _BottomNavAdaptiveStyle(
        iconSize: 20.0,
        selectedFontSize: 10.0,
        unselectedFontSize: 9.0,
      );
    }
  }
}
