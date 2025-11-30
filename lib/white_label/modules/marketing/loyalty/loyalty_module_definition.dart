import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Fidélité.
///
/// Ce module gère le programme de fidélité avec accumulation de points
/// et récompenses pour les clients réguliers.
ModuleDefinition get loyaltyModuleDefinition => const ModuleDefinition(
      id: ModuleId.loyalty,
      category: ModuleCategory.marketing,
      name: 'Fidélité',
      description: 'Programme de fidélité avec points et récompenses.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter la gestion des niveaux de fidélité
