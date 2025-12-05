/// lib/builder/runtime/module_aware_block.dart
///
/// Module-aware block rendering widget.
///
/// This widget wraps block rendering with module checking using the
/// white-label navigation system's isModuleEnabled() helper.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/builder_block.dart';
import '../../white_label/runtime/module_helpers.dart';
import '../../white_label/core/module_id.dart';
import 'builder_block_runtime_registry.dart';

/// Module-aware block renderer.
///
/// This widget automatically hides blocks that require disabled modules.
/// It uses the white-label navigation system's isModuleEnabled() helper.
///
/// Usage:
/// ```dart
/// ModuleAwareBlock(
///   block: block,
///   isPreview: false,
/// )
/// ```
class ModuleAwareBlock extends ConsumerWidget {
  /// The block to render
  final BuilderBlock block;
  
  /// Whether this is preview mode (true) or runtime mode (false)
  final bool isPreview;
  
  /// Optional max content width
  final double? maxContentWidth;

  const ModuleAwareBlock({
    required this.block,
    this.isPreview = false,
    this.maxContentWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In preview mode, always show the block
    if (isPreview) {
      return _renderBlock(context);
    }
    
    // In runtime mode, check if block requires a module
    if (block.requiredModule != null) {
      // Parse the module ID
      final moduleId = _parseModuleId(block.requiredModule!);
      
      if (moduleId != null) {
        // Check if module is enabled
        if (!isModuleEnabled(ref, moduleId)) {
          // Module is disabled, hide the block
          return const SizedBox.shrink();
        }
      }
    }
    
    // Module is enabled or not required, render the block
    return _renderBlock(context);
  }
  
  /// Render the block using the registry
  Widget _renderBlock(BuildContext context) {
    return BuilderBlockRuntimeRegistry.render(
      block,
      context,
      isPreview: isPreview,
      maxContentWidth: maxContentWidth,
    );
  }
  
  /// Parse module ID string to ModuleId enum.
  /// Returns null if the string doesn't match any ModuleId.
  static ModuleId? _parseModuleId(String moduleIdStr) {
    try {
      return ModuleId.values.firstWhere(
        (id) => id.code == moduleIdStr,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Render a list of blocks with module awareness.
///
/// Each block is wrapped in ModuleAwareBlock to check module status.
///
/// Usage:
/// ```dart
/// ModuleAwareBlockList(
///   blocks: blocks,
///   isPreview: false,
/// )
/// ```
class ModuleAwareBlockList extends StatelessWidget {
  /// The blocks to render
  final List<BuilderBlock> blocks;
  
  /// Whether this is preview mode
  final bool isPreview;
  
  /// Optional max content width
  final double? maxContentWidth;

  const ModuleAwareBlockList({
    required this.blocks,
    this.isPreview = false,
    this.maxContentWidth,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocks.map((block) {
        return ModuleAwareBlock(
          block: block,
          isPreview: isPreview,
          maxContentWidth: maxContentWidth,
        );
      }).toList(),
    );
  }
}
