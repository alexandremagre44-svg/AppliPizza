// lib/builder/editor/widgets/block_list_view.dart
// Reusable block list view widget with reordering support
// Part of Builder B3 modular UI layer

import 'package:flutter/material.dart';
import '../../models/models.dart';
import 'block_tile.dart';

/// A reorderable list view of blocks
/// 
/// Features:
/// - Drag and drop reordering
/// - Block selection
/// - Edit and delete actions
/// - Empty state
/// - Optional header widget
class BlockListView extends StatelessWidget {
  /// List of blocks to display (should be sorted by order)
  final List<BuilderBlock> blocks;
  
  /// Currently selected block ID
  final String? selectedBlockId;
  
  /// Called when blocks are reordered
  final void Function(int oldIndex, int newIndex)? onReorder;
  
  /// Called when a block is tapped
  final void Function(BuilderBlock block)? onBlockTap;
  
  /// Called when edit is requested for a block
  final void Function(BuilderBlock block)? onBlockEdit;
  
  /// Called when delete is requested for a block
  final void Function(BuilderBlock block)? onBlockDelete;
  
  /// Optional header widget to show above the list
  final Widget? header;
  
  /// Whether the list is currently loading
  final bool isLoading;
  
  /// Message to show when list is empty
  final String emptyMessage;
  
  /// Use compact tile style
  final bool compact;

  const BlockListView({
    super.key,
    required this.blocks,
    this.selectedBlockId,
    this.onReorder,
    this.onBlockTap,
    this.onBlockEdit,
    this.onBlockDelete,
    this.header,
    this.isLoading = false,
    this.emptyMessage = 'Aucun bloc.\nAppuyez sur + pour en ajouter.',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (header != null) header!,
        Expanded(
          child: blocks.isEmpty
              ? _buildEmptyState()
              : _buildBlockList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockList() {
    if (onReorder != null) {
      return ReorderableListView.builder(
        onReorder: onReorder!,
        itemCount: blocks.length,
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          final block = blocks[index];
          return _buildBlockTile(block, index);
        },
      );
    }

    return ListView.builder(
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        return _buildBlockTile(block, index);
      },
    );
  }

  Widget _buildBlockTile(BuilderBlock block, int index) {
    final isSelected = block.id == selectedBlockId;
    
    if (compact) {
      return ReorderableDragStartListener(
        key: ValueKey(block.id),
        index: index,
        child: BlockTileCompact(
          block: block,
          isSelected: isSelected,
          onTap: onBlockTap != null ? () => onBlockTap!(block) : null,
          onDelete: onBlockDelete != null ? () => onBlockDelete!(block) : null,
        ),
      );
    }

    return ReorderableDragStartListener(
      key: ValueKey(block.id),
      index: index,
      child: BlockTile(
        block: block,
        isSelected: isSelected,
        onTap: onBlockTap != null ? () => onBlockTap!(block) : null,
        onEdit: onBlockEdit != null ? () => onBlockEdit!(block) : null,
        onDelete: onBlockDelete != null ? () => onBlockDelete!(block) : null,
        showDragHandle: onReorder != null,
        canDelete: true,
      ),
    );
  }
}

/// A simplified block list without reordering
class SimpleBlockList extends StatelessWidget {
  final List<BuilderBlock> blocks;
  final String? selectedBlockId;
  final void Function(BuilderBlock block)? onBlockTap;
  final void Function(BuilderBlock block)? onBlockDelete;

  const SimpleBlockList({
    super.key,
    required this.blocks,
    this.selectedBlockId,
    this.onBlockTap,
    this.onBlockDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return Center(
        child: Text(
          'Aucun bloc',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        return BlockTileCompact(
          key: ValueKey(block.id),
          block: block,
          isSelected: block.id == selectedBlockId,
          onTap: onBlockTap != null ? () => onBlockTap!(block) : null,
          onDelete: onBlockDelete != null ? () => onBlockDelete!(block) : null,
        );
      },
    );
  }
}
