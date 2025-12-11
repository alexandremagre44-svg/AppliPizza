/// POS Checkout Sheet - modal bottom sheet for cart and checkout on mobile
/// 
/// This widget displays the cart and checkout options in a modal bottom sheet
/// optimized for mobile devices.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/cart_panel.dart';
import '../widgets/pos_actions_panel_new.dart';

/// Checkout sheet for mobile POS
class PosCheckoutSheet extends ConsumerWidget {
  const PosCheckoutSheet({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Panier',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Cart and actions
          Expanded(
            child: Row(
              children: [
                // Cart (60%)
                Expanded(
                  flex: 3,
                  child: const PosCartPanel(),
                ),
                
                const VerticalDivider(width: 1),
                
                // Actions (40%)
                Expanded(
                  flex: 2,
                  child: const PosActionsPanelNew(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
