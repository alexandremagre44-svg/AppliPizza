// lib/builder/editor/widgets/builder_page_sidebar.dart
// Sidebar widget for Builder B3 page list
// Shows system and custom pages with status indicators

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/icon_helper.dart';

/// Sidebar widget displaying the list of pages
/// 
/// Features:
/// - Shows system pages and custom pages separately
/// - Status indicators (active, draft, published)
/// - Button to add new pages
/// - Page selection callback
class BuilderPageSidebar extends StatefulWidget {
  /// Application ID
  final String appId;
  
  /// Currently selected page key
  final String? selectedPageKey;
  
  /// Callback when a page is selected
  final void Function(BuilderPage page)? onPageSelected;
  
  /// Callback to create a new page
  final VoidCallback? onCreatePage;
  
  /// Width of the sidebar (for desktop)
  final double? width;
  
  /// Whether to show as a compact version (for mobile/tablet)
  final bool compact;

  const BuilderPageSidebar({
    super.key,
    required this.appId,
    this.selectedPageKey,
    this.onPageSelected,
    this.onCreatePage,
    this.width,
    this.compact = false,
  });

  @override
  State<BuilderPageSidebar> createState() => _BuilderPageSidebarState();
}

class _BuilderPageSidebarState extends State<BuilderPageSidebar> {
  final BuilderLayoutService _layoutService = BuilderLayoutService();
  
  List<BuilderPage> _allPages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all draft pages
      final draftPages = await _layoutService.loadAllDraftPages(widget.appId);
      final publishedPages = await _layoutService.loadAllPublishedPages(widget.appId);
      
      // Merge pages - prefer draft if exists
      final mergedPages = <String, BuilderPage>{};
      
      for (final entry in publishedPages.entries) {
        mergedPages[entry.key] = entry.value;
      }
      
      for (final entry in draftPages.entries) {
        mergedPages[entry.key] = entry.value;
      }
      
      setState(() {
        _allPages = mergedPages.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<BuilderPage> get _systemPages {
    return _allPages
        .where((p) => p.isSystemPage)
        .toList()
      ..sort((a, b) => a.bottomNavIndex.compareTo(b.bottomNavIndex));
  }

  List<BuilderPage> get _customPages {
    return _allPages
        .where((p) => !p.isSystemPage)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactView();
    }
    
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : _buildPagesList(),
          ),
          
          // Add button
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Pages',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh, size: 18),
            onPressed: _loadPages,
            tooltip: 'Actualiser',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadPages,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagesList() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // System pages section
        if (_systemPages.isNotEmpty) ...[
          _buildSectionTitle('Pages système', Icons.lock_outline),
          ..._systemPages.map(_buildPageTile),
          const SizedBox(height: 16),
        ],
        
        // Custom pages section
        _buildSectionTitle('Pages personnalisées', Icons.edit_note),
        if (_customPages.isEmpty)
          _buildEmptyState()
        else
          ..._customPages.map(_buildPageTile),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTile(BuilderPage page) {
    final isSelected = page.pageKey == widget.selectedPageKey;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => widget.onPageSelected?.call(page),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                        : Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getPageIcon(page),
                    size: 18,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
                // Name and indicators
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.name.isNotEmpty ? page.name : page.pageKey,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          // Status indicators
                          _buildStatusIndicator(page),
                        ],
                      ),
                    ],
                  ),
                ),
                // Navigation indicator
                if (isSelected)
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuilderPage page) {
    final indicators = <Widget>[];
    
    // Active status
    if (page.isActive) {
      indicators.add(_buildIndicatorChip(
        'Actif',
        Colors.green,
      ));
    }
    
    // Draft indicator
    if (page.draftLayout.isNotEmpty && page.hasUnpublishedChanges) {
      indicators.add(_buildIndicatorChip(
        'Brouillon',
        Colors.orange,
      ));
    }
    
    // Published indicator
    if (page.publishedLayout.isNotEmpty) {
      indicators.add(_buildIndicatorChip(
        'Publié',
        Colors.blue,
      ));
    }
    
    if (indicators.isEmpty) {
      return Text(
        'Non publié',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    }
    
    return Wrap(
      spacing: 4,
      children: indicators,
    );
  }

  Widget _buildIndicatorChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune page personnalisée',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: FilledButton.icon(
        onPressed: widget.onCreatePage,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Nouvelle page'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(42),
        ),
      ),
    );
  }

  Widget _buildCompactView() {
    // Compact dropdown for mobile/tablet
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _isLoading
                ? const LinearProgressIndicator()
                : DropdownButton<String>(
                    value: widget.selectedPageKey,
                    hint: const Text('Sélectionner une page'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _allPages.map((page) {
                      return DropdownMenuItem<String>(
                        value: page.pageKey,
                        child: Row(
                          children: [
                            Icon(
                              _getPageIcon(page),
                              size: 18,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                page.name.isNotEmpty ? page.name : page.pageKey,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (page.isActive)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (pageKey) {
                      if (pageKey != null) {
                        final page = _allPages.firstWhere((p) => p.pageKey == pageKey);
                        widget.onPageSelected?.call(page);
                      }
                    },
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: widget.onCreatePage,
            tooltip: 'Nouvelle page',
          ),
        ],
      ),
    );
  }

  IconData _getPageIcon(BuilderPage page) {
    if (page.icon.isNotEmpty) {
      return IconHelper.iconFromName(page.icon);
    }
    
    // Default icons based on page type
    if (page.isSystemPage) {
      final sysId = page.systemId;
      if (sysId != null) {
        switch (sysId) {
          case BuilderPageId.profile:
            return Icons.person;
          case BuilderPageId.cart:
            return Icons.shopping_cart;
          case BuilderPageId.rewards:
            return Icons.card_giftcard;
          case BuilderPageId.roulette:
            return Icons.casino;
          default:
            return Icons.article;
        }
      }
    }
    
    return Icons.article;
  }
}
