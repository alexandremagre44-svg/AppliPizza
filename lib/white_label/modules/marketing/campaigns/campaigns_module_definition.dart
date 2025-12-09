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
// TODO: Ajouter les widgets/screens du module
//       - CampaignsAdminScreen: Liste et gestion des campagnes
//       - CampaignEditorScreen: Création/édition de campagne
//       - CampaignTemplatesScreen: Templates prédéfinis
// TODO: Ajouter les providers Riverpod du module
//       - campaignsProvider: Liste des campagnes
//       - campaignStatsProvider: Statistiques d'une campagne
// TODO: Ajouter les modèles de données
//       - Campaign: {id, name, type, status, targetSegments, content, schedule}
//       - CampaignTemplate: {id, name, category, defaultContent}
//       - CampaignStats: {sent, opened, clicked, converted}
// TODO: Intégration avec services d'emailing (Mailchimp, SendGrid, Brevo)
//       - API endpoints for campaign management
//       - Webhook handlers for delivery status
