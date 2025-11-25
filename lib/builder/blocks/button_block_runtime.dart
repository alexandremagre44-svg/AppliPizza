// lib/builder/blocks/button_block_runtime.dart
// Runtime version of ButtonBlock - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';

/// Button block for call-to-action buttons
/// 
/// Configuration:
/// - label: Button text (default: 'Button')
/// - size: Button size (small, medium, large) (default: medium)
/// - alignment: Button alignment (left, center, right) (default: center)
/// - textColor: Text color in hex (default: #FFFFFF for primary, theme for others)
/// - backgroundColor: Background color in hex (default: theme primary)
/// - borderRadius: Corner radius (default: 8)
/// - padding: Padding around button (default: 12)
/// - margin: Margin around block (default: 0)
/// - action: Action to perform on tap (required)
/// 
/// Responsive: Constrained width on desktop
class ButtonBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const ButtonBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults
    final label = helper.getString('label', defaultValue: 'Button');
    final size = helper.getString('size', defaultValue: 'medium');
    final alignment = helper.getString('alignment', defaultValue: 'center');
    final textColor = helper.getColor('textColor');
    final backgroundColor = helper.getColor('backgroundColor');
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 8.0);
    final padding = helper.getEdgeInsets('padding', defaultValue: const EdgeInsets.all(12));
    final margin = helper.getEdgeInsets('margin');
    
    // Get action config from separate tapAction/tapActionTarget fields
    // Falls back to 'action' field for backward compatibility
    var actionConfig = helper.getActionConfig();
    actionConfig ??= block.config['action'] as Map<String, dynamic>?;

    // Determine button size
    EdgeInsets buttonPadding;
    double fontSize;
    switch (size.toLowerCase()) {
      case 'small':
        buttonPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        fontSize = 14;
        break;
      case 'large':
        buttonPadding = const EdgeInsets.symmetric(horizontal: 48, vertical: 20);
        fontSize = 18;
        break;
      default: // medium
        buttonPadding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
        fontSize = 16;
    }

    // Determine alignment
    Alignment widgetAlignment;
    switch (alignment.toLowerCase()) {
      case 'left':
        widgetAlignment = Alignment.centerLeft;
        break;
      case 'right':
        widgetAlignment = Alignment.centerRight;
        break;
      default:
        widgetAlignment = Alignment.center;
    }

    // Build button
    Widget button = ElevatedButton(
      onPressed: actionConfig != null && actionConfig.isNotEmpty
          ? () => ActionHelper.execute(context, BlockAction.fromConfig(actionConfig))
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: textColor ?? Colors.white,
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 2,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );

    // Apply padding
    Widget content = Padding(
      padding: padding,
      child: Align(
        alignment: widgetAlignment,
        child: button,
      ),
    );

    // Apply margin if configured
    if (margin != EdgeInsets.zero) {
      content = Padding(
        padding: margin,
        child: content,
      );
    }

    return content;
  }
}
