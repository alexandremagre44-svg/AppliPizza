// lib/src/screens/admin/studio/studio_texts_screen.dart
// Screen for managing configurable app texts

import 'package:flutter/material.dart';
import '../../../models/app_texts_config.dart';
import 'package:pizza_delizza/src/features/home/data/repositories/app_texts_repository.dart';
import 'package:pizza_delizza/src/features/shared/theme/app_theme.dart';

class StudioTextsScreen extends StatefulWidget {
  const StudioTextsScreen({super.key});

  @override
  State<StudioTextsScreen> createState() => _StudioTextsScreenState();
}

class _StudioTextsScreenState extends State<StudioTextsScreen> {
  final AppTextsRepository _service = AppTextsRepository();
  
  AppTextsConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    final config = await _service.getAppTextsConfig();
    
    setState(() {
      _config = config;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Textes & Messages'),
        backgroundColor: AppColors.primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppSpacing.paddingLG,
              children: [
                _buildSection(
                  'Général',
                  Icons.settings,
                  [
                    _buildTextField(
                      'Nom de l\'application',
                      _config!.general.appName,
                      (value) async {
                        final updated = _config!.general.copyWith(appName: value);
                        await _service.updateGeneralTexts(updated);
                        _loadConfig();
                      },
                    ),
                    _buildTextField(
                      'Slogan',
                      _config!.general.slogan,
                      (value) async {
                        final updated = _config!.general.copyWith(slogan: value);
                        await _service.updateGeneralTexts(updated);
                        _loadConfig();
                      },
                    ),
                    _buildTextField(
                      'Intro page d\'accueil',
                      _config!.general.homeIntro,
                      (value) async {
                        final updated = _config!.general.copyWith(homeIntro: value);
                        await _service.updateGeneralTexts(updated);
                        _loadConfig();
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.xxl),
                
                _buildSection(
                  'Messages Commande',
                  Icons.shopping_bag,
                  [
                    _buildTextField(
                      'Message de succès',
                      _config!.orderMessages.successMessage,
                      (value) async {
                        final updated =
                            _config!.orderMessages.copyWith(successMessage: value);
                        await _service.updateOrderMessages(updated);
                        _loadConfig();
                      },
                    ),
                    _buildTextField(
                      'Message d\'échec',
                      _config!.orderMessages.failureMessage,
                      (value) async {
                        final updated =
                            _config!.orderMessages.copyWith(failureMessage: value);
                        await _service.updateOrderMessages(updated);
                        _loadConfig();
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.xxl),
                
                _buildSection(
                  'Messages d\'erreur',
                  Icons.error_outline,
                  [
                    _buildTextField(
                      'Erreur réseau',
                      _config!.errorMessages.networkError,
                      (value) async {
                        final updated =
                            _config!.errorMessages.copyWith(networkError: value);
                        await _service.updateErrorMessages(updated);
                        _loadConfig();
                      },
                    ),
                    _buildTextField(
                      'Erreur serveur',
                      _config!.errorMessages.serverError,
                      (value) async {
                        final updated =
                            _config!.errorMessages.copyWith(serverError: value);
                        await _service.updateErrorMessages(updated);
                        _loadConfig();
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: AppSpacing.xxl),
                
                _buildSection(
                  'Fidélité',
                  Icons.loyalty,
                  [
                    _buildTextField(
                      'Message de récompense',
                      _config!.loyaltyTexts.rewardMessage,
                      (value) async {
                        final updated =
                            _config!.loyaltyTexts.copyWith(rewardMessage: value);
                        await _service.updateLoyaltyTexts(updated);
                        _loadConfig();
                      },
                    ),
                    _buildTextField(
                      'Explication du programme',
                      _config!.loyaltyTexts.programExplanation,
                      (value) async {
                        final updated = _config!.loyaltyTexts
                            .copyWith(programExplanation: value);
                        await _service.updateLoyaltyTexts(updated);
                        _loadConfig();
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryRed),
                SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.primaryRed,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    Future<void> Function(String) onSaved,
  ) {
    final controller = TextEditingController(text: value);
    bool hasChanges = false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelLarge),
              SizedBox(height: AppSpacing.xs),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: AppRadius.input),
                  contentPadding: AppSpacing.paddingMD,
                  suffixIcon: hasChanges
                      ? IconButton(
                          icon: Icon(Icons.check_circle, color: AppColors.successGreen),
                          onPressed: () async {
                            if (controller.text.trim().isEmpty) {
                              _showSnackBar('Le texte ne peut pas être vide', isError: true);
                              return;
                            }
                            await onSaved(controller.text);
                            setState(() => hasChanges = false);
                            _showSnackBar('Enregistré');
                          },
                        )
                      : null,
                ),
                onChanged: (newValue) {
                  if (newValue != value) {
                    setState(() => hasChanges = true);
                  } else {
                    setState(() => hasChanges = false);
                  }
                },
                onSubmitted: (newValue) async {
                  if (newValue.trim().isEmpty) {
                    _showSnackBar('Le texte ne peut pas être vide', isError: true);
                    return;
                  }
                  await onSaved(newValue);
                  setState(() => hasChanges = false);
                  _showSnackBar('Enregistré');
                },
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                hasChanges
                    ? 'Cliquez sur ✓ ou appuyez sur Entrée pour sauvegarder'
                    : 'Appuyez sur Entrée pour sauvegarder',
                style: AppTextStyles.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: hasChanges ? AppColors.primaryRed : AppColors.textMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
