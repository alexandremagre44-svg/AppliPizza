// lib/screens/kitchen_tablet/kitchen_tablet_status_chip.dart

import 'package:flutter/material.dart';
import '../../services/runtime/kitchen_orders_runtime_service.dart';

/// Widget chip pour afficher le statut d'une commande en cuisine
class KitchenTabletStatusChip extends StatelessWidget {
  final KitchenStatus status;

  const KitchenTabletStatusChip({
    super.key,
    required this.status,
  });

  /// Retourne la couleur associée au statut
  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
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

  /// Retourne la couleur du texte associée au statut
  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case KitchenStatus.pending:
        return colorScheme.onSurfaceVariant;
      case KitchenStatus.preparing:
        return colorScheme.onPrimaryContainer;
      case KitchenStatus.ready:
        return colorScheme.onTertiaryContainer;
      case KitchenStatus.delivered:
        return colorScheme.onSurfaceVariant;
    }
  }

  /// Retourne le label du statut
  String _getStatusLabel() {
    switch (status) {
      case KitchenStatus.pending:
        return 'En attente';
      case KitchenStatus.preparing:
        return 'En préparation';
      case KitchenStatus.ready:
        return 'Prête';
      case KitchenStatus.delivered:
        return 'Livrée';
    }
  }

  /// Retourne l'icône du statut
  IconData _getStatusIcon() {
    switch (status) {
      case KitchenStatus.pending:
        return Icons.schedule;
      case KitchenStatus.preparing:
        return Icons.restaurant;
      case KitchenStatus.ready:
        return Icons.check_circle;
      case KitchenStatus.delivered:
        return Icons.done_all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: 16,
            color: _getTextColor(context),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusLabel(),
            style: TextStyle(
              color: _getTextColor(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
