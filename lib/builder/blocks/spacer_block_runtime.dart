// lib/builder/blocks/spacer_block_runtime.dart
// Runtime version of SpacerBlock

import 'package:flutter/material.dart';
import '../models/builder_block.dart';

class SpacerBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const SpacerBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final heightStr = block.getConfig<String>('height') ?? '32';
    final height = double.tryParse(heightStr) ?? 32.0;

    return SizedBox(height: height);
  }
}
