// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/profile/widgets/loyalty_section_widget.dart
// Compact loyalty section for profile screen (Material 3)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/app_theme.dart';
import '../../../../white_label/theme/theme_extensions.dart';
import '../../../core/constants.dart';
import '../../../models/app_texts_config.dart';

/// Compact loyalty card showing points, level, and progress
/// Material 3 design with Card, radius 16, subtle shadow
class LoyaltySectionWidget extends StatelessWidget {
  final int loyaltyPoints;
  final int lifetimePoints;
  final String vipTier;
  final ProfileTexts texts;

  const LoyaltySectionWidget({
    super.key,
    required this.loyaltyPoints,
    required this.lifetimePoints,
    required this.vipTier,
    required this.texts,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate progress to next free pizza (every 1000 points)
    final progressToFreePizza = (loyaltyPoints % 1000) / 1000.0;
    final pointsNeeded = 1000 - (loyaltyPoints % 1000);
    
    // Determine tier color and label
    final tierInfo = _getTierInfo(vipTier);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and tier badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: Colors.amber,
                      size: 24,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      texts.loyaltyTitle,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Tier badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: tierInfo['color'].withOpacity(0.1),
                    borderRadius: AppRadius.badge,
                    border: Border.all(
                      color: tierInfo['color'],
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tierInfo['icon'],
                        size: 14,
                        color: tierInfo['color'],
                      ),
                      SizedBox(width: AppSpacing.xxs),
                      Text(
                        tierInfo['label'],
                        style: AppTextStyles.labelSmall.copyWith(
                          color: tierInfo['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Points display
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        texts.loyaltyPoints,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        '$loyaltyPoints pts',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: AppSpacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: AppRadius.cardSmall,
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texts.loyaltyProgress,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: AppRadius.radiusSmall,
                  child: LinearProgressIndicator(
                    value: progressToFreePizza,
                    backgroundColor: AppColors.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  texts.loyaltyPointsNeeded.replaceAll('{points}', pointsNeeded.toString()),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // CTA Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to rewards screen
                  context.push(AppRoutes.rewards);
                },
                icon: Icon(Icons.emoji_events, size: 18),
                label: Text(texts.loyaltyCtaViewRewards),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get tier information (color, icon, label)
  Map<String, dynamic> _getTierInfo(String vipTier) {
    switch (vipTier.toLowerCase()) {
      case 'gold':
        return {
          'color': Colors.amber.shade700,
          'label': 'GOLD',
          'icon': Icons.workspace_premium,
        };
      case 'silver':
        return {
          'color': Colors.grey.shade400,
          'label': 'SILVER',
          'icon': Icons.military_tech,
        };
      default:
        return {
          'color': Colors.brown.shade400,
          'label': 'BRONZE',
          'icon': Icons.emoji_events,
        };
    }
  }
}
