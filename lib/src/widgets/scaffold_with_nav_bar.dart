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
import '../core/constants.dart';
import '../../builder/models/models.dart';
import '../../builder/services/builder_navigation_service.dart';
import '../../builder/utils/icon_helper.dart';

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
          );
          
          // Runtime safety: If less than 2 items, show fallback navigation
          // This prevents Flutter crash: 'items.length >= 2' assertion
          if (navItems.items.length < 2) {
            debugPrint('⚠️ Bottom bar has < 2 items (${navItems.items.length}), showing fallback navigation');
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
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_menu_outlined),
                    label: 'Menu',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_outlined),
                    label: 'Panier',
                  ),
                ],
              ),
            );
          }
          
          // Calculate current index based on location
          final currentIndex = _calculateSelectedIndex(
            context,
            navItems.pages,
          );

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
              selectedFontSize: 13,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              onTap: (int index) => _onItemTapped(context, index, navItems.pages, navItems.items, isAdmin),
              items: navItems.items,
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
  _NavigationItemsResult _buildNavigationItems(
    BuildContext context,
    WidgetRef ref,
    List<BuilderPage> builderPages,
    bool isAdmin,
    int totalItems,
  ) {
    final items = <BottomNavigationBarItem>[];
    final pages = <_NavPage>[];

    // Add builder pages first
    for (final page in builderPages) {
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
      // If icon is empty or invalid, use system default
      final iconPair = page.icon.isNotEmpty 
          ? IconHelper.getIconPair(page.icon)
          : (systemConfig != null 
              ? IconHelper.getIconPair(_getIconNameFromIconData(systemConfig.defaultIcon))
              : IconHelper.getIconPair('help_outline'));
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
