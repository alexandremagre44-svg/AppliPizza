// lib/src/widgets/page_renderer.dart
// Page renderer for B3 dynamic page architecture
// Builds Flutter widgets from PageSchema configurations

import 'package:flutter/material.dart';
import '../models/page_schema.dart';

/// Widget that renders a page from a PageSchema
class PageRenderer extends StatelessWidget {
  final PageSchema pageSchema;

  const PageRenderer({
    Key? key,
    required this.pageSchema,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sort blocks by order
    final sortedBlocks = List<WidgetBlock>.from(pageSchema.blocks)
      ..sort((a, b) => a.order.compareTo(b.order));

    // Filter visible blocks
    final visibleBlocks = sortedBlocks.where((block) => block.visible).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(pageSchema.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: visibleBlocks.map((block) => _buildBlock(context, block)).toList(),
        ),
      ),
    );
  }

  /// Build a widget from a WidgetBlock
  Widget _buildBlock(BuildContext context, WidgetBlock block) {
    switch (block.type) {
      case WidgetBlockType.text:
        return _buildTextBlock(context, block);
      case WidgetBlockType.image:
        return _buildImageBlock(context, block);
      case WidgetBlockType.button:
        return _buildButtonBlock(context, block);
      case WidgetBlockType.banner:
        return _buildBannerBlock(context, block);
      case WidgetBlockType.productList:
        return _buildProductListBlock(context, block);
      case WidgetBlockType.categoryList:
        return _buildCategoryListBlock(context, block);
      case WidgetBlockType.custom:
      default:
        return _buildCustomBlock(context, block);
    }
  }

  /// Build a text block
  Widget _buildTextBlock(BuildContext context, WidgetBlock block) {
    final text = block.properties['text'] as String? ?? '';
    final fontSize = (block.properties['fontSize'] as num?)?.toDouble() ?? 16.0;
    final fontWeight = block.properties['bold'] == true ? FontWeight.bold : FontWeight.normal;
    final textAlign = _parseTextAlign(block.properties['align'] as String?);
    
    final color = _parseColor(block.styling?['color'] as String?);
    final padding = _parsePadding(block.styling?['padding']);

    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
        textAlign: textAlign,
      ),
    );
  }

  /// Build an image block
  Widget _buildImageBlock(BuildContext context, WidgetBlock block) {
    final imageUrl = block.properties['url'] as String? ?? '';
    final height = (block.properties['height'] as num?)?.toDouble();
    final width = (block.properties['width'] as num?)?.toDouble();
    final fit = _parseBoxFit(block.properties['fit'] as String?);
    
    final padding = _parsePadding(block.styling?['padding']);

    if (imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height ?? 200,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 50),
            ),
          );
        },
      ),
    );
  }

  /// Build a button block
  Widget _buildButtonBlock(BuildContext context, WidgetBlock block) {
    final label = block.properties['label'] as String? ?? 'Button';
    final action = block.actions?['onTap'] as String?;
    
    final padding = _parsePadding(block.styling?['padding']);
    final backgroundColor = _parseColor(block.styling?['backgroundColor'] as String?);
    final textColor = _parseColor(block.styling?['textColor'] as String?);

    return Padding(
      padding: padding,
      child: ElevatedButton(
        onPressed: action != null ? () => _handleAction(context, action, block.actions) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
        ),
        child: Text(label),
      ),
    );
  }

  /// Build a banner block
  Widget _buildBannerBlock(BuildContext context, WidgetBlock block) {
    final text = block.properties['text'] as String? ?? '';
    final backgroundColor = _parseColor(block.styling?['backgroundColor'] as String?) ?? 
                           Theme.of(context).primaryColor;
    final textColor = _parseColor(block.styling?['textColor'] as String?) ?? Colors.white;
    final padding = _parsePadding(block.styling?['padding']);

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Build a product list block (placeholder for now)
  Widget _buildProductListBlock(BuildContext context, WidgetBlock block) {
    final title = block.properties['title'] as String? ?? 'Produits';
    final padding = _parsePadding(block.styling?['padding']);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(
              child: Text('Product List (à implémenter avec DataSource)'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a category list block (placeholder for now)
  Widget _buildCategoryListBlock(BuildContext context, WidgetBlock block) {
    final title = block.properties['title'] as String? ?? 'Catégories';
    final padding = _parsePadding(block.styling?['padding']);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Container(
            height: 150,
            color: Colors.grey[200],
            child: const Center(
              child: Text('Category List (à implémenter avec DataSource)'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a custom block (fallback)
  Widget _buildCustomBlock(BuildContext context, WidgetBlock block) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.amber[100],
      child: Text('Custom Block: ${block.id} (type: ${block.type.value})'),
    );
  }

  /// Handle button actions
  void _handleAction(BuildContext context, String action, Map<String, dynamic>? actionData) {
    // Parse action
    if (action.startsWith('navigate:')) {
      final route = action.substring('navigate:'.length);
      Navigator.pushNamed(context, route);
    } else if (action == 'back') {
      Navigator.pop(context);
    }
    // Add more action types as needed
  }

  /// Parse color from hex string
  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;
    
    try {
      if (colorStr.startsWith('#')) {
        final hexColor = colorStr.substring(1);
        if (hexColor.length == 6) {
          return Color(int.parse('FF$hexColor', radix: 16));
        } else if (hexColor.length == 8) {
          return Color(int.parse(hexColor, radix: 16));
        }
      }
    } catch (e) {
      // Invalid color format
    }
    return null;
  }

  /// Parse padding from various formats
  EdgeInsets _parsePadding(dynamic paddingData) {
    if (paddingData == null) {
      return const EdgeInsets.all(8.0);
    }

    if (paddingData is num) {
      return EdgeInsets.all(paddingData.toDouble());
    }

    if (paddingData is Map) {
      final top = (paddingData['top'] as num?)?.toDouble() ?? 8.0;
      final right = (paddingData['right'] as num?)?.toDouble() ?? 8.0;
      final bottom = (paddingData['bottom'] as num?)?.toDouble() ?? 8.0;
      final left = (paddingData['left'] as num?)?.toDouble() ?? 8.0;
      return EdgeInsets.fromLTRB(left, top, right, bottom);
    }

    return const EdgeInsets.all(8.0);
  }

  /// Parse TextAlign from string
  TextAlign _parseTextAlign(String? align) {
    switch (align?.toLowerCase()) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      default:
        return TextAlign.start;
    }
  }

  /// Parse BoxFit from string
  BoxFit _parseBoxFit(String? fit) {
    switch (fit?.toLowerCase()) {
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fitwidth':
        return BoxFit.fitWidth;
      case 'fitheight':
        return BoxFit.fitHeight;
      default:
        return BoxFit.cover;
    }
  }
}
