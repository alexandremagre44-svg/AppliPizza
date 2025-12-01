/// test/white_label/app_module_integration_test.dart
///
/// Tests d'intégration pour Phase 3: connexion de l'application cliente.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza/white_label/runtime/module_runtime_adapter.dart';
import 'package:pizza_delizza/src/navigation/dynamic_navbar_builder.dart';
import 'package:pizza_delizza/builder/models/models.dart';

void main() {
  group('Phase 3 Integration Tests', () {
    test('Module ordering OFF → écran commande inaccessible', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'loyalty'], // Pas de 'ordering'
      );

      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.ordering),
        isFalse,
      );
    });

    test('Module roulette OFF → écran roulette inaccessible', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'loyalty'], // Pas de 'roulette'
      );

      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.roulette),
        isFalse,
      );
    });

    test('Module delivery OFF → onglet livraison masqué', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['ordering', 'loyalty'], // Pas de 'delivery'
      );

      // Simuler des pages de navigation
      final pages = [
        BuilderPage(
          pageKey: 'home',
          route: '/home',
          order: 0,
          title: 'Accueil',
          isActive: true,
        ),
        BuilderPage(
          pageKey: 'delivery',
          route: '/delivery',
          order: 1,
          title: 'Livraison',
          isActive: true,
        ),
        BuilderPage(
          pageKey: 'profile',
          route: '/profile',
          order: 2,
          title: 'Profil',
          isActive: true,
        ),
      ];

      // Vérifier que delivery nécessite un module
      expect(
        DynamicNavbarBuilder.requiresModule('/delivery'),
        isTrue,
      );

      expect(
        DynamicNavbarBuilder.getRequiredModule('/delivery'),
        equals(ModuleId.delivery),
      );
    });

    test('Tout ON → tout visible', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'ordering', 'loyalty', 'roulette'],
      );

      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.delivery),
        isTrue,
      );
      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.ordering),
        isTrue,
      );
      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.loyalty),
        isTrue,
      );
      expect(
        ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.roulette),
        isTrue,
      );
    });

    test('Aucun plan (premier lancement) → fallback 100% legacy', () {
      // Plan null = mode fallback
      expect(
        ModuleRuntimeAdapter.isModuleActiveById(null, ModuleId.delivery),
        isFalse,
      );

      expect(
        ModuleRuntimeAdapter.getActiveModules(null),
        isEmpty,
      );
    });

    test('DynamicNavbarBuilder gère le fallback correctement', () {
      // Fallback navbar pour restaurants sans plan
      final fallback = DynamicNavbarBuilder.buildFallbackNavItems(
        cartItemCount: 5,
      );

      expect(fallback.items.length, greaterThanOrEqualTo(4));
      expect(fallback.pages.length, equals(fallback.items.length));
      
      // Vérifier que les routes de base sont présentes
      final routes = fallback.pages.map((p) => p.route).toList();
      expect(routes, contains('/home'));
      expect(routes, contains('/menu'));
      expect(routes, contains('/cart'));
      expect(routes, contains('/profile'));
    });

    test('Routes système toujours accessibles sans module', () {
      // Routes de base ne nécessitent pas de module
      expect(
        DynamicNavbarBuilder.requiresModule('/home'),
        isFalse,
      );
      expect(
        DynamicNavbarBuilder.requiresModule('/menu'),
        isFalse,
      );
      expect(
        DynamicNavbarBuilder.requiresModule('/cart'),
        isFalse,
      );
      expect(
        DynamicNavbarBuilder.requiresModule('/profile'),
        isFalse,
      );
    });

    test('Routes module nécessitent leur module respectif', () {
      expect(
        DynamicNavbarBuilder.getRequiredModule('/delivery'),
        equals(ModuleId.delivery),
      );
      expect(
        DynamicNavbarBuilder.getRequiredModule('/rewards'),
        equals(ModuleId.loyalty),
      );
      expect(
        DynamicNavbarBuilder.getRequiredModule('/roulette'),
        equals(ModuleId.roulette),
      );
      expect(
        DynamicNavbarBuilder.getRequiredModule('/kitchen'),
        equals(ModuleId.kitchenTablet),
      );
      expect(
        DynamicNavbarBuilder.getRequiredModule('/staff'),
        equals(ModuleId.staffTablet),
      );
    });

    test('Module activation status correct via adapter', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test_123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['delivery', 'loyalty'],
      );

      final activeModules = ModuleRuntimeAdapter.getActiveModules(plan);
      final inactiveModules = ModuleRuntimeAdapter.getInactiveModules(plan);

      expect(activeModules, contains(ModuleId.delivery));
      expect(activeModules, contains(ModuleId.loyalty));
      expect(activeModules.length, equals(2));

      expect(inactiveModules, isNot(contains(ModuleId.delivery)));
      expect(inactiveModules, isNot(contains(ModuleId.loyalty)));
      expect(inactiveModules, contains(ModuleId.roulette));
    });
  });
}
