/// Test for Service Guard
///
/// This test verifies service guard functionality for protecting
/// business operations based on module status.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/runtime/service_guard.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';

void main() {
  group('ServiceGuard Tests', () {
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

    test('isEnabled returns true for active modules', () {
      final plan = createTestPlan(activeModules: ['loyalty', 'roulette']);
      final guard = ServiceGuard(plan: plan);

      expect(guard.isEnabled(ModuleId.loyalty), true);
      expect(guard.isEnabled(ModuleId.roulette), true);
    });

    test('isEnabled returns false for inactive modules', () {
      final plan = createTestPlan(activeModules: ['loyalty']);
      final guard = ServiceGuard(plan: plan);

      expect(guard.isEnabled(ModuleId.roulette), false);
      expect(guard.isEnabled(ModuleId.delivery), false);
    });

    test('isEnabled returns true when plan is null and allowWhenPlanNull is true', () {
      final guard = ServiceGuard(plan: null, allowWhenPlanNull: true);

      expect(guard.isEnabled(ModuleId.loyalty), true);
      expect(guard.isEnabled(ModuleId.roulette), true);
    });

    test('isEnabled returns false when plan is null and allowWhenPlanNull is false', () {
      final guard = ServiceGuard(plan: null, allowWhenPlanNull: false);

      expect(guard.isEnabled(ModuleId.loyalty), false);
      expect(guard.isEnabled(ModuleId.roulette), false);
    });

    test('isPartiallyEnabled detects partial modules', () {
      final plan = createTestPlan(activeModules: ['newsletter']);
      final guard = ServiceGuard(plan: plan);

      // Newsletter is partially implemented
      expect(guard.isPartiallyEnabled(ModuleId.newsletter), true);

      // Loyalty is fully implemented
      final fullPlan = createTestPlan(activeModules: ['loyalty']);
      final fullGuard = ServiceGuard(plan: fullPlan);
      expect(fullGuard.isPartiallyEnabled(ModuleId.loyalty), false);
    });

    test('ensureEnabled throws ModuleDisabledException for disabled modules', () {
      final plan = createTestPlan(activeModules: ['loyalty']);
      final guard = ServiceGuard(plan: plan);

      expect(
        () => guard.ensureEnabled(ModuleId.roulette, 'spinWheel'),
        throwsA(isA<ModuleDisabledException>()),
      );
    });

    test('ensureEnabled does not throw for enabled modules', () {
      final plan = createTestPlan(activeModules: ['loyalty']);
      final guard = ServiceGuard(plan: plan);

      expect(
        () => guard.ensureEnabled(ModuleId.loyalty, 'addPoints'),
        returnsNormally,
      );
    });

    test('ensureEnabled throws for partial modules when strictPartialCheck is true', () {
      final plan = createTestPlan(activeModules: ['newsletter']);
      final guard = ServiceGuard(plan: plan, strictPartialCheck: true);

      expect(
        () => guard.ensureEnabled(ModuleId.newsletter, 'subscribe'),
        throwsA(isA<ModulePartiallyImplementedException>()),
      );
    });

    test('ensureEnabled does not throw for partial modules when strictPartialCheck is false', () {
      final plan = createTestPlan(activeModules: ['newsletter']);
      final guard = ServiceGuard(plan: plan, strictPartialCheck: false);

      expect(
        () => guard.ensureEnabled(ModuleId.newsletter, 'subscribe'),
        returnsNormally,
      );
    });

    test('ensureFullyEnabled always throws for partial modules', () {
      final plan = createTestPlan(activeModules: ['newsletter']);
      final guard = ServiceGuard(plan: plan, strictPartialCheck: false);

      expect(
        () => guard.ensureFullyEnabled(ModuleId.newsletter, 'subscribe'),
        throwsA(isA<ModulePartiallyImplementedException>()),
      );
    });

    test('ensureFullyEnabled does not throw for fully implemented modules', () {
      final plan = createTestPlan(activeModules: ['loyalty']);
      final guard = ServiceGuard(plan: plan);

      expect(
        () => guard.ensureFullyEnabled(ModuleId.loyalty, 'addPoints'),
        returnsNormally,
      );
    });

    test('isOperationAllowed returns true for enabled, non-partial modules', () {
      final plan = createTestPlan(activeModules: ['loyalty']);
      final guard = ServiceGuard(plan: plan);

      expect(guard.isOperationAllowed(ModuleId.loyalty), true);
    });

    test('isOperationAllowed returns false for disabled modules', () {
      final plan = createTestPlan(activeModules: ['loyalty']);
      final guard = ServiceGuard(plan: plan);

      expect(guard.isOperationAllowed(ModuleId.roulette), false);
    });

    test('isOperationAllowed returns false for partial modules', () {
      final plan = createTestPlan(activeModules: ['newsletter']);
      final guard = ServiceGuard(plan: plan);

      expect(guard.isOperationAllowed(ModuleId.newsletter), false);
    });

    test('isOperationAllowedPartial returns true for partial modules', () {
      final plan = createTestPlan(activeModules: ['newsletter']);
      final guard = ServiceGuard(plan: plan);

      expect(guard.isOperationAllowedPartial(ModuleId.newsletter), true);
    });

    test('ServiceGuard.permissive allows all operations', () {
      final guard = ServiceGuard.permissive();

      expect(guard.isEnabled(ModuleId.loyalty), true);
      expect(guard.isEnabled(ModuleId.roulette), true);
      expect(() => guard.ensureEnabled(ModuleId.loyalty), returnsNormally);
    });

    test('ServiceGuard.strict denies all operations', () {
      final guard = ServiceGuard.strict();

      expect(guard.isEnabled(ModuleId.loyalty), false);
      expect(guard.isEnabled(ModuleId.roulette), false);
    });

    test('ModuleDisabledException has correct properties', () {
      final exception = ModuleDisabledException(
        moduleId: ModuleId.loyalty,
        operation: 'addPoints',
      );

      expect(exception.moduleId, ModuleId.loyalty);
      expect(exception.operation, 'addPoints');
      expect(exception.message, contains('loyalty'));
      expect(exception.message, contains('addPoints'));
    });

    test('ModulePartiallyImplementedException has correct properties', () {
      final exception = ModulePartiallyImplementedException(
        moduleId: ModuleId.newsletter,
        operation: 'subscribe',
      );

      expect(exception.moduleId, ModuleId.newsletter);
      expect(exception.operation, 'subscribe');
      expect(exception.message, contains('newsletter'));
      expect(exception.message, contains('subscribe'));
      expect(exception.message, contains('partially implemented'));
    });
  });
}
