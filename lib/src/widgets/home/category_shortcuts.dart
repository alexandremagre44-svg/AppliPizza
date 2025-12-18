// lib/src/widgets/home/category_shortcuts.dart
// Category shortcuts grid for home page
// MIGRATED to WL V2 Theme - Uses theme colors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';

/// Category shortcut button data
class CategoryShortcut {
  final String name;
  final IconData icon;
  final String route;

  const CategoryShortcut({
    required this.name,
    required this.icon,
    required this.route,
  });
}

/// Category shortcuts widget displaying 4 category buttons
/// Each button navigates to the menu page
class CategoryShortcuts extends StatelessWidget {
  const CategoryShortcuts({super.key});

  static const List<CategoryShortcut> _categories = [
    CategoryShortcut(
      name: 'Pizzas',
      icon: Icons.local_pizza,
      route: '/menu',
    ),
    CategoryShortcut(
      name: 'Menus',
      icon: Icons.restaurant_menu,
      route: '/menu',
    ),
    CategoryShortcut(
      name: 'Boissons',
      icon: Icons.local_drink,
      route: '/menu',
    ),
    CategoryShortcut(
      name: 'Desserts',
      icon: Icons.cake,
      route: '/menu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories.map((category) {
          return _CategoryButton(category: category);
        }).toList(),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  final CategoryShortcut category;

  const _CategoryButton({required this.category});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Material(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusLG,
          elevation: 2,
          shadowColor: context.colorScheme.shadow.withOpacity(0.1),
          child: InkWell(
            onTap: () => context.push(category.route),
            borderRadius: AppRadius.radiusLG,
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                      size: 28,
                      color: context.primaryColor,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      category.name,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: context.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
