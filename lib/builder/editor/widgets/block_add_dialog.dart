// lib/builder/editor/widgets/block_add_dialog.dart
// Dialog for adding new blocks to a page
// Part of Builder B3 modular UI layer

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../../src/providers/restaurant_plan_provider.dart';
import '../../../white_label/restaurant/restaurant_plan_unified.dart';

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
///   - Falls back to showing all modules if plan is not loaded
class BlockAddDialog extends ConsumerWidget {
  /// Current number of blocks (used for order calculation)
  final int currentBlockCount;
  
  /// Optional filter for available block types
  final List<BlockType>? allowedTypes;
  
  /// Whether to show system modules section
  final bool showSystemModules;

  const BlockAddDialog({
    super.key,
    required this.currentBlockCount,
    this.allowedTypes,
    this.showSystemModules = true,
  });

  /// Show the dialog and return the created block
  static Future<BuilderBlock?> show(
    BuildContext context, {
    required int currentBlockCount,
    List<BlockType>? allowedTypes,
    bool showSystemModules = true,
  }) {
    return showDialog<BuilderBlock>(
      context: context,
      builder: (context) => BlockAddDialog(
        currentBlockCount: currentBlockCount,
        allowedTypes: allowedTypes,
        showSystemModules: showSystemModules,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get restaurant plan for filtering modules
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    
    // DEBUG: Log plan loading state
    if (kDebugMode) {
      debugPrint('🔍 [BlockAddDialog] planAsync state:');
      planAsync.when(
        loading: () => debugPrint('  ⏳ loading...'),
        error: (e, _) => debugPrint('  ❌ error: $e'),
        data: (plan) {
          if (plan == null) {
            debugPrint('  ⚠️ data: plan is null → fallback (show all modules)');
          } else {
            final activeModules = plan.activeModules.map((m) => m.code).join(', ');
            debugPrint('  ✅ data: plan loaded with ${plan.activeModules.length} modules: $activeModules');
          }
        },
      );
    }
    
    // Use .when() to properly handle loading/error/data states
    return planAsync.when(
      loading: () {
        debugPrint('📦 [BlockAddDialog] Displaying loading dialog');
        return _buildLoadingDialog(context);
      },
      error: (e, _) {
        debugPrint('⚠️ [BlockAddDialog] Error loading plan, fallback to all modules: $e');
        return _buildDialogContent(context, null); // Fallback: show all modules
      },
      data: (plan) {
        if (plan == null) {
          debugPrint('⚠️ [BlockAddDialog] Plan is null, fallback to all modules');
        } else {
          debugPrint('✅ [BlockAddDialog] Plan loaded successfully');
        }
        return _buildDialogContent(context, plan);
      },
    );
  }

  /// Build loading dialog
  Widget _buildLoadingDialog(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_box, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          const Text('Ajouter un bloc'),
        ],
      ),
      content: const SizedBox(
        height: 100,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement du plan...'),
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

  /// Build dialog content with plan data (or null for fallback)
  Widget _buildDialogContent(BuildContext context, RestaurantPlanUnified? plan) {
    // Filter out system type from regular blocks
    final regularBlocks = (allowedTypes ?? BlockType.values)
        .where((t) => t != BlockType.system)
        .toList();
    
    // DEBUG: Log filtering
    if (kDebugMode && plan != null) {
      debugPrint('🔍 [BlockAddDialog] Filtering modules for plan ${plan.restaurantId}');
      debugPrint('   Active modules: ${plan.activeModules.map((m) => m.code).join(", ")}');
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
                Colors.grey,
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
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
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
    final allModules = [
      _SystemModuleInfo(
        id: 'cart_module',
        label: 'Panier',
        description: 'Panier et validation',
        icon: Icons.shopping_cart,
        color: Colors.green,
      ),
      _SystemModuleInfo(
        id: 'roulette',
        label: 'Roulette',
        description: 'Roue de la chance',
        icon: Icons.casino,
        color: Colors.purple,
      ),
      _SystemModuleInfo(
        id: 'loyalty',
        label: 'Fidélité',
        description: 'Points et progression',
        icon: Icons.card_giftcard,
        color: Colors.amber,
      ),
      _SystemModuleInfo(
        id: 'rewards',
        label: 'Récompenses',
        description: 'Tickets et bons',
        icon: Icons.stars,
        color: Colors.orange,
      ),
      _SystemModuleInfo(
        id: 'accountActivity',
        label: 'Activité du compte',
        description: 'Commandes et favoris',
        icon: Icons.history,
        color: Colors.blue,
      ),
    ];

    // Filter modules based on restaurant plan
    // Use SystemBlock.getFilteredModules() to get available modules for this plan
    final availableModuleIds = SystemBlock.getFilteredModules(plan);
    final filteredModules = allModules.where((module) {
      return availableModuleIds.contains(module.id);
    }).toList();
    
    // DEBUG: Log filtered modules
    if (kDebugMode) {
      debugPrint('   Available module IDs: ${availableModuleIds.join(", ")}');
      debugPrint('   Filtered modules: ${filteredModules.map((m) => m.id).join(", ")}');
    }

    return Column(
      children: [
        // Show warning if plan is null
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
                    'Plan non chargé → tous les modules affichés (fallback)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade900,
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
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
    final newBlock = SystemBlock(
      id: 'block_${DateTime.now().millisecondsSinceEpoch}',
      moduleType: moduleType,
      order: currentBlockCount,
    );
    Navigator.pop(context, newBlock);
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
