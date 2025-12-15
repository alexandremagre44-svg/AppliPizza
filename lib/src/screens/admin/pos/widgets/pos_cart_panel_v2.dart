// lib/src/screens/admin/pos/widgets/pos_cart_panel_v2.dart
/// 
/// Enhanced POS cart panel with validation feedback and item actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design/pos_theme.dart';
import '../design/pos_components.dart';
import '../providers/pos_cart_provider.dart';

/// Enhanced POS Cart Panel
class PosCartPanelV2 extends ConsumerWidget {
  const PosCartPanelV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(posCartProvider);
    final cartNotifier = ref.read(posCartProvider.notifier);
    final validationErrors = cartNotifier.validateCart();
    final total = cartNotifier.calculateTotalWithSelections();

    return Column(
      children: [
        // Cart header
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: PosColors.primaryGradient,
            boxShadow: PosShadows.primaryGlow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panier',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${cart.totalItems} article${cart.totalItems > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Validation errors banner
        if (validationErrors.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange[50],
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    validationErrors.first,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Cart items
        Expanded(
          child: cart.items.isEmpty
              ? PosEmptyState(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Panier vide',
                  subtitle: 'Ajoutez des produits\npour commencer',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 28,
                    thickness: 1,
                    color: Color(0xFFEEEEEE),
                  ),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _PosCartItemTileV2(item: item);
                  },
                ),
        ),

        // Cart summary footer
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[200]!, width: 2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate_rounded, color: Colors.grey[700], size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} €',
                      style: PosTextStyles.priceDisplay,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PosCartItemTileV2 extends ConsumerWidget {
  final dynamic item;

  const _PosCartItemTileV2({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[200],
                            child: Icon(Icons.image_not_supported_rounded,
                                color: Colors.grey[400], size: 30),
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: Icon(Icons.fastfood_rounded,
                              color: Colors.grey[400], size: 32),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Display description with selections
                    if (item.displayDescription != null &&
                        item.displayDescription!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          item.displayDescription!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Actions and price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity controls
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => ref
                            .read(posCartProvider.notifier)
                            .decrementQuantity(item.id),
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(10)),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.remove_rounded,
                              size: 18, color: Colors.red[600]),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => ref
                            .read(posCartProvider.notifier)
                            .incrementQuantity(item.id),
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(10)),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.add_rounded,
                              size: 18, color: Colors.green[600]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Duplicate button
                  IconButton(
                    icon: const Icon(Icons.content_copy, size: 18),
                    color: Colors.blue[600],
                    tooltip: 'Dupliquer',
                    onPressed: () {
                      ref.read(posCartProvider.notifier).duplicateItem(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Article dupliqué'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    color: Colors.red[600],
                    tooltip: 'Supprimer',
                    onPressed: () {
                      ref.read(posCartProvider.notifier).removeItem(item.id);
                    },
                  ),
                ],
              ),

              // Price with selections delta
              Builder(
                builder: (context) {
                  // Calculate total with selections
                  double itemTotal = item.price;
                  for (final selection in item.selections) {
                    itemTotal += selection.priceDelta / 100.0;
                  }
                  itemTotal *= item.quantity;
                  
                  return PosPriceTag(
                    price: itemTotal,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
