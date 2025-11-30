// lib/builder/preview/builder_runtime_renderer.dart
// Renders builder blocks using runtime widgets (with real providers and data)
// Phase 5: Layout logic centralized, all styling via BlockConfigHelper
// ThemeConfig Integration: Uses theme spacing and background color

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../runtime/builder_block_runtime_registry.dart';
import '../runtime/builder_theme_resolver.dart';

/// Renders a list of BuilderBlocks using runtime widgets
/// These widgets can access providers, services, and real data
/// 
/// Features:
/// - Filters out disabled blocks (isActive == false)
/// - Sorts blocks by order property
/// - Handles unknown block types gracefully
/// - Optional ScrollView wrapper for proper scrolling
/// - Error handling for individual blocks
/// - Phase 5 compliant: centralized layout logic
/// - maxContentWidth support for constrained layouts
/// - ThemeConfig support for consistent spacing and styling
class BuilderRuntimeRenderer extends ConsumerWidget {
  final List<BuilderBlock> blocks;
  final Color? backgroundColor;
  
  /// Maximum content width in pixels (optional constraint)
  /// Useful for desktop layouts with centered content
  /// Example: 600.0 for a 600px max width
  final double? maxContentWidth;
  
  /// Whether to wrap content in SingleChildScrollView
  /// Set to false if parent already provides scrolling
  final bool wrapInScrollView;
  
  /// Optional ThemeConfig for consistent styling
  /// If provided, uses theme.spacing for block spacing
  /// If null, uses default spacing of 16px
  final ThemeConfig? themeConfig;

  const BuilderRuntimeRenderer({
    super.key,
    required this.blocks,
    this.backgroundColor,
    this.maxContentWidth,
    this.wrapInScrollView = true,
    this.themeConfig,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use theme spacing or default
    final theme = themeConfig ?? context.builderTheme;
    final blockSpacing = theme.spacing;
    
    // Use theme background color if not explicitly set
    final effectiveBackgroundColor = backgroundColor ?? theme.backgroundColor;
    
    // Filter enabled blocks only (isActive == true) and sort by order
    final activeBlocks = blocks
        .where((block) => block.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // Empty state when no blocks are configured
    if (activeBlocks.isEmpty) {
      return Container(
        color: effectiveBackgroundColor,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(theme.spacing * 2),
            child: Text(
              'Aucun contenu configuré',
              style: TextStyle(
                fontSize: theme.textBodySize,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    // Build column of blocks with theme-based spacing
    Widget blocksColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Render each block with error handling and spacing
        for (int i = 0; i < activeBlocks.length; i++) ...[
          _buildBlockSafe(activeBlocks[i], context, theme),
          // Add spacing between blocks (except after last block)
          if (i < activeBlocks.length - 1)
            SizedBox(height: blockSpacing),
        ],
      ],
    );
    
    // Apply max content width constraint if specified
    if (maxContentWidth != null) {
      blocksColumn = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth!),
          child: blocksColumn,
        ),
      );
    }

    // Wrap in ScrollView if requested
    return Container(
      color: effectiveBackgroundColor,
      child: wrapInScrollView
          ? SingleChildScrollView(child: blocksColumn)
          : blocksColumn,
    );
  }

  /// Safely builds a block with error handling and generic config support
  /// Applies padding, margin, and other generic styles from config
  /// Returns SizedBox.shrink() if block fails to render
  Widget _buildBlockSafe(BuilderBlock block, BuildContext context, ThemeConfig theme) {
    try {
      // Build the core block widget
      Widget blockWidget = _buildBlock(block, context);
      
      // Apply generic config: padding, margin, styles
      blockWidget = _applyGenericConfig(block, blockWidget, theme);
      
      return blockWidget;
    } catch (e, stackTrace) {
      // Log error in debug mode only
      if (kDebugMode) {
        debugPrint('Error rendering block ${block.id} (${block.type.value}): $e');
        debugPrint('Stack trace: $stackTrace');
      }
      
      // Return fallback error widget instead of crashing the page
      return _buildErrorFallback(block, e.toString(), theme);
    }
  }
  
  /// Build error fallback widget for failed blocks
  Widget _buildErrorFallback(BuilderBlock block, String errorMessage, ThemeConfig theme) {
    return Container(
      padding: EdgeInsets.all(theme.spacing),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(theme.cardRadius),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 32),
          const SizedBox(height: 8),
          Text(
            'Erreur de rendu: ${block.type.label}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 4),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Apply generic configuration to a block widget
  /// Supports: padding, margin, backgroundColor, borderRadius, elevation
  Widget _applyGenericConfig(BuilderBlock block, Widget child, ThemeConfig theme) {
    Widget result = child;
    
    // Apply padding if configured
    final padding = _parsePadding(block.getConfig<dynamic>('padding'));
    if (padding != null) {
      result = Padding(padding: padding, child: result);
    }
    
    // Apply margin if configured (using Container with margin)
    final margin = _parsePadding(block.getConfig<dynamic>('margin'));
    final bgColor = _parseColor(block.getConfig<String>('backgroundColor'));
    // Use block-specific radius or fallback to theme cardRadius
    final borderRadius = block.getConfig<double>('borderRadius') ?? 
        (bgColor != null ? theme.cardRadius : null);
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
      // Validate known keys and warn about typos in debug mode
      if (kDebugMode) {
        final knownKeys = {'top', 'left', 'right', 'bottom'};
        final unknownKeys = value.keys.where((k) => !knownKeys.contains(k)).toList();
        if (unknownKeys.isNotEmpty) {
          debugPrint('Warning: Unknown padding/margin keys: $unknownKeys. Valid keys: $knownKeys');
        }
      }
      
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

  /// Maps block type to corresponding runtime widget via registry
  Widget _buildBlock(BuilderBlock block, BuildContext context) {
    return BuilderBlockRuntimeRegistry.render(
      block,
      context,
      maxContentWidth: maxContentWidth,
    );
  }
}
