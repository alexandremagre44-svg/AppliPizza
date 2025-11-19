// lib/src/services/campaign_service.dart
// Service pour gérer les campagnes d'emailing

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/campaign.dart';

class CampaignService {
  static const String _campaignsKey = 'campaigns_list';
  final Uuid _uuid = const Uuid();

  // Charger toutes les campagnes
  Future<List<Campaign>> loadCampaigns() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? campaignsJson = prefs.getString(_campaignsKey);

      if (campaignsJson == null || campaignsJson.isEmpty) {
        // Initialiser avec quelques campagnes de démonstration
        final defaultCampaigns = _getDefaultCampaigns();
        await saveCampaigns(defaultCampaigns);
        return defaultCampaigns;
      }

      final List<dynamic> decoded = json.decode(campaignsJson);
      return decoded.map((json) => Campaign.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors du chargement des campagnes: $e');
      return [];
    }
  }

  // Sauvegarder la liste des campagnes
  Future<bool> saveCampaigns(List<Campaign> campaigns) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          campaigns.map((campaign) => campaign.toJson()).toList();
      final String encoded = json.encode(jsonList);
      return await prefs.setString(_campaignsKey, encoded);
    } catch (e) {
      print('Erreur lors de la sauvegarde des campagnes: $e');
      return false;
    }
  }

  // Ajouter une nouvelle campagne
  Future<bool> addCampaign(Campaign campaign) async {
    try {
      final campaigns = await loadCampaigns();
      campaigns.add(campaign);
      return await saveCampaigns(campaigns);
    } catch (e) {
      print('Erreur lors de l\'ajout de la campagne: $e');
      return false;
    }
  }

  // Mettre à jour une campagne
  Future<bool> updateCampaign(Campaign campaign) async {
    try {
      final campaigns = await loadCampaigns();
      final index = campaigns.indexWhere((c) => c.id == campaign.id);

      if (index == -1) {
        print('Campagne non trouvée');
        return false;
      }

      campaigns[index] = campaign;
      return await saveCampaigns(campaigns);
    } catch (e) {
      print('Erreur lors de la mise à jour de la campagne: $e');
      return false;
    }
  }

  // Supprimer une campagne
  Future<bool> deleteCampaign(String id) async {
    try {
      final campaigns = await loadCampaigns();
      campaigns.removeWhere((c) => c.id == id);
      return await saveCampaigns(campaigns);
    } catch (e) {
      print('Erreur lors de la suppression de la campagne: $e');
      return false;
    }
  }

  // Récupérer une campagne par ID
  Future<Campaign?> getCampaignById(String id) async {
    try {
      final campaigns = await loadCampaigns();
      return campaigns.firstWhere((c) => c.id == id);
    } catch (e) {
      print('Campagne non trouvée: $e');
      return null;
    }
  }

  // Obtenir les campagnes par statut
  Future<List<Campaign>> getCampaignsByStatus(String status) async {
    final campaigns = await loadCampaigns();
    return campaigns.where((c) => c.status == status).toList();
  }

  // Simuler l'envoi d'une campagne (pour la démo)
  Future<bool> sendCampaign(String campaignId, int recipientCount) async {
    try {
      final campaigns = await loadCampaigns();
      final index = campaigns.indexWhere((c) => c.id == campaignId);

      if (index == -1) {
        return false;
      }

      // Simuler l'envoi avec des statistiques
      final stats = CampaignStats(
        totalRecipients: recipientCount,
        sent: recipientCount,
        failed: 0,
        opened: 0,
        clicked: 0,
      );

      campaigns[index] = campaigns[index].copyWith(
        status: 'sent',
        sentAt: DateTime.now(),
        stats: stats,
      );

      return await saveCampaigns(campaigns);
    } catch (e) {
      print('Erreur lors de l\'envoi de la campagne: $e');
      return false;
    }
  }

  // Mettre à jour les statistiques d'une campagne
  Future<bool> updateCampaignStats(String campaignId, CampaignStats stats) async {
    try {
      final campaigns = await loadCampaigns();
      final index = campaigns.indexWhere((c) => c.id == campaignId);

      if (index == -1) {
        return false;
      }

      campaigns[index] = campaigns[index].copyWith(stats: stats);
      return await saveCampaigns(campaigns);
    } catch (e) {
      print('Erreur lors de la mise à jour des statistiques: $e');
      return false;
    }
  }

  // Planifier une campagne
  Future<bool> scheduleCampaign(String campaignId, DateTime scheduleAt) async {
    try {
      final campaigns = await loadCampaigns();
      final index = campaigns.indexWhere((c) => c.id == campaignId);

      if (index == -1) {
        return false;
      }

      campaigns[index] = campaigns[index].copyWith(
        scheduleAt: scheduleAt,
        status: 'scheduled',
      );

      return await saveCampaigns(campaigns);
    } catch (e) {
      print('Erreur lors de la planification de la campagne: $e');
      return false;
    }
  }

  // Campagnes par défaut pour la démo
  List<Campaign> _getDefaultCampaigns() {
    final now = DateTime.now();

    return [
      Campaign(
        id: _uuid.v4(),
        name: 'Promo Weekend',
        templateId: 'template-promo',
        segment: 'all',
        status: 'draft',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Campaign(
        id: _uuid.v4(),
        name: 'Nouvelle Pizza du mois',
        templateId: 'template-nouveaute',
        segment: 'active',
        status: 'sent',
        createdAt: now.subtract(const Duration(days: 10)),
        sentAt: now.subtract(const Duration(days: 8)),
        stats: CampaignStats(
          totalRecipients: 150,
          sent: 150,
          failed: 0,
          opened: 95,
          clicked: 42,
        ),
      ),
      Campaign(
        id: _uuid.v4(),
        name: 'Offre VIP',
        templateId: 'template-standard',
        segment: 'vip',
        status: 'scheduled',
        scheduleAt: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
