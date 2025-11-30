import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Constructeur de pages.
///
/// Ce module permet de créer des pages personnalisées avec des blocs
/// visuels, offrant une flexibilité maximale pour le contenu.
ModuleDefinition get pagesBuilderModuleDefinition => const ModuleDefinition(
      id: ModuleId.pagesBuilder,
      category: ModuleCategory.appearance,
      name: 'Constructeur de pages',
      description: 'Création de pages personnalisées avec blocs visuels.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter l'intégration avec Builder B3 existant
