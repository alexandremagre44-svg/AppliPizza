// lib/src/widgets/order_status_badge.dart
// Badge de statut pour afficher l'état d'une commande
// MIGRATED to WL V2 Theme - Uses semantic colors from AppColors

import 'package:flutter/material.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../../white_label/theme/theme_extensions.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;
  
  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    
    return Container(
      padding: compact 
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: AppRadius.badge,
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            config.emoji,
            style: TextStyle(fontSize: compact ? 12 : 14),
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: config.color,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
  
  _StatusConfig _getStatusConfig(String status) {
    // WL V2: Semantic colors (warning/success/error) kept as AppColors
    // for universal meaning. Text colors use theme.
    switch (status) {
      case OrderStatus.pending:
        return _StatusConfig(
          emoji: '🕓',
          color: AppColors.warning, // Semantic: orange
        );
      case OrderStatus.preparing:
        return _StatusConfig(
          emoji: '🧑‍🍳',
          color: AppColors.info, // Semantic: blue
        );
      case OrderStatus.ready:
        return _StatusConfig(
          emoji: '✅',
          color: AppColors.success, // Semantic: green
        );
      case OrderStatus.delivered:
        return _StatusConfig(
          emoji: '📦',
          color: AppColors.textSecondary, // Theme text secondary
        );
      case OrderStatus.cancelled:
        return _StatusConfig(
          emoji: '❌',
          color: AppColors.error, // Semantic: red
        );
      default:
        return _StatusConfig(
          emoji: '❓',
          color: AppColors.textTertiary, // Theme text tertiary
        );
    }
  }
}

class _StatusConfig {
  final String emoji;
  final Color color;
  
  _StatusConfig({required this.emoji, required this.color});
}
