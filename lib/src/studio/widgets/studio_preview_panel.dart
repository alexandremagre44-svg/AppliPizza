// lib/src/studio/widgets/studio_preview_panel.dart
// Real-time preview panel for Studio V2

import 'package:flutter/material.dart';
import '../../models/home_config.dart';
import '../../models/home_layout_config.dart';
import '../../models/banner_config.dart';
import '../models/text_block_model.dart';
import '../models/popup_v2_model.dart';

class StudioPreviewPanel extends StatelessWidget {
  final HomeConfig? homeConfig;
  final HomeLayoutConfig? layoutConfig;
  final List<BannerConfig> banners;
  final List<PopupV2Model> popupsV2;
  final List<TextBlockModel> textBlocks;

  const StudioPreviewPanel({
    super.key,
    this.homeConfig,
    this.layoutConfig,
    this.banners = const [],
    this.popupsV2 = const [],
    this.textBlocks = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.phone_iphone, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Prévisualisation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Phone frame
          Expanded(
            child: Center(
              child: Container(
                width: 375,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _buildPreviewContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (layoutConfig == null || !layoutConfig!.studioEnabled) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.visibility_off, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Studio désactivé',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Activez le Studio dans les paramètres',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        // App Bar
        Container(
          height: 56,
          color: const Color(0xFFD32F2F),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.menu, color: Colors.white),
              const SizedBox(width: 16),
              const Text(
                'Pizza Deli\'Zza',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Dynamic content based on layout order
        ...layoutConfig!.sectionsOrder.map((section) {
          if (!layoutConfig!.isSectionEnabled(section)) {
            return const SizedBox.shrink();
          }

          switch (section) {
            case 'hero':
              return _buildHeroPreview();
            case 'banner':
              return _buildBannersPreview();
            case 'popups':
              return _buildPopupsIndicator();
            default:
              return const SizedBox.shrink();
          }
        }).toList(),

        // Additional content
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Catégories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Mock category cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              4,
              (index) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildHeroPreview() {
    if (homeConfig == null || !homeConfig!.heroEnabled) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 200,
      color: Colors.grey[300],
      child: Stack(
        children: [
          if (homeConfig!.heroImageUrl != null)
            Image.network(
              homeConfig!.heroImageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[300]);
              },
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (homeConfig!.heroTitle.isNotEmpty)
                  Text(
                    homeConfig!.heroTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (homeConfig!.heroSubtitle.isNotEmpty)
                  Text(
                    homeConfig!.heroSubtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannersPreview() {
    final activeBanners = banners
        .where((b) => b.isCurrentlyActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (activeBanners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: activeBanners.map((banner) {
        final bgColor = _parseColor(banner.backgroundColor);
        final textColor = _parseColor(banner.textColor);
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: bgColor,
          child: Row(
            children: [
              if (banner.iconData != null) ...[
                Icon(banner.iconData, color: textColor, size: 16),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  banner.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPopupsIndicator() {
    final activePopups = popupsV2.where((p) => p.isCurrentlyActive).toList();
    
    if (activePopups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
          const SizedBox(width: 8),
          Text(
            '${activePopups.length} popup(s) actif(s)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}
