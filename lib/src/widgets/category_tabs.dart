// lib/src/widgets/category_tabs.dart
// Barre d'onglets catégories avec scroll horizontal
// MIGRATED to WL V2 Theme - Uses theme primary color

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../white_label/theme/theme_extensions.dart';

/// Barre d'onglets pour filtrer par catégorie
/// - Scroll horizontal
/// - Onglet actif : fond rouge + texte blanc avec ombre
/// - Onglets inactifs : bordure rouge + texte rouge
/// 
/// ANIMATION: AnimatedContainer (200ms) - Transition fluide entre états actif/inactif
/// Fichier: lib/src/widgets/category_tabs.dart
/// But: Améliorer la lisibilité de l'onglet actif avec une ombre douce
/// 
/// WL V2 MIGRATION: Active tab uses theme primary color
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
    // WL V2: Uses theme primary color for active state
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
            color: isSelected ? context.primaryColor : Colors.transparent, // WL V2: Theme primary
            border: Border.all(
              color: context.primaryColor, // WL V2: Theme primary
              width: 1.5,
            ),
            borderRadius: AppRadius.radiusXL,
            boxShadow: isSelected ? AppShadows.soft : null,
          ),
          child: Center(
            child: Text(
              category,
              style: context.titleSmall?.copyWith( // WL V2: Theme text
                color: isSelected
                    ? context.onPrimary // WL V2: Contrast color
                    : context.primaryColor, // WL V2: Theme primary
              ),
            ),
          ),
        ),
      ),
    );
  }
}
