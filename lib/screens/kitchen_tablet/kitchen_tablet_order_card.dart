// lib/screens/kitchen_tablet/kitchen_tablet_order_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/runtime/kitchen_orders_runtime_service.dart';
import 'kitchen_tablet_status_chip.dart';

/// Widget card pour afficher une commande en cuisine
class KitchenTabletOrderCard extends StatelessWidget {
  final KitchenOrder order;
  final VoidCallback? onStartPreparing;
  final VoidCallback? onMarkReady;
  final VoidCallback? onMarkDelivered;

  const KitchenTabletOrderCard({
    super.key,
    required this.order,
    this.onStartPreparing,
    this.onMarkReady,
    this.onMarkDelivered,
  });

  /// Calcule le temps écoulé depuis la création de la commande
  String _getElapsedTime() {
    final now = DateTime.now();
    final elapsed = now.difference(order.createdAt);

    if (elapsed.inHours > 0) {
      return '${elapsed.inHours}h ${elapsed.inMinutes % 60}min';
    } else if (elapsed.inMinutes > 0) {
      return '${elapsed.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }

  /// Formate l'heure de pickup
  String? _formatPickupTime() {
    if (order.pickupTime == null) return null;
    return DateFormat('HH:mm').format(order.pickupTime!);
  }

  /// Retourne la couleur de la carte selon le statut
  Color _getCardColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (order.status) {
      case KitchenStatus.pending:
        return colorScheme.surfaceVariant;
      case KitchenStatus.preparing:
        return colorScheme.primaryContainer;
      case KitchenStatus.ready:
        return colorScheme.tertiaryContainer;
      case KitchenStatus.delivered:
        return colorScheme.surfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pickupTime = _formatPickupTime();

    return Card(
      elevation: order.isViewed ? 2 : 8,
      color: _getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: order.isViewed
            ? BorderSide.none
            : BorderSide(
                color: colorScheme.primary,
                width: 3,
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec numéro de commande et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Numéro de commande
                Text(
                  'Commande #${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                // Badge nouveau
                if (!order.isViewed)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'NOUVEAU',
                      style: TextStyle(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Statut
            KitchenTabletStatusChip(status: order.status),
            const SizedBox(height: 12),

            // Informations de temps
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  'Il y a ${_getElapsedTime()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (pickupTime != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.schedule, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Pickup: $pickupTime',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Liste des items
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        order.items[index],
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Boutons d'action
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  /// Construit les boutons d'action selon le statut
  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (order.status) {
      case KitchenStatus.pending:
        // Bouton "Commencer"
        if (onStartPreparing != null) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStartPreparing,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Commencer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          );
        }
        return const SizedBox.shrink();

      case KitchenStatus.preparing:
        // Bouton "Prêt"
        if (onMarkReady != null) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onMarkReady,
              icon: const Icon(Icons.check_circle),
              label: const Text('Marquer Prête'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.tertiary,
                foregroundColor: colorScheme.onTertiary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          );
        }
        return const SizedBox.shrink();

      case KitchenStatus.ready:
        // Bouton "Livré"
        if (onMarkDelivered != null) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onMarkDelivered,
              icon: const Icon(Icons.done_all),
              label: const Text('Terminé / Livré'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          );
        }
        return const SizedBox.shrink();

      case KitchenStatus.delivered:
        // Pas de bouton pour les commandes livrées
        return const SizedBox.shrink();
    }
  }
}
