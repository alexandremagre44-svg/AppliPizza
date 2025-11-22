// lib/src/admin/studio_b3/widgets/block_editor_panel.dart
// Center panel: Dynamic form editor for block properties

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/page_schema.dart';
import 'dart:developer' as developer;

/// Panel for editing block properties with dynamic forms
class BlockEditorPanel extends StatefulWidget {
  final WidgetBlock block;
  final Function(WidgetBlock) onBlockUpdated;

  const BlockEditorPanel({
    Key? key,
    required this.block,
    required this.onBlockUpdated,
  }) : super(key: key);

  @override
  State<BlockEditorPanel> createState() => _BlockEditorPanelState();
}

class _BlockEditorPanelState extends State<BlockEditorPanel> {
  late Map<String, dynamic> _properties;
  late Map<String, dynamic>? _styling;
  late Map<String, dynamic>? _actions;
  late DataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    _initializeProperties();
  }

  @override
  void didUpdateWidget(BlockEditorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.block.id != oldWidget.block.id) {
      _initializeProperties();
    }
  }

  void _initializeProperties() {
    _properties = Map<String, dynamic>.from(widget.block.properties);
    _styling = widget.block.styling != null 
        ? Map<String, dynamic>.from(widget.block.styling!) 
        : {};
    _actions = widget.block.actions != null 
        ? Map<String, dynamic>.from(widget.block.actions!) 
        : {};
    _dataSource = widget.block.dataSource;
    
    // Initialize DataSource for product/category lists if not present
    if (_dataSource == null && 
        (widget.block.type == WidgetBlockType.productList || 
         widget.block.type == WidgetBlockType.categoryList)) {
      final sourceType = widget.block.type == WidgetBlockType.productList
          ? DataSourceType.products
          : DataSourceType.categories;
      _dataSource = DataSource(
        id: 'datasource_${widget.block.id}',
        type: sourceType,
        config: {},
      );
      developer.log('🔧 BlockEditorPanel: Initialized DataSource for ${widget.block.type.value}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPropertiesSection(),
                  const SizedBox(height: 24),
                  _buildStylingSection(),
                  const SizedBox(height: 24),
                  _buildActionsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Icon(_getIconForBlockType(widget.block.type), size: 24),
          const SizedBox(width: 12),
          Text(
            'Éditer ${_getNameForBlockType(widget.block.type)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Propriétés',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._buildFieldsForBlockType(widget.block.type),
      ],
    );
  }

  List<Widget> _buildFieldsForBlockType(WidgetBlockType type) {
    switch (type) {
      case WidgetBlockType.text:
        return _buildTextFields();
      case WidgetBlockType.button:
        return _buildButtonFields();
      case WidgetBlockType.image:
        return _buildImageFields();
      case WidgetBlockType.banner:
        return _buildBannerFields();
      case WidgetBlockType.productList:
        return _buildProductListFields();
      case WidgetBlockType.categoryList:
        return _buildCategoryListFields();
      case WidgetBlockType.custom:
        return [const Text('Bloc personnalisé (aucun champ)')];
    }
  }

  List<Widget> _buildTextFields() {
    return [
      TextField(
        controller: TextEditingController(text: _properties['text']?.toString()),
        decoration: const InputDecoration(
          labelText: 'Texte',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        onChanged: (value) => _updateProperty('text', value),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: TextEditingController(
          text: _properties['fontSize']?.toString() ?? '16',
        ),
        decoration: const InputDecoration(
          labelText: 'Taille de police',
          border: OutlineInputBorder(),
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
        onChanged: (value) => _updateProperty('fontSize', double.tryParse(value) ?? 16.0),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _properties['align']?.toString() ?? 'left',
        decoration: const InputDecoration(
          labelText: 'Alignement',
          border: OutlineInputBorder(),
        ),
        items: ['left', 'center', 'right', 'justify']
            .map((align) => DropdownMenuItem(value: align, child: Text(align)))
            .toList(),
        onChanged: (value) => _updateProperty('align', value),
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Gras'),
        value: _properties['bold'] == true,
        onChanged: (value) => _updateProperty('bold', value),
      ),
    ];
  }

  List<Widget> _buildButtonFields() {
    return [
      TextField(
        controller: TextEditingController(text: _properties['label']?.toString()),
        decoration: const InputDecoration(
          labelText: 'Texte du bouton',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _updateProperty('label', value),
      ),
    ];
  }

  List<Widget> _buildImageFields() {
    return [
      TextField(
        controller: TextEditingController(text: _properties['url']?.toString()),
        decoration: const InputDecoration(
          labelText: 'URL de l\'image',
          border: OutlineInputBorder(),
          hintText: 'https://...',
        ),
        onChanged: (value) => _updateProperty('url', value),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: TextEditingController(
          text: _properties['height']?.toString() ?? '200',
        ),
        decoration: const InputDecoration(
          labelText: 'Hauteur',
          border: OutlineInputBorder(),
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
        onChanged: (value) => _updateProperty('height', double.tryParse(value) ?? 200.0),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _properties['fit']?.toString() ?? 'cover',
        decoration: const InputDecoration(
          labelText: 'Ajustement',
          border: OutlineInputBorder(),
        ),
        items: ['cover', 'contain', 'fill', 'fitWidth', 'fitHeight']
            .map((fit) => DropdownMenuItem(value: fit, child: Text(fit)))
            .toList(),
        onChanged: (value) => _updateProperty('fit', value),
      ),
    ];
  }

  List<Widget> _buildBannerFields() {
    return [
      TextField(
        controller: TextEditingController(text: _properties['text']?.toString()),
        decoration: const InputDecoration(
          labelText: 'Texte de la bannière',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _updateProperty('text', value),
      ),
    ];
  }

  List<Widget> _buildProductListFields() {
    return [
      TextField(
        controller: TextEditingController(text: _properties['title']?.toString()),
        decoration: const InputDecoration(
          labelText: 'Titre',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _updateProperty('title', value),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: TextEditingController(
          text: _properties['columns']?.toString() ?? '2',
        ),
        decoration: const InputDecoration(
          labelText: 'Nombre de colonnes',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => _updateProperty('columns', int.tryParse(value) ?? 2),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: TextEditingController(
          text: _properties['spacing']?.toString() ?? '16',
        ),
        decoration: const InputDecoration(
          labelText: 'Espacement',
          border: OutlineInputBorder(),
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
        onChanged: (value) => _updateProperty('spacing', double.tryParse(value) ?? 16.0),
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Afficher les prix'),
        value: _properties['showPrice'] == true,
        onChanged: (value) => _updateProperty('showPrice', value),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _getCategoryFilter(),
        decoration: const InputDecoration(
          labelText: 'Filtrer par catégorie',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: '', child: Text('Toutes')),
          const DropdownMenuItem(value: 'pizza', child: Text('Pizza')),
          const DropdownMenuItem(value: 'menus', child: Text('Menus')),
          const DropdownMenuItem(value: 'boissons', child: Text('Boissons')),
          const DropdownMenuItem(value: 'desserts', child: Text('Desserts')),
        ],
        onChanged: (value) {
          if (value != null) {
            _updateDataSourceConfig('category', value);
          }
        },
      ),
      const SizedBox(height: 16),
      TextField(
        controller: TextEditingController(
          text: _getDataSourceLimit()?.toString() ?? '',
        ),
        decoration: const InputDecoration(
          labelText: 'Limite (nombre de produits)',
          border: OutlineInputBorder(),
          hintText: 'Laisser vide pour tout afficher',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          final limit = value.isEmpty ? null : int.tryParse(value);
          _updateDataSourceConfig('limit', limit);
        },
      ),
      const SizedBox(height: 8),
      const Text(
        'DataSource: produits connectés à Firestore',
        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ];
  }

  List<Widget> _buildCategoryListFields() {
    return [
      TextField(
        controller: TextEditingController(text: _properties['title']?.toString()),
        decoration: const InputDecoration(
          labelText: 'Titre',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _updateProperty('title', value),
      ),
      const SizedBox(height: 16),
      const Text(
        'DataSource: catégories connectées à Firestore',
        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text(
        'Les catégories sont extraites automatiquement des produits disponibles.',
        style: TextStyle(color: Colors.grey, fontSize: 11),
      ),
    ];
  }

  Widget _buildStylingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Style',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(text: _styling?['color']?.toString()),
          decoration: const InputDecoration(
            labelText: 'Couleur (hex)',
            border: OutlineInputBorder(),
            hintText: '#FF5733',
          ),
          onChanged: (value) => _updateStyling('color', value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(
            text: _styling?['backgroundColor']?.toString(),
          ),
          decoration: const InputDecoration(
            labelText: 'Couleur de fond (hex)',
            border: OutlineInputBorder(),
            hintText: '#FFFFFF',
          ),
          onChanged: (value) => _updateStyling('backgroundColor', value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(
            text: _styling?['padding']?.toString() ?? '8.0',
          ),
          decoration: const InputDecoration(
            labelText: 'Padding',
            border: OutlineInputBorder(),
            suffixText: 'px',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
          onChanged: (value) => _updateStyling('padding', double.tryParse(value) ?? 8.0),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    if (widget.block.type != WidgetBlockType.button) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(text: _actions?['onTap']?.toString()),
          decoration: const InputDecoration(
            labelText: 'Action (onTap)',
            border: OutlineInputBorder(),
            hintText: 'navigate:/menu',
          ),
          onChanged: (value) => _updateAction('onTap', value),
        ),
        const SizedBox(height: 8),
        const Text(
          'Exemples: navigate:/menu, navigate:/cart, back',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _updateProperty(String key, dynamic value) {
    setState(() {
      _properties[key] = value;
    });
    _notifyUpdate();
  }

  void _updateStyling(String key, dynamic value) {
    setState(() {
      _styling![key] = value;
    });
    _notifyUpdate();
  }

  void _updateAction(String key, dynamic value) {
    setState(() {
      _actions![key] = value;
    });
    _notifyUpdate();
  }

  void _notifyUpdate() {
    final updatedBlock = widget.block.copyWith(
      properties: _properties,
      styling: _styling,
      actions: _actions,
      dataSource: _dataSource,
    );
    widget.onBlockUpdated(updatedBlock);
  }

  void _updateDataSourceConfig(String key, dynamic value) {
    if (_dataSource != null) {
      setState(() {
        final newConfig = Map<String, dynamic>.from(_dataSource!.config);
        if (value == null || (value is String && value.isEmpty)) {
          newConfig.remove(key);
        } else {
          newConfig[key] = value;
        }
        _dataSource = _dataSource!.copyWith(config: newConfig);
      });
      _notifyUpdate();
      developer.log('🔧 BlockEditorPanel: Updated DataSource config: $key = $value');
    }
  }

  String? _getCategoryFilter() {
    return _dataSource?.config['category'] as String? ?? '';
  }

  int? _getDataSourceLimit() {
    return _dataSource?.config['limit'] as int?;
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
        return 'Produits';
      case WidgetBlockType.categoryList:
        return 'Catégories';
      case WidgetBlockType.custom:
        return 'Custom';
    }
  }
}
