// lib/src/widgets/admin/admin_home_preview.dart
// Widget for live preview of home screen in admin studio

import 'package:flutter/material.dart';
import '../../models/home_config.dart';
import '../../models/app_texts_config.dart';
import '../../models/popup_config.dart';
import '../../design_system/app_theme.dart';
import '../home/hero_banner.dart';
import '../home/info_banner.dart';

/// Live preview of the home screen for admin editing
/// Shows how the home will look with current draft or published configuration
class AdminHomePreview extends StatelessWidget {
  final HomeConfig? homeConfig;
  final HomeTexts? homeTexts;
  final List<PopupConfig>? popups;
  final List<String>? sectionsOrder;
  final Map<String, bool>? enabledSections;
  final bool? studioEnabled;

  const AdminHomePreview({
    super.key,
    this.homeConfig,
    this.homeTexts,
    this.popups,
    this.sectionsOrder,
    this.enabledSections,
    this.studioEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline, width: 2),
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceContainerLow,
      ),
      child: Column(
        children: [
          // Preview Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_iphone, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Prévisualisation',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                if (studioEnabled == false)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Studio désactivé',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onErrorContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Preview Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildPreviewContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    // If studio is globally disabled, show empty state
    if (studioEnabled == false) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off, size: 48, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Studio désactivé',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les éléments Hero, Bandeau et Popups\nne seront pas affichés côté client',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Build sections in order
    final orderedSections = sectionsOrder ?? ['hero', 'banner', 'popups'];
    final enabled = enabledSections ?? {'hero': true, 'banner': true, 'popups': true};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryRed,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        homeTexts?.appName ?? 'Pizza Deli\'Zza',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        homeTexts?.slogan ?? 'À emporter uniquement',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dynamic sections based on order and enabled state
          ...orderedSections.map((section) {
            if (enabled[section] != true) return const SizedBox.shrink();
            
            switch (section) {
              case 'hero':
                return _buildHeroPreview();
              case 'banner':
                return _buildBannerPreview();
              case 'popups':
                return _buildPopupsPreview();
              default:
                return const SizedBox.shrink();
            }
          }).toList(),

          // Placeholder for rest of content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nos catégories',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Sections de contenu...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPreview() {
    if (homeConfig?.hero == null || homeConfig!.hero!.isActive == false) {
      return const SizedBox.shrink();
    }

    final hero = homeConfig!.hero!;
    return Container(
      margin: const EdgeInsets.all(12),
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        image: hero.imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(hero.imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hero.title.isNotEmpty)
              Text(
                hero.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (hero.subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                hero.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBannerPreview() {
    if (homeConfig?.promoBanner == null || !homeConfig!.promoBanner!.isCurrentlyActive) {
      return const SizedBox.shrink();
    }

    final banner = homeConfig!.promoBanner!;
    Color bgColor = AppColors.primaryRed;
    Color textColor = Colors.white;

    if (banner.backgroundColor != null) {
      final colorValue = ColorConverter.hexToColor(banner.backgroundColor);
      if (colorValue != null) {
        bgColor = Color(colorValue);
      }
    }

    if (banner.textColor != null) {
      final colorValue = ColorConverter.hexToColor(banner.textColor);
      if (colorValue != null) {
        textColor = Color(colorValue);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.campaign, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              banner.text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupsPreview() {
    if (popups == null || popups!.isEmpty) {
      return const SizedBox.shrink();
    }

    final activePopups = popups!.where((p) => p.isCurrentlyActive).toList();
    if (activePopups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tertiary, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active, color: AppColors.onTertiaryContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${activePopups.length} popup(s) actif(s)',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
