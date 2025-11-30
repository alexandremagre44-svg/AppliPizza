import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Newsletter.
///
/// Ce module gère l'envoi de newsletters et communications marketing
/// aux clients inscrits.
ModuleDefinition get newsletterModuleDefinition => const ModuleDefinition(
      id: ModuleId.newsletter,
      category: ModuleCategory.marketing,
      name: 'Newsletter',
      description: 'Envoi de newsletters et communications marketing.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter l'intégration avec des services d'emailing (Mailchimp, Sendinblue)
