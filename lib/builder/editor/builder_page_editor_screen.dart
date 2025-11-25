// lib/builder/editor/builder_page_editor_screen.dart
// Page editor screen for Builder B3 system
// MOBILE RESPONSIVE: Adapts layout for mobile (<600px), tablet, and desktop
// PHASE 7: Enhanced with all block fields, tap actions, auto-save, and page creation
// PHASE 8E: System page protections and SystemBlock protections

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../preview/preview.dart';
import '../utils/responsive.dart';
import '../utils/action_helper.dart';
import 'new_page_dialog.dart';

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
  static const double _mobileEditorPanelHeight = 60.0;
  static const Duration _autoSaveDelay = Duration(seconds: 2);
  
  final BuilderLayoutService _service = BuilderLayoutService();
  BuilderPage? _page;
  bool _isLoading = true;
  BuilderBlock? _selectedBlock;
  bool _hasChanges = false;
  bool _showPreviewInMobile = false;
  late TabController _tabController;
  Timer? _autoSaveTimer;
  bool _isSaving = false;
  
  /// Whether to show the mobile editor panel at the bottom
  /// Panel is shown when a block is selected AND we're showing the blocks list (not preview)
  bool get _shouldShowMobileEditorPanel => _selectedBlock != null && !_showPreviewInMobile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPage();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// Schedule auto-save after changes
  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(_autoSaveDelay, () {
      if (_hasChanges && _page != null) {
        _autoSaveDraft();
      }
    });
  }

  /// Auto-save draft without user confirmation
  Future<void> _autoSaveDraft() async {
    if (_page == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      await _service.saveDraft(_page!);
      setState(() {
        _hasChanges = false;
        _isSaving = false;
      });
      debugPrint('✅ Auto-saved draft');
    } catch (e) {
      setState(() => _isSaving = false);
      debugPrint('❌ Auto-save failed: $e');
    }
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
      
      // Verify and correct system page flag if needed
      page = _verifySystemPageIntegrity(page);

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
  
  /// Verify and correct system page integrity at load time
  /// 
  /// Checks:
  /// - System pages have isSystemPage = true
  /// - System pages have valid displayLocation
  /// - System pages have a default icon if missing
  BuilderPage _verifySystemPageIntegrity(BuilderPage page) {
    var correctedPage = page;
    bool needsCorrection = false;
    
    // Check if this should be a system page but isn't marked as such
    if (page.pageId.isSystemPage && !page.isSystemPage) {
      debugPrint('⚠️ Correcting isSystemPage for ${page.pageId.value}');
      correctedPage = correctedPage.copyWith(isSystemPage: true);
      needsCorrection = true;
    }
    
    // Validate displayLocation for system pages
    if (correctedPage.isSystemPage) {
      final validLocations = ['bottomBar', 'hidden'];
      if (!validLocations.contains(correctedPage.displayLocation)) {
        debugPrint('⚠️ Correcting displayLocation for ${page.pageId.value}');
        correctedPage = correctedPage.copyWith(displayLocation: 'hidden');
        needsCorrection = true;
      }
    }
    
    // Set default icon for system pages if missing
    if (correctedPage.isSystemPage && (correctedPage.icon.isEmpty || correctedPage.icon == 'help_outline')) {
      String defaultIcon;
      switch (page.pageId) {
        case BuilderPageId.profile:
          defaultIcon = 'person';
          break;
        case BuilderPageId.cart:
          defaultIcon = 'shopping_cart';
          break;
        case BuilderPageId.rewards:
          defaultIcon = 'card_giftcard';
          break;
        case BuilderPageId.roulette:
          defaultIcon = 'casino';
          break;
        default:
          defaultIcon = 'help_outline';
      }
      if (correctedPage.icon != defaultIcon) {
        correctedPage = correctedPage.copyWith(icon: defaultIcon);
        needsCorrection = true;
      }
    }
    
    // Auto-save corrected page if changes were made
    if (needsCorrection) {
      debugPrint('✅ Auto-correcting system page ${page.pageId.value}');
      _service.saveDraft(correctedPage);
    }
    
    return correctedPage;
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
    _scheduleAutoSave();
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
        return {
          'height': 24,
        };
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
        return {
          'htmlContent': '<p>Contenu HTML</p>',
        };
      case BlockType.system:
        // System blocks use moduleType, not through _addBlock
        return {
          'moduleType': 'unknown',
        };
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
    _scheduleAutoSave();
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
    _scheduleAutoSave();
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
    _scheduleAutoSave();
  }

  /// Update multiple config values at once
  void _updateBlockConfigMultiple(Map<String, dynamic> updates) {
    if (_page == null || _selectedBlock == null) return;

    var updatedBlock = _selectedBlock!;
    for (final entry in updates.entries) {
      updatedBlock = updatedBlock.updateConfig(entry.key, entry.value);
    }

    setState(() {
      _page = _page!.updateBlock(updatedBlock);
      _selectedBlock = updatedBlock;
      _hasChanges = true;
    });
    _scheduleAutoSave();
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
              if (responsive.isMobile)
                IconButton(
                  // When showing list, button switches to preview; when showing preview, button switches to list
                  icon: Icon(!_showPreviewInMobile ? Icons.visibility : Icons.view_list),
                  tooltip: !_showPreviewInMobile ? 'Voir la prévisualisation' : 'Voir la liste',
                  onPressed: () => setState(() => _showPreviewInMobile = !_showPreviewInMobile),
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

  /// Mobile layout with blocks list showing delete/drag actions permanently
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Show either blocks list (default) or preview (when toggled)
        Positioned.fill(
          bottom: _shouldShowMobileEditorPanel ? _mobileEditorPanelHeight : 0,
          child: _showPreviewInMobile ? _buildPreviewTab() : _buildBlocksList(),
        ),
        // Floating editor panel button (when block is selected and in list view)
        if (_shouldShowMobileEditorPanel)
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

    return Column(
      children: [
        // System page protection banner
        if (_page!.isSystemPage)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                      message: 'Cette page ne peut pas être supprimée.\nL\'ID ne peut pas être modifié.\nVous pouvez modifier les blocs.',
                      child: Icon(Icons.info_outline, color: Colors.blue.shade400, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildProtectionChip(Icons.block, 'Suppression', false),
                    _buildProtectionChip(Icons.block, 'ID', false),
                    _buildProtectionChip(Icons.check_circle, 'Blocs', true),
                    _buildProtectionChip(Icons.check_circle, 'Ordre', true),
                  ],
                ),
              ],
            ),
          ),
        
        // Blocks list
        Expanded(
          child: blocks.isEmpty
              ? const Center(
                  child: Text(
                    'Aucun bloc.\nAppuyez sur + pour en ajouter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ReorderableListView.builder(
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
                ),
        ),
      ],
    );
  }
  
  /// Build a small protection chip for system page banner
  Widget _buildProtectionChip(IconData icon, String label, bool allowed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: allowed ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: allowed ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: allowed ? Colors.green.shade600 : Colors.red.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: allowed ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
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
      case BlockType.system:
        final moduleType = block.getConfig<String>('moduleType', 'unknown') ?? 'unknown';
        return 'Module ${SystemBlock.getModuleLabel(moduleType)}';
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
      case BlockType.system:
        return _buildSystemConfig(block);
    }
  }

  /// Build configuration fields for system blocks
  /// System blocks are non-configurable, so we just show info about the module
  /// Protection: No configuration fields are exposed
  List<Widget> _buildSystemConfig(BuilderBlock block) {
    final moduleType = block.getConfig<String>('moduleType', 'unknown') ?? 'unknown';
    final moduleLabel = SystemBlock.getModuleLabel(moduleType);
    final isValidModule = SystemBlock.availableModules.contains(moduleType);
    
    // Get the appropriate icon for the module type
    IconData moduleIcon;
    Color iconColor;
    switch (moduleType) {
      case 'roulette':
        moduleIcon = Icons.casino;
        iconColor = Colors.purple.shade600;
        break;
      case 'loyalty':
        moduleIcon = Icons.card_giftcard;
        iconColor = Colors.amber.shade600;
        break;
      case 'rewards':
        moduleIcon = Icons.stars;
        iconColor = Colors.orange.shade600;
        break;
      case 'accountActivity':
        moduleIcon = Icons.history;
        iconColor = Colors.blue.shade600;
        break;
      default:
        moduleIcon = Icons.help_outline;
        iconColor = Colors.grey.shade600;
    }
    
    return [
      // Module info card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(moduleIcon, size: 32, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[Module: $moduleLabel]',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: $moduleType',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Protection banner
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
                  const Expanded(
                    child: Text(
                      'Module système protégé',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // No config message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ce module système ne possède aucune configuration.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Warning if module type is invalid
            if (!isValidModule) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 20, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Module "$moduleType" inconnu. Ce bloc peut ne pas s\'afficher correctement.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Restrictions list
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restrictions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            _buildRestrictionRow(Icons.block, 'Pas de configuration personnalisée'),
            const SizedBox(height: 4),
            _buildRestrictionRow(Icons.block, 'Type de bloc non modifiable'),
            const SizedBox(height: 4),
            _buildRestrictionRow(Icons.check_circle, 'Suppression autorisée'),
            const SizedBox(height: 4),
            _buildRestrictionRow(Icons.check_circle, 'Réorganisation autorisée'),
          ],
        ),
      ),
    ];
  }
  
  /// Build a restriction row for system block config
  Widget _buildRestrictionRow(IconData icon, String text) {
    final isAllowed = icon == Icons.check_circle;
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isAllowed ? Colors.green.shade600 : Colors.red.shade400,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
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
        label: 'Alignement du texte',
        value: block.getConfig<String>('alignment', 'center') ?? 'center',
        items: const ['left', 'center', 'right'],
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
      _buildColorPicker(
        label: 'Couleur du texte',
        value: block.getConfig<String>('textColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('textColor', v),
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
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
        items: const ['small', 'normal', 'large', 'title', 'heading'],
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
      _buildNumberField(
        label: 'Padding',
        value: block.getConfig<int>('padding', 16) ?? 16,
        onChanged: (v) => _updateBlockConfig('padding', v),
        helperText: 'Espacement intérieur',
      ),
      _buildNumberField(
        label: 'Nombre de lignes max',
        value: block.getConfig<int>('maxLines', 0) ?? 0,
        onChanged: (v) => _updateBlockConfig('maxLines', v),
        helperText: '0 = illimité',
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
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
        label: 'Alignement du titre',
        value: block.getConfig<String>('titleAlignment', 'left') ?? 'left',
        items: const ['left', 'center', 'right'],
        onChanged: (v) => _updateBlockConfig('titleAlignment', v),
      ),
      _buildDropdown<String>(
        label: 'Taille du titre',
        value: block.getConfig<String>('titleSize', 'medium') ?? 'medium',
        items: const ['small', 'medium', 'large'],
        onChanged: (v) => _updateBlockConfig('titleSize', v),
      ),
      _buildDropdown<String>(
        label: 'Mode',
        value: block.getConfig<String>('mode', 'featured') ?? 'featured',
        items: const ['featured', 'manual', 'top_selling', 'promo'],
        onChanged: (v) => _updateBlockConfig('mode', v),
      ),
      _buildTextField(
        label: 'Catégorie',
        value: block.getConfig<String>('categoryId', '') ?? '',
        onChanged: (v) => _updateBlockConfig('categoryId', v),
        helperText: 'ID de la catégorie (Pizza, Boissons, etc.)',
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
      _buildNumberField(
        label: 'Limite',
        value: block.getConfig<int>('limit', 6) ?? 6,
        onChanged: (v) => _updateBlockConfig('limit', v),
        helperText: 'Nombre maximum de produits à afficher',
      ),
      _buildColorPicker(
        label: 'Couleur de fond',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
      _buildColorPicker(
        label: 'Couleur du texte',
        value: block.getConfig<String>('textColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('textColor', v),
      ),
      _buildNumberField(
        label: 'Border Radius',
        value: block.getConfig<int>('borderRadius', 8) ?? 8,
        onChanged: (v) => _updateBlockConfig('borderRadius', v),
        helperText: 'Arrondi des coins',
      ),
      _buildNumberField(
        label: 'Élévation',
        value: block.getConfig<int>('elevation', 2) ?? 2,
        onChanged: (v) => _updateBlockConfig('elevation', v),
        helperText: 'Ombre portée',
        max: 24,
      ),
      _buildDropdown<String>(
        label: 'Action au clic sur produit',
        value: block.getConfig<String>('actionOnProductTap', 'openProductDetail') ?? 'openProductDetail',
        items: const ['openProductDetail', 'openPage'],
        onChanged: (v) => _updateBlockConfig('actionOnProductTap', v),
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
      _buildColorPicker(
        label: 'Couleur du texte',
        value: block.getConfig<String>('textColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('textColor', v),
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
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
      _buildColorPicker(
        label: 'Couleur de fond',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
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
      _buildDropdown<String>(
        label: 'Style',
        value: block.getConfig<String>('style', 'primary') ?? 'primary',
        items: const ['primary', 'secondary', 'outline', 'text'],
        onChanged: (v) => _updateBlockConfig('style', v),
      ),
      _buildDropdown<String>(
        label: 'Alignement',
        value: block.getConfig<String>('alignment', 'center') ?? 'center',
        items: const ['left', 'center', 'right', 'stretch'],
        onChanged: (v) => _updateBlockConfig('alignment', v),
      ),
      _buildColorPicker(
        label: 'Couleur du bouton',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
      _buildColorPicker(
        label: 'Couleur du texte',
        value: block.getConfig<String>('textColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('textColor', v),
      ),
      _buildNumberField(
        label: 'Border Radius',
        value: block.getConfig<int>('borderRadius', 8) ?? 8,
        onChanged: (v) => _updateBlockConfig('borderRadius', v),
        helperText: 'Arrondi des coins',
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
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
      _buildDropdown<String>(
        label: 'Ajustement de l\'image',
        value: block.getConfig<String>('fit', 'cover') ?? 'cover',
        items: const ['cover', 'contain', 'fill', 'fitWidth', 'fitHeight'],
        onChanged: (v) => _updateBlockConfig('fit', v),
      ),
      _buildNumberField(
        label: 'Hauteur',
        value: block.getConfig<int>('height', 300) ?? 300,
        onChanged: (v) => _updateBlockConfig('height', v),
        helperText: 'Hauteur en pixels',
      ),
      _buildNumberField(
        label: 'Border Radius',
        value: block.getConfig<int>('borderRadius', 0) ?? 0,
        onChanged: (v) => _updateBlockConfig('borderRadius', v),
        helperText: 'Arrondi des coins',
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildSpacerConfig(BuilderBlock block) {
    return [
      _buildNumberField(
        label: 'Hauteur',
        value: block.getConfig<int>('height', 24) ?? 24,
        onChanged: (v) => _updateBlockConfig('height', v),
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
        items: const ['horizontal', 'grid', 'carousel'],
        onChanged: (v) => _updateBlockConfig('layout', v),
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
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
      child: TextFormField(
        key: ValueKey('${label}_$value'), // Unique key for rebuild
        initialValue: value,
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
    // Filter out system type from regular blocks
    final regularBlocks = BlockType.values.where((t) => t != BlockType.system).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un bloc'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Regular blocks section
                const Text(
                  'Blocs de contenu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Divider(),
                ...regularBlocks.map((type) => ListTile(
                  leading: Text(
                    type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(type.label),
                  onTap: () {
                    Navigator.pop(context);
                    _addBlock(type);
                  },
                )),
                
                const SizedBox(height: 16),
                
                // System modules section
                const Text(
                  'Modules système',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Divider(color: Colors.blue),
                ListTile(
                  leading: Icon(Icons.casino, size: 28, color: Colors.purple.shade600),
                  title: const Text('Ajouter module Roulette'),
                  subtitle: const Text('Roue de la chance'),
                  onTap: () {
                    Navigator.pop(context);
                    _addSystemBlock('roulette');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.card_giftcard, size: 28, color: Colors.amber.shade600),
                  title: const Text('Ajouter module Fidélité'),
                  subtitle: const Text('Points et progression'),
                  onTap: () {
                    Navigator.pop(context);
                    _addSystemBlock('loyalty');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.stars, size: 28, color: Colors.orange.shade600),
                  title: const Text('Ajouter module Récompenses'),
                  subtitle: const Text('Tickets et bons'),
                  onTap: () {
                    Navigator.pop(context);
                    _addSystemBlock('rewards');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history, size: 28, color: Colors.blue.shade600),
                  title: const Text('Ajouter module Activité du compte'),
                  subtitle: const Text('Commandes et favoris'),
                  onTap: () {
                    Navigator.pop(context);
                    _addSystemBlock('accountActivity');
                  },
                ),
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
      ),
    );
  }

  /// Add a system block with the specified module type
  void _addSystemBlock(String moduleType) {
    if (_page == null) return;

    final newBlock = SystemBlock(
      id: 'block_${DateTime.now().millisecondsSinceEpoch}',
      moduleType: moduleType,
      order: _page!.blocks.length,
    );

    setState(() {
      _page = _page!.addBlock(newBlock);
      _hasChanges = true;
      _selectedBlock = newBlock;
    });
    _scheduleAutoSave();
  }

  /// Build tap action configuration fields
  /// 
  /// Shows:
  /// - Action type dropdown (none, openPage, openLegacyPage, openUrl)
  /// - Conditional target field based on action type
  List<Widget> _buildTapActionFields(BuilderBlock block) {
    final tapAction = block.getConfig<String>('tapAction', 'none') ?? 'none';
    final tapActionTarget = block.getConfig<String>('tapActionTarget', '') ?? '';

    return [
      const Divider(height: 32),
      const Text(
        '🔗 Action au clic',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
      const SizedBox(height: 12),
      _buildDropdown<String>(
        label: 'Type d\'action',
        value: tapAction,
        items: const ['none', 'openPage', 'openLegacyPage', 'openSystemPage', 'openUrl'],
        onChanged: (v) {
          _updateBlockConfigMultiple({
            'tapAction': v,
            'tapActionTarget': '', // Reset target when action type changes
          });
        },
      ),
      // Show target field based on action type
      if (tapAction == 'openPage')
        _buildTextField(
          label: 'ID de la page Builder',
          value: tapActionTarget,
          onChanged: (v) => _updateBlockConfig('tapActionTarget', v),
          helperText: 'Ex: promo, menu, about',
        ),
      if (tapAction == 'openLegacyPage' && LegacyRoutes.values.isNotEmpty)
        _buildDropdown<String>(
          label: 'Route de l\'application',
          value: LegacyRoutes.values.contains(tapActionTarget) 
              ? tapActionTarget 
              : LegacyRoutes.values.first,
          items: LegacyRoutes.values,
          onChanged: (v) => _updateBlockConfig('tapActionTarget', v),
        ),
      if (tapAction == 'openSystemPage')
        _buildDropdown<String>(
          label: 'Page système',
          value: SystemPageRoutes.values.contains(tapActionTarget)
              ? tapActionTarget
              : SystemPageRoutes.values.first,
          items: SystemPageRoutes.values,
          onChanged: (v) => _updateBlockConfig('tapActionTarget', v),
        ),
      if (tapAction == 'openSystemPage')
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ouvre la page système avec la version Builder si disponible.',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),
      if (tapAction == 'openUrl')
        _buildTextField(
          label: 'URL externe',
          value: tapActionTarget,
          onChanged: (v) => _updateBlockConfig('tapActionTarget', v),
          helperText: 'Ex: https://example.com',
        ),
    ];
  }

  /// Build padding/margin/spacing fields
  Widget _buildNumberField({
    required String label,
    required int value,
    required Function(int) onChanged,
    String? helperText,
    int min = 0,
    int max = 999,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey('${label}_$value'), // Unique key for rebuild
        initialValue: value.toString(),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final parsed = int.tryParse(v) ?? value;
          onChanged(parsed.clamp(min, max));
        },
      ),
    );
  }
}
