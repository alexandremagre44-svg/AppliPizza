/// Test for Module Runtime Mapping (Phase 4B)
///
/// This test verifies the runtime mapping layer works correctly.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/core/module_runtime_mapping.dart';

void main() {
  group('ModuleRuntimeMapping Tests', () {
    test('getRuntimeRoute returns correct routes for implemented modules', () {
      // Test implemented modules with routes
      expect(ModuleRuntimeMapping.getRuntimeRoute(ModuleId.loyalty), '/rewards');
      expect(ModuleRuntimeMapping.getRuntimeRoute(ModuleId.roulette), '/roulette');
      expect(ModuleRuntimeMapping.getRuntimeRoute(ModuleId.delivery), '/delivery');
      expect(ModuleRuntimeMapping.getRuntimeRoute(ModuleId.ordering), '/menu');
    });

    test('getRuntimeRoute returns null for modules without pages', () {
      // Theme doesn't have a route
      expect(ModuleRuntimeMapping.getRuntimeRoute(ModuleId.theme), isNull);
    });

    test('getRuntimePage returns correct values', () {
      // Modules with pages
      expect(ModuleRuntimeMapping.getRuntimePage(ModuleId.loyalty), true);
      expect(ModuleRuntimeMapping.getRuntimePage(ModuleId.roulette), true);
      expect(ModuleRuntimeMapping.getRuntimePage(ModuleId.delivery), true);

      // Modules without pages
      expect(ModuleRuntimeMapping.getRuntimePage(ModuleId.theme), false);
      expect(ModuleRuntimeMapping.getRuntimePage(ModuleId.newsletter), false);
    });

    test('hasBuilderBlock returns correct values', () {
      // Modules with builder blocks
      expect(ModuleRuntimeMapping.hasBuilderBlock(ModuleId.loyalty), true);
      expect(ModuleRuntimeMapping.hasBuilderBlock(ModuleId.roulette), true);
      expect(ModuleRuntimeMapping.hasBuilderBlock(ModuleId.promotions), true);

      // Modules without builder blocks
      expect(ModuleRuntimeMapping.hasBuilderBlock(ModuleId.delivery), false);
      expect(ModuleRuntimeMapping.hasBuilderBlock(ModuleId.theme), false);
    });

    test('isImplemented returns correct values', () {
      // Fully implemented modules
      expect(ModuleRuntimeMapping.isImplemented(ModuleId.loyalty), true);
      expect(ModuleRuntimeMapping.isImplemented(ModuleId.roulette), true);
      expect(ModuleRuntimeMapping.isImplemented(ModuleId.ordering), true);

      // Not fully implemented
      expect(ModuleRuntimeMapping.isImplemented(ModuleId.newsletter), false);
      expect(ModuleRuntimeMapping.isImplemented(ModuleId.wallet), false);
    });

    test('isPartiallyImplemented returns correct values', () {
      // Partially implemented modules
      expect(ModuleRuntimeMapping.isPartiallyImplemented(ModuleId.newsletter), true);
      expect(ModuleRuntimeMapping.isPartiallyImplemented(ModuleId.paymentTerminal), true);

      // Fully implemented or planned modules
      expect(ModuleRuntimeMapping.isPartiallyImplemented(ModuleId.loyalty), false);
      expect(ModuleRuntimeMapping.isPartiallyImplemented(ModuleId.wallet), false);
    });

    test('isPlanned returns correct values', () {
      // Planned modules
      expect(ModuleRuntimeMapping.isPlanned(ModuleId.wallet), true);
      expect(ModuleRuntimeMapping.isPlanned(ModuleId.timeRecorder), true);

      // Implemented modules
      expect(ModuleRuntimeMapping.isPlanned(ModuleId.loyalty), false);
      expect(ModuleRuntimeMapping.isPlanned(ModuleId.roulette), false);
    });

    test('isReady is same as isImplemented', () {
      expect(
        ModuleRuntimeMapping.isReady(ModuleId.loyalty),
        ModuleRuntimeMapping.isImplemented(ModuleId.loyalty),
      );
      expect(
        ModuleRuntimeMapping.isReady(ModuleId.wallet),
        ModuleRuntimeMapping.isImplemented(ModuleId.wallet),
      );
    });

    test('exists returns true for all modules', () {
      for (final moduleId in ModuleId.values) {
        expect(ModuleRuntimeMapping.exists(moduleId), true,
            reason: 'Module ${moduleId.code} should exist');
      }
    });

    test('getRoutesForModules returns correct routes', () {
      final routes = ModuleRuntimeMapping.getRoutesForModules([
        ModuleId.loyalty,
        ModuleId.roulette,
        ModuleId.theme, // Has no route
      ]);

      expect(routes['loyalty'], '/rewards');
      expect(routes['roulette'], '/roulette');
      expect(routes.containsKey('theme'), false); // No route for theme
    });

    test('getModulesWithPages returns correct list', () {
      final modules = ModuleRuntimeMapping.getModulesWithPages();
      
      expect(modules, contains(ModuleId.loyalty));
      expect(modules, contains(ModuleId.roulette));
      expect(modules, contains(ModuleId.delivery));
      
      expect(modules, isNot(contains(ModuleId.theme)));
      expect(modules, isNot(contains(ModuleId.newsletter)));
    });

    test('getModulesWithBuilderBlocks returns correct list', () {
      final modules = ModuleRuntimeMapping.getModulesWithBuilderBlocks();
      
      expect(modules, contains(ModuleId.loyalty));
      expect(modules, contains(ModuleId.roulette));
      expect(modules, contains(ModuleId.promotions));
      
      // Verify that only modules with builder blocks are returned
      expect(modules.length, greaterThan(0));
      for (final module in modules) {
        expect(ModuleRuntimeMapping.hasBuilderBlock(module), true);
      }
    });

    test('getStatusSummary returns correct counts', () {
      final summary = ModuleRuntimeMapping.getStatusSummary();
      
      expect(summary['implemented'], greaterThan(0));
      expect(summary['partial'], greaterThan(0));
      expect(summary['planned'], greaterThan(0));
      
      // Total should equal number of modules
      final total = summary['implemented']! + summary['partial']! + summary['planned']!;
      expect(total, ModuleId.values.length);
    });

    test('getLabel returns correct labels', () {
      expect(ModuleRuntimeMapping.getLabel(ModuleId.loyalty), 'Fidélité');
      expect(ModuleRuntimeMapping.getLabel(ModuleId.roulette), 'Roulette');
      expect(ModuleRuntimeMapping.getLabel(ModuleId.delivery), 'Livraison');
    });

    test('isPremium returns correct values', () {
      // Premium modules
      expect(ModuleRuntimeMapping.isPremium(ModuleId.roulette), true);
      expect(ModuleRuntimeMapping.isPremium(ModuleId.wallet), true);

      // Free modules
      expect(ModuleRuntimeMapping.isPremium(ModuleId.loyalty), false);
      expect(ModuleRuntimeMapping.isPremium(ModuleId.ordering), false);
    });
  });
}
