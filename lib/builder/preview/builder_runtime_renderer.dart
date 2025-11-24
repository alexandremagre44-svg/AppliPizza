// lib/builder/preview/builder_runtime_renderer.dart
// Renders builder blocks using runtime widgets (with real providers and data)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Renders a list of BuilderBlocks using runtime widgets
/// These widgets can access providers, services, and real data
/// 
/// Features:
/// - Filters out disabled blocks (isActive == false)
/// - Sorts blocks by order property
/// - Handles unknown block types gracefully
/// - Optional ScrollView wrapper for proper scrolling
/// - Error handling for individual blocks
class BuilderRuntimeRenderer extends ConsumerWidget {
  final List<BuilderBlock> blocks;
  final Color? backgroundColor;
  
  /// Whether to wrap content in SingleChildScrollView
  /// Set to false if parent already provides scrolling
  final bool wrapInScrollView;

  const BuilderRuntimeRenderer({
    super.key,
    required this.blocks,
    this.backgroundColor,
    this.wrapInScrollView = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter enabled blocks only (isActive == true) and sort by order
    final activeBlocks = blocks
        .where((block) => block.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // Empty state when no blocks are configured
    if (activeBlocks.isEmpty) {
      return Container(
        color: backgroundColor,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'Aucun contenu configuré',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    // Build column of blocks with spacing
    final blocksColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Render each block with error handling and spacing
        for (int i = 0; i < activeBlocks.length; i++) ...[
          _buildBlockSafe(activeBlocks[i]),
          // Add spacing between blocks (except after last block)
          if (i < activeBlocks.length - 1)
            const SizedBox(height: 16),
        ],
      ],
    );

    // Wrap in ScrollView if requested
    return Container(
      color: backgroundColor,
      child: wrapInScrollView
          ? SingleChildScrollView(child: blocksColumn)
          : blocksColumn,
    );
  }

  /// Safely builds a block with error handling
  /// Returns SizedBox.shrink() if block fails to render
  Widget _buildBlockSafe(BuilderBlock block) {
    try {
      return _buildBlock(block);
    } catch (e, stackTrace) {
      // Log error in debug mode
      debugPrint('Error rendering block ${block.id} (${block.type.value}): $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Return empty widget instead of crashing the page
      return const SizedBox.shrink();
    }
  }

  /// Maps block type to corresponding runtime widget
  Widget _buildBlock(BuilderBlock block) {
    switch (block.type) {
      case BlockType.hero:
        return HeroBlockRuntime(block: block);
      
      case BlockType.text:
        return TextBlockRuntime(block: block);
      
      case BlockType.banner:
        return BannerBlockRuntime(block: block);
      
      case BlockType.productList:
        return ProductListBlockRuntime(block: block);
      
      case BlockType.info:
        return InfoBlockRuntime(block: block);
      
      case BlockType.spacer:
        return SpacerBlockRuntime(block: block);
      
      case BlockType.image:
        return ImageBlockRuntime(block: block);
      
      case BlockType.button:
        return ButtonBlockRuntime(block: block);
      
      case BlockType.categoryList:
        return CategoryListBlockRuntime(block: block);
      
      case BlockType.html:
        return HtmlBlockRuntime(block: block);
      
      // Unknown block types are silently ignored
      default:
        debugPrint('Unknown block type: ${block.type.value} for block ${block.id}');
        return const SizedBox.shrink();
    }
  }
}
