// lib/src/widgets/home/hero_banner.dart
// Hero banner for home page with image, title, subtitle and CTA button

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Hero banner widget for the home page
/// Displays a prominent banner with image, title, subtitle and CTA button
class HeroBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback? onPressed;
  final VoidCallback? onTap;
  final String? imageUrl;

  const HeroBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.onPressed,
    this.onTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      margin: AppSpacing.paddingHorizontalLG,
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusXL,
        boxShadow: AppShadows.medium,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusXL,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or gradient
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildGradientBackground();
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildGradientBackground();
                },
              )
            else
              _buildGradientBackground(),
            
            // Dark overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: AppSpacing.paddingXXL,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.surfaceWhite,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.surfaceWhite.withOpacity(0.95),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  ElevatedButton(
                    onPressed: onPressed ?? onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceWhite,
                      foregroundColor: AppColors.primaryRed,
                      padding: AppSpacing.buttonPadding,
                      elevation: 4,
                    ),
                    child: Text(buttonText),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryRed,
            AppColors.primaryRedDark,
          ],
        ),
      ),
    );
  }
}
