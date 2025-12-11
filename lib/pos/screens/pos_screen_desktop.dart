/// POS Desktop/Tablet Screen - 3-column layout for desktop/tablet devices
/// 
/// This screen implements the POS interface optimized for larger screens
/// with a 3-column layout: Products | Cart | Actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../widgets/pos_actions_panel_new.dart';
import '../widgets/pos_context_bar.dart';

/// Desktop/Tablet POS Screen with 3-column layout
class PosScreenDesktop extends ConsumerWidget {
  const PosScreenDesktop({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Context bar showing current order context
        const PosContextBar(),
        
        // Main 3-column layout
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: Product catalog (flex: 2)
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.grey[100],
                  child: const PosProductGrid(),
                ),
              ),
              
              const VerticalDivider(width: 1),
              
              // Middle column: Cart (flex: 1)
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  child: const PosCartPanel(),
                ),
              ),
              
              const VerticalDivider(width: 1),
              
              // Right column: Actions (fixed width: 300px)
              SizedBox(
                width: 300,
                child: Container(
                  color: Colors.white,
                  child: const PosActionsPanelNew(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
