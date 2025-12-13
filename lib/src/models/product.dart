// lib/src/models/product.dart

// ===============================================
// ENUMS FOR TYPE SAFETY
// ===============================================

/// Product category enum for type safety
enum ProductCategory {
  pizza('Pizza'),
  menus('Menus'),
  boissons('Boissons'),
  desserts('Desserts');

  const ProductCategory(this.value);
  final String value;

  /// Convert from string to enum, with fallback to Pizza
  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => ProductCategory.pizza,
    );
  }
}

/// Display spot enum for type safety
enum DisplaySpot {
  home('home'),
  promotions('promotions'),
  new_('new'),
  all('all');

  const DisplaySpot(this.value);
  final String value;

  /// Convert from string to enum, with fallback to all
  static DisplaySpot fromString(String value) {
    return DisplaySpot.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DisplaySpot.all,
    );
  }
}

// ===============================================
// PRODUCT MODEL
// ===============================================

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final ProductCategory category;
  final bool isMenu;
  final List<String> baseIngredients; 
  final List<String> allowedSupplements; // IDs des ingrédients autorisés en supplément 
  // NOUVEAU: Propriétés spécifiques aux menus
  final int pizzaCount;
  final int drinkCount;
  // NOUVEAU: Mise en avant du produit
  final bool isFeatured;
  // NOUVEAU: Gestion de l'affichage et de l'état
  final bool isActive; // Produit actif ou inactif
  final DisplaySpot displaySpot; // Où afficher le produit: 'home', 'promotions', 'new', 'all'
  final int order; // Ordre d'affichage (priorité numérique)
  // NOUVEAU: Tags de mise en avant pour Studio
  final bool isBestSeller; // Produit best-seller
  final bool isNew; // Nouveau produit
  final bool isChefSpecial; // Spécialité du chef
  final bool isKidFriendly; // Adapté aux enfants
  // PHASE C: Métier restaurant - produit viande nécessitant cuisson
  final bool isMeat; // Produit contenant de la viande (nécessite cuisson pour restaurants)

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isMenu = false,
    this.baseIngredients = const [], 
    this.allowedSupplements = const [], // Par défaut aucun supplément autorisé
    this.pizzaCount = 1, // Par défaut à 1
    this.drinkCount = 0, // Par défaut à 0
    this.isFeatured = false, // Par défaut non mis en avant
    this.isActive = true, // Par défaut actif
    this.displaySpot = DisplaySpot.all, // Par défaut affiché partout
    this.order = 0, // Par défaut ordre 0
    this.isBestSeller = false,
    this.isNew = false,
    this.isChefSpecial = false,
    this.isKidFriendly = false,
    this.isMeat = false, // PHASE C: Par défaut non viande
  });

  // Méthode pour créer une copie d'un produit avec des modifications
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    ProductCategory? category,
    bool? isMenu,
    List<String>? baseIngredients,
    List<String>? allowedSupplements,
    int? pizzaCount,
    int? drinkCount,
    bool? isFeatured,
    bool? isActive,
    DisplaySpot? displaySpot,
    int? order,
    bool? isBestSeller,
    bool? isNew,
    bool? isChefSpecial,
    bool? isKidFriendly,
    bool? isMeat,
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
      allowedSupplements: allowedSupplements ?? this.allowedSupplements,
      pizzaCount: pizzaCount ?? this.pizzaCount,
      drinkCount: drinkCount ?? this.drinkCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      displaySpot: displaySpot ?? this.displaySpot,
      order: order ?? this.order,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      isNew: isNew ?? this.isNew,
      isChefSpecial: isChefSpecial ?? this.isChefSpecial,
      isKidFriendly: isKidFriendly ?? this.isKidFriendly,
      isMeat: isMeat ?? this.isMeat,
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
      'category': category.value,
      'isMenu': isMenu,
      'baseIngredients': baseIngredients,
      'allowedSupplements': allowedSupplements,
      'pizzaCount': pizzaCount,
      'drinkCount': drinkCount,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'displaySpot': displaySpot.value,
      'order': order,
      'isBestSeller': isBestSeller,
      'isNew': isNew,
      'isChefSpecial': isChefSpecial,
      'isKidFriendly': isKidFriendly,
      'isMeat': isMeat,
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
      category: ProductCategory.fromString(json['category'] as String),
      isMenu: json['isMenu'] as bool? ?? false,
      baseIngredients: (json['baseIngredients'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      allowedSupplements: (json['allowedSupplements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      pizzaCount: json['pizzaCount'] as int? ?? 1,
      drinkCount: json['drinkCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      // Nouveaux champs avec valeurs par défaut pour rétrocompatibilité
      isActive: json['isActive'] as bool? ?? true,
      displaySpot: DisplaySpot.fromString(json['displaySpot'] as String? ?? 'all'),
      order: json['order'] as int? ?? 0,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
      isChefSpecial: json['isChefSpecial'] as bool? ?? false,
      isKidFriendly: json['isKidFriendly'] as bool? ?? false,
      isMeat: json['isMeat'] as bool? ?? false, // PHASE C: Par défaut non viande
    );
  }
}

// ===============================================
// MODÈLE D'INGRÉDIENT (pour la customisation)
// ===============================================

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