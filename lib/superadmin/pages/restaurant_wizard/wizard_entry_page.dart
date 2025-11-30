/// lib/superadmin/pages/restaurant_wizard/wizard_entry_page.dart
///
/// Page principale du Wizard de création de restaurant.
/// Affiche le stepper et le contenu de l'étape courante.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'wizard_state.dart';
import 'wizard_step_identity.dart';
import 'wizard_step_brand.dart';
import 'wizard_step_template.dart';
import 'wizard_step_modules.dart';
import 'wizard_step_preview.dart';

/// Page principale du wizard de création de restaurant.
class WizardEntryPage extends ConsumerWidget {
  const WizardEntryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(restaurantWizardProvider);

    // Si le wizard est complété, afficher un message de succès
    if (wizardState.isCompleted) {
      return _WizardCompletedScreen(
        blueprint: wizardState.blueprint,
        onClose: () {
          ref.read(restaurantWizardProvider.notifier).reset();
          context.go('/superadmin/restaurants');
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          // Header avec stepper
          _WizardHeader(
            currentStep: wizardState.currentStep,
            onStepTap: (step) {
              ref.read(restaurantWizardProvider.notifier).goToStep(step);
            },
          ),
          // Contenu de l'étape
          Expanded(
            child: _buildStepContent(wizardState.currentStep),
          ),
          // Footer avec navigation
          _WizardFooter(
            wizardState: wizardState,
            onBack: () {
              ref.read(restaurantWizardProvider.notifier).previousStep();
            },
            onNext: () {
              ref.read(restaurantWizardProvider.notifier).nextStep();
            },
            onSubmit: () {
              ref.read(restaurantWizardProvider.notifier).submit();
            },
            onCancel: () {
              _showCancelDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(WizardStep step) {
    switch (step) {
      case WizardStep.identity:
        return const WizardStepIdentity();
      case WizardStep.brand:
        return const WizardStepBrand();
      case WizardStep.template:
        return const WizardStepTemplate();
      case WizardStep.modules:
        return const WizardStepModules();
      case WizardStep.preview:
        return const WizardStepPreview();
    }
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la création ?'),
        content: const Text(
          'Toutes les modifications seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(restaurantWizardProvider.notifier).reset();
              context.go('/superadmin/restaurants');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}

/// Header du wizard avec le stepper.
class _WizardHeader extends StatelessWidget {
  final WizardStep currentStep;
  final Function(WizardStep) onStepTap;

  const _WizardHeader({
    required this.currentStep,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          const Text(
            'Créer un nouveau restaurant',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentStep.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          // Stepper horizontal
          Row(
            children: WizardStep.values.map((step) {
              final isActive = step.index <= currentStep.index;
              final isCurrent = step == currentStep;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onStepTap(step),
                  child: Row(
                    children: [
                      // Cercle de l'étape
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? const Color(0xFF1A1A2E)
                              : isActive
                                  ? Colors.green
                                  : Colors.grey.shade300,
                        ),
                        child: Center(
                          child: isActive && !isCurrent
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${step.index + 1}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent || isActive
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Titre de l'étape
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight:
                                    isCurrent ? FontWeight.bold : FontWeight.normal,
                                color: isCurrent
                                    ? const Color(0xFF1A1A2E)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Ligne de connexion
                      if (step.index < WizardStep.values.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: step.index < currentStep.index
                                ? Colors.green
                                : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Footer du wizard avec les boutons de navigation.
class _WizardFooter extends StatelessWidget {
  final RestaurantWizardState wizardState;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _WizardFooter({
    required this.wizardState,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton Annuler
          TextButton(
            onPressed: onCancel,
            child: const Text('Annuler'),
          ),
          Row(
            children: [
              // Bouton Précédent
              if (wizardState.canGoBack)
                OutlinedButton(
                  onPressed: onBack,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 18),
                      SizedBox(width: 8),
                      Text('Précédent'),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
              // Bouton Suivant / Créer
              if (wizardState.isLastStep)
                ElevatedButton(
                  onPressed: wizardState.isSubmitting || !wizardState.isCurrentStepValid
                      ? null
                      : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: wizardState.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 18),
                            SizedBox(width: 8),
                            Text('Créer le restaurant'),
                          ],
                        ),
                )
              else
                ElevatedButton(
                  onPressed: wizardState.isCurrentStepValid ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Suivant'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Écran affiché quand le wizard est complété avec succès.
class _WizardCompletedScreen extends StatelessWidget {
  final dynamic blueprint;
  final VoidCallback onClose;

  const _WizardCompletedScreen({
    required this.blueprint,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(48),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green.shade600,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Restaurant créé avec succès !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Le restaurant "${blueprint.name}" a été créé.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Retour à la liste'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
