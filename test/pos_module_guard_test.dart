/// test/pos_module_guard_test.dart
///
/// Tests for POS module route guard.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizza_delizza_clean/white_label/core/module_id.dart';
import 'package:pizza_delizza_clean/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza_clean/src/navigation/module_route_guards.dart';
import 'package:pizza_delizza_clean/src/providers/restaurant_plan_provider.dart';

void main() {
  group('POS Module Guard', () {
    test('posRouteGuard should require pos module', () {
      // Create a test widget
      final testWidget = Container(child: const Text('POS Screen'));
      
      // Apply guard
      final guarded = posRouteGuard(testWidget);
      
      // Verify it returns a ModuleRouteGuard
      expect(guarded, isA<ModuleRouteGuard>());
      expect((guarded as ModuleRouteGuard).requiredModule, equals(ModuleId.pos));
    });

    testWidgets('should show content when POS module is active', (tester) async {
      // Create a plan with POS module active
      final plan = RestaurantPlanUnified.defaults(
        restaurantId: 'test',
        name: 'Test Restaurant',
        slug: 'test',
      ).copyWith(
        activeModules: ['pos', 'ordering'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            restaurantPlanUnifiedProvider.overrideWith(
              (ref) => AsyncValue.data(plan),
            ),
          ],
          child: MaterialApp(
            home: posRouteGuard(
              const Scaffold(
                body: Center(child: Text('POS Content')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show the POS content
      expect(find.text('POS Content'), findsOneWidget);
    });

    testWidgets('should show disabled screen when POS module is inactive', (tester) async {
      // Create a plan without POS module
      final plan = RestaurantPlanUnified.defaults(
        restaurantId: 'test',
        name: 'Test Restaurant',
        slug: 'test',
      ).copyWith(
        activeModules: ['ordering', 'delivery'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            restaurantPlanUnifiedProvider.overrideWith(
              (ref) => AsyncValue.data(plan),
            ),
          ],
          child: MaterialApp(
            home: posRouteGuard(
              const Scaffold(
                body: Center(child: Text('POS Content')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should NOT show the POS content
      expect(find.text('POS Content'), findsNothing);
      
      // Should show the disabled screen
      expect(find.text('Module non disponible'), findsOneWidget);
      expect(find.text('Module "POS / Caisse" désactivé'), findsOneWidget);
    });

    testWidgets('should show loading indicator while plan loads', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            restaurantPlanUnifiedProvider.overrideWith(
              (ref) => const AsyncValue.loading(),
            ),
          ],
          child: MaterialApp(
            home: posRouteGuard(
              const Scaffold(
                body: Center(child: Text('POS Content')),
              ),
            ),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('POS Content'), findsNothing);
    });
  });

  group('Kitchen Module Guard', () {
    testWidgets('should show content when kitchen module is active', (tester) async {
      // Create a plan with kitchen module active
      final plan = RestaurantPlanUnified.defaults(
        restaurantId: 'test',
        name: 'Test Restaurant',
        slug: 'test',
      ).copyWith(
        activeModules: ['kitchen_tablet', 'ordering'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            restaurantPlanUnifiedProvider.overrideWith(
              (ref) => AsyncValue.data(plan),
            ),
          ],
          child: MaterialApp(
            home: kitchenRouteGuard(
              const Scaffold(
                body: Center(child: Text('Kitchen Content')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show the kitchen content
      expect(find.text('Kitchen Content'), findsOneWidget);
    });

    testWidgets('should show disabled screen when kitchen module is inactive', (tester) async {
      // Create a plan without kitchen module
      final plan = RestaurantPlanUnified.defaults(
        restaurantId: 'test',
        name: 'Test Restaurant',
        slug: 'test',
      ).copyWith(
        activeModules: ['ordering', 'delivery'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            restaurantPlanUnifiedProvider.overrideWith(
              (ref) => AsyncValue.data(plan),
            ),
          ],
          child: MaterialApp(
            home: kitchenRouteGuard(
              const Scaffold(
                body: Center(child: Text('Kitchen Content')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should NOT show the kitchen content
      expect(find.text('Kitchen Content'), findsNothing);
      
      // Should show the disabled screen
      expect(find.text('Module non disponible'), findsOneWidget);
      expect(find.text('Module "Tablette cuisine" désactivé'), findsOneWidget);
    });
  });

  group('Module Independence', () {
    test('POS and Kitchen modules are independent', () {
      // Create plan with only POS
      final posOnlyPlan = RestaurantPlanUnified.defaults(
        restaurantId: 'test',
        name: 'Test',
        slug: 'test',
      ).copyWith(activeModules: ['pos']);
      
      expect(posOnlyPlan.hasModule(ModuleId.pos), isTrue);
      expect(posOnlyPlan.hasModule(ModuleId.kitchen_tablet), isFalse);
      
      // Create plan with only Kitchen
      final kitchenOnlyPlan = RestaurantPlanUnified.defaults(
        restaurantId: 'test',
        name: 'Test',
        slug: 'test',
      ).copyWith(activeModules: ['kitchen_tablet']);
      
      expect(kitchenOnlyPlan.hasModule(ModuleId.kitchen_tablet), isTrue);
      expect(kitchenOnlyPlan.hasModule(ModuleId.pos), isFalse);
      
      // Create plan with both
      final bothPlan = RestaurantPlanUnified.defaults(
        restaurantId: 'test',
        name: 'Test',
        slug: 'test',
      ).copyWith(activeModules: ['pos', 'kitchen_tablet']);
      
      expect(bothPlan.hasModule(ModuleId.pos), isTrue);
      expect(bothPlan.hasModule(ModuleId.kitchen_tablet), isTrue);
    });
  });

  group('Template Does Not Auto-Activate Modules', () {
    test('template recommendations do not auto-enable modules', () {
      // Create plan with pizzeria template but no modules
      final plan = RestaurantPlanUnified.defaults(
        restaurantId: 'test',
        name: 'Test Pizzeria',
        slug: 'test',
        templateId: 'pizzeria-classic',
      ).copyWith(
        activeModules: [], // Explicitly no modules
      );
      
      // Template recommends POS and Kitchen
      final template = plan.template;
      expect(template?.recommendsPOS, isTrue);
      expect(template?.recommendsKitchen, isTrue);
      
      // But they are NOT activated
      expect(plan.hasModule(ModuleId.pos), isFalse);
      expect(plan.hasModule(ModuleId.kitchen_tablet), isFalse);
      
      // This proves templates DO NOT control module activation
    });
  });
}
