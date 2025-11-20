// lib/src/screens/admin/studio/modules/studio_texts_module.dart
// Texts module - Edit all app texts (focus on Home texts)

import 'package:flutter/material.dart';
import '../../../../design_system/app_theme.dart';
import '../../../../models/app_texts_config.dart';

class StudioTextsModule extends StatefulWidget {
  final AppTextsConfig? draftTextsConfig;
  final Function(AppTextsConfig) onUpdate;

  const StudioTextsModule({
    super.key,
    required this.draftTextsConfig,
    required this.onUpdate,
  });

  @override
  State<StudioTextsModule> createState() => _StudioTextsModuleState();
}

class _StudioTextsModuleState extends State<StudioTextsModule> {
  late Map<String, TextEditingController> _controllers;
  String _selectedSection = 'home';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final home = widget.draftTextsConfig?.home ?? HomeTexts.defaultTexts();
    _controllers = {
      'appName': TextEditingController(text: home.appName),
      'slogan': TextEditingController(text: home.slogan),
      'title': TextEditingController(text: home.title),
      'subtitle': TextEditingController(text: home.subtitle),
      'ctaViewMenu': TextEditingController(text: home.ctaViewMenu),
      'welcomeMessage': TextEditingController(text: home.welcomeMessage),
      'categoriesTitle': TextEditingController(text: home.categoriesTitle),
      'promosTitle': TextEditingController(text: home.promosTitle),
      'bestSellersTitle': TextEditingController(text: home.bestSellersTitle),
      'featuredTitle': TextEditingController(text: home.featuredTitle),
      'retryButton': TextEditingController(text: home.retryButton),
      'productAddedToCart': TextEditingController(text: home.productAddedToCart),
    };
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateTexts() {
    final updatedHome = HomeTexts(
      appName: _controllers['appName']!.text,
      slogan: _controllers['slogan']!.text,
      title: _controllers['title']!.text,
      subtitle: _controllers['subtitle']!.text,
      ctaViewMenu: _controllers['ctaViewMenu']!.text,
      welcomeMessage: _controllers['welcomeMessage']!.text,
      categoriesTitle: _controllers['categoriesTitle']!.text,
      promosTitle: _controllers['promosTitle']!.text,
      bestSellersTitle: _controllers['bestSellersTitle']!.text,
      featuredTitle: _controllers['featuredTitle']!.text,
      retryButton: _controllers['retryButton']!.text,
      productAddedToCart: _controllers['productAddedToCart']!.text,
    );

    final updatedConfig = widget.draftTextsConfig?.copyWith(home: updatedHome) ??
        AppTextsConfig.defaultConfig().copyWith(home: updatedHome);

    widget.onUpdate(updatedConfig);
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser aux valeurs par défaut ?'),
        content: const Text(
          'Tous les textes seront restaurés aux valeurs par défaut. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final defaultHome = HomeTexts.defaultTexts();
              setState(() {
                _controllers['appName']!.text = defaultHome.appName;
                _controllers['slogan']!.text = defaultHome.slogan;
                _controllers['title']!.text = defaultHome.title;
                _controllers['subtitle']!.text = defaultHome.subtitle;
                _controllers['ctaViewMenu']!.text = defaultHome.ctaViewMenu;
                _controllers['welcomeMessage']!.text = defaultHome.welcomeMessage;
                _controllers['categoriesTitle']!.text = defaultHome.categoriesTitle;
                _controllers['promosTitle']!.text = defaultHome.promosTitle;
                _controllers['bestSellersTitle']!.text = defaultHome.bestSellersTitle;
                _controllers['featuredTitle']!.text = defaultHome.featuredTitle;
                _controllers['retryButton']!.text = defaultHome.retryButton;
                _controllers['productAddedToCart']!.text = defaultHome.productAddedToCart;
              });
              _updateTexts();
              Navigator.of(context).pop();
            },
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Module Textes', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Personnalisez tous les textes de l\'application',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _resetToDefaults,
                icon: const Icon(Icons.restore),
                label: const Text('Réinitialiser'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildHomeTextsEditor(),
        ],
      ),
    );
  }

  Widget _buildHomeTextsEditor() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Textes de l\'écran d\'accueil', style: AppTextStyles.titleLarge),
            const SizedBox(height: 24),
            _buildTextField(
              'appName',
              'Nom de l\'application',
              'Pizza Deli\'Zza',
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'slogan',
              'Slogan',
              'À emporter uniquement',
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'title',
              'Titre principal',
              'Bienvenue chez Pizza Deli\'Zza',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'subtitle',
              'Sous-titre',
              'Découvrez nos pizzas artisanales',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'ctaViewMenu',
              'Bouton voir le menu',
              'Voir le menu',
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'welcomeMessage',
              'Message de bienvenue',
              'Bienvenue',
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'categoriesTitle',
              'Titre des catégories',
              'Nos catégories',
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'promosTitle',
              'Titre des promos',
              '🔥 Promos du moment',
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'bestSellersTitle',
              'Titre best-sellers',
              '🔥 Best-sellers',
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'featuredTitle',
              'Titre produits phares',
              '⭐ Produits phares',
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'retryButton',
              'Bouton réessayer',
              'Réessayer',
              maxLines: 1,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'productAddedToCart',
              'Message ajout panier',
              '{name} ajouté au panier !',
              maxLines: 1,
              helperText: 'Utilisez {name} pour le nom du produit',
            ),
            const SizedBox(height: 24),
            Text(
              'Les modifications sont automatiquement sauvegardées en mode brouillon. '
              'Cliquez sur "Publier" pour enregistrer.',
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

  Widget _buildTextField(
    String key,
    String label,
    String hint, {
    int maxLines = 1,
    String? helperText,
  }) {
    return TextField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        helperText: helperText,
      ),
      maxLines: maxLines,
      onChanged: (_) => _updateTexts(),
    );
  }
}

