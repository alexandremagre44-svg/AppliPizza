// lib/src/services/email_template_service.dart
// Service pour gérer les templates d'emails

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:pizza_delizza/src/features/mailing/data/models/email_template.dart';
import '../utils/email_templates.dart';

class EmailTemplateService {
  static const String _templatesKey = 'email_templates_list';
  final Uuid _uuid = const Uuid();

  // Charger tous les templates
  Future<List<EmailTemplate>> loadTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? templatesJson = prefs.getString(_templatesKey);

      if (templatesJson == null || templatesJson.isEmpty) {
        // Initialiser avec les templates par défaut
        final defaultTemplates = _getDefaultTemplates();
        await saveTemplates(defaultTemplates);
        return defaultTemplates;
      }

      final List<dynamic> decoded = json.decode(templatesJson);
      return decoded.map((json) => EmailTemplate.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors du chargement des templates: $e');
      return [];
    }
  }

  // Sauvegarder la liste des templates
  Future<bool> saveTemplates(List<EmailTemplate> templates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          templates.map((template) => template.toJson()).toList();
      final String encoded = json.encode(jsonList);
      return await prefs.setString(_templatesKey, encoded);
    } catch (e) {
      print('Erreur lors de la sauvegarde des templates: $e');
      return false;
    }
  }

  // Ajouter un nouveau template
  Future<bool> addTemplate(EmailTemplate template) async {
    try {
      final templates = await loadTemplates();
      templates.add(template);
      return await saveTemplates(templates);
    } catch (e) {
      print('Erreur lors de l\'ajout du template: $e');
      return false;
    }
  }

  // Mettre à jour un template
  Future<bool> updateTemplate(EmailTemplate template) async {
    try {
      final templates = await loadTemplates();
      final index = templates.indexWhere((t) => t.id == template.id);

      if (index == -1) {
        print('Template non trouvé');
        return false;
      }

      templates[index] = template.copyWith(updatedAt: DateTime.now());
      return await saveTemplates(templates);
    } catch (e) {
      print('Erreur lors de la mise à jour du template: $e');
      return false;
    }
  }

  // Supprimer un template
  Future<bool> deleteTemplate(String id) async {
    try {
      final templates = await loadTemplates();
      templates.removeWhere((t) => t.id == id);
      return await saveTemplates(templates);
    } catch (e) {
      print('Erreur lors de la suppression du template: $e');
      return false;
    }
  }

  // Récupérer un template par ID
  Future<EmailTemplate?> getTemplateById(String id) async {
    try {
      final templates = await loadTemplates();
      return templates.firstWhere((t) => t.id == id);
    } catch (e) {
      print('Template non trouvé: $e');
      return null;
    }
  }

  // Prévisualiser un template avec des données de test
  String previewTemplate(EmailTemplate template,
      {Map<String, String>? testData}) {
    final defaultTestData = {
      'subject': template.subject,
      'content':
          'Ceci est un exemple de contenu pour prévisualiser votre template. Vous pouvez personnaliser ce texte avec vos propres variables.',
      'product': 'Pizza Margherita',
      'discount': '-20%',
      'ctaText': template.ctaText ?? 'Commander maintenant',
      'ctaUrl': template.ctaUrl ?? 'https://delizza.fr/commander',
      'bannerUrl': template.bannerUrl ??
          'https://images.unsplash.com/photo-1513104890138-7c749659a591',
      'unsubUrl': 'https://delizza.fr/unsubscribe/TOKEN',
      'appDownloadUrl': 'https://play.google.com/store/apps/details?id=fr.delizza',
    };

    final data = testData ?? defaultTestData;
    return EmailTemplates.compileTemplate(template.htmlBody, data);
  }

  // Templates par défaut
  List<EmailTemplate> _getDefaultTemplates() {
    final now = DateTime.now();

    return [
      EmailTemplate(
        id: _uuid.v4(),
        name: 'Template Standard',
        subject: 'Découvrez nos offres',
        htmlBody: EmailTemplates.getDefaultTemplate(),
        createdAt: now,
        ctaText: 'Voir nos pizzas',
        ctaUrl: 'https://delizza.fr/menu',
        bannerUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
      ),
      EmailTemplate(
        id: _uuid.v4(),
        name: 'Template Promo',
        subject: 'Offre spéciale cette semaine !',
        htmlBody: EmailTemplates.getPromoTemplate(),
        createdAt: now,
        ctaText: 'Profiter de l\'offre',
        ctaUrl: 'https://delizza.fr/promotions',
      ),
      EmailTemplate(
        id: _uuid.v4(),
        name: 'Template Nouveauté',
        subject: 'Nouvelle pizza au menu !',
        htmlBody: EmailTemplates.getNewProductTemplate(),
        createdAt: now,
        ctaText: 'Découvrir la nouveauté',
        ctaUrl: 'https://delizza.fr/nouveautes',
        bannerUrl: 'https://images.unsplash.com/photo-1595708684082-a173bb3a06c5',
      ),
    ];
  }
}
