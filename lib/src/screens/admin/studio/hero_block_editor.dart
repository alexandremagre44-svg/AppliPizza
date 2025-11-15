// lib/src/screens/admin/studio/hero_block_editor.dart
// Screen for editing Hero banner configuration with Material 3 design

import 'package:flutter/material.dart';
import '../../../models/home_config.dart';
import '../../../services/home_config_service.dart';
import '../../../services/image_upload_service.dart';
import '../../../design_system/app_theme.dart';

/// Standalone screen for editing Hero banner configuration
/// Follows Material 3 design and Pizza Deli'Zza brand guidelines
class HeroBlockEditor extends StatefulWidget {
  final HeroConfig? initialHero;
  final VoidCallback? onSaved;

  const HeroBlockEditor({
    super.key,
    this.initialHero,
    this.onSaved,
  });

  @override
  State<HeroBlockEditor> createState() => _HeroBlockEditorState();
}

class _HeroBlockEditorState extends State<HeroBlockEditor> {
  final _formKey = GlobalKey<FormState>();
  final HomeConfigService _homeConfigService = HomeConfigService();
  final ImageUploadService _imageService = ImageUploadService();

  // Text controllers
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _ctaTextController;
  late TextEditingController _ctaActionController;

  // State
  String _imageUrl = '';
  bool _isActive = true;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _ctaTextController = TextEditingController();
    _ctaActionController = TextEditingController();
    _loadHeroData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _ctaTextController.dispose();
    _ctaActionController.dispose();
    super.dispose();
  }

  /// Load existing Hero data from Firestore
  Future<void> _loadHeroData() async {
    setState(() => _isLoading = true);

    try {
      // Use provided initialHero or load from service
      HeroConfig? hero = widget.initialHero;
      
      if (hero == null) {
        final config = await _homeConfigService.getHomeConfig();
        hero = config?.hero;
      }

      if (hero != null) {
        _titleController.text = hero.title;
        _subtitleController.text = hero.subtitle;
        _ctaTextController.text = hero.ctaText;
        _ctaActionController.text = hero.ctaAction;
        _imageUrl = hero.imageUrl;
        _isActive = hero.isActive;
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors du chargement: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Pick and upload image
  Future<void> _pickAndUploadImage() async {
    final imageFile = await _imageService.pickImageFromGallery();
    
    if (imageFile == null) return;

    // Validate image
    if (!_imageService.isValidImage(imageFile)) {
      if (mounted) {
        _showSnackBar(
          'Image invalide. Formats acceptés : JPG, PNG, WEBP (max 10MB)',
          isError: true,
        );
      }
      return;
    }

    setState(() {
      _isUploadingImage = true;
      _uploadProgress = 0.0;
    });

    final imageUrl = await _imageService.uploadImageWithProgress(
      imageFile,
      'home/hero',
      onProgress: (progress) {
        if (mounted) {
          setState(() => _uploadProgress = progress);
        }
      },
    );

    setState(() => _isUploadingImage = false);

    if (imageUrl != null) {
      setState(() => _imageUrl = imageUrl);
      if (mounted) {
        _showSnackBar('Image téléchargée avec succès');
      }
    } else {
      if (mounted) {
        _showSnackBar('Erreur lors du téléchargement de l\'image', isError: true);
      }
    }
  }

  /// Save Hero configuration to Firestore
  Future<void> _saveHero() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedHero = HeroConfig(
        isActive: _isActive,
        imageUrl: _imageUrl,
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim(),
        ctaText: _ctaTextController.text.trim(),
        ctaAction: _ctaActionController.text.trim(),
      );

      final success = await _homeConfigService.updateHeroConfig(updatedHero);

      if (success && mounted) {
        _showSnackBar('Hero enregistré avec succès');
        widget.onSaved?.call();
        // Go back after successful save
        Navigator.of(context).pop();
      } else if (!success && mounted) {
        _showSnackBar('Erreur lors de l\'enregistrement', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Hero',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Card
                    Card(
                      color: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusLarge,
                      ),
                      elevation: 0,
                      shadowColor: AppColors.black.withOpacity(0.08),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section
                            _buildImageSection(),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Title Field
                            _buildTextField(
                              controller: _titleController,
                              label: 'Titre',
                              required: true,
                              maxLines: 2,
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Subtitle Field
                            _buildTextField(
                              controller: _subtitleController,
                              label: 'Sous-titre',
                              maxLines: 2,
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // CTA Text Field
                            _buildTextField(
                              controller: _ctaTextController,
                              label: 'Texte du bouton CTA',
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // CTA Action Field
                            _buildTextField(
                              controller: _ctaActionController,
                              label: 'Action / lien du CTA',
                              helperText: 'Ex: /menu, /admin/pizza',
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Visibility Switch
                            _buildVisibilitySwitch(),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Save Button
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image principale',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Image preview or placeholder
        Card(
          color: AppColors.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          clipBehavior: Clip.antiAlias,
          child: _imageUrl.isNotEmpty
              ? Stack(
                  children: [
                    Image.network(
                      _imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    ),
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() => _imageUrl = '');
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.overlay,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : _buildImagePlaceholder(),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Upload button
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: _isUploadingImage ? null : _pickAndUploadImage,
            child: _isUploadingImage
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: _uploadProgress,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Upload en cours... ${(_uploadProgress * 100).toInt()}%',
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(_imageUrl.isEmpty ? 'Choisir une image' : 'Changer l\'image'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Aucune image sélectionnée',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label *' : label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: label,
            helperText: helperText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildVisibilitySwitch() {
    return Card(
      color: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: SwitchListTile(
        title: Text(
          'Visibilité',
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: Text(
          _isActive ? 'Hero actif' : 'Hero désactivé',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        value: _isActive,
        onChanged: (value) {
          setState(() => _isActive = value);
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return FilledButton(
      onPressed: _isSaving ? null : _saveHero,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      child: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.white,
              ),
            )
          : Text(
              'Enregistrer',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
    );
  }
}
