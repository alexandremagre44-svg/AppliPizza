// lib/builder/blocks/text_block_runtime.dart
// Runtime version of TextBlock - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';

/// Text block for displaying formatted text
/// 
/// Configuration:
/// - content: Text content to display (default: '')
/// - textAlign: Alignment (left, center, right, justify) (default: left)
/// - fontSize: Font size in pixels (default: 16)
/// - fontWeight: Weight (normal, medium, semibold, bold) (default: normal)
/// - textColor: Text color in hex (default: #000000)
/// - maxLines: Maximum lines before truncation (default: null - no limit)
/// - padding: Padding around text (default: 12)
/// - margin: Margin around block (default: 0)
/// - action: Optional tap action
/// 
/// Responsive: Full width on mobile, constrained on desktop
class TextBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const TextBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults
    final content = helper.getString('content', defaultValue: '');
    final textAlign = helper.getTextAlign('textAlign', defaultValue: TextAlign.left);
    final fontSize = helper.getDouble('fontSize', defaultValue: 16.0);
    final fontWeight = helper.getFontWeight('fontWeight', defaultValue: FontWeight.normal);
    final textColor = helper.getColor('textColor', defaultValue: Colors.black87);
    final maxLines = helper.has('maxLines') ? helper.getInt('maxLines') : null;
    final padding = helper.getEdgeInsets('padding', defaultValue: const EdgeInsets.all(12));
    final margin = helper.getEdgeInsets('margin');
    
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
}
