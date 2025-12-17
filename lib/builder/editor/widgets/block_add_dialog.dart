// lib/builder/editor/widgets/block_add_dialog.dart
// Dialog for adding new blocks to a page
// Part of Builder B3 modular UI layer
//
// TODO: Manual test cases after applying this patch:
//
// Test Case 1: Selective module activation
//   - In SuperAdmin, enable only: Commandes en ligne, Livraison, Click & Collect, Thème
//   - Disable: Fidélité, Roulette, Promotions, Newsletter, Tablette, etc.
//   - In Builder, open "Ajouter un bloc" modal
//   - Expected: "Modules système" section should show only modules corresponding to 
//     enabled features (plus always-visible modules like menu_catalog)
//   - The disabled modules should NOT appear in the list
//
// Test Case 2: Minimal configuration
//   - In SuperAdmin, disable all optional WL features (keep only minimum required)
//   - In Builder, open "Ajouter un bloc" modal
//   - Expected: System modules list should be drastically reduced
//   - App should not crash, existing system pages remain editable
//   - Cannot add new blocks for disabled modules
//
// Test Case 3: Plan not loaded (null)
//   - If plan is not loaded or fails to load
//   - Expected: BlockAddDialog should behave safely
//     - Show only always-visible modules (menu_catalog)
//     - OR show nothing in system modules section
//     - Should NOT show all modules like before (current behavior)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../utils/builder_modules.dart' as builder_modules;
import '../../../src/providers/restaurant_plan_provider.dart';
import '../../../white_label/restaurant/restaurant_plan_unified.dart';
import '../../../white_label/core/module_id.dart';
import '../../../white_label/core/module_category.dart';
import '../../white_label/theme/theme_extensions.dart';

/// Dialog for selecting and adding a new block
/// 
/// Features:
/// - Grid or list view of available block types
/// - Separate section for system modules
/// - Block type previews and descriptions
/// - Returns the created block or null if cancelled
/// - **Filters system modules based on restaurant's white-label plan**
///   - Only shows modules for which the required ModuleId is activated
///   - Modules without module requirements are always shown (legacy compatibility)
///   - If plan is null, shows only always-visible modules (strict filtering)
class BlockAddDialog extends StatelessWidget {
  /// Current number of blocks (used for order calculation)
  final int currentBlockCount;
  
  /// Optional filter for available block types
  final List<BlockType>? allowedTypes;
  
  /// Whether to show system modules section
  /// 
  /// Default: false - System modules should be managed through white-label
  /// configuration, not added directly in the page builder.
  final bool showSystemModules;
  
  /// Restaurant plan for filtering modules
  /// 
  /// If provided, only modules enabled in this plan will be shown.
  /// If null, only always-visible modules (menu_catalog) are shown.
  final RestaurantPlanUnified? restaurantPlan;

  const BlockAddDialog({
    super.key,
    required this.currentBlockCount,
    this.allowedTypes,
    this.showSystemModules = false,
    this.restaurantPlan,
  });

