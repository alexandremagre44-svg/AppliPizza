/// lib/superadmin/pages/restaurant_wizard/wizard_step_modules.dart
///
/// Étape 4 du Wizard: Configuration des modules.
/// Permet d'activer/désactiver les différents modules du restaurant.
/// Utilise ModuleRegistry pour afficher tous les 17 modules disponibles.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../white_label/core/module_category.dart';
import '../../../white_label/core/module_definition.dart' as core;
import '../../../white_label/core/module_id.dart';
import '../../../white_label/core/module_registry.dart';
import 'wizard_state.dart';

/// Retourne une icône pour un ModuleId.
IconData _getModuleIcon(ModuleId moduleId) {
  switch (moduleId) {
    case ModuleId.ordering:
      return Icons.shopping_cart;
    case ModuleId.delivery:
      return Icons.delivery_dining;
    case ModuleId.clickAndCollect:
      return Icons.store;
    case ModuleId.payments:
      return Icons.payment;
    case ModuleId.paymentTerminal:
      return Icons.point_of_sale;
    case ModuleId.wallet:
      return Icons.account_balance_wallet;
    case ModuleId.loyalty:
      return Icons.card_giftcard;
    case ModuleId.roulette:
      return Icons.casino;
    case ModuleId.promotions:
      return Icons.local_offer;
    case ModuleId.newsletter:
      return Icons.email;
    case ModuleId.kitchenTablet:
      return Icons.kitchen;
    case ModuleId.staffTablet:
      return Icons.tablet_android;
    case ModuleId.timeRecorder:
      return Icons.access_time;
    case ModuleId.theme:
      return Icons.palette;
    case ModuleId.pagesBuilder:
      return Icons.web;
    case ModuleId.reporting:
      return Icons.analytics;
    case ModuleId.exports:
      return Icons.download;
    case ModuleId.campaigns:
      return Icons.campaign;
  }
}

/// Retourne une couleur pour une catégorie de module.
Color _getCategoryColor(ModuleCategory category) {
  switch (category) {
    case ModuleCategory.core:
      return Colors.blue;
    case ModuleCategory.payment:
      return Colors.green;
    case ModuleCategory.marketing:
      return Colors.orange;
    case ModuleCategory.operations:
      return Colors.purple;
    case ModuleCategory.appearance:
      return Colors.pink;
    case ModuleCategory.staff:
      return Colors.teal;
    case ModuleCategory.analytics:
      return Colors.indigo;
  }
}

