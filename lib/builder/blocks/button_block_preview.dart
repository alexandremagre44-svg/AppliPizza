// lib/builder/blocks/button_block_preview.dart
// Button block preview widget

import 'package:flutter/material.dart';
import '../models/models.dart';

/// Button Block Preview
/// 
/// Displays a call-to-action button.
class ButtonBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const ButtonBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final label = block.getConfig<String>('label', 'Bouton');
    final alignment = block.getConfig<String>('alignment', 'center');
    final style = block.getConfig<String>('style', 'primary');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: _getAlignment(alignment),
      child: ElevatedButton(
        onPressed: () {},
        style: _getButtonStyle(style),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(String alignment) {
    switch (alignment) {
      case 'left':
        return Alignment.centerLeft;
      case 'right':
        return Alignment.centerRight;
      case 'center':
      default:
        return Alignment.center;
    }
  }

  ButtonStyle _getButtonStyle(String style) {
    switch (style) {
      case 'secondary':
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case 'outline':
        return OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          elevation: MaterialStateProperty.all(0),
        );
      case 'primary':
      default:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
    }
  }
}
