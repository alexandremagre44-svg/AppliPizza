import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Portefeuille.
///
/// Ce module permet aux clients de stocker du crédit dans un portefeuille
/// virtuel pour payer rapidement leurs commandes.
ModuleDefinition get walletModuleDefinition => const ModuleDefinition(
      id: ModuleId.wallet,
      category: ModuleCategory.payment,
      name: 'Portefeuille',
      description:
          'Portefeuille client pour stocker du crédit et payer rapidement.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.payments],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter la gestion des transactions de portefeuille
