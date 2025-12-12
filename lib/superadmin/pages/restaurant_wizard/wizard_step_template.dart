/// lib/superadmin/pages/restaurant_wizard/wizard_step_template.dart
///
/// Étape 3 du Wizard: Sélection du template.
/// Permet de choisir un template de départ pour le restaurant.
/// 
/// ⚠️ IMPORTANT: Le template définit la LOGIQUE MÉTIER uniquement.
/// Les modules sont recommandés mais DOIVENT être activés manuellement
/// par le SuperAdmin à l'étape suivante.
///
/// FIX WizardStepTemplate:
/// - Added debug logs to track template selection flow
/// - Connected TemplateCard.onSelect -> RestaurantWizardState.selectTemplate
/// - Ensured selectedTemplateId comes from blueprint.templateId
/// - Synced preview/modules steps with same source of truth
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pizza_delizza/white_label/core/module_id.dart';
import '../../../white_label/restaurant/restaurant_template.dart';
import 'wizard_state.dart';

/// Récupère un template par son ID.
/// Utilise le nouveau système de templates métier.
RestaurantTemplate? getTemplateById(String? id) {
  return RestaurantTemplates.getById(id);
}

/// Étape 3: Sélection du template.
class WizardStepTemplate extends ConsumerWidget {
  const WizardStepTemplate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(restaurantWizardProvider);
    final selectedTemplateId = wizardState.blueprint.templateId;

    if (kDebugMode) {
      debugPrint('[WizardStepTemplate] Building with selectedTemplateId: $selectedTemplateId');
    }

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
                'Choisir un template métier',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Le template définit la logique métier (workflow, types de service, etc.).\nLes modules business seront activés à l\'étape suivante.',
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
                itemCount: RestaurantTemplates.all.length,
                itemBuilder: (context, index) {
                  final template = RestaurantTemplates.all[index];
                  final isSelected = template.id == selectedTemplateId;

                  if (kDebugMode) {
                    debugPrint('[WizardStepTemplate] Building card ${template.id}: isSelected=$isSelected, selectedTemplateId=$selectedTemplateId');
                  }

                  return _TemplateCard(
                    template: template,
                    isSelected: isSelected,
                    onSelect: () {
                      if (kDebugMode) {
                        debugPrint('[WizardStepTemplate] Template card clicked: ${template.id}');
                      }
                      ref
                          .read(restaurantWizardProvider.notifier)
                          .selectTemplate(template);
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // Info sur le template sélectionné
              if (selectedTemplateId != null)
                _TemplateDetails(
                  template: getTemplateById(selectedTemplateId) ??
                      RestaurantTemplates.defaultTemplate,
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
  final VoidCallback onSelect;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.onSelect,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
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
            // Modules recommandés
            Text(
              '${template.recommendedModules.length} modules recommandés',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white60 : Colors.grey.shade500,
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Détails du template sélectionné.
class _TemplateDetails extends StatelessWidget {
  final RestaurantTemplate template;

  const _TemplateDetails({required this.template});

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration du template "${template.name}"',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type de service: ${_getServiceTypeLabel(template.serviceType)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Modules recommandés (à activer à l\'étape suivante):',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          if (template.recommendedModules.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: template.recommendedModules.map((moduleId) {
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 14,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        moduleId.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Aucun module recommandé. Vous pourrez activer les modules à l\'étape suivante.',
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

  String _getServiceTypeLabel(ServiceType type) {
    switch (type) {
      case ServiceType.tableService:
        return 'Service à table';
      case ServiceType.counterService:
        return 'Service au comptoir';
      case ServiceType.deliveryOnly:
        return 'Livraison uniquement';
      case ServiceType.mixed:
        return 'Mixte (table + comptoir + livraison)';
    }
  }
}
