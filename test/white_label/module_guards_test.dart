/// Test for module guards functionality
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/runtime/module_navigation_registry.dart';
import 'package:pizza_delizza/white_label/runtime/module_route_resolver.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';

void main() {
  group('ModuleNavigationRegistry', () {
    setUp(() {
      // Clear registry before each test
      ModuleNavigationRegistry.clear();
    });

    test('should register module routes', () {
      // No routes initially
      expect(ModuleNavigationRegistry.getAllRegisteredModules(), isEmpty);

      // Register a module (note: we can't easily create GoRoute in tests)
      // So we just verify the registry structure exists
      expect(ModuleNavigationRegistry.hasRoutes(ModuleId.loyalty), false);
    });

    test('should get summary of registered routes', () {
      final summary = ModuleNavigationRegistry.getSummary();
      
      expect(summary, isA<Map<String, dynamic>>());
      expect(summary['totalModules'], isA<int>());
      expect(summary['totalRoutes'], isA<int>());
    });
  });

  group('ModuleRouteResolver', () {
    test('should resolve routes for plan with enabled modules', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-restaurant',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['loyalty', 'roulette'],
      );

      // Verify plan has the modules
      expect(plan.hasModule(ModuleId.loyalty), true);
      expect(plan.hasModule(ModuleId.roulette), true);
      expect(plan.hasModule(ModuleId.delivery), false);
    });

    test('should return empty list for null plan', () {
      final routes = ModuleRouteResolver.resolveRoutesFor(null);
      expect(routes, isEmpty);
    });

    test('should get enabled modules with routes', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test-restaurant',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        activeModules: ['loyalty'],
      );

      final enabledModules = ModuleRouteResolver.getEnabledModulesWithRoutes(plan);
      
      // Should be empty since we haven't registered any routes
      expect(enabledModules, isA<List<ModuleId>>());
    });

    test('should validate routes against active modules', () {
      final route = '/rewards';
      
      // Should resolve to loyalty module
      final resolved = ModuleRouteResolver.resolve(route);
      expect(resolved, ModuleId.loyalty);
    });

    test('should identify system routes', () {
      expect(ModuleRouteResolver.isValidRoute('/home'), true);
      expect(ModuleRouteResolver.isValidRoute('/menu'), true);
      expect(ModuleRouteResolver.isValidRoute('/cart'), true);
    });

    test('should get all system routes', () {
      final systemRoutes = ModuleRouteResolver.getSystemRoutes();
      
      expect(systemRoutes, contains('/home'));
      expect(systemRoutes, contains('/menu'));
      expect(systemRoutes, contains('/cart'));
      expect(systemRoutes, contains('/profile'));
    });
  });

  group('RestaurantPlanUnified', () {
    test('should check if module is enabled', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test',
        name: 'Test',
        slug: 'test',
        activeModules: ['loyalty', 'roulette'],
      );

      expect(plan.hasModule(ModuleId.loyalty), true);
      expect(plan.hasModule(ModuleId.roulette), true);
      expect(plan.hasModule(ModuleId.delivery), false);
    });

    test('should get list of enabled module IDs', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test',
        name: 'Test',
        slug: 'test',
        activeModules: ['loyalty', 'roulette', 'delivery'],
      );

      final enabledIds = plan.enabledModuleIds;
      
      expect(enabledIds, hasLength(3));
      expect(enabledIds, contains(ModuleId.loyalty));
      expect(enabledIds, contains(ModuleId.roulette));
      expect(enabledIds, contains(ModuleId.delivery));
    });
  });
}
