import 'module_category.dart';

/// Identifiant unique pour chaque module de l'application white-label.
///
/// Chaque module activable/désactivable possède un identifiant unique
/// permettant de le référencer dans la configuration restaurant.
enum ModuleId {
  /// Module de commandes en ligne
  ordering,

  /// Module de livraison
  delivery,

  /// Module Click & Collect
  clickAndCollect,

  /// Module paiements (cœur)
  payments,

  /// Module terminal de paiement
  paymentTerminal,

  /// Module portefeuille électronique
  wallet,

  /// Module fidélité
  loyalty,

  /// Module roulette / jeu marketing
  roulette,

  /// Module promotions
  promotions,

  /// Module newsletter
  newsletter,

  /// Module tablette cuisine
  kitchen_tablet,

  /// Module tablette staff / serveur
  staff_tablet,

  /// Module POS / Caisse (Point de Vente)
  pos,

  /// Module pointeuse / gestion du temps
  timeRecorder,

  /// Module thème / personnalisation visuelle
  theme,

  /// Module constructeur de pages
  pagesBuilder,

  /// Module reporting / tableaux de bord
  reporting,

  /// Module exports de données
  exports,

  /// Module campagnes marketing
  campaigns,
}

/// Extension pour ajouter des métadonnées à chaque identifiant de module.
extension ModuleIdX on ModuleId {
  /// Retourne un code technique (snake_case) pour le module.
  String get code {
    switch (this) {
      case ModuleId.ordering:
        return 'ordering';
      case ModuleId.delivery:
        return 'delivery';
      case ModuleId.clickAndCollect:
        return 'click_and_collect';
      case ModuleId.payments:
        return 'payments';
      case ModuleId.paymentTerminal:
        return 'payment_terminal';
      case ModuleId.wallet:
        return 'wallet';
      case ModuleId.loyalty:
        return 'loyalty';
      case ModuleId.roulette:
        return 'roulette';
      case ModuleId.promotions:
        return 'promotions';
      case ModuleId.newsletter:
        return 'newsletter';
      case ModuleId.kitchen_tablet:
        return 'kitchen_tablet';
      case ModuleId.staff_tablet:
        return 'staff_tablet';
      case ModuleId.pos:
        return 'pos';
      case ModuleId.timeRecorder:
        return 'time_recorder';
      case ModuleId.theme:
        return 'theme';
      case ModuleId.pagesBuilder:
        return 'pages_builder';
      case ModuleId.reporting:
        return 'reporting';
      case ModuleId.exports:
        return 'exports';
      case ModuleId.campaigns:
        return 'campaigns';
    }
  }

  /// Retourne un libellé lisible pour le module.
  String get label {
    switch (this) {
      case ModuleId.ordering:
        return 'Commandes en ligne';
      case ModuleId.delivery:
        return 'Livraison';
      case ModuleId.clickAndCollect:
        return 'Click & Collect';
      case ModuleId.payments:
        return 'Paiements';
      case ModuleId.paymentTerminal:
        return 'Terminal de paiement';
      case ModuleId.wallet:
        return 'Portefeuille';
      case ModuleId.loyalty:
        return 'Fidélité';
      case ModuleId.roulette:
        return 'Roulette';
      case ModuleId.promotions:
        return 'Promotions';
      case ModuleId.newsletter:
        return 'Newsletter';
      case ModuleId.kitchen_tablet:
        return 'Tablette cuisine';
      case ModuleId.staff_tablet:
        return 'Caisse / Staff Tablet';
      case ModuleId.pos:
        return 'POS / Caisse';
      case ModuleId.timeRecorder:
        return 'Pointeuse';
      case ModuleId.theme:
        return 'Thème';
      case ModuleId.pagesBuilder:
        return 'Constructeur de pages';
      case ModuleId.reporting:
        return 'Reporting';
      case ModuleId.exports:
        return 'Exports';
      case ModuleId.campaigns:
        return 'Campagnes';
    }
  }

  /// Retourne la catégorie du module.
  /// 
  /// IMPORTANT: Les modules de catégorie `system` ne doivent JAMAIS
  /// apparaître dans le Pages Builder.
  /// 
  /// Classification selon la DOCTRINE WL:
  /// - SYSTEM: pos, ordering (includes cart/checkout functionality), payments, kitchen_tablet, staff_tablet
  /// - BUSINESS: delivery, click_and_collect, loyalty, promotions, roulette, wallet, campaigns, time_recorder
  /// - VISUAL: pages_builder, theme
  /// 
  /// Note: Cart and checkout are not separate ModuleId values - they are functionality
  /// provided by the ordering module. When ordering is enabled, cart/checkout are available.
  ModuleCategory get category {
    switch (this) {
      // Modules SYSTÈME - Routes fixes, JAMAIS dans le Builder
      // Ces modules représentent le runtime core (routes, services)
      case ModuleId.pos:
      case ModuleId.ordering:           // inclut cart/checkout
      case ModuleId.payments:
      case ModuleId.paymentTerminal:
      case ModuleId.kitchen_tablet:
      case ModuleId.staff_tablet:
        return ModuleCategory.system;
      
      // Modules MÉTIER - Fonctionnalités business optionnelles
      // Peuvent être ajoutés au Builder si activés
      case ModuleId.delivery:
      case ModuleId.clickAndCollect:
      case ModuleId.loyalty:
      case ModuleId.roulette:
      case ModuleId.promotions:
      case ModuleId.newsletter:
      case ModuleId.wallet:              // wallet est BUSINESS selon doctrine
      case ModuleId.timeRecorder:
      case ModuleId.reporting:
      case ModuleId.exports:
      case ModuleId.campaigns:
        return ModuleCategory.business;
      
      // Modules VISUELS - Pages / Builder / Contenu
      case ModuleId.theme:
      case ModuleId.pagesBuilder:
        return ModuleCategory.visual;
    }
  }

  /// Vérifie si ce module est un module système.
  /// 
  /// Les modules système sont des routes/pages FIXES qui ne doivent
  /// JAMAIS être ajoutables comme blocs ou pages dans le Builder.
  /// 
  /// Retourne `true` pour: pos, ordering (inclut cart), payments,
  /// paymentTerminal, kitchen_tablet, staff_tablet
  bool get isSystemModule => category == ModuleCategory.system;

  // TODO: Ajouter une icône (IconData) pour chaque module
  // TODO: Ajouter un routeName pour le routing runtime
}
