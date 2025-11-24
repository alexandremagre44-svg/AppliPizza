// lib/builder/blocks/category_list_block_preview.dart
// Category list block preview widget - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/block_config_helper.dart';

/// Category List Block Preview
/// 
/// Displays mock categories in horizontal or grid layout.
/// Preview version with debug borders and stable rendering even with empty config.
class CategoryListBlockPreview extends StatelessWidget {
  final BuilderBlock block;

  const CategoryListBlockPreview({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults matching runtime
    final title = helper.getString('title', defaultValue: '');
    final layout = helper.getString('layout', defaultValue: 'horizontal');
    final columns = helper.getInt('columns', defaultValue: 2);
    final showIcons = helper.getBool('showIcons', defaultValue: true);
    final iconSize = helper.getDouble('iconSize', defaultValue: 24.0);
    final categoryStyle = helper.getString('categoryStyle', defaultValue: 'card');
    final spacing = helper.getDouble('spacing', defaultValue: 12.0);
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 8.0);

    // Mock categories for preview
    final categories = [
      _PreviewCategory('Pizza', Icons.local_pizza),
      _PreviewCategory('Desserts', Icons.cake),
      _PreviewCategory('Drinks', Icons.local_drink),
      _PreviewCategory('Pasta', Icons.restaurant),
    ];

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.purple.withOpacity(0.5),
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
                  color: Colors.purple.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CATEGORIES',
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
                  'layout:$layout style:$categoryStyle',
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
            SizedBox(height: spacing),
          ],
          
          // Layout preview
          _buildLayoutPreview(
            layout,
            columns,
            categories,
            showIcons,
            iconSize,
            categoryStyle,
            spacing,
            borderRadius,
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutPreview(
    String layout,
    int columns,
    List<_PreviewCategory> categories,
    bool showIcons,
    double iconSize,
    String categoryStyle,
    double spacing,
    double borderRadius,
  ) {
    switch (layout.toLowerCase()) {
      case 'grid':
        return _buildGridPreview(categories, columns, showIcons, iconSize, categoryStyle, spacing, borderRadius);
      case 'horizontal':
      default:
        return _buildHorizontalPreview(categories, showIcons, iconSize, categoryStyle, spacing, borderRadius);
    }
  }

  Widget _buildHorizontalPreview(
    List<_PreviewCategory> categories,
    bool showIcons,
    double iconSize,
    String categoryStyle,
    double spacing,
    double borderRadius,
  ) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: spacing),
            child: _buildCategoryItem(
              categories[index],
              showIcons,
              iconSize,
              categoryStyle,
              borderRadius,
              isHorizontal: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridPreview(
    List<_PreviewCategory> categories,
    int columns,
    bool showIcons,
    double iconSize,
    String categoryStyle,
    double spacing,
    double borderRadius,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: 2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryItem(
          categories[index],
          showIcons,
          iconSize,
          categoryStyle,
          borderRadius,
          isHorizontal: false,
        );
      },
    );
  }

  Widget _buildCategoryItem(
    _PreviewCategory category,
    bool showIcons,
    double iconSize,
    String categoryStyle,
    double borderRadius, {
    bool isHorizontal = false,
  }) {
    switch (categoryStyle.toLowerCase()) {
      case 'badge':
        return _buildBadgeStyle(category, showIcons, iconSize, borderRadius);
      case 'circle':
        return _buildCircleStyle(category, showIcons, iconSize);
      case 'card':
      default:
        return _buildCardStyle(category, showIcons, iconSize, borderRadius, isHorizontal);
    }
  }

  Widget _buildCardStyle(
    _PreviewCategory category,
    bool showIcons,
    double iconSize,
    double borderRadius,
    bool isHorizontal,
  ) {
    return Container(
      width: isHorizontal ? 100 : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD32F2F).withOpacity(0.1),
            const Color(0xFFD32F2F).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: const Color(0xFFD32F2F).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcons)
            Icon(
              category.icon,
              size: iconSize,
              color: const Color(0xFFD32F2F),
            ),
          if (showIcons) const SizedBox(height: 8),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD32F2F),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeStyle(
    _PreviewCategory category,
    bool showIcons,
    double iconSize,
    double borderRadius,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcons) ...[
            Icon(
              category.icon,
              size: iconSize,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleStyle(
    _PreviewCategory category,
    bool showIcons,
    double iconSize,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFD32F2F).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: showIcons
                ? Icon(
                    category.icon,
                    size: iconSize,
                    color: const Color(0xFFD32F2F),
                  )
                : Text(
                    category.name[0],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          category.name,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Internal preview category model
class _PreviewCategory {
  final String name;
  final IconData icon;

  _PreviewCategory(this.name, this.icon);
}
