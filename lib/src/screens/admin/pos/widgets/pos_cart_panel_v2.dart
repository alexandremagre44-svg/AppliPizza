// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/admin/pos/widgets/pos_cart_panel_v2.dart
/// 
/// Enhanced POS cart panel with validation feedback and item actions
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/pos_design_system.dart';
import '../../../../design_system/pos_components.dart';
import '../../../../design_system/colors.dart';
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
        // Cart header - ShopCaisse style
        Container(
          padding: EdgeInsets.all(PosSpacing.lg),
          decoration: BoxDecoration(
            color: PosColors.primary,
            boxShadow: PosShadows.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(PosSpacing.sm),
                decoration: BoxDecoration(
                  color: PosColors.textOnPrimary.withOpacity(0.2),
                  borderRadius: PosRadii.mdRadius,
                ),
                child: Icon(
                  Icons.shopping_cart_rounded,
                  color: PosColors.textOnPrimary,
                  size: PosIconSize.md,
                ),
              ),
              SizedBox(width: PosSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panier',
                    style: PosTypography.headingSmall.copyWith(
                      color: PosColors.textOnPrimary,
                    ),
                  ),
                  Text(
                    '${cart.totalItems} article${cart.totalItems > 1 ? 's' : ''}',
                    style: PosTypography.bodySmall.copyWith(
                      color: PosColors.textOnPrimary.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Validation errors banner - ShopCaisse style
        if (validationErrors.isNotEmpty)
          Container(
            padding: EdgeInsets.all(PosSpacing.md),
            color: PosColors.warningLight,
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: PosColors.warning, size: PosIconSize.sm),
                SizedBox(width: PosSpacing.sm),
                Expanded(
                  child: Text(
                    validationErrors.first,
                    style: PosTypography.labelMedium.copyWith(
                      color: PosColors.warning,
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceVariant // was Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: 72,
                          color: context.colorScheme.surfaceVariant // was Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Panier vide',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.surfaceVariant // was Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez des produits\npour commencer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.colorScheme.surfaceVariant // was Colors.grey[500],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (context, index) => Divider(
                    height: PosSpacing.lg,
                    thickness: 1,
                    color: PosColors.border,
                  ),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _PosCartItemTileV2(item: item);
                  },
                ),
        ),

        // Cart summary footer - ShopCaisse style
        Container(
          padding: EdgeInsets.all(PosSpacing.lg),
          decoration: BoxDecoration(
            color: PosColors.surface,
            border: Border(
              top: BorderSide(color: PosColors.border, width: 2),
            ),
            boxShadow: PosShadows.md,
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(PosSpacing.md),
                decoration: BoxDecoration(
                  color: PosColors.surfaceVariant,
                  borderRadius: PosRadii.mdRadius,
                  border: Border.all(color: PosColors.border, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate_rounded, color: PosColors.textSecondary, size: PosIconSize.md),
                        SizedBox(width: PosSpacing.sm),
                        Text('Total', style: PosTypography.headingMedium),
                      ],
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} €',
                      style: PosTypography.priceLarge.copyWith(
                        color: PosColors.primary,
                      ),
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
        color: context.colorScheme.surfaceVariant // was Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.surfaceVariant // was Colors.grey[200]!, width: 1),
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
                        color: context.colorScheme.shadow.withOpacity(0.1),
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
                            color: context.colorScheme.surfaceVariant // was Colors.grey[200],
                            child: Icon(Icons.image_not_supported_rounded,
                                color: context.colorScheme.surfaceVariant // was Colors.grey[400], size: 30),
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: context.colorScheme.surfaceVariant // was Colors.grey[200],
                          child: Icon(Icons.fastfood_rounded,
                              color: context.colorScheme.surfaceVariant // was Colors.grey[400], size: 32),
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
                        color: context.colorScheme.surfaceVariant // was Colors.grey[900],
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
                            color: context.colorScheme.surfaceVariant // was Colors.grey[600],
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
                  color: context.onPrimary,
                  border: Border.all(color: context.colorScheme.surfaceVariant // was Colors.grey[300]!, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: context.colorScheme.shadow.withOpacity(0.05),
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
                              size: 18, color: AppColors.error[600]),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: context.colorScheme.surfaceVariant // was Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.colorScheme.surfaceVariant // was Colors.grey[800],
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
                              size: 18, color: AppColors.success[600]),
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
                    color: context.primaryColor[600],
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
                    color: AppColors.error[600],
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
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryContainer,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${itemTotal.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
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
