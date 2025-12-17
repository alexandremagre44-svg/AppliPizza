// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/profile/widgets/account_activity_widget.dart
// Account activity section (orders and favorites) for profile screen (Material 3)

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../../../white_label/theme/theme_extensions.dart';
import '../../../models/app_texts_config.dart';

/// Display account activity: orders count and favorites count
/// Two card-style list items with counters
class AccountActivityWidget extends StatelessWidget {
  final int ordersCount;
  final int favoritesCount;
  final ProfileTexts texts;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onFavoritesTap;

  const AccountActivityWidget({
    super.key,
    required this.ordersCount,
    required this.favoritesCount,
    required this.texts,
    this.onOrdersTap,
    this.onFavoritesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Icon(
              Icons.timeline,
              color: AppColors.primary,
              size: 24,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Activité du compte',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        SizedBox(height: AppSpacing.md),
        
        // Orders card
        _buildActivityCard(
          context: context,
          icon: Icons.shopping_bag_outlined,
          iconColor: AppColors.primary,
          title: texts.activityMyOrders,
          count: ordersCount,
          onTap: onOrdersTap,
        ),
        
        SizedBox(height: AppSpacing.sm),
        
        // Favorites card
        _buildActivityCard(
          context: context,
          icon: Icons.favorite_outline,
          iconColor: Colors.pink,
          title: texts.activityMyFavorites,
          count: favoritesCount,
          onTap: onFavoritesTap,
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: AppRadius.cardSmall,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              
              SizedBox(width: AppSpacing.md),
              
              // Title
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Count badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: AppRadius.badge,
                ),
                child: Text(
                  count.toString(),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(width: AppSpacing.sm),
              
              // Arrow
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
