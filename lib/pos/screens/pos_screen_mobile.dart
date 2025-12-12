/// POS Mobile Screen - optimized for mobile/serveuse mode
/// 
/// This screen implements the POS interface for mobile devices,
/// with a full-screen product grid and floating cart button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import '../widgets/product_grid.dart';
import '../widgets/pos_context_bar.dart';
import '../providers/pos_cart_provider.dart';
import 'pos_checkout_sheet.dart';

/// Mobile POS Screen optimized for servers (serveuse mode)
class PosScreenMobile extends ConsumerWidget {
  const PosScreenMobile({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(posCartProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Column(
        children: [
          // Context bar
          const PosContextBar(),
          
          // Full-screen product grid
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: const PosProductGrid(),
            ),
          ),
        ],
      ),
      
      // Floating cart button
      floatingActionButton: badges.Badge(
        badgeContent: Text(
          '${cart.totalItems}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        showBadge: cart.isNotEmpty,
        position: badges.BadgePosition.topEnd(top: -4, end: -4),
        badgeStyle: badges.BadgeStyle(
          badgeColor: Colors.red[600]!,
          padding: const EdgeInsets.all(6),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Show cart modal
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const PosCheckoutSheet(),
            );
          },
          icon: const Icon(Icons.shopping_cart, size: 28),
          label: Text(
            '${cart.total.toStringAsFixed(2)} €',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
