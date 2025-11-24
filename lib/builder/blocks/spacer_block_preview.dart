// lib/builder/blocks/spacer_block_preview.dart
// Spacer block preview widget

import 'package:flutter/material.dart';
import '../models/models.dart';

/// Spacer Block Preview
/// 
/// Displays vertical spacing between blocks.
class SpacerBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const SpacerBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final height = block.getConfig<double>('height', 32.0);

    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
      ),
    );
  }
}
