// MIGRATED to WL V2 Theme - Uses theme colors
/// lib/src/screens/delivery/delivery_summary_widget.dart
///
/// Widget récapitulatif de la livraison pour le checkout.
///
/// Affiche:
/// - Zone choisie
/// - Frais de livraison
/// - Minimum requis
/// - Instructions livreur
/// - Temps estimé

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/cards.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/restaurant_plan_provider.dart';
import '../../../white_label/modules/core/delivery/delivery_settings.dart';

/// Widget récapitulatif de la livraison pour intégration dans le checkout.
class DeliverySummaryWidget extends ConsumerWidget {
  const DeliverySummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryProvider);
    final cartState = ref.watch(cartProvider);
    final deliverySettings = ref.watch(deliverySettingsProvider);

    // Ne rien afficher si pas de livraison configurée
    if (!deliveryState.isDeliveryConfigured) {
      return const SizedBox.shrink();
    }

    final address = deliveryState.selectedAddress!;
    final area = deliveryState.selectedArea!;
    final cartTotal = cartState.total;

    // Calculer les frais de livraison
    final deliveryFee = deliverySettings != null
        ? computeDeliveryFee(deliverySettings, area, cartTotal)
        : area.deliveryFee;

    // Vérifier le minimum
    final minimumOk = deliverySettings != null
        ? isMinimumReached(deliverySettings, area, cartTotal)
        : cartTotal >= area.minimumOrderAmount;

    final minimumAmount = deliverySettings != null
        ? getMinimumOrderAmount(deliverySettings, area)
        : area.minimumOrderAmount;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Livraison',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              // Bouton modifier
              TextButton(
                onPressed: () => context.push('/delivery/address'),
                child: const Text('Modifier'),
              ),
            ],
          ),

          const Divider(height: AppSpacing.lg),

          // Adresse
          _buildInfoRow(
            context,
            icon: Icons.location_on,
            label: 'Adresse',
            value: address.formattedAddress,
          ),

          if (address.complement != null && address.complement!.isNotEmpty)
            _buildInfoRow(
              context,
              icon: Icons.apartment,
              label: 'Complément',
              value: address.complement!,
            ),

          const SizedBox(height: AppSpacing.sm),

          // Zone
          _buildInfoRow(
            context,
            icon: Icons.map,
            label: 'Zone',
            value: area.name,
          ),

          const SizedBox(height: AppSpacing.sm),

          // Délai estimé
          _buildInfoRow(
            context,
            icon: Icons.access_time,
            label: 'Délai estimé',
            value: '${area.estimatedMinutes} min',
            valueColor: AppColors.info,
          ),

          const Divider(height: AppSpacing.lg),

          // Frais de livraison
          _buildFeeRow(
            context,
            label: 'Frais de livraison',
            value: deliveryFee > 0
                ? '${deliveryFee.toStringAsFixed(2)} €'
                : 'Gratuit',
            isFree: deliveryFee == 0,
          ),

          // Message livraison gratuite
          if (deliverySettings?.freeDeliveryThreshold != null &&
              deliveryFee > 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Gratuit dès ${deliverySettings!.freeDeliveryThreshold!.toStringAsFixed(0)} € de commande',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),

          // Avertissement minimum non atteint
          if (!minimumOk) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: AppSpacing.paddingSM,
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.warning, size: 20),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Minimum de commande: ${minimumAmount.toStringAsFixed(2)} €',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warningDark,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Instructions livreur
          if (address.driverInstructions != null &&
              address.driverInstructions!.isNotEmpty) ...[
            const Divider(height: AppSpacing.lg),
            _buildInfoRow(
              context,
              icon: Icons.note,
              label: 'Instructions',
              value: address.driverInstructions!,
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: valueColor,
                  ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isFree = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isFree ? AppColors.success : null,
              ),
        ),
      ],
    );
  }
}

/// Widget compact pour afficher les frais de livraison dans le récapitulatif.
class DeliveryFeeRow extends ConsumerWidget {
  const DeliveryFeeRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryProvider);
    final cartState = ref.watch(cartProvider);
    final deliverySettings = ref.watch(deliverySettingsProvider);

    if (!deliveryState.isDeliveryConfigured) {
      return const SizedBox.shrink();
    }

    final area = deliveryState.selectedArea!;
    final cartTotal = cartState.total;

    final deliveryFee = deliverySettings != null
        ? computeDeliveryFee(deliverySettings, area, cartTotal)
        : area.deliveryFee;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Frais de livraison'),
        Text(
          deliveryFee > 0
              ? '${deliveryFee.toStringAsFixed(2)} €'
              : 'Gratuit',
          style: TextStyle(
            color: deliveryFee == 0 ? AppColors.success : null,
            fontWeight: deliveryFee == 0 ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}

/// Widget pour afficher un badge avec le délai estimé.
class DeliveryTimeBadge extends ConsumerWidget {
  const DeliveryTimeBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryProvider);

    if (!deliveryState.isDeliveryConfigured) {
      return const SizedBox.shrink();
    }

    final area = deliveryState.selectedArea!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 16, color: AppColors.info),
          const SizedBox(width: 4),
          Text(
            '${area.estimatedMinutes} min',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.infoDark,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
