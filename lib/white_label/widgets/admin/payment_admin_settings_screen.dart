import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Payment provider type
enum PaymentProvider {
  stripe('Stripe', Icons.credit_card),
  offline('Paiement à la livraison', Icons.local_shipping),
  terminal('Terminal de paiement', Icons.point_of_sale);

  final String label;
  final IconData icon;
  const PaymentProvider(this.label, this.icon);
}

/// Payment Admin Settings Screen
/// 
/// Allows restaurant owners to configure payment settings (Stripe, offline, terminal).
/// Provides a UI for managing payment providers and their configuration.
class PaymentAdminSettingsScreen extends StatefulWidget {
  /// Restaurant ID for storing payment settings
  final String? restaurantId;

  const PaymentAdminSettingsScreen({
    super.key,
    this.restaurantId,
  });

  @override
  State<PaymentAdminSettingsScreen> createState() =>
      _PaymentAdminSettingsScreenState();
}

class _PaymentAdminSettingsScreenState
    extends State<PaymentAdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;

  // Stripe settings
  bool _stripeEnabled = false;
  final _stripePublicKeyController = TextEditingController();
  final _stripeSecretKeyController = TextEditingController();
  bool _stripeTestMode = true;
  List<String> _acceptedPaymentMethods = ['card'];

  // Offline payment settings
  bool _offlineEnabled = false;
  String _offlineInstructions = 'Paiement à la livraison en espèces ou carte bancaire';

  // Terminal settings
  bool _terminalEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _stripePublicKeyController.dispose();
    _stripeSecretKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final restaurantId = widget.restaurantId ?? 'default';
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('settings')
          .doc('payments')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          // Stripe
          _stripeEnabled = data['stripe']?['enabled'] as bool? ?? false;
          _stripePublicKeyController.text =
              data['stripe']?['publicKey'] as String? ?? '';
          _stripeSecretKeyController.text =
              data['stripe']?['secretKey'] as String? ?? '';
          _stripeTestMode = data['stripe']?['testMode'] as bool? ?? true;
          _acceptedPaymentMethods = (data['stripe']?['acceptedMethods'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              ['card'];

          // Offline
          _offlineEnabled = data['offline']?['enabled'] as bool? ?? false;
          _offlineInstructions =
              data['offline']?['instructions'] as String? ??
                  'Paiement à la livraison en espèces ou carte bancaire';

          // Terminal
          _terminalEnabled = data['terminal']?['enabled'] as bool? ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error loading payment settings: $e');
      _showSnackBar('Erreur lors du chargement des paramètres', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final restaurantId = widget.restaurantId ?? 'default';
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('settings')
          .doc('payments')
          .set({
        'stripe': {
          'enabled': _stripeEnabled,
          'publicKey': _stripePublicKeyController.text.trim(),
          'secretKey': _stripeSecretKeyController.text.trim(),
          'testMode': _stripeTestMode,
          'acceptedMethods': _acceptedPaymentMethods,
        },
        'offline': {
          'enabled': _offlineEnabled,
          'instructions': _offlineInstructions,
        },
        'terminal': {
          'enabled': _terminalEnabled,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showSnackBar('Paramètres sauvegardés avec succès');
    } catch (e) {
      debugPrint('Error saving payment settings: $e');
      _showSnackBar('Erreur lors de la sauvegarde', isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Paiements'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveSettings,
              tooltip: 'Sauvegarder',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStripeSection(),
                  const SizedBox(height: 24),
                  _buildOfflineSection(),
                  const SizedBox(height: 24),
                  _buildTerminalSection(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildStripeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PaymentProvider.stripe.icon,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Stripe',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Acceptez les paiements par carte bancaire en ligne',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⚠️ SÉCURITÉ: La clé secrète ne doit JAMAIS être stockée client-side. '
                      'En production, migrez vers Cloud Functions + Secret Manager.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _stripeEnabled,
              onChanged: (value) {
                setState(() {
                  _stripeEnabled = value;
                });
              },
              title: const Text('Activer Stripe'),
              contentPadding: EdgeInsets.zero,
            ),
            if (_stripeEnabled) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _stripePublicKeyController,
                decoration: InputDecoration(
                  labelText: 'Clé publique Stripe *',
                  hintText: 'pk_test_...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: _stripeEnabled
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Clé publique requise';
                        }
                        // Validate Stripe key format
                        if (_stripeTestMode && !value.startsWith('pk_test_')) {
                          return 'Clé test doit commencer par pk_test_';
                        }
                        if (!_stripeTestMode && !value.startsWith('pk_live_')) {
                          return 'Clé live doit commencer par pk_live_';
                        }
                        return null;
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stripeSecretKeyController,
                decoration: InputDecoration(
                  labelText: 'Clé secrète Stripe *',
                  hintText: 'sk_test_...',
                  helperText: 'IMPORTANT: À configurer côté serveur (Cloud Functions)',
                  helperMaxLines: 2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
                validator: _stripeEnabled
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return 'Clé secrète requise';
                        }
                        // Validate Stripe key format
                        if (_stripeTestMode && !value.startsWith('sk_test_')) {
                          return 'Clé test doit commencer par sk_test_';
                        }
                        if (!_stripeTestMode && !value.startsWith('sk_live_')) {
                          return 'Clé live doit commencer par sk_live_';
                        }
                        return null;
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _stripeTestMode,
                onChanged: (value) {
                  setState(() {
                    _stripeTestMode = value;
                  });
                },
                title: const Text('Mode Test'),
                subtitle: const Text('Utiliser les clés de test'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PaymentProvider.offline.icon,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Paiement à la livraison',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Acceptez le paiement en espèces ou carte lors de la livraison',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _offlineEnabled,
              onChanged: (value) {
                setState(() {
                  _offlineEnabled = value;
                });
              },
              title: const Text('Activer paiement offline'),
              contentPadding: EdgeInsets.zero,
            ),
            if (_offlineEnabled) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _offlineInstructions,
                decoration: InputDecoration(
                  labelText: 'Instructions pour le client',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
                onChanged: (value) {
                  _offlineInstructions = value;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PaymentProvider.terminal.icon,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Terminal de paiement',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Utilisez un terminal physique pour les paiements en restaurant',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _terminalEnabled,
              onChanged: (value) {
                setState(() {
                  _terminalEnabled = value;
                });
              },
              title: const Text('Activer terminal'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveSettings,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Enregistrer la configuration',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
