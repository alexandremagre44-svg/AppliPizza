/// test/white_label/module_activation_test.dart
///
/// Tests unitaires pour l'activation/désactivation des modules.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza/white_label/runtime/module_runtime_adapter.dart';

void main() {
  group('ModuleRuntimeAdapter', () {
    test('isModuleActive retourne true si le module est dans activeModules', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'loyalty'],
      );

      expect(
        ModuleRuntimeAdapter.isModuleActive(plan, 'delivery'),
        isTrue,
      );
      expect(
        ModuleRuntimeAdapter.isModuleActive(plan, 'loyalty'),
        isTrue,
      );
      expect(
        ModuleRuntimeAdapter.isModuleActive(plan, 'roulette'),
        isFalse,
      );
    });

    test('isModuleActiveById fonctionne avec ModuleId enum', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'loyalty', 'promotions'],
      );

      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.delivery),
        isTrue,
      );
      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.loyalty),
        isTrue,
      );
      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.roulette),
        isFalse,
      );
    });

    test('getActiveModules retourne la liste des modules actifs', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'loyalty'],
      );

      final activeModules = ModuleRuntimeAdapter.getActiveModules(plan);

      expect(activeModules, contains(ModuleId.delivery));
      expect(activeModules, contains(ModuleId.loyalty));
      expect(activeModules, isNot(contains(ModuleId.roulette)));
      expect(activeModules.length, equals(2));
    });

    test('getInactiveModules retourne les modules non activés', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery'],
      );

      final inactiveModules = ModuleRuntimeAdapter.getInactiveModules(plan);

      expect(inactiveModules, isNot(contains(ModuleId.delivery)));
      expect(inactiveModules, contains(ModuleId.loyalty));
      expect(inactiveModules, contains(ModuleId.roulette));
    });

    test('areAllModulesActive vérifie tous les modules requis', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'loyalty', 'ordering'],
      );

      expect(
        ModuleRuntimeAdapter.areAllModulesActive(
          plan,
          [ModuleId.delivery, ModuleId.loyalty],
        ),
        isTrue,
      );

      expect(
        ModuleRuntimeAdapter.areAllModulesActive(
          plan,
          [ModuleId.delivery, ModuleId.roulette],
        ),
        isFalse,
      );
    });

    test('isAnyModuleActive vérifie si au moins un module est actif', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery'],
      );

      expect(
        ModuleRuntimeAdapter.isAnyModuleActive(
          plan,
          [ModuleId.delivery, ModuleId.roulette],
        ),
        isTrue,
      );

      expect(
        ModuleRuntimeAdapter.isAnyModuleActive(
          plan,
          [ModuleId.roulette, ModuleId.loyalty],
        ),
        isFalse,
      );
    });

    test('retourne false si le plan est null', () {
      expect(
        ModuleRuntimeAdapter.isModuleActive(null, 'delivery'),
        isFalse,
      );

      expect(
        ModuleRuntimeAdapter.isModuleActiveById(null, ModuleId.delivery),
        isFalse,
      );

      expect(
        ModuleRuntimeAdapter.getActiveModules(null),
        isEmpty,
      );
    });
  });

  group('RestaurantPlanUnified', () {
    test('hasModule vérifie correctement les modules actifs', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'loyalty'],
      );

      expect(plan.hasModule(ModuleId.delivery), isTrue);
      expect(plan.hasModule(ModuleId.loyalty), isTrue);
      expect(plan.hasModule(ModuleId.roulette), isFalse);
    });

    test('enabledModuleIds retourne la liste typée des modules', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'loyalty', 'roulette'],
      );

      final enabledIds = plan.enabledModuleIds;

      expect(enabledIds, contains(ModuleId.delivery));
      expect(enabledIds, contains(ModuleId.loyalty));
      expect(enabledIds, contains(ModuleId.roulette));
      expect(enabledIds.length, equals(3));
    });

    test('gère les codes de modules invalides gracieusement', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'invalid_module', 'loyalty'],
      );

      final enabledIds = plan.enabledModuleIds;

      // Les modules invalides sont ignorés
      expect(enabledIds, contains(ModuleId.delivery));
      expect(enabledIds, contains(ModuleId.loyalty));
      expect(enabledIds.length, equals(2));
    });
  });
}
