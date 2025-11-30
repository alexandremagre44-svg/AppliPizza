// lib/builder/editor/widgets/builder_properties_panel.dart
// Properties panel widget for Builder B3 page editor
// Displays configuration options for pages, blocks, and navigation

import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/action_helper.dart';
import '../../utils/icon_helper.dart';
import 'icon_picker_dialog.dart';

/// Maximum characters for truncated page name in bottom nav preview
const int kMaxPageNameLength = 6;

/// Properties panel widget for page editor
/// 
/// Features:
/// - Tabbed interface (Page / Block / Navigation)
/// - Block configuration fields
/// - Navigation settings
/// - Responsive width handling
class BuilderPropertiesPanel extends StatefulWidget {
  /// The page being edited
  final BuilderPage? page;
  
  /// Currently selected block
  final BuilderBlock? selectedBlock;
  
  /// Callback when block config changes
  final void Function(String key, dynamic value)? onBlockConfigChanged;
  
  /// Callback when multiple block config values change
  final void Function(Map<String, dynamic> updates)? onBlockConfigMultipleChanged;
  
  /// Callback when block is deselected
  final VoidCallback? onBlockDeselected;
  
  /// Callback when navigation params change
  final void Function({bool? isActive, int? bottomNavIndex})? onNavigationParamsChanged;
  
  /// Callback to show icon picker
  final VoidCallback? onIconPickerRequested;
  
  /// Width of the panel
  final double? width;
  
  /// Duplicate index warning
  final String? duplicateIndexWarning;

  const BuilderPropertiesPanel({
    super.key,
    this.page,
    this.selectedBlock,
    this.onBlockConfigChanged,
    this.onBlockConfigMultipleChanged,
    this.onBlockDeselected,
    this.onNavigationParamsChanged,
    this.onIconPickerRequested,
    this.width,
    this.duplicateIndexWarning,
  });

  @override
  State<BuilderPropertiesPanel> createState() => _BuilderPropertiesPanelState();
}

