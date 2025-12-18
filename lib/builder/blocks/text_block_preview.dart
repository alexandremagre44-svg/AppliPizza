// lib/builder/blocks/text_block_preview.dart
import '../../white_label/theme/theme_extensions.dart';
// Text block preview widget

import 'package:flutter/material.dart';
import '../models/models.dart';

/// Text Block Preview
/// 
/// Displays formatted text content with alignment and size options.
class TextBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const TextBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final content = block.getConfig<String>('content', 'Texte par défaut') ?? 'Texte par défaut';
    final alignment = block.getConfig<String>('alignment', 'left') ?? 'left';
    final size = block.getConfig<String>('size', 'normal') ?? 'normal';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Text(
        content,
        textAlign: _getTextAlignment(alignment),
        style: _getTextStyle(size),
      ),
    );
  }

  TextAlign _getTextAlignment(String alignment) {
    switch (alignment) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
      default:
        return TextAlign.left;
    }
  }

  TextStyle _getTextStyle(String size) {
    switch (size) {
      case 'small':
        return const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Colors.black87,
        );
      case 'large':
        return const TextStyle(
          fontSize: 20,
          height: 1.6,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        );
      case 'normal':
      default:
        return const TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.black87,
        );
    }
  }
}
