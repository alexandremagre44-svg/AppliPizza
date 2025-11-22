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
      case WidgetBlockType.heroAdvanced:
        return _buildHeroAdvancedFields();
      case WidgetBlockType.carousel:
        return _buildCarouselFields();
      case WidgetBlockType.popup:
        return _buildPopupFields();
      case WidgetBlockType.productSlider:
        return [const Text('Product Slider (configuration minimale)')];
      case WidgetBlockType.categorySlider:
        return [const Text('Category Slider (configuration minimale)')];
      case WidgetBlockType.promoBanner:
        return [const Text('Promo Banner (configuration minimale)')];
      case WidgetBlockType.stickyCta:
        return [const Text('Sticky CTA (configuration minimale)')];
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

  List<Widget> _buildHeroAdvancedFields() {
    final List<Widget> fields = [];
    
    // === IMAGE SECTION ===
    fields.addAll([
      const Text('Image de fond', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: TextEditingController(text: _properties['imageUrl']?.toString()),
        decoration: const InputDecoration(
          labelText: 'URL de l\'image',
          border: OutlineInputBorder(),
          hintText: 'https://...',
        ),
        onChanged: (value) => _updateProperty('imageUrl', value),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: TextEditingController(
          text: _properties['height']?.toString() ?? '400',
        ),
        decoration: const InputDecoration(
          labelText: 'Hauteur',
          border: OutlineInputBorder(),
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
        onChanged: (value) => _updateProperty('height', double.tryParse(value) ?? 400.0),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: TextEditingController(
          text: _properties['borderRadius']?.toString() ?? '0',
        ),
        decoration: const InputDecoration(
          labelText: 'Border Radius',
          border: OutlineInputBorder(),
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
        onChanged: (value) => _updateProperty('borderRadius', double.tryParse(value) ?? 0.0),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _properties['imageFit']?.toString() ?? 'cover',
        decoration: const InputDecoration(
          labelText: 'Ajustement image',
          border: OutlineInputBorder(),
        ),
        items: ['cover', 'contain', 'fill', 'fitWidth', 'fitHeight']
            .map((fit) => DropdownMenuItem(value: fit, child: Text(fit)))
            .toList(),
        onChanged: (value) => _updateProperty('imageFit', value),
      ),
      const Divider(height: 32),
    ]);
    
    // === OVERLAY SECTION ===
    fields.addAll([
      const Text('Overlay / Gradient', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      SwitchListTile(
        title: const Text('Utiliser un gradient'),
        value: _properties['hasGradient'] == true,
        onChanged: (value) => _updateProperty('hasGradient', value),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
      if (_properties['hasGradient'] != true) ...[
        TextField(
          controller: TextEditingController(text: _properties['overlayColor']?.toString()),
          decoration: const InputDecoration(
            labelText: 'Couleur overlay (hex)',
            border: OutlineInputBorder(),
            hintText: '#000000',
          ),
          onChanged: (value) => _updateProperty('overlayColor', value),
        ),
      ] else ...[
        TextField(
          controller: TextEditingController(text: _properties['gradientStartColor']?.toString()),
          decoration: const InputDecoration(
            labelText: 'Couleur début (hex)',
            border: OutlineInputBorder(),
            hintText: '#000000',
          ),
          onChanged: (value) => _updateProperty('gradientStartColor', value),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: TextEditingController(text: _properties['gradientEndColor']?.toString()),
          decoration: const InputDecoration(
            labelText: 'Couleur fin (hex)',
            border: OutlineInputBorder(),
            hintText: '#00000000',
          ),
          onChanged: (value) => _updateProperty('gradientEndColor', value),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _properties['gradientDirection']?.toString() ?? 'vertical',
          decoration: const InputDecoration(
            labelText: 'Direction gradient',
            border: OutlineInputBorder(),
          ),
          items: ['vertical', 'horizontal']
              .map((dir) => DropdownMenuItem(value: dir, child: Text(dir)))
              .toList(),
          onChanged: (value) => _updateProperty('gradientDirection', value),
        ),
      ],
      const SizedBox(height: 12),
      TextField(
        controller: TextEditingController(
          text: _properties['overlayOpacity']?.toString() ?? '0.4',
        ),
        decoration: const InputDecoration(
          labelText: 'Opacité',
          border: OutlineInputBorder(),
          hintText: '0.0 - 1.0',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        onChanged: (value) {
          final opacity = double.tryParse(value) ?? 0.4;
          _updateProperty('overlayOpacity', opacity.clamp(0.0, 1.0));
        },
      ),
      const Divider(height: 32),
    ]);
    
    // === CONTENT SECTION ===
    fields.addAll([
      const Text('Contenu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: TextEditingController(text: _properties['title']?.toString()),
        decoration: const InputDecoration(
          labelText: 'Titre',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) => _updateProperty('title', value),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: TextEditingController(text: _properties['subtitle']?.toString()),
        decoration: const InputDecoration(
          labelText: 'Sous-titre',
          border: OutlineInputBorder(),
        ),
        maxLines: 2,
        onChanged: (value) => _updateProperty('subtitle', value),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: TextEditingController(text: _properties['titleColor']?.toString()),
        decoration: const InputDecoration(
          labelText: 'Couleur titre (hex)',
          border: OutlineInputBorder(),
          hintText: '#FFFFFF',
        ),
        onChanged: (value) => _updateProperty('titleColor', value),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: TextEditingController(text: _properties['subtitleColor']?.toString()),
        decoration: const InputDecoration(
          labelText: 'Couleur sous-titre (hex)',
          border: OutlineInputBorder(),
          hintText: '#FFFFFFB3',
        ),
        onChanged: (value) => _updateProperty('subtitleColor', value),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _properties['contentAlign']?.toString() ?? 'center',
        decoration: const InputDecoration(
          labelText: 'Alignement',
          border: OutlineInputBorder(),
        ),
        items: ['center', 'left', 'right', 'top', 'bottom']
            .map((align) => DropdownMenuItem(value: align, child: Text(align)))
            .toList(),
        onChanged: (value) => _updateProperty('contentAlign', value),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: TextEditingController(
          text: _properties['spacing']?.toString() ?? '8',
        ),
        decoration: const InputDecoration(
          labelText: 'Espacement',
          border: OutlineInputBorder(),
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
        onChanged: (value) => _updateProperty('spacing', double.tryParse(value) ?? 8.0),
      ),
      const Divider(height: 32),
    ]);
    
    // === CTA BUTTONS SECTION ===
    fields.addAll([
      Row(
        children: [
          const Text('CTA Buttons', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: _addCTAButton,
            tooltip: 'Ajouter un CTA',
          ),
        ],
      ),
      const SizedBox(height: 8),
    ]);
    
    final ctas = _properties['ctas'] as List<dynamic>? ?? [];
    for (int i = 0; i < ctas.length && i < 3; i++) {
      fields.add(_buildCTAEditor(i, ctas[i] as Map<String, dynamic>));
      fields.add(const SizedBox(height: 12));
    }
    
    if (ctas.isEmpty) {
      fields.add(const Text('Aucun CTA. Cliquez sur + pour en ajouter.', style: TextStyle(color: Colors.grey, fontSize: 12)));
    }
    
    return fields;
  }

  Widget _buildCTAEditor(int index, Map<String, dynamic> cta) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('CTA ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () => _removeCTAButton(index),
                  tooltip: 'Supprimer',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: cta['label']?.toString()),
              decoration: const InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => _updateCTA(index, 'label', value),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: cta['action']?.toString()),
              decoration: const InputDecoration(
                labelText: 'Action',
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'navigate:/menu',
              ),
              onChanged: (value) => _updateCTA(index, 'action', value),
            ),
          ],
        ),
      ),
    );
  }

  void _addCTAButton() {
    final ctas = List<Map<String, dynamic>>.from(_properties['ctas'] as List<dynamic>? ?? []);
    if (ctas.length >= 3) {
      return; // Max 3 CTAs
    }
    ctas.add({
      'label': 'Nouveau CTA',
      'action': 'navigate:/menu',
      'backgroundColor': '#D62828',
      'textColor': '#FFFFFF',
      'borderRadius': 8.0,
      'padding': 16.0,
    });
    setState(() {
      _properties['ctas'] = ctas;
    });
    _notifyUpdate();
  }

  void _removeCTAButton(int index) {
    final ctas = List<Map<String, dynamic>>.from(_properties['ctas'] as List<dynamic>? ?? []);
    if (index >= 0 && index < ctas.length) {
      ctas.removeAt(index);
      setState(() {
        _properties['ctas'] = ctas;
      });
      _notifyUpdate();
    }
  }

  void _updateCTA(int index, String key, dynamic value) {
    final ctas = List<Map<String, dynamic>>.from(_properties['ctas'] as List<dynamic>? ?? []);
    if (index >= 0 && index < ctas.length) {
      ctas[index][key] = value;
      setState(() {
        _properties['ctas'] = ctas;
      });
      _notifyUpdate();
    }
  }

  /// Build fields for carousel block (B3.5.B)
  List<Widget> _buildCarouselFields() {
    final carouselType = _properties['carouselType'] as String? ?? 'images';
    
    return [
      // Carousel Type
      DropdownButtonFormField<String>(
        value: carouselType,
        decoration: const InputDecoration(
          labelText: 'Type de carrousel',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: 'images', child: Text('Images')),
          const DropdownMenuItem(value: 'products', child: Text('Produits')),
          const DropdownMenuItem(value: 'categories', child: Text('Catégories')),
        ],
        onChanged: (value) {
          _updateProperty('carouselType', value);
          // Initialize DataSource for products/categories
          if (value == 'products' || value == 'categories') {
            final sourceType = value == 'products'
                ? DataSourceType.products
                : DataSourceType.categories;
            _dataSource = DataSource(
              id: 'datasource_${widget.block.id}',
              type: sourceType,
              config: {},
            );
          }
        },
      ),
      const SizedBox(height: 16),
      
      // Height
      TextField(
        controller: TextEditingController(
          text: _properties['height']?.toString() ?? '250',
        ),
        decoration: const InputDecoration(
          labelText: 'Hauteur',
          border: OutlineInputBorder(),
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
        onChanged: (value) => _updateProperty('height', double.tryParse(value) ?? 250.0),
      ),
      const SizedBox(height: 16),
      
      // Viewport Fraction
      TextField(
        controller: TextEditingController(
          text: _properties['viewportFraction']?.toString() ?? '0.85',
        ),
        decoration: const InputDecoration(
          labelText: 'Viewport Fraction',
          border: OutlineInputBorder(),
          hintText: '0.85 (0.5 - 1.0)',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
        onChanged: (value) {
          final val = double.tryParse(value) ?? 0.85;
          _updateProperty('viewportFraction', val.clamp(0.5, 1.0));
        },
      ),
      const SizedBox(height: 16),
      
      // Border Radius
      TextField(
        controller: TextEditingController(
          text: _properties['borderRadius']?.toString() ?? '12',
        ),
        decoration: const InputDecoration(
          labelText: 'Border Radius',
          border: OutlineInputBorder(),
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
        onChanged: (value) => _updateProperty('borderRadius', double.tryParse(value) ?? 12.0),
      ),
      const SizedBox(height: 16),
      
      // AutoPlay
      SwitchListTile(
        title: const Text('AutoPlay'),
        value: _properties['autoPlay'] as bool? ?? false,
        onChanged: (value) => _updateProperty('autoPlay', value),
      ),
      
      // AutoPlay Interval
      if (_properties['autoPlay'] == true) ...[
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(
            text: _properties['autoPlayIntervalMs']?.toString() ?? '3000',
          ),
          decoration: const InputDecoration(
            labelText: 'Intervalle AutoPlay',
            border: OutlineInputBorder(),
            suffixText: 'ms',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _updateProperty('autoPlayIntervalMs', int.tryParse(value) ?? 3000),
        ),
      ],
      const SizedBox(height: 16),
      
      // Enlarge Center Page
      SwitchListTile(
        title: const Text('Agrandir page centrale'),
        value: _properties['enlargeCenterPage'] as bool? ?? true,
        onChanged: (value) => _updateProperty('enlargeCenterPage', value),
      ),
      const SizedBox(height: 16),
      
      // Show Indicators
      SwitchListTile(
        title: const Text('Afficher indicateurs'),
        value: _properties['showIndicators'] as bool? ?? true,
        onChanged: (value) => _updateProperty('showIndicators', value),
      ),
      
      // Indicator Colors
      if (_properties['showIndicators'] == true) ...[
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(text: _properties['indicatorColor']?.toString() ?? '#9E9E9E'),
          decoration: const InputDecoration(
            labelText: 'Couleur indicateur',
            border: OutlineInputBorder(),
            hintText: '#9E9E9E',
          ),
          onChanged: (value) => _updateProperty('indicatorColor', value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(text: _properties['indicatorActiveColor']?.toString() ?? '#2196F3'),
          decoration: const InputDecoration(
            labelText: 'Couleur indicateur actif',
            border: OutlineInputBorder(),
            hintText: '#2196F3',
          ),
          onChanged: (value) => _updateProperty('indicatorActiveColor', value),
        ),
      ],
      
      const SizedBox(height: 24),
      const Divider(),
      const SizedBox(height: 16),
      
      // Type-specific fields
      if (carouselType == 'images') ..._buildImageSlideFields(),
      if (carouselType == 'products') ..._buildProductCarouselFields(),
      if (carouselType == 'categories') ..._buildCategoryCarouselFields(),
    ];
  }

  /// Build fields for image slides
  List<Widget> _buildImageSlideFields() {
    final slides = List<Map<String, dynamic>>.from(_properties['slides'] as List<dynamic>? ?? []);
    
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Slides (Images)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            onPressed: _addImageSlide,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Ajouter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ...slides.asMap().entries.map((entry) {
        final index = entry.key;
        final slide = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Slide ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _removeImageSlide(index),
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: slide['imageUrl']?.toString()),
                  decoration: const InputDecoration(
                    labelText: 'URL Image',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => _updateImageSlide(index, 'imageUrl', value),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: slide['title']?.toString()),
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => _updateImageSlide(index, 'title', value),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: slide['subtitle']?.toString()),
                  decoration: const InputDecoration(
                    labelText: 'Sous-titre',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => _updateImageSlide(index, 'subtitle', value),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(text: slide['action']?.toString()),
                  decoration: const InputDecoration(
                    labelText: 'Action',
                    border: OutlineInputBorder(),
                    isDense: true,
                    hintText: 'navigate:/menu',
                  ),
                  onChanged: (value) => _updateImageSlide(index, 'action', value),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ];
  }

  /// Build fields for product carousel
  List<Widget> _buildProductCarouselFields() {
    return [
      const Text(
        'Configuration Produits',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      SwitchListTile(
        title: const Text('Afficher prix'),
        value: _properties['showPrice'] as bool? ?? true,
        onChanged: (value) => _updateProperty('showPrice', value),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: TextEditingController(
          text: _dataSource?.config['limit']?.toString() ?? '',
        ),
        decoration: const InputDecoration(
          labelText: 'Limite de produits',
          border: OutlineInputBorder(),
          hintText: 'Laisser vide pour tout',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (_dataSource != null) {
            final config = Map<String, dynamic>.from(_dataSource!.config);
            config['limit'] = value.isEmpty ? null : int.tryParse(value);
            _dataSource = DataSource(
              id: _dataSource!.id,
              type: _dataSource!.type,
              config: config,
            );
            _notifyUpdate();
          }
        },
      ),
    ];
  }

  /// Build fields for category carousel
  List<Widget> _buildCategoryCarouselFields() {
    return [
      const Text(
        'Configuration Catégories',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: TextEditingController(
          text: _dataSource?.config['limit']?.toString() ?? '',
        ),
        decoration: const InputDecoration(
          labelText: 'Limite de catégories',
          border: OutlineInputBorder(),
          hintText: 'Laisser vide pour tout',
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (_dataSource != null) {
            final config = Map<String, dynamic>.from(_dataSource!.config);
            config['limit'] = value.isEmpty ? null : int.tryParse(value);
            _dataSource = DataSource(
              id: _dataSource!.id,
              type: _dataSource!.type,
              config: config,
            );
            _notifyUpdate();
          }
        },
      ),
    ];
  }

  void _addImageSlide() {
    final slides = List<Map<String, dynamic>>.from(_properties['slides'] as List<dynamic>? ?? []);
    slides.add({
      'imageUrl': 'https://picsum.photos/800/600',
      'title': 'Nouveau slide',
      'subtitle': '',
      'action': '',
      'overlayColor': '#000000',
      'overlayOpacity': 0.3,
      'useGradient': false,
    });
    setState(() {
      _properties['slides'] = slides;
    });
    _notifyUpdate();
  }

  void _removeImageSlide(int index) {
    final slides = List<Map<String, dynamic>>.from(_properties['slides'] as List<dynamic>? ?? []);
    if (index >= 0 && index < slides.length) {
      slides.removeAt(index);
      setState(() {
        _properties['slides'] = slides;
      });
      _notifyUpdate();
    }
  }

  void _updateImageSlide(int index, String key, dynamic value) {
    final slides = List<Map<String, dynamic>>.from(_properties['slides'] as List<dynamic>? ?? []);
    if (index >= 0 && index < slides.length) {
      slides[index][key] = value;
      setState(() {
        _properties['slides'] = slides;
      });
      _notifyUpdate();
    }
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

  /// Build popup configuration fields
  List<Widget> _buildPopupFields() {
    return [
      _buildSectionTitle('Contenu'),
      _buildTextField('title', 'Titre', _properties['title'] as String? ?? ''),
      _buildTextField('message', 'Message', _properties['message'] as String? ?? '', maxLines: 3),
      _buildColorField('titleColor', 'Couleur du titre', _properties['titleColor'] as String? ?? '#000000'),
      _buildColorField('messageColor', 'Couleur du message', _properties['messageColor'] as String? ?? '#757575'),
      _buildDropdownField(
        'alignment',
        'Alignement',
        _properties['alignment'] as String? ?? 'center',
        ['start', 'center'],
        (value) {
          _updateProperty('alignment', value);
        },
      ),
      _buildDropdownField(
        'icon',
        'Icône',
        _properties['icon'] as String? ?? '',
        ['', 'info', 'warning', 'promo', 'success', 'error'],
        (value) {
          _updateProperty('icon', value);
        },
      ),
      
      const SizedBox(height: 16),
      _buildSectionTitle('Apparence'),
      _buildColorField('backgroundColor', 'Couleur de fond', _properties['backgroundColor'] as String? ?? '#FFFFFF'),
      _buildNumberField('borderRadius', 'Border Radius (px)', _properties['borderRadius'] as num? ?? 16),
      _buildNumberField('padding', 'Padding (px)', _properties['padding'] as num? ?? 20),
      _buildNumberField('maxWidth', 'Largeur max (px)', _properties['maxWidth'] as num? ?? 300),
      _buildNumberField('elevation', 'Élévation (ombre)', _properties['elevation'] as num? ?? 8),
      _buildColorField('overlayColor', 'Couleur overlay', _properties['overlayColor'] as String? ?? '#000000'),
      _buildSliderField(
        'overlayOpacity',
        'Opacité overlay',
        (_properties['overlayOpacity'] as num?)?.toDouble() ?? 0.5,
        0.0,
        1.0,
      ),
      
      const SizedBox(height: 16),
      _buildSectionTitle('Comportement'),
      _buildSwitchField('showOnLoad', 'Afficher au chargement', _properties['showOnLoad'] as bool? ?? true),
      _buildDropdownField(
        'triggerType',
        'Type de déclencheur',
        _properties['triggerType'] as String? ?? 'onLoad',
        ['onLoad', 'delayed', 'onScrollStart'],
        (value) {
          _updateProperty('triggerType', value);
        },
      ),
      _buildNumberField('delayMs', 'Délai (ms)', _properties['delayMs'] as num? ?? 0),
      _buildSwitchField('dismissibleByTapOutside', 'Fermer en tapant dehors', _properties['dismissibleByTapOutside'] as bool? ?? true),
      _buildSwitchField('showOncePerSession', 'Afficher 1 fois par session', _properties['showOncePerSession'] as bool? ?? false),
      
      const SizedBox(height: 16),
      _buildSectionTitle('CTAs (Boutons)'),
      _buildCTAsManager(),
    ];
  }

  /// Build CTAs manager for popup
  Widget _buildCTAsManager() {
    final ctas = (_properties['ctas'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...ctas.asMap().entries.map((entry) {
          final index = entry.key;
          final cta = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CTA ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          final newCtas = List<Map<String, dynamic>>.from(ctas);
                          newCtas.removeAt(index);
                          _updateProperty('ctas', newCtas);
                        },
                      ),
                    ],
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Label'),
                    controller: TextEditingController(text: cta['label'] as String? ?? ''),
                    onChanged: (value) {
                      final newCtas = List<Map<String, dynamic>>.from(ctas);
                      newCtas[index] = {...cta, 'label': value};
                      _updateProperty('ctas', newCtas);
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Action (ex: navigate:/menu ou dismissOnly)'),
                    controller: TextEditingController(text: cta['action'] as String? ?? 'dismissOnly'),
                    onChanged: (value) {
                      final newCtas = List<Map<String, dynamic>>.from(ctas);
                      newCtas[index] = {...cta, 'action': value};
                      _updateProperty('ctas', newCtas);
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Background Color (hex)'),
                    controller: TextEditingController(text: cta['backgroundColor'] as String? ?? '#2196F3'),
                    onChanged: (value) {
                      final newCtas = List<Map<String, dynamic>>.from(ctas);
                      newCtas[index] = {...cta, 'backgroundColor': value};
                      _updateProperty('ctas', newCtas);
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Text Color (hex)'),
                    controller: TextEditingController(text: cta['textColor'] as String? ?? '#FFFFFF'),
                    onChanged: (value) {
                      final newCtas = List<Map<String, dynamic>>.from(ctas);
                      newCtas[index] = {...cta, 'textColor': value};
                      _updateProperty('ctas', newCtas);
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        
        if (ctas.length < 2)
          ElevatedButton.icon(
            onPressed: () {
              final newCtas = List<Map<String, dynamic>>.from(ctas);
              newCtas.add({
                'label': 'OK',
                'action': 'dismissOnly',
                'backgroundColor': '#2196F3',
                'textColor': '#FFFFFF',
                'borderRadius': 8.0,
              });
              _updateProperty('ctas', newCtas);
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un CTA'),
          ),
      ],
    );
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
        return Icons.view_carousel;
      case WidgetBlockType.popup:
        return Icons.notifications_active;
      case WidgetBlockType.productSlider:
        return Icons.view_carousel;
      case WidgetBlockType.categorySlider:
        return Icons.category;
      case WidgetBlockType.promoBanner:
        return Icons.campaign;
      case WidgetBlockType.stickyCta:
        return Icons.touch_app;
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
      case WidgetBlockType.heroAdvanced:
        return 'Hero Avancé';
      case WidgetBlockType.carousel:
        return 'Carousel';
      case WidgetBlockType.popup:
        return 'Popup';
      case WidgetBlockType.custom:
        return 'Custom';
      case WidgetBlockType.productSlider:
        return 'Product Slider';
      case WidgetBlockType.categorySlider:
        return 'Category Slider';
      case WidgetBlockType.promoBanner:
        return 'Promo Banner';
      case WidgetBlockType.stickyCta:
        return 'Sticky CTA';
    }
  }

  /// Helper method to build a section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// Helper method to build a text field
  Widget _buildTextField(String key, String label, String value, {int maxLines = 1}) {
    return Column(
      children: [
        TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          maxLines: maxLines,
          onChanged: (newValue) => _updateProperty(key, newValue),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Helper method to build a number field
  Widget _buildNumberField(String key, String label, num value) {
    return Column(
      children: [
        TextField(
          controller: TextEditingController(text: value.toString()),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
          onChanged: (newValue) {
            final parsed = double.tryParse(newValue);
            if (parsed != null) {
              _updateProperty(key, parsed);
            }
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Helper method to build a color field
  Widget _buildColorField(String key, String label, String value) {
    return Column(
      children: [
        TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            hintText: '#RRGGBB',
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _parseColor(value),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
          ),
          onChanged: (newValue) => _updateProperty(key, newValue),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return Colors.grey;
    try {
      final hex = colorStr.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      // Invalid color
    }
    return Colors.grey;
  }

  /// Helper method to build a dropdown field
  Widget _buildDropdownField(String key, String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: options.contains(value) ? value : options.first,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option.isEmpty ? '(Aucun)' : option),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Helper method to build a switch field
  Widget _buildSwitchField(String key, String label, bool value) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(label),
          value: value,
          onChanged: (newValue) => _updateProperty(key, newValue),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Helper method to build a slider field
  Widget _buildSliderField(String key, String label, double value, double min, double max, {int? divisions}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                label: value.toStringAsFixed(2),
                onChanged: (newValue) => _updateProperty(key, newValue),
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                value.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
