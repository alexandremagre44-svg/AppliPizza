// lib/builder/runtime/builder_block_runtime_registry.dart
// Central registry for block rendering (preview + runtime)
// White-label pro architecture - Module-aware
//
// Purpose: Centralize the mapping between BlockType and block widgets
// Unified renderer that works in both preview and runtime modes
// Module-aware: automatically hides blocks for disabled modules

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../blocks/hero_block_runtime.dart';
import '../blocks/hero_block_preview.dart';
import '../blocks/text_block_runtime.dart';
import '../blocks/text_block_preview.dart';
import '../blocks/banner_block_runtime.dart';
import '../blocks/banner_block_preview.dart';
import '../blocks/product_list_block_runtime.dart';
import '../blocks/product_list_block_preview.dart';
import '../blocks/info_block_runtime.dart';
import '../blocks/info_block_preview.dart';
import '../blocks/spacer_block_runtime.dart';
import '../blocks/spacer_block_preview.dart';
import '../blocks/image_block_runtime.dart';
import '../blocks/image_block_preview.dart';
import '../blocks/button_block_runtime.dart';
import '../blocks/button_block_preview.dart';
import '../blocks/category_list_block_runtime.dart';
import '../blocks/category_list_block_preview.dart';
import '../blocks/html_block_runtime.dart';
import '../blocks/html_block_preview.dart';
import '../blocks/system_block_runtime.dart';
import '../blocks/system_block_preview.dart';
import '../../white_label/restaurant/restaurant_feature_flags.dart';
import '../../white_label/runtime/module_helpers.dart';
import '../../white_label/core/module_id.dart';

/// Typedef for a unified block renderer function.
/// 
/// Takes a [BuilderBlock], [BuildContext], and [isPreview] flag.
/// Returns a [Widget] that renders the block in preview or runtime mode.
typedef BlockRenderer = Widget Function(
  BuildContext context,
  BuilderBlock block,
  bool isPreview, {
  double? maxContentWidth,
});

