import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Tablette cuisine.
///
/// Ce module affiche les commandes en cuisine sur une tablette dédiée
/// pour une meilleure organisation de la production.
ModuleDefinition get kitchenTabletModuleDefinition => const ModuleDefinition(
      id: ModuleId.kitchen_tablet,
      category: ModuleCategory.operations,
      name: 'Tablette cuisine',
      description: 'Affichage des commandes en cuisine sur tablette dédiée.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.ordering],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter la gestion des postes de travail (four, préparation, etc.)
