// lib/builder/preview/builder_page_preview.dart
// Preview widget that renders a list of blocks visually
// MOBILE RESPONSIVE: Fixed sizing and zoom issues on mobile

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../blocks/blocks.dart';
import '../utils/responsive.dart';

/// Builder Page Preview Widget
/// 
/// Displays a visual preview of a page based on its blocks.
/// Does not depend on runtime providers - uses only block data.
/// 
/// Usage:
/// ```dart
/// BuilderPagePreview(blocks: page.blocks)
/// ```
class BuilderPagePreview extends StatelessWidget {
  final List<BuilderBlock> blocks;
  final Color? backgroundColor;

  const BuilderPagePreview({
    super.key,
    required this.blocks,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Sort blocks by order
    final sortedBlocks = List<BuilderBlock>.from(blocks)
      ..sort((a, b) => a.order.compareTo(b.order));

    // Filter only active blocks
    final activeBlocks = sortedBlocks.where((b) => b.isActive).toList();

    if (activeBlocks.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveBuilder(constraints.maxWidth);
        
        return Container(
          color: backgroundColor ?? Colors.grey.shade50,
          child: SingleChildScrollView(
            physics: responsive.isMobile 
              ? const ClampingScrollPhysics() 
              : const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: responsive.previewMaxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.horizontalPadding,
                  vertical: responsive.verticalPadding,
                ),
                child: Column(
                  children: activeBlocks.map((block) => _buildBlock(block)).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlock(BuilderBlock block) {
    switch (block.type) {
      case BlockType.hero:
        return HeroBlockPreview(block: block);
      case BlockType.banner:
        return BannerBlockPreview(block: block);
      case BlockType.text:
        return TextBlockPreview(block: block);
      case BlockType.productList:
        return ProductListBlockPreview(block: block);
      case BlockType.info:
        return InfoBlockPreview(block: block);
      case BlockType.spacer:
        return SpacerBlockPreview(block: block);
      case BlockType.image:
        return ImageBlockPreview(block: block);
      case BlockType.button:
        return ButtonBlockPreview(block: block);
      case BlockType.categoryList:
        return CategoryListBlockPreview(block: block);
      case BlockType.html:
        return HtmlBlockPreview(block: block);
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun bloc à prévisualiser',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ajoutez des blocs pour voir la prévisualisation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen preview dialog
class BuilderFullScreenPreview extends StatelessWidget {
  final List<BuilderBlock> blocks;
  final String pageTitle;

  const BuilderFullScreenPreview({
    super.key,
    required this.blocks,
    required this.pageTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prévisualisation: $pageTitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: BuilderPagePreview(blocks: blocks),
    );
  }

  /// Show full-screen preview
  static void show(
    BuildContext context, {
    required List<BuilderBlock> blocks,
    required String pageTitle,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuilderFullScreenPreview(
          blocks: blocks,
          pageTitle: pageTitle,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
