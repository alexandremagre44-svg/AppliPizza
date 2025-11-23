// lib/modules/customization/data/models/customization_group.dart
// TODO: migration future — ce fichier est une copie, le code original reste la source active.
// Source originale: Logique implicite dans pizza_customization_modal.dart
// Les groupes sont organisés par IngredientCategory

import 'customization_option.dart';

/// Modèle représentant un groupe d'options de personnalisation
/// Dans le code actuel, les groupes sont organisés par IngredientCategory
/// (fromages, viandes, légumes, sauces, herbes)
class CustomizationGroup {
  final String id;
  final String name;
  final IngredientCategory category;
  final List<Ingredient> options;
  final bool required; // Si le client doit faire un choix
  final int minSelections; // Minimum de sélections requises
  final int maxSelections; // Maximum de sélections autorisées
  final String? subtitle; // Description du groupe
  
  const CustomizationGroup({
    required this.id,
    required this.name,
    required this.category,
    required this.options,
    this.required = false,
    this.minSelections = 0,
    this.maxSelections = 999,
    this.subtitle,
  });

  /// Création depuis JSON
  factory CustomizationGroup.fromJson(Map<String, dynamic> json) {
    return CustomizationGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      category: IngredientCategory.fromString(json['category'] as String),
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => Ingredient.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      required: json['required'] as bool? ?? false,
      minSelections: json['minSelections'] as int? ?? 0,
      maxSelections: json['maxSelections'] as int? ?? 999,
      subtitle: json['subtitle'] as String?,
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'options': options.map((o) => o.toJson()).toList(),
      'required': required,
      'minSelections': minSelections,
      'maxSelections': maxSelections,
      if (subtitle != null) 'subtitle': subtitle,
    };
  }

  /// Copie avec modifications
  CustomizationGroup copyWith({
    String? id,
    String? name,
    IngredientCategory? category,
    List<Ingredient>? options,
    bool? required,
    int? minSelections,
    int? maxSelections,
    String? subtitle,
  }) {
    return CustomizationGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      options: options ?? this.options,
      required: required ?? this.required,
      minSelections: minSelections ?? this.minSelections,
      maxSelections: maxSelections ?? this.maxSelections,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}
