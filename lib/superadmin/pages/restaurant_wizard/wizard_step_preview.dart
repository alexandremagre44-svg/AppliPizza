/// lib/superadmin/pages/restaurant_wizard/wizard_step_preview.dart
///
/// Étape 5 du Wizard: Aperçu et validation.
/// Affiche un résumé de toutes les configurations avant création.
/// Inclut une validation des dépendances des modules.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../white_label/core/module_id.dart';
import '../../models/restaurant_blueprint.dart';
import 'wizard_state.dart';
import 'wizard_step_template.dart';

/// Étape 5: Aperçu final avant création.
class WizardStepPreview extends ConsumerWidget {
  const WizardStepPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(restaurantWizardProvider);
    final blueprint = wizardState.blueprint;
    final enabledModules = wizardState.enabledModuleIds;

    // Valider les dépendances
    final isModulesValid = validateModuleDependencies(enabledModules);
    final missingDeps = getMissingDependencies(enabledModules);

    // Récupérer le template sélectionné
    final selectedTemplate = getTemplateById(blueprint.templateId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la section
              const Text(
                'Aperçu de votre restaurant',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vérifiez les informations avant de créer votre restaurant.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Validation status (avec vérification des dépendances)
              _ValidationStatus(
                blueprint: blueprint,
                enabledModules: enabledModules,
                isModulesValid: isModulesValid,
                missingDeps: missingDeps,
              ),
              const SizedBox(height: 24),

              // Sections de prévisualisation
              _PreviewSection(
                title: 'Identité',
                icon: Icons.store,
                stepIndex: WizardStep.identity.index,
                onEdit: () {
                  ref
                      .read(restaurantWizardProvider.notifier)
                      .goToStep(WizardStep.identity);
                },
                children: [
                  _PreviewRow(label: 'Nom', value: blueprint.name),
                  _PreviewRow(label: 'Slug', value: blueprint.slug),
                ],
              ),
              const SizedBox(height: 16),

              _PreviewSection(
                title: 'Marque',
                icon: Icons.palette,
                stepIndex: WizardStep.brand.index,
                onEdit: () {
                  ref
                      .read(restaurantWizardProvider.notifier)
                      .goToStep(WizardStep.brand);
                },
                children: [
                  _PreviewRow(
                    label: 'Nom de marque',
                    value: blueprint.brand.brandName,
                  ),
                  _PreviewColorRow(
                    label: 'Couleurs',
                    colors: [
                      blueprint.brand.primaryColor,
                      blueprint.brand.secondaryColor,
                      blueprint.brand.accentColor,
                    ],
                  ),
                  _PreviewRow(
                    label: 'Logo',
                    value: blueprint.brand.logoUrl ?? 'Non défini',
                    isOptional: blueprint.brand.logoUrl == null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _PreviewSection(
                title: 'Template',
                icon: Icons.dashboard,
                stepIndex: WizardStep.template.index,
                onEdit: () {
                  ref
                      .read(restaurantWizardProvider.notifier)
                      .goToStep(WizardStep.template);
                },
                children: [
                  _PreviewRow(
                    label: 'Template',
                    value: selectedTemplate?.name ?? 'Aucun template sélectionné',
                    isOptional: selectedTemplate == null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _PreviewSection(
                title: 'Modules',
                icon: Icons.extension,
                stepIndex: WizardStep.modules.index,
                onEdit: () {
                  ref
                      .read(restaurantWizardProvider.notifier)
                      .goToStep(WizardStep.modules);
                },
                children: [
                  _PreviewModulesRowNew(enabledModules: enabledModules),
                ],
              ),
              const SizedBox(height: 32),

              // Aperçu visuel de l'app
              _AppPreview(blueprint: blueprint),
              const SizedBox(height: 32),

              // Erreur éventuelle
              if (wizardState.error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          wizardState.error!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade800,
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
}

/// Indicateur de validation (avec vérification des dépendances des modules).
class _ValidationStatus extends StatelessWidget {
  final RestaurantBlueprintLight blueprint;
  final List<ModuleId> enabledModules;
  final bool isModulesValid;
  final List<ModuleId> missingDeps;

  const _ValidationStatus({
    required this.blueprint,
    required this.enabledModules,
    required this.isModulesValid,
    required this.missingDeps,
  });

  @override
  Widget build(BuildContext context) {
    final issues = <String>[];

    if (blueprint.name.isEmpty) issues.add('Nom manquant');
    if (blueprint.slug.isEmpty) issues.add('Slug manquant');
    if (blueprint.brand.brandName.isEmpty) issues.add('Nom de marque manquant');
    if (!isModulesValid) {
      issues.add('Dépendances modules: ${missingDeps.map((m) => m.label).join(', ')}');
    }

    final isValid = blueprint.isValid && isModulesValid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isValid ? Colors.green.shade100 : Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isValid ? Icons.check_circle : Icons.warning,
              color: isValid ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isValid ? 'Prêt à créer' : 'Configuration incomplète',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        isValid ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
                if (!isValid && issues.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      issues.join(' • '),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                if (isValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${enabledModules.length} modules activés',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section de prévisualisation.
class _PreviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final int stepIndex;
  final VoidCallback onEdit;
  final List<Widget> children;

  const _PreviewSection({
    required this.title,
    required this.icon,
    required this.stepIndex,
    required this.onEdit,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Modifier'),
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// Ligne de prévisualisation simple.
class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isOptional;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isOptional ? FontWeight.normal : FontWeight.w500,
                color: isOptional ? Colors.grey.shade500 : const Color(0xFF1A1A2E),
                fontStyle: isOptional ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne de prévisualisation pour les couleurs.
class _PreviewColorRow extends StatelessWidget {
  final String label;
  final List<String> colors;

  const _PreviewColorRow({
    required this.label,
    required this.colors,
  });

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Row(
            children: colors.map((color) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _parseColor(color),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Ligne de prévisualisation pour les modules.
class _PreviewModulesRow extends StatelessWidget {
  final RestaurantModulesLight modules;

  const _PreviewModulesRow({required this.modules});

  String _getModuleLabel(String module) {
    switch (module) {
      case 'ordering':
        return 'Commande';
      case 'delivery':
        return 'Livraison';
      case 'clickAndCollect':
        return 'Click & Collect';
      case 'payments':
        return 'Paiement';
      case 'loyalty':
        return 'Fidélité';
      case 'roulette':
        return 'Roulette';
      case 'kitchenTablet':
        return 'Cuisine';
      case 'staffTablet':
        return 'Staff';
      default:
        return module;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabledModules = modules.enabledModules;

    if (enabledModules.isEmpty) {
      return Text(
        'Aucun module activé',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: enabledModules.map((module) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 14, color: Colors.green.shade600),
              const SizedBox(width: 4),
              Text(
                _getModuleLabel(module),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Ligne de prévisualisation pour les modules (version avec ModuleId).
class _PreviewModulesRowNew extends StatelessWidget {
  final List<ModuleId> enabledModules;

  const _PreviewModulesRowNew({required this.enabledModules});

  @override
  Widget build(BuildContext context) {
    if (enabledModules.isEmpty) {
      return Text(
        'Aucun module activé',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: enabledModules.map((moduleId) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 14, color: Colors.green.shade600),
              const SizedBox(width: 4),
              Text(
                moduleId.label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Aperçu visuel de l'application.
class _AppPreview extends StatelessWidget {
  final RestaurantBlueprintLight blueprint;

  const _AppPreview({required this.blueprint});

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
    final primary = _parseColor(blueprint.brand.primaryColor);
    final accent = _parseColor(blueprint.brand.accentColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aperçu de l\'application',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Container(
              width: 280,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: primary,
                      child: SafeArea(
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
                                blueprint.brand.brandName.isEmpty
                                    ? blueprint.name
                                    : blueprint.brand.brandName,
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
                    ),
                    // Content placeholder
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade50,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              height: 20,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 14,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom nav
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.home, color: primary),
                          Icon(Icons.restaurant_menu, color: Colors.grey.shade400),
                          Icon(Icons.shopping_cart, color: Colors.grey.shade400),
                          Icon(Icons.person, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
