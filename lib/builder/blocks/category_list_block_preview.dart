// lib/builder/blocks/category_list_block_preview.dart
// Category list block preview widget

import 'package:flutter/material.dart';
import '../models/models.dart';

/// Category List Block Preview
/// 
/// Displays a horizontal list of category cards.
class CategoryListBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const CategoryListBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final categoryIds = block.getConfig<List>('categoryIds', []);
    final categoryCount = categoryIds.isNotEmpty ? categoryIds.length : 4;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Catégories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categoryCount.clamp(0, 8),
              itemBuilder: (context, index) {
                return _buildCategoryCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(int index) {
    final colors = [
      Colors.red.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.teal.shade100,
      Colors.pink.shade100,
      Colors.amber.shade100,
    ];

    final icons = [
      Icons.local_pizza,
      Icons.fastfood,
      Icons.restaurant,
      Icons.cake,
      Icons.local_cafe,
      Icons.icecream,
      Icons.lunch_dining,
      Icons.dinner_dining,
    ];

    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors[index % colors.length],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icons[index % icons.length],
                size: 36,
                color: Colors.black87,
              ),
              const SizedBox(height: 8),
              Text(
                'Cat ${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
