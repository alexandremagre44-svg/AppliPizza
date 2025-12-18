// lib/src/widgets/home/info_banner.dart
// Info banner widget for displaying business hours
// MIGRATED to WL V2 Theme - Uses theme colors

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';

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
    // WL V2: Uses theme colors with fallback to custom colors if provided
    return Container(
      margin: AppSpacing.paddingHorizontalLG,
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.surfaceColor, // WL V2: Theme surface or custom
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: context.outlineVariant, // WL V2: Theme outline
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: iconColor ?? textColor ?? context.textSecondary, // WL V2: Theme text or custom
            ),
            SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Text(
              text,
              style: context.bodyMedium?.copyWith( // WL V2: Theme text
                color: textColor ?? context.onSurface, // WL V2: Theme text or custom
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
