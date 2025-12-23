// lib/modules/customization/presentation/widgets/customization_group_section.dart
// TODO: migration future — ce widget est extrait de la logique dans pizza_customization_modal.dart
// Source originale: lib/src/screens/home/pizza_customization_modal.dart (_buildCategorySection)
//
// Ce widget représente une section groupée d'options de personnalisation
// Il affiche :
// - Un en-tête avec icône, titre et sous-titre
// - La liste des options disponibles dans ce groupe
// - Un style cohérent Material 3

import 'package:flutter/material.dart';
import '../../data/models/customization_group.dart';
import 'customization_option_tile.dart';

/// Widget affichant un groupe d'options de personnalisation
class CustomizationGroupSection extends StatelessWidget {
  final CustomizationGroup group;
  final Set<String> selectedOptionIds;
  final Function(String) onOptionToggle;
  
  const CustomizationGroupSection({
    super.key,
    required this.group,
    required this.selectedOptionIds,
    required this.onOptionToggle,
  });
  
  /// Bridge constructor pour créer depuis un widget legacy
  /// TODO: À implémenter lors de la Phase 3 de migration
  /// IMPORTANT: Non utilisé dans l'app actuelle
  factory CustomizationGroupSection.fromLegacy(dynamic legacyWidget) {
    // TODO: Mapping depuis l'ancien code de _buildCategorySection
    throw UnimplementedError('Bridge non implémenté - Phase 3');
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: Implémenter l'affichage complet avec le design system
    // Pour l'instant, structure de base extraite du code original
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(group.category),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (group.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          group.subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Liste des options
          ...group.options.map((option) {
            return CustomizationOptionTile(
              ingredient: option,
              isSelected: selectedOptionIds.contains(option.id),
              onTap: () => onOptionToggle(option.id),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(IngredientCategory category) {
    switch (category) {
      case IngredientCategory.fromage:
        return Icons.restaurant;
      case IngredientCategory.viande:
        return Icons.food_bank;
      case IngredientCategory.legume:
        return Icons.eco;
      case IngredientCategory.sauce:
        return Icons.water_drop;
      case IngredientCategory.herbe:
        return Icons.spa;
      default:
        return Icons.category;
    }
  }
}
