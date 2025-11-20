// lib/src/studio/widgets/modules/studio_settings_v2.dart
// Settings module V2 - Advanced Studio configuration

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/home_layout_config.dart';

class StudioSettingsV2 extends StatelessWidget {
  final HomeLayoutConfig? layoutConfig;
  final Function(HomeLayoutConfig) onUpdate;

  const StudioSettingsV2({
    super.key,
    required this.layoutConfig,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final config = layoutConfig ?? HomeLayoutConfig.defaultConfig();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres du Studio',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Configuration globale et ordre des sections',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Global toggle
          SwitchListTile(
            title: const Text('Activer le Studio globalement'),
            subtitle: const Text('Désactiver masque tous les éléments du Studio'),
            value: config.studioEnabled,
            onChanged: (value) {
              onUpdate(config.copyWith(studioEnabled: value));
            },
          ),
          const SizedBox(height: 24),

          // Section toggles
          const Text('Sections actives', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          ...config.sectionsOrder.map((section) {
            return SwitchListTile(
              title: Text(section.toUpperCase()),
              value: config.enabledSections[section] ?? false,
              onChanged: (value) {
                final newEnabledSections = Map<String, bool>.from(config.enabledSections);
                newEnabledSections[section] = value;
                onUpdate(config.copyWith(enabledSections: newEnabledSections));
              },
            );
          }),
        ],
      ),
    );
  }
}
