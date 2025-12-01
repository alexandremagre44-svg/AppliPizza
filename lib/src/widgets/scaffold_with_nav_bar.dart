// lib/src/widgets/scaffold_with_nav_bar.dart
// Dynamic bottom navigation bar controlled by Builder B3
//
// Navigation structure loaded from:
// restaurants/{restaurantId}/pages_system (order)
// restaurants/{restaurantId}/pages_published (content)

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

/// Provider for bottom bar pages
/// Loads pages dynamically from Builder B3
/// Uses currentRestaurantProvider for consistent restaurant scoping
final bottomBarPagesProvider = FutureProvider.autoDispose<List<BuilderPage>>((ref) async {
  final appId = ref.watch(currentRestaurantProvider).id;
  final service = BuilderNavigationService(appId);
  return await service.getBottomBarPages();
});

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
              unselectedItemColor: Colors.grey[400],
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
  /// Injects admin page if user is admin
  /// Uses SystemPages registry for consistent icon and label handling
  /// Module guard: filters pages based on feature flags
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

    // Add builder pages first
    for (final page in builderPages) {
      // Module guard: Skip pages for disabled modules
      final requiredModule = _getRequiredModuleForRoute(page.route);
      if (requiredModule != null && flags != null) {
        if (!flags.has(requiredModule)) {
          if (kDebugMode) {
            debugPrint('🚫 [BottomNav] Skipping ${page.pageKey} - module ${requiredModule.code} is disabled');
          }
          continue;
        }
      }
      
      // Determine the correct route for this page
      // System pages use their defined routes, custom pages use /page/<pageKey>
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
        debugPrint('🔧 [BottomNav] Generated route for ${page.pageKey}: $effectiveRoute');
      }
      
      // Safety check: Skip pages with still-invalid routes
      if (effectiveRoute.isEmpty || effectiveRoute == '/') {
        debugPrint('⚠️ Skipping page ${page.pageKey} with invalid route: "$effectiveRoute"');
        continue;
      }
      
      // Try to get system page configuration for this page (only for system pages)
      final systemConfig = page.systemId != null ? SystemPages.getConfig(page.systemId!) : null;
      
      // Use page name if available and not generic, otherwise use system default or pageKey
      final displayName = (page.name.isNotEmpty && page.name != 'Page')
          ? page.name 
          : (systemConfig?.defaultName ?? page.pageKey);
      
      // Get icon (with outlined/filled versions)
      // System pages: use system default icon
      // Custom pages with icon: use the custom icon
      // Custom pages without icon: fallback to 'layers' (default for custom pages)
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

    return _NavigationItemsResult(items: items, pages: pages);
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

  /// Get the required module for a specific route
  /// Returns null if no module is required (always visible)
  ModuleId? _getRequiredModuleForRoute(String route) {
    switch (route) {
      case '/roulette':
        return ModuleId.roulette;
      case '/rewards':
        return ModuleId.loyalty;
      case '/kitchen':
        return ModuleId.kitchenTablet;
      case '/staff-tablet':
      case '/staff-tablet/catalog':
      case '/staff-tablet/checkout':
      case '/staff-tablet/history':
        return ModuleId.staffTablet;
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

  /// Phase 3: Apply module filtering using DynamicNavbarBuilder
  /// 
  /// Filters navigation items based on active modules in RestaurantPlanUnified.
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

    // Convert _NavPage list to BuilderPage list for filtering
    final builderPages = navItems.pages.map((navPage) {
      return BuilderPage(
        pageKey: navPage.route.replaceAll('/', '').replaceAll('-', '_'),
        route: navPage.route,
        order: 0,
        title: navPage.label,
        isActive: true,
      );
    }).toList();

    // Apply DynamicNavbarBuilder filtering
    final filtered = DynamicNavbarBuilder.filterNavItems(
      originalPages: builderPages,
      originalItems: navItems.items,
      plan: plan,
    );

    // If filtering resulted in too few items, use fallback
    if (filtered.items.length < 2) {
      debugPrint('📱 [BottomNav] Module filtering resulted in <2 items, using fallback');
      final fallback = DynamicNavbarBuilder.buildFallbackNavItems(
        cartItemCount: cartItemCount,
      );
      
      // Convert back to _NavigationItemsResult format
      final fallbackPages = fallback.pages.map((page) {
        return _NavPage(route: page.route, label: page.title);
      }).toList();
      
      return _NavigationItemsResult(
        items: fallback.items,
        pages: fallbackPages,
      );
    }

    // Convert filtered results back to _NavigationItemsResult
    final filteredPages = filtered.pages.map((page) {
      return _NavPage(route: page.route, label: page.title);
    }).toList();

    debugPrint('📱 [BottomNav] Module filtering: ${navItems.items.length} → ${filtered.items.length} items');
    
    return _NavigationItemsResult(
      items: filtered.items,
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
