/// Test for Unreachable Pages Adapter (Phase 4C)
///
/// This test verifies page visibility functionality.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/runtime/unreachable_pages_adapter.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';

void main() {
  group('Unreachable Pages Adapter Tests', () {
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

    test('isPageReachable returns true for system routes', () {
      final plan = createTestPlan(activeModules: []);

      expect(isPageReachable('/home', plan), true);
      expect(isPageReachable('/menu', plan), true);
      expect(isPageReachable('/cart', plan), true);
      expect(isPageReachable('/profile', plan), true);
    });

    test('isPageReachable returns true for active module routes', () {
      final plan = createTestPlan(activeModules: ['loyalty', 'roulette']);

      expect(isPageReachable('/rewards', plan), true);
      expect(isPageReachable('/roulette', plan), true);
    });

    test('isPageReachable returns false for inactive module routes', () {
      final plan = createTestPlan(activeModules: ['loyalty']);

      expect(isPageReachable('/roulette', plan), false);
      expect(isPageReachable('/delivery', plan), false);
    });

    test('isPageReachable returns true for all when plan is null', () {
      expect(isPageReachable('/home', null), true);
      expect(isPageReachable('/rewards', null), true);
      expect(isPageReachable('/roulette', null), true);
    });

    test('shouldHidePage is inverse of isPageReachable', () {
      final plan = createTestPlan(activeModules: ['loyalty']);

      expect(shouldHidePage('/rewards', plan), false); // Reachable
      expect(shouldHidePage('/roulette', plan), true); // Not reachable
    });

    test('isPagePartiallyAvailable detects partial modules', () {
      final plan = createTestPlan(activeModules: ['newsletter']);

      // Newsletter is partially implemented
      expect(isPagePartiallyAvailable('/newsletter', plan), true);

      // Loyalty is fully implemented
      final fullPlan = createTestPlan(activeModules: ['loyalty']);
      expect(isPagePartiallyAvailable('/rewards', fullPlan), false);
    });

    test('getUnreachableReason provides explanation', () {
      final plan = createTestPlan(activeModules: ['loyalty']);

      // Reachable page - no reason
      expect(getUnreachableReason('/rewards', plan), isNull);

      // Unreachable page - has reason
      final reason = getUnreachableReason('/roulette', plan);
      expect(reason, isNotNull);
      expect(reason, contains('not active'));
    });

    test('getReachablePages returns correct list', () {
      final plan = createTestPlan(
        activeModules: ['loyalty', 'delivery'],
      );

      final reachable = getReachablePages(plan);

      // Should include system routes
      expect(reachable, contains('/home'));
      expect(reachable, contains('/menu'));

      // Should include active module routes
      expect(reachable, contains('/rewards'));
      expect(reachable, contains('/delivery'));
    });

    test('getHiddenPages returns correct list', () {
      final plan = createTestPlan(
        activeModules: ['loyalty'],
      );

      final hidden = getHiddenPages(plan);

      // Should include inactive module routes with pages
      expect(hidden, contains('/roulette'));
      expect(hidden, contains('/delivery'));

      // Should not include active routes
      expect(hidden, isNot(contains('/rewards')));
    });

    test('getPartiallyAvailablePages returns correct list', () {
      final plan = createTestPlan(
        activeModules: ['newsletter', 'payment_terminal'],
      );

      final partial = getPartiallyAvailablePages(plan);

      // Should include partially implemented modules that are active
      expect(partial.length, greaterThan(0));
    });

    test('filterReachableRoutes filters correctly', () {
      final plan = createTestPlan(activeModules: ['loyalty']);

      final allRoutes = ['/home', '/rewards', '/roulette', '/menu'];
      final reachable = filterReachableRoutes(allRoutes, plan);

      expect(reachable, contains('/home'));
      expect(reachable, contains('/rewards'));
      expect(reachable, contains('/menu'));
      expect(reachable, isNot(contains('/roulette')));
    });

    test('filterUnreachableRoutes filters correctly', () {
      final plan = createTestPlan(activeModules: ['loyalty']);

      final allRoutes = ['/home', '/rewards', '/roulette', '/menu'];
      final unreachable = filterUnreachableRoutes(allRoutes, plan);

      expect(unreachable, contains('/roulette'));
      expect(unreachable, isNot(contains('/home')));
      expect(unreachable, isNot(contains('/rewards')));
    });

    test('getPageVisibilitySummary provides stats', () {
      final plan = createTestPlan(
        activeModules: ['loyalty', 'roulette'],
      );

      final summary = getPageVisibilitySummary(plan);

      expect(summary['reachable'], greaterThan(0));
      expect(summary['hidden'], greaterThan(0));
      expect(summary['activeModules'], 2);
      expect(summary['reachableRoutes'], isA<List>());
      expect(summary['hiddenRoutes'], isA<List>());
    });

    test('validatePageVisibility detects issues', () {
      // Plan with no active modules
      final emptyPlan = createTestPlan(activeModules: []);
      final warnings = validatePageVisibility(emptyPlan);
      expect(warnings.length, greaterThan(0));

      // Plan with active modules should have fewer warnings
      final normalPlan = createTestPlan(activeModules: ['loyalty', 'delivery']);
      final normalWarnings = validatePageVisibility(normalPlan);
      expect(normalWarnings.length, lessThanOrEqualTo(warnings.length));
    });

    test('filterReachableRoutes returns all when plan is null', () {
      final allRoutes = ['/home', '/rewards', '/roulette'];
      final reachable = filterReachableRoutes(allRoutes, null);

      expect(reachable, equals(allRoutes));
    });

    test('filterUnreachableRoutes returns empty when plan is null', () {
      final allRoutes = ['/home', '/rewards', '/roulette'];
      final unreachable = filterUnreachableRoutes(allRoutes, null);

      expect(unreachable, isEmpty);
    });
  });
}
