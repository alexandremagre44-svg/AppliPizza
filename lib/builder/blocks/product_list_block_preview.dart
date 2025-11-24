// lib/builder/blocks/product_list_block_preview.dart
// Product list block preview widget

import 'package:flutter/material.dart';
import '../models/models.dart';

/// Product List Block Preview
/// 
/// Displays a grid of product placeholders.
/// No actual product data loading - just visual placeholders.
class ProductListBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const ProductListBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final mode = block.getConfig<String>('mode', 'manual') ?? 'manual';
    final productIds = block.getConfig<List>('productIds', []) ?? [];

    final productCount = productIds.isNotEmpty ? productIds.length : 4;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant_menu, size: 20),
              const SizedBox(width: 8),
              Text(
                'Produits ($mode)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: productCount.clamp(0, 6),
            itemBuilder: (context, index) {
              return _buildProductCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
          // Product info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produit ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(index + 1) * 5}.99 €',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
