// lib/builder/blocks/spacer_block_runtime.dart
import '../../white_label/theme/theme_extensions.dart';
// Runtime version of SpacerBlock - Phase 5 enhanced
// ThemeConfig Integration: Uses theme spacing as default

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../models/theme_config.dart';
import '../utils/block_config_helper.dart';
import '../runtime/builder_theme_resolver.dart';

/// Spacer block for adding vertical space
/// 
/// Configuration:
/// - height: Height in pixels (default: theme spacing * 1.5)
/// - margin: Optional margin around the spacer
/// 
/// Responsive: Maintains same height on all devices
/// ThemeConfig: Uses theme.spacing for default height
class SpacerBlockRuntime extends StatelessWidget {
  final BuilderBlock block;
  
  /// Optional theme config override
  /// If null, uses theme from context
  final ThemeConfig? themeConfig;

  const SpacerBlockRuntime({
    super.key,
    required this.block,
    this.themeConfig,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get theme (from prop or context)
    final theme = themeConfig ?? context.builderTheme;
    
    // Get configuration with defaults - use theme spacing as default
    final height = helper.getDouble('height', defaultValue: theme.spacing * 1.5);
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
