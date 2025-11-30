import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Terminal de paiement.
///
/// Ce module permet l'intégration avec les terminaux de paiement physiques
/// (TPE) pour les paiements en point de vente.
ModuleDefinition get paymentTerminalModuleDefinition => const ModuleDefinition(
      id: ModuleId.paymentTerminal,
      category: ModuleCategory.payment,
      name: 'Terminal de paiement',
      description: 'Intégration avec les terminaux de paiement physiques.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [ModuleId.payments],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter l'intégration avec différents fabricants de TPE
