// lib/src/admin/studio_b2/preview_panel.dart
// Preview panel showing HomeScreenB2 in draft mode

import 'package:flutter/material.dart';
import '../../models/app_config.dart';
import '../../services/app_config_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/home/hero_banner.dart';
import '../../widgets/home/home_shimmer_loading.dart';

/// Preview panel for HomeScreenB2 in draft mode
/// 
/// Displays a live preview of how the home screen will look
/// with the current draft configuration
class PreviewPanel extends StatefulWidget {
  final String appId;

  const PreviewPanel({
    super.key,
    required this.appId,
  });

  @override
  State<PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends State<PreviewPanel> {
  final AppConfigService _configService = AppConfigService();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Preview header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Icon(Icons.phone_iphone, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Aperçu (brouillon)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DRAFT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Preview content
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Container(
                  width: 375,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: StreamBuilder<AppConfig?>(
                      stream: _configService.watchConfig(
                        appId: widget.appId,
                        draft: true,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const HomeShimmerLoading();
                        }

                        if (!snapshot.hasData || snapshot.data == null) {
                          return _buildNoPreview();
                        }

                        final config = snapshot.data!;
                        return _buildPreviewContent(config);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPreview() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_off,
            size: 48,
            color: AppColors.textLight,
          ),
          SizedBox(height: 16),
          Text(
            'Pas d\'aperçu disponible',
            style: TextStyle(color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(AppConfig config) {
    final home = config.home;
    
    // Sort and filter sections
    final sortedSections = List<HomeSectionConfig>.from(home.sections)
      ..sort((a, b) => a.order.compareTo(b.order));
    final activeSections = sortedSections.where((s) => s.active).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar simulation
          Container(
            height: 56,
            color: _parseColor(home.theme.primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const Row(
              children: [
                Text(
                  'Pizza Deli\'Zza B2',
                  style: TextStyle(
                    color: AppColors.surfaceWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Welcome header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  home.texts.welcomeTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  home.texts.welcomeSubtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          // Sections
          ...activeSections.map((section) => _buildSectionPreview(section, home.theme)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionPreview(HomeSectionConfig section, ThemeConfigV2 theme) {
    switch (section.type) {
      case HomeSectionType.hero:
        return _buildHeroPreview(section);
      case HomeSectionType.promoBanner:
        return _buildPromoBannerPreview(section);
      case HomeSectionType.popup:
        return const SizedBox.shrink();
      case HomeSectionType.productGrid:
      case HomeSectionType.categoryList:
      case HomeSectionType.custom:
      default:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${section.type.value} - ${section.id}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
          ),
        );
    }
  }

  Widget _buildHeroPreview(HomeSectionConfig section) {
    final data = section.data;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Transform.scale(
        scale: 0.9,
        child: HeroBanner(
          title: data['title'] as String? ?? '',
          subtitle: data['subtitle'] as String? ?? '',
          buttonText: data['ctaLabel'] as String? ?? '',
          imageUrl: (data['imageUrl'] as String? ?? '').isNotEmpty 
              ? data['imageUrl'] as String? 
              : null,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildPromoBannerPreview(HomeSectionConfig section) {
    final data = section.data;
    final text = data['text'] as String? ?? '';
    final backgroundColor = data['backgroundColor'] as String? ?? '#D62828';
    final textColor = data['textColor'] as String? ?? '#FFFFFF';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _parseColor(backgroundColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer,
            color: _parseColor(textColor),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _parseColor(textColor),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexString) {
    try {
      final hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      // Return default on error
    }
    return AppColors.primaryRed;
  }
}
