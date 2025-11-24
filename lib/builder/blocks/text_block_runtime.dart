// lib/builder/blocks/text_block_runtime.dart
// Runtime version of TextBlock - uses real app styling

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../../src/theme/app_theme.dart';

class TextBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const TextBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final content = block.getConfig<String>('content') ?? '';
    final alignment = block.getConfig<String>('alignment') ?? 'left';
    final size = block.getConfig<String>('size') ?? 'normal';

    // Determine text alignment
    TextAlign textAlign;
    switch (alignment) {
      case 'center':
        textAlign = TextAlign.center;
        break;
      case 'right':
        textAlign = TextAlign.right;
        break;
      default:
        textAlign = TextAlign.left;
    }

    // Determine text style
    TextStyle textStyle;
    switch (size) {
      case 'small':
        textStyle = AppTextStyles.bodySmall;
        break;
      case 'large':
        textStyle = AppTextStyles.bodyLarge;
        break;
      default:
        textStyle = AppTextStyles.bodyMedium;
    }

    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: Text(
        content,
        textAlign: textAlign,
        style: textStyle,
      ),
    );
  }
}
