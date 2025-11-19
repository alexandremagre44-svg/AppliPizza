// lib/src/widgets/category_tabs.dart
// Barre d'onglets catégories avec scroll horizontal

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Barre d'onglets pour filtrer par catégorie
/// - Scroll horizontal
/// - Onglet actif : fond rouge + texte blanc avec ombre
/// - Onglets inactifs : bordure rouge + texte rouge
/// 
/// ANIMATION: AnimatedContainer (200ms) - Transition fluide entre états actif/inactif
/// Fichier: lib/src/widgets/category_tabs.dart
/// But: Améliorer la lisibilité de l'onglet actif avec une ombre douce
class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // refactor padding → app_theme standard
    return Container(
      height: 50,
      padding: AppSpacing.paddingVerticalSM,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingHorizontalLG,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: _buildCategoryChip(
              context,
              category,
              isSelected,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String category,
    bool isSelected,
  ) {
    // refactor chip style → app_theme standard (colors, radius, shadow, text)
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onCategorySelected(category),
        borderRadius: AppRadius.radiusXL,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryRed : Colors.transparent,
            border: Border.all(
              color: AppColors.primaryRed,
              width: 1.5,
            ),
            borderRadius: AppRadius.radiusXL,
            boxShadow: isSelected ? AppShadows.soft : null,
          ),
          child: Center(
            child: Text(
              category,
              style: AppTextStyles.titleSmall.copyWith(
                color: isSelected
                    ? AppColors.surfaceWhite
                    : AppColors.primaryRed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
