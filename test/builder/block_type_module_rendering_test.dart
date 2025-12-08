// test/builder/block_type_module_rendering_test.dart
// Test suite to verify BlockType.module rendering in runtime
//
// This test validates that BlockType.module blocks are properly rendered
// on the client side using the ModuleRuntimeRegistry.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/models/builder_block.dart';
import 'package:pizza_delizza/builder/models/builder_enums.dart';
import 'package:pizza_delizza/builder/runtime/builder_block_runtime_registry.dart';
import 'package:pizza_delizza/builder/runtime/module_runtime_registry.dart';

void main() {
  group('BlockType.module Runtime Rendering', () {
    setUp(() {
      // Clear registry before each test
      ModuleRuntimeRegistry.clear();
    });

    testWidgets('should render BlockType.module with registered client widget', (tester) async {
      // Arrange: Register a test module
      const moduleId = 'test_wl_module';
      const testKey = Key('client_widget');
      
      ModuleRuntimeRegistry.registerClient(
        moduleId,
        (ctx) => const Text('Client Widget', key: testKey),
      );

      // Create a BlockType.module block
      final block = BuilderBlock(
        id: 'block_1',
        type: BlockType.module,
        order: 0,
        config: {'moduleId': moduleId},
      );

      // Act: Render the block in runtime mode (isPreview: false)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return BuilderBlockRuntimeRegistry.render(
                  block,
                  context,
                  isPreview: false, // Runtime mode = client side
                );
              },
            ),
          ),
        ),
      );

      // Assert: Client widget should be rendered
      expect(find.byKey(testKey), findsOneWidget);
      expect(find.text('Client Widget'), findsOneWidget);
    });

    testWidgets('should fallback to admin widget if client widget not available', (tester) async {
      // Arrange: Register only admin widget (no client widget)
      const moduleId = 'test_wl_module_admin_only';
      const testKey = Key('admin_widget');
      
      ModuleRuntimeRegistry.registerAdmin(
        moduleId,
        (ctx) => const Text('Admin Widget', key: testKey),
      );

      // Create a BlockType.module block
      final block = BuilderBlock(
        id: 'block_2',
        type: BlockType.module,
        order: 0,
        config: {'moduleId': moduleId},
      );

      // Act: Render in runtime mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return BuilderBlockRuntimeRegistry.render(
                  block,
                  context,
                  isPreview: false,
                );
              },
            ),
          ),
        ),
      );

      // Assert: Admin widget should be used as fallback
      expect(find.byKey(testKey), findsOneWidget);
      expect(find.text('Admin Widget'), findsOneWidget);
    });

    testWidgets('should show UnknownModuleWidget if module not registered', (tester) async {
      // Arrange: Create block with unregistered module
      const moduleId = 'unregistered_module';
      
      final block = BuilderBlock(
        id: 'block_3',
        type: BlockType.module,
        order: 0,
        config: {'moduleId': moduleId},
      );

      // Act: Render in runtime mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return BuilderBlockRuntimeRegistry.render(
                  block,
                  context,
                  isPreview: false,
                );
              },
            ),
          ),
        ),
      );

      // Assert: UnknownModuleWidget should be shown
      expect(find.textContaining(moduleId), findsOneWidget);
      expect(find.textContaining('non disponible'), findsOneWidget);
    });

    testWidgets('should render admin widget in preview mode', (tester) async {
      // Arrange: Register both admin and client widgets
      const moduleId = 'test_dual_module';
      const adminKey = Key('admin_widget');
      const clientKey = Key('client_widget');
      
      ModuleRuntimeRegistry.registerAdmin(
        moduleId,
        (ctx) => const Text('Admin Widget', key: adminKey),
      );
      ModuleRuntimeRegistry.registerClient(
        moduleId,
        (ctx) => const Text('Client Widget', key: clientKey),
      );

      final block = BuilderBlock(
        id: 'block_4',
        type: BlockType.module,
        order: 0,
        config: {'moduleId': moduleId},
      );

      // Act: Render in preview mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return BuilderBlockRuntimeRegistry.render(
                  block,
                  context,
                  isPreview: true, // Preview mode = admin context
                );
              },
            ),
          ),
        ),
      );

      // Assert: Admin widget should be rendered in preview
      expect(find.byKey(adminKey), findsOneWidget);
      expect(find.byKey(clientKey), findsNothing);
    });

    testWidgets('should handle missing moduleId gracefully', (tester) async {
      // Arrange: Create block without moduleId in config
      final block = BuilderBlock(
        id: 'block_5',
        type: BlockType.module,
        order: 0,
        config: {}, // No moduleId
      );

      // Act: Render in runtime mode
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return BuilderBlockRuntimeRegistry.render(
                  block,
                  context,
                  isPreview: false,
                );
              },
            ),
          ),
        ),
      );

      // Assert: Should not crash, should render something (empty or fallback)
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('Integration: BlockType.module in BuilderRuntimeRenderer', () {
    testWidgets('should render multiple BlockType.module blocks in a page', (tester) async {
      // Arrange: Register two modules
      ModuleRuntimeRegistry.registerClient(
        'module_a',
        (ctx) => const Text('Module A'),
      );
      ModuleRuntimeRegistry.registerClient(
        'module_b',
        (ctx) => const Text('Module B'),
      );

      // Create blocks
      final blocks = [
        BuilderBlock(
          id: 'block_a',
          type: BlockType.module,
          order: 0,
          config: {'moduleId': 'module_a'},
        ),
        BuilderBlock(
          id: 'block_b',
          type: BlockType.module,
          order: 1,
          config: {'moduleId': 'module_b'},
        ),
      ];

      // Act: Render all blocks
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: blocks.map((block) {
                  return Builder(
                    builder: (context) {
                      return BuilderBlockRuntimeRegistry.render(
                        block,
                        context,
                        isPreview: false,
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );

      // Assert: Both modules should be rendered
      expect(find.text('Module A'), findsOneWidget);
      expect(find.text('Module B'), findsOneWidget);
    });
  });
}
