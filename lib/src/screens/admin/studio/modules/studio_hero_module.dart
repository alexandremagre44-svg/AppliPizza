// lib/src/screens/admin/studio/modules/studio_hero_module.dart
// Hero module - Complete hero banner editor with draft mode

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../design_system/app_theme.dart';
import '../../../../models/home_config.dart';

class StudioHeroModule extends StatefulWidget {
  final HomeConfig? draftHomeConfig;
  final Function(HomeConfig) onUpdate;

  const StudioHeroModule({
    super.key,
    required this.draftHomeConfig,
    required this.onUpdate,
  });

  @override
  State<StudioHeroModule> createState() => _StudioHeroModuleState();
}

class _StudioHeroModuleState extends State<StudioHeroModule> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _imageUrlController;
  late TextEditingController _ctaTextController;
  late TextEditingController _ctaActionController;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final hero = widget.draftHomeConfig?.hero;
    _titleController = TextEditingController(text: hero?.title ?? '');
    _subtitleController = TextEditingController(text: hero?.subtitle ?? '');
    _imageUrlController = TextEditingController(text: hero?.imageUrl ?? '');
    _ctaTextController = TextEditingController(text: hero?.ctaText ?? '');
    _ctaActionController = TextEditingController(text: hero?.ctaAction ?? '');
    _isActive = hero?.isActive ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageUrlController.dispose();
    _ctaTextController.dispose();
    _ctaActionController.dispose();
    super.dispose();
  }

  void _updateHero() {
    final updatedHero = HeroConfig(
      isActive: _isActive,
      imageUrl: _imageUrlController.text,
      title: _titleController.text,
      subtitle: _subtitleController.text,
      ctaText: _ctaTextController.text,
      ctaAction: _ctaActionController.text,
    );

    final updatedConfig = widget.draftHomeConfig?.copyWith(hero: updatedHero) ??
        HomeConfig.initial().copyWith(hero: updatedHero);

    widget.onUpdate(updatedConfig);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Module Hero', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Configurez la bannière principale de l\'écran d\'accueil',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildHeroEditor(),
        ],
      ),
    );
  }

  Widget _buildHeroEditor() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Activer le Hero'),
              subtitle: const Text('Afficher la bannière sur l\'écran d\'accueil'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
                _updateHero();
              },
            ),
            const Divider(height: 32),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'URL de l\'image',
                hintText: 'https://exemple.com/image.jpg',
                border: OutlineInputBorder(),
                helperText: 'URL de l\'image de fond du Hero',
              ),
              onChanged: (_) => _updateHero(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                hintText: 'Bienvenue chez Pizza Deli\'Zza',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (_) => _updateHero(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Sous-titre',
                hintText: 'Découvrez nos pizzas artisanales',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (_) => _updateHero(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctaTextController,
              decoration: const InputDecoration(
                labelText: 'Texte du bouton',
                hintText: 'Voir le menu',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _updateHero(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctaActionController,
              decoration: const InputDecoration(
                labelText: 'Action du bouton',
                hintText: '/menu',
                border: OutlineInputBorder(),
                helperText: 'Route GoRouter (ex: /menu, /products)',
              ),
              onChanged: (_) => _updateHero(),
            ),
            const SizedBox(height: 24),
            Text(
              'Les modifications sont automatiquement sauvegardées en mode brouillon. '
              'Cliquez sur "Publier" dans la barre supérieure pour enregistrer.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
