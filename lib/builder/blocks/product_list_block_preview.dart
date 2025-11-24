// lib/builder/blocks/product_list_block_preview.dart
// Product list block preview widget - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/block_config_helper.dart';

/// Product List Block Preview
/// 
/// Displays mock products in grid, carousel, or list layout.
/// Preview version with debug borders and stable rendering even with empty config.
class ProductListBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const ProductListBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults matching runtime
    final title = helper.getString('title', defaultValue: '');
    final layout = helper.getString('layout', defaultValue: 'grid');
    final columns = helper.getInt('columns', defaultValue: 2);
    final showPrices = helper.getBool('showPrices', defaultValue: true);
    final category = helper.getString('category', defaultValue: '');
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 0.0);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.green.withOpacity(0.5),
          width: 2,
        ),
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRODUCTS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  'layout:$layout cols:$columns${category.isNotEmpty ? ' cat:$category' : ''}',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Title if present
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          // Layout preview
          _buildLayoutPreview(layout, columns, showPrices),
        ],
      ),
    );
  }

  Widget _buildLayoutPreview(String layout, int columns, bool showPrices) {
    switch (layout.toLowerCase()) {
      case 'carousel':
        return _buildCarouselPreview(showPrices);
      case 'list':
        return _buildListPreview(showPrices);
      case 'grid':
      default:
        return _buildGridPreview(columns, showPrices);
    }
  }

  Widget _buildGridPreview(int columns, bool showPrices) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => _buildProductCard(index, showPrices),
    );
  }

  Widget _buildCarouselPreview(bool showPrices) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 120,
              child: _buildProductCard(index, showPrices),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListPreview(bool showPrices) {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildProductCard(index, showPrices, isListView: true),
        ),
      ),
    );
  }

  Widget _buildProductCard(int index, bool showPrices, {bool isListView = false}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: isListView ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Product image placeholder
          if (!isListView)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
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
            )
          else
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.local_pizza,
                  size: 24,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          
          // Product info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Product ${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showPrices) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${(index + 1) * 5}.99 €',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
