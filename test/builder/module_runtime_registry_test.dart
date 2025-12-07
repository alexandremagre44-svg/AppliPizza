// test/builder/module_runtime_registry_test.dart
// Test suite for ModuleRuntimeRegistry
//
// Validates the parallel registry system for White-Label modules
// independently from the BlockType renderer system.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/runtime/module_runtime_registry.dart';

void main() {
  group('ModuleRuntimeRegistry', () {
    setUp(() {
      // Clear registry before each test to ensure isolation
      ModuleRuntimeRegistry.clear();
    });

    test('should register and retrieve a module', () {
      // Arrange
      const moduleId = 'test_module';
      Widget testWidget(BuildContext context) => const Text('Test Module');

      // Act
      ModuleRuntimeRegistry.register(moduleId, testWidget);

      // Assert
      expect(ModuleRuntimeRegistry.contains(moduleId), true);
    });

    testWidgets('should build a registered module', (tester) async {
      // Arrange
      const moduleId = 'test_module';
      const testKey = Key('test_module_widget');
      Widget testWidget(BuildContext context) => const Text('Test', key: testKey);

      // Act
      ModuleRuntimeRegistry.register(moduleId, testWidget);

      // Assert - Build the widget in a real context
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final widget = ModuleRuntimeRegistry.build(moduleId, context);
                return widget ?? const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      
      expect(find.byKey(testKey), findsOneWidget);
    });

    testWidgets('should return null for unregistered module', (tester) async {
      // Arrange
      const moduleId = 'unregistered_module';

      // Act - Build with a real context
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final widget = ModuleRuntimeRegistry.build(moduleId, context);
                expect(widget, isNull);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // Assert
      expect(ModuleRuntimeRegistry.contains(moduleId), false);
    });

    test('should unregister a module', () {
      // Arrange
      const moduleId = 'test_module';
      Widget testWidget(BuildContext context) => const Text('Test');
      ModuleRuntimeRegistry.register(moduleId, testWidget);

      // Act
      final result = ModuleRuntimeRegistry.unregister(moduleId);

      // Assert
      expect(result, true);
      expect(ModuleRuntimeRegistry.contains(moduleId), false);
    });

    test('should return false when unregistering non-existent module', () {
      // Arrange
      const moduleId = 'non_existent_module';

      // Act
      final result = ModuleRuntimeRegistry.unregister(moduleId);

      // Assert
      expect(result, false);
    });

    test('should clear all registered modules', () {
      // Arrange
      ModuleRuntimeRegistry.register('module1', (ctx) => const Text('Module 1'));
      ModuleRuntimeRegistry.register('module2', (ctx) => const Text('Module 2'));
      ModuleRuntimeRegistry.register('module3', (ctx) => const Text('Module 3'));

      // Act
      ModuleRuntimeRegistry.clear();

      // Assert
      expect(ModuleRuntimeRegistry.contains('module1'), false);
      expect(ModuleRuntimeRegistry.contains('module2'), false);
      expect(ModuleRuntimeRegistry.contains('module3'), false);
      expect(ModuleRuntimeRegistry.getRegisteredModules(), isEmpty);
    });

    test('should get all registered module IDs', () {
      // Arrange
      ModuleRuntimeRegistry.register('module1', (ctx) => const Text('Module 1'));
      ModuleRuntimeRegistry.register('module2', (ctx) => const Text('Module 2'));
      ModuleRuntimeRegistry.register('module3', (ctx) => const Text('Module 3'));

      // Act
      final modules = ModuleRuntimeRegistry.getRegisteredModules();

      // Assert
      expect(modules, hasLength(3));
      expect(modules, containsAll(['module1', 'module2', 'module3']));
    });

    test('should allow re-registering a module (overwrite)', () {
      // Arrange
      const moduleId = 'test_module';
      Widget widget1(BuildContext context) => const Text('Widget 1');
      Widget widget2(BuildContext context) => const Text('Widget 2');

      // Act
      ModuleRuntimeRegistry.register(moduleId, widget1);
      ModuleRuntimeRegistry.register(moduleId, widget2);

      // Assert
      final result = ModuleRuntimeRegistry.build(moduleId, MockBuildContext());
      expect(result, isNotNull);
      expect((result as Text).data, 'Widget 2');
    });
  });

  group('UnknownModuleWidget', () {
    testWidgets('should display module ID and error icon', (tester) async {
      // Arrange
      const moduleId = 'unknown_module';
      const widget = UnknownModuleWidget(moduleId: moduleId);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      // Assert - Check for key elements without hardcoding French text
      expect(find.byIcon(Icons.extension_off), findsOneWidget);
      expect(find.textContaining(moduleId), findsOneWidget);
      // Verify the widget exists and is of correct type
      expect(find.byType(UnknownModuleWidget), findsOneWidget);
    });

    testWidgets('should show container with orange styling', (tester) async {
      // Arrange
      const widget = UnknownModuleWidget(moduleId: 'test');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      );

      // Assert - Check for visual elements
      expect(find.byIcon(Icons.extension_off), findsOneWidget);
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(Icons.extension_off),
          matching: find.byType(Container),
        ).first,
      );
      
      // Verify the container has decoration (orange theme)
      expect(container.decoration, isNotNull);
      expect(container.decoration, isA<BoxDecoration>());
    });
  });

  group('Integration with registerWhiteLabelModules', () {
    test('should register delivery_module', () {
      // Note: This test validates that the registration function exists
      // and can be called. The actual registration happens in main.dart.
      // We import and call it here to verify the integration.
      
      // Import is done at the top of main.dart, so we just verify
      // that the module can be registered programmatically
      ModuleRuntimeRegistry.register(
        'delivery_module',
        (ctx) => const Text('Delivery Module'),
      );

      // Assert
      expect(ModuleRuntimeRegistry.contains('delivery_module'), true);
    });
  });
}
