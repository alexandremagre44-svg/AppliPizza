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
  
  /// Get Material Icon for the module type
  IconData _getModuleIcon(String moduleType) {
    switch (moduleType) {
      case 'roulette':
        return Icons.casino;
      case 'loyalty':
        return Icons.card_giftcard;
      case 'rewards':
        return Icons.stars;
      case 'accountActivity':
        return Icons.history;
      default:
        return Icons.help_outline;
    }
  }
  
  /// Get color for the module type icon
  Color _getModuleColor(String moduleType) {
    switch (moduleType) {
      case 'roulette':
        return Colors.purple.shade600;
      case 'loyalty':
        return Colors.amber.shade600;
      case 'rewards':
        return Colors.orange.shade600;
      case 'accountActivity':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the module type from config
    final moduleType = block.config['moduleType'] as String? ?? 'unknown';
    final moduleLabel = SystemBlock.getModuleLabel(moduleType);
    
    // Get icon and color for the module
    final moduleIcon = _getModuleIcon(moduleType);
    final moduleColor = _getModuleColor(moduleType);
    
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
            Icon(
              moduleIcon,
              size: 32,
              color: isValidModule ? moduleColor : Colors.red.shade400,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isValidModule ? '[Module: $moduleLabel]' : '[Module système inconnu]',
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
