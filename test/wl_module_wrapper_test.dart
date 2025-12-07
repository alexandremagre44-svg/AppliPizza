// test/wl_module_wrapper_test.dart
// Test suite for WL Module Wrapper and Registry

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/runtime/wl/wl_module_wrapper.dart';
import 'package:pizza_delizza/builder/runtime/module_runtime_registry.dart';

void main() {
  group('WLModuleWrapper', () {
    testWidgets('should wrap child with constraints', (WidgetTester tester) async {
      // Arrange
      const testChild = Text('Test Module');
      const wrapper = WLModuleWrapper(child: testChild);

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: wrapper,
          ),
        ),
      );

      // Assert
      expect(find.text('Test Module'), findsOneWidget);
      
      // Verify ConstrainedBox exists
      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      expect(constrainedBox.constraints.maxWidth, equals(600.0));
    });

    testWidgets('should allow custom maxWidth', (WidgetTester tester) async {
      // Arrange
      const testChild = Text('Test Module');
      const wrapper = WLModuleWrapper(
        child: testChild,
        maxWidth: 800,
      );

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: wrapper,
          ),
        ),
      );

      // Assert
      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      expect(constrainedBox.constraints.maxWidth, equals(800.0));
    });
  });

  group('ModuleRuntimeRegistry', () {
    setUp(() {
      // Clear registry before each test
      ModuleRuntimeRegistry.clear();
    });

    test('should register and retrieve admin widgets', () {
      // Arrange
      Widget testBuilder(BuildContext ctx) => const Text('Admin Widget');
      
      // Act
      ModuleRuntimeRegistry.registerAdmin('test_module', testBuilder);
      
      // Assert
      expect(ModuleRuntimeRegistry.containsAdmin('test_module'), isTrue);
    });

    test('should register and retrieve client widgets', () {
      // Arrange
      Widget testBuilder(BuildContext ctx) => const Text('Client Widget');
      
      // Act
      ModuleRuntimeRegistry.registerClient('test_module', testBuilder);
      
      // Assert
      expect(ModuleRuntimeRegistry.containsClient('test_module'), isTrue);
    });

    testWidgets('buildAdmin should wrap widget with WLModuleWrapper', 
        (WidgetTester tester) async {
      // Arrange
      ModuleRuntimeRegistry.registerAdmin(
        'test_module',
        (ctx) => const Text('Admin Widget'),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final widget = ModuleRuntimeRegistry.buildAdmin(
                  'test_module',
                  context,
                );
                return widget ?? const SizedBox();
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Admin Widget'), findsOneWidget);
      expect(find.byType(WLModuleWrapper), findsOneWidget);
    });

    testWidgets('buildClient should wrap widget with WLModuleWrapper', 
        (WidgetTester tester) async {
      // Arrange
      ModuleRuntimeRegistry.registerClient(
        'test_module',
        (ctx) => const Text('Client Widget'),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final widget = ModuleRuntimeRegistry.buildClient(
                  'test_module',
                  context,
                );
                return widget ?? const SizedBox();
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Client Widget'), findsOneWidget);
      expect(find.byType(WLModuleWrapper), findsOneWidget);
    });

    test('should return null for unregistered modules', () {
      // Act & Assert - using a build context
      expect(ModuleRuntimeRegistry.containsAdmin('unknown_module'), isFalse);
      expect(ModuleRuntimeRegistry.containsClient('unknown_module'), isFalse);
    });

    test('should unregister modules', () {
      // Arrange
      ModuleRuntimeRegistry.registerAdmin(
        'test_module',
        (ctx) => const Text('Test'),
      );
      
      // Act
      final result = ModuleRuntimeRegistry.unregister('test_module');
      
      // Assert
      expect(result, isTrue);
      expect(ModuleRuntimeRegistry.containsAdmin('test_module'), isFalse);
    });

    test('should get all registered modules', () {
      // Arrange
      ModuleRuntimeRegistry.registerAdmin('module1', (ctx) => const Text('1'));
      ModuleRuntimeRegistry.registerClient('module2', (ctx) => const Text('2'));
      
      // Act
      final modules = ModuleRuntimeRegistry.getRegisteredModules();
      
      // Assert
      expect(modules, contains('module1'));
      expect(modules, contains('module2'));
    });
  });
}
