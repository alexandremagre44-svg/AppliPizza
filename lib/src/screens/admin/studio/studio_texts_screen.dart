// lib/src/screens/admin/studio/studio_texts_screen.dart
// TextBlockEditor - Gestion des textes et messages de l'application
// Material 3 + Design System Pizza Deli'Zza

import 'package:flutter/material.dart';
import '../../../models/app_texts_config.dart';
import '../../../services/app_texts_service.dart';
import '../../../design_system/app_theme.dart';

/// TextBlockEditor - Écran de gestion des textes et messages
/// 
/// Permet d'éditer tous les textes de l'application:
/// - Textes de la page d'accueil
/// - Messages de commande
/// - Messages d'erreur de paiement
/// - Messages de bienvenue et généraux
class StudioTextsScreen extends StatefulWidget {
  const StudioTextsScreen({super.key});

  @override
  State<StudioTextsScreen> createState() => _StudioTextsScreenState();
}

class _StudioTextsScreenState extends State<StudioTextsScreen> {
  final AppTextsService _service = AppTextsService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers pour chaque champ
  late TextEditingController _appNameController;
  late TextEditingController _sloganController;
  late TextEditingController _homeIntroController;
  late TextEditingController _successMessageController;
  late TextEditingController _failureMessageController;
  late TextEditingController _noSlotsMessageController;
  late TextEditingController _networkErrorController;
  late TextEditingController _serverErrorController;
  late TextEditingController _sessionExpiredController;
  
