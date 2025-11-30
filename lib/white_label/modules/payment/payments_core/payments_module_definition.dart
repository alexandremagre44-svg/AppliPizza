import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Paiements (cœur).
///
/// Ce module gère les paiements en ligne (CB, etc.) et sert de base
/// pour les autres modules de paiement.
ModuleDefinition get paymentsModuleDefinition => const ModuleDefinition(
      id: ModuleId.payments,
      category: ModuleCategory.payment,
      name: 'Paiements',
      description: 'Gestion des paiements en ligne (CB, etc.).',
      isPremium: false,
      requiresConfiguration: true,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter l'intégration Stripe / autres PSP
