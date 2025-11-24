// lib/builder/blocks/category_list_block_runtime.dart
// Runtime version of CategoryListBlock - displays category navigation

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/builder_block.dart';
import '../../src/models/product.dart';
import '../../src/theme/app_theme.dart';
import '../../src/core/constants.dart';

/// Enhanced CategoryListBlockRuntime with configurable categories
/// 
/// Configuration options:
/// - mode: 'auto' (use main categories), 'custom' (specific categories)
/// - categories: List of category IDs for custom mode
/// - title: Optional title for the section
/// - layout: 'grid' or 'horizontal'
class CategoryListBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const CategoryListBlockRuntime({
    super.key,
    required this.block,
  });

  // Helper getters for configuration
  String get _mode => block.getConfig<String>('mode') ?? 'auto';
  String? get _title => block.getConfig<String>('title');
  String get _layout => block.getConfig<String>('layout') ?? 'horizontal';

  List<_CategoryItem> get _categories {
    if (_mode == 'custom') {
      final customCats = block.getConfig<List>('categories') ?? [];
      return customCats
          .map((cat) => _CategoryItem(
                name: cat['name'] as String? ?? '',
                icon: cat['icon'] as String? ?? '🍕',
                route: cat['route'] as String? ?? AppRoutes.menu,
              ))
          .toList();
    }

    // Auto mode: use main categories
    return [
      _CategoryItem(
        name: 'Pizzas',
        icon: '🍕',
        route: AppRoutes.menu,
      ),
      _CategoryItem(
        name: 'Menus',
        icon: '🍽️',
        route: AppRoutes.menu,
      ),
      _CategoryItem(
        name: 'Boissons',
        icon: '🥤',
        route: AppRoutes.menu,
      ),
      _CategoryItem(
        name: 'Desserts',
        icon: '🍰',
        route: AppRoutes.menu,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_title != null && _title!.isNotEmpty) ...[
          Padding(
            padding: AppSpacing.paddingHorizontalLG,
            child: Text(
              _title!,
              style: AppTextStyles.headlineMedium,
            ),
          ),
          SizedBox(height: AppSpacing.md),
        ],
        _layout == 'grid' ? _buildGrid(context) : _buildHorizontal(context),
      ],
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingHorizontalLG,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: _buildCategoryCard(context, category),
          );
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(context, category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, _CategoryItem category) {
    return InkWell(
      onTap: () {
        context.go(category.route);
      },
      borderRadius: AppRadius.card,
      child: Container(
        width: _layout == 'horizontal' ? 100 : null,
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryRed.withOpacity(0.1),
              AppColors.primaryRed.withOpacity(0.05),
            ],
          ),
          borderRadius: AppRadius.card,
          border: Border.all(
            color: AppColors.primaryRed.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.icon,
              style: const TextStyle(fontSize: 32),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              category.name,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final String icon;
  final String route;

  _CategoryItem({
    required this.name,
    required this.icon,
    required this.route,
  });
}
