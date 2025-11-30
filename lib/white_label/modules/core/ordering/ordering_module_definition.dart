import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Commandes en ligne.
///
/// Ce module permet de prendre des commandes clients sur différents canaux :
/// sur place, à emporter, ou en livraison.
ModuleDefinition get orderingModuleDefinition => const ModuleDefinition(
      id: ModuleId.ordering,
      category: ModuleCategory.core,
      name: 'Commandes en ligne',
      description:
          'Permet de prendre des commandes clients (sur place / à emporter / livraison).',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
