// test/module_gate_test.dart
/// Tests for ModuleGate - Central modularity layer

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza/white_label/runtime/module_gate.dart';

void main() {
  group('ModuleGate - Core Functionality', () {
    test('permissive gate allows all modules when plan is null', () {
      final gate = ModuleGate.permissive();

      expect(gate.isModuleEnabled(ModuleId.delivery), true);
      expect(gate.isModuleEnabled(ModuleId.clickAndCollect), true);
      expect(gate.isModuleEnabled(ModuleId.loyalty), true);
    });

    test('strict gate denies all modules when plan is null', () {
      final gate = ModuleGate.strict();

      expect(gate.isModuleEnabled(ModuleId.delivery), false);
      expect(gate.isModuleEnabled(ModuleId.clickAndCollect), false);
      expect(gate.isModuleEnabled(ModuleId.loyalty), false);
    });

    test('gate with plan checks activeModules correctly', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery', 'click_and_collect'],
      );

      final gate = ModuleGate(plan: plan);

      expect(gate.isModuleEnabled(ModuleId.delivery), true);
      expect(gate.isModuleEnabled(ModuleId.clickAndCollect), true);
      expect(gate.isModuleEnabled(ModuleId.loyalty), false);
      expect(gate.isModuleEnabled(ModuleId.roulette), false);
    });

    test('gate with empty activeModules denies all modules', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [],
      );

      final gate = ModuleGate(plan: plan);

      expect(gate.isModuleEnabled(ModuleId.delivery), false);
      expect(gate.isModuleEnabled(ModuleId.clickAndCollect), false);
      expect(gate.isModuleEnabled(ModuleId.loyalty), false);
    });
  });

  group('ModuleGate - Order Type Authorization', () {
    test('base order types (dine_in, takeaway) are always allowed', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [], // No modules active
      );

      final gate = ModuleGate(plan: plan);

      expect(gate.isOrderTypeAllowed('dine_in'), true);
      expect(gate.isOrderTypeAllowed('takeaway'), true);
    });

    test('delivery order type requires delivery module', () {
      final planWithoutDelivery = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [],
      );

      final planWithDelivery = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery'],
      );

      final gateWithout = ModuleGate(plan: planWithoutDelivery);
      final gateWith = ModuleGate(plan: planWithDelivery);

      expect(gateWithout.isOrderTypeAllowed('delivery'), false);
      expect(gateWith.isOrderTypeAllowed('delivery'), true);
    });

    test('click_collect order type requires clickAndCollect module', () {
      final planWithoutCC = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [],
      );

      final planWithCC = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['click_and_collect'],
      );

      final gateWithout = ModuleGate(plan: planWithoutCC);
      final gateWith = ModuleGate(plan: planWithCC);

      expect(gateWithout.isOrderTypeAllowed('click_collect'), false);
      expect(gateWith.isOrderTypeAllowed('click_collect'), true);
    });

    test('unknown order types are denied', () {
      final gate = ModuleGate.permissive();

      expect(gate.isOrderTypeAllowed('unknown_type'), false);
      expect(gate.isOrderTypeAllowed(''), false);
      expect(gate.isOrderTypeAllowed('invalid'), false);
    });
  });

  group('ModuleGate - Allowed Order Types List', () {
    test('returns only base types when no modules active', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: [],
      );

      final gate = ModuleGate(plan: plan);
      final types = gate.allowedOrderTypes();

      expect(types, ['dine_in', 'takeaway']);
    });

    test('includes delivery when module is active', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery'],
      );

      final gate = ModuleGate(plan: plan);
      final types = gate.allowedOrderTypes();

      expect(types, contains('delivery'));
      expect(types, hasLength(3)); // dine_in, takeaway, delivery
    });

    test('includes click_collect when module is active', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['click_and_collect'],
      );

      final gate = ModuleGate(plan: plan);
      final types = gate.allowedOrderTypes();

      expect(types, contains('click_collect'));
      expect(types, hasLength(3)); // dine_in, takeaway, click_collect
    });

    test('includes all types when both modules are active', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery', 'click_and_collect'],
      );

      final gate = ModuleGate(plan: plan);
      final types = gate.allowedOrderTypes();

      expect(types, containsAll(['dine_in', 'takeaway', 'delivery', 'click_collect']));
      expect(types, hasLength(4));
    });
  });

  group('ModuleGate - Multiple Module Checks', () {
    test('hasAllModules returns true only if all modules are active', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery', 'loyalty'],
      );

      final gate = ModuleGate(plan: plan);

      expect(gate.hasAllModules([ModuleId.delivery, ModuleId.loyalty]), true);
      expect(gate.hasAllModules([ModuleId.delivery, ModuleId.roulette]), false);
      expect(gate.hasAllModules([ModuleId.clickAndCollect]), false);
    });

    test('hasAnyModule returns true if at least one module is active', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery'],
      );

      final gate = ModuleGate(plan: plan);

      expect(gate.hasAnyModule([ModuleId.delivery, ModuleId.clickAndCollect]), true);
      expect(gate.hasAnyModule([ModuleId.loyalty, ModuleId.roulette]), false);
      expect(gate.hasAnyModule([ModuleId.delivery]), true);
    });

    test('hasAllModules with empty list returns true', () {
      final gate = ModuleGate.strict();
      expect(gate.hasAllModules([]), true);
    });

    test('hasAnyModule with empty list returns false', () {
      final gate = ModuleGate.permissive();
      expect(gate.hasAnyModule([]), false);
    });
  });

  group('ModuleGate - Enabled Modules List', () {
    test('returns empty list when plan is null', () {
      final gate = ModuleGate.permissive();
      expect(gate.enabledModules(), isEmpty);
    });

    test('returns activeModules from plan', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery', 'loyalty', 'roulette'],
      );

      final gate = ModuleGate(plan: plan);
      final modules = gate.enabledModules();

      expect(modules, ['delivery', 'loyalty', 'roulette']);
      expect(modules.length, 3);
    });

    test('returns copy of activeModules (immutability)', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery'],
      );

      final gate = ModuleGate(plan: plan);
      final modules1 = gate.enabledModules();
      final modules2 = gate.enabledModules();

      expect(identical(modules1, modules2), false);
      expect(modules1, modules2);
    });
  });

  group('ModuleGate - Edge Cases', () {
    test('handles plan with null activeModules gracefully', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        name: 'Test Restaurant',
        slug: 'test-resto',
        // activeModules defaults to empty list
      );

      final gate = ModuleGate(plan: plan);

      expect(gate.isModuleEnabled(ModuleId.delivery), false);
      expect(gate.allowedOrderTypes(), ['dine_in', 'takeaway']);
      expect(gate.enabledModules(), isEmpty);
    });

    test('toString provides useful debug info', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto-123',
        name: 'Test Restaurant',
        slug: 'test-resto',
        activeModules: ['delivery', 'loyalty'],
      );

      final gate = ModuleGate(plan: plan);
      final str = gate.toString();

      expect(str, contains('test-resto-123'));
      expect(str, contains('modules: 2'));
    });

    test('allowWhenPlanNull parameter controls null behavior', () {
      final gateAllowing = ModuleGate(plan: null, allowWhenPlanNull: true);
      final gateDenying = ModuleGate(plan: null, allowWhenPlanNull: false);

      expect(gateAllowing.isModuleEnabled(ModuleId.delivery), true);
      expect(gateDenying.isModuleEnabled(ModuleId.delivery), false);
    });
  });
}
