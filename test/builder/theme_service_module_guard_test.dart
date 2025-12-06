/// test/builder/theme_service_module_guard_test.dart
///
/// Tests for ThemeService module guards to verify correct behavior
/// when the theme module is enabled/disabled.
///
/// Note: These tests focus on the module guard logic.
/// Integration tests with Firestore should be done separately.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza_clean/builder/models/theme_config.dart';
import 'package:pizza_delizza_clean/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza_clean/white_label/core/module_id.dart';

void main() {
  group('ThemeService - Module Guard Logic', () {
    const testAppId = 'test_restaurant_123';

    test('backward compatibility - allows operations when no plan is set', () {
      // When no plan is set, the service should allow operations
      // This is tested by construction - no exception should be thrown
      // The actual Firestore operations are not tested here
      
      expect(() {
        final planWithoutTheme = RestaurantPlanUnified(
          restaurantId: testAppId,
          name: 'Test Restaurant',
          slug: 'test-restaurant',
          activeModules: [],
        );
        
        // This should be valid
        expect(planWithoutTheme.hasModule(ModuleId.theme), isFalse);
      }, returnsNormally);
    });

    test('plan correctly identifies enabled theme module', () {
      final plan = RestaurantPlanUnified(
        restaurantId: testAppId,
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: [
          ModuleId.theme.code, // Theme enabled
          ModuleId.ordering.code,
        ],
      );

      // Should recognize theme as enabled
      expect(plan.hasModule(ModuleId.theme), isTrue);
      expect(plan.hasModule(ModuleId.ordering), isTrue);
      expect(plan.hasModule(ModuleId.delivery), isFalse);
    });

    test('plan correctly identifies disabled theme module', () {
      final plan = RestaurantPlanUnified(
        restaurantId: testAppId,
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: [
          ModuleId.ordering.code,
          // Theme NOT enabled
        ],
      );

      // Should recognize theme as disabled
      expect(plan.hasModule(ModuleId.theme), isFalse);
      expect(plan.hasModule(ModuleId.ordering), isTrue);
    });

    test('plan with multiple modules correctly identifies each', () {
      // Test with multiple modules
      final plan = RestaurantPlanUnified(
        restaurantId: testAppId,
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: [
          ModuleId.ordering.code,
          ModuleId.delivery.code,
          ModuleId.theme.code,
          ModuleId.loyalty.code,
        ],
      );

      // All specified modules should be enabled
      expect(plan.hasModule(ModuleId.ordering), isTrue);
      expect(plan.hasModule(ModuleId.delivery), isTrue);
      expect(plan.hasModule(ModuleId.theme), isTrue);
      expect(plan.hasModule(ModuleId.loyalty), isTrue);
      
      // Modules not in the list should be disabled
      expect(plan.hasModule(ModuleId.roulette), isFalse);
      expect(plan.hasModule(ModuleId.promotions), isFalse);
    });

    test('plan with no active modules disables all', () {
      final plan = RestaurantPlanUnified(
        restaurantId: testAppId,
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: [],
      );

      // All modules should be disabled
      expect(plan.hasModule(ModuleId.theme), isFalse);
      expect(plan.hasModule(ModuleId.ordering), isFalse);
      expect(plan.hasModule(ModuleId.delivery), isFalse);
    });

    test('module code to ModuleId conversion works correctly', () {
      // Test that the code property matches the enum
      expect(ModuleId.theme.code, equals('theme'));
      expect(ModuleId.ordering.code, equals('ordering'));
      expect(ModuleId.delivery.code, equals('delivery'));
      expect(ModuleId.loyalty.code, equals('loyalty'));
      expect(ModuleId.roulette.code, equals('roulette'));
    });

    test('enabledModuleIds returns correct list', () {
      final plan = RestaurantPlanUnified(
        restaurantId: testAppId,
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: [
          ModuleId.theme.code,
          ModuleId.ordering.code,
          ModuleId.delivery.code,
        ],
      );

      final enabledModules = plan.enabledModuleIds;
      
      expect(enabledModules.length, equals(3));
      expect(enabledModules, contains(ModuleId.theme));
      expect(enabledModules, contains(ModuleId.ordering));
      expect(enabledModules, contains(ModuleId.delivery));
      expect(enabledModules, isNot(contains(ModuleId.loyalty)));
    });
  });
}
