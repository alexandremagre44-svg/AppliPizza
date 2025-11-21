// lib/src/studio/widgets/studio_preview_panel_v2.dart
// Improved preview panel for Studio V2 - displays real HomeScreen with draft data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/home_config.dart';
import '../../models/home_layout_config.dart';
import '../../models/banner_config.dart';
import '../../providers/home_config_provider.dart';
import '../../providers/home_layout_provider.dart';
import '../models/text_block_model.dart';
import '../models/popup_v2_model.dart';
import '../../screens/home/home_screen.dart';
import '../providers/banner_provider.dart';
import '../providers/popup_v2_provider.dart';
import '../providers/text_block_provider.dart';

/// Preview panel for Studio V2 that displays the REAL HomeScreen
/// with draft configuration using provider overrides
class StudioPreviewPanelV2 extends StatelessWidget {
  final HomeConfig? homeConfig;
  final HomeLayoutConfig? layoutConfig;
  final List<BannerConfig> banners;
  final List<PopupV2Model> popupsV2;
  final List<TextBlockModel> textBlocks;

  const StudioPreviewPanelV2({
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
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      size: 12,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Mode brouillon',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rendu 1:1 de HomeScreen avec vos modifications',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          
          // Phone frame with real HomeScreen
          Expanded(
            child: Center(
              child: Container(
                width: 375,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 200,
                ),
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
                  child: _buildPreviewContent(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(BuildContext context) {
    // Create provider overrides to inject draft data
    final overrides = <Override>[];

    // Override homeConfigProvider with draft data
    if (homeConfig != null) {
      overrides.add(
        homeConfigProvider.overrideWith((ref) {
          return Stream.value(homeConfig);
        }),
      );
    }

    // Override homeLayoutProvider with draft data
    if (layoutConfig != null) {
      overrides.add(
        homeLayoutProvider.overrideWith((ref) {
          return Stream.value(layoutConfig);
        }),
      );
    }

    // Override bannersProvider with draft data
    overrides.add(
      bannersProvider.overrideWith((ref) {
        return Stream.value(banners);
      }),
    );
    overrides.add(
      activeBannersProvider.overrideWith((ref) {
        return Stream.value(
          banners.where((b) => b.isCurrentlyActive).toList(),
        );
      }),
    );

    // Override popupsV2Provider with draft data
    overrides.add(
      popupsV2Provider.overrideWith((ref) {
        return Stream.value(popupsV2);
      }),
    );
    overrides.add(
      activePopupsV2Provider.overrideWith((ref) {
        return Stream.value(
          popupsV2
              .where((p) => p.isCurrentlyActive)
              .toList()
            ..sort((a, b) => b.priority.compareTo(a.priority)),
        );
      }),
    );

    // Override textBlocksProvider with draft data
    overrides.add(
      textBlocksProvider.overrideWith((ref) {
        return Stream.value(textBlocks);
      }),
    );
    overrides.add(
      enabledTextBlocksProvider.overrideWith((ref) {
        return Stream.value(
          textBlocks.where((b) => b.isEnabled).toList(),
        );
      }),
    );

    // Wrap HomeScreen with ProviderScope to inject draft data
    return ProviderScope(
      overrides: overrides,
      child: const HomeScreen(),
    );
  }
}