class _BuilderPropertiesPanelState extends State<BuilderPropertiesPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Auto-select block tab if block is selected
    if (widget.selectedBlock != null) {
      _tabController.index = 1;
    }
  }

  @override
  void didUpdateWidget(BuilderPropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Switch to block tab when block is selected
    if (widget.selectedBlock != null && oldWidget.selectedBlock == null) {
      _tabController.animateTo(1);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header with tabs
          _buildHeader(),
          
          // Tab content with independent scroll per tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPageTab(),
                _buildBlockTab(),
                _buildNavigationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Propriétés',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          TabBar(
            controller: _tabController,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: [
              Tab(
                icon: Icon(Icons.article_outlined, size: 18),
                text: 'Page',
                height: 46,
              ),
              Tab(
                icon: Badge(
                  isLabelVisible: widget.selectedBlock != null,
                  smallSize: 8,
                  child: Icon(Icons.widgets_outlined, size: 18),
                ),
                text: 'Bloc',
                height: 46,
              ),
              Tab(
                icon: Icon(Icons.navigation_outlined, size: 18),
                text: 'Navigation',
                height: 46,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageTab() {
    if (widget.page == null) {
      return _buildEmptyState('Aucune page sélectionnée');
    }
    
    final page = widget.page!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Page info card
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getPageIcon(page),
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            page.name.isNotEmpty ? page.name : page.pageKey,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            page.route,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                // Stats
                Row(
                  children: [
                    _buildStatItem(
                      Icons.layers,
                      '${page.draftLayout.length}',
                      'Blocs',
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.public,
                      page.publishedLayout.isNotEmpty ? 'Oui' : 'Non',
                      'Publié',
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      Icons.visibility,
                      page.isActive ? 'Actif' : 'Inactif',
                      'Statut',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // System page warning
        if (page.isSystemPage)
          _buildSystemPageBanner(),
        
        const SizedBox(height: 16),
        
        // Page type info
        _buildInfoRow('Type', page.pageType.label),
        _buildInfoRow('Clé', page.pageKey),
        if (page.description.isNotEmpty)
          _buildInfoRow('Description', page.description),
        _buildInfoRow('Mis à jour', _formatDate(page.updatedAt)),
      ],
    );
  }

  Widget _buildBlockTab() {
    if (widget.selectedBlock == null) {
      return _buildEmptyState('Sélectionnez un bloc pour le configurer');
    }
    
    final block = widget.selectedBlock!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Block header
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    block.type.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          block.type.label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ordre: ${block.order}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onBlockDeselected,
                    tooltip: 'Fermer',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Configuration',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Configuration fields
          ..._buildConfigFields(block),
        ],
      ),
    );
  }

  Widget _buildNavigationTab() {
    if (widget.page == null) {
      return _buildEmptyState('Aucune page sélectionnée');
    }
    
    final page = widget.page!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active switch
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  page.isActive ? Icons.visibility : Icons.visibility_off,
                  color: page.isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Afficher dans la barre',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        page.isActive 
                            ? 'Page visible dans la navigation' 
                            : 'Page masquée',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: page.isActive,
                  onChanged: (value) {
                    widget.onNavigationParamsChanged?.call(isActive: value);
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Position selector (only if active)
        if (page.isActive) ...[
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sort,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Position (0-4)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: DropdownButton<int>(
                          value: (page.bottomNavIndex >= 0 && page.bottomNavIndex <= 4) 
                              ? page.bottomNavIndex 
                              : null,
                          hint: const Text('Choisir'),
                          underline: const SizedBox(),
                          items: List.generate(5, (i) => i).map((index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text('$index'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              widget.onNavigationParamsChanged?.call(bottomNavIndex: value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Duplicate warning
                  if (widget.duplicateIndexWarning != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, size: 16, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.duplicateIndexWarning!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Icon picker (for custom pages only)
          if (!page.isSystemPage)
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Icon(
                        _getPageIcon(page),
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Icône',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            page.icon.isEmpty ? 'Par défaut' : page.icon,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: widget.onIconPickerRequested,
                      child: const Text('Choisir'),
                    ),
                  ],
                ),
              ),
            ),
        ],
        
        const SizedBox(height: 24),
        
        // Bottom nav visualization
        _buildBottomNavPreview(page),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemPageBanner() {
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Page système protégée',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                Text(
                  'Cette page ne peut pas être supprimée',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavPreview(BuilderPage page) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu de la barre de navigation',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final isCurrentPage = page.isActive && page.bottomNavIndex == index;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCurrentPage 
                              ? Theme.of(context).colorScheme.primaryContainer 
                              : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isCurrentPage ? _getPageIcon(page) : Icons.circle_outlined,
                          size: 18,
                          color: isCurrentPage 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCurrentPage ? page.name.take(kMaxPageNameLength) : '$index',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                          color: isCurrentPage 
                              ? Theme.of(context).colorScheme.primary 
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConfigFields(BuilderBlock block) {
    switch (block.type) {
      case BlockType.hero:
        return _buildHeroConfig(block);
      case BlockType.text:
        return _buildTextConfig(block);
      case BlockType.productList:
        return _buildProductListConfig(block);
      case BlockType.banner:
        return _buildBannerConfig(block);
      case BlockType.info:
        return _buildInfoConfig(block);
      case BlockType.button:
        return _buildButtonConfig(block);
      case BlockType.image:
        return _buildImageConfig(block);
      case BlockType.spacer:
        return _buildSpacerConfig(block);
      case BlockType.categoryList:
        return _buildCategoryListConfig(block);
      case BlockType.html:
        return _buildHtmlConfig(block);
      case BlockType.system:
        return _buildSystemConfig(block);
    }
  }

  // Config field builders - simplified versions
  List<Widget> _buildHeroConfig(BuilderBlock block) {
    return [
      _buildTextField('Titre', block.getConfig<String>('title', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('title', v)),
      _buildTextField('Sous-titre', block.getConfig<String>('subtitle', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('subtitle', v)),
      _buildTextField('Label bouton', block.getConfig<String>('buttonLabel', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('buttonLabel', v)),
      _buildTextField('URL Image', block.getConfig<String>('imageUrl', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('imageUrl', v)),
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildTextConfig(BuilderBlock block) {
    return [
      _buildTextField('Contenu', block.getConfig<String>('content', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('content', v), maxLines: 4),
      _buildDropdown('Alignement', block.getConfig<String>('alignment', 'left') ?? 'left',
          ['left', 'center', 'right'], (v) => widget.onBlockConfigChanged?.call('alignment', v)),
      _buildDropdown('Taille', block.getConfig<String>('size', 'normal') ?? 'normal',
          ['small', 'normal', 'large', 'title', 'heading'], (v) => widget.onBlockConfigChanged?.call('size', v)),
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildProductListConfig(BuilderBlock block) {
    return [
      _buildTextField('Titre', block.getConfig<String>('title', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('title', v)),
      _buildDropdown('Mode', block.getConfig<String>('mode', 'featured') ?? 'featured',
          ['featured', 'manual', 'top_selling', 'promo'], (v) => widget.onBlockConfigChanged?.call('mode', v)),
      _buildDropdown('Layout', block.getConfig<String>('layout', 'grid') ?? 'grid',
          ['grid', 'carousel', 'list'], (v) => widget.onBlockConfigChanged?.call('layout', v)),
    ];
  }

  List<Widget> _buildBannerConfig(BuilderBlock block) {
    return [
      _buildTextField('Titre', block.getConfig<String>('title', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('title', v)),
      _buildTextField('Sous-titre', block.getConfig<String>('subtitle', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('subtitle', v)),
      _buildDropdown('Style', block.getConfig<String>('style', 'info') ?? 'info',
          ['info', 'promo', 'warning', 'success'], (v) => widget.onBlockConfigChanged?.call('style', v)),
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildInfoConfig(BuilderBlock block) {
    return [
      _buildTextField('Titre', block.getConfig<String>('title', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('title', v)),
      _buildTextField('Contenu', block.getConfig<String>('content', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('content', v), maxLines: 3),
      _buildDropdown('Icône', block.getConfig<String>('icon', 'info') ?? 'info',
          ['info', 'warning', 'success', 'error', 'time', 'phone', 'location', 'email'], 
          (v) => widget.onBlockConfigChanged?.call('icon', v)),
    ];
  }

  List<Widget> _buildButtonConfig(BuilderBlock block) {
    return [
      _buildTextField('Label', block.getConfig<String>('label', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('label', v)),
      _buildDropdown('Style', block.getConfig<String>('style', 'primary') ?? 'primary',
          ['primary', 'secondary', 'outline', 'text'], (v) => widget.onBlockConfigChanged?.call('style', v)),
      _buildDropdown('Alignement', block.getConfig<String>('alignment', 'center') ?? 'center',
          ['left', 'center', 'right', 'stretch'], (v) => widget.onBlockConfigChanged?.call('alignment', v)),
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildImageConfig(BuilderBlock block) {
    return [
      _buildTextField('URL Image', block.getConfig<String>('imageUrl', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('imageUrl', v)),
      _buildTextField('Légende', block.getConfig<String>('caption', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('caption', v)),
      _buildDropdown('Ajustement', block.getConfig<String>('fit', 'cover') ?? 'cover',
          ['cover', 'contain', 'fill', 'fitWidth', 'fitHeight'], 
          (v) => widget.onBlockConfigChanged?.call('fit', v)),
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildSpacerConfig(BuilderBlock block) {
    final height = block.getConfig<int>('height', 24) ?? 24;
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          initialValue: height.toString(),
          decoration: const InputDecoration(
            labelText: 'Hauteur (px)',
            border: OutlineInputBorder(),
            filled: true,
            suffixText: 'px',
          ),
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final parsed = int.tryParse(v) ?? 24;
            widget.onBlockConfigChanged?.call('height', parsed.clamp(0, 500));
          },
        ),
      ),
    ];
  }

  List<Widget> _buildCategoryListConfig(BuilderBlock block) {
    return [
      _buildTextField('Titre', block.getConfig<String>('title', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('title', v)),
      _buildDropdown('Mode', block.getConfig<String>('mode', 'auto') ?? 'auto',
          ['auto', 'custom'], (v) => widget.onBlockConfigChanged?.call('mode', v)),
      _buildDropdown('Layout', block.getConfig<String>('layout', 'horizontal') ?? 'horizontal',
          ['horizontal', 'grid', 'carousel'], (v) => widget.onBlockConfigChanged?.call('layout', v)),
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildHtmlConfig(BuilderBlock block) {
    return [
      _buildTextField('Contenu HTML', block.getConfig<String>('htmlContent', '') ?? '', 
          (v) => widget.onBlockConfigChanged?.call('htmlContent', v), maxLines: 8),
    ];
  }

  List<Widget> _buildSystemConfig(BuilderBlock block) {
    final moduleType = block.getConfig<String>('moduleType', 'unknown') ?? 'unknown';
    final moduleLabel = SystemBlock.getModuleLabel(moduleType);
    
    return [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.lock, size: 20, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Module: $moduleLabel',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  Text(
                    'Bloc système non configurable',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildTapActionFields(BuilderBlock block) {
    final tapAction = block.getConfig<String>('tapAction', 'none') ?? 'none';
    final tapActionTarget = block.getConfig<String>('tapActionTarget', '') ?? '';

    return [
      const SizedBox(height: 8),
      const Divider(),
      const SizedBox(height: 8),
      Text(
        '🔗 Action au clic',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(height: 8),
      _buildDropdown('Type d\'action', tapAction,
          ['none', 'openPage', 'openLegacyPage', 'openSystemPage', 'openUrl'], 
          (v) {
            widget.onBlockConfigMultipleChanged?.call({
              'tapAction': v,
              'tapActionTarget': '',
            });
          }),
      if (tapAction == 'openPage')
        _buildTextField('ID de la page', tapActionTarget, 
            (v) => widget.onBlockConfigChanged?.call('tapActionTarget', v)),
      if (tapAction == 'openUrl')
        _buildTextField('URL externe', tapActionTarget, 
            (v) => widget.onBlockConfigChanged?.call('tapActionTarget', v)),
    ];
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: ValueKey('${label}_$value'),
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (v) => onChanged(v ?? items.first),
      ),
    );
  }

  IconData _getPageIcon(BuilderPage page) {
    if (page.icon.isNotEmpty) {
      return IconHelper.iconFromName(page.icon);
    }
    
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Extension for String.take
extension StringTake on String {
  String take(int n) {
    if (length <= n) return this;
    return substring(0, n);
  }
}
