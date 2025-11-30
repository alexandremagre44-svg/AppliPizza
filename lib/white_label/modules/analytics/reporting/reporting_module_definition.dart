import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Reporting.
///
/// Ce module fournit des tableaux de bord et statistiques de ventes
/// pour suivre les performances du restaurant.
ModuleDefinition get reportingModuleDefinition => const ModuleDefinition(
      id: ModuleId.reporting,
      category: ModuleCategory.analytics,
      name: 'Reporting',
      description: 'Tableaux de bord et statistiques de ventes.',
      isPremium: false,
      requiresConfiguration: false,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter les graphiques et visualisations
