// MIGRATED to WL V2 Theme - Uses theme colors
/// lib/src/screens/delivery/delivery_tracking_screen.dart
///
/// Écran de suivi de livraison.
///
/// Affiche:
/// - Statut de la commande
/// - Adresse de livraison
/// - Zone de livraison
/// - Heure estimée
///
/// TODO: Future intégration géolocalisation livreur

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/cards.dart';
import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../models/order.dart';
import '../../providers/restaurant_plan_provider.dart';
import '../../../white_label/core/module_id.dart';

/// Écran de suivi de livraison d'une commande.
class DeliveryTrackingScreen extends ConsumerWidget {
  final Order order;

  const DeliveryTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(restaurantFeatureFlagsProvider);

    // Guard: Vérifier si le module livraison est activé
    if (!(flags?.has(ModuleId.delivery) ?? false)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Suivi de livraison'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Le module livraison n\'est pas disponible'),
        ),
      );
    }

    // Vérifier que c'est bien une commande en livraison
    if (!order.isDeliveryOrder) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Suivi de livraison'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Cette commande n\'est pas en livraison'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suivi de livraison',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec animation livraison
            _buildDeliveryHeader(context),

            const SizedBox(height: AppSpacing.lg),

            // Statut de la commande
            _buildStatusCard(context),

            const SizedBox(height: AppSpacing.md),

            // Adresse de livraison
            _buildAddressCard(context),

            const SizedBox(height: AppSpacing.md),

            // Détails de la commande
            _buildOrderDetailsCard(context),

            const SizedBox(height: AppSpacing.lg),

            // TODO: Future - Carte avec géolocalisation du livreur
            _buildMapPlaceholder(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryHeader(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delivery_dining,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre commande est en route !',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Commande #${order.id.substring(0, 8).toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Statut',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Timeline des statuts
          _buildStatusTimeline(context),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context) {
    // Define delivery statuses with display name, status value, and icon
    // Using a custom status value for "En livraison" since OrderStatus.ready maps to delivery in transit
    const inDeliveryStatus = 'in_delivery';
    
    final statuses = [
      ('Commande reçue', OrderStatus.pending, Icons.receipt_long),
      ('En préparation', OrderStatus.preparing, Icons.restaurant),
      ('En cuisson', OrderStatus.baking, Icons.local_fire_department),
      ('En livraison', inDeliveryStatus, Icons.delivery_dining),
      ('Livrée', OrderStatus.delivered, Icons.check_circle),
    ];

    // Déterminer l'index actuel
    int currentIndex = 0;
    for (int i = 0; i < statuses.length; i++) {
      final statusValue = statuses[i].$2;
      // OrderStatus.ready maps to "En livraison" for delivery orders
      if (order.status == statusValue || 
          (order.status == OrderStatus.ready && statusValue == inDeliveryStatus)) {
        currentIndex = i;
        break;
      }
    }

    return Column(
      children: List.generate(statuses.length, (index) {
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final status = statuses[index];

        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : AppColors.neutral200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    status.$3,
                    size: 18,
                    color: isCompleted ? context.onPrimary : AppColors.neutral500,
                  ),
                ),
                if (index < statuses.length - 1)
                  Container(
                    width: 2,
                    height: 24,
                    color: isCompleted ? AppColors.primary : AppColors.neutral200,
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  status.$1,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                      ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    final address = order.deliveryAddress;
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Adresse de livraison',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (address != null) ...[
            Text(
              address.formattedAddress,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (address.complement != null && address.complement!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                address.complement!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            if (address.driverInstructions != null && address.driverInstructions!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: AppSpacing.paddingSM,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, size: 16, color: AppColors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address.driverInstructions!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.infoDark,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else
            Text(
              'Adresse non disponible',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Détails de la commande',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Montant total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total'),
              Text(
                '${order.total.toStringAsFixed(2)} €',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          if (order.deliveryFee != null && order.deliveryFee! > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.delivery_dining, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    const Text('Frais de livraison'),
                  ],
                ),
                Text('${order.deliveryFee!.toStringAsFixed(2)} €'),
              ],
            ),
          ],
          const Divider(height: AppSpacing.lg),
          // Nombre d'articles
          Text(
            '${order.items.length} article(s)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 48,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Suivi en temps réel',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bientôt disponible',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton pour accéder au suivi de livraison.
/// À utiliser dans les écrans de confirmation et d'historique.
class DeliveryTrackingButton extends ConsumerWidget {
  final Order order;

  const DeliveryTrackingButton({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(restaurantFeatureFlagsProvider);

    // Ne pas afficher si:
    // - Module livraison désactivé
    // - Pas une commande en livraison
    // - Commande déjà livrée ou annulée
    if (!(flags?.has(ModuleId.delivery) ?? false)) {
      return const SizedBox.shrink();
    }

    if (!order.isDeliveryOrder) {
      return const SizedBox.shrink();
    }

    if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: () {
        context.push('/order/${order.id}/tracking', extra: order);
      },
      icon: const Icon(Icons.delivery_dining),
      label: const Text('Suivre ma livraison'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: context.onPrimary,
      ),
    );
  }
}
