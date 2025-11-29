// lib/modules/customization/presentation/widgets/customization_option_tile.dart
// TODO: migration future — ce widget est extrait de la logique dans pizza_customization_modal.dart
// Source originale: lib/src/screens/home/pizza_customization_modal.dart (_buildSupplementOptions)
//
// Ce widget représente une tuile pour sélectionner/désélectionner une option de personnalisation
// Il affiche :
// - Le nom de l'ingrédient
// - Le coût supplémentaire
// - Un état visuel (sélectionné/non sélectionné)
// - Une animation lors du changement d'état

import 'package:flutter/material.dart';
import '../../data/models/customization_option.dart';

/// Widget affichant une option de personnalisation (ingrédient)
class CustomizationOptionTile extends StatelessWidget {
  final Ingredient ingredient;
  final bool isSelected;
  final VoidCallback onTap;
  
  const CustomizationOptionTile({
    super.key,
    required this.ingredient,
    required this.isSelected,
    required this.onTap,
  });
  
  /// Bridge constructor pour créer depuis un widget legacy
  /// TODO: À implémenter lors de la Phase 3 de migration
  /// IMPORTANT: Non utilisé dans l'app actuelle
  factory CustomizationOptionTile.fromLegacy(dynamic legacyWidget) {
    // TODO: Mapping depuis l'ancien code de _buildSupplementOptions
    throw UnimplementedError('Bridge non implémenté - Phase 3');
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: Implémenter l'affichage complet avec le design system
    // Pour l'instant, structure de base extraite du code original
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isSelected ? Icons.check_rounded : Icons.add_rounded,
            color: isSelected ? Colors.white : Colors.grey.shade600,
            size: 24,
          ),
        ),
        title: Text(
          ingredient.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.orange : Colors.black87,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '+${ingredient.extraCost.toStringAsFixed(2)}€',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
