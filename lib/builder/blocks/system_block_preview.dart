// lib/builder/blocks/system_block_preview.dart
// Preview version of SystemBlock for the editor

import 'package:flutter/material.dart';
import '../models/builder_block.dart';

/// System Block Preview Widget
/// 
/// Displays a simplified preview of system modules in the builder editor.
/// Shows a grey box with the module name and an icon.
/// Displays a blue border when debug mode is enabled.
class SystemBlockPreview extends StatelessWidget {
  final BuilderBlock block;
  final bool debugMode;

  const SystemBlockPreview({
    super.key,
    required this.block,
    this.debugMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get the module type from config
    final moduleType = block.config['moduleType'] as String? ?? 'unknown';
    final moduleLabel = SystemBlock.getModuleLabel(moduleType);
    final moduleIcon = SystemBlock.getModuleIcon(moduleType);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: debugMode ? Colors.blue : Colors.grey.shade400,
          width: debugMode ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            moduleIcon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Module $moduleLabel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Module système (non configurable)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
