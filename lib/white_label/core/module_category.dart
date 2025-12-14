/// Enumération des catégories de modules disponibles dans l'application white-label.
///
/// Chaque module appartient à une catégorie qui permet de regrouper les fonctionnalités
/// par domaine métier.
///
/// IMPORTANT: Les modules `system` ne doivent JAMAIS apparaître dans le Pages Builder.
/// Ils représentent des routes/pages FIXES, hors builder.
enum ModuleCategory {
  /// Modules système (POS, cart, ordering, payments)
  /// Ces modules sont des routes/pages FIXES et ne doivent JAMAIS être ajoutables
  /// comme blocs ou pages dans le Builder, même si activés par le SuperAdmin.
  system,

  /// Modules métier (delivery, loyalty, promotions, etc.)
  business,

  /// Modules visuels (pages_builder, theme)
  visual,

  // Legacy categories kept for backward compatibility but deprecated
  @Deprecated('Use ModuleCategory.business instead')
  core,

  @Deprecated('Use ModuleCategory.system instead')
  payment,

  @Deprecated('Use ModuleCategory.business instead')
  marketing,

  @Deprecated('Use ModuleCategory.system instead')
  operations,

  @Deprecated('Use ModuleCategory.visual instead')
  appearance,

  @Deprecated('Use ModuleCategory.business instead')
  staff,

  @Deprecated('Use ModuleCategory.business instead')
  analytics,
}

/// Extension pour ajouter des métadonnées à chaque catégorie de module.
extension ModuleCategoryX on ModuleCategory {
  /// Retourne un libellé lisible pour la catégorie.
  String get label {
    switch (this) {
      case ModuleCategory.system:
        return 'Système';
      case ModuleCategory.business:
        return 'Métier';
      case ModuleCategory.visual:
        return 'Visuel';
      // Legacy
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
      case ModuleCategory.system:
        return 'Modules système (POS, ordering, payments, etc.) - Routes fixes, non ajoutables au Builder';
      case ModuleCategory.business:
        return 'Modules métier (delivery, loyalty, promotions, etc.)';
      case ModuleCategory.visual:
        return 'Modules visuels (pages_builder, theme)';
      // Legacy
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

/// Niveau d'accès requis pour un module ou une route.
///
/// Définit qui peut accéder à un module donné en fonction de leur rôle.
enum ModuleAccessLevel {
  /// Accessible par tous les utilisateurs (clients)
  client,

  /// Accessible uniquement par le staff (serveurs, caissiers)
  staff,

  /// Accessible uniquement par les administrateurs
  admin,

  /// Modules système (cuisine, tablettes spécialisées)
  kitchen,

  /// Modules système (ne nécessite pas d'authentification spéciale)
  system,
}

/// Extension pour ajouter des métadonnées aux niveaux d'accès.
extension ModuleAccessLevelX on ModuleAccessLevel {
  /// Retourne un libellé lisible pour le niveau d'accès.
  String get label {
    switch (this) {
      case ModuleAccessLevel.client:
        return 'Client';
      case ModuleAccessLevel.staff:
        return 'Staff';
      case ModuleAccessLevel.admin:
        return 'Administrateur';
      case ModuleAccessLevel.kitchen:
        return 'Cuisine';
      case ModuleAccessLevel.system:
        return 'Système';
    }
  }

  /// Retourne une description du niveau d'accès.
  String get description {
    switch (this) {
      case ModuleAccessLevel.client:
        return 'Accessible à tous les utilisateurs connectés';
      case ModuleAccessLevel.staff:
        return 'Réservé au personnel (serveurs, caissiers)';
      case ModuleAccessLevel.admin:
        return 'Réservé aux administrateurs du restaurant';
      case ModuleAccessLevel.kitchen:
        return 'Réservé au personnel de cuisine';
      case ModuleAccessLevel.system:
        return 'Module système sans restriction spéciale';
    }
  }
}
