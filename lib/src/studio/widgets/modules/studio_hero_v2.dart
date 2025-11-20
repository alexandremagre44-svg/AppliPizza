// lib/src/studio/widgets/modules/studio_hero_v2.dart
// Hero module V2 - Enhanced hero section editor

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/home_config.dart';

class StudioHeroV2 extends StatefulWidget {
  final HomeConfig? homeConfig;
  final Function(HomeConfig) onUpdate;

  const StudioHeroV2({
    super.key,
    required this.homeConfig,
    required this.onUpdate,
  });

  @override
  State<StudioHeroV2> createState() => _StudioHeroV2State();
}

class _StudioHeroV2State extends State<StudioHeroV2> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _ctaTextController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final config = widget.homeConfig ?? HomeConfig.initial();
    _titleController = TextEditingController(text: config.heroTitle);
    _subtitleController = TextEditingController(text: config.heroSubtitle);
    _ctaTextController = TextEditingController(text: config.heroCtaText);
    _imageUrlController = TextEditingController(text: config.heroImageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _ctaTextController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateConfig() {
    final config = widget.homeConfig ?? HomeConfig.initial();
    widget.onUpdate(config.copyWith(
      heroTitle: _titleController.text,
      heroSubtitle: _subtitleController.text,
      heroCtaText: _ctaTextController.text,
      heroImageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.homeConfig ?? HomeConfig.initial();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Section Hero',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Configurez l\'image de bannière principale',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Enable/Disable
          SwitchListTile(
            title: const Text('Activer la section Hero'),
            value: config.heroEnabled,
            onChanged: (value) {
              widget.onUpdate(config.copyWith(heroEnabled: value));
            },
          ),
          const SizedBox(height: 24),

          // Image URL
          TextField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              labelText: 'URL de l\'image',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateConfig(),
          ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateConfig(),
          ),
          const SizedBox(height: 16),

          // Subtitle
          TextField(
            controller: _subtitleController,
            decoration: const InputDecoration(
              labelText: 'Sous-titre',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (_) => _updateConfig(),
          ),
          const SizedBox(height: 16),

          // CTA Text
          TextField(
            controller: _ctaTextController,
            decoration: const InputDecoration(
              labelText: 'Texte du bouton',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateConfig(),
          ),
        ],
      ),
    );
  }
}
