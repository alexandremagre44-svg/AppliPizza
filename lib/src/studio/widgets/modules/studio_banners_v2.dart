// lib/src/studio/widgets/modules/studio_banners_v2.dart
// Banners module V2 - Multi-banner CRUD with drag & drop

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/banner_config.dart';

class StudioBannersV2 extends StatelessWidget {
  final List<BannerConfig> banners;
  final Function(List<BannerConfig>) onUpdate;

  const StudioBannersV2({
    super.key,
    required this.banners,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bandeaux', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Gérez vos bandeaux programmables', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _addBanner(context),
                icon: const Icon(Icons.add),
                label: const Text('Nouveau bandeau'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (banners.isEmpty)
            const Center(child: Text('Aucun bandeau configuré'))
          else
            ...banners.map((banner) => _buildBannerCard(context, banner)),
        ],
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, BannerConfig banner) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(banner.iconData ?? Icons.campaign),
        title: Text(banner.text),
        trailing: Switch(
          value: banner.isEnabled,
          onChanged: (value) {
            final updated = banners.map((b) {
              return b.id == banner.id ? b.copyWith(isEnabled: value) : b;
            }).toList();
            onUpdate(updated);
          },
        ),
      ),
    );
  }

  void _addBanner(BuildContext context) {
    final newBanner = BannerConfig.defaultBanner(order: banners.length);
    onUpdate([...banners, newBanner]);
  }
}
