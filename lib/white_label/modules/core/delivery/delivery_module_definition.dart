import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Livraison.
///
/// Ce module gère les livraisons avec zones de livraison, frais,
/// et suivi des livreurs.
ModuleDefinition get deliveryModuleDefinition => const ModuleDefinition(
      id: ModuleId.delivery,
      category: ModuleCategory.core,
      name: 'Livraison',
      description:
          'Gestion des livraisons avec zones, frais et suivi des livreurs.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [ModuleId.ordering],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
