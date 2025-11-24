// lib/builder/blocks/html_block_runtime.dart
// Runtime version of HTMLBlock - simplified text rendering

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../../src/theme/app_theme.dart';

class HtmlBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const HtmlBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final html = block.getConfig<String>('html') ?? '';
    
    if (html.isEmpty) {
      return const SizedBox.shrink();
    }

    // Simple HTML tag stripping for display
    final strippedText = html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();

    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: Text(
        strippedText,
        style: AppTextStyles.bodyMedium,
      ),
    );
  }
}
