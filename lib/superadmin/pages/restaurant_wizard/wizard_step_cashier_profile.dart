/// lib/superadmin/pages/restaurant_wizard/wizard_step_cashier_profile.dart
///
/// Étape 4 du Wizard (conditionnelle): Choix du profil métier caisse.
/// Affichée UNIQUEMENT si le Template Vide a été sélectionné à l'étape précédente.
///
/// Permet de définir l'orientation métier POS sans imposer de modules.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../white_label/restaurant/cashier_profile.dart';
import 'wizard_state.dart';
import '../../white_label/theme/theme_extensions.dart';

/// Étape 4: Choix du profil métier caisse (conditionnelle).
/// N'est affichée que si le Template Vide est sélectionné.
class WizardStepCashierProfile extends ConsumerWidget {
  const WizardStepCashierProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(restaurantWizardProvider);
    final selectedProfile = wizardState.blueprint.cashierProfile;

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
                'Choisir votre profil métier',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ce profil orientera le comportement de votre application de caisse.\n'
                'Vous pourrez toujours activer ou désactiver les modules à l\'étape suivante.',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Grille de profils
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: CashierProfile.values.length,
                itemBuilder: (context, index) {
                  final profile = CashierProfile.values[index];
                  final isSelected = profile == selectedProfile;

                  return _CashierProfileCard(
                    profile: profile,
                    isSelected: isSelected,
                    onSelect: () {
                      ref
                          .read(restaurantWizardProvider.notifier)
                          .updateCashierProfile(profile);
                    },
                  );
                },
              ),
              const SizedBox(height: 32),

              // Info sur le profil sélectionné
              _CashierProfileInfo(profile: selectedProfile),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte de profil métier caisse.
class _CashierProfileCard extends StatelessWidget {
  final CashierProfile profile;
  final bool isSelected;
  final VoidCallback onSelect;

  const _CashierProfileCard({
    required this.profile,
    required this.isSelected,
    required this.onSelect,
  });

  IconData _getIcon() {
    switch (profile.iconName) {
      case 'local_pizza':
        return Icons.local_pizza;
      case 'fastfood':
        return Icons.fastfood;
      case 'restaurant':
        return Icons.restaurant;
      case 'set_meal':
        return Icons.set_meal;
      case 'store':
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
            color: isSelected ? const context.onSurface : context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const context.onSurface : context.colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const context.onSurface.withValues(alpha: 0.2),
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
                          ? context.surfaceColor.withValues(alpha: 0.1)
                          : context.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIcon(),
                      size: 28,
                      color: isSelected ? context.surfaceColor : context.textSecondary.shade700,
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
                        color: context.surfaceColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Nom
              Text(
                profile.displayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? context.surfaceColor : const context.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Expanded(
                child: Text(
                  profile.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? context.surfaceColor70 : context.textSecondary.shade600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Information sur le profil sélectionné.
class _CashierProfileInfo extends StatelessWidget {
  final CashierProfile profile;

  const _CashierProfileInfo({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil sélectionné: ${profile.displayName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ce profil orientera le comportement de la caisse. '
                  'Les modules restent librement configurables à l\'étape suivante.',
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
    );
  }
}
