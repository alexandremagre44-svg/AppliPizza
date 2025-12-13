/// lib/white_label/restaurant/cashier_profile.dart
///
/// Profil métier POS (Point of Sale) pour orienter le comportement de la caisse.
/// Ce profil est indépendant des templates et des modules activés.
///
/// IMPORTANT: Ce profil définit UNIQUEMENT la logique métier POS.
/// Il n'influence PAS les modules disponibles ni leur activation.
library;

/// Profil métier de la caisse / POS.
///
/// Définit le comportement métier de l'application POS selon le type d'établissement.
/// Cette information est orthogonale aux templates et aux modules activés.
///
/// Exemples d'utilisation future:
/// - Adapter l'interface POS selon le profil
/// - Personnaliser les workflows de commande
/// - Ajuster les options d'impression
/// - Configurer les raccourcis métier
enum CashierProfile {
  /// Profil générique sans spécialisation métier.
  /// Utilisé par défaut pour une configuration neutre.
  generic,

  /// Profil spécialisé pour pizzeria.
  /// Peut inclure: personnalisation pizzas, gestion des tailles, etc.
  pizzeria,

  /// Profil spécialisé pour fast-food / restauration rapide.
  /// Peut inclure: menus rapides, service comptoir optimisé, etc.
  fastFood,

  /// Profil spécialisé pour restaurant classique.
  /// Peut inclure: service à table, gestion des additions, etc.
  restaurant,

  /// Profil spécialisé pour restaurant de sushi.
  /// Peut inclure: composition de plateaux, assortiments, etc.
  sushi,
}

/// Extension pour CashierProfile.
extension CashierProfileExtension on CashierProfile {
  /// Valeur string pour JSON/Firestore.
  String get value {
    switch (this) {
      case CashierProfile.generic:
        return 'generic';
      case CashierProfile.pizzeria:
        return 'pizzeria';
      case CashierProfile.fastFood:
        return 'fastFood';
      case CashierProfile.restaurant:
        return 'restaurant';
      case CashierProfile.sushi:
        return 'sushi';
    }
  }

  /// Nom d'affichage pour l'UI.
  String get displayName {
    switch (this) {
      case CashierProfile.generic:
        return 'Générique';
      case CashierProfile.pizzeria:
        return 'Pizzeria';
      case CashierProfile.fastFood:
        return 'Fast-food';
      case CashierProfile.restaurant:
        return 'Restaurant';
      case CashierProfile.sushi:
        return 'Sushi';
    }
  }

  /// Description du profil.
  String get description {
    switch (this) {
      case CashierProfile.generic:
        return 'Configuration générique sans spécialisation métier';
      case CashierProfile.pizzeria:
        return 'Optimisé pour pizzeria avec personnalisation avancée';
      case CashierProfile.fastFood:
        return 'Optimisé pour restauration rapide et service comptoir';
      case CashierProfile.restaurant:
        return 'Optimisé pour restaurant classique avec service à table';
      case CashierProfile.sushi:
        return 'Optimisé pour restaurant de sushi et plats japonais';
    }
  }

  /// Icône suggérée pour l'UI.
  String get iconName {
    switch (this) {
      case CashierProfile.generic:
        return 'store';
      case CashierProfile.pizzeria:
        return 'local_pizza';
      case CashierProfile.fastFood:
        return 'fastfood';
      case CashierProfile.restaurant:
        return 'restaurant';
      case CashierProfile.sushi:
        return 'set_meal';
    }
  }

  /// Factory pour créer depuis une string.
  static CashierProfile fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pizzeria':
        return CashierProfile.pizzeria;
      case 'fastfood':
      case 'fast_food':
        return CashierProfile.fastFood;
      case 'restaurant':
        return CashierProfile.restaurant;
      case 'sushi':
        return CashierProfile.sushi;
      case 'generic':
      default:
        return CashierProfile.generic;
    }
  }
}
