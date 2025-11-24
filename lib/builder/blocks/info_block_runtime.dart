// lib/builder/blocks/info_block_runtime.dart
// Runtime version of InfoBlock

import 'package:flutter/material.dart';
import '../models/builder_block.dart';
import '../../src/theme/app_theme.dart';

class InfoBlockRuntime extends StatelessWidget {
  final BuilderBlock block;

  const InfoBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context) {
    final title = block.getConfig<String>('title') ?? '';
    final content = block.getConfig<String>('content') ?? '';
    final iconName = block.getConfig<String>('icon') ?? 'info';

    IconData icon;
    Color color;
    switch (iconName) {
      case 'warning':
        icon = Icons.warning_amber_outlined;
        color = Colors.orange;
        break;
      case 'error':
        icon = Icons.error_outline;
        color = AppColors.errorRed;
        break;
      case 'success':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.blue;
    }

    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: Container(
        padding: AppSpacing.paddingLG,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: AppRadius.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty) ...[
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(color: color),
                    ),
                    SizedBox(height: AppSpacing.xs),
                  ],
                  if (content.isNotEmpty)
                    Text(
                      content,
                      style: AppTextStyles.bodyMedium,
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
