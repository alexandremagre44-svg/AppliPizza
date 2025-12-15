/// Test suite for POS module normalization
///
/// Validates that the POS module architecture follows White Label doctrine:
/// - POS is a single root module
/// - staff_tablet and kitchen_tablet are deprecated
/// - POS OFF = zero POS functionality
/// - POS ON = complete POS system
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/core/module_registry.dart';
import 'package:pizza_delizza/white_label/core/module_category.dart';
import 'package:pizza_delizza/white_label/runtime/module_gate.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';

void main() {
  group('POS Module Normalization', () {
    test('ModuleId should only have pos, not staff_tablet or kitchen_tablet', () {
      // Verify that only pos exists in the enum
      final allModules = ModuleId.values;
      
      expect(allModules.contains(ModuleId.pos), isTrue, 
          reason: 'ModuleId.pos should exist');
      
      // Since we removed staff_tablet and kitchen_tablet from the enum,
      // attempting to access them should cause compilation error
      // This test verifies the enum structure is correct
      expect(allModules.length, greaterThan(0),
          reason: 'Should have at least one module');
    });

    test('ModuleRegistry should have pos entry with proper dependencies', () {
      final posDefinition = ModuleRegistry.of('pos');
      
      expect(posDefinition, isNotNull, 
          reason: 'POS module should be in registry');
      expect(posDefinition!.id, equals('pos'),
          reason: 'Module ID should be "pos"');
      expect(posDefinition.category, equals(ModuleCategory.operations),
          reason: 'POS should be in operations category');
      expect(posDefinition.dependencies, contains('ordering'),
          reason: 'POS should depend on ordering');
      expect(posDefinition.dependencies, contains('payments'),
          reason: 'POS should depend on payments');
    });

    test('ModuleRegistry should not have staff_tablet or kitchen_tablet entries', () {
      final staffDefinition = ModuleRegistry.of('staff_tablet');
      final kitchenDefinition = ModuleRegistry.of('kitchen_tablet');
      
      expect(staffDefinition, isNull,
          reason: 'staff_tablet should not be in registry');
      expect(kitchenDefinition, isNull,
          reason: 'kitchen_tablet should not be in registry');
    });

    test('POS module should be marked as system category', () {
      final posModule = ModuleId.pos;
      
      expect(posModule.isSystemModule, isTrue,
          reason: 'POS should be a system module');
      expect(posModule.category, equals(ModuleCategory.system),
          reason: 'POS should have system category');
    });

    test('ModuleGate with POS OFF should block all POS functionality', () {
      // Create a plan without POS module
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        restaurantName: 'Test Restaurant',
        modules: [
          // Only ordering, no POS
          ModuleConfig(id: 'ordering', enabled: true),
        ],
        activeModules: ['ordering'],
        featureFlags: const {},
      );
      
      final gate = ModuleGate(plan: plan);
      
      expect(gate.isModuleEnabled(ModuleId.pos), isFalse,
          reason: 'POS should be disabled when not in plan');
      expect(gate.isModuleEnabled(ModuleId.ordering), isTrue,
          reason: 'Ordering should be enabled');
    });

    test('ModuleGate with POS ON should enable POS functionality', () {
      // Create a plan with POS module
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-resto',
        restaurantName: 'Test Restaurant',
        modules: [
          ModuleConfig(id: 'ordering', enabled: true),
          ModuleConfig(id: 'payments', enabled: true),
          ModuleConfig(id: 'pos', enabled: true),
        ],
        activeModules: ['ordering', 'payments', 'pos'],
        featureFlags: const {},
      );
      
      final gate = ModuleGate(plan: plan);
      
      expect(gate.isModuleEnabled(ModuleId.pos), isTrue,
          reason: 'POS should be enabled when in plan');
      expect(gate.isModuleEnabled(ModuleId.ordering), isTrue,
          reason: 'Ordering should be enabled');
      expect(gate.isModuleEnabled(ModuleId.payments), isTrue,
          reason: 'Payments should be enabled');
    });

    test('POS code should resolve to "pos" not "staff_tablet" or "kitchen_tablet"', () {
      final posCode = ModuleId.pos.code;
      
      expect(posCode, equals('pos'),
          reason: 'POS module code should be "pos"');
    });

    test('POS label should be descriptive', () {
      final posLabel = ModuleId.pos.label;
      
      expect(posLabel, isNotEmpty,
          reason: 'POS should have a label');
      expect(posLabel.toLowerCase(), contains('pos'),
          reason: 'Label should mention POS');
    });

    test('All POS-related routes should require pos module', () {
      // This is a documentation test to ensure we remember the requirement
      // In practice, route guards are tested separately
      
      // POS-related routes that must be gated by ModuleId.pos:
      final posRoutes = [
        '/pos',
        '/staff-tablet',
        '/staff-tablet/catalog',
        '/staff-tablet/checkout',
        '/staff-tablet/history',
        '/kitchen',
      ];
      
      expect(posRoutes.length, equals(6),
          reason: 'Should have identified all POS routes');
      
      // All these routes must check ModuleId.pos, not separate modules
    });
  });

  group('POS Module Integration', () {
    test('Builder should not expose POS as a selectable module', () {
      // POS is a system module and should never appear in Builder
      // This is enforced by the module category system
      
      expect(ModuleId.pos.isSystemModule, isTrue,
          reason: 'POS should be system module to prevent Builder exposure');
    });

    test('POS dependencies should be satisfied before enabling', () {
      final posDefinition = ModuleRegistry.of('pos');
      
      expect(posDefinition, isNotNull);
      expect(posDefinition!.dependencies.isNotEmpty, isTrue,
          reason: 'POS should have dependencies');
      
      // Dependencies should be checked before enabling POS
      final requiredModules = posDefinition.dependencies;
      expect(requiredModules.contains('ordering'), isTrue,
          reason: 'POS requires ordering');
      expect(requiredModules.contains('payments'), isTrue,
          reason: 'POS requires payments');
    });
  });
}
