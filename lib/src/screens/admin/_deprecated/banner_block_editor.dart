// lib/src/screens/admin/_deprecated/banner_block_editor.dart
// ⚠️ DEPRECATED - Migrated to unified Studio (admin_studio_screen_refactored.dart)
// Preserved ONLY for rollback and reference.
// Do not import or use in new code.
//
// Screen for editing Promotional Banner configuration with Material 3 design

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/home_config.dart';
import '../../../services/home_config_service.dart';
import '../../../design_system/colors.dart';
import '../../../design_system/spacing.dart';
import '../../../design_system/radius.dart';
import '../../../design_system/text_styles.dart';
import '../../../design_system/shadows.dart';

/// Standalone screen for editing Promotional Banner configuration
/// Follows Material 3 design and Pizza Deli'Zza brand guidelines
class BannerBlockEditor extends StatefulWidget {
  final PromoBannerConfig? initialBanner;
  final VoidCallback? onSaved;

  const BannerBlockEditor({
    super.key,
    this.initialBanner,
    this.onSaved,
  });

  @override
  State<BannerBlockEditor> createState() => _BannerBlockEditorState();
}

class _BannerBlockEditorState extends State<BannerBlockEditor> {
  final _formKey = GlobalKey<FormState>();
  final HomeConfigService _homeConfigService = HomeConfigService();

  // Text controllers
  late TextEditingController _textController;

  // State
  Color _backgroundColor = AppColors.primary; // Default #D32F2F
  Color _textColor = AppColors.white; // Default white
  bool _isActive = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _loadBannerData();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// Load existing Banner data from Firestore
  Future<void> _loadBannerData() async {
    setState(() => _isLoading = true);

    try {
      // Use provided initialBanner or load from service
      PromoBannerConfig? banner = widget.initialBanner;
      
      if (banner == null) {
        final config = await _homeConfigService.getHomeConfig();
        banner = config?.promoBanner;
      }

      if (banner != null) {
        _textController.text = banner.text;
        _isActive = banner.isActive;
        
        // Parse colors from hex strings
        final bgColorValue = ColorConverter.hexToColor(banner.backgroundColor);
        _backgroundColor = bgColorValue != null 
            ? Color(bgColorValue) 
            : AppColors.primary;
        
        final textColorValue = ColorConverter.hexToColor(banner.textColor);
        _textColor = textColorValue != null 
            ? Color(textColorValue) 
            : AppColors.white;
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

  /// Show color picker dialog
  Future<void> _pickColor({required bool isBackground}) async {
    Color currentColor = isBackground ? _backgroundColor : _textColor;
    Color? selectedColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isBackground ? 'Couleur de fond' : 'Couleur du texte',
          style: AppTextStyles.titleMedium,
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            labelTypes: const [ColorLabelType.hex],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (selectedColor != null) {
                setState(() {
                  if (isBackground) {
                    _backgroundColor = selectedColor!;
                  } else {
                    _textColor = selectedColor!;
                  }
                });
              }
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Save Banner configuration to Firestore
  Future<void> _saveBanner() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedBanner = PromoBannerConfig(
        isActive: _isActive,
        text: _textController.text.trim(),
        backgroundColor: ColorConverter.colorToHexWithoutAlpha(_backgroundColor.value),
        textColor: ColorConverter.colorToHexWithoutAlpha(_textColor.value),
      );

      final success = await _homeConfigService.updatePromoBanner(updatedBanner);

      if (success && mounted) {
        _showSnackBar('Bandeau enregistré avec succès');
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
          'Bandeau',
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
                            // Preview Section
                            _buildPreviewSection(),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Text Field
                            _buildTextField(
                              controller: _textController,
                              label: 'Texte du bandeau',
                              required: true,
                              maxLines: 2,
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Background Color Picker
                            _buildColorPicker(
                              label: 'Couleur de fond',
                              color: _backgroundColor,
                              onTap: () => _pickColor(isBackground: true),
                            ),
                            
                            const SizedBox(height: AppSpacing.md),
                            
                            // Text Color Picker
                            _buildColorPicker(
                              label: 'Couleur du texte',
                              color: _textColor,
                              onTap: () => _pickColor(isBackground: false),
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

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aperçu',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Preview banner
        Card(
          color: _backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.local_offer,
                  color: _textColor,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _textController.text.isEmpty 
                        ? 'Aperçu du texte du bandeau' 
                        : _textController.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _textColor,
                      fontWeight: FontWeight.w600,
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
          onChanged: (value) => setState(() {}), // Update preview
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

  Widget _buildColorPicker({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Row(
              children: [
                // Color preview
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(
                      color: AppColors.outline,
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Hex value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        ColorConverter.colorToHexWithoutAlpha(color.value),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.color_lens_outlined,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
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
          _isActive ? 'Bandeau actif' : 'Bandeau désactivé',
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
      onPressed: _isSaving ? null : _saveBanner,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
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
