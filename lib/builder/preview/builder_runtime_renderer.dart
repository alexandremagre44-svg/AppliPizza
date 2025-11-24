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
class BuilderRuntimeRenderer extends ConsumerWidget {
  final List<BuilderBlock> blocks;
  final Color? backgroundColor;

  const BuilderRuntimeRenderer({
    super.key,
    required this.blocks,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter active blocks and sort by order
    final activeBlocks = blocks
        .where((block) => block.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (activeBlocks.isEmpty) {
      return Container(
        color: backgroundColor,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'Aucun bloc actif',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: activeBlocks.map((block) => _buildBlock(block)).toList(),
      ),
    );
  }

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
      
      default:
        return const SizedBox.shrink();
    }
  }
}
