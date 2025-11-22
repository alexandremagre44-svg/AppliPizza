// lib/src/admin/studio_b3/page_editor.dart
// Page editor with 3-panel layout: Blocks, Editor, Preview

import 'package:flutter/material.dart';
import '../../models/app_config.dart';
import '../../models/page_schema.dart';
import 'widgets/block_list_panel.dart';
import 'widgets/block_editor_panel.dart';
import 'widgets/preview_panel.dart';

/// Page editor with 3-panel layout
class PageEditor extends StatefulWidget {
  final PageSchema pageSchema;
  final AppConfig config;
  final VoidCallback onBack;
  final Function(PageSchema) onSave;

  const PageEditor({
    Key? key,
    required this.pageSchema,
    required this.config,
    required this.onBack,
    required this.onSave,
  }) : super(key: key);

  @override
  State<PageEditor> createState() => _PageEditorState();
}

class _PageEditorState extends State<PageEditor> {
  late PageSchema _currentPage;
  WidgetBlock? _selectedBlock;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.pageSchema;
  }

  @override
  void didUpdateWidget(PageEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageSchema.id != oldWidget.pageSchema.id) {
      _currentPage = widget.pageSchema;
      _selectedBlock = null;
      _hasUnsavedChanges = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Column(
        children: [
          _buildEditorHeader(),
          Expanded(
            child: Row(
              children: [
                // Left panel: Block List
                SizedBox(
                  width: 300,
                  child: BlockListPanel(
                    blocks: _currentPage.blocks,
                    selectedBlock: _selectedBlock,
                    onBlockSelected: (block) {
                      setState(() {
                        _selectedBlock = block;
                      });
                    },
                    onBlocksReordered: (blocks) {
                      _updatePage(_currentPage.copyWith(blocks: blocks));
                    },
                    onBlockToggle: (block, visible) {
                      _toggleBlockVisibility(block, visible);
                    },
                    onBlockAdd: _showAddBlockDialog,
                    onBlockDuplicate: _duplicateBlock,
                    onBlockDelete: _deleteBlock,
                  ),
                ),
                // Center panel: Block Editor
                Expanded(
                  flex: 2,
                  child: _selectedBlock != null
                      ? BlockEditorPanel(
                          block: _selectedBlock!,
                          onBlockUpdated: (updatedBlock) {
                            _updateBlock(updatedBlock);
                          },
                        )
                      : _buildNoBlockSelected(),
                ),
                // Right panel: Preview
                SizedBox(
                  width: 400,
                  child: PreviewPanel(
                    pageSchema: _currentPage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _onBackPressed,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Retour',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(text: _currentPage.name),
                  decoration: const InputDecoration(
                    labelText: 'Nom de la page',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    _updatePage(_currentPage.copyWith(name: value));
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: _currentPage.route),
                  decoration: const InputDecoration(
                    labelText: 'Route',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixText: '/',
                  ),
                  onChanged: (value) {
                    final route = value.startsWith('/') ? value : '/$value';
                    _updatePage(_currentPage.copyWith(route: route));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (_hasUnsavedChanges)
            Chip(
              label: const Text('Modifications non sauvegardées'),
              backgroundColor: Colors.orange[100],
            ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _saveChanges,
            icon: const Icon(Icons.save),
            label: const Text('Sauvegarder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoBlockSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez un bloc pour l\'éditer',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ou ajoutez un nouveau bloc',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _updatePage(PageSchema updatedPage) {
    setState(() {
      _currentPage = updatedPage;
      _hasUnsavedChanges = true;
    });
  }

  void _updateBlock(WidgetBlock updatedBlock) {
    final updatedBlocks = _currentPage.blocks.map((block) {
      return block.id == updatedBlock.id ? updatedBlock : block;
    }).toList();

    setState(() {
      _currentPage = _currentPage.copyWith(blocks: updatedBlocks);
      _selectedBlock = updatedBlock;
      _hasUnsavedChanges = true;
    });
  }

  void _toggleBlockVisibility(WidgetBlock block, bool visible) {
    final updatedBlock = block.copyWith(visible: visible);
    _updateBlock(updatedBlock);
  }

  void _duplicateBlock(WidgetBlock block) {
    final newBlock = block.copyWith(
      id: 'block_${DateTime.now().millisecondsSinceEpoch}',
      order: _currentPage.blocks.length + 1,
    );

    final updatedBlocks = [..._currentPage.blocks, newBlock];
    _updatePage(_currentPage.copyWith(blocks: updatedBlocks));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bloc dupliqué')),
    );
  }

  void _deleteBlock(WidgetBlock block) {
    final updatedBlocks = _currentPage.blocks.where((b) => b.id != block.id).toList();
    
    // Reorder remaining blocks
    final reorderedBlocks = updatedBlocks.asMap().entries.map((entry) {
      return entry.value.copyWith(order: entry.key + 1);
    }).toList();

    setState(() {
      _currentPage = _currentPage.copyWith(blocks: reorderedBlocks);
      if (_selectedBlock?.id == block.id) {
        _selectedBlock = null;
      }
      _hasUnsavedChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bloc supprimé')),
    );
  }

  void _showAddBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un bloc'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: WidgetBlockType.values.map((type) {
              return ListTile(
                leading: Icon(_getIconForBlockType(type)),
                title: Text(_getNameForBlockType(type)),
                subtitle: Text(_getDescriptionForBlockType(type)),
                onTap: () {
                  Navigator.pop(context);
                  _addBlock(type);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _addBlock(WidgetBlockType type) {
    final newBlock = WidgetBlock(
      id: 'block_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      order: _currentPage.blocks.length + 1,
      visible: true,
      properties: _getDefaultPropertiesForType(type),
    );

    final updatedBlocks = [..._currentPage.blocks, newBlock];
    setState(() {
      _currentPage = _currentPage.copyWith(blocks: updatedBlocks);
      _selectedBlock = newBlock;
      _hasUnsavedChanges = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bloc ajouté')),
    );
  }

  Map<String, dynamic> _getDefaultPropertiesForType(WidgetBlockType type) {
    switch (type) {
      case WidgetBlockType.text:
        return {'text': 'Nouveau texte', 'fontSize': 16.0, 'align': 'left'};
      case WidgetBlockType.button:
        return {'label': 'Nouveau bouton'};
      case WidgetBlockType.image:
        return {'url': '', 'height': 200.0};
      case WidgetBlockType.banner:
        return {'text': 'Nouvelle bannière'};
      case WidgetBlockType.productList:
        return {'title': 'Produits'};
      case WidgetBlockType.categoryList:
        return {'title': 'Catégories'};
      case WidgetBlockType.heroAdvanced:
        return {
          'imageUrl': 'https://picsum.photos/800/600',
          'height': 400.0,
          'borderRadius': 0.0,
          'imageFit': 'cover',
          'overlayColor': '#000000',
          'overlayOpacity': 0.4,
          'hasGradient': false,
          'gradientStartColor': '#000000',
          'gradientEndColor': '#00000000',
          'gradientDirection': 'vertical',
          'title': 'Bienvenue chez Pizza Deli\'Zza',
          'subtitle': 'Découvrez nos délicieuses pizzas artisanales',
          'titleColor': '#FFFFFF',
          'subtitleColor': '#FFFFFFB3',
          'contentAlign': 'center',
          'spacing': 8.0,
          'ctas': [
            {
              'label': 'Commander maintenant',
              'action': 'navigate:/menu',
              'backgroundColor': '#D62828',
              'textColor': '#FFFFFF',
              'borderRadius': 8.0,
              'padding': 16.0,
            }
          ],
          'hasAnimation': true,
          'animationType': 'fadeIn',
          'animationDuration': 1000,
        };
      case WidgetBlockType.carousel:
        return {
          'carouselType': 'images',
          'height': 250.0,
          'viewportFraction': 0.85,
          'autoPlay': true,
          'autoPlayIntervalMs': 3000,
          'enlargeCenterPage': true,
          'showIndicators': true,
          'indicatorColor': '#9E9E9E',
          'indicatorActiveColor': '#2196F3',
          'borderRadius': 12.0,
          'slides': [
            {
              'imageUrl': 'https://picsum.photos/800/600?random=1',
              'title': 'Pizza Margherita',
              'subtitle': 'La classique italienne',
              'action': 'navigate:/menu',
              'overlayColor': '#000000',
              'overlayOpacity': 0.3,
              'useGradient': false,
            },
            {
              'imageUrl': 'https://picsum.photos/800/600?random=2',
              'title': 'Pizza 4 Fromages',
              'subtitle': 'Un délice pour les amateurs',
              'action': 'navigate:/menu',
              'overlayColor': '#000000',
              'overlayOpacity': 0.3,
              'useGradient': false,
            },
            {
              'imageUrl': 'https://picsum.photos/800/600?random=3',
              'title': 'Pizza Végétarienne',
              'subtitle': 'Fraîche et savoureuse',
              'action': 'navigate:/menu',
              'overlayColor': '#000000',
              'overlayOpacity': 0.3,
              'useGradient': false,
            },
          ],
        };
      case WidgetBlockType.popup:
        return {
          'title': 'Offre spéciale !',
          'message': 'Profitez de -20% sur votre première commande avec le code BIENVENUE20',
          'titleColor': '#212121',
          'messageColor': '#757575',
          'alignment': 'center',
          'icon': 'promo',
          'backgroundColor': '#FFFFFF',
          'borderRadius': 16.0,
          'padding': 20.0,
          'maxWidth': 300.0,
          'elevation': 8.0,
          'overlayColor': '#000000',
          'overlayOpacity': 0.5,
          'showOnLoad': true,
          'triggerType': 'onLoad',
          'delayMs': 0,
          'dismissibleByTapOutside': true,
          'showOncePerSession': false,
          'ctas': [
            {
              'label': 'J\'en profite !',
              'action': 'navigate:/menu',
              'backgroundColor': '#4CAF50',
              'textColor': '#FFFFFF',
              'borderRadius': 8.0,
            }
          ],
        };
      case WidgetBlockType.custom:
        return {};
    }
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
        return 'Liste de produits';
      case WidgetBlockType.categoryList:
        return 'Liste de catégories';
      case WidgetBlockType.heroAdvanced:
        return 'Hero Avancé';
      case WidgetBlockType.carousel:
        return 'Carrousel';
      case WidgetBlockType.popup:
        return 'Popup';
      case WidgetBlockType.custom:
        return 'Personnalisé';
    }
  }

  String _getDescriptionForBlockType(WidgetBlockType type) {
    switch (type) {
      case WidgetBlockType.text:
        return 'Paragraphe de texte simple';
      case WidgetBlockType.button:
        return 'Bouton d\'action';
      case WidgetBlockType.image:
        return 'Image ou photo';
      case WidgetBlockType.banner:
        return 'Bannière colorée';
      case WidgetBlockType.productList:
        return 'Grille de produits';
      case WidgetBlockType.categoryList:
        return 'Liste des catégories';
      case WidgetBlockType.heroAdvanced:
        return 'Hero avec image, overlay, gradient et CTAs';
      case WidgetBlockType.carousel:
        return 'Carrousel d\'images, produits ou catégories';
      case WidgetBlockType.popup:
        return 'Popup/modal avec déclencheurs et conditions';
      case WidgetBlockType.custom:
        return 'Bloc personnalisé';
    }
  }

  Future<void> _saveChanges() async {
    await widget.onSave(_currentPage);
    setState(() {
      _hasUnsavedChanges = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Page sauvegardée'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifications non sauvegardées'),
        content: const Text(
          'Vous avez des modifications non sauvegardées. Voulez-vous les sauvegarder ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Ignorer'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveChanges();
              if (mounted) Navigator.pop(context, true);
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _onBackPressed() async {
    if (await _onWillPop()) {
      widget.onBack();
    }
  }
}
