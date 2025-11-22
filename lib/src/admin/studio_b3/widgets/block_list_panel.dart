// lib/src/admin/studio_b3/widgets/block_list_panel.dart
// Left panel: List of blocks with drag & drop reordering

import 'package:flutter/material.dart';
import '../../../models/page_schema.dart';

/// Panel showing list of blocks with reordering capability
class BlockListPanel extends StatelessWidget {
  final List<WidgetBlock> blocks;
  final WidgetBlock? selectedBlock;
  final Function(WidgetBlock) onBlockSelected;
  final Function(List<WidgetBlock>) onBlocksReordered;
  final Function(WidgetBlock, bool) onBlockToggle;
  final VoidCallback onBlockAdd;
  final Function(WidgetBlock) onBlockDuplicate;
  final Function(WidgetBlock) onBlockDelete;

  const BlockListPanel({
    Key? key,
    required this.blocks,
    required this.selectedBlock,
    required this.onBlockSelected,
    required this.onBlocksReordered,
    required this.onBlockToggle,
    required this.onBlockAdd,
    required this.onBlockDuplicate,
    required this.onBlockDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: blocks.isEmpty
                ? _buildEmptyState(context)
                : _buildBlockList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Blocs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${blocks.length} bloc(s)',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onBlockAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.widgets_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Aucun bloc',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre premier bloc',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockList(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: blocks.length,
      onReorder: (oldIndex, newIndex) {
        final reorderedBlocks = List<WidgetBlock>.from(blocks);
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final item = reorderedBlocks.removeAt(oldIndex);
        reorderedBlocks.insert(newIndex, item);
        
        // Update order property
        final updatedBlocks = reorderedBlocks.asMap().entries.map((entry) {
          return entry.value.copyWith(order: entry.key + 1);
        }).toList();
        
        onBlocksReordered(updatedBlocks);
      },
      itemBuilder: (context, index) {
        final block = blocks[index];
        final isSelected = selectedBlock?.id == block.id;
        
        return _buildBlockItem(context, block, isSelected, index);
      },
    );
  }

  Widget _buildBlockItem(
    BuildContext context,
    WidgetBlock block,
    bool isSelected,
    int index,
  ) {
    return Card(
      key: ValueKey(block.id),
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.blue[50] : Colors.white,
      child: InkWell(
        onTap: () => onBlockSelected(block),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getIconForBlockType(block.type),
                    size: 20,
                    color: isSelected ? Colors.blue : Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getNameForBlockType(block.type),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[900] : Colors.black,
                      ),
                    ),
                  ),
                  Switch(
                    value: block.visible,
                    onChanged: (value) => onBlockToggle(block, value),
                    activeColor: Colors.green,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${block.id}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () => onBlockDuplicate(block),
                    tooltip: 'Dupliquer',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    onPressed: () => onBlockDelete(block),
                    tooltip: 'Supprimer',
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForBlockType(WidgetBlockType type) {
    switch (type) {
      case WidgetBlockType.text:
        return Icons.text_fields;
      case WidgetBlockType.button:
        return Icons.smart_button;
      case WidgetBlockType.image:
        return Icons.image;
      case WidgetBlockType.banner:
        return Icons.view_carousel;
      case WidgetBlockType.productList:
        return Icons.grid_view;
      case WidgetBlockType.categoryList:
        return Icons.category;
      case WidgetBlockType.heroAdvanced:
        return Icons.view_agenda;
      case WidgetBlockType.carousel:
        return Icons.view_carousel_outlined;
      case WidgetBlockType.popup:
        return Icons.notifications_active;
      case WidgetBlockType.custom:
        return Icons.extension;
    }
  }

  String _getNameForBlockType(WidgetBlockType type) {
    switch (type) {
      case WidgetBlockType.text:
        return 'Texte';
      case WidgetBlockType.button:
        return 'Bouton';
      case WidgetBlockType.image:
        return 'Image';
      case WidgetBlockType.banner:
        return 'Bannière';
      case WidgetBlockType.productList:
        return 'Produits';
      case WidgetBlockType.categoryList:
        return 'Catégories';
      case WidgetBlockType.heroAdvanced:
        return 'Hero Avancé';
      case WidgetBlockType.carousel:
        return 'Carrousel';
      case WidgetBlockType.popup:
        return 'Popup';
      case WidgetBlockType.custom:
        return 'Custom';
    }
  }
}