  AppTextsConfig? _config;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadConfig();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    _appNameController = TextEditingController();
    _sloganController = TextEditingController();
    _homeIntroController = TextEditingController();
    _successMessageController = TextEditingController();
    _failureMessageController = TextEditingController();
    _noSlotsMessageController = TextEditingController();
    _networkErrorController = TextEditingController();
    _serverErrorController = TextEditingController();
    _sessionExpiredController = TextEditingController();
  }

  void _disposeControllers() {
    _appNameController.dispose();
    _sloganController.dispose();
    _homeIntroController.dispose();
    _successMessageController.dispose();
    _failureMessageController.dispose();
    _noSlotsMessageController.dispose();
    _networkErrorController.dispose();
    _serverErrorController.dispose();
    _sessionExpiredController.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    try {
      final config = await _service.getAppTextsConfig();
      
      setState(() {
        _config = config;
        _populateControllers(config);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors du chargement: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateControllers(AppTextsConfig config) {
    _appNameController.text = config.general.appName;
    _sloganController.text = config.general.slogan;
    _homeIntroController.text = config.general.homeIntro;
    _successMessageController.text = config.orderMessages.successMessage;
    _failureMessageController.text = config.orderMessages.failureMessage;
    _noSlotsMessageController.text = config.orderMessages.noSlotsMessage;
    _networkErrorController.text = config.errorMessages.networkError;
    _serverErrorController.text = config.errorMessages.serverError;
    _sessionExpiredController.text = config.errorMessages.sessionExpired;
  }

  Future<void> _saveAllChanges() async {
    if (_formKey.currentState?.validate() != true) {
      _showSnackBar('Veuillez corriger les erreurs', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedConfig = _config!.copyWith(
        general: _config!.general.copyWith(
          appName: _appNameController.text.trim(),
          slogan: _sloganController.text.trim(),
          homeIntro: _homeIntroController.text.trim(),
        ),
        orderMessages: _config!.orderMessages.copyWith(
          successMessage: _successMessageController.text.trim(),
          failureMessage: _failureMessageController.text.trim(),
          noSlotsMessage: _noSlotsMessageController.text.trim(),
        ),
        errorMessages: _config!.errorMessages.copyWith(
          networkError: _networkErrorController.text.trim(),
          serverError: _serverErrorController.text.trim(),
          sessionExpired: _sessionExpiredController.text.trim(),
        ),
        updatedAt: DateTime.now(),
      );

      final success = await _service.saveAppTextsConfig(updatedConfig);

      if (success) {
        _showSnackBar('✓ Tous les textes ont été enregistrés');
        await _loadConfig();
      } else {
        _showSnackBar('Erreur lors de l\'enregistrement', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Textes & Messages',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    AppSpacing.verticalSpaceMD,
                    
                    // Section Accueil
                    _buildCategoryCard(
                      title: 'Accueil',
                      icon: Icons.home_outlined,
                      children: [
                        _buildTextField(
                          controller: _appNameController,
                          label: 'Nom de l\'application',
                          hint: 'Ex: Pizza Deli\'Zza',
                        ),
                        AppSpacing.verticalSpaceMD,
                        _buildTextField(
                          controller: _sloganController,
                          label: 'Slogan / Sous-titre',
                          hint: 'Ex: La meilleure pizza à emporter',
                        ),
                        AppSpacing.verticalSpaceMD,
                        _buildTextField(
                          controller: _homeIntroController,
                          label: 'Message d\'introduction',
                          hint: 'Ex: Découvrez nos pizzas artisanales',
                          maxLines: 2,
                        ),
                      ],
                    ),
                    
                    AppSpacing.verticalSpaceMD,
                    
                    // Section Commandes
                    _buildCategoryCard(
                      title: 'Commandes',
                      icon: Icons.shopping_cart_outlined,
                      children: [
                        _buildTextField(
                          controller: _successMessageController,
                          label: 'Message de commande validée',
                          hint: 'Ex: Votre commande a été validée',
                          maxLines: 2,
                        ),
                        AppSpacing.verticalSpaceMD,
                        _buildTextField(
                          controller: _failureMessageController,
                          label: 'Message de commande annulée',
                          hint: 'Ex: Votre commande a été annulée',
                          maxLines: 2,
                        ),
                        AppSpacing.verticalSpaceMD,
                        _buildTextField(
                          controller: _noSlotsMessageController,
                          label: 'Message aucun créneau disponible',
                          hint: 'Ex: Aucun créneau disponible',
                          maxLines: 2,
                        ),
                      ],
                    ),
                    
                    AppSpacing.verticalSpaceMD,
                    
                    // Section Paiements
                    _buildCategoryCard(
                      title: 'Paiements',
                      icon: Icons.payment_outlined,
                      children: [
                        _buildTextField(
                          controller: _networkErrorController,
                          label: 'Erreur de connexion',
                          hint: 'Ex: Erreur de connexion. Vérifiez votre réseau',
                          maxLines: 2,
                        ),
                        AppSpacing.verticalSpaceMD,
                        _buildTextField(
                          controller: _serverErrorController,
                          label: 'Erreur de paiement / serveur',
                          hint: 'Ex: Erreur serveur. Réessayez plus tard',
                          maxLines: 2,
                        ),
                      ],
                    ),
                    
                    AppSpacing.verticalSpaceMD,
                    
                    // Section Général
                    _buildCategoryCard(
                      title: 'Général',
                      icon: Icons.info_outline,
                      children: [
                        _buildTextField(
                          controller: _sessionExpiredController,
                          label: 'Message de bienvenue / Session',
                          hint: 'Ex: Votre session a expiré',
                          maxLines: 2,
                        ),
                      ],
                    ),
                    
                    AppSpacing.verticalSpaceMD,
                    
                    // Bouton Enregistrer
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _saveAllChanges,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.button,
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                'Sauvegarder tous les textes',
                                style: AppTextStyles.labelLarge,
                              ),
                      ),
                    ),
                    
                    AppSpacing.verticalSpaceXL,
                  ],
                ),
              ),
            ),
    );
  }

  /// Construit une carte de catégorie avec titre et icône
  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                AppSpacing.horizontalSpaceSM,
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceMD,
            ...children,
          ],
        ),
      ),
    );
  }

  /// Construit un champ de texte avec validation
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelMedium,
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ce champ ne peut pas être vide';
        }
        return null;
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.button,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
