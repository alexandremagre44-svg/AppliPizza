// lib/src/screens/admin/_deprecated/popup_block_editor.dart
// ⚠️ DEPRECATED - Migrated to unified Studio (admin_studio_screen_refactored.dart)
// Preserved ONLY for rollback and reference.
// Do not import or use in new code.
//
// PopupBlockEditor - Éditeur complet de popups et roulette pour Studio Builder
// Material 3 + Pizza Deli'Zza Brand Guidelines

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../../models/popup_config.dart';
import '../../../services/popup_service.dart';
import '../../../services/roulette_rules_service.dart';
import '../../../design_system/app_theme.dart';

/// Éditeur de popup et roulette avec aperçu en temps réel
/// Conforme Material 3 et Brand Guidelines Pizza Deli'Zza
class PopupBlockEditor extends StatefulWidget {
  final PopupConfig? existingPopup;
  final RouletteRules? existingRouletteRules;
  final bool isRouletteMode;

  const PopupBlockEditor({
    super.key,
    this.existingPopup,
    this.existingRouletteRules,
    this.isRouletteMode = false,
  });

  @override
  State<PopupBlockEditor> createState() => _PopupBlockEditorState();
}

class _PopupBlockEditorState extends State<PopupBlockEditor> {
  final _formKey = GlobalKey<FormState>();
  final PopupService _popupService = PopupService();
  final RouletteRulesService _rouletteRulesService = RouletteRulesService();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageController;
  late TextEditingController _ctaTextController;
  late TextEditingController _ctaActionController;
  late TextEditingController _probabilityController;

