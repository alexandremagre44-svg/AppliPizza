// test/pos_module_test.dart
// Basic tests for POS module Phase 1

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizza_delizza/src/screens/admin/pos/pos_screen.dart';
import 'package:pizza_delizza/src/screens/admin/pos/pos_shell_scaffold.dart';
import 'package:pizza_delizza/src/screens/admin/pos/pos_routes.dart';
import 'package:pizza_delizza/src/core/constants.dart';

void main() {
  group('POS Module Phase 1 Tests', () {
    
    test('PosRoutes.main references AppRoutes.pos correctly', () {
      // Verify consistency between PosRoutes.main and AppRoutes.pos
      expect(PosRoutes.main, equals(AppRoutes.pos));
      // Verify the expected value
      expect(PosRoutes.main, equals('/pos'));
    });

    testWidgets('PosScreen builds without error', (WidgetTester tester) async {
      // Build PosScreen widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const PosScreen(),
          ),
        ),
      );

      // Verify the screen renders
      expect(find.byType(PosScreen), findsOneWidget);
      
      // Verify the scaffold is present
      expect(find.byType(PosShellScaffold), findsOneWidget);
      
      // Verify the title is displayed
      expect(find.text('Caisse'), findsOneWidget);
    });

    testWidgets('PosScreen displays 3 placeholder zones on wide screen', (WidgetTester tester) async {
      // Set screen size to wide (tablet/desktop)
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const PosScreen(),
          ),
        ),
      );

      // Wait for the layout to build
      await tester.pumpAndSettle();

      // Verify placeholder zones are present
      expect(find.text('Produits'), findsOneWidget);
      expect(find.text('Panier'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
      
      // Verify placeholder text
      expect(find.textContaining('À implémenter en Phase 2'), findsWidgets);

      // Reset to default size
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('PosScreen displays placeholder zones on mobile', (WidgetTester tester) async {
      // Set screen size to mobile
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const PosScreen(),
          ),
        ),
      );

      // Wait for the layout to build
      await tester.pumpAndSettle();

      // Verify placeholder zones are present
      expect(find.text('Produits'), findsOneWidget);
      expect(find.text('Panier'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);

      // Reset to default size
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('PosShellScaffold builds with custom title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PosShellScaffold(
            title: 'Test Title',
            child: const Text('Test Content'),
          ),
        ),
      );

      // Verify custom title is displayed
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('PosShellScaffold builds with default title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PosShellScaffold(
            child: const Text('Test Content'),
          ),
        ),
      );

      // Verify default title is displayed
      expect(find.text('Caisse'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });
  });
}
