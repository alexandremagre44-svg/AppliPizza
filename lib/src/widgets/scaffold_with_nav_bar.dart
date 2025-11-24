// lib/src/widgets/scaffold_with_nav_bar.dart
// Dynamic bottom navigation bar controlled by Builder B3

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../../builder/models/builder_page.dart';
import '../../builder/services/builder_navigation_service.dart';
import '../../builder/utils/app_context.dart';
import '../../builder/utils/icon_helper.dart';

/// Provider for bottom bar pages
/// Loads pages dynamically from Builder B3
final bottomBarPagesProvider = FutureProvider.autoDispose<List<BuilderPage>>((ref) async {
  final appId = ref.watch(currentAppIdProvider);
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
          // Build navigation items dynamically
          final navItems = _buildNavigationItems(
            context,
            ref,
            builderPages,
            isAdmin,
            totalItems,
          );
          
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
              onTap: (int index) => _onItemTapped(context, index, navItems.pages),
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
            child: const BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              items: [
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
          print('Error loading bottom bar pages: $error');
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
                if (index == 0) context.go('/home');
                if (index == 1) context.go('/menu');
                if (index == 2) context.go('/cart');
                if (index == 3) context.go('/profile');
              },
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Accueil',
                ),
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
  _NavigationItemsResult _buildNavigationItems(
    BuildContext context,
    WidgetRef ref,
    List<BuilderPage> builderPages,
    bool isAdmin,
    int totalItems,
  ) {
    final items = <BottomNavigationBarItem>[];
    final pages = <_NavPage>[];

    // Inject admin page first if user is admin
    if (isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
      pages.add(_NavPage(route: '/admin/studio', name: 'Admin'));
    }

    // Add builder pages
    for (final page in builderPages) {
      // Get icon (with outlined/filled versions)
      final iconPair = IconHelper.getIconPair(page.icon);
      final outlinedIcon = iconPair.$1;
      final filledIcon = iconPair.$2;

      // Special handling for cart page - add badge
      if (page.route == '/cart' && totalItems > 0) {
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
            label: page.name,
          ),
        );
      } else {
        items.add(
          BottomNavigationBarItem(
            icon: Icon(outlinedIcon),
            activeIcon: Icon(filledIcon),
            label: page.name,
          ),
        );
      }

      pages.add(_NavPage(route: page.route, name: page.name));
    }

    return _NavigationItemsResult(items: items, pages: pages);
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
  void _onItemTapped(BuildContext context, int index, List<_NavPage> pages) {
    if (index >= 0 && index < pages.length) {
      context.go(pages[index].route);
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
