// test/delivery_module_test.dart
// Integration test for Delivery Module widgets

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/runtime/modules/delivery_module_client_widget.dart';
import 'package:pizza_delizza/builder/runtime/modules/delivery_module_admin_widget.dart';

void main() {
  group('Delivery Module Integration Tests', () {
    testWidgets('DeliveryModuleClientWidget can be built without errors',
        (WidgetTester tester) async {
      // Test that the client widget can be wrapped in MaterialApp and Scaffold
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryModuleClientWidget(),
          ),
        ),
      );

      // Wait for all animations and rebuilds
      await tester.pumpAndSettle();

      // Verify key elements are present
      expect(find.text('Livraison'), findsOneWidget);
      expect(find.text('Votre adresse'), findsOneWidget);
      expect(find.text('Créneau de livraison'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
      expect(find.text('Valider la livraison'), findsOneWidget);
    });

    testWidgets('DeliveryModuleClientWidget form validation works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryModuleClientWidget(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the validation button
      final button = find.text('Valider la livraison');
      expect(button, findsOneWidget);

      // Button should be disabled initially (tester can't actually tap disabled buttons)
      final FilledButton filledButton = tester.widget(find.byType(FilledButton));
      expect(filledButton.onPressed, isNull);

      // Enter an address
      await tester.enterText(find.byType(TextField), '123 Rue de la Pizza');
      await tester.pumpAndSettle();

      // Select a time slot
      await tester.tap(find.text('12:00 - 12:30').first);
      await tester.pumpAndSettle();

      // Now button should be enabled
      final FilledButton enabledButton = tester.widget(find.byType(FilledButton));
      expect(enabledButton.onPressed, isNotNull);
    });

    testWidgets('DeliveryModuleClientWidget renders without layout errors',
        (WidgetTester tester) async {
      // Test in various container sizes to ensure proper constraints
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: const DeliveryModuleClientWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not throw any layout exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('DeliveryModuleAdminWidget can be built without errors',
        (WidgetTester tester) async {
      // Test that the admin widget can be wrapped in MaterialApp and Scaffold
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryModuleAdminWidget(),
          ),
        ),
      );

      // Wait for all animations and rebuilds
      await tester.pumpAndSettle();

      // Verify key elements are present
      expect(find.text('Livraison'), findsOneWidget);
      expect(
        find.text(
            'Gérez vos zones de livraison, vos frais, vos horaires et vos contraintes.'),
        findsOneWidget,
      );
      expect(find.text('Configurer'), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping), findsOneWidget);
    });

    testWidgets('DeliveryModuleAdminWidget renders without layout errors',
        (WidgetTester tester) async {
      // Test in various container sizes to ensure proper constraints
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 400,
              child: const DeliveryModuleAdminWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not throw any layout exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets('DeliveryModuleAdminWidget button shows snackbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DeliveryModuleAdminWidget(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the configure button
      await tester.tap(find.text('Configurer'));
      await tester.pumpAndSettle();

      // Verify snackbar appears
      expect(find.text('Configuration de livraison - À implémenter'), findsOneWidget);
    });
  });
}
