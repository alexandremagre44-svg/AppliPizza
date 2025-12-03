// test/pos_kitchen_modules_test.dart
// Tests for kitchen_tablet and staff_tablet modules routes setup

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pizza_delizza/src/screens/kitchen/kitchen_screen.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/core/module_matrix.dart';
import 'package:pizza_delizza/white_label/core/module_runtime_mapping.dart';
import 'package:pizza_delizza/white_label/runtime/module_route_resolver.dart';

void main() {
  group('staff_tablet Module Tests (maps to /pos route)', () {
    test('ModuleId.staff_tablet exists', () {
      expect(ModuleId.values.contains(ModuleId.staff_tablet), isTrue);
    });

    test('ModuleId.staff_tablet has correct code', () {
      expect(ModuleId.staff_tablet.code, equals('staff_tablet'));
    });

    test('ModuleId.staff_tablet has correct label', () {
      expect(ModuleId.staff_tablet.label, equals('Caisse / Staff Tablet'));
    });

    test('ModuleId.staff_tablet has correct category', () {
      expect(ModuleId.staff_tablet.category, equals(ModuleCategory.operations));
    });

    test('staff_tablet module exists in module matrix', () {
      final meta = moduleMatrix['staff_tablet'];
      expect(meta, isNotNull);
      expect(meta!.id, equals('staff_tablet'));
      expect(meta.label, equals('Caisse / Staff Tablet'));
      expect(meta.status, equals(ModuleStatus.implemented));
      expect(meta.hasPage, isTrue);
      expect(meta.hasBuilderBlock, isFalse);
      expect(meta.defaultRoute, equals('/pos'));
      expect(meta.tags, contains('staff'));
      expect(meta.tags, contains('operations'));
    });

    test('ModuleRuntimeMapping returns correct route for staff_tablet', () {
      final route = ModuleRuntimeMapping.getRuntimeRoute(ModuleId.staff_tablet);
      expect(route, equals('/pos'));
    });

    test('ModuleRuntimeMapping indicates staff_tablet has a page', () {
      final hasPage = ModuleRuntimeMapping.getRuntimePage(ModuleId.staff_tablet);
      expect(hasPage, isTrue);
    });

    test('ModuleRuntimeMapping indicates staff_tablet has no builder block', () {
      final hasBlock = ModuleRuntimeMapping.hasBuilderBlock(ModuleId.staff_tablet);
      expect(hasBlock, isFalse);
    });

    test('ModuleRuntimeMapping indicates staff_tablet is implemented', () {
      final isImplemented = ModuleRuntimeMapping.isImplemented(ModuleId.staff_tablet);
      expect(isImplemented, isTrue);
    });

    test('ModuleRouteResolver resolves /pos to ModuleId.staff_tablet', () {
      final moduleId = ModuleRouteResolver.resolve('/pos');
      expect(moduleId, equals(ModuleId.staff_tablet));
    });

    test('ModuleRouteResolver.resolveDetailed provides full info for /pos', () {
      final result = ModuleRouteResolver.resolveDetailed('/pos');
      expect(result.isResolved, isTrue);
      expect(result.moduleId, equals(ModuleId.staff_tablet));
      expect(result.route, equals('/pos'));
      expect(result.requiresModule, isTrue);
    });
  });

  group('kitchen_tablet Module Tests (maps to /kitchen route)', () {
    test('ModuleId.kitchen_tablet exists', () {
      expect(ModuleId.values.contains(ModuleId.kitchen_tablet), isTrue);
    });

    test('ModuleId.kitchen_tablet has correct code', () {
      expect(ModuleId.kitchen_tablet.code, equals('kitchen_tablet'));
    });

    test('ModuleId.kitchen_tablet has correct label', () {
      expect(ModuleId.kitchen_tablet.label, equals('Tablette cuisine'));
    });

    test('ModuleId.kitchen_tablet has correct category', () {
      expect(ModuleId.kitchen_tablet.category, equals(ModuleCategory.operations));
    });

    test('kitchen_tablet module exists in module matrix', () {
      final meta = moduleMatrix['kitchen_tablet'];
      expect(meta, isNotNull);
      expect(meta!.id, equals('kitchen_tablet'));
      expect(meta.label, equals('Tablette cuisine'));
      expect(meta.status, equals(ModuleStatus.implemented));
      expect(meta.hasPage, isTrue);
      expect(meta.hasBuilderBlock, isFalse);
      expect(meta.defaultRoute, equals('/kitchen'));
      expect(meta.tags, contains('kitchen'));
      expect(meta.tags, contains('operations'));
    });

    test('ModuleRuntimeMapping returns correct route for kitchen_tablet', () {
      final route = ModuleRuntimeMapping.getRuntimeRoute(ModuleId.kitchen_tablet);
      expect(route, equals('/kitchen'));
    });

    test('ModuleRuntimeMapping indicates kitchen_tablet has a page', () {
      final hasPage = ModuleRuntimeMapping.getRuntimePage(ModuleId.kitchen_tablet);
      expect(hasPage, isTrue);
    });

    test('ModuleRuntimeMapping indicates kitchen_tablet has no builder block', () {
      final hasBlock = ModuleRuntimeMapping.hasBuilderBlock(ModuleId.kitchen_tablet);
      expect(hasBlock, isFalse);
    });

    test('ModuleRuntimeMapping indicates kitchen_tablet is implemented', () {
      final isImplemented = ModuleRuntimeMapping.isImplemented(ModuleId.kitchen_tablet);
      expect(isImplemented, isTrue);
    });

    test('ModuleRouteResolver resolves /kitchen to ModuleId.kitchen_tablet', () {
      final moduleId = ModuleRouteResolver.resolve('/kitchen');
      expect(moduleId, equals(ModuleId.kitchen_tablet));
    });

    test('ModuleRouteResolver.resolveDetailed provides full info for /kitchen', () {
      final result = ModuleRouteResolver.resolveDetailed('/kitchen');
      expect(result.isResolved, isTrue);
      expect(result.moduleId, equals(ModuleId.kitchen_tablet));
      expect(result.route, equals('/kitchen'));
      expect(result.requiresModule, isTrue);
    });

    testWidgets('KitchenScreen builds without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KitchenScreen(),
        ),
      );

      expect(find.byType(KitchenScreen), findsOneWidget);
      expect(find.text('Cuisine'), findsOneWidget);
      expect(find.text('Module Kitchen'), findsOneWidget);
      expect(find.byIcon(Icons.kitchen), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    test('Both modules are in operations category', () {
      expect(ModuleId.staff_tablet.category, equals(ModuleCategory.operations));
      expect(ModuleId.kitchen_tablet.category, equals(ModuleCategory.operations));
    });

    test('Both modules are implemented', () {
      expect(ModuleRuntimeMapping.isImplemented(ModuleId.staff_tablet), isTrue);
      expect(ModuleRuntimeMapping.isImplemented(ModuleId.kitchen_tablet), isTrue);
    });

    test('Both modules have pages but no builder blocks', () {
      expect(ModuleRuntimeMapping.getRuntimePage(ModuleId.staff_tablet), isTrue);
      expect(ModuleRuntimeMapping.getRuntimePage(ModuleId.kitchen_tablet), isTrue);
      expect(ModuleRuntimeMapping.hasBuilderBlock(ModuleId.staff_tablet), isFalse);
      expect(ModuleRuntimeMapping.hasBuilderBlock(ModuleId.kitchen_tablet), isFalse);
    });

    test('Routes are properly resolved', () {
      final allRoutes = ModuleRouteResolver.getAllModuleRoutes();
      expect(allRoutes['/pos'], equals(ModuleId.staff_tablet));
      expect(allRoutes['/kitchen'], equals(ModuleId.kitchen_tablet));
    });

    test('Routes are valid', () {
      expect(ModuleRouteResolver.isValidRoute('/pos'), isTrue);
      expect(ModuleRouteResolver.isValidRoute('/kitchen'), isTrue);
    });

    test('Routes are not phantom routes', () {
      expect(ModuleRouteResolver.isPhantomRoute('/pos'), isFalse);
      expect(ModuleRouteResolver.isPhantomRoute('/kitchen'), isFalse);
    });
  });
}
