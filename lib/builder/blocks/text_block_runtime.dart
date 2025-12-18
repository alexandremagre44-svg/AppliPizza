// lib/builder/blocks/text_block_runtime.dart
import '../../white_label/theme/theme_extensions.dart';
// Runtime version of TextBlock - Phase 5 enhanced
// ThemeConfig Integration: Uses theme textBodySize and textHeadingSize

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../models/theme_config.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';
import '../runtime/builder_theme_resolver.dart';

/// Text block for displaying formatted text
/// 
/// Configuration:
/// - content: Text content to display (default: '')
/// - textAlign: Alignment (left, center, right, justify) (default: left)
/// - fontSize: Font size in pixels (default: theme textBodySize)
/// - fontWeight: Weight (normal, medium, semibold, bold) (default: normal)
/// - textColor: Text color in hex (default: #000000)
/// - maxLines: Maximum lines before truncation (default: null - no limit)
/// - padding: Padding around text (default: theme spacing)
/// - margin: Margin around block (default: 0)
/// - size: Text size preset (small, normal, large, title, heading)
/// - action: Optional tap action
/// 
/// Responsive: Full width on mobile, constrained on desktop
/// ThemeConfig: Uses theme.textBodySize and theme.textHeadingSize
class TextBlockRuntime extends StatelessWidget {
  final BuilderBlock block;
  
  /// Optional theme config override
  /// If null, uses theme from context
  final ThemeConfig? themeConfig;

  const TextBlockRuntime({
    super.key,
    required this.block,
    this.themeConfig,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get theme (from prop or context)
    final theme = themeConfig ?? context.builderTheme;
    
    // Get configuration with defaults
    final content = helper.getString('content', defaultValue: '');
    final textAlign = helper.getTextAlign('textAlign', defaultValue: TextAlign.left);
    final fontWeight = helper.getFontWeight('fontWeight', defaultValue: FontWeight.normal);
    final textColor = helper.getColor('textColor', defaultValue: Colors.black87);
    final maxLines = helper.has('maxLines') ? helper.getInt('maxLines') : null;
    final padding = helper.getEdgeInsets('padding', defaultValue: EdgeInsets.all(theme.spacing * 0.75));
    final margin = helper.getEdgeInsets('margin');
    
    // Determine font size from explicit fontSize or size preset
    final sizePreset = helper.getString('size', defaultValue: 'normal');
    final fontSize = _getFontSize(helper, theme, sizePreset);
    
    // Get action config
    final actionConfig = block.config['action'] as Map<String, dynamic>?;

    // Build text widget
    Widget textWidget = Text(
      content,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
      ),
    );

    // Apply padding
    textWidget = Padding(
      padding: padding,
      child: textWidget,
    );

    // Apply margin if configured
    if (margin != EdgeInsets.zero) {
      textWidget = Padding(
        padding: margin,
        child: textWidget,
      );
    }

    // Wrap with action if configured
    if (actionConfig != null && actionConfig.isNotEmpty) {
      textWidget = ActionHelper.wrapWithAction(context, textWidget, actionConfig);
    }

    return textWidget;
  }
  
  /// Get font size from explicit value or preset
  double _getFontSize(BlockConfigHelper helper, ThemeConfig theme, String sizePreset) {
    // If explicit fontSize is provided, use it
    if (helper.has('fontSize')) {
      return helper.getDouble('fontSize', defaultValue: theme.textBodySize);
    }
    
    // Otherwise use preset based on theme values
    switch (sizePreset.toLowerCase()) {
      case 'small':
        return theme.textBodySize * 0.85;
      case 'large':
        return theme.textBodySize * 1.25;
      case 'title':
        return theme.textHeadingSize * 0.85;
      case 'heading':
        return theme.textHeadingSize;
      case 'normal':
      default:
        return theme.textBodySize;
    }
  }
}
