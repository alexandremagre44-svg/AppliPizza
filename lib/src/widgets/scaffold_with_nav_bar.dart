// lib/src/widgets/scaffold_with_nav_bar.dart
// Dynamic bottom navigation bar controlled by Builder B3
// WL V2 MIGRATED: Uses theme colors for navigation bar
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
import '../core/constants.dart';
import '../navigation/unified_navbar_controller.dart';
import '../../builder/utils/icon_helper.dart';
import '../../white_label/theme/theme_extensions.dart';

// NOTE: bottomBarPagesProvider removed - now using navBarItemsProvider
// from unified_navbar_controller.dart which handles all nav logic centrally

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
    
    // Read unified navigation items from the new provider
    final navItemsAsync = ref.watch(navBarItemsProvider);

    return navItemsAsync.when(
      data: (navItems) {
        debugPrint('📱 [BottomNav] Loaded ${navItems.length} unified nav items');
        
        // Convert NavBarItem list to BottomNavigationBarItem list
        final bottomNavItems = _convertToBottomNavItems(navItems, totalItems);
        
        // Add admin tab if user is admin
        if (isAdmin) {
          bottomNavItems.add(
            const BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin',
            ),
          );
        }
        
        // CASE 1: No navigation items (0 modules active)
        // Display centered placeholder message
        if (bottomNavItems.isEmpty) {
          debugPrint('⚠️ No navigation items available, showing placeholder');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: context.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun module actif',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // CASE 2: Only 1 navigation item (1 module active)
        // Display the single module directly without BottomNavigationBar
        // Flutter requires BottomNavigationBar.items.length >= 2
        if (bottomNavItems.length == 1) {
          debugPrint('📱 [BottomNav] Only 1 item available, hiding bottom bar and displaying module directly');
          return Scaffold(
            body: child,
          );
        }
        
        // CASE 3: 2+ navigation items
        // Display normal BottomNavigationBar behavior
        final currentIndex = _calculateSelectedIndex(context, navItems);
        final adaptiveStyle = _BottomNavAdaptiveStyle.forItemCount(bottomNavItems.length);
        
        debugPrint('[BottomNav] Rendered ${bottomNavItems.length} items (index: $currentIndex)');

        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.shadow.withOpacity(0.1), // WL V2: Theme shadow
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              selectedItemColor: context.primaryColor, // WL V2: Already using theme
              unselectedItemColor: context.textSecondary, // WL V2: Already using theme
              selectedFontSize: adaptiveStyle.selectedFontSize,
              unselectedFontSize: adaptiveStyle.unselectedFontSize,
              iconSize: adaptiveStyle.iconSize,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              onTap: (int index) => _onItemTapped(context, index, navItems, isAdmin),
              items: bottomNavItems,
            ),
          ),
        );
      },
      loading: () {
        // Hide navigation bar during loading
        return Scaffold(body: child);
      },
      error: (error, stack) {
        // On error, hide navigation bar and show the child
        debugPrint('⚠️ Error loading navigation items: $error');
        if (kDebugMode && stack != null) {
          debugPrint('Stack trace: $stack');
        }
        return Scaffold(body: child);
      },
    );
  }

  /// Convert NavBarItem list to BottomNavigationBarItem list
  ///
  /// Converts the unified NavBarItem format to Flutter's BottomNavigationBarItem
  /// with proper icon handling and badge support.
  List<BottomNavigationBarItem> _convertToBottomNavItems(
    List<NavBarItem> navItems,
    int cartItemCount,
  ) {
    final items = <BottomNavigationBarItem>[];

    for (final navItem in navItems) {
      // Get icon pair (outlined/filled)
      final iconPair = IconHelper.getIconPair(navItem.icon);
      final outlinedIcon = iconPair.$1;
      final filledIcon = iconPair.$2;

      // Special handling for cart page - add badge
      // Note: Badge color is kept as white for visibility on primary color badge background
      if (navItem.route == '/cart') {
        items.add(
          BottomNavigationBarItem(
            icon: badges.Badge(
              showBadge: cartItemCount > 0,
              badgeContent: const Text(
                '', // Empty, count shown via badgeContent
                style: TextStyle(color: Colors.white, fontSize: 10), // White for contrast
              ),
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.red, // Keep red for cart badge (universal signal)
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

  /// Calculate selected index based on current location
  ///
  /// Matches the current route with navItems routes using startsWith
  /// to handle dynamic pages (e.g., /menu/item/123 matches /menu)
  ///
  /// Returns 0 (first item) as fallback when no route matches. This ensures
  /// the navbar always has a valid selection, preventing navigation confusion.
  int _calculateSelectedIndex(
    BuildContext context,
    List<NavBarItem> navItems,
  ) {
    final String location = GoRouterState.of(context).uri.toString();

    // Find matching item by route using startsWith for dynamic pages
    for (var i = 0; i < navItems.length; i++) {
      if (location.startsWith(navItems[i].route)) {
        return i;
      }
    }

    // Fallback to first item if no match found (e.g., on unknown routes)
    return 0;
  }

  /// Handle navigation tap
  ///
  /// Navigates to the selected tab route, with special handling for admin tab
  void _onItemTapped(
    BuildContext context,
    int index,
    List<NavBarItem> navItems,
    bool isAdmin,
  ) {
    // If it's the last item AND user is admin → open AdminStudio
    // (Admin tab is added after nav items)
    if (isAdmin && index == navItems.length) {
      context.go(AppRoutes.adminStudio);
      return;
    }

    // Otherwise → normal navigation
    if (index >= 0 && index < navItems.length) {
      final route = navItems[index].route;

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
