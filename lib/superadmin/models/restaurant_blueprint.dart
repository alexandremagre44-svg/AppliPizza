/// lib/superadmin/models/restaurant_blueprint.dart
///
/// Modèle léger pour décrire un restaurant de façon générique.
/// Version LIGHT du blueprint complet d'un restaurant.
/// 
/// Ce modèle est destiné à préparer le futur générateur de restaurants
/// et reste en Dart pur (pas de dépendances Firestore).
library;

/// Configuration des modules activés pour un restaurant.
/// 
/// Représente les fonctionnalités disponibles dans l'application du restaurant.
class RestaurantModulesLight {
  /// Module de commande en ligne.
  final bool ordering;

  /// Module de livraison.
  final bool delivery;

  /// Module Click & Collect.
  final bool clickAndCollect;

  /// Module de paiement en ligne.
  final bool payments;

  /// Module de fidélité (points, rewards).
  final bool loyalty;

  /// Module Roulette (jeu promotionnel).
  final bool roulette;

  /// Module tablette cuisine (affichage commandes).
  final bool kitchenTablet;

  /// Module tablette staff (prise de commande).
  final bool staffTablet;

  /// Constructeur avec valeurs par défaut (tout désactivé).
  const RestaurantModulesLight({
    this.ordering = false,
    this.delivery = false,
    this.clickAndCollect = false,
    this.payments = false,
    this.loyalty = false,
    this.roulette = false,
    this.kitchenTablet = false,
    this.staffTablet = false,
  });

  /// Factory pour créer une instance depuis un Map JSON.
  factory RestaurantModulesLight.fromJson(Map<String, dynamic> json) {
    return RestaurantModulesLight(
      ordering: json['ordering'] as bool? ?? false,
      delivery: json['delivery'] as bool? ?? false,
      clickAndCollect: json['clickAndCollect'] as bool? ?? false,
      payments: json['payments'] as bool? ?? false,
      loyalty: json['loyalty'] as bool? ?? false,
      roulette: json['roulette'] as bool? ?? false,
      kitchenTablet: json['kitchenTablet'] as bool? ?? false,
      staffTablet: json['staffTablet'] as bool? ?? false,
    );
  }

  /// Convertit l'instance en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'ordering': ordering,
      'delivery': delivery,
      'clickAndCollect': clickAndCollect,
      'payments': payments,
      'loyalty': loyalty,
      'roulette': roulette,
      'kitchenTablet': kitchenTablet,
      'staffTablet': staffTablet,
    };
  }

  /// Crée une copie avec des valeurs modifiées.
  RestaurantModulesLight copyWith({
    bool? ordering,
    bool? delivery,
    bool? clickAndCollect,
    bool? payments,
    bool? loyalty,
    bool? roulette,
    bool? kitchenTablet,
    bool? staffTablet,
  }) {
    return RestaurantModulesLight(
      ordering: ordering ?? this.ordering,
      delivery: delivery ?? this.delivery,
      clickAndCollect: clickAndCollect ?? this.clickAndCollect,
      payments: payments ?? this.payments,
      loyalty: loyalty ?? this.loyalty,
      roulette: roulette ?? this.roulette,
      kitchenTablet: kitchenTablet ?? this.kitchenTablet,
      staffTablet: staffTablet ?? this.staffTablet,
    );
  }

  /// Retourne la liste des modules activés sous forme de noms.
  List<String> get enabledModules {
    final List<String> modules = [];
    if (ordering) modules.add('ordering');
    if (delivery) modules.add('delivery');
    if (clickAndCollect) modules.add('clickAndCollect');
    if (payments) modules.add('payments');
    if (loyalty) modules.add('loyalty');
    if (roulette) modules.add('roulette');
    if (kitchenTablet) modules.add('kitchenTablet');
    if (staffTablet) modules.add('staffTablet');
    return modules;
  }

  /// Nombre de modules activés.
  int get enabledCount => enabledModules.length;

  @override
  String toString() {
    return 'RestaurantModulesLight(enabled: ${enabledModules.join(', ')})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantModulesLight &&
        other.ordering == ordering &&
        other.delivery == delivery &&
        other.clickAndCollect == clickAndCollect &&
        other.payments == payments &&
        other.loyalty == loyalty &&
        other.roulette == roulette &&
        other.kitchenTablet == kitchenTablet &&
        other.staffTablet == staffTablet;
  }

  @override
  int get hashCode {
    return Object.hash(
      ordering,
      delivery,
      clickAndCollect,
      payments,
      loyalty,
      roulette,
      kitchenTablet,
      staffTablet,
    );
  }
}

