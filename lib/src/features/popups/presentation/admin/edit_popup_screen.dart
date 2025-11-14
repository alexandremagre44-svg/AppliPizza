// lib/src/screens/admin/studio/edit_popup_screen.dart
// Advanced popup editor with live preview

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../data/models/popup_config.dart';
import 'package:pizza_delizza/src/services/popup_service.dart';
import 'package:pizza_delizza/src/services/image_upload_service.dart';
import '../../shared/design_system/app_theme.dart';

class EditPopupScreen extends StatefulWidget {
  final PopupConfig? existingPopup;
  
  const EditPopupScreen({super.key, this.existingPopup});

  @override
  State<EditPopupScreen> createState() => _EditPopupScreenState();
}

class _EditPopupScreenState extends State<EditPopupScreen> {
  final PopupService _popupService = PopupService();
  final ImageUploadService _imageUploadService = ImageUploadService();
  
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late TextEditingController _buttonTextController;
  late TextEditingController _buttonLinkController;
  
  PopupTrigger _selectedTrigger = PopupTrigger.onAppOpen;
  PopupAudience _selectedAudience = PopupAudience.all;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isEnabled = true;
  String? _imageUrl;
  File? _selectedImageFile;
  bool _isUploading = false;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    final popup = widget.existingPopup;
    _titleController = TextEditingController(text: popup?.title ?? '');
    _messageController = TextEditingController(text: popup?.message ?? '');
    _buttonTextController = TextEditingController(text: popup?.buttonText ?? '');
    _buttonLinkController = TextEditingController(text: popup?.buttonLink ?? '');
    _selectedTrigger = popup?.trigger ?? PopupTrigger.onAppOpen;
    _selectedAudience = popup?.audience ?? PopupAudience.all;
    _startDate = popup?.startDate;
    _endDate = popup?.endDate;
    _isEnabled = popup?.isEnabled ?? true;
    _imageUrl = popup?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _buttonTextController.dispose();
    _buttonLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _imageUploadService.pickImageFromGallery();
    if (file != null) {
      if (_imageUploadService.isValidImage(file)) {
        setState(() {
          _selectedImageFile = file;
        });
      } else {
        _showSnackBar('Image invalide. Taille max: 10MB', isError: true);
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImageFile == null) return;
    
    setState(() => _isUploading = true);
    
    final url = await _imageUploadService.uploadImage(
      _selectedImageFile!,
      'popups',
    );
    
    setState(() {
      _isUploading = false;
      if (url != null) {
        _imageUrl = url;
        _selectedImageFile = null;
      }
    });
    
    if (url == null) {
      _showSnackBar('Erreur lors du téléchargement', isError: true);
    }
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _applyTemplate(String templateName) {
    switch (templateName) {
      case 'special_offer':
        setState(() {
          _titleController.text = '🎉 Offre Spéciale !';
          _messageController.text = 'Profitez de -20% sur votre prochaine commande avec le code SPECIAL20';
          _buttonTextController.text = 'J\'en profite';
          _buttonLinkController.text = '/menu';
          _selectedTrigger = PopupTrigger.onAppOpen;
          _selectedAudience = PopupAudience.all;
        });
        break;
      case 'new_product':
        setState(() {
          _titleController.text = '🍕 Nouvelle Pizza !';
          _messageController.text = 'Découvrez notre nouvelle pizza du chef, disponible maintenant';
          _buttonTextController.text = 'Découvrir';
          _buttonLinkController.text = '/menu';
          _selectedTrigger = PopupTrigger.onHomeScroll;
          _selectedAudience = PopupAudience.all;
        });
        break;
      case 'loyalty':
        setState(() {
          _titleController.text = '⭐ Programme Fidélité';
          _messageController.text = 'Gagnez des points à chaque commande et obtenez des récompenses';
          _buttonTextController.text = 'En savoir plus';
          _buttonLinkController.text = '/profile';
          _selectedTrigger = PopupTrigger.onAppOpen;
          _selectedAudience = PopupAudience.newUsers;
        });
        break;
    }
  }

  Future<void> _savePopup() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Le titre est requis', isError: true);
      return;
    }
    
