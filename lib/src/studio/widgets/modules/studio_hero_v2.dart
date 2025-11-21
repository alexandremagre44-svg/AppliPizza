// lib/src/studio/widgets/modules/studio_hero_v2.dart
// Hero module V2 - Professional hero section editor with pro-level UX

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/home_config.dart';
import '../../models/media_asset_model.dart';
import '../media/image_selector_widget.dart';

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
  late TextEditingController _ctaActionController;
  
  String _ctaLinkType = 'menu'; // 'menu', 'promotions', 'customUrl'

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
    _ctaActionController = TextEditingController(text: config.heroCtaAction);
    
    // Determine CTA link type based on current action
    final action = config.heroCtaAction;
    if (action.contains('/menu')) {
      _ctaLinkType = 'menu';
    } else if (action.contains('/promotions')) {
      _ctaLinkType = 'promotions';
    } else {
      _ctaLinkType = 'customUrl';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _ctaTextController.dispose();
    _imageUrlController.dispose();
    _ctaActionController.dispose();
    super.dispose();
  }

  void _updateConfig() {
    final config = widget.homeConfig ?? HomeConfig.initial();
    widget.onUpdate(config.copyWith(
      heroTitle: _titleController.text,
      heroSubtitle: _subtitleController.text,
      heroCtaText: _ctaTextController.text,
      heroImageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      heroCtaAction: _ctaActionController.text,
    ));
  }

  void _onCtaLinkTypeChanged(String? value) {
    if (value == null) return;
    
    setState(() {
      _ctaLinkType = value;
      
      // Update CTA action based on type
      switch (value) {
        case 'menu':
          _ctaActionController.text = '/menu';
          break;
        case 'promotions':
          _ctaActionController.text = '/promotions';
          break;
        case 'customUrl':
          // Keep custom URL or clear if coming from preset
          if (_ctaActionController.text == '/menu' || 
              _ctaActionController.text == '/promotions') {
            _ctaActionController.text = '';
          }
          break;
      }
      
      _updateConfig();
    });
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _imageUrlController.text = clipboardData.text!;
        _updateConfig();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ URL collée depuis le presse-papier'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.homeConfig ?? HomeConfig.initial();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Section Hero',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Configurez la bannière principale de votre page d\'accueil',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Enable/Disable Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Afficher la section Hero',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Désactivez pour masquer la bannière sur la page d\'accueil',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: config.heroEnabled,
                  onChanged: (value) {
                    widget.onUpdate(config.copyWith(heroEnabled: value));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Image Section
          _buildSection(
            title: 'Image',
            icon: Icons.image_outlined,
            children: [
              // Media Manager selector
              ImageSelectorWidget(
                filterFolder: MediaFolder.hero,
                currentUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
                onImageSelected: (url, size) {
                  setState(() {
                    _imageUrlController.text = url;
                    _updateConfig();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✓ Image sélectionnée (${size.name})'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        labelText: 'URL de l\'image',
                        hintText: 'https://example.com/image.jpg',
                        helperText: 'Ou entrez l\'URL complète manuellement',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: (_) => _updateConfig(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Tooltip(
                    message: 'Coller depuis le presse-papier',
                    child: IconButton.filled(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.content_paste, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
              if (_imageUrlController.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prévisualisation disponible dans le panneau de droite',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Content Section
          _buildSection(
            title: 'Contenu',
            icon: Icons.text_fields,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre principal *',
                  hintText: 'Ex: Bienvenue chez Pizza Deli\'Zza',
                  helperText: 'Titre principal affiché sur la bannière',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                  errorText: _titleController.text.isEmpty && config.heroEnabled
                      ? 'Le titre est requis quand Hero est activé'
                      : null,
                ),
                onChanged: (_) {
                  _updateConfig();
                  setState(() {}); // Refresh to show/hide error
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _subtitleController,
                decoration: InputDecoration(
                  labelText: 'Sous-titre',
                  hintText: 'Ex: Les meilleures pizzas de la ville',
                  helperText: 'Description courte ou slogan',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 2,
                onChanged: (_) => _updateConfig(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Call-to-Action Section
          _buildSection(
            title: 'Bouton d\'action (CTA)',
            icon: Icons.touch_app_outlined,
            children: [
              TextField(
                controller: _ctaTextController,
                decoration: InputDecoration(
                  labelText: 'Texte du bouton',
                  hintText: 'Ex: Commander maintenant',
                  helperText: 'Texte affiché sur le bouton',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (_) => _updateConfig(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _ctaLinkType,
                decoration: InputDecoration(
                  labelText: 'Type de lien',
                  helperText: 'Destination du bouton',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'menu',
                    child: Row(
                      children: [
                        Icon(Icons.restaurant_menu, size: 18),
                        SizedBox(width: 8),
                        Text('Menu'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'promotions',
                    child: Row(
                      children: [
                        Icon(Icons.local_offer, size: 18),
                        SizedBox(width: 8),
                        Text('Promotions'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'customUrl',
                    child: Row(
                      children: [
                        Icon(Icons.link, size: 18),
                        SizedBox(width: 8),
                        Text('URL personnalisée'),
                      ],
                    ),
                  ),
                ],
                onChanged: _onCtaLinkTypeChanged,
              ),
              if (_ctaLinkType == 'customUrl') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _ctaActionController,
                  decoration: InputDecoration(
                    labelText: 'URL personnalisée',
                    hintText: '/custom-page ou https://...',
                    helperText: 'Chemin de route ou URL complète',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[50],
                    prefixIcon: const Icon(Icons.link),
                  ),
                  onChanged: (_) => _updateConfig(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Validation Summary
          if (config.heroEnabled) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isValidConfiguration()
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isValidConfiguration()
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isValidConfiguration()
                        ? Icons.check_circle
                        : Icons.warning_amber,
                    color: _isValidConfiguration()
                        ? Colors.green
                        : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isValidConfiguration()
                          ? 'Configuration valide et prête à être publiée'
                          : 'Certains champs requis sont vides',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isValidConfiguration()
                            ? Colors.green[700]
                            : Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  bool _isValidConfiguration() {
    return _titleController.text.isNotEmpty;
  }
}
