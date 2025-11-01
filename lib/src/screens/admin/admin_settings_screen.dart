// lib/src/screens/admin/admin_settings_screen.dart
import 'package:flutter/material.dart';
import '../../models/app_settings.dart';
import '../../services/settings_service.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _deliveryFeeController;
  late TextEditingController _minimumOrderController;
  late TextEditingController _deliveryTimeController;
  late TextEditingController _deliveryZoneController;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _deliveryFeeController = TextEditingController();
    _minimumOrderController = TextEditingController();
    _deliveryTimeController = TextEditingController();
    _deliveryZoneController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _deliveryFeeController.dispose();
    _minimumOrderController.dispose();
    _deliveryTimeController.dispose();
    _deliveryZoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final settings = await _settingsService.loadSettings();
    _deliveryFeeController.text = settings.deliveryFee.toString();
    _minimumOrderController.text = settings.minimumOrderAmount.toString();
    _deliveryTimeController.text = settings.estimatedDeliveryTime.toString();
    _deliveryZoneController.text = settings.deliveryZone;
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final settings = AppSettings(
      deliveryFee: double.parse(_deliveryFeeController.text),
      minimumOrderAmount: double.parse(_minimumOrderController.text),
      estimatedDeliveryTime: int.parse(_deliveryTimeController.text),
      deliveryZone: _deliveryZoneController.text,
    );

    final success = await _settingsService.saveSettings(settings);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres sauvegardés')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(VisualConstants.paddingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paramètres de livraison', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deliveryFeeController,
                      decoration: const InputDecoration(
                        labelText: 'Frais de livraison (€)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null) {
                          return 'Montant invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _minimumOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Montant minimum de commande (€)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || double.tryParse(value) == null) {
                          return 'Montant invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deliveryTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Temps de livraison estimé (minutes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Valeur invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deliveryZoneController,
                      decoration: const InputDecoration(
                        labelText: 'Zone de livraison',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Zone requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('Sauvegarder les paramètres'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
