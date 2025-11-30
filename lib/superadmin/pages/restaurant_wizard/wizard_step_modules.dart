/// lib/superadmin/pages/restaurant_wizard/wizard_step_modules.dart
///
/// Étape 4 du Wizard: Configuration des modules.
/// Permet d'activer/désactiver les différents modules du restaurant.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/restaurant_blueprint.dart';
import 'wizard_state.dart';

/// Définition d'un module avec ses métadonnées.
class ModuleDefinition {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String category;
  final bool isCore;

  const ModuleDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.isCore = false,
  });
}

/// Liste des modules disponibles.
const List<ModuleDefinition> _availableModules = [
  // Core
  ModuleDefinition(
    id: 'ordering',
    name: 'Commande en ligne',
    description: 'Permet aux clients de passer des commandes depuis l\'application.',
    icon: Icons.shopping_cart,
    category: 'Core',
    isCore: true,
  ),
  ModuleDefinition(
    id: 'payments',
    name: 'Paiement en ligne',
    description: 'Intègre les paiements par carte bancaire et autres moyens.',
    icon: Icons.payment,
    category: 'Core',
    isCore: true,
  ),
  // Livraison
  ModuleDefinition(
    id: 'delivery',
    name: 'Livraison',
    description: 'Active le service de livraison à domicile.',
    icon: Icons.delivery_dining,
    category: 'Livraison',
  ),
  ModuleDefinition(
    id: 'clickAndCollect',
    name: 'Click & Collect',
    description: 'Permet aux clients de commander et récupérer sur place.',
    icon: Icons.store,
    category: 'Livraison',
  ),
  // Marketing
  ModuleDefinition(
    id: 'loyalty',
    name: 'Programme fidélité',
    description: 'Système de points et récompenses pour fidéliser les clients.',
    icon: Icons.card_giftcard,
    category: 'Marketing',
  ),
  ModuleDefinition(
    id: 'roulette',
    name: 'Jeu Roulette',
    description: 'Mini-jeu promotionnel pour engager les clients.',
    icon: Icons.casino,
    category: 'Marketing',
  ),
  // Operations
  ModuleDefinition(
    id: 'kitchenTablet',
    name: 'Tablette cuisine',
    description: 'Affichage des commandes en cuisine sur tablette.',
    icon: Icons.kitchen,
    category: 'Operations',
  ),
  ModuleDefinition(
    id: 'staffTablet',
    name: 'Tablette staff',
    description: 'Interface de prise de commande pour le personnel.',
    icon: Icons.tablet_android,
    category: 'Operations',
  ),
];

/// Étape 4: Configuration des modules.
class WizardStepModules extends ConsumerWidget {
  const WizardStepModules({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(restaurantWizardProvider);
    final modules = wizardState.blueprint.modules;

    // Grouper les modules par catégorie
    final modulesByCategory = <String, List<ModuleDefinition>>{};
    for (final module in _availableModules) {
      modulesByCategory.putIfAbsent(module.category, () => []);
      modulesByCategory[module.category]!.add(module);
    }

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
                'Sélectionnez les fonctionnalités que vous souhaitez activer pour votre restaurant.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),

              // Résumé
              _ModulesSummary(modules: modules),
              const SizedBox(height: 32),

              // Modules par catégorie
              ...modulesByCategory.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...entry.value.map((moduleDef) {
                      final isEnabled = _isModuleEnabled(modules, moduleDef.id);
                      return _ModuleToggleCard(
                        module: moduleDef,
                        isEnabled: isEnabled,
                        onToggle: (value) {
                          _toggleModule(ref, moduleDef.id, value);
                        },
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                );
              }),

              // Actions rapides
              _QuickActions(
                onEnableAll: () => _enableAllModules(ref),
                onDisableAll: () => _disableAllModules(ref),
                onEnableCore: () => _enableCoreModules(ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isModuleEnabled(RestaurantModulesLight modules, String moduleId) {
    switch (moduleId) {
      case 'ordering':
        return modules.ordering;
      case 'delivery':
        return modules.delivery;
      case 'clickAndCollect':
        return modules.clickAndCollect;
      case 'payments':
        return modules.payments;
      case 'loyalty':
        return modules.loyalty;
      case 'roulette':
        return modules.roulette;
      case 'kitchenTablet':
        return modules.kitchenTablet;
      case 'staffTablet':
        return modules.staffTablet;
      default:
        return false;
    }
  }

  void _toggleModule(WidgetRef ref, String moduleId, bool value) {
    final notifier = ref.read(restaurantWizardProvider.notifier);
    switch (moduleId) {
      case 'ordering':
        notifier.updateModules(ordering: value);
        break;
      case 'delivery':
        notifier.updateModules(delivery: value);
        break;
      case 'clickAndCollect':
        notifier.updateModules(clickAndCollect: value);
        break;
      case 'payments':
        notifier.updateModules(payments: value);
        break;
      case 'loyalty':
        notifier.updateModules(loyalty: value);
        break;
      case 'roulette':
        notifier.updateModules(roulette: value);
        break;
      case 'kitchenTablet':
        notifier.updateModules(kitchenTablet: value);
        break;
      case 'staffTablet':
        notifier.updateModules(staffTablet: value);
        break;
    }
  }

  void _enableAllModules(WidgetRef ref) {
    ref.read(restaurantWizardProvider.notifier).setModules(
          const RestaurantModulesLight(
            ordering: true,
            delivery: true,
            clickAndCollect: true,
            payments: true,
            loyalty: true,
            roulette: true,
            kitchenTablet: true,
            staffTablet: true,
          ),
        );
  }

  void _disableAllModules(WidgetRef ref) {
    ref
        .read(restaurantWizardProvider.notifier)
        .setModules(const RestaurantModulesLight());
  }

  void _enableCoreModules(WidgetRef ref) {
    ref.read(restaurantWizardProvider.notifier).setModules(
          const RestaurantModulesLight(
            ordering: true,
            payments: true,
          ),
        );
  }
}

/// Résumé des modules activés.
class _ModulesSummary extends StatelessWidget {
  final RestaurantModulesLight modules;

  const _ModulesSummary({required this.modules});

  @override
  Widget build(BuildContext context) {
    final enabledCount = modules.enabledCount;
    final totalCount = _availableModules.length;

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
                    modules.enabledModules.join(', '),
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

/// Carte de module avec toggle.
class _ModuleToggleCard extends StatelessWidget {
  final ModuleDefinition module;
  final bool isEnabled;
  final Function(bool) onToggle;

  const _ModuleToggleCard({
    required this.module,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
              module.icon,
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
                    Text(
                      module.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    if (module.isCore) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Core',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
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
