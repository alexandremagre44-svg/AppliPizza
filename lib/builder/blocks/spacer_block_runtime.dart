// lib/builder/blocks/spacer_block_runtime.dart
// Runtime version of SpacerBlock - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../utils/block_config_helper.dart';

/// Spacer block for adding vertical space
/// 
/// Configuration:
/// - height: Height in pixels (default: 24)
/// - margin: Optional margin around the spacer
/// 
/// Responsive: Maintains same height on all devices
class SpacerBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const SpacerBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults
    final height = helper.getDouble('height', defaultValue: 24.0);
    final margin = helper.getEdgeInsets('margin');

    // Build spacer
    Widget spacer = SizedBox(height: height);

    // Apply margin if configured
    if (margin != EdgeInsets.zero) {
      spacer = Padding(
        padding: margin,
        child: spacer,
      );
    }

    return spacer;
  }
}
