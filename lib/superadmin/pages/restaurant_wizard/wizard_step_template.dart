/// lib/superadmin/pages/restaurant_wizard/wizard_step_template.dart
///
/// Étape 3 du Wizard: Sélection du template.
/// Permet de choisir un template de départ pour le restaurant.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wizard_state.dart';

/// Template disponible pour la création de restaurant.
class RestaurantTemplate {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final List<String> includedModules;
  final String previewImageUrl;

  const RestaurantTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.includedModules,
    this.previewImageUrl = '',
  });
}

/// Templates mock disponibles.
const List<RestaurantTemplate> _mockTemplates = [
  RestaurantTemplate(
    id: 'pizzeria-template-1',
    name: 'Pizzeria Classic',
    description: 'Template complet pour pizzeria avec commande en ligne, livraison et fidélité.',
    iconName: 'local_pizza',
    includedModules: ['ordering', 'delivery', 'clickAndCollect', 'payments', 'loyalty'],
  ),
  RestaurantTemplate(
    id: 'fast-food-template-1',
    name: 'Fast Food Express',
    description: 'Template optimisé pour la restauration rapide avec système de tickets.',
    iconName: 'fastfood',
    includedModules: ['ordering', 'clickAndCollect', 'payments', 'kitchenTablet'],
  ),
  RestaurantTemplate(
    id: 'restaurant-premium',
    name: 'Restaurant Premium',
    description: 'Template haut de gamme avec toutes les fonctionnalités incluses.',
    iconName: 'restaurant',
    includedModules: ['ordering', 'delivery', 'clickAndCollect', 'payments', 'loyalty', 'roulette', 'kitchenTablet', 'staffTablet'],
  ),
  RestaurantTemplate(
    id: 'snack-delivery',
    name: 'Snack + Livraison',
    description: 'Template pour snack avec focus sur la livraison.',
    iconName: 'delivery_dining',
    includedModules: ['ordering', 'delivery', 'payments'],
  ),
  RestaurantTemplate(
    id: 'blank-template',
    name: 'Template Vide',
    description: 'Commencez de zéro et configurez tout manuellement.',
    iconName: 'add_box',
    includedModules: [],
  ),
];

/// Étape 3: Sélection du template.
class WizardStepTemplate extends ConsumerWidget {
  const WizardStepTemplate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(restaurantWizardProvider);
    final selectedTemplateId = wizardState.blueprint.templateId;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la section
              const Text(
                'Choisir un template',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sélectionnez un template de départ pour votre restaurant. Vous pourrez personnaliser les modules ensuite.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Grille de templates
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _mockTemplates.length,
                itemBuilder: (context, index) {
                  final template = _mockTemplates[index];
                  final isSelected = template.id == selectedTemplateId;

                  return _TemplateCard(
                    template: template,
                    isSelected: isSelected,
                    onTap: () {
                      ref
                          .read(restaurantWizardProvider.notifier)
                          .updateTemplate(template.id);
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // Info sur le template sélectionné
              if (selectedTemplateId != null)
                _TemplateDetails(
                  template: _mockTemplates.firstWhere(
                    (t) => t.id == selectedTemplateId,
                    orElse: () => _mockTemplates.last,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte de template.
class _TemplateCard extends StatelessWidget {
  final RestaurantTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (template.iconName) {
      case 'local_pizza':
        return Icons.local_pizza;
      case 'fastfood':
        return Icons.fastfood;
      case 'restaurant':
        return Icons.restaurant;
      case 'delivery_dining':
        return Icons.delivery_dining;
      case 'add_box':
        return Icons.add_box_outlined;
      default:
        return Icons.store;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône et sélection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIcon(),
                    size: 28,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Nom
            Text(
              template.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            // Description
            Expanded(
              child: Text(
                template.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white70 : Colors.grey.shade600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            // Modules inclus
            Text(
              '${template.includedModules.length} modules inclus',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white60 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Détails du template sélectionné.
class _TemplateDetails extends StatelessWidget {
  final RestaurantTemplate template;

  const _TemplateDetails({required this.template});

  String _getModuleLabel(String module) {
    switch (module) {
      case 'ordering':
        return 'Commande en ligne';
      case 'delivery':
        return 'Livraison';
      case 'clickAndCollect':
        return 'Click & Collect';
      case 'payments':
        return 'Paiement en ligne';
      case 'loyalty':
        return 'Programme fidélité';
      case 'roulette':
        return 'Jeu Roulette';
      case 'kitchenTablet':
        return 'Tablette cuisine';
      case 'staffTablet':
        return 'Tablette staff';
      default:
        return module;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600),
              const SizedBox(width: 12),
              Text(
                'Modules inclus dans "${template.name}"',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          if (template.includedModules.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: template.includedModules.map((module) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    _getModuleLabel(module),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Aucun module pré-configuré. Vous pourrez activer les modules à l\'étape suivante.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
