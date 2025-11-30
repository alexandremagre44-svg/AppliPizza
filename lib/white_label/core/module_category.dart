/// Enumération des catégories de modules disponibles dans l'application white-label.
///
/// Chaque module appartient à une catégorie qui permet de regrouper les fonctionnalités
/// par domaine métier.
enum ModuleCategory {
  /// Modules essentiels au fonctionnement de base (commandes, livraison, click & collect)
  core,

  /// Modules de paiement (paiements, terminaux, portefeuilles)
  payment,

  /// Modules marketing (fidélité, roulette, promotions, newsletter)
  marketing,

  /// Modules opérationnels (tablette cuisine, tablette staff, pointeuse)
  operations,

  /// Modules d'apparence (thème, constructeur de pages)
  appearance,

  /// Modules staff (gestion du personnel)
  staff,

  /// Modules d'analytics (reporting, exports)
  analytics,
}

/// Extension pour ajouter des métadonnées à chaque catégorie de module.
extension ModuleCategoryX on ModuleCategory {
  /// Retourne un libellé lisible pour la catégorie.
  String get label {
    switch (this) {
      case ModuleCategory.core:
        return 'Cœur métier';
      case ModuleCategory.payment:
        return 'Paiements';
      case ModuleCategory.marketing:
        return 'Marketing';
      case ModuleCategory.operations:
        return 'Opérations';
      case ModuleCategory.appearance:
        return 'Apparence';
      case ModuleCategory.staff:
        return 'Personnel';
      case ModuleCategory.analytics:
        return 'Analytics';
    }
  }

  /// Retourne une description de la catégorie.
  String get description {
    switch (this) {
      case ModuleCategory.core:
        return 'Fonctionnalités essentielles pour la prise de commandes et la gestion des ventes.';
      case ModuleCategory.payment:
        return 'Gestion des paiements, terminaux et portefeuilles électroniques.';
      case ModuleCategory.marketing:
        return 'Outils marketing pour fidéliser et attirer les clients.';
      case ModuleCategory.operations:
        return 'Outils pour la gestion opérationnelle en cuisine et en salle.';
      case ModuleCategory.appearance:
        return 'Personnalisation de l\'apparence et du contenu de l\'application.';
      case ModuleCategory.staff:
        return 'Gestion du personnel et des équipes.';
      case ModuleCategory.analytics:
        return 'Tableaux de bord, rapports et exports de données.';
    }
  }

  // TODO: Ajouter une icône (IconData) pour chaque catégorie
  // TODO: Ajouter une couleur thématique pour chaque catégorie
}
