/// lib/superadmin/pages/modules/delivery/delivery_settings_page.dart
///
/// Page SuperAdmin pour configurer le module Livraison d'un restaurant.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../white_label/core/module_id.dart';
import '../../../../white_label/core/module_config.dart';
import '../../../../white_label/modules/core/delivery/delivery_area.dart';
import '../../../../white_label/modules/core/delivery/delivery_settings.dart';
import '../../../../white_label/modules/core/delivery/delivery_module_config.dart';
import '../../../services/restaurant_plan_service.dart';

/// Page de configuration du module Livraison.
class DeliverySettingsPage extends StatefulWidget {
  /// Identifiant du restaurant.
  final String restaurantId;

  /// Nom du restaurant (pour affichage).
  final String? restaurantName;

  const DeliverySettingsPage({
    super.key,
    required this.restaurantId,
    this.restaurantName,
  });

  @override
  State<DeliverySettingsPage> createState() => _DeliverySettingsPageState();
}

class _DeliverySettingsPageState extends State<DeliverySettingsPage> {
  final RestaurantPlanService _planService = RestaurantPlanService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  String? _error;

  late DeliverySettings _settings;
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _minimumOrderController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _freeThresholdController = TextEditingController();
  final _radiusController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  final _maxScheduleController = TextEditingController();
  final _maxConcurrentController = TextEditingController();
  final _deliveryMessageController = TextEditingController();
  final _driverInstructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _minimumOrderController.dispose();
    _deliveryFeeController.dispose();
    _freeThresholdController.dispose();
    _radiusController.dispose();
    _prepTimeController.dispose();
    _deliveryTimeController.dispose();
    _maxScheduleController.dispose();
    _maxConcurrentController.dispose();
    _deliveryMessageController.dispose();
    _driverInstructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final plan = await _planService.loadPlan(widget.restaurantId);
      final moduleConfig = plan.getModuleConfig(ModuleId.delivery);

      if (moduleConfig != null && moduleConfig.settings.isNotEmpty) {
        // Parse settings from the generic ModuleConfig
        _settings = DeliverySettings.fromJson(moduleConfig.settings);
      } else {
        // Use default settings if not configured
        _settings = DeliverySettings.defaults();
      }
      
