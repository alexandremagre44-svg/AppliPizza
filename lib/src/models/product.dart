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
  // NOUVEAU: Mise en avant du produit
  final bool isFeatured;
  // NOUVEAU: Gestion de l'affichage et de l'état
  final bool isActive; // Produit actif ou inactif
  final String displaySpot; // Où afficher le produit: 'home', 'promotions', 'new', 'all'
  final int order; // Ordre d'affichage (priorité numérique)

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
    this.isFeatured = false, // Par défaut non mis en avant
    this.isActive = true, // Par défaut actif
    this.displaySpot = 'all', // Par défaut affiché partout
    this.order = 0, // Par défaut ordre 0
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
    bool? isFeatured,
    bool? isActive,
    String? displaySpot,
    int? order,
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
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      displaySpot: displaySpot ?? this.displaySpot,
      order: order ?? this.order,
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isMenu': isMenu,
      'baseIngredients': baseIngredients,
      'pizzaCount': pizzaCount,
      'drinkCount': drinkCount,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'displaySpot': displaySpot,
      'order': order,
    };
  }

  // Création depuis JSON (avec compatibilité pour anciens produits)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      isMenu: json['isMenu'] as bool? ?? false,
      baseIngredients: (json['baseIngredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      pizzaCount: json['pizzaCount'] as int? ?? 1,
      drinkCount: json['drinkCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      // Nouveaux champs avec valeurs par défaut pour rétrocompatibilité
      isActive: json['isActive'] as bool? ?? true,
      displaySpot: json['displaySpot'] as String? ?? 'all',
      order: json['order'] as int? ?? 0,
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