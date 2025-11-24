// lib/builder/preview/builder_runtime_renderer.dart
// Renders builder blocks using runtime widgets (with real providers and data)

import 'package:flutter/foundation.dart';
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

  /// Safely builds a block with error handling and generic config support
  /// Applies padding, margin, and other generic styles from config
  /// Returns SizedBox.shrink() if block fails to render
  Widget _buildBlockSafe(BuilderBlock block) {
    try {
      // Build the core block widget
      Widget blockWidget = _buildBlock(block);
      
      // Apply generic config: padding, margin, styles
      blockWidget = _applyGenericConfig(block, blockWidget);
      
      return blockWidget;
    } catch (e, stackTrace) {
      // Log error in debug mode only
      if (kDebugMode) {
        debugPrint('Error rendering block ${block.id} (${block.type.value}): $e');
        debugPrint('Stack trace: $stackTrace');
      }
      
      // Return empty widget instead of crashing the page
      return const SizedBox.shrink();
    }
  }

  /// Apply generic configuration to a block widget
  /// Supports: padding, margin, backgroundColor, borderRadius, elevation
  Widget _applyGenericConfig(BuilderBlock block, Widget child) {
    Widget result = child;
    
    // Apply padding if configured
    final padding = _parsePadding(block.getConfig<dynamic>('padding'));
    if (padding != null) {
      result = Padding(padding: padding, child: result);
    }
    
    // Apply margin if configured (using Container with margin)
    final margin = _parsePadding(block.getConfig<dynamic>('margin'));
    final bgColor = _parseColor(block.getConfig<String>('backgroundColor'));
    final borderRadius = block.getConfig<double>('borderRadius');
    final elevation = block.getConfig<double>('elevation');
    
    if (margin != null || bgColor != null || borderRadius != null || elevation != null) {
      result = Container(
        margin: margin,
        decoration: bgColor != null || borderRadius != null
            ? BoxDecoration(
                color: bgColor,
                borderRadius: borderRadius != null 
                    ? BorderRadius.circular(borderRadius) 
                    : null,
                boxShadow: elevation != null && elevation > 0
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: elevation * 2,
                          offset: Offset(0, elevation),
                        ),
                      ]
                    : null,
              )
            : null,
        child: result,
      );
    }
    
    return result;
  }

  /// Parse padding/margin value from config
  /// Supports: number (all sides), map {top, left, right, bottom}, or string
  EdgeInsets? _parsePadding(dynamic value) {
    if (value == null) return null;
    
    // If it's a number, apply to all sides
    if (value is num) {
      return EdgeInsets.all(value.toDouble());
    }
    
    // If it's a map with specific sides
    if (value is Map) {
      return EdgeInsets.only(
        top: (value['top'] as num?)?.toDouble() ?? 0,
        left: (value['left'] as num?)?.toDouble() ?? 0,
        right: (value['right'] as num?)?.toDouble() ?? 0,
        bottom: (value['bottom'] as num?)?.toDouble() ?? 0,
      );
    }
    
    // If it's a string like "16" or "16,8,16,8"
    if (value is String) {
      final parts = value.split(',').map((s) => double.tryParse(s.trim()) ?? 0).toList();
      if (parts.length == 1) {
        return EdgeInsets.all(parts[0]);
      } else if (parts.length == 2) {
        return EdgeInsets.symmetric(vertical: parts[0], horizontal: parts[1]);
      } else if (parts.length == 4) {
        return EdgeInsets.only(
          top: parts[0],
          right: parts[1],
          bottom: parts[2],
          left: parts[3],
        );
      }
    }
    
    return null;
  }

  /// Parse color from hex string
  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;
    
    try {
      // Remove # if present
      final hex = colorStr.replaceAll('#', '');
      
      // Support 6-digit (RGB) and 8-digit (ARGB) hex colors
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing color: $colorStr');
      }
    }
    
    return null;
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
        if (kDebugMode) {
          debugPrint('Unknown block type: ${block.type.value} for block ${block.id}');
        }
        return const SizedBox.shrink();
    }
  }
}