  // État
  String _selectedType = 'popup';
  bool _isVisible = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.isRouletteMode && widget.existingRouletteRules != null) {
      // Mode roulette
      final rules = widget.existingRouletteRules!;
      _titleController = TextEditingController(text: 'Roulette de la chance');
      _descriptionController = TextEditingController(
        text: 'Configuration des règles de la roulette',
      );
      _imageController = TextEditingController();
      _ctaTextController = TextEditingController(text: 'Voir les paramètres');
      _ctaActionController = TextEditingController();
      _probabilityController = TextEditingController(text: '0');
      _selectedType = 'roulette';
      _isVisible = rules.isEnabled;
    } else if (widget.existingPopup != null) {
      // Mode édition popup
      final popup = widget.existingPopup!;
      _titleController = TextEditingController(text: popup.title);
      _descriptionController = TextEditingController(text: popup.message);
      _imageController = TextEditingController(text: popup.imageUrl ?? '');
      _ctaTextController = TextEditingController(text: popup.buttonText ?? '');
      _ctaActionController = TextEditingController(text: popup.buttonLink ?? '');
      _probabilityController = TextEditingController(text: '0');
      _selectedType = 'popup';
      _isVisible = popup.isEnabled;
    } else {
      // Mode création
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _imageController = TextEditingController();
      _ctaTextController = TextEditingController();
      _ctaActionController = TextEditingController();
      _probabilityController = TextEditingController(text: '0');
      _selectedType = 'popup';
      _isVisible = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _ctaTextController.dispose();
    _ctaActionController.dispose();
    _probabilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPopup != null || widget.existingRouletteRules != null;
    final screenTitle = isEditing
        ? (_selectedType == 'roulette' ? 'Modifier la roulette' : 'Modifier la popup')
        : 'Créer une popup';

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          screenTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulaire d'édition (gauche)
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: AppSpacing.paddingMD,
                child: _buildFormSection(),
              ),
            ),

            // Aperçu en temps réel (droite)
            Expanded(
              flex: 2,
              child: Container(
                color: AppColors.surface,
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingMD,
                  child: _buildPreviewSection(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Section formulaire
  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Type de contenu (Chips)
        if (!widget.isRouletteMode) ...[
          Text(
            'Type de contenu',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('Popup'),
                selected: _selectedType == 'popup',
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedType = 'popup');
                  }
                },
                selectedColor: AppColors.primaryContainer,
                backgroundColor: AppColors.surfaceContainer,
                labelStyle: AppTextStyles.labelLarge.copyWith(
                  color: _selectedType == 'popup'
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurface,
                ),
              ),
              ChoiceChip(
                label: const Text('Roulette'),
                selected: _selectedType == 'roulette',
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedType = 'roulette');
                  }
                },
                selectedColor: AppColors.primaryContainer,
                backgroundColor: AppColors.surfaceContainer,
                labelStyle: AppTextStyles.labelLarge.copyWith(
                  color: _selectedType == 'roulette'
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
        ],

        // Titre
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Titre *',
            hintText: 'Entrez le titre',
            prefixIcon: const Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le titre est requis';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: AppSpacing.md),

        // Description
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description *',
            hintText: 'Entrez la description',
            prefixIcon: const Icon(Icons.description),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La description est requise';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: AppSpacing.md),

        // Image (optionnelle)
        TextFormField(
          controller: _imageController,
          decoration: InputDecoration(
            labelText: 'URL de l\'image (optionnelle)',
            hintText: 'https://example.com/image.jpg',
            prefixIcon: const Icon(Icons.image),
          ),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: AppSpacing.md),

        // Probabilité (si roulette)
        if (_selectedType == 'roulette') ...[
          TextFormField(
            controller: _probabilityController,
            decoration: InputDecoration(
              labelText: 'Probabilité (%)',
              hintText: 'Entre 0 et 100',
              prefixIcon: const Icon(Icons.percent),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La probabilité est requise pour la roulette';
              }
              final probability = int.tryParse(value);
              if (probability == null || probability < 0 || probability > 100) {
                return 'La probabilité doit être entre 0 et 100';
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: AppSpacing.md),
        ],

        // Bouton CTA - Texte
        TextFormField(
          controller: _ctaTextController,
          decoration: InputDecoration(
            labelText: 'Texte du bouton',
            hintText: 'Ex: En savoir plus',
            prefixIcon: const Icon(Icons.touch_app),
          ),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: AppSpacing.md),

        // Bouton CTA - Action
        TextFormField(
          controller: _ctaActionController,
          decoration: InputDecoration(
            labelText: 'Action du bouton',
            hintText: 'Ex: /menu ou /profile',
            prefixIcon: const Icon(Icons.link),
          ),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: AppSpacing.lg),

        // Switch de visibilité
        Card(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
          child: SwitchListTile(
            title: Text(
              'Visible',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Activer ou désactiver l\'affichage',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            value: _isVisible,
            onChanged: (value) {
              setState(() => _isVisible = value);
            },
            activeColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  /// Section aperçu
  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // En-tête
        Row(
          children: [
            Icon(
              Icons.preview,
              color: AppColors.primary,
              size: 24,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Aperçu en temps réel',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Aperçu de la popup/roulette
        Card(
          elevation: 2,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.dialog,
          ),
          child: Padding(
            padding: AppSpacing.paddingLG,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image si présente
                if (_imageController.text.isNotEmpty) ...[
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: AppRadius.radiusSmall,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                ],

                // Icône de type
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _selectedType == 'roulette' ? Icons.casino : Icons.notifications,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Titre
                Text(
                  _titleController.text.isEmpty
                      ? 'Titre de la popup'
                      : _titleController.text,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  _descriptionController.text.isEmpty
                      ? 'Description de la popup apparaîtra ici'
                      : _descriptionController.text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),

                // Probabilité si roulette
                if (_selectedType == 'roulette' &&
                    _probabilityController.text.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentGoldLight,
                      borderRadius: AppRadius.chip,
                    ),
                    child: Text(
                      'Probabilité: ${_probabilityController.text}%',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                ],

                // Bouton CTA
                if (_ctaTextController.text.isNotEmpty)
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(_ctaTextController.text),
                  ),

                SizedBox(height: AppSpacing.sm),

                // Badge de visibilité
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: _isVisible
                        ? AppColors.successContainer
                        : AppColors.errorContainer,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    _isVisible ? 'Visible' : 'Masqué',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: AppSpacing.lg),

        // Informations supplémentaires
        Card(
          elevation: 0,
          color: AppColors.infoLight,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'L\'aperçu est une représentation simplifiée. Le rendu final peut varier.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.infoDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Barre d'actions en bas
  Widget _buildBottomBar() {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bouton Annuler
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            child: const Text('Annuler'),
          ),
          SizedBox(width: AppSpacing.sm),

          // Bouton Supprimer (si édition)
          if (widget.existingPopup != null) ...[
            FilledButton.tonal(
              onPressed: _isSaving ? null : _deletePopup,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.errorContainer,
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              child: const Text('Supprimer'),
            ),
            SizedBox(width: AppSpacing.sm),
          ],

          // Bouton Sauvegarder
          FilledButton(
            onPressed: _isSaving ? null : _savePopup,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.onPrimary,
                      ),
                    ),
                  )
                : const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  /// Sauvegarder la popup ou roulette
  Future<void> _savePopup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_selectedType == 'roulette') {
        // Sauvegarder la roulette
        await _saveRoulette();
      } else {
        // Sauvegarder la popup
        await _savePopupConfig();
      }

      if (mounted) {
        _showSnackBar('Sauvegarde réussie');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors de la sauvegarde: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// Sauvegarder la configuration de popup
  Future<void> _savePopupConfig() async {
    final isEditing = widget.existingPopup != null;
    final popup = PopupConfig(
      id: widget.existingPopup?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      message: _descriptionController.text.trim(),
      imageUrl: _imageController.text.trim().isEmpty
          ? null
          : _imageController.text.trim(),
      buttonText: _ctaTextController.text.trim().isEmpty
          ? null
          : _ctaTextController.text.trim(),
      buttonLink: _ctaActionController.text.trim().isEmpty
          ? null
          : _ctaActionController.text.trim(),
      isEnabled: _isVisible,
      createdAt: widget.existingPopup?.createdAt ?? DateTime.now(),
      priority: widget.existingPopup?.priority ?? 0,
    );

    final success = isEditing
        ? await _popupService.updatePopup(popup)
        : await _popupService.createPopup(popup);

    if (!success) {
      throw Exception('Échec de la sauvegarde de la popup');
    }
  }

  /// Sauvegarder la configuration de roulette
  Future<void> _saveRoulette() async {
    final rules = widget.existingRouletteRules?.copyWith(
          isEnabled: _isVisible,
        ) ??
        RouletteRules(
          isEnabled: _isVisible,
        );

    await _rouletteRulesService.saveRules(rules);
  }

  /// Supprimer la popup
  Future<void> _deletePopup() async {
    if (widget.existingPopup == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog,
        ),
        title: Text(
          'Supprimer la popup ?',
          style: AppTextStyles.headlineMedium,
        ),
        content: Text(
          'Cette action est irréversible. Voulez-vous continuer ?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isSaving = true);

      try {
        final success = await _popupService.deletePopup(widget.existingPopup!.id);
        if (success) {
          if (mounted) {
            _showSnackBar('Popup supprimée');
            Navigator.of(context).pop(true);
          }
        } else {
          throw Exception('Échec de la suppression');
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Erreur lors de la suppression: $e', isError: true);
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  /// Afficher un snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.snackbar,
        ),
      ),
    );
  }
}
