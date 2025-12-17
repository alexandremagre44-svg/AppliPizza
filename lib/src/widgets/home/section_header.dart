// lib/src/widgets/home/section_header.dart
// Section header widget for home page
// MIGRATED to WL V2 Theme - Uses theme colors

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';

/// Section header widget for home page sections
/// Displays a title with consistent styling
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineMedium,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'Voir tout',
                style: context.labelLarge?.copyWith( // WL V2: Theme text
                  color: context.primaryColor, // WL V2: Theme primary
                ),
              ),
            ),
        ],
      ),
    );
  }
}
