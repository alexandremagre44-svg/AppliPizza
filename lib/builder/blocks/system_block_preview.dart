// lib/builder/blocks/system_block_preview.dart
// Preview version of SystemBlock for the editor
// Phase 5: Pure StatelessWidget, no business logic, preview only

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../models/builder_enums.dart';
import '../runtime/module_runtime_registry.dart';

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
/// - Optional plan-based filtering (hides disabled modules)
class SystemBlockPreview extends StatelessWidget {
  final BuilderBlock block;
  final bool debugMode;
  
  /// Optional restaurant plan for filtering modules
  /// If provided and module is disabled, returns SizedBox.shrink()
  final dynamic plan; // RestaurantPlanUnified? - dynamic to avoid import cycle
  
  /// Default height for system block preview
  static const double defaultHeight = 120.0;

  const SystemBlockPreview({
    super.key,
    required this.block,
    this.debugMode = false,
    this.plan,
  });
  
  /// Get Material Icon for the module type
  IconData _getModuleIcon(String moduleType) {
    switch (moduleType) {
      case 'roulette':
        return Icons.casino;
      case 'loyalty':
        return Icons.card_giftcard;
      case 'loyalty_module':
        return Icons.star;
      case 'rewards':
        return Icons.stars;
      case 'promotions_module':
        return Icons.local_offer;
      case 'newsletter_module':
        return Icons.email;
      case 'kitchen_module':
        return Icons.kitchen;
      case 'staff_module':
        return Icons.point_of_sale;
      case 'menu_catalog':
        return Icons.restaurant_menu;
      case 'profile_module':
        return Icons.person;
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
      case 'loyalty_module':
        return Colors.amber.shade600;
      case 'rewards':
        return Colors.orange.shade600;
      case 'promotions_module':
        return Colors.red.shade600;
      case 'newsletter_module':
        return Colors.teal.shade600;
      case 'kitchen_module':
        return Colors.brown.shade600;
      case 'staff_module':
        return Colors.cyan.shade600;
      case 'menu_catalog':
        return Colors.deepOrange.shade600;
      case 'profile_module':
        return Colors.blueGrey.shade600;
      case 'accountActivity':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  /// Build the ADMIN widget for a White-Label module in preview mode
  Widget? _buildAdminWidget(BuildContext context, String moduleId) {
    return ModuleRuntimeRegistry.buildAdmin(moduleId, context);
  }
  
  /// Check if a module is enabled in the plan
  /// 
  /// Returns true if:
  /// - module is in the filtered modules list from SystemBlock.getFilteredModules
  /// 
  /// Conservative approach: returns false if plan is null (hides all WL modules by default).
  bool _isModuleEnabled(String moduleType) {
    // Use the centralized SystemBlock.isModuleEnabled method
    // Note: plan is dynamic to avoid import cycle
    try {
      return SystemBlock.isModuleEnabled(moduleType, plan as dynamic);
    } catch (e) {
      // If filtering fails, hide the module (conservative/fail-closed)
      if (kDebugMode) {
        debugPrint('⚠️ [SystemBlockPreview] Error checking module enabled: $e');
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter modules based on plan if provided
    if (plan != null && block is SystemBlock) {
      final systemBlock = block as SystemBlock;
      final moduleType = systemBlock.moduleType;
      
      // Check if module should be hidden based on plan
      if (!_isModuleEnabled(moduleType)) {
        if (kDebugMode) {
          debugPrint('🚫 [SystemBlockPreview] Module "$moduleType" is disabled in plan - hiding');
        }
        return const SizedBox.shrink();
      }
    }
    
    // Check if this is a BlockType.module with moduleId
    // These should render the ADMIN widget in preview mode
    if (block.type == BlockType.module && block is SystemBlock) {
      final systemBlock = block as SystemBlock;
      if (systemBlock.moduleId != null) {
        final moduleId = systemBlock.moduleId!;
        
        // Filter modules based on plan for BlockType.module
        if (!SystemBlock.isModuleEnabled(moduleId, plan as dynamic)) {
          if (kDebugMode) {
            debugPrint('🚫 [SystemBlockPreview] Module "$moduleId" is disabled in plan - hiding');
          }
          return const SizedBox.shrink();
        }
        
        // Check if this is a WL system module (cart_module, delivery_module)
        // These should show a neutral placeholder, NOT try to render
        if (_isWLSystemModule(moduleId)) {
          return _buildSystemModulePlaceholder(context, moduleId);
        }
        
        // For other modules, try to render the ADMIN widget
        final widget = _buildAdminWidget(context, moduleId);
        if (widget != null) {
          return widget;
        }
        // Fallback to preview placeholder if admin widget not registered
      }
    }
    
    // Get the module type from config
    final moduleType = block.config['moduleType'] as String? ?? 'unknown';
    
    // Check if this is a WL system module
    if (_isWLSystemModule(moduleType)) {
      return _buildSystemModulePlaceholder(context, moduleType);
    }
    
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
  
  /// Check if a module ID is a WL system module (should not be rendered in preview)
  bool _isWLSystemModule(String moduleId) {
    const wlSystemModules = [
      'cart_module',
      'delivery_module',
      'click_collect_module',
    ];
    return wlSystemModules.contains(moduleId);
  }
  
  /// Build a neutral placeholder for WL system modules
  Widget _buildSystemModulePlaceholder(BuildContext context, String moduleId) {
    return Container(
      height: defaultHeight,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 32,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 12),
            Text(
              '[Module système – prévisualisation non disponible]',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Type: $moduleId',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
