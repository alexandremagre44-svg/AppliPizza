import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Promotions.
///
/// Ce module gère les codes promotionnels, réductions et offres spéciales.
ModuleDefinition get promotionsModuleDefinition => const ModuleDefinition(
      id: ModuleId.promotions,
      category: ModuleCategory.marketing,
      name: 'Promotions',
      description: 'Gestion des codes promo et réductions.',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter les types de promotions (pourcentage, montant fixe, BOGO)
