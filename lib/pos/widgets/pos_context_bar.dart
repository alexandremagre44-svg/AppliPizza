/// POS Context Bar - displays current order context at the top of POS UI
/// 
/// Shows the order type (Table/Sur place/À emporter) and allows changing it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pos_context_provider.dart';
import '../screens/pos_table_selector.dart';

/// Context bar widget
class PosContextBar extends ConsumerWidget {
  const PosContextBar({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posContext = ref.watch(posContextProvider);
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Context indicator
          Expanded(
            child: Row(
              children: [
                Icon(
                  _getContextIcon(posContext),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  posContext?.displayLabel ?? 'Aucun contexte',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (posContext?.customerName != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '• ${posContext!.customerName}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Change context button
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const PosContextSelector(),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
            label: const Text(
              'Changer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getContextIcon(dynamic context) {
    if (context == null) return Icons.help_outline;
    
    switch (context.type.toString().split('.').last) {
      case 'table':
        return Icons.table_restaurant;
      case 'surPlace':
        return Icons.restaurant_menu;
      case 'emporter':
        return Icons.shopping_bag;
      default:
        return Icons.help_outline;
    }
  }
}
