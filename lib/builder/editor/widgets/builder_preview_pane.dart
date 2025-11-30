// lib/builder/editor/widgets/builder_preview_pane.dart
// Preview pane widget for Builder B3 page editor
// Displays page preview with draft/published toggle

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../preview/preview.dart';

/// Preview pane widget for page editor
/// 
/// Features:
/// - Toggle between draft and published preview
/// - Full screen preview button
/// - Responsive sizing
/// - Empty state handling
class BuilderPreviewPane extends StatefulWidget {
  /// The page to preview
  final BuilderPage? page;
  
  /// Page title for full screen preview
  final String? pageTitle;
  
  /// Whether to show header
  final bool showHeader;
  
  /// Callback for full screen
  final VoidCallback? onFullScreen;

  const BuilderPreviewPane({
    super.key,
    this.page,
    this.pageTitle,
    this.showHeader = true,
    this.onFullScreen,
  });

  @override
  State<BuilderPreviewPane> createState() => _BuilderPreviewPaneState();
}

class _BuilderPreviewPaneState extends State<BuilderPreviewPane> {
  bool _showDraft = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          if (widget.showHeader) _buildHeader(),
          
          // Preview content with proper padding
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.page != null
                  ? _buildPreview()
                  : _buildEmptyState(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Prévisualisation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Draft/Published toggle
          if (widget.page != null)
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Brouillon', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.edit_note, size: 16),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Publié', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.public, size: 16),
                ),
              ],
              selected: {_showDraft},
              onSelectionChanged: (selection) {
                setState(() => _showDraft = selection.first);
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          const SizedBox(width: 8),
          // Full screen button
          IconButton(
            icon: const Icon(Icons.fullscreen, size: 20),
            onPressed: _showFullScreen,
            tooltip: 'Plein écran',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final page = widget.page!;
    
    // Choose layout based on toggle
    final List<BuilderBlock> layout;
    if (_showDraft) {
      layout = page.draftLayout.isNotEmpty 
          ? page.draftLayout 
          : page.publishedLayout;
    } else {
      layout = page.publishedLayout.isNotEmpty 
          ? page.publishedLayout 
          : page.draftLayout;
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: BuilderPagePreview(
        blocks: layout,
        modules: page.modules,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.preview_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Sélectionnez une page pour voir la prévisualisation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez une page dans la liste à gauche',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreen() {
    if (widget.page == null) return;
    
    if (widget.onFullScreen != null) {
      widget.onFullScreen!();
    } else {
      final page = widget.page!;
      final List<BuilderBlock> layout;
      if (_showDraft) {
        layout = page.draftLayout.isNotEmpty 
            ? page.draftLayout 
            : page.publishedLayout;
      } else {
        layout = page.publishedLayout.isNotEmpty 
            ? page.publishedLayout 
            : page.draftLayout;
      }

      BuilderFullScreenPreview.show(
        context,
        blocks: layout,
        modules: page.modules,
        pageTitle: widget.pageTitle ?? page.name,
      );
    }
  }
}