/// Étape 4: Configuration des modules.
class WizardStepModules extends ConsumerWidget {
  const WizardStepModules({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(restaurantWizardProvider);
    final enabledModules = wizardState.enabledModuleIds;
    // Use a Set for O(1) lookup performance
    final enabledModulesSet = enabledModules.toSet();

    // Récupérer tous les modules depuis ModuleRegistry
    final allModules = ModuleRegistry.definitions.values.toList();

    // Grouper les modules par catégorie
    final modulesByCategory = <ModuleCategory, List<core.ModuleDefinition>>{};
    for (final module in allModules) {
      modulesByCategory.putIfAbsent(module.category, () => []);
      modulesByCategory[module.category]!.add(module);
    }

    // Calculer les dépendances manquantes
    final missingDeps = getMissingDependencies(enabledModules);

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
                'Activer les modules',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sélectionnez les fonctionnalités que vous souhaitez activer pour votre restaurant. '
                '${allModules.length} modules disponibles.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),

              // Résumé
              _ModulesSummary(
                enabledCount: enabledModules.length,
                totalCount: allModules.length,
                enabledModules: enabledModules,
              ),
              const SizedBox(height: 16),

              // Avertissement dépendances
              if (missingDeps.isNotEmpty)
                _DependencyWarning(missingDeps: missingDeps),
              const SizedBox(height: 24),

              // Modules par catégorie
              ...modulesByCategory.entries.map((entry) {
                return _ModuleCategorySection(
                  category: entry.key,
                  modules: entry.value,
                  enabledModulesSet: enabledModulesSet,
                  onToggle: (moduleId, enabled) {
                    ref
                        .read(restaurantWizardProvider.notifier)
                        .toggleModule(moduleId, enabled);
                  },
                );
              }),

              const SizedBox(height: 24),

              // Actions rapides
              _QuickActions(
                onEnableAll: () {
                  ref
                      .read(restaurantWizardProvider.notifier)
                      .setEnabledModules(ModuleId.values.toList());
                },
                onDisableAll: () {
                  ref
                      .read(restaurantWizardProvider.notifier)
                      .setEnabledModules([]);
                },
                onEnableCore: () {
                  ref.read(restaurantWizardProvider.notifier).setEnabledModules([
                    ModuleId.ordering,
                    ModuleId.payments,
                  ]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Résumé des modules activés.
class _ModulesSummary extends StatelessWidget {
  final int enabledCount;
  final int totalCount;
  final List<ModuleId> enabledModules;

  const _ModulesSummary({
    required this.enabledCount,
    required this.totalCount,
    required this.enabledModules,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enabledCount > 0 ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabledCount > 0 ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabledCount > 0 ? Colors.green.shade100 : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.extension,
              size: 24,
              color: enabledCount > 0 ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$enabledCount / $totalCount modules activés',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: enabledCount > 0
                        ? Colors.green.shade800
                        : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                if (enabledCount > 0)
                  Text(
                    enabledModules.take(5).map((m) => m.label).join(', ') +
                        (enabledModules.length > 5
                            ? ' +${enabledModules.length - 5}'
                            : ''),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    'Aucun module activé',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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

/// Avertissement pour les dépendances manquantes.
class _DependencyWarning extends StatelessWidget {
  final List<ModuleId> missingDeps;

  const _DependencyWarning({required this.missingDeps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dépendances manquantes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Modules requis: ${missingDeps.map((m) => m.label).join(', ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
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

/// Section de modules par catégorie.
class _ModuleCategorySection extends StatelessWidget {
  final ModuleCategory category;
  final List<core.ModuleDefinition> modules;
  final Set<ModuleId> enabledModulesSet;
  final Function(ModuleId, bool) onToggle;

  const _ModuleCategorySection({
    required this.category,
    required this.modules,
    required this.enabledModulesSet,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              category.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${modules.length})',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          category.description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        ...modules.map((moduleDef) {
          final isEnabled = enabledModulesSet.contains(moduleDef.id);
          return _ModuleToggleCard(
            module: moduleDef,
            isEnabled: isEnabled,
            categoryColor: color,
            onToggle: (value) => onToggle(moduleDef.id, value),
          );
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Carte de module avec toggle.
class _ModuleToggleCard extends StatelessWidget {
  final core.ModuleDefinition module;
  final bool isEnabled;
  final Color categoryColor;
  final Function(bool) onToggle;

  const _ModuleToggleCard({
    required this.module,
    required this.isEnabled,
    required this.categoryColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Récupérer les dépendances
    final deps = module.dependencies;
    final hasDeps = deps.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? Colors.green.shade300 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getModuleIcon(module.id),
              size: 24,
              color: isEnabled ? Colors.green.shade600 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        module.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (module.isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  module.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (hasDeps) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Requiert: ${deps.map((d) => d.label).join(', ')}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Switch
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

/// Actions rapides pour les modules.
class _QuickActions extends StatelessWidget {
  final VoidCallback onEnableAll;
  final VoidCallback onDisableAll;
  final VoidCallback onEnableCore;

  const _QuickActions({
    required this.onEnableAll,
    required this.onDisableAll,
    required this.onEnableCore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionButton(
                label: 'Activer tout',
                icon: Icons.check_circle_outline,
                onTap: onEnableAll,
              ),
              _QuickActionButton(
                label: 'Désactiver tout',
                icon: Icons.remove_circle_outline,
                onTap: onDisableAll,
              ),
              _QuickActionButton(
                label: 'Modules Core uniquement',
                icon: Icons.verified_outlined,
                onTap: onEnableCore,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