/// Configuration minimale de la marque (brand) d'un restaurant.
class RestaurantBrandLight {
  /// Nom de la marque.
  final String brandName;

  /// Couleur primaire (format hex, ex: "#E63946").
  final String primaryColor;

  /// Couleur secondaire (format hex).
  final String secondaryColor;

  /// Couleur d'accent (format hex).
  final String accentColor;

  /// URL du logo (optionnel).
  final String? logoUrl;

  /// URL de l'icône de l'application (optionnel).
  final String? appIconUrl;

  /// Constructeur avec valeurs par défaut.
  const RestaurantBrandLight({
    this.brandName = '',
    this.primaryColor = '#E63946',
    this.secondaryColor = '#1D3557',
    this.accentColor = '#F1FAEE',
    this.logoUrl,
    this.appIconUrl,
  });

  /// Factory pour créer une instance depuis un Map JSON.
  factory RestaurantBrandLight.fromJson(Map<String, dynamic> json) {
    return RestaurantBrandLight(
      brandName: json['brandName'] as String? ?? '',
      primaryColor: json['primaryColor'] as String? ?? '#E63946',
      secondaryColor: json['secondaryColor'] as String? ?? '#1D3557',
      accentColor: json['accentColor'] as String? ?? '#F1FAEE',
      logoUrl: json['logoUrl'] as String?,
      appIconUrl: json['appIconUrl'] as String?,
    );
  }

  /// Convertit l'instance en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'brandName': brandName,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (appIconUrl != null) 'appIconUrl': appIconUrl,
    };
  }

  /// Crée une copie avec des valeurs modifiées.
  RestaurantBrandLight copyWith({
    String? brandName,
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    String? logoUrl,
    String? appIconUrl,
  }) {
    return RestaurantBrandLight(
      brandName: brandName ?? this.brandName,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      logoUrl: logoUrl ?? this.logoUrl,
      appIconUrl: appIconUrl ?? this.appIconUrl,
    );
  }

  @override
  String toString() {
    return 'RestaurantBrandLight(brandName: $brandName, primaryColor: $primaryColor)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantBrandLight &&
        other.brandName == brandName &&
        other.primaryColor == primaryColor &&
        other.secondaryColor == secondaryColor &&
        other.accentColor == accentColor &&
        other.logoUrl == logoUrl &&
        other.appIconUrl == appIconUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      brandName,
      primaryColor,
      secondaryColor,
      accentColor,
      logoUrl,
      appIconUrl,
    );
  }
}

/// Types de restaurant supportés.
enum RestaurantType {
  /// Restaurant classique avec service à table.
  restaurant,
  /// Snack / Fast-food.
  snack,
  /// Snack avec livraison.
  snackDelivery,
  /// Configuration personnalisée.
  custom,
}

/// Extension pour convertir RestaurantType en/depuis String.
extension RestaurantTypeExtension on RestaurantType {
  /// Valeur string pour JSON/Firestore.
  String get value {
    switch (this) {
      case RestaurantType.restaurant:
        return 'RESTAURANT';
      case RestaurantType.snack:
        return 'SNACK';
      case RestaurantType.snackDelivery:
        return 'SNACK_DELIVERY';
      case RestaurantType.custom:
        return 'CUSTOM';
    }
  }

  /// Nom d'affichage.
  String get displayName {
    switch (this) {
      case RestaurantType.restaurant:
        return 'Restaurant';
      case RestaurantType.snack:
        return 'Snack';
      case RestaurantType.snackDelivery:
        return 'Snack + Livraison';
      case RestaurantType.custom:
        return 'Personnalisé';
    }
  }

  /// Factory pour créer depuis une string.
  static RestaurantType fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'RESTAURANT':
        return RestaurantType.restaurant;
      case 'SNACK':
        return RestaurantType.snack;
      case 'SNACK_DELIVERY':
        return RestaurantType.snackDelivery;
      case 'CUSTOM':
        return RestaurantType.custom;
      default:
        return RestaurantType.custom;
    }
  }
}

