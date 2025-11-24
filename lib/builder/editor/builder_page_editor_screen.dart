// lib/builder/editor/builder_page_editor_screen.dart
// Page editor screen for Builder B3 system
// MOBILE RESPONSIVE: Adapts layout for mobile (<600px), tablet, and desktop

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../preview/preview.dart';
import '../utils/responsive.dart';

/// Builder Page Editor Screen
/// 
/// Allows editing a page's blocks with:
/// - Load draft page
/// - Display block list
/// - Add/remove blocks
/// - Reorder blocks (drag & drop)
/// - Edit block configuration
/// - Preview page (tab view or full-screen)
class BuilderPageEditorScreen extends StatefulWidget {
  final String appId;
  final BuilderPageId pageId;

  const BuilderPageEditorScreen({
    super.key,
    required this.appId,
    required this.pageId,
  });

  @override
  State<BuilderPageEditorScreen> createState() => _BuilderPageEditorScreenState();
}

class _BuilderPageEditorScreenState extends State<BuilderPageEditorScreen> with SingleTickerProviderStateMixin {
  final BuilderLayoutService _service = BuilderLayoutService();
  BuilderPage? _page;
  bool _isLoading = true;
  BuilderBlock? _selectedBlock;
  bool _hasChanges = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPage() async {
    setState(() => _isLoading = true);

    try {
      // Load draft, or create default if none exists
      var page = await _service.loadDraft(widget.appId, widget.pageId);
      
      if (page == null) {
        page = await _service.createDefaultPage(
          widget.appId,
          widget.pageId,
          isDraft: true,
        );
      }

      setState(() {
        _page = page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  Future<void> _saveDraft() async {
    if (_page == null) return;

    try {
      await _service.saveDraft(_page!);
      setState(() => _hasChanges = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Brouillon sauvegardé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e')),
        );
      }
    }
  }

  Future<void> _publishPage() async {
    if (_page == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publier la page'),
        content: const Text('Voulez-vous publier cette page ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publier'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.publishPage(
        _page!,
        userId: 'admin', // TODO: Get from auth
        shouldDeleteDraft: false,
      );
      
      setState(() => _hasChanges = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Page publiée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e')),
        );
      }
    }
  }

  void _addBlock(BlockType type) {
    if (_page == null) return;

    final newBlock = BuilderBlock(
      id: 'block_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      order: _page!.blocks.length,
      config: _getDefaultConfig(type),
    );

    setState(() {
      _page = _page!.addBlock(newBlock);
      _hasChanges = true;
      _selectedBlock = newBlock;
    });
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
        };
      case BlockType.text:
        return {
          'content': 'Nouveau texte',
          'alignment': 'left',
          'size': 'normal',
        };
      case BlockType.productList:
        return {
          'mode': 'featured',
          'productIds': '',
          'layout': 'grid',
          'limit': 6,
        };
      case BlockType.banner:
        return {
          'text': 'Nouvelle bannière',
          'backgroundColor': '#2196F3',
          'textColor': '#FFFFFF',
        };
      default:
        return {};
    }
  }

  void _removeBlock(String blockId) {
    if (_page == null) return;

    setState(() {
      _page = _page!.removeBlock(blockId);
      _hasChanges = true;
      if (_selectedBlock?.id == blockId) {
        _selectedBlock = null;
      }
    });
  }

  void _reorderBlocks(int oldIndex, int newIndex) {
    if (_page == null) return;

    // Adjust index for removal
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final blocks = _page!.sortedBlocks;
    final block = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, block);

    final blockIds = blocks.map((b) => b.id).toList();

    setState(() {
      _page = _page!.reorderBlocks(blockIds);
      _hasChanges = true;
    });
  }

  void _selectBlock(BuilderBlock block) {
    setState(() {
      _selectedBlock = block;
    });
  }

