// lib/builder/editor/builder_page_editor_screen.dart
// Page editor screen for Builder B3 system

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../preview/preview.dart';

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
        deleteDraft: false,
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
          'mode': 'manual',
          'productIds': [],
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Éditeur: ${widget.pageId.label}'),
        bottom: TabBar(
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
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEditorTab(),
                    _buildPreviewTab(),
                  ],
                ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddBlockDialog,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un bloc'),
            )
          : null,
    );
  }

  Widget _buildEditorTab() {
    return Row(
      children: [
        // Blocks list (left side)
        Expanded(
          flex: 2,
          child: _buildBlocksList(),
        ),
        // Configuration panel (right side)
        if (_selectedBlock != null)
          Expanded(
            flex: 1,
            child: _buildConfigPanel(),
          ),
      ],
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
      ),
      _buildTextField(
        label: 'Sous-titre',
        value: block.getConfig<String>('subtitle', '') ?? '',
        onChanged: (v) => _updateBlockConfig('subtitle', v),
      ),
      _buildTextField(
        label: 'URL Image',
        value: block.getConfig<String>('imageUrl', '') ?? '',
        onChanged: (v) => _updateBlockConfig('imageUrl', v),
      ),
      _buildTextField(
        label: 'Couleur de fond',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
      _buildTextField(
        label: 'Label du bouton',
        value: block.getConfig<String>('buttonLabel', '') ?? '',
        onChanged: (v) => _updateBlockConfig('buttonLabel', v),
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
    ];
  }

  List<Widget> _buildProductListConfig(BuilderBlock block) {
    final productIds = block.getConfig<List>('productIds', []) ?? [];
    final idsText = productIds.join(', ');

    return [
      _buildDropdown<String>(
        label: 'Mode',
        value: block.getConfig<String>('mode', 'manual') ?? 'manual',
        items: const ['manual', 'auto'],
        onChanged: (v) => _updateBlockConfig('mode', v),
      ),
      _buildTextField(
        label: 'IDs des produits (séparés par virgule)',
        value: idsText,
        onChanged: (v) {
          final ids = v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
          _updateBlockConfig('productIds', ids);
        },
        helperText: 'Ex: prod1, prod2, prod3',
      ),
    ];
  }

  List<Widget> _buildBannerConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Texte',
        value: block.getConfig<String>('text', '') ?? '',
        onChanged: (v) => _updateBlockConfig('text', v),
      ),
      _buildTextField(
        label: 'Couleur de fond',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
      _buildTextField(
        label: 'Couleur du texte',
        value: block.getConfig<String>('textColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('textColor', v),
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
