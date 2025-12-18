// lib/src/widgets/home/promo_card_compact.dart
// Compact promo card for horizontal carousel
// MIGRATED to WL V2 Theme - Uses theme colors

import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';

/// Compact promo card for displaying promotional products
/// Used in horizontal carousel on home page
class PromoCardCompact extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const PromoCardCompact({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: AppRadius.radiusLG,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with promo badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: context.backgroundColor,
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: context.primaryColor,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: context.backgroundColor,
                                child: const Center(
                                  child: Icon(
                                    Icons.local_pizza,
                                    size: 40,
                                    color: context.textSecondary,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: context.backgroundColor,
                            child: const Center(
                              child: Icon(
                                Icons.local_pizza,
                                size: 40,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                  ),
                ),
                // Promo badge
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: AppRadius.badge,
                    ),
                    child: Text(
                      'PROMO',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: context.surfaceColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: AppTextStyles.price,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          borderRadius: AppRadius.badge,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: context.surfaceColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
