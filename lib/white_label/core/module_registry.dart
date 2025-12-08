import 'module_category.dart';
import 'module_definition.dart';
import 'module_id.dart';

/// Registre central de tous les modules disponibles dans l'application white-label.
///
/// Ce registre contient la définition de chaque module avec ses métadonnées.
/// Il est utilisé par :
/// - Le SuperAdmin pour afficher les modules disponibles
/// - Le RestaurantBlueprint pour valider les configurations
/// - Le générateur d'app pour savoir quels modules inclure
class ModuleRegistry {
  /// Map statique contenant toutes les définitions de modules.
  static final Map<ModuleId, ModuleDefinition> definitions = {
    // === CORE ===
    ModuleId.ordering: const ModuleDefinition(
      id: ModuleId.ordering,
      category: ModuleCategory.core,
      name: 'Commandes en ligne',
      description:
          'Permet de prendre des commandes clients (sur place / à emporter / livraison).',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    ),
    ModuleId.delivery: const ModuleDefinition(
      id: ModuleId.delivery,
      category: ModuleCategory.core,
      name: 'Livraison',
      description:
          'Gestion des livraisons avec zones, frais et suivi des livreurs.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [ModuleId.ordering],
    ),
    ModuleId.clickAndCollect: const ModuleDefinition(
      id: ModuleId.clickAndCollect,
      category: ModuleCategory.core,
      name: 'Click & Collect',
      description:
          'Permet aux clients de commander en ligne et récupérer sur place.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [ModuleId.ordering],
    ),

    // === PAYMENT ===
    ModuleId.payments: const ModuleDefinition(
      id: ModuleId.payments,
      category: ModuleCategory.payment,
      name: 'Paiements',
      description: 'Gestion des paiements en ligne (CB, etc.).',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    ),
    ModuleId.paymentTerminal: const ModuleDefinition(
      id: ModuleId.paymentTerminal,
      category: ModuleCategory.payment,
      name: 'Terminal de paiement',
      description: 'Intégration avec les terminaux de paiement physiques.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.payments],
    ),
    ModuleId.wallet: const ModuleDefinition(
      id: ModuleId.wallet,
      category: ModuleCategory.payment,
      name: 'Portefeuille',
      description:
          'Portefeuille client pour stocker du crédit et payer rapidement.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.payments],
    ),

    // === MARKETING ===
    ModuleId.loyalty: const ModuleDefinition(
      id: ModuleId.loyalty,
      category: ModuleCategory.marketing,
      name: 'Fidélité',
      description: 'Programme de fidélité avec points et récompenses.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    ),
    ModuleId.roulette: const ModuleDefinition(
      id: ModuleId.roulette,
      category: ModuleCategory.marketing,
      name: 'Roulette',
      description: 'Jeu de la roulette pour gagner des réductions.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    ),
    ModuleId.promotions: const ModuleDefinition(
      id: ModuleId.promotions,
      category: ModuleCategory.marketing,
      name: 'Promotions',
      description: 'Gestion des codes promo et réductions.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    ),
    ModuleId.campaigns: const ModuleDefinition(
      id: ModuleId.campaigns,
      category: ModuleCategory.marketing,
      name: 'Campagnes',
      description: 'Création et gestion de campagnes marketing ciblées.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    ),
    ModuleId.newsletter: const ModuleDefinition(
      id: ModuleId.newsletter,
      category: ModuleCategory.marketing,
      name: 'Newsletter',
      description: 'Envoi de newsletters et communications marketing.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    ),

    // === OPERATIONS ===
    ModuleId.kitchen_tablet: const ModuleDefinition(
      id: ModuleId.kitchen_tablet,
      category: ModuleCategory.operations,
      name: 'Tablette cuisine',
      description:
          'Affichage des commandes en cuisine sur tablette dédiée.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.ordering],
    ),
    ModuleId.staff_tablet: const ModuleDefinition(
      id: ModuleId.staff_tablet,
      category: ModuleCategory.operations,
      name: 'Tablette staff',
      description:
          'Application pour les serveurs et le personnel de salle.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.ordering],
    ),
    ModuleId.timeRecorder: const ModuleDefinition(
      id: ModuleId.timeRecorder,
      category: ModuleCategory.operations,
      name: 'Pointeuse',
      description: 'Gestion du temps de travail et pointage du personnel.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    ),

    // === APPEARANCE ===
    ModuleId.theme: const ModuleDefinition(
      id: ModuleId.theme,
      category: ModuleCategory.appearance,
      name: 'Thème',
      description: 'Personnalisation des couleurs et du style de l\'app.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    ),
    ModuleId.pagesBuilder: const ModuleDefinition(
      id: ModuleId.pagesBuilder,
      category: ModuleCategory.appearance,
      name: 'Constructeur de pages',
      description: 'Création de pages personnalisées avec blocs visuels.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    ),

    // === ANALYTICS ===
    ModuleId.reporting: const ModuleDefinition(
      id: ModuleId.reporting,
      category: ModuleCategory.analytics,
      name: 'Reporting',
      description: 'Tableaux de bord et statistiques de ventes.',
      isPremium: false,
      requiresConfiguration: false,
      dependencies: [],
    ),
    ModuleId.exports: const ModuleDefinition(
      id: ModuleId.exports,
      category: ModuleCategory.analytics,
      name: 'Exports',
      description: 'Export des données en CSV, Excel, etc.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.reporting],
    ),
  };

  /// Retourne la définition d'un module par son identifiant.
  ///
  /// Lève une exception si le module n'existe pas.
  static ModuleDefinition of(ModuleId id) {
    final definition = definitions[id];
    if (definition == null) {
      throw ArgumentError(
        'Module with ID "${id.code}" not found in registry. '
        'Available modules: ${definitions.keys.map((k) => k.code).join(", ")}',
      );
    }
    return definition;
  }

  /// Retourne la définition d'un module par son code string.
  ///
  /// Accepte des codes string comme "delivery", "loyalty", etc.
  /// Lève une exception si le module n'existe pas.
  static ModuleDefinition? ofString(String moduleId) {
    // Find the ModuleId enum that matches the string code
    for (final entry in definitions.entries) {
      if (entry.key.code == moduleId) {
        return entry.value;
      }
    }
    return null;
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