  void _updateBlockConfig(String key, dynamic value) {
    if (_page == null || _selectedBlock == null) return;

    final updatedBlock = _selectedBlock!.updateConfig(key, value);

    setState(() {
      _page = _page!.updateBlock(updatedBlock);
      _selectedBlock = updatedBlock;
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveBuilder(constraints.maxWidth);
        
        return Scaffold(
          appBar: AppBar(
            title: Text(responsive.isMobile 
              ? widget.pageId.label 
              : 'Éditeur: ${widget.pageId.label}'
            ),
            bottom: responsive.isMobile 
              ? null // No tabs on mobile - use bottom sheet instead
              : TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(icon: Icon(Icons.edit), text: 'Édition'),
                    Tab(icon: Icon(Icons.visibility), text: 'Prévisualisation'),
                  ],
                ),
            actions: [
              if (_hasChanges)
                IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: 'Sauvegarder',
                  onPressed: _saveDraft,
                ),
              if (!responsive.isMobile)
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  tooltip: 'Prévisualisation plein écran',
                  onPressed: _showFullScreenPreview,
                ),
              IconButton(
                icon: const Icon(Icons.publish),
                tooltip: 'Publier',
                onPressed: _publishPage,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _page == null
                  ? const Center(child: Text('Impossible de charger la page'))
                  : responsive.isMobile
                      ? _buildMobileLayout()
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildEditorTab(responsive),
                            _buildPreviewTab(),
                          ],
                        ),
          floatingActionButton: (_tabController.index == 0 || responsive.isMobile)
              ? FloatingActionButton.extended(
                  onPressed: _showAddBlockDialog,
                  icon: const Icon(Icons.add),
                  label: Text(responsive.isMobile ? 'Bloc' : 'Ajouter un bloc'),
                )
              : null,
        );
      },
    );
  }

  Widget _buildEditorTab(ResponsiveBuilder responsive) {
    return Row(
      children: [
        // Blocks list (left side)
        Expanded(
          flex: 2,
          child: _buildBlocksList(),
        ),
        // Configuration panel (right side) - only on desktop/tablet
        if (_selectedBlock != null && responsive.isNotMobile)
          Expanded(
            flex: 1,
            child: _buildConfigPanel(),
          ),
      ],
    );
  }

  /// Mobile layout with preview on top and editor panel in bottom sheet
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Preview (full screen with padding for bottom sheet)
        Positioned.fill(
          bottom: _selectedBlock != null ? 60 : 0,
          child: _buildPreviewTab(),
        ),
        // Floating editor panel button (when block is selected)
        if (_selectedBlock != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: SafeArea(
                top: false,
                child: ListTile(
                  leading: Text(
                    _selectedBlock!.type.icon,
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  title: Text(
                    _selectedBlock!.type.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Tapez pour configurer',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => _showMobileEditorSheet(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _selectedBlock = null),
                      ),
                    ],
                  ),
                  onTap: () => _showMobileEditorSheet(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Show mobile editor sheet with block configuration
  void _showMobileEditorSheet() {
    if (_selectedBlock == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        _selectedBlock!.type.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedBlock!.type.label,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Configuration fields (scrollable)
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildConfigFields(_selectedBlock!),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewTab() {
    if (_page == null) {
      return const Center(child: Text('Aucune page à prévisualiser'));
    }

    return BuilderPagePreview(blocks: _page!.blocks);
  }

  void _showFullScreenPreview() {
    if (_page == null) return;

    BuilderFullScreenPreview.show(
      context,
      blocks: _page!.blocks,
      pageTitle: widget.pageId.label,
    );
  }

  Widget _buildBlocksList() {
    final blocks = _page!.sortedBlocks;

    if (blocks.isEmpty) {
      return const Center(
        child: Text(
          'Aucun bloc.\nAppuyez sur + pour en ajouter.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ReorderableListView.builder(
      onReorder: _reorderBlocks,
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        final isSelected = _selectedBlock?.id == block.id;

        return Card(
          key: ValueKey(block.id),
          margin: const EdgeInsets.all(8),
          color: isSelected ? Colors.blue.shade50 : null,
          elevation: isSelected ? 4 : 1,
          child: ListTile(
            leading: Text(
              block.type.icon,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(
              block.type.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(_getBlockSummary(block)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeBlock(block.id),
                ),
                const Icon(Icons.drag_handle),
              ],
            ),
            onTap: () => _selectBlock(block),
          ),
        );
      },
    );
  }

  String _getBlockSummary(BuilderBlock block) {
    switch (block.type) {
      case BlockType.hero:
        return block.getConfig<String>('title', 'Sans titre') ?? 'Sans titre';
      case BlockType.text:
        final content = block.getConfig<String>('content', '') ?? '';
        return content.length > 40 ? '${content.substring(0, 40)}...' : content;
      case BlockType.productList:
        final ids = block.getConfig<List>('productIds', []) ?? [];
        return '${ids.length} produit(s)';
      case BlockType.banner:
        return block.getConfig<String>('text', 'Bannière') ?? 'Bannière';
      default:
        return 'Bloc ${block.type.value}';
    }
  }

  Widget _buildConfigPanel() {
    final block = _selectedBlock!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  block.type.icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    block.type.label,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedBlock = null),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              'Configuration',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildConfigFields(block),
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
      default:
        return [const Text('Configuration non disponible pour ce type')];
    }
  }

  List<Widget> _buildHeroConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Titre',
        value: block.getConfig<String>('title', '') ?? '',
        onChanged: (v) => _updateBlockConfig('title', v),
        helperText: 'Titre principal du hero banner',
      ),
      _buildTextField(
        label: 'Sous-titre',
        value: block.getConfig<String>('subtitle', '') ?? '',
        onChanged: (v) => _updateBlockConfig('subtitle', v),
        helperText: 'Texte secondaire (optionnel)',
      ),
      _buildTextField(
        label: 'Label du bouton',
        value: block.getConfig<String>('buttonLabel', '') ?? '',
        onChanged: (v) => _updateBlockConfig('buttonLabel', v),
        helperText: 'Texte du bouton CTA',
      ),
      _buildTextField(
        label: 'URL Image',
        value: block.getConfig<String>('imageUrl', '') ?? '',
        onChanged: (v) => _updateBlockConfig('imageUrl', v),
        helperText: 'URL de l\'image de fond',
      ),
      _buildDropdown<String>(
        label: 'Alignement',
        value: block.getConfig<String>('alignment', 'left') ?? 'left',
        items: const ['left', 'center'],
        onChanged: (v) => _updateBlockConfig('alignment', v),
      ),
      _buildDropdown<String>(
        label: 'Hauteur',
        value: block.getConfig<String>('heightPreset', 'normal') ?? 'normal',
        items: const ['small', 'normal', 'large'],
        onChanged: (v) => _updateBlockConfig('heightPreset', v),
      ),
      _buildColorPicker(
        label: 'Couleur de fond',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
    ];
  }

  List<Widget> _buildTextConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Contenu',
        value: block.getConfig<String>('content', '') ?? '',
        onChanged: (v) => _updateBlockConfig('content', v),
        maxLines: 5,
        helperText: 'Texte du bloc',
      ),
      _buildDropdown<String>(
        label: 'Alignement',
        value: block.getConfig<String>('alignment', 'left') ?? 'left',
        items: const ['left', 'center', 'right'],
        onChanged: (v) => _updateBlockConfig('alignment', v),
      ),
      _buildDropdown<String>(
        label: 'Taille',
        value: block.getConfig<String>('size', 'normal') ?? 'normal',
        items: const ['small', 'normal', 'large'],
        onChanged: (v) => _updateBlockConfig('size', v),
      ),
      _buildCheckbox(
        label: 'Gras',
        value: block.getConfig<bool>('bold', false) ?? false,
        onChanged: (v) => _updateBlockConfig('bold', v),
      ),
      _buildColorPicker(
        label: 'Couleur du texte',
        value: block.getConfig<String>('color', '') ?? '',
        onChanged: (v) => _updateBlockConfig('color', v),
      ),
    ];
  }

  List<Widget> _buildProductListConfig(BuilderBlock block) {
    final productIds = block.getConfig<String>('productIds', '') ?? '';

    return [
      _buildTextField(
        label: 'Titre (optionnel)',
        value: block.getConfig<String>('title', '') ?? '',
        onChanged: (v) => _updateBlockConfig('title', v),
        helperText: 'Titre de la section de produits',
      ),
      _buildDropdown<String>(
        label: 'Mode',
        value: block.getConfig<String>('mode', 'featured') ?? 'featured',
        items: const ['featured', 'manual', 'top_selling', 'promo'],
        onChanged: (v) => _updateBlockConfig('mode', v),
      ),
      _buildDropdown<String>(
        label: 'Layout',
        value: block.getConfig<String>('layout', 'grid') ?? 'grid',
        items: const ['grid', 'carousel', 'list'],
        onChanged: (v) => _updateBlockConfig('layout', v),
      ),
      _buildTextField(
        label: 'IDs des produits (pour mode manuel)',
        value: productIds,
        onChanged: (v) => _updateBlockConfig('productIds', v),
        helperText: 'Séparés par virgule. Ex: prod1,prod2,prod3',
        maxLines: 2,
      ),
      _buildTextField(
        label: 'Limite',
        value: (block.getConfig<int>('limit', 6) ?? 6).toString(),
        onChanged: (v) {
          final limit = int.tryParse(v) ?? 6;
          _updateBlockConfig('limit', limit);
        },
        helperText: 'Nombre maximum de produits à afficher',
      ),
    ];
  }

  List<Widget> _buildBannerConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Titre',
        value: block.getConfig<String>('title', '') ?? '',
        onChanged: (v) => _updateBlockConfig('title', v),
        helperText: 'Titre principal de la bannière',
      ),
      _buildTextField(
        label: 'Sous-titre',
        value: block.getConfig<String>('subtitle', '') ?? '',
        onChanged: (v) => _updateBlockConfig('subtitle', v),
        helperText: 'Texte secondaire (optionnel)',
      ),
      _buildTextField(
        label: 'Texte (fallback)',
        value: block.getConfig<String>('text', '') ?? '',
        onChanged: (v) => _updateBlockConfig('text', v),
        helperText: 'Utilisé si titre absent',
      ),
      _buildTextField(
        label: 'URL Image',
        value: block.getConfig<String>('imageUrl', '') ?? '',
        onChanged: (v) => _updateBlockConfig('imageUrl', v),
        helperText: 'Image de fond (optionnelle)',
      ),
      _buildTextField(
        label: 'Label CTA',
        value: block.getConfig<String>('ctaLabel', '') ?? '',
        onChanged: (v) => _updateBlockConfig('ctaLabel', v),
        helperText: 'Texte du bouton d\'action',
      ),
      _buildTextField(
        label: 'Action CTA',
        value: block.getConfig<String>('ctaAction', '') ?? '',
        onChanged: (v) => _updateBlockConfig('ctaAction', v),
        helperText: 'Route ex: /menu',
      ),
      _buildDropdown<String>(
        label: 'Style',
        value: block.getConfig<String>('style', 'info') ?? 'info',
        items: const ['info', 'promo', 'warning', 'success'],
        onChanged: (v) => _updateBlockConfig('style', v),
      ),
      _buildColorPicker(
        label: 'Couleur de fond',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
    ];
  }

  List<Widget> _buildInfoConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Titre',
        value: block.getConfig<String>('title', '') ?? '',
        onChanged: (v) => _updateBlockConfig('title', v),
        helperText: 'Titre de l\'information',
      ),
      _buildTextField(
        label: 'Contenu',
        value: block.getConfig<String>('content', '') ?? '',
        onChanged: (v) => _updateBlockConfig('content', v),
        maxLines: 3,
        helperText: 'Texte descriptif',
      ),
      _buildDropdown<String>(
        label: 'Icône',
        value: block.getConfig<String>('icon', 'info') ?? 'info',
        items: const ['info', 'warning', 'success', 'error', 'time', 'phone', 'location', 'email'],
        onChanged: (v) => _updateBlockConfig('icon', v),
      ),
      _buildCheckbox(
        label: 'Mise en évidence',
        value: block.getConfig<bool>('highlight', false) ?? false,
        onChanged: (v) => _updateBlockConfig('highlight', v),
      ),
      _buildDropdown<String>(
        label: 'Type d\'action',
        value: block.getConfig<String>('actionType', 'none') ?? 'none',
        items: const ['none', 'call', 'email', 'navigate'],
        onChanged: (v) => _updateBlockConfig('actionType', v),
      ),
      _buildTextField(
        label: 'Valeur de l\'action',
        value: block.getConfig<String>('actionValue', '') ?? '',
        onChanged: (v) => _updateBlockConfig('actionValue', v),
        helperText: 'Numéro, email ou URL',
      ),
    ];
  }

  List<Widget> _buildButtonConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Label',
        value: block.getConfig<String>('label', '') ?? '',
        onChanged: (v) => _updateBlockConfig('label', v),
        helperText: 'Texte du bouton',
      ),
      _buildTextField(
        label: 'Action',
        value: block.getConfig<String>('action', '') ?? '',
        onChanged: (v) => _updateBlockConfig('action', v),
        helperText: 'Route ex: /menu',
      ),
      _buildDropdown<String>(
        label: 'Style',
        value: block.getConfig<String>('style', 'primary') ?? 'primary',
        items: const ['primary', 'secondary', 'outline'],
        onChanged: (v) => _updateBlockConfig('style', v),
      ),
      _buildDropdown<String>(
        label: 'Alignement',
        value: block.getConfig<String>('alignment', 'center') ?? 'center',
        items: const ['left', 'center', 'right'],
        onChanged: (v) => _updateBlockConfig('alignment', v),
      ),
    ];
  }

  List<Widget> _buildImageConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'URL Image',
        value: block.getConfig<String>('imageUrl', '') ?? '',
        onChanged: (v) => _updateBlockConfig('imageUrl', v),
        helperText: 'URL de l\'image',
      ),
      _buildTextField(
        label: 'Légende',
        value: block.getConfig<String>('caption', '') ?? '',
        onChanged: (v) => _updateBlockConfig('caption', v),
        helperText: 'Texte sous l\'image (optionnel)',
      ),
      _buildDropdown<String>(
        label: 'Alignement',
        value: block.getConfig<String>('alignment', 'center') ?? 'center',
        items: const ['left', 'center', 'right'],
        onChanged: (v) => _updateBlockConfig('alignment', v),
      ),
      _buildTextField(
        label: 'Hauteur',
        value: (block.getConfig<int>('height', 300) ?? 300).toString(),
        onChanged: (v) {
          final height = int.tryParse(v) ?? 300;
          _updateBlockConfig('height', height);
        },
        helperText: 'Hauteur en pixels',
      ),
    ];
  }

  List<Widget> _buildSpacerConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Hauteur',
        value: (block.getConfig<int>('height', 24) ?? 24).toString(),
        onChanged: (v) {
          final height = int.tryParse(v) ?? 24;
          _updateBlockConfig('height', height);
        },
        helperText: 'Hauteur de l\'espace en pixels',
      ),
    ];
  }

  List<Widget> _buildCategoryListConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Titre (optionnel)',
        value: block.getConfig<String>('title', '') ?? '',
        onChanged: (v) => _updateBlockConfig('title', v),
        helperText: 'Titre de la section',
      ),
      _buildDropdown<String>(
        label: 'Mode',
        value: block.getConfig<String>('mode', 'auto') ?? 'auto',
        items: const ['auto', 'custom'],
        onChanged: (v) => _updateBlockConfig('mode', v),
      ),
      _buildDropdown<String>(
        label: 'Layout',
        value: block.getConfig<String>('layout', 'horizontal') ?? 'horizontal',
        items: const ['horizontal', 'grid'],
        onChanged: (v) => _updateBlockConfig('layout', v),
      ),
    ];
  }

  List<Widget> _buildHtmlConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Contenu HTML',
        value: block.getConfig<String>('htmlContent', '') ?? '',
        onChanged: (v) => _updateBlockConfig('htmlContent', v),
        maxLines: 10,
        helperText: 'Code HTML personnalisé',
      ),
    ];
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        maxLines: maxLines,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _buildColorPicker({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    // Predefined color palette
    final colors = {
      '': 'Par défaut',
      '#DC2626': 'Rouge',
      '#EA580C': 'Orange',
      '#CA8A04': 'Jaune',
      '#16A34A': 'Vert',
      '#0284C7': 'Bleu',
      '#9333EA': 'Violet',
      '#DB2777': 'Rose',
      '#000000': 'Noir',
      '#FFFFFF': 'Blanc',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.entries.map((entry) {
              final isSelected = value == entry.key;
              Color colorValue;
              
              if (entry.key.isEmpty) {
                colorValue = Colors.grey.shade300;
              } else {
                try {
                  colorValue = Color(int.parse(entry.key.replaceAll('#', '0xFF')));
                } catch (e) {
                  // Fallback to grey if color parsing fails
                  colorValue = Colors.grey.shade300;
                  debugPrint('Invalid color format: ${entry.key}');
                }
              }
              
              return InkWell(
                onTap: () => onChanged(entry.key),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorValue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: entry.key.isEmpty
                      ? const Icon(Icons.block, color: Colors.grey)
                      : null,
                ),
              );
            }).toList(),
          ),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Sélectionné: ${colors[value] ?? value}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un bloc'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: BlockType.values.length,
            itemBuilder: (context, index) {
              final type = BlockType.values[index];
              return ListTile(
                leading: Text(
                  type.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(type.label),
                onTap: () {
                  Navigator.pop(context);
                  _addBlock(type);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
