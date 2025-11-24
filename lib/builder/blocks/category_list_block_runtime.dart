// lib/builder/blocks/category_list_block_runtime.dart
// Runtime version of CategoryListBlock - Phase 5 enhanced

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../utils/block_config_helper.dart';
import '../utils/action_helper.dart';
import '../../src/models/product.dart';

/// Category list block for displaying category navigation
/// 
/// Configuration:
/// - title: Section title (default: '')
/// - layout: Display layout - horizontal, grid (default: horizontal)
/// - columns: Grid columns (default: 2 mobile, 4 desktop)
/// - showIcons: Display category icons (default: true)
/// - iconSize: Icon size in pixels (default: 24)
/// - categoryStyle: Style - badge, card, circle (default: card)
/// - spacing: Spacing between items (default: 12)
/// - padding: Padding around container (default: 12)
/// - margin: Margin around container (default: 0)
/// - backgroundColor: Background color in hex (default: transparent)
/// - borderRadius: Corner radius (default: 8)
/// - tapAction: Action when category is tapped (openPage, openUrl, scrollToBlock)
/// 
/// Responsive: Horizontal on mobile, grid adapts columns based on screen size
class CategoryListBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  // Responsive breakpoints
  static const double _mobileBreakpoint = 600.0;
  static const double _desktopBreakpoint = 800.0;

  const CategoryListBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get configuration with defaults
    final title = helper.getString('title', defaultValue: '');
    final layout = helper.getString('layout', defaultValue: 'horizontal');
    final columns = _calculateColumns(helper, context);
    final showIcons = helper.getBool('showIcons', defaultValue: true);
    final iconSize = helper.getDouble('iconSize', defaultValue: 24.0);
    final categoryStyle = helper.getString('categoryStyle', defaultValue: 'card');
    final spacing = helper.getDouble('spacing', defaultValue: 12.0);
    final padding = helper.getEdgeInsets('padding', defaultValue: const EdgeInsets.all(12));
    final margin = helper.getEdgeInsets('margin');
    final backgroundColor = helper.getColor('backgroundColor');
    final borderRadius = helper.getDouble('borderRadius', defaultValue: 8.0);
    final tapActionConfig = block.config['tapAction'] as Map<String, dynamic>?;

    // Get categories
    final categories = _getCategories();

    if (categories.isEmpty) {
      return _buildPlaceholder(padding, margin, backgroundColor, borderRadius);
    }

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing),
        ],
        _buildLayout(
          context,
          categories,
          layout,
          columns,
          showIcons,
          iconSize,
          categoryStyle,
          spacing,
          borderRadius,
          tapActionConfig,
        ),
      ],
    );

    // Apply padding
    content = Padding(
      padding: padding,
      child: content,
    );

    // Apply background color and border radius
    if (backgroundColor != null || borderRadius > 0) {
      content = Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
        ),
        child: content,
      );
    }

    // Apply margin
    if (margin != EdgeInsets.zero) {
      content = Padding(
        padding: margin,
        child: content,
      );
    }

    return content;
  }

  /// Calculate grid columns based on screen size and config
  int _calculateColumns(BlockConfigHelper helper, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < _mobileBreakpoint;
    
    // Use config value if provided, otherwise use responsive defaults
    if (helper.has('columns')) {
      return helper.getInt('columns', defaultValue: isMobile ? 2 : 4);
    }
    
    return isMobile ? 2 : 4;
  }

  /// Get default categories
  List<_CategoryItem> _getCategories() {
    return ProductCategory.values.map((category) {
      return _CategoryItem(
        name: category.value,
        icon: _getCategoryIcon(category),
        category: category,
      );
    }).toList();
  }

  /// Get icon for category
  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.pizza:
        return Icons.local_pizza;
      case ProductCategory.menus:
        return Icons.restaurant_menu;
      case ProductCategory.boissons:
        return Icons.local_drink;
      case ProductCategory.desserts:
        return Icons.cake;
    }
  }

  /// Build layout based on configuration
  Widget _buildLayout(
    BuildContext context,
    List<_CategoryItem> categories,
    String layout,
    int columns,
    bool showIcons,
    double iconSize,
    String categoryStyle,
    double spacing,
    double borderRadius,
    Map<String, dynamic>? tapActionConfig,
  ) {
    switch (layout.toLowerCase()) {
      case 'grid':
        return _buildGrid(
          context,
          categories,
          columns,
          showIcons,
          iconSize,
          categoryStyle,
          spacing,
          borderRadius,
          tapActionConfig,
        );
      case 'horizontal':
      default:
        return _buildHorizontal(
          context,
          categories,
          showIcons,
          iconSize,
          categoryStyle,
          spacing,
          borderRadius,
          tapActionConfig,
        );
    }
  }

  /// Build horizontal layout
  Widget _buildHorizontal(
    BuildContext context,
    List<_CategoryItem> categories,
    bool showIcons,
    double iconSize,
    String categoryStyle,
    double spacing,
    double borderRadius,
    Map<String, dynamic>? tapActionConfig,
  ) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: EdgeInsets.only(right: spacing),
            child: _buildCategoryItem(
              context,
              category,
              showIcons,
              iconSize,
              categoryStyle,
              borderRadius,
              tapActionConfig,
              isHorizontal: true,
            ),
          );
        },
      ),
    );
  }

  /// Build grid layout
  Widget _buildGrid(
    BuildContext context,
    List<_CategoryItem> categories,
    int columns,
    bool showIcons,
    double iconSize,
    String categoryStyle,
    double spacing,
    double borderRadius,
    Map<String, dynamic>? tapActionConfig,
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
        final category = categories[index];
        return _buildCategoryItem(
          context,
          category,
          showIcons,
          iconSize,
          categoryStyle,
          borderRadius,
          tapActionConfig,
          isHorizontal: false,
        );
      },
    );
  }

  /// Build category item based on style
  Widget _buildCategoryItem(
    BuildContext context,
    _CategoryItem category,
    bool showIcons,
    double iconSize,
    String categoryStyle,
    double borderRadius,
    Map<String, dynamic>? tapActionConfig, {
    bool isHorizontal = false,
  }) {
    Widget item;
    
    switch (categoryStyle.toLowerCase()) {
      case 'badge':
        item = _buildBadgeStyle(category, showIcons, iconSize, borderRadius);
        break;
      case 'circle':
        item = _buildCircleStyle(category, showIcons, iconSize);
        break;
      case 'card':
      default:
        item = _buildCardStyle(category, showIcons, iconSize, borderRadius, isHorizontal);
    }

    // Wrap with action
    return GestureDetector(
      onTap: () => _handleCategoryTap(context, category, tapActionConfig),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: item,
      ),
    );
  }

  /// Build card style category
  Widget _buildCardStyle(
    _CategoryItem category,
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
              fontSize: 14,
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

  /// Build badge style category
  Widget _buildBadgeStyle(
    _CategoryItem category,
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build circle style category
  Widget _buildCircleStyle(
    _CategoryItem category,
    bool showIcons,
    double iconSize,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          category.name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Handle category tap with custom action or default behavior
  void _handleCategoryTap(
    BuildContext context,
    _CategoryItem category,
    Map<String, dynamic>? tapActionConfig,
  ) {
    // If custom tap action is configured, use ActionHelper
    if (tapActionConfig != null && tapActionConfig.isNotEmpty) {
      ActionHelper.execute(context, BlockAction.fromConfig(tapActionConfig));
      return;
    }

    // Default behavior: navigate to menu with category filter
    ActionHelper.execute(
      context,
      BlockAction(
        type: BlockActionType.openPage,
        value: '/menu?category=${category.category.value}',
      ),
    );
  }

  /// Build placeholder when no categories available
  Widget _buildPlaceholder(
    EdgeInsets padding,
    EdgeInsets margin,
    Color? backgroundColor,
    double borderRadius,
  ) {
    Widget placeholder = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade100,
        borderRadius: borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'No categories available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );

    if (margin != EdgeInsets.zero) {
      placeholder = Padding(padding: margin, child: placeholder);
    }

    return placeholder;
  }
}

/// Internal category item model
class _CategoryItem {
  final String name;
  final IconData icon;
  final ProductCategory category;

  _CategoryItem({
    required this.name,
    required this.icon,
    required this.category,
  });
}
