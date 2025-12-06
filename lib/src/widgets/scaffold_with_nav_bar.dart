// lib/src/widgets/scaffold_with_nav_bar.dart
// Dynamic bottom navigation bar controlled by Builder B3
//
// Navigation structure loaded from:
// restaurants/{restaurantId}/pages_system (order)
// restaurants/{restaurantId}/pages_published (content)
//
// White-Label Integration:
// - Uses RestaurantPlanUnified to filter pages by active modules
// - Calls plan.hasModule(moduleId) to check if module is enabled
// - Logs active modules: '[WL NAV] Modules actifs: ${plan.activeModules}'
// - Hides pages and nav buttons for disabled modules
// - Preserves all existing UI/UX (IndexedStack, BottomNav)
// - Does not modify Builder B3, Admin routes, or SuperAdmin routes
// - Maintains backward compatibility with feature flags

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
      print('[WL NAV] Modules actifs: ${unifiedPlan.activeModules}');
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: bottomBarPagesAsync.when(
        data: (builderPages) {
          // Debug: trace loaded pages (using pageKey instead of pageId)
          debugPrint('📱 [BottomNav] Loaded ${builderPages.length} pages: ${builderPages.map((p) => "${p.pageKey}(route:${p.route}, system:${p.systemId?.value ?? 'null'})").join(", ")}');
          
          // Build navigation items dynamically
          final navItems = _buildNavigationItems(
            context,
            ref,
            builderPages,
            isAdmin,
            totalItems,
            flags,
          );
          
          // Phase 3: Apply DynamicNavbarBuilder filtering based on active modules
          final filteredNavItems = _applyModuleFiltering(
            navItems,
            unifiedPlan,
            totalItems,
          );
          
          // Runtime safety: If less than 2 items, show fallback navigation
          // This prevents Flutter crash: 'items.length >= 2' assertion
          if (filteredNavItems.items.length < 2) {
            debugPrint('⚠️ Bottom bar has < 2 items (${filteredNavItems.items.length}), showing fallback navigation');
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
          final currentIndex = _calculateSelectedIndex(
            context,
            filteredNavItems.pages,
          );
          
          // Get adaptive styling based on item count (supports up to 6 items)
          final adaptiveStyle = _BottomNavAdaptiveStyle.forItemCount(filteredNavItems.items.length);
          
          // Debug: log rendered items count
          debugPrint('[BottomNav] Rendered ${filteredNavItems.items.length} items (after module filtering)');

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
              onTap: (int index) => _onItemTapped(context, index, filteredNavItems.pages, filteredNavItems.items, isAdmin),
              items: filteredNavItems.items,
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

  /// Build navigation items from Builder pages
  /// 
  /// White-label integration: This function now uses the unified plan
  /// to filter pages based on active modules. It delegates to:
  /// - buildPagesFromPlan() for page filtering
  /// - buildBottomNavItemsFromPlan() for item creation
  /// 
  /// The function preserves backward compatibility by:
  /// - Using feature flags as fallback when plan is not available
  /// - Keeping all existing UI logic (icons, labels, badges)
  /// - Maintaining admin tab injection
  /// - Preserving system pages (menu, cart, profile)
  /// 
  /// Module guard: filters pages based on feature flags (legacy) or unified plan (white-label)
  _NavigationItemsResult _buildNavigationItems(
    BuildContext context,
    WidgetRef ref,
    List<BuilderPage> builderPages,
    bool isAdmin,
    int totalItems,
    RestaurantFeatureFlags? flags,
  ) {
    // White-label: Get unified plan for module-based filtering
    final unifiedPlanAsync = ref.watch(restaurantPlanUnifiedProvider);
    final unifiedPlan = unifiedPlanAsync.asData?.value;

    // White-label: Filter pages based on active modules in the plan
    // This uses plan.hasModule() to determine which pages to show
    final filteredPages = buildPagesFromPlan(builderPages, unifiedPlan);

    // White-label: Build navigation items from filtered pages
    // This creates the actual BottomNavigationBarItem widgets
    final result = buildBottomNavItemsFromPlan(
      context,
      ref,
      filteredPages,
      unifiedPlan,
      isAdmin,
      totalItems,
    );

    // Legacy fallback: If no plan is available, also check feature flags
    // This ensures backward compatibility with restaurants not using unified plan
    if (unifiedPlan == null && flags != null) {
      final legacyFilteredItems = <BottomNavigationBarItem>[];
      final legacyFilteredPages = <_NavPage>[];
      
      for (var i = 0; i < result.pages.length; i++) {
        final page = result.pages[i];
        final requiredModule = _getRequiredModuleForRoute(page.route);
        
        if (requiredModule != null && !flags.has(requiredModule)) {
          if (kDebugMode) {
            debugPrint('[WL NAV] Legacy filter: Skipping ${page.name} - module ${requiredModule.code} disabled in flags');
          }
          continue;
        }
        
        legacyFilteredItems.add(result.items[i]);
        legacyFilteredPages.add(page);
      }
      
      if (kDebugMode) {
        debugPrint('[WL NAV] Applied legacy feature flags filter: ${result.items.length} → ${legacyFilteredItems.length}');
      }
      
      return _NavigationItemsResult(
        items: legacyFilteredItems,
        pages: legacyFilteredPages,
      );
    }

    return result;
  }
  
  /// Helper to convert IconData to icon name string
  /// This is a workaround since we need string names for IconHelper
  String _getIconNameFromIconData(IconData iconData) {
    if (iconData == Icons.home) return 'home';
    if (iconData == Icons.restaurant_menu) return 'restaurant_menu';
    if (iconData == Icons.shopping_cart) return 'shopping_cart';
    if (iconData == Icons.person) return 'person';
    if (iconData == Icons.card_giftcard) return 'card_giftcard';
    if (iconData == Icons.casino) return 'casino';
    return 'help_outline';
  }

  /// White-label: Build pages from unified plan
  /// 
  /// This function filters Builder pages based on active modules in the plan.
  /// It uses plan.hasModule() to check if each module is enabled.
  /// 
  /// Returns a filtered list of pages that should be shown in navigation.
  /// This function is called by the main navigation builder to ensure
  /// only pages for active modules are displayed.
  /// 
  /// Rules:
  /// - System pages (menu, cart, profile) are always included
  /// - Module pages are included only if plan.hasModule(moduleId) returns true
  /// - Custom pages from Builder B3 are always included (no module requirement)
  List<BuilderPage> buildPagesFromPlan(
    List<BuilderPage> builderPages,
    RestaurantPlanUnified? plan,
  ) {
    // If no plan loaded, return all pages (fallback mode for backward compatibility)
    if (plan == null) {
      if (kDebugMode) {
        debugPrint('[WL NAV] No plan loaded - returning all pages');
      }
      return builderPages;
    }

    final filteredPages = <BuilderPage>[];

    for (final page in builderPages) {
      // Check if page requires a specific module
      final requiredModule = _getRequiredModuleForRoute(page.route);
      
      if (requiredModule != null) {
        // Module-specific page: check if module is enabled using plan.hasModule()
        if (plan.hasModule(requiredModule)) {
          filteredPages.add(page);
          if (kDebugMode) {
            debugPrint('[WL NAV] ✓ Page ${page.pageKey} included - module ${requiredModule.code} is enabled');
          }
        } else {
          if (kDebugMode) {
            debugPrint('[WL NAV] ✗ Page ${page.pageKey} excluded - module ${requiredModule.code} is disabled');
          }
        }
      } else {
        // System or custom page: always include
        filteredPages.add(page);
        if (kDebugMode) {
          debugPrint('[WL NAV] ✓ Page ${page.pageKey} included - no module requirement');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('[WL NAV] Filtered pages: ${builderPages.length} → ${filteredPages.length}');
    }

    return filteredPages;
  }

  /// White-label: Build bottom navigation items from unified plan
  /// 
  /// This function creates BottomNavigationBarItem widgets based on the filtered pages
  /// and the unified plan. It ensures that only navigation items for active modules
  /// are displayed.
  /// 
  /// The function:
  /// 1. Takes filtered pages from buildPagesFromPlan()
  /// 2. Creates BottomNavigationBarItem for each page
  /// 3. Adds special handling for cart badge
  /// 4. Adds admin tab if user is admin
  /// 
  /// Returns a result containing both items and pages for navigation.
  _NavigationItemsResult buildBottomNavItemsFromPlan(
    BuildContext context,
    WidgetRef ref,
    List<BuilderPage> filteredPages,
    RestaurantPlanUnified? plan,
    bool isAdmin,
    int totalItems,
  ) {
    final items = <BottomNavigationBarItem>[];
    final pages = <_NavPage>[];

    if (kDebugMode) {
      debugPrint('[WL NAV] Building nav items for ${filteredPages.length} pages');
    }

    // Build navigation items for each filtered page
    for (final page in filteredPages) {
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
      
      if (kDebugMode) {
        debugPrint('[WL NAV] Added admin tab');
      }
    }

    if (kDebugMode) {
      debugPrint('[WL NAV] Built ${items.length} navigation items');
    }

    return _NavigationItemsResult(items: items, pages: pages);
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