/// Legacy typedef for backward compatibility.
@Deprecated('Use BlockRenderer instead')
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
  
  /// Map from [BlockType] to a unified block renderer.
  /// 
  /// Each entry maps a block type to a function that creates the corresponding
  /// widget in either preview or runtime mode. The renderer receives:
  /// - context: BuildContext
  /// - block: BuilderBlock data
  /// - isPreview: true for editor preview, false for runtime
  /// - maxContentWidth: optional width constraint
  static final Map<BlockType, BlockRenderer> _renderers = {
    BlockType.hero: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview 
        ? HeroBlockPreview(block: block)
        : HeroBlockRuntime(block: block);
    },
    
    BlockType.text: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview
        ? TextBlockPreview(block: block)
        : TextBlockRuntime(block: block);
    },
    
    BlockType.banner: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview
        ? BannerBlockPreview(block: block)
        : BannerBlockRuntime(block: block);
    },
    
    BlockType.productList: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview
        ? ProductListBlockPreview(block: block)
        : ProductListBlockRuntime(block: block);
    },
    
    BlockType.info: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview
        ? InfoBlockPreview(block: block)
        : InfoBlockRuntime(block: block);
    },
    
    BlockType.spacer: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview
        ? SpacerBlockPreview(block: block)
        : SpacerBlockRuntime(block: block);
    },
    
    BlockType.image: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview
        ? ImageBlockPreview(block: block)
        : ImageBlockRuntime(block: block);
    },
    
    BlockType.button: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview
        ? ButtonBlockPreview(block: block)
        : ButtonBlockRuntime(block: block);
    },
    
    BlockType.categoryList: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview
        ? CategoryListBlockPreview(block: block)
        : CategoryListBlockRuntime(block: block);
    },
    
    BlockType.html: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview
        ? HtmlBlockPreview(block: block)
        : HtmlBlockRuntime(block: block);
    },
    
    BlockType.system: (context, block, isPreview, {double? maxContentWidth}) {
      return isPreview
        ? SystemBlockPreview(block: block)
        : SystemBlockRuntime(
            block: block,
            maxContentWidth: maxContentWidth,
          );
    },
  };
  
  /// Legacy builders map for backward compatibility.
  @Deprecated('Use _renderers instead')
  static final Map<BlockType, BlockRuntimeBuilder> _builders = {};{}
  
  /// Get the renderer function for a specific [BlockType].
  /// 
  /// Returns `null` if no renderer is registered for the given type.
  /// Use [render] for direct rendering with fallback handling.
  static BlockRenderer? getRenderer(BlockType type) {
    return _renderers[type];
  }
  
  /// Legacy method for backward compatibility.
  @Deprecated('Use getRenderer instead')
  static BlockRuntimeBuilder? getBuilder(BlockType type) {
    final renderer = _renderers[type];
    if (renderer == null) return null;
    return (block, context, {double? maxContentWidth}) {
      return renderer(context, block, false, maxContentWidth: maxContentWidth);
    };
  }
  
  /// Check if a renderer is registered for the given [BlockType].
  static bool hasRenderer(BlockType type) {
    return _renderers.containsKey(type);
  }
  
  /// Legacy method for backward compatibility.
  @Deprecated('Use hasRenderer instead')
  static bool hasBuilder(BlockType type) {
    return hasRenderer(type);
  }
  
  /// Get all registered block types.
  static Set<BlockType> get registeredTypes => _renderers.keys.toSet();
  
  /// Render a [BuilderBlock] to a widget.
  /// 
  /// Uses the registered renderer for the block's type. If no renderer is found,
  /// returns a fallback widget showing an "unknown block type" message.
  /// 
  /// Module-aware: Automatically hides blocks that require disabled modules.
  /// 
  /// [block] - The block to render
  /// [context] - The build context
  /// [isPreview] - True for editor preview, false for runtime (default: false)
  /// [maxContentWidth] - Optional max width constraint for responsive layouts
  /// [featureFlags] - Optional feature flags for legacy module visibility check
  static Widget render(
    BuilderBlock block,
    BuildContext context, {
    bool isPreview = false,
    double? maxContentWidth,
    RestaurantFeatureFlags? featureFlags,
  }) {
    // Module guard: Check if block requires a module
    if (!isPreview && block.requiredModule != null) {
      // First try the new isModuleEnabled helper (preferred)
      if (context is StatefulElement || context is StatelessElement) {
        try {
          // Try to get WidgetRef from context (only works if Consumer/ConsumerWidget)
          final container = ProviderScope.containerOf(context, listen: false);
          if (container != null) {
            // Use the new module helper
            final moduleIdStr = block.requiredModule!;
            final moduleId = _parseModuleId(moduleIdStr);
            if (moduleId != null) {
              // We need a WidgetRef, but we have BuildContext
              // For now, fall back to featureFlags check
              // TODO: Refactor to accept WidgetRef parameter
            }
          }
        } catch (_) {
          // Fall through to featureFlags check
        }
      }
      
      // Fallback to legacy featureFlags check
      if (featureFlags != null) {
        if (!featureFlags.has(block.requiredModule!)) {
          return const SizedBox.shrink();
        }
      }
    }
    
    final renderer = _renderers[block.type];
    
    if (renderer != null) {
      return renderer(
        context,
        block,
        isPreview,
        maxContentWidth: maxContentWidth,
      );
    }
    
    // Fallback for unknown block types
    return _buildUnknownBlockFallback(block, context, isPreview);
  }
  
  /// Parse module ID string to ModuleId enum.
  /// Returns null if the string doesn't match any ModuleId.
  static ModuleId? _parseModuleId(String moduleIdStr) {
    try {
      return ModuleId.values.firstWhere(
        (id) => id.code == moduleIdStr,
      );
    } catch (_) {
      return null;
    }
  }
  
  /// Render a list of blocks to widgets.
  /// 
  /// Convenience method for rendering multiple blocks at once.
  /// Each block is rendered using [render].
  /// 
  /// [blocks] - List of blocks to render
  /// [context] - Build context
  /// [isPreview] - True for editor preview, false for runtime (default: false)
  /// [maxContentWidth] - Optional max width constraint
  /// [featureFlags] - Optional feature flags for module visibility check
  static List<Widget> renderAll(
    List<BuilderBlock> blocks,
    BuildContext context, {
    bool isPreview = false,
    double? maxContentWidth,
    RestaurantFeatureFlags? featureFlags,
  }) {
    return blocks.map((block) => render(
      block,
      context,
      isPreview: isPreview,
      maxContentWidth: maxContentWidth,
      featureFlags: featureFlags,
    )).toList();
  }
  
  /// Build fallback widget for unknown block types.
  static Widget _buildUnknownBlockFallback(
    BuilderBlock block,
    BuildContext context,
    bool isPreview,
  ) {
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
                if (isPreview) ...[
                  const SizedBox(height: 4),
                  Text(
                    '(Preview Mode)',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.amber.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Register a custom renderer for a block type.
  /// 
  /// Use this to override default renderers or add new block types at runtime.
  /// This is useful for white-label customization or testing.
  /// 
  /// Note: This modifies the global registry. In production, prefer
  /// defining all renderers in [_renderers] at compile time.
  static void registerRenderer(BlockType type, BlockRenderer renderer) {
    _renderers[type] = renderer;
  }
  
  /// Legacy method for backward compatibility.
  @Deprecated('Use registerRenderer instead')
  static void registerBuilder(BlockType type, BlockRuntimeBuilder builder) {
    _renderers[type] = (context, block, isPreview, {double? maxContentWidth}) {
      return builder(block, context, maxContentWidth: maxContentWidth);
    };
  }
  
  /// Unregister a renderer for a block type.
  /// 
  /// Returns `true` if a renderer was removed, `false` if none was registered.
  static bool unregisterRenderer(BlockType type) {
    return _renderers.remove(type) != null;
  }
  
  /// Legacy method for backward compatibility.
  @Deprecated('Use unregisterRenderer instead')
  static bool unregisterBuilder(BlockType type) {
    return unregisterRenderer(type);
  }
}
