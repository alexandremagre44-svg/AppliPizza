/// Test for Module Route Resolver (Phase 4B)
///
/// This test verifies route resolution and phantom route detection.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/runtime/module_route_resolver.dart';

void main() {
  group('ModuleRouteResolver Tests', () {
    test('resolve returns correct module for module routes', () {
      expect(ModuleRouteResolver.resolve('/rewards'), ModuleId.loyalty);
      expect(ModuleRouteResolver.resolve('/roulette'), ModuleId.roulette);
      expect(ModuleRouteResolver.resolve('/delivery'), ModuleId.delivery);
      expect(ModuleRouteResolver.resolve('/menu'), ModuleId.ordering);
    });

    test('resolve returns null for system routes', () {
      expect(ModuleRouteResolver.resolve('/home'), isNull);
      expect(ModuleRouteResolver.resolve('/cart'), isNull);
      expect(ModuleRouteResolver.resolve('/profile'), isNull);
      expect(ModuleRouteResolver.resolve('/'), isNull);
    });

    test('resolve handles route normalization', () {
      // With trailing slash
      expect(ModuleRouteResolver.resolve('/rewards/'), ModuleId.loyalty);
      
      // With query params
      expect(ModuleRouteResolver.resolve('/rewards?tab=active'), ModuleId.loyalty);
      
      // Without leading slash
      expect(ModuleRouteResolver.resolve('rewards'), ModuleId.loyalty);
    });

    test('resolveDetailed provides full information', () {
      // System route
      final homeResult = ModuleRouteResolver.resolveDetailed('/home');
      expect(homeResult.isResolved, true);
      expect(homeResult.requiresModule, false);
      expect(homeResult.moduleId, isNull);

      // Module route
      final rewardsResult = ModuleRouteResolver.resolveDetailed('/rewards');
      expect(rewardsResult.isResolved, true);
      expect(rewardsResult.requiresModule, true);
      expect(rewardsResult.moduleId, ModuleId.loyalty);

      // Unknown route
      final unknownResult = ModuleRouteResolver.resolveDetailed('/unknown-page');
      expect(unknownResult.isResolved, false);
      expect(unknownResult.requiresModule, true);
      expect(unknownResult.moduleId, isNull);
    });

    test('belongsToModule checks route ownership', () {
      expect(ModuleRouteResolver.belongsToModule('/rewards', ModuleId.loyalty), true);
      expect(ModuleRouteResolver.belongsToModule('/rewards', ModuleId.roulette), false);
      expect(ModuleRouteResolver.belongsToModule('/home', ModuleId.loyalty), false);
    });

    test('isValidRoute correctly identifies valid routes', () {
      // Valid system routes
      expect(ModuleRouteResolver.isValidRoute('/home'), true);
      expect(ModuleRouteResolver.isValidRoute('/cart'), true);

      // Valid module routes
      expect(ModuleRouteResolver.isValidRoute('/rewards'), true);
      expect(ModuleRouteResolver.isValidRoute('/roulette'), true);

      // Invalid routes
      expect(ModuleRouteResolver.isValidRoute('/unknown-page'), false);
      expect(ModuleRouteResolver.isValidRoute('/non-existent'), false);
    });

    test('isPhantomRoute detects phantom routes', () {
      // Phantom routes (not system, no module owns them)
      expect(ModuleRouteResolver.isPhantomRoute('/unknown-page'), true);
      expect(ModuleRouteResolver.isPhantomRoute('/non-existent'), true);

      // Not phantom (system routes)
      expect(ModuleRouteResolver.isPhantomRoute('/home'), false);
      expect(ModuleRouteResolver.isPhantomRoute('/cart'), false);

      // Not phantom (module routes)
      expect(ModuleRouteResolver.isPhantomRoute('/rewards'), false);
      expect(ModuleRouteResolver.isPhantomRoute('/roulette'), false);
    });

    test('getAllModuleRoutes returns all routes', () {
      final routes = ModuleRouteResolver.getAllModuleRoutes();
      
      expect(routes['/rewards'], ModuleId.loyalty);
      expect(routes['/roulette'], ModuleId.roulette);
      expect(routes['/delivery'], ModuleId.delivery);
      
      // Should not contain system routes
      expect(routes.containsKey('/home'), false);
      expect(routes.containsKey('/cart'), false);
    });

    test('getSystemRoutes returns all system routes', () {
      final routes = ModuleRouteResolver.getSystemRoutes();
      
      expect(routes, contains('/'));
      expect(routes, contains('/home'));
      expect(routes, contains('/menu'));
      expect(routes, contains('/cart'));
      expect(routes, contains('/profile'));
    });

    test('validateRoutes detects phantoms in a list', () {
      final testRoutes = [
        '/home',           // Valid system route
        '/rewards',        // Valid module route
        '/unknown-page',   // Phantom
        '/roulette',       // Valid module route
        '/non-existent',   // Phantom
      ];
      
      final phantoms = ModuleRouteResolver.validateRoutes(testRoutes);
      
      expect(phantoms, contains('/unknown-page'));
      expect(phantoms, contains('/non-existent'));
      expect(phantoms, isNot(contains('/home')));
      expect(phantoms, isNot(contains('/rewards')));
    });

    test('prefix matching works for nested routes', () {
      // Assuming nested routes like /roulette/play should resolve to roulette module
      // This test depends on the module having the route defined
      final result = ModuleRouteResolver.resolveDetailed('/roulette/play');
      
      // Should match roulette module by prefix
      expect(result.moduleId, ModuleId.roulette);
      expect(result.isResolved, true);
    });

    test('RouteResolutionResult factory methods work correctly', () {
      final success = RouteResolutionResult.success(
        moduleId: ModuleId.loyalty,
        route: '/rewards',
      );
      expect(success.isResolved, true);
      expect(success.requiresModule, true);
      expect(success.moduleId, ModuleId.loyalty);

      final systemRoute = RouteResolutionResult.systemRoute(route: '/home');
      expect(systemRoute.isResolved, true);
      expect(systemRoute.requiresModule, false);
      expect(systemRoute.moduleId, isNull);

      final notFound = RouteResolutionResult.notFound(route: '/unknown');
      expect(notFound.isResolved, false);
      expect(notFound.requiresModule, true);
      expect(notFound.moduleId, isNull);
    });
  });
}
