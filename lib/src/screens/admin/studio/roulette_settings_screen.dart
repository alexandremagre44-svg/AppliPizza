// lib/src/screens/admin/studio/roulette_settings_screen.dart
// Écran de configuration des paramètres de la roulette

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/roulette_settings.dart';

/// Écran de configuration des règles d'activation de la roulette
/// 
/// Permet de configurer:
/// - Activation globale
/// - Limites d'utilisation (jour/semaine/mois/total)
/// - Cooldown entre utilisations
/// - Dates de validité
/// - Jours actifs de la semaine
/// - Horaires actifs
/// - Conditions d'éligibilité utilisateur
class RouletteSettingsScreen extends StatefulWidget {
  const RouletteSettingsScreen({super.key});

  @override
  State<RouletteSettingsScreen> createState() => _RouletteSettingsScreenState();
}

class _RouletteSettingsScreenState extends State<RouletteSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _limitValueController = TextEditingController();
  final _cooldownController = TextEditingController();
  final _startHourController = TextEditingController();
  final _endHourController = TextEditingController();
  final _minOrdersController = TextEditingController();
  final _minSpentController = TextEditingController();
  
  // State
  bool _isEnabled = false;
  String _limitType = 'none';
  int _limitValue = 0;
  int _cooldownHours = 0;
  DateTime? _validFrom;
  DateTime? _validTo;
  List<int> _activeDays = [1, 2, 3, 4, 5, 6, 7];
  int _activeStartHour = 0;
  int _activeEndHour = 23;
  String _eligibilityType = 'all';
  int? _minOrders;
  double? _minSpent;
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _limitValueController.dispose();
    _cooldownController.dispose();
    _startHourController.dispose();
    _endHourController.dispose();
    _minOrdersController.dispose();
    _minSpentController.dispose();
    super.dispose();
  }

  /// Charge les paramètres depuis Firestore
  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('marketing')
          .doc('roulette_settings')
          .get();

      if (doc.exists && doc.data() != null) {
        final settings = RouletteSettings.fromMap(doc.data()!);
        setState(() {
          _isEnabled = settings.isEnabled;
          _limitType = settings.limitType;
          _limitValue = settings.limitValue;
          _cooldownHours = settings.cooldownHours;
          _validFrom = settings.validFrom?.toDate();
          _validTo = settings.validTo?.toDate();
          _activeDays = List.from(settings.activeDays);
          _activeStartHour = settings.activeStartHour;
          _activeEndHour = settings.activeEndHour;
          _eligibilityType = settings.eligibilityType;
          _minOrders = settings.minOrders;
          _minSpent = settings.minSpent;
          
          // Update controllers
          _limitValueController.text = _limitValue.toString();
          _cooldownController.text = _cooldownHours.toString();
          _startHourController.text = _activeStartHour.toString();
          _endHourController.text = _activeEndHour.toString();
          _minOrdersController.text = _minOrders?.toString() ?? '';
          _minSpentController.text = _minSpent?.toString() ?? '';
        });
      } else {
        // Utiliser les valeurs par défaut
        final defaultSettings = RouletteSettings.defaultSettings();
        setState(() {
          _isEnabled = defaultSettings.isEnabled;
          _limitType = defaultSettings.limitType;
          _limitValue = defaultSettings.limitValue;
          _cooldownHours = defaultSettings.cooldownHours;
          _activeDays = List.from(defaultSettings.activeDays);
          _activeStartHour = defaultSettings.activeStartHour;
          _activeEndHour = defaultSettings.activeEndHour;
          _eligibilityType = defaultSettings.eligibilityType;
          
          _limitValueController.text = _limitValue.toString();
          _cooldownController.text = _cooldownHours.toString();
          _startHourController.text = _activeStartHour.toString();
          _endHourController.text = _activeEndHour.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Sauvegarde les paramètres dans Firestore
  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Parse les valeurs des champs
      _limitValue = int.tryParse(_limitValueController.text) ?? 0;
      _cooldownHours = int.tryParse(_cooldownController.text) ?? 0;
      _activeStartHour = int.tryParse(_startHourController.text) ?? 0;
      _activeEndHour = int.tryParse(_endHourController.text) ?? 23;
      
      if (_eligibilityType == 'min_orders') {
        _minOrders = int.tryParse(_minOrdersController.text);
      } else {
        _minOrders = null;
      }
      
      if (_eligibilityType == 'min_spent') {
        _minSpent = double.tryParse(_minSpentController.text);
      } else {
        _minSpent = null;
      }

      final settings = RouletteSettings(
        isEnabled: _isEnabled,
        limitType: _limitType,
        limitValue: _limitValue,
        cooldownHours: _cooldownHours,
        validFrom: _validFrom != null ? Timestamp.fromDate(_validFrom!) : null,
        validTo: _validTo != null ? Timestamp.fromDate(_validTo!) : null,
        activeDays: _activeDays,
        activeStartHour: _activeStartHour,
        activeEndHour: _activeEndHour,
        eligibilityType: _eligibilityType,
        minOrders: _minOrders,
        minSpent: _minSpent,
      );

      await FirebaseFirestore.instance
          .collection('marketing')
          .doc('roulette_settings')
          .set(settings.toMap(), SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres enregistrés avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Paramètres de la roulette'),
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
                  _buildLimitsSection(),
                  SizedBox(height: AppSpacing.md),
                  _buildCooldownSection(),
                  SizedBox(height: AppSpacing.md),
                  _buildValiditySection(),
                  SizedBox(height: AppSpacing.md),
                  _buildActiveDaysSection(),
                  SizedBox(height: AppSpacing.md),
                  _buildActiveHoursSection(),
                  SizedBox(height: AppSpacing.md),
                  _buildEligibilitySection(),
                  SizedBox(height: AppSpacing.md),
                  _buildSaveButton(),
                  SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
    );
  }

  /// Section 1 - Activation globale
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
                Text('Activation', style: AppTextStyles.titleMedium),
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

  /// Section 2 - Limites d'utilisation
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
            SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _limitType,
              decoration: InputDecoration(
                labelText: 'Type de limite',
                border: OutlineInputBorder(borderRadius: AppRadius.input),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Aucune limite')),
                DropdownMenuItem(value: 'per_day', child: Text('Par jour')),
                DropdownMenuItem(value: 'per_week', child: Text('Par semaine')),
                DropdownMenuItem(value: 'per_month', child: Text('Par mois')),
                DropdownMenuItem(value: 'total', child: Text('Total')),
              ],
              onChanged: (value) => setState(() => _limitType = value ?? 'none'),
            ),
            if (_limitType != 'none') ...[
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _limitValueController,
                decoration: InputDecoration(
                  labelText: 'Nombre maximum d\'utilisations',
                  border: OutlineInputBorder(borderRadius: AppRadius.input),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (_limitType != 'none' && (value == null || value.isEmpty)) {
                    return 'Veuillez entrer une valeur';
                  }
                  final num = int.tryParse(value ?? '');
                  if (_limitType != 'none' && (num == null || num <= 0)) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
            ],
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
                Text('Cooldown', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Délai minimum entre deux utilisations par un même utilisateur',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _cooldownController,
              decoration: InputDecoration(
                labelText: 'Cooldown (heures)',
                border: OutlineInputBorder(borderRadius: AppRadius.input),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                helperText: '0 = pas de cooldown',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une valeur';
                }
                final num = int.tryParse(value);
                if (num == null || num < 0) {
                  return 'Veuillez entrer un nombre valide (≥0)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Section 4 - Validité (dates)
  Widget _buildValiditySection() {
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
                Icon(Icons.calendar_today, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.sm),
                Text('Période de validité', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de début'),
              subtitle: Text(
                _validFrom != null
                    ? '${_validFrom!.day}/${_validFrom!.month}/${_validFrom!.year}'
                    : 'Non définie',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_validFrom != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _validFrom = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _validFrom ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => _validFrom = date);
                      }
                    },
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.outlineVariant),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date de fin'),
              subtitle: Text(
                _validTo != null
                    ? '${_validTo!.day}/${_validTo!.month}/${_validTo!.year}'
                    : 'Non définie',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_validTo != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _validTo = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _validTo ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => _validTo = date);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 5 - Jours actifs
  Widget _buildActiveDaysSection() {
    const dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    const dayNames = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

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
                Icon(Icons.date_range, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.sm),
                Text('Jours actifs', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Sélectionnez les jours où la roulette est disponible',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final dayNumber = index + 1;
                final isActive = _activeDays.contains(dayNumber);
                
                return Tooltip(
                  message: dayNames[index],
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isActive) {
                          _activeDays.remove(dayNumber);
                        } else {
                          _activeDays.add(dayNumber);
                        }
                        _activeDays.sort();
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.surfaceContainerLow,
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.outline,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          dayLabels[index],
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isActive
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Section 6 - Horaires actifs
  Widget _buildActiveHoursSection() {
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
                Text('Horaires actifs', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Définissez la plage horaire d\'activation (format 24h)',
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
          ],
        ),
      ),
    );
  }

  /// Section 7 - Éligibilité utilisateur
  Widget _buildEligibilitySection() {
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
                Icon(Icons.people, color: AppColors.primary, size: 24),
                SizedBox(width: AppSpacing.sm),
                Text('Éligibilité utilisateur', style: AppTextStyles.titleMedium),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _eligibilityType,
              decoration: InputDecoration(
                labelText: 'Type d\'éligibilité',
                border: OutlineInputBorder(borderRadius: AppRadius.input),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tous les utilisateurs')),
                DropdownMenuItem(value: 'new_users', child: Text('Nouveaux utilisateurs')),
                DropdownMenuItem(value: 'loyal_users', child: Text('Utilisateurs fidèles')),
                DropdownMenuItem(value: 'min_orders', child: Text('Minimum de commandes')),
                DropdownMenuItem(value: 'min_spent', child: Text('Montant minimum dépensé')),
              ],
              onChanged: (value) => setState(() {
                _eligibilityType = value ?? 'all';
                if (_eligibilityType != 'min_orders') {
                  _minOrdersController.clear();
                }
                if (_eligibilityType != 'min_spent') {
                  _minSpentController.clear();
                }
              }),
            ),
            if (_eligibilityType == 'min_orders') ...[
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _minOrdersController,
                decoration: InputDecoration(
                  labelText: 'Nombre minimum de commandes',
                  border: OutlineInputBorder(borderRadius: AppRadius.input),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (_eligibilityType == 'min_orders' &&
                      (value == null || value.isEmpty)) {
                    return 'Veuillez entrer une valeur';
                  }
                  final num = int.tryParse(value ?? '');
                  if (_eligibilityType == 'min_orders' &&
                      (num == null || num <= 0)) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
            ],
            if (_eligibilityType == 'min_spent') ...[
              SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _minSpentController,
                decoration: InputDecoration(
                  labelText: 'Montant minimum dépensé (€)',
                  border: OutlineInputBorder(borderRadius: AppRadius.input),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (_eligibilityType == 'min_spent' &&
                      (value == null || value.isEmpty)) {
                    return 'Veuillez entrer une valeur';
                  }
                  final num = double.tryParse(value ?? '');
                  if (_eligibilityType == 'min_spent' &&
                      (num == null || num <= 0)) {
                    return 'Veuillez entrer un montant valide';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Section 8 - Bouton d'enregistrement
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
                'Enregistrer',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
