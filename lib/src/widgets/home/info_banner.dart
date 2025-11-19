// lib/src/widgets/home/info_banner.dart
// Info banner widget for displaying business hours

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Info banner widget for displaying important information
/// Used on home page to show opening hours and other details
class InfoBanner extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const InfoBanner({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.paddingHorizontalLG,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.backgroundLight,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.textLight.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: iconColor ?? textColor ?? AppColors.textMedium,
            ),
            SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor ?? AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
