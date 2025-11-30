// lib/builder/runtime/builder_block_runtime_registry.dart
// Central registry for runtime block rendering
// White-label pro architecture - Phase 5 compliant
//
// Purpose: Centralize the mapping between BlockType and runtime widgets
// Adding a new block type only requires:
//   1) Creating a runtime widget in lib/builder/blocks/
//   2) Importing it here and adding to _builders map

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../blocks/hero_block_runtime.dart';
import '../blocks/text_block_runtime.dart';
import '../blocks/banner_block_runtime.dart';
import '../blocks/product_list_block_runtime.dart';
import '../blocks/info_block_runtime.dart';
import '../blocks/spacer_block_runtime.dart';
import '../blocks/image_block_runtime.dart';
import '../blocks/button_block_runtime.dart';
import '../blocks/category_list_block_runtime.dart';
import '../blocks/html_block_runtime.dart';
import '../blocks/system_block_runtime.dart';

/// Typedef for a block runtime builder function.
/// 
/// Takes a [BuilderBlock] and [BuildContext], optionally constrained by [maxContentWidth].
/// Returns a [Widget] that renders the block at runtime.
typedef BlockRuntimeBuilder = Widget Function(
  BuilderBlock block,
  BuildContext context, {
  double? maxContentWidth,
});

/// Central registry for runtime block rendering.
/// 
/// This registry provides a single source of truth for mapping [BlockType]
/// to concrete runtime widget builders. It enables:
/// - White-label architecture: easily swap block implementations
/// - Extensibility: add new block types with minimal code changes
/// - Testability: mock or override builders for testing
/// 
/// Usage:
/// ```dart
/// // Get a builder for a specific block type
/// final builder = BuilderBlockRuntimeRegistry.getBuilder(BlockType.hero);
/// if (builder != null) {
///   final widget = builder(block, context);
/// }
/// 
/// // Or render directly (with fallback for unknown types)
/// final widget = BuilderBlockRuntimeRegistry.render(block, context);
/// ```
class BuilderBlockRuntimeRegistry {
  // Private constructor - this class is not meant to be instantiated
  BuilderBlockRuntimeRegistry._();
  
  /// Map from [BlockType] to a runtime widget builder.
  /// 
  /// Each entry maps a block type to a function that creates the corresponding
  /// runtime widget. The builder receives the block data and context, and
  /// optionally a max content width for responsive layouts.
  static final Map<BlockType, BlockRuntimeBuilder> _builders = {
    BlockType.hero: (block, context, {double? maxContentWidth}) {
      return HeroBlockRuntime(block: block);
    },
    
    BlockType.text: (block, context, {double? maxContentWidth}) {
      return TextBlockRuntime(block: block);
    },
    
    BlockType.banner: (block, context, {double? maxContentWidth}) {
      return BannerBlockRuntime(block: block);
    },
    
    BlockType.productList: (block, context, {double? maxContentWidth}) {
      return ProductListBlockRuntime(block: block);
    },
    
    BlockType.info: (block, context, {double? maxContentWidth}) {
      return InfoBlockRuntime(block: block);
    },
    
    BlockType.spacer: (block, context, {double? maxContentWidth}) {
      return SpacerBlockRuntime(block: block);
    },
    
    BlockType.image: (block, context, {double? maxContentWidth}) {
      return ImageBlockRuntime(block: block);
    },
    
    BlockType.button: (block, context, {double? maxContentWidth}) {
      return ButtonBlockRuntime(block: block);
    },
    
    BlockType.categoryList: (block, context, {double? maxContentWidth}) {
      return CategoryListBlockRuntime(block: block);
    },
    
    BlockType.html: (block, context, {double? maxContentWidth}) {
      return HtmlBlockRuntime(block: block);
    },
    
    BlockType.system: (block, context, {double? maxContentWidth}) {
      return SystemBlockRuntime(
        block: block,
        maxContentWidth: maxContentWidth,
      );
    },
  };
  
  /// Get the builder function for a specific [BlockType].
  /// 
  /// Returns `null` if no builder is registered for the given type.
  /// Use [render] for direct rendering with fallback handling.
  static BlockRuntimeBuilder? getBuilder(BlockType type) {
    return _builders[type];
  }
  
  /// Check if a builder is registered for the given [BlockType].
  static bool hasBuilder(BlockType type) {
    return _builders.containsKey(type);
  }
  
  /// Get all registered block types.
  static Set<BlockType> get registeredTypes => _builders.keys.toSet();
  
  /// Render a [BuilderBlock] to a widget.
  /// 
  /// Uses the registered builder for the block's type. If no builder is found,
  /// returns a fallback widget showing an "unknown block type" message.
  /// 
  /// [block] - The block to render
  /// [context] - The build context
  /// [maxContentWidth] - Optional max width constraint for responsive layouts
  static Widget render(
    BuilderBlock block,
    BuildContext context, {
    double? maxContentWidth,
  }) {
    final builder = _builders[block.type];
    
    if (builder != null) {
      return builder(block, context, maxContentWidth: maxContentWidth);
    }
    
    // Fallback for unknown block types
    return _buildUnknownBlockFallback(block, context);
  }
  
  /// Render a list of blocks to widgets.
  /// 
  /// Convenience method for rendering multiple blocks at once.
  /// Each block is rendered using [render].
  static List<Widget> renderAll(
    List<BuilderBlock> blocks,
    BuildContext context, {
    double? maxContentWidth,
  }) {
    return blocks.map((block) => render(
      block,
      context,
      maxContentWidth: maxContentWidth,
    )).toList();
  }
  
  /// Build fallback widget for unknown block types.
  static Widget _buildUnknownBlockFallback(BuilderBlock block, BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: Colors.amber.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Unknown block type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Type: ${block.type.value}',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Register a custom builder for a block type.
  /// 
  /// Use this to override default builders or add new block types at runtime.
  /// This is useful for white-label customization or testing.
  /// 
  /// Note: This modifies the global registry. In production, prefer
  /// defining all builders in [_builders] at compile time.
  static void registerBuilder(BlockType type, BlockRuntimeBuilder builder) {
    _builders[type] = builder;
  }
  
  /// Unregister a builder for a block type.
  /// 
  /// Returns `true` if a builder was removed, `false` if none was registered.
  static bool unregisterBuilder(BlockType type) {
    return _builders.remove(type) != null;
  }
}
