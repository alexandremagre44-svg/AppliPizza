// lib/src/models/product.dart

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isMenu;
  final List<String> baseIngredients; 
  // NOUVEAU: Propriétés spécifiques aux menus
  final int pizzaCount;
  final int drinkCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isMenu = false,
    this.baseIngredients = const [], 
    this.pizzaCount = 1, // Par défaut à 1
    this.drinkCount = 0, // Par défaut à 0
  });

  // Méthode pour créer une copie d'un produit avec des modifications
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isMenu,
    List<String>? baseIngredients,
    int? pizzaCount,
    int? drinkCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isMenu: isMenu ?? this.isMenu,
      baseIngredients: baseIngredients ?? this.baseIngredients,
      pizzaCount: pizzaCount ?? this.pizzaCount,
      drinkCount: drinkCount ?? this.drinkCount,
    );
  }
}

// ===============================================
// MODÈLE D'INGRÉDIENT (pour la customisation)
// ===============================================

class Ingredient {
  final String id;
  final String name;
  final double extraCost; // Coût si l'ingrédient est ajouté en plus
  
  Ingredient({
    required this.id,
    required this.name,
    this.extraCost = 0.0,
  });
}