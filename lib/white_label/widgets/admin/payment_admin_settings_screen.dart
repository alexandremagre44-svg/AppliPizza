import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Payment method type
enum PaymentMethod {
  stripe,
  offline,
  terminal,
}

/// Payment Admin Settings Screen
/// 
/// Allows restaurant owners to configure payment settings.
class PaymentAdminSettingsScreen extends ConsumerStatefulWidget {
  const PaymentAdminSettingsScreen({super.key});

  @override
  ConsumerState<PaymentAdminSettingsScreen> createState() =>
      _PaymentAdminSettingsScreenState();
}

class _PaymentAdminSettingsScreenState
    extends ConsumerState<PaymentAdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Stripe settings
  bool _stripeEnabled = false;
  bool _stripeTestMode = true;
  final _stripePublicKeyController = TextEditingController();
  final _stripeSecretKeyController = TextEditingController();

  // Offline payment
  bool _offlineEnabled = true;

  // Terminal payment
  bool _terminalEnabled = false;
  final _terminalProviderController = TextEditingController();

  // Accepted payment methods
  bool _acceptCard = true;
  bool _acceptApplePay = false;
  bool _acceptGooglePay = false;

  // Currency
  String _currency = 'EUR';

  @override
  void initState() {
    super.initState();
    // TODO: Load settings from Firestore/provider
    _loadSettings();
  }

  void _loadSettings() {
    // TODO: Load from restaurant payment config
    // For now, using defaults
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // TODO: Save to Firestore
    // final restaurantId = ref.read(currentRestaurantProvider)?.id;
    // await ref.read(paymentsServiceProvider).updateSettings(...);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuration enregistrée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _stripePublicKeyController.dispose();
    _stripeSecretKeyController.dispose();
    _terminalProviderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Paiements'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Configurez les moyens de paiement acceptés dans votre restaurant',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Currency selection
            _buildSection(
              title: 'Devise',
              icon: Icons.euro,
              child: DropdownButtonFormField<String>(
                value: _currency,
                decoration: const InputDecoration(
                  labelText: 'Devise par défaut',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                  DropdownMenuItem(value: 'USD', child: Text('USD - Dollar')),
                  DropdownMenuItem(value: 'GBP', child: Text('GBP - Livre Sterling')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _currency = value);
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // Stripe settings
            _buildSection(
              title: 'Paiement en ligne (Stripe)',
              icon: Icons.credit_card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Activer Stripe'),
                    subtitle: const Text('Accepter les paiements CB en ligne'),
                    value: _stripeEnabled,
                    onChanged: (value) {
                      setState(() => _stripeEnabled = value);
                    },
                  ),

                  if (_stripeEnabled) ...[
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Mode Test'),
                      subtitle: const Text('Utiliser les clés de test Stripe'),
                      value: _stripeTestMode,
                      onChanged: (value) {
                        setState(() => _stripeTestMode = value);
                      },
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stripePublicKeyController,
                      decoration: InputDecoration(
                        labelText: 'Clé publique Stripe',
                        hintText: _stripeTestMode
                            ? 'pk_test_...'
                            : 'pk_live_...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.vpn_key),
                      ),
                      validator: (value) {
                        if (_stripeEnabled && (value == null || value.isEmpty)) {
                          return 'Clé publique requise';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stripeSecretKeyController,
                      decoration: InputDecoration(
                        labelText: 'Clé secrète Stripe',
                        hintText: _stripeTestMode
                            ? 'sk_test_...'
                            : 'sk_live_...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (_stripeEnabled && (value == null || value.isEmpty)) {
                          return 'Clé secrète requise';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    const Text(
                      'Méthodes de paiement acceptées:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Carte bancaire'),
                      value: _acceptCard,
                      onChanged: (value) {
                        setState(() => _acceptCard = value ?? true);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Apple Pay'),
                      value: _acceptApplePay,
                      onChanged: (value) {
                        setState(() => _acceptApplePay = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Google Pay'),
                      value: _acceptGooglePay,
                      onChanged: (value) {
                        setState(() => _acceptGooglePay = value ?? false);
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Offline payment
            _buildSection(
              title: 'Paiement à la livraison / retrait',
              icon: Icons.money,
              child: SwitchListTile(
                title: const Text('Activer le paiement en espèces'),
                subtitle: const Text('Paiement sur place ou à la livraison'),
                value: _offlineEnabled,
                onChanged: (value) {
                  setState(() => _offlineEnabled = value);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Terminal payment
            _buildSection(
              title: 'Terminal de Paiement (TPE)',
              icon: Icons.point_of_sale,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Activer le TPE'),
                    subtitle: const Text('Terminal de paiement physique'),
                    value: _terminalEnabled,
                    onChanged: (value) {
                      setState(() => _terminalEnabled = value);
                    },
                  ),

                  if (_terminalEnabled) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _terminalProviderController,
                      decoration: const InputDecoration(
                        labelText: 'Fournisseur TPE',
                        hintText: 'Ex: SumUp, Square, etc.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer la configuration'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Warning card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Important: Ne partagez jamais vos clés secrètes Stripe. '
                        'Elles sont stockées de manière sécurisée dans votre configuration.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
