// lib/src/admin/studio_b2/texts_editor.dart
// Editor for text configuration

import 'package:flutter/material.dart';
import '../../models/app_config.dart';
import '../../theme/app_theme.dart';

/// Editor for texts configuration
class TextsEditor extends StatefulWidget {
  final AppConfig config;
  final String appId;
  final Function(AppConfig) onConfigUpdated;

  const TextsEditor({
    super.key,
    required this.config,
    required this.appId,
    required this.onConfigUpdated,
  });

  @override
  State<TextsEditor> createState() => _TextsEditorState();
}

class _TextsEditorState extends State<TextsEditor> {
  late TextEditingController _welcomeTitleController;
  late TextEditingController _welcomeSubtitleController;

  @override
  void initState() {
    super.initState();
    _welcomeTitleController = TextEditingController(
      text: widget.config.home.texts.welcomeTitle,
    );
    _welcomeSubtitleController = TextEditingController(
      text: widget.config.home.texts.welcomeSubtitle,
    );
  }

  @override
  void dispose() {
    _welcomeTitleController.dispose();
    _welcomeSubtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.text_fields, size: 28, color: AppColors.primaryRed),
                const SizedBox(width: 12),
                const Text(
                  'Textes de l\'application',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Configurez les textes affichés sur l\'écran d\'accueil',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const Divider(height: 32),
            // Welcome title
            const Text(
              'Titre de bienvenue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _welcomeTitleController,
              decoration: const InputDecoration(
                labelText: 'Titre principal',
                helperText: 'Affiché en haut de l\'écran d\'accueil',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            // Welcome subtitle
            const Text(
              'Sous-titre de bienvenue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _welcomeSubtitleController,
              decoration: const InputDecoration(
                labelText: 'Sous-titre',
                helperText: 'Texte secondaire sous le titre',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer les modifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    final updatedTexts = TextsConfig(
      welcomeTitle: _welcomeTitleController.text,
      welcomeSubtitle: _welcomeSubtitleController.text,
    );

    final updatedConfig = widget.config.copyWith(
      home: widget.config.home.copyWith(
        texts: updatedTexts,
      ),
    );

    widget.onConfigUpdated(updatedConfig);
  }
}
