// lib/builder/blocks/banner_block_preview.dart
// Banner block preview widget

import 'package:flutter/material.dart';
import '../models/models.dart';

/// Banner Block Preview
/// 
/// Displays a colored banner with text.
class BannerBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const BannerBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final text = block.getConfig<String>('text', 'Bannière');
    final backgroundColor = block.getConfig<String>('backgroundColor', '#2196F3');
    final textColor = block.getConfig<String>('textColor', '#FFFFFF');

    final bgColor = _parseColor(backgroundColor);
    final txtColor = _parseColor(textColor);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: txtColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: txtColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        final hex = colorString.substring(1);
        return Color(int.parse('FF$hex', radix: 16));
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }
}
