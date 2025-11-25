// lib/builder/blocks/system_block_preview.dart
// Preview version of SystemBlock for the editor
// Phase 5: Pure StatelessWidget, no business logic, preview only

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/builder_block.dart';

/// System Block Preview Widget
/// 
/// Displays a simplified preview of system modules in the builder editor.
/// Never executes real system widgets in preview mode.
/// 
/// Features:
/// - Fixed height of 120px by default
/// - Grey background with module name and icon
/// - Blue border when debug mode is enabled
/// - No real widget execution (safe for preview)
class SystemBlockPreview extends StatelessWidget {
  final BuilderBlock block;
  final bool debugMode;
  
  /// Default height for system block preview
  static const double defaultHeight = 120.0;

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
    
    // Check if module type is valid
    final isValidModule = SystemBlock.availableModules.contains(moduleType);
    
    // Use debug mode from kDebugMode if not explicitly set
    final showDebugBorder = debugMode || kDebugMode;

    return Container(
      height: defaultHeight,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showDebugBorder ? Colors.blue : Colors.grey.shade400,
          width: showDebugBorder ? 2 : 1,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
                  isValidModule ? 'Module $moduleLabel' : 'Module système inconnu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isValidModule ? Colors.grey.shade800 : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isValidModule 
                      ? 'Prévisualisation uniquement' 
                      : 'Type: $moduleType',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
