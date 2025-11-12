// lib/src/screens/admin/mailing/email_template_preview_dialog.dart
// Dialog pour prévisualiser un template d'email

import 'package:flutter/material.dart';
import 'dart:js' as js;
import '../../../models/email_template.dart';
import '../../../services/email_template_service.dart';
import '../../../theme/app_theme.dart';

class EmailTemplatePreviewDialog extends StatelessWidget {
  final EmailTemplate template;

  const EmailTemplatePreviewDialog({
    super.key,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    final templateService = EmailTemplateService();
    final previewHtml = templateService.previewTemplate(template);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prévisualisation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.name,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Preview content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.blue.shade700, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Ceci est un aperçu avec des données de test',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // HTML Preview (simplified rendering)
                      _buildHtmlPreview(previewHtml),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Copy HTML to clipboard
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('HTML copié dans le presse-papier'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copier le HTML'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHtmlPreview(String html) {
    // Pour une prévisualisation simple, on affiche les informations principales
    // Dans une vraie app web, on pourrait utiliser un iframe ou HtmlElementView
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simuler le header rouge de l'email
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                children: [
                  Text(
                    '🍕 Pizza Deli\'Zza',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'La meilleure pizza, livrée chez vous',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Contenu simulé
          Text(
            template.subject,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ceci est un exemple de contenu pour prévisualiser votre template. '
            'Vous pouvez personnaliser ce texte avec vos propres variables.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textMedium,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Bouton CTA simulé
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                template.ctaText ?? 'Commander maintenant',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Footer simulé
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Pizza Deli\'Zza',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '123 Avenue des Pizzas, 75001 Paris',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Se désinscrire',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.primaryRed,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
