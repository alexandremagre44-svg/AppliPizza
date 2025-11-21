// lib/src/studio/widgets/modules/studio_settings_v2.dart
// Settings module V2 - Professional Studio configuration

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/home_layout_config.dart';

class StudioSettingsV2 extends StatefulWidget {
  final HomeLayoutConfig? layoutConfig;
  final Function(HomeLayoutConfig) onUpdate;

  const StudioSettingsV2({
    super.key,
    required this.layoutConfig,
    required this.onUpdate,
  });

  @override
  State<StudioSettingsV2> createState() => _StudioSettingsV2State();
}

class _StudioSettingsV2State extends State<StudioSettingsV2> {
  @override
  Widget build(BuildContext context) {
    final config = widget.layoutConfig ?? HomeLayoutConfig.defaultConfig();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Paramètres',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Configuration globale du Studio et ordre d\'affichage',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Global Studio Toggle
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.power_settings_new,
                      color: config.studioEnabled ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Studio Global',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                      value: config.studioEnabled,
                      onChanged: (value) {
                        widget.onUpdate(config.copyWith(studioEnabled: value));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  config.studioEnabled
                      ? 'Le Studio est activé. Les clients voient les éléments configurés.'
                      : 'Le Studio est désactivé. Tous les éléments sont masqués côté client.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Individual Section Toggles
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.view_module_outlined, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sections actives',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Contrôlez la visibilité de chaque section individuellement',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                ...config.sectionsOrder.map((section) {
                  final isEnabled = config.enabledSections[section] ?? false;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          _getIconForSection(section),
                          size: 20,
                          color: isEnabled ? AppColors.primary : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getLabelForSection(section),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: isEnabled,
                          onChanged: (value) {
                            final newEnabledSections = Map<String, bool>.from(config.enabledSections);
                            newEnabledSections[section] = value;
                            widget.onUpdate(config.copyWith(enabledSections: newEnabledSections));
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sections Order
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.reorder, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Ordre d\'affichage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Définissez l\'ordre d\'apparition des sections sur la page d\'accueil',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                ...List.generate(config.sectionsOrder.length, (index) {
                  final section = config.sectionsOrder[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(_getIconForSection(section), size: 18, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getLabelForSection(section),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                        // Move up button
                        IconButton(
                          icon: const Icon(Icons.arrow_upward, size: 18),
                          onPressed: index > 0
                              ? () => _moveSection(config, index, -1)
                              : null,
                        ),
                        // Move down button
                        IconButton(
                          icon: const Icon(Icons.arrow_downward, size: 18),
                          onPressed: index < config.sectionsOrder.length - 1
                              ? () => _moveSection(config, index, 1)
                              : null,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Les modifications prennent effet immédiatement après publication',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
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

  IconData _getIconForSection(String section) {
    switch (section.toLowerCase()) {
      case 'hero':
        return Icons.image_outlined;
      case 'banner':
      case 'banners':
        return Icons.notifications_outlined;
      case 'popups':
        return Icons.campaign_outlined;
      case 'categories':
        return Icons.grid_view_outlined;
      case 'bestsellers':
        return Icons.star_outline;
      case 'promotions':
        return Icons.local_offer_outlined;
      default:
        return Icons.view_module_outlined;
    }
  }

  String _getLabelForSection(String section) {
    switch (section.toLowerCase()) {
      case 'hero':
        return 'Section Hero';
      case 'banner':
      case 'banners':
        return 'Bandeaux d\'information';
      case 'popups':
        return 'Popups';
      case 'categories':
        return 'Catégories';
      case 'bestsellers':
        return 'Meilleures ventes';
      case 'promotions':
        return 'Promotions';
      default:
        return section.toUpperCase();
    }
  }

  void _moveSection(HomeLayoutConfig config, int index, int direction) {
    final newOrder = List<String>.from(config.sectionsOrder);
    final section = newOrder.removeAt(index);
    newOrder.insert(index + direction, section);
    widget.onUpdate(config.copyWith(sectionsOrder: newOrder));
  }
}
