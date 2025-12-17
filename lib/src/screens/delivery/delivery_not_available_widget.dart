// MIGRATED to WL V2 Theme - Uses theme colors
/// lib/src/screens/delivery/delivery_not_available_widget.dart
///
/// Widget affiché quand la livraison n'est pas disponible.
///
/// Raisons possibles:
/// - Adresse hors zone
/// - Livraison désactivée
/// - Minimum non atteint
/// - Aucune zone configurée

import 'package:flutter/material.dart';

import '../../design_system/buttons.dart';
import '../../design_system/cards.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';

/// Raisons pour lesquelles la livraison n'est pas disponible.
enum DeliveryUnavailableReason {
  /// L'adresse est hors de toutes les zones de livraison
  outOfArea,

  /// Le module livraison est désactivé
  disabled,

  /// Le minimum de commande n'est pas atteint
  minimumNotReached,

  /// Aucune zone de livraison n'est configurée
  noZones,

  /// Erreur de chargement des paramètres
  loadError,
}

/// Widget pour afficher un message quand la livraison n'est pas disponible.
class DeliveryNotAvailableWidget extends StatelessWidget {
  final DeliveryUnavailableReason reason;
  final double? minimumAmount;
  final double? currentAmount;
  final VoidCallback? onRetry;
  final VoidCallback? onSwitchToPickup;

  const DeliveryNotAvailableWidget({
    super.key,
    required this.reason,
    this.minimumAmount,
    this.currentAmount,
    this.onRetry,
    this.onSwitchToPickup,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: AppEmptyCard(
        icon: _getIcon(),
        title: _getTitle(),
        subtitle: _getSubtitle(),
        action: _buildActions(context),
      ),
    );
  }

  IconData _getIcon() {
    switch (reason) {
      case DeliveryUnavailableReason.outOfArea:
        return Icons.location_off;
      case DeliveryUnavailableReason.disabled:
        return Icons.delivery_dining;
      case DeliveryUnavailableReason.minimumNotReached:
        return Icons.shopping_cart;
      case DeliveryUnavailableReason.noZones:
        return Icons.map;
      case DeliveryUnavailableReason.loadError:
        return Icons.error_outline;
    }
  }

  String _getTitle() {
    switch (reason) {
      case DeliveryUnavailableReason.outOfArea:
        return 'Adresse hors zone';
      case DeliveryUnavailableReason.disabled:
        return 'Livraison indisponible';
      case DeliveryUnavailableReason.minimumNotReached:
        return 'Minimum non atteint';
      case DeliveryUnavailableReason.noZones:
        return 'Aucune zone de livraison';
      case DeliveryUnavailableReason.loadError:
        return 'Erreur de chargement';
    }
  }

  String _getSubtitle() {
    switch (reason) {
      case DeliveryUnavailableReason.outOfArea:
        return 'Désolé, nous ne livrons pas encore à cette adresse. '
            'Vous pouvez modifier votre adresse ou choisir le retrait sur place.';
      case DeliveryUnavailableReason.disabled:
        return 'Le service de livraison n\'est pas disponible actuellement. '
            'Veuillez choisir le retrait sur place.';
      case DeliveryUnavailableReason.minimumNotReached:
        if (minimumAmount != null && currentAmount != null) {
          final remaining = minimumAmount! - currentAmount!;
          return 'Le minimum de commande est de ${minimumAmount!.toStringAsFixed(2)} €. '
              'Il vous manque ${remaining.toStringAsFixed(2)} € pour pouvoir être livré.';
        }
        return 'Le montant de votre commande n\'atteint pas le minimum requis pour la livraison.';
      case DeliveryUnavailableReason.noZones:
        return 'Aucune zone de livraison n\'est configurée pour ce restaurant. '
            'Veuillez choisir le retrait sur place.';
      case DeliveryUnavailableReason.loadError:
        return 'Une erreur est survenue lors du chargement des informations de livraison. '
            'Veuillez réessayer.';
    }
  }

  Widget? _buildActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reason == DeliveryUnavailableReason.outOfArea && onRetry != null)
          AppButton.primary(
            text: 'Modifier l\'adresse',
            icon: Icons.edit_location,
            onPressed: onRetry,
          ),

        if (reason == DeliveryUnavailableReason.minimumNotReached && onRetry != null)
          AppButton.primary(
            text: 'Ajouter des articles',
            icon: Icons.add_shopping_cart,
            onPressed: onRetry,
          ),

        if (reason == DeliveryUnavailableReason.loadError && onRetry != null)
          AppButton.primary(
            text: 'Réessayer',
            icon: Icons.refresh,
            onPressed: onRetry,
          ),

        if (onSwitchToPickup != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton.outline(
            text: 'Choisir le retrait sur place',
            icon: Icons.store,
            onPressed: onSwitchToPickup,
          ),
        ],
      ],
    );
  }
}

/// Widget inline pour afficher un avertissement de minimum non atteint.
class DeliveryMinimumWarning extends StatelessWidget {
  final double minimumAmount;
  final double currentAmount;
  final VoidCallback? onAddItems;

  const DeliveryMinimumWarning({
    super.key,
    required this.minimumAmount,
    required this.currentAmount,
    this.onAddItems,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = minimumAmount - currentAmount;
    final progress = currentAmount / minimumAmount;

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: AppColors.warning, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Minimum de commande non atteint',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.warningDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.warning.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Votre panier: ${currentAmount.toStringAsFixed(2)} €',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warningDark,
                    ),
              ),
              Text(
                'Minimum: ${minimumAmount.toStringAsFixed(2)} €',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warningDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            'Ajoutez ${remaining.toStringAsFixed(2)} € pour pouvoir être livré',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.warningDark,
                ),
          ),

          if (onAddItems != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton.secondary(
              text: 'Ajouter des articles',
              icon: Icons.add,
              onPressed: onAddItems,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget pour afficher un badge "hors zone".
class OutOfAreaBadge extends StatelessWidget {
  const OutOfAreaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, size: 16, color: AppColors.error),
          const SizedBox(width: 4),
          Text(
            'Hors zone',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
