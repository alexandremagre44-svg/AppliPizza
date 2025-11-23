// lib/modules/customization/data/models/customization_option.dart
// TODO: migration future — ce fichier est une copie, le code original reste la source active.
// Source originale: lib/src/models/product.dart (class Ingredient)

/// Catégorie d'ingrédient pour une meilleure organisation
enum IngredientCategory {
  fromage('Fromages'),
  viande('Viandes'),
  legume('Légumes'),
  sauce('Sauces'),
  herbe('Herbes & Épices'),
  autre('Autres');

  const IngredientCategory(this.displayName);
  final String displayName;

  static IngredientCategory fromString(String value) {
    return IngredientCategory.values.firstWhere(
      (e) => e.name == value || e.displayName == value,
      orElse: () => IngredientCategory.autre,
    );
  }
}

/// Modèle représentant une option de personnalisation pour un article (Ingrédient)
class Ingredient {
  final String id;
  final String name;
  final double extraCost; // Coût si l'ingrédient est ajouté en plus
  final IngredientCategory category;
  final bool isActive; // Ingrédient actif ou non
  final String? iconName; // Nom de l'icône Material (optionnel)
  final int order; // Ordre d'affichage
  
  Ingredient({
    required this.id,
    required this.name,
    this.extraCost = 0.0,
    this.category = IngredientCategory.autre,
    this.isActive = true,
    this.iconName,
    this.order = 0,
  });

  /// Création depuis JSON
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as String,
      name: json['name'] as String,
      extraCost: (json['extraCost'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] != null
          ? IngredientCategory.fromString(json['category'] as String)
          : IngredientCategory.autre,
      isActive: json['isActive'] as bool? ?? true,
      iconName: json['iconName'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }

  /// Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'extraCost': extraCost,
      'category': category.name,
      'isActive': isActive,
      'iconName': iconName,
      'order': order,
    };
  }

  /// Copie avec modifications
  Ingredient copyWith({
    String? id,
    String? name,
    double? extraCost,
    IngredientCategory? category,
    bool? isActive,
    String? iconName,
    int? order,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      extraCost: extraCost ?? this.extraCost,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      iconName: iconName ?? this.iconName,
      order: order ?? this.order,
    );
  }
}
