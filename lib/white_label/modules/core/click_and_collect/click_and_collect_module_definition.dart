import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Click & Collect.
///
/// Ce module permet aux clients de commander en ligne et de venir
/// récupérer leur commande sur place.
ModuleDefinition get clickAndCollectModuleDefinition => const ModuleDefinition(
      id: ModuleId.clickAndCollect,
      category: ModuleCategory.core,
      name: 'Click & Collect',
      description:
          'Permet aux clients de commander en ligne et récupérer sur place.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [ModuleId.ordering],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