/// Blueprint léger d'un restaurant.
/// 
/// Représente une version simplifiée du blueprint complet,
/// contenant les informations essentielles pour décrire un restaurant.
class RestaurantBlueprintLight {
  // ==========================================================================
  // Identité
  // ==========================================================================

  /// Identifiant unique du restaurant.
  final String id;

  /// Nom du restaurant.
  final String name;

  /// Slug URL-friendly (pour sous-domaine / URL).
  final String slug;

  /// Type de restaurant.
  final RestaurantType type;

  /// Identifiant du template utilisé (ex: "pizzeria-template-1").
  final String? templateId;

  // ==========================================================================
  // Brand
  // ==========================================================================

  /// Configuration minimale de la marque.
  final RestaurantBrandLight brand;

  // ==========================================================================
  // Modules
  // ==========================================================================

  /// Modules activés pour ce restaurant.
  final RestaurantModulesLight modules;

  // ==========================================================================
  // Métadonnées
  // ==========================================================================

  /// Date de création.
  final DateTime createdAt;

  /// Date de dernière mise à jour.
  final DateTime? updatedAt;

  /// Constructeur principal.
  const RestaurantBlueprintLight({
    required this.id,
    required this.name,
    required this.slug,
    this.type = RestaurantType.custom,
    this.templateId,
    this.brand = const RestaurantBrandLight(),
    this.modules = const RestaurantModulesLight(),
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory pour créer une instance depuis un Map JSON.
  factory RestaurantBlueprintLight.fromJson(Map<String, dynamic> json) {
    return RestaurantBlueprintLight(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      type: RestaurantTypeExtension.fromString(json['type'] as String?),
      templateId: json['templateId'] as String?,
      brand: json['brand'] != null
          ? RestaurantBrandLight.fromJson(json['brand'] as Map<String, dynamic>)
          : const RestaurantBrandLight(),
      modules: json['modules'] != null
          ? RestaurantModulesLight.fromJson(
              json['modules'] as Map<String, dynamic>)
          : const RestaurantModulesLight(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime
              ? json['createdAt'] as DateTime
              : DateTime.tryParse(json['createdAt'].toString()) ??
                  DateTime.now())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is DateTime
              ? json['updatedAt'] as DateTime
              : DateTime.tryParse(json['updatedAt'].toString()))
          : null,
    );
  }

  /// Convertit l'instance en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'type': type.value,
      if (templateId != null) 'templateId': templateId,
      'brand': brand.toJson(),
      'modules': modules.toJson(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Crée une copie avec des valeurs modifiées.
  RestaurantBlueprintLight copyWith({
    String? id,
    String? name,
    String? slug,
    RestaurantType? type,
    String? templateId,
    RestaurantBrandLight? brand,
    RestaurantModulesLight? modules,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RestaurantBlueprintLight(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      type: type ?? this.type,
      templateId: templateId ?? this.templateId,
      brand: brand ?? this.brand,
      modules: modules ?? this.modules,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Factory pour créer une instance vide avec des valeurs par défaut.
  factory RestaurantBlueprintLight.empty() {
    return RestaurantBlueprintLight(
      id: '',
      name: '',
      slug: '',
      type: RestaurantType.custom,
      createdAt: DateTime.now(),
    );
  }

  /// Vérifie si le blueprint est valide (champs requis remplis).
  bool get isValid => id.isNotEmpty && name.isNotEmpty && slug.isNotEmpty;

  /// Retourne la liste des modules activés.
  List<String> get enabledModules => modules.enabledModules;

  /// Nombre de modules activés.
  int get enabledModulesCount => modules.enabledCount;

  @override
  String toString() {
    return 'RestaurantBlueprintLight(id: $id, name: $name, slug: $slug, '
        'type: ${type.value}, modules: ${modules.enabledCount} enabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantBlueprintLight &&
        other.id == id &&
        other.name == name &&
        other.slug == slug &&
        other.type == type &&
        other.templateId == templateId &&
        other.brand == brand &&
        other.modules == modules &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      slug,
      type,
      templateId,
      brand,
      modules,
      createdAt,
      updatedAt,
    );
  }
}
