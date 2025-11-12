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
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onCategorySelected(category),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryRed : Colors.transparent,
            border: Border.all(
              color: AppTheme.primaryRed,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
            // Ombre légère pour détacher le pill rouge actif
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryRed.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              category,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.surfaceWhite
                    : AppTheme.primaryRed,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
