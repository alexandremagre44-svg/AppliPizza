// test/pos_kitchen_modules_test.dart
// Tests for POS and Kitchen modules routes setup

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pizza_delizza/src/screens/pos/pos_home_screen.dart';
import 'package:pizza_delizza/src/screens/kitchen/kitchen_screen.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';
import 'package:pizza_delizza/white_label/core/module_matrix.dart';
import 'package:pizza_delizza/white_label/core/module_runtime_mapping.dart';
import 'package:pizza_delizza/white_label/runtime/module_route_resolver.dart';

void main() {
  group('POS Module Tests', () {
    test('ModuleId.pos exists', () {
      expect(ModuleId.values.contains(ModuleId.pos), isTrue);
    });

    test('ModuleId.pos has correct code', () {
      expect(ModuleId.pos.code, equals('pos'));
    });

    test('ModuleId.pos has correct label', () {
      expect(ModuleId.pos.label, equals('POS'));
    });

    test('ModuleId.pos has correct category', () {
      expect(ModuleId.pos.category, equals(ModuleCategory.operations));
    });

    test('POS module exists in module matrix', () {
      final meta = moduleMatrix['pos'];
      expect(meta, isNotNull);
      expect(meta!.id, equals('pos'));
      expect(meta.label, equals('POS'));
      expect(meta.status, equals(ModuleStatus.implemented));
      expect(meta.hasPage, isTrue);
      expect(meta.hasBuilderBlock, isFalse);
      expect(meta.defaultRoute, equals('/pos'));
      expect(meta.tags, contains('staff'));
      expect(meta.tags, contains('operations'));
    });

    test('ModuleRuntimeMapping returns correct route for pos', () {
      final route = ModuleRuntimeMapping.getRuntimeRoute(ModuleId.pos);
      expect(route, equals('/pos'));
    });

    test('ModuleRuntimeMapping indicates pos has a page', () {
      final hasPage = ModuleRuntimeMapping.getRuntimePage(ModuleId.pos);
      expect(hasPage, isTrue);
    });

    test('ModuleRuntimeMapping indicates pos has no builder block', () {
      final hasBlock = ModuleRuntimeMapping.hasBuilderBlock(ModuleId.pos);
      expect(hasBlock, isFalse);
    });

    test('ModuleRuntimeMapping indicates pos is implemented', () {
      final isImplemented = ModuleRuntimeMapping.isImplemented(ModuleId.pos);
      expect(isImplemented, isTrue);
    });

    test('ModuleRouteResolver resolves /pos to ModuleId.pos', () {
      final moduleId = ModuleRouteResolver.resolve('/pos');
      expect(moduleId, equals(ModuleId.pos));
    });

    test('ModuleRouteResolver.resolveDetailed provides full info for /pos', () {
      final result = ModuleRouteResolver.resolveDetailed('/pos');
      expect(result.isResolved, isTrue);
      expect(result.moduleId, equals(ModuleId.pos));
      expect(result.route, equals('/pos'));
      expect(result.requiresModule, isTrue);
    });

    testWidgets('PosHomeScreen builds without error', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PosHomeScreen(),
        ),
      );

      expect(find.byType(PosHomeScreen), findsOneWidget);
      expect(find.text('Point de Vente (POS)'), findsOneWidget);
      expect(find.text('Module POS'), findsOneWidget);
      expect(find.byIcon(Icons.point_of_sale), findsOneWidget);
    });
  });

  group('Kitchen Module Tests', () {
    test('ModuleId.kitchen exists', () {
      expect(ModuleId.values.contains(ModuleId.kitchen), isTrue);
    });

    test('ModuleId.kitchen has correct code', () {
      expect(ModuleId.kitchen.code, equals('kitchen'));
    });

    test('ModuleId.kitchen has correct label', () {
      expect(ModuleId.kitchen.label, equals('Cuisine'));
    });

    test('ModuleId.kitchen has correct category', () {
      expect(ModuleId.kitchen.category, equals(ModuleCategory.operations));
    });

    test('Kitchen module exists in module matrix', () {
      final meta = moduleMatrix['kitchen'];
      expect(meta, isNotNull);
      expect(meta!.id, equals('kitchen'));
      expect(meta.label, equals('Cuisine'));
      expect(meta.status, equals(ModuleStatus.implemented));
      expect(meta.hasPage, isTrue);
      expect(meta.hasBuilderBlock, isFalse);
      expect(meta.defaultRoute, equals('/kitchen'));
      expect(meta.tags, contains('staff'));
      expect(meta.tags, contains('operations'));
    });

    test('ModuleRuntimeMapping returns correct route for kitchen', () {
      final route = ModuleRuntimeMapping.getRuntimeRoute(ModuleId.kitchen);
      expect(route, equals('/kitchen'));
    });

    test('ModuleRuntimeMapping indicates kitchen has a page', () {
      final hasPage = ModuleRuntimeMapping.getRuntimePage(ModuleId.kitchen);
      expect(hasPage, isTrue);
    });

    test('ModuleRuntimeMapping indicates kitchen has no builder block', () {
      final hasBlock = ModuleRuntimeMapping.hasBuilderBlock(ModuleId.kitchen);
      expect(hasBlock, isFalse);
    });

    test('ModuleRuntimeMapping indicates kitchen is implemented', () {
      final isImplemented = ModuleRuntimeMapping.isImplemented(ModuleId.kitchen);
      expect(isImplemented, isTrue);
    });

    test('ModuleRouteResolver resolves /kitchen to ModuleId.kitchen', () {
      final moduleId = ModuleRouteResolver.resolve('/kitchen');
      expect(moduleId, equals(ModuleId.kitchen));
    });

    test('ModuleRouteResolver.resolveDetailed provides full info for /kitchen', () {
      final result = ModuleRouteResolver.resolveDetailed('/kitchen');
      expect(result.isResolved, isTrue);
      expect(result.moduleId, equals(ModuleId.kitchen));
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
      expect(ModuleId.pos.category, equals(ModuleCategory.operations));
      expect(ModuleId.kitchen.category, equals(ModuleCategory.operations));
    });

    test('Both modules are implemented', () {
      expect(ModuleRuntimeMapping.isImplemented(ModuleId.pos), isTrue);
      expect(ModuleRuntimeMapping.isImplemented(ModuleId.kitchen), isTrue);
    });

    test('Both modules have pages but no builder blocks', () {
      expect(ModuleRuntimeMapping.getRuntimePage(ModuleId.pos), isTrue);
      expect(ModuleRuntimeMapping.getRuntimePage(ModuleId.kitchen), isTrue);
      expect(ModuleRuntimeMapping.hasBuilderBlock(ModuleId.pos), isFalse);
      expect(ModuleRuntimeMapping.hasBuilderBlock(ModuleId.kitchen), isFalse);
    });

    test('Routes are properly resolved', () {
      final allRoutes = ModuleRouteResolver.getAllModuleRoutes();
      expect(allRoutes['/pos'], equals(ModuleId.pos));
      expect(allRoutes['/kitchen'], equals(ModuleId.kitchen));
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
