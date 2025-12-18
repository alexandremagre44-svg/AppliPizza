// lib/src/widgets/ingredient_selector.dart
// Widget réutilisable pour la gestion dynamique des ingrédients
// ⚠️ DÉPRÉCIÉ: Ce widget utilise une liste statique d'ingrédients
// Utilisez plutôt les providers Firestore (ingredientStreamProvider) pour une gestion dynamique
// MIGRATED to WL V2 Theme - Uses theme colors with fallback to primary

import 'package:flutter/material.dart';
import '../../white_label/theme/theme_extensions.dart';

/// Widget pour gérer dynamiquement les ingrédients d'une pizza
/// 
/// ⚠️ DÉPRÉCIÉ: Ce widget contient une liste statique d'ingrédients en dur.
/// Pour une gestion dynamique depuis Firestore, utilisez:
/// - `ingredientStreamProvider` pour écouter les changements en temps réel
/// - Les écrans product_form_screen.dart et pizza_customization_modal.dart
///   montrent comment implémenter correctement la gestion dynamique
/// 
/// Permet de:
/// - Afficher et cocher/décocher des ingrédients existants
/// - Ajouter de nouveaux ingrédients manuellement
/// - Retirer des ingrédients de la liste
@Deprecated('Utilisez ingredientStreamProvider avec Firestore pour une gestion dynamique')
class IngredientSelector extends StatefulWidget {
  /// Liste initiale des ingrédients sélectionnés
  final List<String> selectedIngredients;
  
  /// Liste des ingrédients de base disponibles (suggestions)
  final List<String> availableIngredients;
  
  /// Callback appelé quand la liste des ingrédients change
  final Function(List<String>) onIngredientsChanged;
  
  /// Couleur principale du widget (optionnel)
  final Color? primaryColor;

  const IngredientSelector({
    super.key,
    required this.selectedIngredients,
    this.availableIngredients = const [
      'Tomate',
      'Mozzarella',
      'Jambon',
      'Champignons',
      'Oignons',
      'Poivrons',
      'Olives',
      'Pepperoni',
      'Chorizo',
      'Poulet',
      'Bacon',
      'Fromage de chèvre',
      'Parmesan',
      'Roquette',
      'Basilic',
      'Origan',
    ],
    required this.onIngredientsChanged,
    this.primaryColor,
  });

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();
}

class _IngredientSelectorState extends State<IngredientSelector> {
  late List<String> _currentIngredients;
  final TextEditingController _newIngredientController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentIngredients = List.from(widget.selectedIngredients);
  }

  @override
  void dispose() {
    _newIngredientController.dispose();
    super.dispose();
  }

  /// Notifie le parent que la liste a changé
  void _notifyChange() {
    widget.onIngredientsChanged(_currentIngredients);
  }

  /// Ajoute un ingrédient à la liste
  void _addIngredient(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isNotEmpty && !_currentIngredients.contains(trimmed)) {
      setState(() {
        _currentIngredients.add(trimmed);
      });
      _notifyChange();
    }
  }

  /// Retire un ingrédient de la liste
  void _removeIngredient(String ingredient) {
    setState(() {
      _currentIngredients.remove(ingredient);
    });
    _notifyChange();
  }

  /// Toggle un ingrédient (ajoute s'il n'existe pas, retire sinon)
  void _toggleIngredient(String ingredient) {
    if (_currentIngredients.contains(ingredient)) {
      _removeIngredient(ingredient);
    } else {
      _addIngredient(ingredient);
    }
  }

  @override
  Widget build(BuildContext context) {
    // WL V2: Use custom color if provided, otherwise theme primary
    final color = widget.primaryColor ?? context.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===============================================
          // EN-TÊTE: Titre et compteur
          // ===============================================
          Row(
            children: [
              Icon(Icons.local_pizza, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ingrédients',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentIngredients.length}',
                  style: TextStyle(
                    color: context.onPrimary, // WL V2: Contrast color
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ===============================================
          // SECTION 1: Ingrédients sélectionnés (Chips actifs)
          // ===============================================
          if (_currentIngredients.isNotEmpty) ...[
            Text(
              'Ingrédients sélectionnés:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.onSurface, // WL V2: Theme text
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentIngredients.map((ingredient) {
                return Chip(
                  label: Text(ingredient),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeIngredient(ingredient),
                  backgroundColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  deleteIconColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: color.withOpacity(0.5)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // ===============================================
          // SECTION 2: Ingrédients disponibles (Checkboxes)
          // ===============================================
          Text(
            'Ingrédients disponibles:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.onSurface, // WL V2: Theme text
            ),
          ),
          const SizedBox(height: 8),
          
          // Liste des ingrédients disponibles non encore sélectionnés
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.availableIngredients.map((ingredient) {
              final isSelected = _currentIngredients.contains(ingredient);
              return InkWell(
                onTap: () => _toggleIngredient(ingredient),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withOpacity(0.2) 
                        : context.surfaceColor, // WL V2: Theme surface
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? color.withOpacity(0.5) 
                          : context.outlineVariant, // WL V2: Theme outline
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 18,
                        color: isSelected ? color : context.textSecondary, // WL V2: Theme text
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ingredient,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? color : context.onSurface, // WL V2: Theme text
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),

          // ===============================================
          // SECTION 3: Ajouter un nouvel ingrédient
          // ===============================================
          Text(
            'Ajouter un ingrédient personnalisé:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.onSurface, // WL V2: Theme text
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newIngredientController,
                  decoration: InputDecoration(
                    hintText: 'Ex: Roquette, Gorgonzola...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary, // WL V2: Theme text
                    ),
                    filled: true,
                    fillColor: context.surfaceColor, // WL V2: Theme surface
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.outlineVariant), // WL V2: Theme outline
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.outlineVariant), // WL V2: Theme outline
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: color, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (value) {
                    _addIngredient(value);
                    _newIngredientController.clear();
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_newIngredientController.text.trim().isNotEmpty) {
                    _addIngredient(_newIngredientController.text);
                    _newIngredientController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: context.onPrimary, // WL V2: Contrast color
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Icon(Icons.add, size: 24),
              ),
            ],
          ),

          // ===============================================
          // INFO: Note sur la gestion des ingrédients
          // ===============================================
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.secondaryContainer, // WL V2: Theme secondary container
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.outlineVariant), // WL V2: Theme outline
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: context.onSecondaryContainer, size: 18), // WL V2: Theme color
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Les ingrédients sont propres à cette pizza et n\'affectent pas les autres produits.',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.onSecondaryContainer, // WL V2: Theme color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
