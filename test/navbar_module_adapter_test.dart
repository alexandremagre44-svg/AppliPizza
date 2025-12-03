/// Test for Navbar Module Adapter (Phase 4B)
///
/// This test verifies navbar filtering based on active modules.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/runtime/navbar_module_adapter.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';

void main() {
  group('NavbarModuleAdapter Tests', () {
    // Helper to create a test plan
    RestaurantPlanUnified createTestPlan({
      List<String> activeModules = const [],
    }) {
      return RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: activeModules,
      );
    }

    test('filterNavItemsByModules keeps all items when plan is null', () {
      final items = [
        const NavItem(route: '/home', label: 'Home'),
        const NavItem(route: '/rewards', label: 'Rewards'),
        const NavItem(route: '/roulette', label: 'Roulette'),
      ];

      final result = NavbarModuleAdapter.filterNavItemsByModules(items, null);

      expect(result.items.length, items.length);
      expect(result.removedCount, 0);
      expect(result.hasRemovals, false);
    });

    test('filterNavItemsByModules keeps system routes always', () {
      final plan = createTestPlan(activeModules: []); // No modules active

      final items = [
        const NavItem(route: '/home', label: 'Home'),
        const NavItem(route: '/menu', label: 'Menu'),
        const NavItem(route: '/cart', label: 'Cart'),
        const NavItem(route: '/profile', label: 'Profile'),
      ];

      final result = NavbarModuleAdapter.filterNavItemsByModules(items, plan);

      expect(result.items.length, items.length);
      expect(result.removedCount, 0);
    });

    test('filterNavItemsByModules removes items for inactive modules', () {
      final plan = createTestPlan(
        activeModules: ['loyalty'], // Only loyalty active
      );

      final items = [
        const NavItem(route: '/home', label: 'Home'),
        const NavItem(route: '/rewards', label: 'Rewards'), // Loyalty - active
        const NavItem(route: '/roulette', label: 'Roulette'), // Roulette - inactive
      ];

      final result = NavbarModuleAdapter.filterNavItemsByModules(items, plan);

      expect(result.items.length, 2); // Home + Rewards
      expect(result.removedCount, 1); // Roulette removed
      expect(result.removedRoutes, contains('/roulette'));
      expect(result.disabledModules, contains('roulette'));
    });

    test('filterNavItemsByModules keeps items for active modules', () {
      final plan = createTestPlan(
        activeModules: ['loyalty', 'roulette'], // Both active
      );

      final items = [
        const NavItem(route: '/home', label: 'Home'),
        const NavItem(route: '/rewards', label: 'Rewards'),
        const NavItem(route: '/roulette', label: 'Roulette'),
      ];

      final result = NavbarModuleAdapter.filterNavItemsByModules(items, plan);

      expect(result.items.length, 3); // All kept
      expect(result.removedCount, 0);
    });

    test('filterActiveOnly returns simplified list', () {
      final plan = createTestPlan(activeModules: ['loyalty']);

      final items = [
        const NavItem(route: '/rewards', label: 'Rewards'),
        const NavItem(route: '/roulette', label: 'Roulette'),
      ];

      final filtered = NavbarModuleAdapter.filterActiveOnly(items, plan);

      expect(filtered.length, 1);
      expect(filtered[0].route, '/rewards');
    });

    test('isItemVisible checks item visibility', () {
      final plan = createTestPlan(activeModules: ['loyalty']);

      final rewardsItem = const NavItem(route: '/rewards', label: 'Rewards');
      final rouletteItem = const NavItem(route: '/roulette', label: 'Roulette');
      final homeItem = const NavItem(route: '/home', label: 'Home');

      expect(NavbarModuleAdapter.isItemVisible(rewardsItem, plan), true);
      expect(NavbarModuleAdapter.isItemVisible(rouletteItem, plan), false);
      expect(NavbarModuleAdapter.isItemVisible(homeItem, plan), true); // System route
    });

    test('getActiveModuleRoutes returns routes for active modules', () {
      final plan = createTestPlan(
        activeModules: ['loyalty', 'roulette', 'delivery'],
      );

      final routes = NavbarModuleAdapter.getActiveModuleRoutes(plan);

      expect(routes, contains('/rewards'));
      expect(routes, contains('/roulette'));
      expect(routes, contains('/delivery'));
    });

    test('getDisabledModuleRoutes returns routes for inactive modules', () {
      final plan = createTestPlan(
        activeModules: ['loyalty'], // Only loyalty active
      );

      final disabled = NavbarModuleAdapter.getDisabledModuleRoutes(plan);

      expect(disabled, contains('/roulette'));
      expect(disabled, contains('/delivery'));
      expect(disabled, isNot(contains('/rewards'))); // Rewards is active
    });

    test('validate detects inactive modules in navbar', () {
      final plan = createTestPlan(activeModules: ['loyalty']);

      final items = [
        const NavItem(route: '/rewards', label: 'Rewards'),
        const NavItem(route: '/roulette', label: 'Roulette'), // Inactive
      ];

      final errors = NavbarModuleAdapter.validate(items, plan);

      expect(errors.length, greaterThan(0));
      expect(errors.any((e) => e.contains('roulette')), true);
    });

    test('validate passes with all active modules', () {
      final plan = createTestPlan(
        activeModules: ['loyalty', 'roulette'],
      );

      final items = [
        const NavItem(route: '/home', label: 'Home'),
        const NavItem(route: '/rewards', label: 'Rewards'),
        const NavItem(route: '/roulette', label: 'Roulette'),
      ];

      final errors = NavbarModuleAdapter.validate(items, plan);

      // Note: There might be warnings about partial implementation,
      // but the key is that it doesn't error on inactive modules
      expect(errors.any((e) => e.contains('inactive')), false);
    });

    test('createStandardNavItems generates basic navbar', () {
      final plan = createTestPlan(
        activeModules: ['loyalty', 'delivery'],
      );

      final items = NavbarModuleAdapter.createStandardNavItems(plan);

      // Should have: home, menu, active module pages, cart, profile
      expect(items.length, greaterThan(4)); // At least system routes + some modules
      
      // Check system routes are present
      expect(items.any((i) => i.route == '/home'), true);
      expect(items.any((i) => i.route == '/menu'), true);
      expect(items.any((i) => i.route == '/cart'), true);
      expect(items.any((i) => i.route == '/profile'), true);

      // Check active module routes are present
      expect(items.any((i) => i.route == '/rewards'), true);
      expect(items.any((i) => i.route == '/delivery'), true);
    });

    test('getFilterStats returns correct statistics', () {
      final plan = createTestPlan(activeModules: ['loyalty']);

      final items = [
        const NavItem(route: '/home', label: 'Home'),
        const NavItem(route: '/rewards', label: 'Rewards'),
        const NavItem(route: '/roulette', label: 'Roulette'),
        const NavItem(route: '/cart', label: 'Cart'),
      ];

      final stats = NavbarModuleAdapter.getFilterStats(items, plan);

      expect(stats['total'], 4);
      expect(stats['kept'], 3); // home, rewards, cart
      expect(stats['removed'], 1); // roulette
      expect(stats['removedRoutes'], contains('/roulette'));
    });

    test('NavItem copyWith creates correct copy', () {
      const original = NavItem(route: '/home', label: 'Home', isActive: false);
      
      final copy = original.copyWith(isActive: true);
      
      expect(copy.route, original.route);
      expect(copy.label, original.label);
      expect(copy.isActive, true);
      expect(original.isActive, false); // Original unchanged
    });

    test('NavbarFilterResult has correct properties', () {
      const result = NavbarFilterResult(
        items: [],
        removedCount: 2,
        removedRoutes: ['/route1', '/route2'],
        disabledModules: ['module1'],
      );

      expect(result.hasRemovals, true);
      expect(result.isEmpty, true);
      expect(result.count, 0);
    });
  });
}
