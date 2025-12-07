// test/builder/builder_module_filter_test.dart
// Tests for Builder module filtering based on restaurant plan

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/models/builder_block.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';

void main() {
  group('Builder Module Filtering', () {
    test('module WL OFF → invisible in Builder', () {
      // Create a plan with only ordering module (roulette OFF)
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['ordering'], // Only ordering, no roulette
      );

      // Get filtered modules
      final filteredModules = SystemBlock.getFilteredModules(plan);

      // Roulette module should NOT be in the list
      expect(filteredModules.contains('roulette_module'), false);
      expect(filteredModules.contains('roulette'), false);
      
      // But menu_catalog should be (always visible)
      expect(filteredModules.contains('menu_catalog'), true);
    });

    test('module WL ON → visible in Builder', () {
      // Create a plan with roulette module enabled
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['ordering', 'roulette'], // Roulette ON
      );

      // Get filtered modules
      final filteredModules = SystemBlock.getFilteredModules(plan);

      // Roulette module SHOULD be in the list
      expect(filteredModules.contains('roulette_module'), true);
      
      // Menu catalog should also be there
      expect(filteredModules.contains('menu_catalog'), true);
    });

    test('module system → always visible', () {
      // Create a plan with NO modules
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [], // No modules enabled
      );

      // Get filtered modules
      final filteredModules = SystemBlock.getFilteredModules(plan);

      // System modules (always visible) should still be there
      expect(filteredModules.contains('menu_catalog'), true,
          reason: 'menu_catalog is in SystemModules.alwaysVisible');
      expect(filteredModules.contains('profile_module'), true,
          reason: 'profile_module is in SystemModules.alwaysVisible');
      
      // WL modules should NOT be there
      expect(filteredModules.contains('roulette_module'), false);
      expect(filteredModules.contains('loyalty_module'), false);
    });

    test('null plan → empty list (strict filtering)', () {
      // Get filtered modules with null plan
      final filteredModules = SystemBlock.getFilteredModules(null);

      // Should return empty list (strict filtering)
      expect(filteredModules, isEmpty);
    });

    test('plan with multiple WL modules', () {
      // Create a plan with several modules
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [
          'ordering',
          'roulette',
          'loyalty',
          'promotions',
        ],
      );

      // Get filtered modules
      final filteredModules = SystemBlock.getFilteredModules(plan);

      // Always visible should be there
      expect(filteredModules.contains('menu_catalog'), true);
      expect(filteredModules.contains('profile_module'), true);
      
      // Enabled WL modules should be there
      expect(filteredModules.contains('roulette_module'), true);
      expect(filteredModules.contains('loyalty_module'), true);
      expect(filteredModules.contains('promotions_module'), true);
      
      // Disabled WL modules should NOT be there
      expect(filteredModules.contains('newsletter_module'), false);
      expect(filteredModules.contains('click_collect_module'), false);
    });

    test('SystemModules.alwaysVisible contains expected modules', () {
      // Verify the always visible list
      expect(SystemModules.alwaysVisible, contains('menu_catalog'));
      expect(SystemModules.alwaysVisible, contains('profile_module'));
      
      // cart_module should NOT be in always visible (it's a system page now)
      expect(SystemModules.alwaysVisible, isNot(contains('cart_module')));
    });

    test('legacy module without WL mapping → always visible', () {
      // Create a plan with no modules
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [],
      );

      // Get filtered modules
      final filteredModules = SystemBlock.getFilteredModules(plan);

      // accountActivity is a legacy module without WL mapping
      // It should be visible even though no modules are enabled
      expect(filteredModules.contains('accountActivity'), true,
          reason: 'Legacy modules without WL mapping are always visible');
    });
  });

  group('SystemModules Configuration', () {
    test('alwaysVisible list is correct', () {
      expect(SystemModules.alwaysVisible, isA<List<String>>());
      expect(SystemModules.alwaysVisible.length, greaterThan(0));
      
      // Verify core modules are in the list
      expect(SystemModules.alwaysVisible.contains('menu_catalog'), true);
      expect(SystemModules.alwaysVisible.contains('profile_module'), true);
    });
  });
}
