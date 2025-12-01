/// lib/superadmin/pages/restaurant_wizard/wizard_step_identity.dart
///
/// Étape 1 du Wizard: Identité du restaurant.
/// Permet de définir le nom et le slug du restaurant.
/// Note: Le type de restaurant est déterminé par le template choisi (étape 3).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wizard_state.dart';

/// Étape 1: Configuration de l'identité du restaurant.
class WizardStepIdentity extends ConsumerStatefulWidget {
  const WizardStepIdentity({super.key});

  @override
  ConsumerState<WizardStepIdentity> createState() => _WizardStepIdentityState();
}

class _WizardStepIdentityState extends ConsumerState<WizardStepIdentity> {
  late TextEditingController _nameController;
  late TextEditingController _slugController;
  bool _autoGenerateSlug = true;

  @override
  void initState() {
    super.initState();
    final blueprint = ref.read(restaurantWizardProvider).blueprint;
    _nameController = TextEditingController(text: blueprint.name);
    _slugController = TextEditingController(text: blueprint.slug);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[àâä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[ïî]'), 'i')
        .replaceAll(RegExp(r'[ôö]'), 'o')
        .replaceAll(RegExp(r'[ùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  void _onNameChanged(String value) {
    ref.read(restaurantWizardProvider.notifier).updateIdentity(name: value);
    if (_autoGenerateSlug) {
      final slug = _generateSlug(value);
      _slugController.text = slug;
      ref.read(restaurantWizardProvider.notifier).updateIdentity(slug: slug);
    }
  }

  void _onSlugChanged(String value) {
    _autoGenerateSlug = false;
    ref.read(restaurantWizardProvider.notifier).updateIdentity(slug: value);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la section
              const Text(
                'Informations de base',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ces informations définissent l\'identité de votre restaurant.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Nom du restaurant
              _buildTextField(
                label: 'Nom du restaurant',
                hint: 'Ex: Pizza Delizza Paris',
                controller: _nameController,
                onChanged: _onNameChanged,
                isRequired: true,
              ),
              const SizedBox(height: 24),

              // Slug
              _buildTextField(
                label: 'Slug (URL)',
                hint: 'Ex: pizza-delizza-paris',
                controller: _slugController,
                onChanged: _onSlugChanged,
                isRequired: true,
                helperText:
                    'Utilisé pour l\'URL: https://${_slugController.text.isEmpty ? 'mon-restaurant' : _slugController.text}.delizza.app',
              ),
              const SizedBox(height: 32),

              // Résumé
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vous pourrez modifier ces informations plus tard dans les paramètres du restaurant.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade800,
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
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String) onChanged,
    bool isRequired = false,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 2,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
