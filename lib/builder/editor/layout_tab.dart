// lib/builder/editor/layout_tab.dart
// Layout tab for the page editor - displays and manages blocks in draftLayout
// Part of Builder B3 modular UI layer

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../preview/preview.dart';
import 'widgets/block_list_view.dart';
import 'widgets/block_add_dialog.dart';
import '../../src/providers/restaurant_plan_provider.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';

/// Layout Tab for the Page Editor
/// 
/// Displays and manages the blocks in a page's draftLayout.
/// 
/// Features:
/// - Display blocks sorted by order
/// - Drag and drop reordering
/// - Add new blocks via dialog
/// - Delete blocks
/// - Select block for editing
/// - Auto-save after changes
/// - Optional live preview panel
/// - Restaurant plan integration for module filtering
class LayoutTab extends ConsumerStatefulWidget {
  /// The page being edited
  final BuilderPage page;
  
  /// Called when the page is updated
  final void Function(BuilderPage updatedPage)? onPageUpdated;
  
  /// Called when a block is selected for editing
  final void Function(BuilderBlock block)? onBlockSelected;
  
  /// Currently selected block ID
  final String? selectedBlockId;
  
  /// Whether to show the preview panel alongside the list
  final bool showPreviewPanel;
  
  /// Whether changes should be auto-saved
  final bool autoSave;

  const LayoutTab({
    super.key,
    required this.page,
    this.onPageUpdated,
    this.onBlockSelected,
    this.selectedBlockId,
    this.showPreviewPanel = false,
    this.autoSave = true,
  });

  @override
  ConsumerState<LayoutTab> createState() => _LayoutTabState();
}

class _LayoutTabState extends ConsumerState<LayoutTab> {
  final BuilderLayoutService _service = BuilderLayoutService();
  late BuilderPage _page;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _page = widget.page;
  }

  @override
  void didUpdateWidget(LayoutTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.page != oldWidget.page) {
      _page = widget.page;
    }
  }

  /// Get sorted blocks from draftLayout
  List<BuilderBlock> get _sortedBlocks {
    final blocks = List<BuilderBlock>.from(_page.draftLayout);
    blocks.sort((a, b) => a.order.compareTo(b.order));
    return blocks;
  }

  /// Save draft to Firestore
  Future<void> _saveDraft() async {
    if (!widget.autoSave || _isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      await _service.saveDraft(_page);
      debugPrint('✅ [LayoutTab] Draft saved');
    } catch (e) {
      debugPrint('❌ [LayoutTab] Save failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de sauvegarde: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Update page and notify parent
  void _updatePage(BuilderPage updatedPage) {
    setState(() {
      _page = updatedPage;
    });
    widget.onPageUpdated?.call(updatedPage);
    _saveDraft();
  }

  /// Handle block reorder
  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final blocks = _sortedBlocks;
    final block = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, block);

    final blockIds = blocks.map((b) => b.id).toList();
    final updatedPage = _page.reorderBlocks(blockIds);
    
    _updatePage(updatedPage);
  }

  /// Handle block tap (select for editing)
  void _onBlockTap(BuilderBlock block) {
    widget.onBlockSelected?.call(block);
  }

  /// Handle block delete
  void _onBlockDelete(BuilderBlock block) {
    final updatedPage = _page.removeBlock(block.id);
    _updatePage(updatedPage);
  }

  /// Get the current restaurant plan from the provider
  /// 
  /// This is used to pass the plan to dialogs without triggering rebuilds.
  /// Returns null if the plan is still loading or in error state.
  RestaurantPlanUnified? _getCurrentPlan() {
    final async = ref.read(restaurantPlanUnifiedProvider);
    return async.maybeWhen(
      data: (p) => p,
      orElse: () => null,
    );
  }

  /// Handle add block
  Future<void> _showAddBlockDialog() async {
    // Get the current plan to pass to the dialog
    final plan = _getCurrentPlan();
    
    final newBlock = await BlockAddDialog.show(
      context,
      currentBlockCount: _page.draftLayout.length,
      restaurantPlan: plan,
    );
    
    if (newBlock != null) {
      final updatedPage = _page.addBlock(newBlock);
      _updatePage(updatedPage);
      widget.onBlockSelected?.call(newBlock);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showPreviewPanel) {
      return Row(
        children: [
          // Blocks list
          Expanded(
            flex: 2,
            child: _buildContent(),
          ),
          // Preview panel
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.visibility, size: 18),
                        const SizedBox(width: 8),
                        const Text(
                          'Prévisualisation',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        if (_isSaving)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BuilderPagePreview(
                      blocks: _sortedBlocks,
                      modules: _page.modules,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _buildContent();
  }

  Widget _buildContent() {
    return Stack(
      children: [
        Column(
          children: [
            // Header with page info
            _buildHeader(),
            // System page banner (if applicable)
            if (_page.isSystemPage) _buildSystemPageBanner(),
            // Blocks list
            Expanded(
              child: BlockListView(
                blocks: _sortedBlocks,
                selectedBlockId: widget.selectedBlockId,
                onReorder: _onReorder,
                onBlockTap: _onBlockTap,
                onBlockEdit: _onBlockTap,
                onBlockDelete: _onBlockDelete,
                emptyMessage: 'Aucun bloc sur cette page.\nAppuyez sur + pour ajouter du contenu.',
              ),
            ),
          ],
        ),
        // Add button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _showAddBlockDialog,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un bloc'),
          ),
        ),
        // Saving indicator
        if (_isSaving)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Sauvegarde...', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers,
            color: Colors.grey.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Layout: ${_page.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${_sortedBlocks.length} bloc(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (_page.hasUnpublishedChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Modifications non publiées',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemPageBanner() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.shield, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Page système protégée',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          Tooltip(
            message: 'Cette page ne peut pas être supprimée.\nVous pouvez modifier les blocs.',
            child: Icon(Icons.info_outline, color: Colors.blue.shade400, size: 18),
          ),
        ],
      ),
    );
  }
}

/// Compact layout tab for mobile or constrained spaces
class LayoutTabCompact extends StatelessWidget {
  final BuilderPage page;
  final void Function(BuilderPage updatedPage)? onPageUpdated;
  final void Function(BuilderBlock block)? onBlockSelected;
  final String? selectedBlockId;

  const LayoutTabCompact({
    super.key,
    required this.page,
    this.onPageUpdated,
    this.onBlockSelected,
    this.selectedBlockId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutTab(
      page: page,
      onPageUpdated: onPageUpdated,
      onBlockSelected: onBlockSelected,
      selectedBlockId: selectedBlockId,
      showPreviewPanel: false,
      autoSave: true,
    );
  }
}
