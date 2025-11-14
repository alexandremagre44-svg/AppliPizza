// lib/src/screens/admin/studio/dialogs/edit_hero_dialog.dart
// Dialog for editing Hero banner configuration

import 'package:flutter/material.dart';
import '../../../data/models/home_config.dart';
import 'package:pizza_delizza/src/services/image_upload_service.dart';
import '../../../../shared/theme/app_theme.dart';

class EditHeroDialog extends StatefulWidget {
  final HeroConfig hero;
  final Function(HeroConfig) onSave;

  const EditHeroDialog({
    super.key,
    required this.hero,
    required this.onSave,
  });

  @override
  State<EditHeroDialog> createState() => _EditHeroDialogState();
}

class _EditHeroDialogState extends State<EditHeroDialog> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _ctaTextController;
  late TextEditingController _ctaActionController;
  late TextEditingController _imageUrlController;
  
  final ImageUploadService _imageService = ImageUploadService();
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.hero.title);
    _subtitleController = TextEditingController(text: widget.hero.subtitle);
    _ctaTextController = TextEditingController(text: widget.hero.ctaText);
    _ctaActionController = TextEditingController(text: widget.hero.ctaAction);
    _imageUrlController = TextEditingController(text: widget.hero.imageUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _ctaTextController.dispose();
    _ctaActionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final imageFile = await _imageService.pickImageFromGallery();
    
    if (imageFile == null) return;

    // Validate image
    if (!_imageService.isValidImage(imageFile)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image invalide. Formats acceptés : JPG, PNG, WEBP (max 10MB)'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final imageUrl = await _imageService.uploadImageWithProgress(
      imageFile,
      'home/hero',
      onProgress: (progress) {
        setState(() {
          _uploadProgress = progress;
        });
      },
    );

    setState(() {
      _isUploading = false;
    });

    if (imageUrl != null) {
      setState(() {
        _imageUrlController.text = imageUrl;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image téléchargée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du téléchargement de l\'image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le titre est requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedHero = widget.hero.copyWith(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      ctaText: _ctaTextController.text.trim(),
      ctaAction: _ctaActionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
    );

    widget.onSave(updatedHero);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, color: AppColors.primaryRed, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Modifier la bannière Hero',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title field
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Subtitle field
                TextField(
                  controller: _subtitleController,
                  decoration: InputDecoration(
                    labelText: 'Sous-titre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.subtitles),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Image picker with preview
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Image de la bannière',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Image preview or placeholder
                    if (_imageUrlController.text.isNotEmpty)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _imageUrlController.text,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 48),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _imageUrlController.text = '';
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Aucune image sélectionnée',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    // Upload button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickAndUploadImage,
                        icon: _isUploading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: _uploadProgress,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(
                          _isUploading 
                              ? 'Upload en cours... ${(_uploadProgress * 100).toInt()}%' 
                              : _imageUrlController.text.isEmpty
                                  ? 'Choisir une image'
                                  : 'Changer l\'image',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // CTA Text field
                TextField(
                  controller: _ctaTextController,
                  decoration: InputDecoration(
                    labelText: 'Texte du bouton',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.touch_app),
                  ),
                ),
                const SizedBox(height: 16),

                // CTA Action field
                TextField(
                  controller: _ctaActionController,
                  decoration: InputDecoration(
                    labelText: 'Action du bouton (route)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.arrow_forward),
                    helperText: 'Ex: /menu, /admin/pizza',
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
