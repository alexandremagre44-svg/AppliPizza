/// Test for Unified NavBar Controller
///
/// This test verifies the unified navigation bar controller that centralizes
/// visibility logic for bottom navigation tabs.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/models/models.dart';
import 'package:pizza_delizza/src/navigation/unified_navbar_controller.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';

void main() {
  group('UnifiedNavBarController Tests', () {
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

    // Helper to create a test builder page
    BuilderPage createBuilderPage({
      required String pageKey,
      required String route,
      required String name,
      String icon = 'home',
      int order = 0,
      bool isActive = true,
      bool isEnabled = true,
      String displayLocation = 'bottomBar',
      List<String> modules = const [],
      BuilderPageId? systemId,
    }) {
      return BuilderPage(
        pageKey: pageKey,
        systemId: systemId,
        route: route,
        name: name,
        icon: icon,
        order: order,
        isActive: isActive,
        isEnabled: isEnabled,
        displayLocation: displayLocation,
        modules: modules,
        appId: 'test-app',
      );
    }

    test('computeNavBarItems includes system pages by default', () {
      final plan = createTestPlan(activeModules: ['ordering']);
      final builderPages = <BuilderPage>[];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Should have Menu, Cart (ordering active), Profile
      expect(items.length, 3);
      expect(items.any((item) => item.route == '/menu'), true);
      expect(items.any((item) => item.route == '/cart'), true);
      expect(items.any((item) => item.route == '/profile'), true);
    });

    test('computeNavBarItems hides cart when ordering module is inactive', () {
      final plan = createTestPlan(activeModules: []); // No modules active
      final builderPages = <BuilderPage>[];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Should have Menu and Profile, but NOT Cart
      expect(items.length, 2);
      expect(items.any((item) => item.route == '/menu'), true);
      expect(items.any((item) => item.route == '/cart'), false);
      expect(items.any((item) => item.route == '/profile'), true);
    });

    test('computeNavBarItems includes builder pages marked for bottomBar', () {
      final plan = createTestPlan(activeModules: []);
      final builderPages = [
        createBuilderPage(
          pageKey: 'promo',
          route: '/promo',
          name: 'Promotions',
          order: 0,
          displayLocation: 'bottomBar',
        ),
      ];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Should have builder page + system pages
      expect(items.any((item) => item.route == '/promo'), true);
      expect(items.any((item) => item.route == '/menu'), true);
      expect(items.any((item) => item.route == '/profile'), true);
    });

    test('computeNavBarItems filters out disabled builder pages', () {
      final plan = createTestPlan(activeModules: []);
      final builderPages = [
        createBuilderPage(
          pageKey: 'promo',
          route: '/promo',
          name: 'Promotions',
          order: 0,
          displayLocation: 'bottomBar',
          isEnabled: false, // Disabled
        ),
      ];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Disabled page should not appear
      expect(items.any((item) => item.route == '/promo'), false);
    });

    test('computeNavBarItems filters out inactive builder pages', () {
      final plan = createTestPlan(activeModules: []);
      final builderPages = [
        createBuilderPage(
          pageKey: 'promo',
          route: '/promo',
          name: 'Promotions',
          order: 0,
          displayLocation: 'bottomBar',
          isActive: false, // Inactive
        ),
      ];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Inactive page should not appear
      expect(items.any((item) => item.route == '/promo'), false);
    });

    test('computeNavBarItems filters builder pages by module requirements', () {
      final plan = createTestPlan(activeModules: []); // No modules
      final builderPages = [
        createBuilderPage(
          pageKey: 'rewards',
          route: '/rewards',
          name: 'Rewards',
          order: 0,
          displayLocation: 'bottomBar',
          modules: ['loyalty'], // Requires loyalty module
        ),
      ];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Page requiring loyalty should not appear when loyalty is inactive
      expect(items.any((item) => item.route == '/rewards'), false);
    });

    test('computeNavBarItems includes builder pages when required modules are active', () {
      final plan = createTestPlan(activeModules: ['loyalty']);
      final builderPages = [
        createBuilderPage(
          pageKey: 'rewards',
          route: '/rewards',
          name: 'Rewards',
          order: 0,
          displayLocation: 'bottomBar',
          modules: ['loyalty'], // Requires loyalty module
        ),
      ];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Page should appear when loyalty is active
      expect(items.any((item) => item.route == '/rewards'), true);
    });

    test('computeNavBarItems orders items correctly (builder first, then system)', () {
      final plan = createTestPlan(activeModules: ['ordering']);
      final builderPages = [
        createBuilderPage(
          pageKey: 'promo',
          route: '/promo',
          name: 'Promotions',
          order: 0,
          displayLocation: 'bottomBar',
        ),
      ];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Builder page should come first
      expect(items[0].source, NavItemSource.builder);
      expect(items[0].route, '/promo');

      // System pages should follow
      final systemItems = items.where((item) => item.source == NavItemSource.system).toList();
      expect(systemItems.length, 3); // Menu, Cart, Profile
    });

    test('computeNavBarItems removes duplicates, preferring builder over system', () {
      final plan = createTestPlan(activeModules: ['ordering']);
      final builderPages = [
        createBuilderPage(
          pageKey: 'menu',
          route: '/menu',
          name: 'Custom Menu',
          order: 0,
          displayLocation: 'bottomBar',
          systemId: BuilderPageId.menu,
        ),
      ];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Should have only one /menu entry (the builder one)
      final menuItems = items.where((item) => item.route == '/menu').toList();
      expect(menuItems.length, 1);
      expect(menuItems[0].source, NavItemSource.builder);
      expect(menuItems[0].label, 'Custom Menu');
    });

    test('computeNavBarItems excludes hidden and internal pages', () {
      final plan = createTestPlan(activeModules: []);
      final builderPages = [
        createBuilderPage(
          pageKey: 'hidden1',
          route: '/hidden1',
          name: 'Hidden Page',
          order: 0,
          displayLocation: 'hidden',
        ),
        createBuilderPage(
          pageKey: 'internal1',
          route: '/internal1',
          name: 'Internal Page',
          order: 0,
          displayLocation: 'internal',
        ),
      ];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Hidden and internal pages should not appear in navbar
      expect(items.any((item) => item.route == '/hidden1'), false);
      expect(items.any((item) => item.route == '/internal1'), false);
    });

    test('isPageVisible returns true for visible system pages', () {
      final plan = createTestPlan(activeModules: ['ordering']);

      expect(
        UnifiedNavBarController.isPageVisible(
          route: '/menu',
          plan: plan,
        ),
        true,
      );

      expect(
        UnifiedNavBarController.isPageVisible(
          route: '/cart',
          plan: plan,
        ),
        true,
      );

      expect(
        UnifiedNavBarController.isPageVisible(
          route: '/profile',
          plan: plan,
        ),
        true,
      );
    });

    test('isPageVisible returns false for cart when ordering is inactive', () {
      final plan = createTestPlan(activeModules: []);

      expect(
        UnifiedNavBarController.isPageVisible(
          route: '/cart',
          plan: plan,
        ),
        false,
      );
    });

    test('isPageVisible checks builder page visibility', () {
      final plan = createTestPlan(activeModules: []);
      final builderPages = [
        createBuilderPage(
          pageKey: 'promo',
          route: '/promo',
          name: 'Promotions',
          isEnabled: false,
        ),
      ];

      expect(
        UnifiedNavBarController.isPageVisible(
          route: '/promo',
          plan: plan,
          builderPages: builderPages,
        ),
        false,
      );
    });

    test('Module pages do NOT get tabs (loyalty, roulette)', () {
      final plan = createTestPlan(activeModules: ['loyalty', 'roulette']);
      final builderPages = <BuilderPage>[];

      final items = UnifiedNavBarController.computeNavBarItems(
        builderPages: builderPages,
        plan: plan,
        isAdmin: false,
      );

      // Loyalty and roulette should NOT have tabs (they're in Profile)
      expect(items.any((item) => item.moduleId == ModuleId.loyalty), false);
      expect(items.any((item) => item.moduleId == ModuleId.roulette), false);
    });
  });
}