  /// Show the dialog and return the created block
  /// 
  /// By default, system modules are hidden. The Builder should focus on
  /// visual content blocks. System modules are configured through the
  /// white-label system.
  static Future<BuilderBlock?> show(
    BuildContext context, {
    required int currentBlockCount,
    List<BlockType>? allowedTypes,
    bool showSystemModules = false,
    RestaurantPlanUnified? restaurantPlan,
  }) {
    return showDialog<BuilderBlock>(
      context: context,
      builder: (context) => BlockAddDialog(
        currentBlockCount: currentBlockCount,
        allowedTypes: allowedTypes,
        showSystemModules: showSystemModules,
        restaurantPlan: restaurantPlan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the restaurant plan passed from the editor
    final plan = restaurantPlan;
    
    // DEBUG: Log plan state
    if (kDebugMode) {
      debugPrint('🔍 [BlockAddDialog] Build with plan:');
      if (plan == null) {
        debugPrint('  ⚠️ plan is null → show only always-visible modules');
      } else {
        final activeModules = plan.activeModules.join(', ');
        debugPrint('  ✅ plan loaded with ${plan.activeModules.length} modules: $activeModules');
      }
    }
    
    return _buildDialogContent(context, plan);
  }

  /// Build dialog content with plan data (or null for strict filtering)
  Widget _buildDialogContent(BuildContext context, RestaurantPlanUnified? plan) {
    // Filter out system and module types - keep only visual content blocks
    // System modules are managed through white-label configuration
    final regularBlocks = (allowedTypes ?? BlockType.values)
        .where((t) => t != BlockType.system && t != BlockType.module)
        .toList();
    
    // DEBUG: Log filtering
    if (kDebugMode && plan != null) {
      debugPrint('🔍 [BlockAddDialog] Filtering modules for plan ${plan.restaurantId}');
      debugPrint('   Active modules: ${plan.activeModules.join(", ")}');
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_box, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          const Text('Ajouter un bloc'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Regular blocks section
              _buildSectionHeader(
                'Blocs de contenu',
                Icons.widgets,
                context.textSecondary,
              ),
              const SizedBox(height: 8),
              _buildBlockGrid(context, regularBlocks),
              
              if (showSystemModules) ...[
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Modules système',
                  Icons.extension,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildSystemModulesList(context, plan),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockGrid(BuildContext context, List<BlockType> types) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) => _buildBlockTypeChip(context, type)).toList(),
    );
  }

  Widget _buildBlockTypeChip(BuildContext context, BlockType type) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addBlock(context, type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(type.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                type.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemModulesList(BuildContext context, RestaurantPlanUnified? plan) {
    // Get filtered module IDs based on restaurant plan
    // This is the KEY CHANGE: using SystemBlock.getFilteredModules() to respect the plan
    // SystemBlock.getFilteredModules() now filters out system modules automatically
    final moduleIds = SystemBlock.getFilteredModules(plan);
    
    // Dynamically construct module info using SystemBlock helper methods
    final builderModules = moduleIds.map((id) {
      return _SystemModuleInfo(
        id: id,
        label: SystemBlock.getModuleLabel(id),
        description: SystemBlock.getModuleDescription(id),
        icon: SystemBlock.getModuleIcon(id),
        color: SystemBlock.getModuleColor(id),
      );
    }).toList();
    
    final filteredModules = builderModules;
    
    // DEBUG: Log filtered modules
    if (kDebugMode) {
      debugPrint('🔍 [BlockAddDialog] SystemBlock.getFilteredModules returned: ${moduleIds.join(", ")}');
      debugPrint('   Filtered modules: ${filteredModules.map((m) => m.id).join(", ")}');
      debugPrint('   Note: System modules (pos, cart, ordering, payments) are automatically filtered out');
    }

    return Column(
      children: [
        // Show warning if plan is null (strict filtering mode)
        if (plan == null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Plan non chargé → seuls les modules toujours visibles sont affichés',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Show message if no modules are available
        if (filteredModules.isEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aucun module système disponible avec la configuration actuelle',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ...filteredModules.map((module) => _buildSystemModuleTile(context, module)).toList(),
      ],
    );
  }

  Widget _buildSystemModuleTile(BuildContext context, _SystemModuleInfo module) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: module.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(module.icon, color: module.color),
        ),
        title: Text(module.label),
        subtitle: Text(
          module.description,
          style: TextStyle(fontSize: 12, color: context.textSecondary.shade600),
        ),
        trailing: const Icon(Icons.add_circle_outline),
        onTap: () => _addSystemBlock(context, module.id),
      ),
    );
  }

  void _addBlock(BuildContext context, BlockType type) {
    final newBlock = BuilderBlock(
      id: 'block_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      order: currentBlockCount,
      config: _getDefaultConfig(type),
    );
    Navigator.pop(context, newBlock);
  }

  void _addSystemBlock(BuildContext context, String moduleType) {
    // CRITICAL SAFETY CHECK: Prevent adding system modules
    // Get the ModuleId for this builder module to check if it's a system module
    final moduleId = builder_modules.getModuleIdForBuilder(moduleType);
    
    if (moduleId != null && moduleId.isSystemModule) {
      // This is a system module and should NEVER be addable via Builder
      if (kDebugMode) {
        debugPrint('🚫 [BlockAddDialog] BLOCKED: Attempted to add system module: $moduleType (${moduleId.code})');
      }
      // Show a message and return without adding
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${moduleId.label} est un module système et ne peut pas être ajouté ici.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
      return;
    }
    
    // Check if this is a WL system module (cart, delivery, click&collect)
    // These should NOT be addable from the Builder
    final isWLSystemModule = [
      'cart_module',
      'delivery_module',
      'click_collect_module',
    ].contains(moduleType);
    
    if (isWLSystemModule) {
      // These modules are system pages and should not be added via Builder
      if (kDebugMode) {
        debugPrint('⚠️ [BlockAddDialog] Attempted to add WL system module: $moduleType');
      }
      // Show a message and return without adding
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$moduleType est une page système et ne peut pas être ajouté ici.'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context);
      return;
    }
    
    // Check if this is a new-style White-Label module (other WL modules)
    final isWLModule = [
      'loyalty_module',
      'rewards_module',
      'promotions_module',
      'newsletter_module',
      'kitchen_module',
      'staff_module',
    ].contains(moduleType);

    final BuilderBlock newBlock;
    if (isWLModule) {
      // Use the createModule factory for White-Label modules
      newBlock = SystemBlock.createModule(moduleType);
      // Update order to current count
      final updatedBlock = newBlock.copyWith(order: currentBlockCount);
      Navigator.pop(context, updatedBlock);
    } else {
      // Legacy system modules (roulette, loyalty, rewards, etc.)
      newBlock = SystemBlock(
        id: 'block_${DateTime.now().millisecondsSinceEpoch}',
        type: BlockType.system,
        moduleType: moduleType,
        order: currentBlockCount,
      );
      Navigator.pop(context, newBlock);
    }
  }

  Map<String, dynamic> _getDefaultConfig(BlockType type) {
    switch (type) {
      case BlockType.hero:
        return {
          'title': 'Titre du Hero',
          'subtitle': 'Sous-titre',
          'imageUrl': '',
          'backgroundColor': '#D32F2F',
          'buttonLabel': 'En savoir plus',
          'alignment': 'center',
          'heightPreset': 'normal',
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.text:
        return {
          'content': 'Nouveau texte',
          'alignment': 'left',
          'size': 'normal',
          'bold': false,
          'color': '',
          'padding': 16,
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.productList:
        return {
          'title': '',
          'titleAlignment': 'left',
          'titleSize': 'medium',
          'mode': 'featured',
          'categoryId': '',
          'productIds': '',
          'layout': 'grid',
          'limit': 6,
          'backgroundColor': '',
          'textColor': '',
          'borderRadius': 8,
          'elevation': 2,
          'actionOnProductTap': 'openProductDetail',
        };
      case BlockType.banner:
        return {
          'title': 'Nouvelle bannière',
          'subtitle': '',
          'text': '',
          'imageUrl': '',
          'backgroundColor': '#2196F3',
          'textColor': '#FFFFFF',
          'style': 'info',
          'ctaLabel': '',
          'ctaAction': '',
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.button:
        return {
          'label': 'Bouton',
          'style': 'primary',
          'alignment': 'center',
          'backgroundColor': '',
          'textColor': '',
          'borderRadius': 8,
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.image:
        return {
          'imageUrl': '',
          'caption': '',
          'alignment': 'center',
          'height': 300,
          'fit': 'cover',
          'borderRadius': 0,
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.spacer:
        return {'height': 24};
      case BlockType.info:
        return {
          'title': 'Information',
          'content': '',
          'icon': 'info',
          'highlight': false,
          'actionType': 'none',
          'actionValue': '',
          'backgroundColor': '',
        };
      case BlockType.categoryList:
        return {
          'title': '',
          'mode': 'auto',
          'layout': 'horizontal',
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.html:
        return {'htmlContent': '<p>Contenu HTML</p>'};
      case BlockType.system:
        return {'moduleType': 'unknown'};
      case BlockType.module:
        return {'moduleType': 'unknown', 'moduleId': ''};
    }
  }
}

/// Helper class for system module information
class _SystemModuleInfo {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const _SystemModuleInfo({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

/// Quick add button that shows the block add dialog
class BlockAddButton extends StatelessWidget {
  final int currentBlockCount;
  final void Function(BuilderBlock block)? onBlockAdded;
  final bool extended;

  const BlockAddButton({
    super.key,
    required this.currentBlockCount,
    this.onBlockAdded,
    this.extended = true,
  });

  @override
  Widget build(BuildContext context) {
    if (extended) {
      return FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter un bloc'),
      );
    }

    return FloatingActionButton(
      onPressed: () => _showAddDialog(context),
      child: const Icon(Icons.add),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final block = await BlockAddDialog.show(
      context,
      currentBlockCount: currentBlockCount,
    );
    
    if (block != null && onBlockAdded != null) {
      onBlockAdded!(block);
    }
  }
}
