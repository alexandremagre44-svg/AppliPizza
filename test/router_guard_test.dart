/// Test for Router Guard (Phase 4C)
///
/// This test verifies route guarding functionality.

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/runtime/router_guard.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';

void main() {
  group('Router Guard Tests', () {
    // Helper to create a mock GoRouterState
    GoRouterState createMockState(String path) {
      return GoRouterState(
        GoRouter(routes: []),
        matchedLocation: path,
        uri: Uri.parse(path),
      );
    }

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

    test('whiteLabelRouteGuard allows all routes when plan is null', () {
      final state = createMockState('/rewards');
      final redirect = whiteLabelRouteGuard(state, null);
      expect(redirect, isNull); // No redirect, route allowed
    });

    test('whiteLabelRouteGuard allows system routes always', () {
      final plan = createTestPlan(activeModules: []); // No modules active

      final homeState = createMockState('/home');
      expect(whiteLabelRouteGuard(homeState, plan), isNull);

      final menuState = createMockState('/menu');
      expect(whiteLabelRouteGuard(menuState, plan), isNull);

      final cartState = createMockState('/cart');
      expect(whiteLabelRouteGuard(cartState, plan), isNull);
    });

    test('whiteLabelRouteGuard blocks routes for inactive modules', () {
      final plan = createTestPlan(
        activeModules: ['loyalty'], // Only loyalty active
      );

      // Loyalty active - should allow
      final loyaltyState = createMockState('/rewards');
      expect(whiteLabelRouteGuard(loyaltyState, plan), isNull);

      // Roulette inactive - should block
      final rouletteState = createMockState('/roulette');
      final redirect = whiteLabelRouteGuard(rouletteState, plan);
      expect(redirect, '/home'); // Redirects to home
    });

    test('whiteLabelRouteGuard allows routes for active modules', () {
      final plan = createTestPlan(
        activeModules: ['loyalty', 'roulette'],
      );

      final loyaltyState = createMockState('/rewards');
      expect(whiteLabelRouteGuard(loyaltyState, plan), isNull);

      final rouletteState = createMockState('/roulette');
      expect(whiteLabelRouteGuard(rouletteState, plan), isNull);
    });

    test('whiteLabelRouteGuard skips validation for auth routes', () {
      final plan = createTestPlan(activeModules: []);

      expect(whiteLabelRouteGuard(createMockState('/login'), plan), isNull);
      expect(whiteLabelRouteGuard(createMockState('/signup'), plan), isNull);
      expect(whiteLabelRouteGuard(createMockState('/splash'), plan), isNull);
    });

    test('whiteLabelRouteGuard skips validation for admin routes', () {
      final plan = createTestPlan(activeModules: []);

      expect(whiteLabelRouteGuard(createMockState('/admin'), plan), isNull);
      expect(whiteLabelRouteGuard(createMockState('/admin/products'), plan), isNull);
    });

    test('whiteLabelRouteGuardWithRedirect uses custom redirect', () {
      final plan = createTestPlan(activeModules: []);
      final state = createMockState('/roulette');

      final redirect = whiteLabelRouteGuardWithRedirect(
        state,
        plan,
        redirectTo: '/menu',
      );

      expect(redirect, '/menu'); // Custom redirect
    });

    test('isRouteAccessible checks route accessibility', () {
      final plan = createTestPlan(activeModules: ['loyalty']);

      expect(isRouteAccessible('/home', plan), true); // System route
      expect(isRouteAccessible('/rewards', plan), true); // Active module
      expect(isRouteAccessible('/roulette', plan), false); // Inactive module
    });

    test('isRouteAccessible returns true for all routes when plan is null', () {
      expect(isRouteAccessible('/home', null), true);
      expect(isRouteAccessible('/rewards', null), true);
      expect(isRouteAccessible('/roulette', null), true);
    });

    test('getAccessibleRoutes returns correct list', () {
      final plan = createTestPlan(
        activeModules: ['loyalty', 'delivery'],
      );

      final accessible = getAccessibleRoutes(plan);

      // Should include system routes
      expect(accessible, contains('/home'));
      expect(accessible, contains('/menu'));
      expect(accessible, contains('/cart'));

      // Should include active module routes
      expect(accessible, contains('/rewards'));
      expect(accessible, contains('/delivery'));

      // Should not include inactive module routes
      expect(accessible, isNot(contains('/roulette')));
    });

    test('getBlockedRoutes returns correct list', () {
      final plan = createTestPlan(
        activeModules: ['loyalty'], // Only loyalty active
      );

      final blocked = getBlockedRoutes(plan);

      // Should include inactive module routes
      expect(blocked, contains('/roulette'));
      expect(blocked, contains('/delivery'));

      // Should not include active module routes
      expect(blocked, isNot(contains('/rewards')));
    });

    test('validateRouteGuard detects issues', () {
      // Plan with no active modules
      final emptyPlan = createTestPlan(activeModules: []);
      final errors = validateRouteGuard(emptyPlan);
      expect(errors, contains('Plan has no active modules'));

      // Plan with active modules should have no errors (or fewer errors)
      final normalPlan = createTestPlan(activeModules: ['loyalty', 'delivery']);
      final normalErrors = validateRouteGuard(normalPlan);
      expect(normalErrors.length, lessThan(errors.length));
    });

    test('whiteLabelRouteGuard allows custom pages', () {
      final plan = createTestPlan(activeModules: ['loyalty']);
      
      // Custom page route (not tied to a module)
      final customState = createMockState('/page/custom-about');
      expect(whiteLabelRouteGuard(customState, plan), isNull);
    });
  });
}
