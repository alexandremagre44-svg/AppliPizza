// lib/src/screens/profile/widgets/roulette_card_widget.dart
// Roulette card for profile screen (Material 3)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/app_theme.dart';
import '../../../core/constants.dart';
import '../../../models/app_texts_config.dart';

/// Dedicated card for roulette access
/// Shows icon, configurable title/description, and CTA button
class RouletteCardWidget extends StatelessWidget {
  final RouletteTexts texts;
  final String userId;

  const RouletteCardWidget({
    super.key,
    required this.texts,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: () {
          // Navigate to roulette screen
          context.push('${AppRoutes.roulette}?userId=$userId');
        },
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.paddingLG,
          child: Column(
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber,
                      Colors.amber.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.casino,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: AppSpacing.lg),
              
              // Title
              Text(
                texts.playTitle,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              // Description
              Text(
                texts.playDescription,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: AppSpacing.lg),
              
              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('${AppRoutes.roulette}?userId=$userId');
                  },
                  icon: Icon(Icons.casino, size: 20),
                  label: Text(texts.playButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.sm + 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