      _initControllers();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Use default settings on error
      _settings = DeliverySettings.defaults();
      _initControllers();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initControllers() {
    _minimumOrderController.text = _settings.minimumOrderAmount.toString();
    _deliveryFeeController.text = _settings.deliveryFee.toString();
    _freeThresholdController.text =
        _settings.freeDeliveryThreshold?.toString() ?? '';
    _radiusController.text = _settings.radiusKm.toString();
    _prepTimeController.text = _settings.preparationTimeMinutes.toString();
    _deliveryTimeController.text =
        _settings.estimatedDeliveryMinutes.toString();
    _maxScheduleController.text = _settings.maxScheduleAheadHours.toString();
    _maxConcurrentController.text =
        _settings.maxConcurrentDeliveries?.toString() ?? '';
    _deliveryMessageController.text = _settings.deliveryMessage ?? '';
    _driverInstructionsController.text =
        _settings.defaultDriverInstructions ?? '';
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  DeliverySettings _buildSettingsFromForm() {
    return _settings.copyWith(
      minimumOrderAmount:
          double.tryParse(_minimumOrderController.text) ?? 15.0,
      deliveryFee: double.tryParse(_deliveryFeeController.text) ?? 2.50,
      freeDeliveryThreshold: _freeThresholdController.text.isEmpty
          ? null
          : double.tryParse(_freeThresholdController.text),
      radiusKm: double.tryParse(_radiusController.text) ?? 5.0,
      preparationTimeMinutes: int.tryParse(_prepTimeController.text) ?? 15,
      estimatedDeliveryMinutes:
          int.tryParse(_deliveryTimeController.text) ?? 30,
      maxScheduleAheadHours: int.tryParse(_maxScheduleController.text) ?? 48,
      maxConcurrentDeliveries: _maxConcurrentController.text.isEmpty
          ? null
          : int.tryParse(_maxConcurrentController.text),
      deliveryMessage: _deliveryMessageController.text.isEmpty
          ? null
          : _deliveryMessageController.text,
      defaultDriverInstructions: _driverInstructionsController.text.isEmpty
          ? null
          : _driverInstructionsController.text,
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final newSettings = _buildSettingsFromForm();
      
      // Load current plan
      final plan = await _planService.loadPlan(widget.restaurantId);
      
      // Update delivery module config with new settings
      final updatedModules = List.of(plan.modules);
      final deliveryIndex = updatedModules.indexWhere(
        (m) => m.id == ModuleId.delivery,
      );
      
      final newConfig = ModuleConfig(
        id: ModuleId.delivery,
        enabled: deliveryIndex >= 0 ? updatedModules[deliveryIndex].enabled : false,
        settings: newSettings.toJson(),
      );
      
      if (deliveryIndex >= 0) {
        updatedModules[deliveryIndex] = newConfig;
      } else {
        updatedModules.add(newConfig);
      }
      
      // Save updated plan
      final updatedPlan = plan.copyWith(modules: updatedModules);
      await _planService.savePlan(updatedPlan);

      setState(() {
        _settings = newSettings;
        _hasChanges = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration enregistrée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGeneralSection(),
                    const SizedBox(height: 24),
                    _buildPricingSection(),
                    const SizedBox(height: 24),
                    _buildTimingSection(),
                    const SizedBox(height: 24),
                    _buildOptionsSection(),
                    const SizedBox(height: 24),
                    _buildAreasSection(),
                    const SizedBox(height: 24),
                    _buildMessagesSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  if (_hasChanges) {
                    _showDiscardDialog();
                  } else {
                    context
                        .go('/superadmin/restaurants/${widget.restaurantId}/modules');
                  }
                },
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Retour aux modules'),
              ),
              const Spacer(),
              if (_hasChanges) ...[
                TextButton(
                  onPressed: () {
                    _initControllers();
                    setState(() {
                      _hasChanges = false;
                    });
                  },
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveSettings,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save, size: 18),
                  label: Text(_isSaving ? 'Enregistrement...' : 'Enregistrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delivery_dining,
                  size: 32,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration Livraison',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    if (widget.restaurantName != null)
                      Text(
                        widget.restaurantName!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              if (_hasChanges)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pending,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Modifications non enregistrées',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSection() {
    return _buildSectionCard(
      title: 'Paramètres généraux',
      icon: Icons.settings,
      color: Colors.blue,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _radiusController,
                decoration: const InputDecoration(
                  labelText: 'Rayon de livraison (km)',
                  hintText: '5.0',
                  border: OutlineInputBorder(),
                  suffixText: 'km',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                onChanged: (_) => _markChanged(),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (double.tryParse(v) == null) return 'Nombre invalide';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return _buildSectionCard(
      title: 'Tarification',
      icon: Icons.euro,
      color: Colors.green,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minimumOrderController,
                decoration: const InputDecoration(
                  labelText: 'Commande minimum',
                  hintText: '15.00',
                  border: OutlineInputBorder(),
                  suffixText: '€',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                onChanged: (_) => _markChanged(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _deliveryFeeController,
                decoration: const InputDecoration(
                  labelText: 'Frais de livraison',
                  hintText: '2.50',
                  border: OutlineInputBorder(),
                  suffixText: '€',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                onChanged: (_) => _markChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _freeThresholdController,
          decoration: const InputDecoration(
            labelText: 'Livraison gratuite dès',
            hintText: 'Laisser vide si non applicable',
            border: OutlineInputBorder(),
            suffixText: '€',
          ),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          onChanged: (_) => _markChanged(),
        ),
      ],
    );
  }

  Widget _buildTimingSection() {
    return _buildSectionCard(
      title: 'Délais',
      icon: Icons.schedule,
      color: Colors.purple,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _prepTimeController,
                decoration: const InputDecoration(
                  labelText: 'Temps de préparation',
                  hintText: '15',
                  border: OutlineInputBorder(),
                  suffixText: 'min',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _markChanged(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _deliveryTimeController,
                decoration: const InputDecoration(
                  labelText: 'Temps de livraison estimé',
                  hintText: '30',
                  border: OutlineInputBorder(),
                  suffixText: 'min',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _markChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _maxScheduleController,
                decoration: const InputDecoration(
                  labelText: 'Programmation max à l\'avance',
                  hintText: '48',
                  border: OutlineInputBorder(),
                  suffixText: 'heures',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _markChanged(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxConcurrentController,
                decoration: const InputDecoration(
                  labelText: 'Livraisons simultanées max',
                  hintText: 'Illimité si vide',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _markChanged(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return _buildSectionCard(
      title: 'Options',
      icon: Icons.toggle_on,
      color: Colors.teal,
      children: [
        SwitchListTile(
          title: const Text('Autoriser les pourboires'),
          subtitle: const Text('Les clients peuvent ajouter un pourboire'),
          value: _settings.allowTips,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(allowTips: value);
              _hasChanges = true;
            });
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Commandes programmées'),
          subtitle:
              const Text('Les clients peuvent programmer une livraison'),
          value: _settings.allowDelayedOrders,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(allowDelayedOrders: value);
              _hasChanges = true;
            });
          },
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Suivi en temps réel'),
          subtitle:
              const Text('Activer le suivi GPS des livreurs'),
          value: _settings.enableRealTimeTracking,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(enableRealTimeTracking: value);
              _hasChanges = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAreasSection() {
    return _buildSectionCard(
      title: 'Zones de livraison (${_settings.areas.length})',
      icon: Icons.map,
      color: Colors.orange,
      children: [
        if (_settings.areas.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Aucune zone de livraison configurée',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Le rayon par défaut sera utilisé',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        else
          ..._settings.areas.map((area) => _buildAreaTile(area)),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _addNewArea,
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une zone'),
        ),
      ],
    );
  }

  Widget _buildAreaTile(DeliveryArea area) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: area.isActive ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.location_on,
          color: area.isActive ? Colors.green : Colors.grey,
        ),
      ),
      title: Text(area.name),
      subtitle: Text(
        '${area.deliveryFee.toStringAsFixed(2)}€ • Min. ${area.minimumOrderAmount.toStringAsFixed(2)}€ • ~${area.estimatedMinutes}min',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: area.isActive,
            onChanged: (value) {
              _toggleAreaActive(area, value);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editArea(area),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteArea(area),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesSection() {
    return _buildSectionCard(
      title: 'Messages personnalisés',
      icon: Icons.message,
      color: Colors.indigo,
      children: [
        TextFormField(
          controller: _deliveryMessageController,
          decoration: const InputDecoration(
            labelText: 'Message de livraison',
            hintText: 'Message affiché lors de la livraison',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (_) => _markChanged(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _driverInstructionsController,
          decoration: const InputDecoration(
            labelText: 'Instructions pour les livreurs',
            hintText: 'Instructions par défaut pour les livreurs',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (_) => _markChanged(),
        ),
      ],
    );
  }

  void _addNewArea() {
    _showAreaDialog(null);
  }

  void _editArea(DeliveryArea area) {
    _showAreaDialog(area);
  }

  void _toggleAreaActive(DeliveryArea area, bool active) {
    final updatedAreas = _settings.areas.map((a) {
      if (a.id == area.id) {
        return a.copyWith(isActive: active);
      }
      return a;
    }).toList();

    setState(() {
      _settings = _settings.copyWith(areas: updatedAreas);
      _hasChanges = true;
    });
  }

  void _deleteArea(DeliveryArea area) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la zone'),
        content: Text('Voulez-vous supprimer la zone "${area.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _settings = _settings.copyWith(
                  areas: _settings.areas.where((a) => a.id != area.id).toList(),
                );
                _hasChanges = true;
              });
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showAreaDialog(DeliveryArea? area) {
    final isNew = area == null;
    final nameController = TextEditingController(text: area?.name ?? '');
    final feeController =
        TextEditingController(text: area?.deliveryFee.toString() ?? '2.50');
    final minController = TextEditingController(
        text: area?.minimumOrderAmount.toString() ?? '15.0');
    final timeController =
        TextEditingController(text: area?.estimatedMinutes.toString() ?? '30');
    final postalCodesController =
        TextEditingController(text: area?.postalCodes.join(', ') ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNew ? 'Nouvelle zone' : 'Modifier la zone'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la zone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: postalCodesController,
                decoration: const InputDecoration(
                  labelText: 'Codes postaux (séparés par des virgules)',
                  hintText: '75001, 75002, 75003',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: feeController,
                      decoration: const InputDecoration(
                        labelText: 'Frais',
                        suffixText: '€',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: minController,
                      decoration: const InputDecoration(
                        labelText: 'Minimum',
                        suffixText: '€',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Temps estimé',
                  suffixText: 'min',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final postalCodes = postalCodesController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();

              final newArea = DeliveryArea(
                id: area?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                postalCodes: postalCodes,
                deliveryFee: double.tryParse(feeController.text) ?? 2.50,
                minimumOrderAmount: double.tryParse(minController.text) ?? 15.0,
                estimatedMinutes: int.tryParse(timeController.text) ?? 30,
                isActive: area?.isActive ?? true,
              );

              Navigator.pop(context);

              setState(() {
                if (isNew) {
                  _settings = _settings.copyWith(
                    areas: [..._settings.areas, newArea],
                  );
                } else {
                  _settings = _settings.copyWith(
                    areas: _settings.areas.map((a) {
                      return a.id == area.id ? newArea : a;
                    }).toList(),
                  );
                }
                _hasChanges = true;
              });
            },
            child: Text(isNew ? 'Ajouter' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifications non enregistrées'),
        content: const Text(
          'Vous avez des modifications non enregistrées. '
          'Voulez-vous les perdre ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer à éditer'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              context
                  .go('/superadmin/restaurants/${widget.restaurantId}/modules');
            },
            child: const Text('Quitter sans enregistrer'),
          ),
        ],
      ),
    );
  }
}