    if (_messageController.text.trim().isEmpty) {
      _showSnackBar('Le message est requis', isError: true);
      return;
    }
    
    // Upload image if selected but not uploaded yet
    if (_selectedImageFile != null) {
      await _uploadImage();
      if (_imageUrl == null) {
        return; // Upload failed
      }
    }
    
    setState(() => _isSaving = true);
    
    final popup = PopupConfig(
      id: widget.existingPopup?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      imageUrl: _imageUrl,
      buttonText: _buttonTextController.text.trim().isEmpty 
          ? null 
          : _buttonTextController.text.trim(),
      buttonLink: _buttonLinkController.text.trim().isEmpty 
          ? null 
          : _buttonLinkController.text.trim(),
      trigger: _selectedTrigger,
      audience: _selectedAudience,
      startDate: _startDate,
      endDate: _endDate,
      isEnabled: _isEnabled,
      createdAt: widget.existingPopup?.createdAt ?? DateTime.now(),
    );
    
    final success = widget.existingPopup == null
        ? await _popupService.createPopup(popup)
        : await _popupService.updatePopup(popup);
    
    setState(() => _isSaving = false);
    
    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      _showSnackBar('Erreur lors de l\'enregistrement', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingPopup == null ? 'Nouveau Popup' : 'Modifier le Popup'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          if (!_isSaving && !_isUploading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _savePopup,
            ),
          if (_isSaving || _isUploading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;
          
          if (isWideScreen) {
            // Split screen layout for desktop
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildFormSection(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 1,
                  child: _buildPreviewSection(),
                ),
              ],
            );
          } else {
            // Tabbed layout for mobile
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: AppColors.primaryRed,
                    unselectedLabelColor: AppColors.textMedium,
                    indicatorColor: AppColors.primaryRed,
                    tabs: const [
                      Tab(text: 'Configuration', icon: Icon(Icons.edit, size: 20)),
                      Tab(text: 'Aperçu', icon: Icon(Icons.visibility, size: 20)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildFormSection(),
                        _buildPreviewSection(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFormSection() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template buttons
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.primaryRed, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text('Utiliser un modèle', style: AppTextStyles.titleMedium),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _buildTemplateChip('Offre Spéciale', 'special_offer'),
                      _buildTemplateChip('Nouveauté', 'new_product'),
                      _buildTemplateChip('Fidélité', 'loyalty'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Basic fields
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Titre*',
              border: OutlineInputBorder(borderRadius: AppRadius.input),
              prefixIcon: const Icon(Icons.title),
            ),
            onChanged: (_) => setState(() {}),
          ),
          
          SizedBox(height: AppSpacing.md),
          
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Message*',
              border: OutlineInputBorder(borderRadius: AppRadius.input),
              prefixIcon: const Icon(Icons.message),
            ),
            maxLines: 3,
            onChanged: (_) => setState(() {}),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Image section
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Image (optionnelle)', style: AppTextStyles.titleMedium),
                  SizedBox(height: AppSpacing.md),
                  if (_imageUrl != null || _selectedImageFile != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.card,
                          child: _selectedImageFile != null
                              ? Image.file(_selectedImageFile!, height: 150, width: double.infinity, fit: BoxFit.cover)
                              : Image.network(_imageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                            onPressed: () => setState(() {
                              _imageUrl = null;
                              _selectedImageFile = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                  if (_imageUrl == null && _selectedImageFile == null)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Ajouter une image'),
                      onPressed: _isUploading ? null : _pickImage,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Button fields
          TextField(
            controller: _buttonTextController,
            decoration: InputDecoration(
              labelText: 'Texte du bouton (optionnel)',
              border: OutlineInputBorder(borderRadius: AppRadius.input),
              prefixIcon: const Icon(Icons.touch_app),
            ),
            onChanged: (_) => setState(() {}),
          ),
          
          SizedBox(height: AppSpacing.md),
          
          TextField(
            controller: _buttonLinkController,
            decoration: InputDecoration(
              labelText: 'Lien du bouton (route GoRouter)',
              border: OutlineInputBorder(borderRadius: AppRadius.input),
              prefixIcon: const Icon(Icons.link),
              hintText: '/menu, /profile, etc.',
            ),
            onChanged: (_) => setState(() {}),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Trigger and audience
          DropdownButtonFormField<PopupTrigger>(
            value: _selectedTrigger,
            decoration: InputDecoration(
              labelText: 'Déclencheur',
              border: OutlineInputBorder(borderRadius: AppRadius.input),
              prefixIcon: const Icon(Icons.play_arrow),
            ),
            items: PopupTrigger.values.map((trigger) {
              return DropdownMenuItem(
                value: trigger,
                child: Text(_getTriggerLabel(trigger)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedTrigger = value);
              }
            },
          ),
          
          SizedBox(height: AppSpacing.md),
          
          DropdownButtonFormField<PopupAudience>(
            value: _selectedAudience,
            decoration: InputDecoration(
              labelText: 'Audience',
              border: OutlineInputBorder(borderRadius: AppRadius.input),
              prefixIcon: const Icon(Icons.people),
            ),
            items: PopupAudience.values.map((audience) {
              return DropdownMenuItem(
                value: audience,
                child: Text(_getAudienceLabel(audience)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedAudience = value);
              }
            },
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Dates
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_startDate == null 
                      ? 'Date de début' 
                      : 'Début: ${_formatDate(_startDate!)}'),
                  onPressed: () => _selectDate(true),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_endDate == null 
                      ? 'Date de fin' 
                      : 'Fin: ${_formatDate(_endDate!)}'),
                  onPressed: () => _selectDate(false),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Enable toggle
          SwitchListTile(
            title: const Text('Popup actif'),
            value: _isEnabled,
            activeColor: AppColors.primaryRed,
            onChanged: (value) => setState(() => _isEnabled = value),
          ),
          
          SizedBox(height: AppSpacing.xxl),
          
          // Save button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving || _isUploading ? null : _savePopup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
              child: _isSaving || _isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(widget.existingPopup == null ? 'Créer' : 'Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      color: AppColors.backgroundLight,
      child: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingXL,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildPopupPreview(),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupPreview() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _titleController.text.isEmpty 
                        ? 'Titre du popup' 
                        : _titleController.text,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: _titleController.text.isEmpty 
                          ? AppColors.textLight 
                          : AppColors.textDark,
                    ),
                  ),
                ),
                Icon(
                  Icons.close,
                  color: AppColors.textMedium,
                  size: 20,
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.md),
            
            if (_imageUrl != null || _selectedImageFile != null) ...[
              ClipRRect(
                borderRadius: AppRadius.card,
                child: _selectedImageFile != null
                    ? Image.file(_selectedImageFile!, height: 200, width: double.infinity, fit: BoxFit.cover)
                    : Image.network(_imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              SizedBox(height: AppSpacing.md),
            ],
            
            Text(
              _messageController.text.isEmpty 
                  ? 'Message du popup. Ajoutez votre contenu ici...' 
                  : _messageController.text,
              style: AppTextStyles.bodyLarge.copyWith(
                color: _messageController.text.isEmpty 
                    ? AppColors.textLight 
                    : AppColors.textDark,
              ),
            ),
            
            if (_buttonTextController.text.isNotEmpty) ...[
              SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                  child: Text(_buttonTextController.text),
                ),
              ),
            ],
            
            SizedBox(height: AppSpacing.sm),
            
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Ne plus afficher',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String label, String templateId) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _applyTemplate(templateId),
      backgroundColor: AppColors.primaryRed.withOpacity(0.1),
      labelStyle: TextStyle(color: AppColors.primaryRed),
    );
  }

  String _getTriggerLabel(PopupTrigger trigger) {
    switch (trigger) {
      case PopupTrigger.onAppOpen:
        return 'À l\'ouverture de l\'app';
      case PopupTrigger.onHomeScroll:
        return 'Au scroll sur l\'accueil';
    }
  }

  String _getAudienceLabel(PopupAudience audience) {
    switch (audience) {
      case PopupAudience.all:
        return 'Tous les utilisateurs';
      case PopupAudience.newUsers:
        return 'Nouveaux utilisateurs';
      case PopupAudience.loyalUsers:
        return 'Utilisateurs fidèles';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    );
  }
}
