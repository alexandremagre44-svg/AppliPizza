// lib/builder/blocks/product_list_block_preview.dart
// Product list block preview widget - Phase 6F enhanced

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/block_config_helper.dart';

/// Product List Block Preview
/// 
/// Displays 3 fake placeholder products in grid, carousel, or list layout.
/// Preview version with blue debug border and config summary.
/// Never loads real Firestore products.
class ProductListBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  // Fake product data for preview
  static const List<_FakeProduct> _fakeProducts = [
    _FakeProduct(name: 'Pizza Margherita', price: 12.99, description: 'Classic Italian pizza'),
    _FakeProduct(name: 'Pizza Pepperoni', price: 14.99, description: 'Spicy pepperoni pizza'),
    _FakeProduct(name: 'Pizza Végétarienne', price: 13.99, description: 'Fresh vegetable pizza'),
  ];

  const ProductListBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    return _buildPreviewContent(context);
  }

  /// Main preview content builder - all logic extracted from build()
  Widget _buildPreviewContent(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    final config = _extractConfig(helper, context);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blue.withOpacity(0.6),
          width: 2,
        ),
        borderRadius: config.borderRadius > 0 
            ? BorderRadius.circular(config.borderRadius) 
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with block label and config summary
          _buildHeader(config),
          
          // Content area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: _getTitleCrossAxisAlignment(config.titleAlignment),
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title if present
                if (config.title.isNotEmpty) ...[
                  _buildTitle(config),
                  const SizedBox(height: 12),
                ],
                
                // Layout preview with 3 fake products
                _buildLayoutPreview(config),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Extract all configuration values with safe defaults
  _PreviewConfig _extractConfig(BlockConfigHelper helper, BuildContext context) {
    final title = helper.getString('title', defaultValue: '');
    final titleAlignment = helper.getString('titleAlignment', defaultValue: 'left');
    final titleSize = helper.getString('titleSize', defaultValue: 'medium');
    final categoryId = helper.getString('categoryId', defaultValue: '');
    final layout = helper.getString('layout', defaultValue: 'grid');
    final limitValue = helper.has('limit') ? helper.getInt('limit') : null;
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 8.0);
    final textColor = helper.getColor('textColor', defaultValue: Colors.black87);
    final elevation = helper.getDouble('elevation', defaultValue: 2.0);

    // Calculate responsive columns
    final columns = _calculateResponsiveColumns(context);

    return _PreviewConfig(
      title: title,
      titleAlignment: titleAlignment,
      titleSize: titleSize,
      categoryId: categoryId,
      layout: layout,
      limit: limitValue,
      borderRadius: borderRadius,
      textColor: textColor,
      elevation: elevation,
      columns: columns,
    );
  }

  /// Calculate responsive grid columns based on screen width
  int _calculateResponsiveColumns(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return 2; // Mobile: 2 columns
    } else if (screenWidth < 900) {
      return 3; // Tablet: 3 columns
    } else {
      return 4; // Desktop: 4 columns
    }
  }

  /// Build header with block name and config summary
  Widget _buildHeader(_PreviewConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: config.borderRadius > 0
            ? BorderRadius.vertical(top: Radius.circular(config.borderRadius - 2))
            : null,
      ),
      child: Row(
        children: [
          // Block name label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'PRODUCT_LIST BLOCK',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          // Config summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              _buildConfigSummary(config),
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build config summary string
  String _buildConfigSummary(_PreviewConfig config) {
    final parts = <String>[
      'layout:${config.layout}',
    ];
    
    if (config.categoryId.isNotEmpty) {
      parts.add('cat:${config.categoryId}');
    }
    
    if (config.limit != null) {
      parts.add('limit:${config.limit}');
    }
    
    return parts.join(' ');
  }

  /// Build title widget with alignment and size
  Widget _buildTitle(_PreviewConfig config) {
    final fontSize = _getTitleFontSize(config.titleSize);
    
    return Text(
      config.title,
      textAlign: _getTitleTextAlign(config.titleAlignment),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: config.textColor,
      ),
    );
  }

  /// Get title font size based on titleSize config
  double _getTitleFontSize(String titleSize) {
    switch (titleSize.toLowerCase()) {
      case 'small':
        return 16.0;
      case 'large':
        return 24.0;
      case 'medium':
      default:
        return 20.0;
    }
  }

  /// Get TextAlign from titleAlignment string
  TextAlign _getTitleTextAlign(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
      default:
        return TextAlign.left;
    }
  }

  /// Get CrossAxisAlignment from titleAlignment string
  CrossAxisAlignment _getTitleCrossAxisAlignment(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'right':
        return CrossAxisAlignment.end;
      case 'left':
      default:
        return CrossAxisAlignment.start;
    }
  }

  /// Build layout preview based on config
  Widget _buildLayoutPreview(_PreviewConfig config) {
    switch (config.layout.toLowerCase()) {
      case 'carousel':
        return _buildCarouselPreview(config);
      case 'list':
        return _buildListPreview(config);
      case 'grid':
      default:
        return _buildGridPreview(config);
    }
  }

  /// Build grid preview with fake products
  Widget _buildGridPreview(_PreviewConfig config) {
    // Limit to 3 fake products for preview
    final productCount = config.limit != null && config.limit! < 3 
        ? config.limit! 
        : 3;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: config.columns.clamp(1, 4),
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: productCount,
      itemBuilder: (context, index) => _buildGridProductCard(
        _fakeProducts[index % _fakeProducts.length],
        config,
      ),
    );
  }

  /// Build carousel preview with fake products
  Widget _buildCarouselPreview(_PreviewConfig config) {
    // Limit to 3 fake products for preview
    final productCount = config.limit != null && config.limit! < 3 
        ? config.limit! 
        : 3;
    
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: productCount,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 160,
              child: _buildCarouselProductCard(
                _fakeProducts[index % _fakeProducts.length],
                config,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build list preview with fake products (image left, text right)
  Widget _buildListPreview(_PreviewConfig config) {
    // Limit to 3 fake products for preview
    final productCount = config.limit != null && config.limit! < 3 
        ? config.limit! 
        : 3;
    
    return Column(
      children: List.generate(
        productCount,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildListProductCard(
            _fakeProducts[index % _fakeProducts.length],
            config,
          ),
        ),
      ),
    );
  }

  /// Build product card for grid layout
  Widget _buildGridProductCard(_FakeProduct product, _PreviewConfig config) {
    return Card(
      elevation: config.elevation.clamp(0, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(config.borderRadius.clamp(0, 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(config.borderRadius.clamp(0, 16)),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.local_pizza,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          // Product info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: config.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.price.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build product card for list layout (image left, text right)
  Widget _buildListProductCard(_FakeProduct product, _PreviewConfig config) {
    return Card(
      elevation: config.elevation.clamp(0, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(config.borderRadius.clamp(0, 16)),
      ),
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            // Product image placeholder (left)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(config.borderRadius.clamp(0, 16)),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.local_pizza,
                  size: 32,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            // Product info (right)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: config.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: config.textColor?.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Add icon
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.add_circle_outline,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build product card for carousel layout
  Widget _buildCarouselProductCard(_FakeProduct product, _PreviewConfig config) {
    return Card(
      elevation: config.elevation.clamp(0, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(config.borderRadius.clamp(0, 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(config.borderRadius.clamp(0, 16)),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.local_pizza,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          // Product info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: config.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: config.textColor?.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal configuration class for preview
class _PreviewConfig {
  final String title;
  final String titleAlignment;
  final String titleSize;
  final String categoryId;
  final String layout;
  final int? limit;
  final double borderRadius;
  final Color? textColor;
  final double elevation;
  final int columns;

  const _PreviewConfig({
    required this.title,
    required this.titleAlignment,
    required this.titleSize,
    required this.categoryId,
    required this.layout,
    required this.limit,
    required this.borderRadius,
    required this.textColor,
    required this.elevation,
    required this.columns,
  });
}

/// Fake product data for preview (never loads real data)
class _FakeProduct {
  final String name;
  final double price;
  final String description;

  const _FakeProduct({
    required this.name,
    required this.price,
    required this.description,
  });
}
