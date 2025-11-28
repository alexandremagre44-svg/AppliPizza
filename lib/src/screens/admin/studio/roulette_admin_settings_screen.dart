// lib/src/screens/admin/studio/roulette_admin_settings_screen.dart
// Unified admin screen for roulette settings and rules

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../../../services/roulette_rules_service.dart';
import '../../../services/roulette_settings_service.dart';

/// Unified screen for managing all roulette configuration (settings + rules)
/// 
/// Uses RouletteRulesService to manage:
/// - Global enable/disable
/// - Cooldown between spins (minDelayHours)
/// - Daily/weekly/monthly limits
/// - Allowed time slots (start/end hours)
/// 
/// Firestore storage: config/roulette_rules
class RouletteAdminSettingsScreen extends ConsumerStatefulWidget {
  const RouletteAdminSettingsScreen({super.key});

  @override
  ConsumerState<RouletteAdminSettingsScreen> createState() => _RouletteAdminSettingsScreenState();
}

class _RouletteAdminSettingsScreenState extends ConsumerState<RouletteAdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Use getters to access services via providers
  RouletteRulesService get _service => ref.read(rouletteRulesServiceProvider);
  RouletteSettingsService get _settingsService => ref.read(rouletteSettingsServiceProvider);
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Form fields
  late bool _isEnabled;
  late int _cooldownMinutes;
  late int _dailyLimit;
  late int _weeklyLimit;
  late int _monthlyLimit;
  late int _allowedStartHour;
  late int _allowedEndHour;
  late int _rateLimitSeconds; // NEW: Rate limit in seconds (for Firestore rules)
  
  // Controllers
  late TextEditingController _cooldownController;
  late TextEditingController _dailyLimitController;
  late TextEditingController _weeklyLimitController;
  late TextEditingController _monthlyLimitController;
  late TextEditingController _startHourController;
  late TextEditingController _endHourController;
  late TextEditingController _rateLimitController; // NEW: Rate limit controller

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final rules = await _service.getRules();
      final rateLimitSeconds = await _settingsService.getLimitSeconds();
      
      // If rules don't exist, use defaults
      final effectiveRules = rules ?? const RouletteRules();
      
      setState(() {
        _isEnabled = effectiveRules.isEnabled;
        // Convert hours to minutes for display (cooldownHours * 60)
        _cooldownMinutes = effectiveRules.cooldownHours * 60;
        _dailyLimit = effectiveRules.maxPlaysPerDay;
        _weeklyLimit = effectiveRules.weeklyLimit;
        _monthlyLimit = effectiveRules.monthlyLimit;
        _allowedStartHour = effectiveRules.allowedStartHour;
        _allowedEndHour = effectiveRules.allowedEndHour;
        _rateLimitSeconds = rateLimitSeconds;
        
        _cooldownController = TextEditingController(text: _cooldownMinutes.toString());
        _dailyLimitController = TextEditingController(text: _dailyLimit.toString());
        _weeklyLimitController = TextEditingController(text: _weeklyLimit.toString());
        _monthlyLimitController = TextEditingController(text: _monthlyLimit.toString());
        _startHourController = TextEditingController(text: _allowedStartHour.toString());
        _endHourController = TextEditingController(text: _allowedEndHour.toString());
        _rateLimitController = TextEditingController(text: _rateLimitSeconds.toString());
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      // Convert minutes back to hours for storage
      final cooldownHours = (int.parse(_cooldownController.text) / 60).ceil();
      
      final rules = RouletteRules(
        isEnabled: _isEnabled,
        cooldownHours: cooldownHours,
        maxPlaysPerDay: int.parse(_dailyLimitController.text),
        weeklyLimit: int.parse(_weeklyLimitController.text),
        monthlyLimit: int.parse(_monthlyLimitController.text),
        allowedStartHour: int.parse(_startHourController.text),
        allowedEndHour: int.parse(_endHourController.text),
      );
      
      // Save both rules and rate limit settings
      await _service.saveRules(rules);
      await _settingsService.updateLimitSeconds(int.parse(_rateLimitController.text));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration sauvegardée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _cooldownController.dispose();
    _dailyLimitController.dispose();
    _weeklyLimitController.dispose();
    _monthlyLimitController.dispose();
    _startHourController.dispose();
    _endHourController.dispose();
    _rateLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Paramètres & Règles'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  _buildActivationSection(),
                  SizedBox(height: AppSpacing.md),
                  _buildRateLimitSection(),
                  SizedBox(height: AppSpacing.md),
                  _buildCooldownSection(),
                  SizedBox(height: AppSpacing.md),
                  _buildLimitsSection(),
                  SizedBox(height: AppSpacing.md),
                  _buildTimeRangeSection(),
                  SizedBox(height: AppSpacing.md),
                  _buildSaveButton(),
                  SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
    );
  }

  /// Section 1 - Global activation
  Widget _buildActivationSection() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.power_settings_new, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.sm),
                Text('Activation globale', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Activer ou désactiver la roulette pour tous les utilisateurs',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            SwitchListTile(
              title: Text(
                _isEnabled ? 'Roulette activée' : 'Roulette désactivée',
                style: AppTextStyles.bodyLarge,
              ),
              subtitle: Text(
                _isEnabled 
                    ? 'Les utilisateurs peuvent tourner la roue'
                    : 'La roulette n\'est pas visible côté client',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              value: _isEnabled,
              onChanged: (value) => setState(() => _isEnabled = value),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// Section 2 - Rate Limit (Server-side security)
  Widget _buildRateLimitSection() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.sm),
                Text('Limite de Rate Limit (Sécurité)', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Délai minimum (en secondes) entre deux tours. Appliqué côté serveur (Firestore) pour la sécurité.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _rateLimitController,
              decoration: InputDecoration(
                labelText: 'Rate Limit (secondes)',
                border: OutlineInputBorder(borderRadius: AppRadius.input),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                helperText: 'Recommandé: 10-30 secondes. Maximum: 3600 (1h)',
                suffixText: 'sec',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                final num = int.tryParse(value);
                if (num == null || num < 1 || num > 3600) {
                  return 'Valeur invalide (1-3600)';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
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
                      'Cette limite est appliquée par les règles de sécurité Firestore et ne peut pas être contournée côté client.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 3 - Cooldown
  Widget _buildCooldownSection() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.sm),
                Text('Délai entre utilisations', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Temps minimum à attendre entre deux tours de roue',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _cooldownController,
              decoration: InputDecoration(
                labelText: 'Cooldown (minutes)',
                border: OutlineInputBorder(borderRadius: AppRadius.input),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                helperText: 'Exemple: 1440 pour 24 heures',
                suffixText: 'min',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                final num = int.tryParse(value);
                if (num == null || num < 0) {
                  return 'Valeur invalide (≥0)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Section 4 - Usage limits
  Widget _buildLimitsSection() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.sm),
                Text('Limites d\'utilisation', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Nombre maximum de tours par période (0 = illimité)',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _dailyLimitController,
              decoration: InputDecoration(
                labelText: 'Spins max par jour',
                border: OutlineInputBorder(borderRadius: AppRadius.input),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                helperText: '0 = illimité',
                suffixText: 'spins',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                final num = int.tryParse(value);
                if (num == null || num < 0) {
                  return 'Valeur invalide (≥0)';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _weeklyLimitController,
              decoration: InputDecoration(
                labelText: 'Spins max par semaine',
                border: OutlineInputBorder(borderRadius: AppRadius.input),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                helperText: '0 = illimité',
                suffixText: 'spins',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                final num = int.tryParse(value);
                if (num == null || num < 0) {
                  return 'Valeur invalide (≥0)';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _monthlyLimitController,
              decoration: InputDecoration(
                labelText: 'Spins max par mois',
                border: OutlineInputBorder(borderRadius: AppRadius.input),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                helperText: '0 = illimité',
                suffixText: 'spins',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                final num = int.tryParse(value);
                if (num == null || num < 0) {
                  return 'Valeur invalide (≥0)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Section 5 - Time range
  Widget _buildTimeRangeSection() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.sm),
                Text('Plage horaire autorisée', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Heures pendant lesquelles la roulette est accessible',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startHourController,
                    decoration: InputDecoration(
                      labelText: 'Heure de début',
                      border: OutlineInputBorder(borderRadius: AppRadius.input),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      helperText: 'Format 24h',
                      suffixText: 'h',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0 || num > 23) {
                        return '0-23';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _endHourController,
                    decoration: InputDecoration(
                      labelText: 'Heure de fin',
                      border: OutlineInputBorder(borderRadius: AppRadius.input),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      helperText: 'Format 24h',
                      suffixText: 'h',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final num = int.tryParse(value);
                      if (num == null || num < 0 || num > 23) {
                        return '0-23';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
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
                      'Exemple: 9h-22h → La roulette sera disponible de 9h à 22h',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Save button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                ),
              )
            : Text(
                'Enregistrer la configuration',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
