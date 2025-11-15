// lib/src/screens/admin/roulette/roulette_rules_admin_screen.dart
// Admin screen for configuring roulette rules and restrictions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design_system/app_theme.dart';
import '../../../services/roulette_rules_service.dart';

class RouletteRulesAdminScreen extends StatefulWidget {
  const RouletteRulesAdminScreen({super.key});

  @override
  State<RouletteRulesAdminScreen> createState() => _RouletteRulesAdminScreenState();
}

class _RouletteRulesAdminScreenState extends State<RouletteRulesAdminScreen> {
  final RouletteRulesService _service = RouletteRulesService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Form fields
  late bool _isEnabled;
  late int _minDelayHours;
  late int _dailyLimit;
  late int _weeklyLimit;
  late int _monthlyLimit;
  late int _allowedStartHour;
  late int _allowedEndHour;
  
  // Controllers
  late TextEditingController _minDelayController;
  late TextEditingController _dailyLimitController;
  late TextEditingController _weeklyLimitController;
  late TextEditingController _monthlyLimitController;
  late TextEditingController _startHourController;
  late TextEditingController _endHourController;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    setState(() => _isLoading = true);
    
    try {
      final rules = await _service.getRules();
      
      setState(() {
        _isEnabled = rules.isEnabled;
        _minDelayHours = rules.minDelayHours;
        _dailyLimit = rules.dailyLimit;
        _weeklyLimit = rules.weeklyLimit;
        _monthlyLimit = rules.monthlyLimit;
        _allowedStartHour = rules.allowedStartHour;
        _allowedEndHour = rules.allowedEndHour;
        
        _minDelayController = TextEditingController(text: _minDelayHours.toString());
        _dailyLimitController = TextEditingController(text: _dailyLimit.toString());
        _weeklyLimitController = TextEditingController(text: _weeklyLimit.toString());
        _monthlyLimitController = TextEditingController(text: _monthlyLimit.toString());
        _startHourController = TextEditingController(text: _allowedStartHour.toString());
        _endHourController = TextEditingController(text: _allowedEndHour.toString());
        
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

  Future<void> _saveRules() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final rules = RouletteRules(
        isEnabled: _isEnabled,
        minDelayHours: int.parse(_minDelayController.text),
        dailyLimit: int.parse(_dailyLimitController.text),
        weeklyLimit: int.parse(_weeklyLimitController.text),
        monthlyLimit: int.parse(_monthlyLimitController.text),
        allowedStartHour: int.parse(_startHourController.text),
        allowedEndHour: int.parse(_endHourController.text),
      );
      
      await _service.saveRules(rules);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Règles sauvegardées avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
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
    _minDelayController.dispose();
    _dailyLimitController.dispose();
    _weeklyLimitController.dispose();
    _monthlyLimitController.dispose();
    _startHourController.dispose();
    _endHourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Règles de la Roulette'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveRules,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppSpacing.paddingLG,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Global activation
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card,
                        side: BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: AppSpacing.paddingLG,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Activation générale',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              title: const Text('Roulette activée'),
                              subtitle: const Text(
                                'Active ou désactive la roulette pour tous les utilisateurs',
                              ),
                              value: _isEnabled,
                              onChanged: (value) {
                                setState(() => _isEnabled = value);
                              },
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Cooldown
                    Text(
                      'Délai entre tirages',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card,
                        side: BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: AppSpacing.paddingLG,
                        child: TextFormField(
                          controller: _minDelayController,
                          decoration: const InputDecoration(
                            labelText: 'Heures minimum entre deux tirages',
                            helperText: 'Exemple: 24 pour 1 fois par jour',
                            suffixText: 'heures',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requis';
                            }
                            final val = int.tryParse(value);
                            if (val == null || val < 0) {
                              return 'Valeur invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Limits
                    Text(
                      'Limites d\'utilisation',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card,
                        side: BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: AppSpacing.paddingLG,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _dailyLimitController,
                              decoration: const InputDecoration(
                                labelText: 'Limite journalière',
                                helperText: '0 = illimité',
                                suffixText: 'tirages/jour',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                final val = int.tryParse(value);
                                if (val == null || val < 0) {
                                  return 'Valeur invalide';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _weeklyLimitController,
                              decoration: const InputDecoration(
                                labelText: 'Limite hebdomadaire',
                                helperText: '0 = illimité',
                                suffixText: 'tirages/semaine',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                final val = int.tryParse(value);
                                if (val == null || val < 0) {
                                  return 'Valeur invalide';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _monthlyLimitController,
                              decoration: const InputDecoration(
                                labelText: 'Limite mensuelle',
                                helperText: '0 = illimité',
                                suffixText: 'tirages/mois',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                final val = int.tryParse(value);
                                if (val == null || val < 0) {
                                  return 'Valeur invalide';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Time slots
                    Text(
                      'Plages horaires',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card,
                        side: BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: AppSpacing.paddingLG,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _startHourController,
                              decoration: const InputDecoration(
                                labelText: 'Heure de début',
                                helperText: 'Format 24h (0-23)',
                                suffixText: 'h',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                final val = int.tryParse(value);
                                if (val == null || val < 0 || val > 23) {
                                  return 'Valeur entre 0 et 23';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _endHourController,
                              decoration: const InputDecoration(
                                labelText: 'Heure de fin',
                                helperText: 'Format 24h (0-23)',
                                suffixText: 'h',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                final val = int.tryParse(value);
                                if (val == null || val < 0 || val > 23) {
                                  return 'Valeur entre 0 et 23';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: AppSpacing.paddingMD,
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: AppRadius.card,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.info,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'La roulette sera disponible entre ces heures. Ex: 11h-22h',
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
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveRules,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.button,
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Enregistrer les règles',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
