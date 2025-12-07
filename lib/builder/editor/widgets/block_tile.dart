// lib/builder/editor/widgets/block_tile.dart
// Reusable block tile widget for displaying a block in the editor list
// Part of Builder B3 modular UI layer

import 'package:flutter/material.dart';
import '../../models/models.dart';

/// A card-style tile representing a single block in the editor
/// 
/// Features:
/// - Block type icon and label
/// - Summary text (content preview)
/// - Drag handle for reordering
/// - Edit and delete buttons
/// - Selection highlight
class BlockTile extends StatelessWidget {
  /// The block to display
  final BuilderBlock block;
  
  /// Whether this block is currently selected
  final bool isSelected;
  
  /// Called when the tile is tapped
  final VoidCallback? onTap;
  
  /// Called when the edit button is pressed
  final VoidCallback? onEdit;
  
  /// Called when the delete button is pressed
  final VoidCallback? onDelete;
  
  /// Whether to show the drag handle (for reorderable lists)
  final bool showDragHandle;
  
  /// Whether to enable delete action
  final bool canDelete;

  const BlockTile({
    super.key,
    required this.block,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showDragHandle = true,
    this.canDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isSelected ? Colors.blue.shade50 : null,
      elevation: isSelected ? 4 : 1,
      child: ListTile(
        leading: _buildLeadingIcon(),
        title: Text(
          block.type.label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          _getBlockSummary(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: _buildTrailingActions(),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLeadingIcon() {
    // For system blocks, show a special icon
    if (block.type == BlockType.system) {
      final moduleType = block.getConfig<String>('moduleType', 'unknown') ?? 'unknown';
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            SystemBlock.getModuleIcon(moduleType),
            size: 20,
            color: Colors.blue.shade700,
          ),
        ),
      );
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          block.type.icon,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildTrailingActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEdit,
            tooltip: 'Modifier',
          ),
        if (canDelete && onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            onPressed: onDelete,
            tooltip: 'Supprimer',
          ),
        if (showDragHandle)
          const Icon(Icons.drag_handle, color: Colors.grey),
      ],
    );
  }

  String _getBlockSummary() {
    switch (block.type) {
      case BlockType.hero:
        return block.getConfig<String>('title', 'Sans titre') ?? 'Sans titre';
      case BlockType.text:
        final content = block.getConfig<String>('content', '') ?? '';
        return content.length > 50 ? '${content.substring(0, 50)}...' : content;
      case BlockType.productList:
        final mode = block.getConfig<String>('mode', 'featured') ?? 'featured';
        final limit = block.getConfig<int>('limit', 6) ?? 6;
        return 'Mode: $mode • Max: $limit produits';
      case BlockType.banner:
        return block.getConfig<String>('title', 'Bannière') ?? 'Bannière';
      case BlockType.button:
        return block.getConfig<String>('label', 'Bouton') ?? 'Bouton';
      case BlockType.image:
        final url = block.getConfig<String>('imageUrl', '') ?? '';
        return url.isNotEmpty ? 'Image configurée' : 'Aucune image';
      case BlockType.spacer:
        final height = block.getConfig<int>('height', 24) ?? 24;
        return 'Hauteur: ${height}px';
      case BlockType.info:
        return block.getConfig<String>('title', 'Information') ?? 'Information';
      case BlockType.categoryList:
        final layout = block.getConfig<String>('layout', 'horizontal') ?? 'horizontal';
        return 'Layout: $layout';
      case BlockType.html:
        return 'Contenu HTML personnalisé';
      case BlockType.system:
        final moduleType = block.getConfig<String>('moduleType', 'unknown') ?? 'unknown';
        return 'Module: ${SystemBlock.getModuleLabel(moduleType)}';
      case BlockType.module:
        final moduleType = block.getConfig<String>('moduleType', 'unknown') ?? 'unknown';
        return 'Module WL: ${SystemBlock.getModuleLabel(moduleType)}';
    }
  }
}

/// Compact version of BlockTile for mobile or constrained layouts
class BlockTileCompact extends StatelessWidget {
  final BuilderBlock block;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BlockTileCompact({
    super.key,
    required this.block,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Text(block.type.icon, style: const TextStyle(fontSize: 18)),
        title: Text(
          block.type.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            const SizedBox(width: 8),
            const Icon(Icons.drag_handle, size: 18, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
