/// lib/superadmin/pages/restaurant_wizard/wizard_step_brand.dart
///
/// Étape 2 du Wizard: Configuration de la marque.
/// Permet de définir les couleurs, le nom de marque et les logos.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wizard_state.dart';

/// Étape 2: Configuration de la marque.
class WizardStepBrand extends ConsumerStatefulWidget {
  const WizardStepBrand({super.key});

  @override
  ConsumerState<WizardStepBrand> createState() => _WizardStepBrandState();
}

class _WizardStepBrandState extends ConsumerState<WizardStepBrand> {
  late TextEditingController _brandNameController;
  late TextEditingController _logoUrlController;
  late TextEditingController _appIconUrlController;

  @override
  void initState() {
    super.initState();
    final brand = ref.read(restaurantWizardProvider).blueprint.brand;
    _brandNameController = TextEditingController(text: brand.brandName);
    _logoUrlController = TextEditingController(text: brand.logoUrl ?? '');
    _appIconUrlController = TextEditingController(text: brand.appIconUrl ?? '');
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _logoUrlController.dispose();
    _appIconUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(restaurantWizardProvider);
    final brand = wizardState.blueprint.brand;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la section
              const Text(
                'Identité visuelle',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Personnalisez l\'apparence de votre application.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Nom de marque
              _buildTextField(
                label: 'Nom de la marque',
                hint: 'Ex: Pizza Delizza',
                controller: _brandNameController,
                onChanged: (value) {
                  ref
                      .read(restaurantWizardProvider.notifier)
                      .updateBrand(brandName: value);
                },
                isRequired: true,
              ),
              const SizedBox(height: 32),

              // Couleurs
              const Text(
                'Couleurs de la marque *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ColorPicker(
                      label: 'Primaire',
                      color: brand.primaryColor,
                      onColorChanged: (color) {
                        ref
                            .read(restaurantWizardProvider.notifier)
                            .updateBrand(primaryColor: color);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ColorPicker(
                      label: 'Secondaire',
                      color: brand.secondaryColor,
                      onColorChanged: (color) {
                        ref
                            .read(restaurantWizardProvider.notifier)
                            .updateBrand(secondaryColor: color);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ColorPicker(
                      label: 'Accent',
                      color: brand.accentColor,
                      onColorChanged: (color) {
                        ref
                            .read(restaurantWizardProvider.notifier)
                            .updateBrand(accentColor: color);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Prévisualisation des couleurs
              const Text(
                'Aperçu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              _ColorPreview(brand: brand),
              const SizedBox(height: 32),

              // URLs des logos
              const Text(
                'Logos (optionnel)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'URL du logo',
                hint: 'https://example.com/logo.png',
                controller: _logoUrlController,
                onChanged: (value) {
                  ref.read(restaurantWizardProvider.notifier).updateBrand(
                        logoUrl: value.isEmpty ? null : value,
                      );
                },
                helperText: 'Format recommandé: PNG ou SVG, fond transparent',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'URL de l\'icône app',
                hint: 'https://example.com/icon.png',
                controller: _appIconUrlController,
                onChanged: (value) {
                  ref.read(restaurantWizardProvider.notifier).updateBrand(
                        appIconUrl: value.isEmpty ? null : value,
                      );
                },
                helperText: 'Format recommandé: PNG 512x512px',
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

/// Widget de sélection de couleur.
class _ColorPicker extends StatefulWidget {
  final String label;
  final String color;
  final Function(String) onColorChanged;

  const _ColorPicker({
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.color);
  }

  @override
  void didUpdateWidget(_ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color && _controller.text != widget.color) {
      _controller.text = widget.color;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return Colors.grey;
  }

  // Palette de couleurs prédéfinies
  static const List<String> _presetColors = [
    '#E63946', // Rouge
    '#F4A261', // Orange
    '#E9C46A', // Jaune
    '#2A9D8F', // Turquoise
    '#264653', // Bleu foncé
    '#1D3557', // Navy
    '#457B9D', // Bleu
    '#A8DADC', // Bleu clair
    '#F1FAEE', // Blanc cassé
    '#6D6875', // Gris violet
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Couleur actuelle
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _parseColor(widget.color),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: widget.onColorChanged,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Palette
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _presetColors.map((color) {
                  final isSelected =
                      color.toLowerCase() == widget.color.toLowerCase();
                  return GestureDetector(
                    onTap: () {
                      _controller.text = color;
                      widget.onColorChanged(color);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1A1A2E)
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Aperçu des couleurs sélectionnées.
class _ColorPreview extends StatelessWidget {
  final dynamic brand;

  const _ColorPreview({required this.brand});

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final primary = _parseColor(brand.primaryColor);
    final secondary = _parseColor(brand.secondaryColor);
    final accent = _parseColor(brand.accentColor);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.restaurant, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    brand.brandName.isEmpty ? 'Nom de marque' : brand.brandName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Button previews
          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: accent,
                ),
                child: const Text('Bouton principal'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: secondary,
                  side: BorderSide(color: secondary),
                ),
                child: const Text('Bouton secondaire'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
