// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/staff_tablet/widgets/staff_tablet_cart_summary.dart

import 'package:flutter/material.dart';
import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';
import '../../design_system/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';
import '../providers/staff_tablet_cart_provider.dart';
import '../../design_system/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';

class StaffTabletCartSummary extends ConsumerWidget {
  const StaffTabletCartSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(staffTabletCartProvider);

    return Column(
      children: [
        // Cart header with gradient
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primarySwatch[600]!, AppColors.primaryDark!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shopping_cart_rounded,
                  color: context.onPrimary,
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
                      color: context.onPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${cart.totalItems} article${cart.totalItems > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.onPrimary.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Cart items with better styling
        Expanded(
          child: cart.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceVariant ,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: 72,
                          color: context.colorScheme.surfaceVariant ,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Panier vide',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: context.colorScheme.surfaceVariant ,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ajoutez des produits\npour commencer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.colorScheme.surfaceVariant ,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
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
                    return _CartItemTile(item: item);
                  },
                ),
        ),

        // Cart summary footer with improved design
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: context.onPrimary,
            border: Border(
              top: BorderSide(color: context.colorScheme.surfaceVariant),
            ),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Total with enhanced design
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceVariant ,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colorScheme.surfaceVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate_rounded, color: context.colorScheme.surfaceVariant),
                        const SizedBox(width: 10),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: context.colorScheme.surfaceVariant ,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${cart.total.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Clear cart button with better styling
              if (cart.items.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppColors.error[700]),
                            const SizedBox(width: 12),
                            const Text('Vider le panier'),
                          ],
                        ),
                        content: const Text(
                          'Êtes-vous sûr de vouloir supprimer tous les articles du panier ?',
                          style: TextStyle(fontSize: 15),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Annuler',
                              style: TextStyle(
                                color: context.colorScheme.surfaceVariant ,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(staffTabletCartProvider.notifier).clearCart();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error[600],
                              foregroundColor: context.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Vider', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                  label: const Text(
                    'Vider le panier',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error[600],
                    side: BorderSide(color: AppColors.error[300]!, width: 1.5),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              
              if (cart.items.isNotEmpty) const SizedBox(height: 12),

              // Proceed to checkout button with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: cart.items.isEmpty
                      ? null
                      : LinearGradient(
                          colors: [AppColors.primarySwatch[600]!, AppColors.primaryDark!],
                        ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: cart.items.isEmpty
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: ElevatedButton.icon(
                  onPressed: cart.items.isEmpty
                      ? null
                      : () => context.push('/staff-tablet/checkout'),
                  icon: const Icon(Icons.check_circle_rounded, size: 24),
                  label: const Text(
                    'Valider la commande',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cart.items.isEmpty ? null : Colors.transparent,
                    foregroundColor: context.onPrimary,
                    disabledBackgroundColor: context.colorScheme.surfaceVariant ,
                    disabledForegroundColor: context.colorScheme.surfaceVariant ,
                    minimumSize: const Size(double.infinity, 64),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends ConsumerWidget {
  final dynamic item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceVariant ,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.surfaceVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image with improved styling
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
                        color: context.colorScheme.surfaceVariant ,
                        child: Icon(Icons.image_not_supported_rounded,
                            color: context.colorScheme.surfaceVariant),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: context.colorScheme.surfaceVariant ,
                      child: Icon(Icons.fastfood_rounded,
                          color: context.colorScheme.surfaceVariant),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Product info and controls
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.surfaceVariant ,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Custom description if exists
                if (item.customDescription != null && item.customDescription!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      item.customDescription!,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colorScheme.surfaceVariant ,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 10),

                // Quantity controls and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity controls with improved design
                    Container(
                      decoration: BoxDecoration(
                        color: context.onPrimary,
                        border: Border.all(color: context.colorScheme.surfaceVariant),
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
                                  .read(staffTabletCartProvider.notifier)
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
                                  color: context.colorScheme.surfaceVariant ,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: context.colorScheme.surfaceVariant ,
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => ref
                                  .read(staffTabletCartProvider.notifier)
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

                    // Price with enhanced styling
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primarySwatch[200]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${item.total.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
