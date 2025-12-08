import 'module_category.dart';
import 'module_definition.dart';

/// Registre central de tous les modules disponibles dans l'application white-label.
///
/// Ce registre contient la définition de chaque module avec ses métadonnées.
/// Il est utilisé par :
/// - Le SuperAdmin pour afficher les modules disponibles
/// - Le RestaurantBlueprint pour valider les configurations
/// - Le générateur d'app pour savoir quels modules inclure
class ModuleRegistry {
  /// Map statique contenant toutes les définitions de modules.
  static final Map<String, ModuleDefinition> definitions = {
    // === CORE ===
    'ordering': const ModuleDefinition(
      id: 'ordering',
      category: ModuleCategory.core,
      name: 'Commandes en ligne',
      description:
          'Permet de prendre des commandes clients (sur place / à emporter / livraison).',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    ),
    'delivery': const ModuleDefinition(
      id: 'delivery',
      category: ModuleCategory.core,
      name: 'Livraison',
      description:
          'Gestion des livraisons avec zones, frais et suivi des livreurs.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: ['ordering'],
    ),
    'click_and_collect': const ModuleDefinition(
      id: 'click_and_collect',
      category: ModuleCategory.core,
      name: 'Click & Collect',
      description:
          'Permet aux clients de commander en ligne et récupérer sur place.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: ['ordering'],
    ),

    // === PAYMENT ===
    'payments': const ModuleDefinition(
      id: 'payments',
      category: ModuleCategory.payment,
      name: 'Paiements',
      description: 'Gestion des paiements en ligne (CB, etc.).',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    ),
    'payment_terminal': const ModuleDefinition(
      id: 'payment_terminal',
      category: ModuleCategory.payment,
      name: 'Terminal de paiement',
      description: 'Intégration avec les terminaux de paiement physiques.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: ['payments'],
    ),
    'wallet': const ModuleDefinition(
      id: 'wallet',
      category: ModuleCategory.payment,
      name: 'Portefeuille',
      description:
          'Portefeuille client pour stocker du crédit et payer rapidement.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: ['payments'],
    ),

    // === MARKETING ===
    'loyalty': const ModuleDefinition(
      id: 'loyalty',
      category: ModuleCategory.marketing,
      name: 'Fidélité',
      description: 'Programme de fidélité avec points et récompenses.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    ),
    'roulette': const ModuleDefinition(
      id: 'roulette',
      category: ModuleCategory.marketing,
      name: 'Roulette',
      description: 'Jeu de la roulette pour gagner des réductions.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    ),
    'promotions': const ModuleDefinition(
      id: 'promotions',
      category: ModuleCategory.marketing,
      name: 'Promotions',
      description: 'Gestion des codes promo et réductions.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    ),
    'campaigns': const ModuleDefinition(
      id: 'campaigns',
      category: ModuleCategory.marketing,
      name: 'Campagnes',
      description: 'Création et gestion de campagnes marketing ciblées.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    ),
    'newsletter': const ModuleDefinition(
      id: 'newsletter',
      category: ModuleCategory.marketing,
      name: 'Newsletter',
      description: 'Envoi de newsletters et communications marketing.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    ),

    // === OPERATIONS ===
    'kitchen_tablet': const ModuleDefinition(
      id: 'kitchen_tablet',
      category: ModuleCategory.operations,
      name: 'Tablette cuisine',
      description:
          'Affichage des commandes en cuisine sur tablette dédiée.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: ['ordering'],
    ),
    'staff_tablet': const ModuleDefinition(
      id: 'staff_tablet',
      category: ModuleCategory.operations,
      name: 'Tablette staff',
      description:
          'Application pour les serveurs et le personnel de salle.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: ['ordering'],
    ),
    'time_recorder': const ModuleDefinition(
      id: 'time_recorder',
      category: ModuleCategory.operations,
      name: 'Pointeuse',
      description: 'Gestion du temps de travail et pointage du personnel.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    ),

    // === APPEARANCE ===
    'theme': const ModuleDefinition(
      id: 'theme',
      category: ModuleCategory.appearance,
      name: 'Thème',
      description: 'Personnalisation des couleurs et du style de l\'app.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    ),
    'pages_builder': const ModuleDefinition(
      id: 'pages_builder',
      category: ModuleCategory.appearance,
      name: 'Constructeur de pages',
      description: 'Création de pages personnalisées avec blocs visuels.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    ),

    // === ANALYTICS ===
    'reporting': const ModuleDefinition(
      id: 'reporting',
      category: ModuleCategory.analytics,
      name: 'Reporting',
      description: 'Tableaux de bord et statistiques de ventes.',
      isPremium: false,
      requiresConfiguration: false,
      dependencies: [],
    ),
    'exports': const ModuleDefinition(
      id: 'exports',
      category: ModuleCategory.analytics,
      name: 'Exports',
      description: 'Export des données en CSV, Excel, etc.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: ['reporting'],
    ),
  };

  /// Retourne la définition d'un module par son identifiant string.
  ///
  /// Retourne null si le module n'existe pas dans le registre.
  /// Exemples d'identifiants valides: 'ordering', 'delivery', 'loyalty', etc.
  static ModuleDefinition? of(String id) {
    return definitions[id];
  }
  
  /// Alias pour of() pour compatibilité avec le code existant.
  /// 
  /// @deprecated Use of() instead. This method will be removed in version 2.0.0.
  /// Migration: Replace `ModuleRegistry.ofString(id)` with `ModuleRegistry.of(id)`.
  @Deprecated('Use of() instead. Will be removed in version 2.0.0')
  static ModuleDefinition? ofString(String id) {
    return of(id);
  }

  /// Retourne la liste des modules appartenant à une catégorie donnée.
  static List<ModuleDefinition> byCategory(ModuleCategory category) {
    return definitions.values
        .where((def) => def.category == category)
        .toList();
  }

  /// Retourne tous les modules premium.
  static List<ModuleDefinition> get premiumModules {
    return definitions.values.where((def) => def.isPremium).toList();
  }

  /// Retourne tous les modules gratuits.
  static List<ModuleDefinition> get freeModules {
    return definitions.values.where((def) => !def.isPremium).toList();
  }

  // TODO: Plus tard, charger les définitions depuis Firestore ou une config distante
  // TODO: Ajouter une méthode pour vérifier les dépendances d'un module
  // TODO: Ajouter une méthode pour valider une configuration complète
}
