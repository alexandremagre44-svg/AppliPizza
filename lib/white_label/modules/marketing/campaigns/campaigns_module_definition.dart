import '../../../core/module_category.dart';
import '../../../core/module_definition.dart';
import '../../../core/module_id.dart';

/// Définition du module Campagnes.
///
/// Ce module permet de créer et gérer des campagnes marketing ciblées
/// (email, SMS, push notifications) pour engager les clients.
ModuleDefinition get campaignsModuleDefinition => const ModuleDefinition(
      id: ModuleId.campaigns,
      category: ModuleCategory.marketing,
      name: 'Campagnes',
      description: 'Création et gestion de campagnes marketing ciblées.',
      isPremium: true,
      requiresConfiguration: true,
      dependencies: [],
    );

// TODO: Ajouter les routes spécifiques au module
// TODO: Ajouter les widgets/screens du module (CampaignsAdminScreen, CampaignEditorScreen)
// TODO: Ajouter les providers Riverpod du module
// TODO: Ajouter les modèles de données (Campaign, CampaignTemplate, CampaignStats)
