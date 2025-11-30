import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Roulette.
///
/// Ce module propose un jeu de roulette marketing permettant aux clients
/// de gagner des réductions ou des cadeaux.
ModuleDefinition get rouletteModuleDefinition => const ModuleDefinition(
      id: ModuleId.roulette,
      category: ModuleCategory.marketing,
      name: 'Roulette',
      description: 'Jeu de la roulette pour gagner des réductions.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter la configuration des segments de la roulette
