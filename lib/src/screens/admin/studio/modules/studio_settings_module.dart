// lib/src/screens/admin/studio/modules/studio_settings_module.dart
// Settings module - Studio activation + layout settings + category management

import 'package:flutter/material.dart';
import '../../../../design_system/app_theme.dart';
import '../../../../models/home_layout_config.dart';

class StudioSettingsModule extends StatefulWidget {
  final HomeLayoutConfig? draftLayoutConfig;
  final Function(HomeLayoutConfig) onUpdate;

  const StudioSettingsModule({
    super.key,
    required this.draftLayoutConfig,
    required this.onUpdate,
  });

  @override
  State<StudioSettingsModule> createState() => _StudioSettingsModuleState();
}

class _StudioSettingsModuleState extends State<StudioSettingsModule> {
  void _updateStudioEnabled(bool enabled) {
    final updated = widget.draftLayoutConfig?.copyWith(studioEnabled: enabled) ??
        HomeLayoutConfig.defaultConfig().copyWith(studioEnabled: enabled);
    widget.onUpdate(updated);
  }

  void _updateSectionsOrder(List<String> newOrder) {
    final updated = widget.draftLayoutConfig?.copyWith(sectionsOrder: newOrder) ??
        HomeLayoutConfig.defaultConfig().copyWith(sectionsOrder: newOrder);
    widget.onUpdate(updated);
  }

  void _updateSectionEnabled(String section, bool enabled) {
    final currentEnabled = Map<String, bool>.from(widget.draftLayoutConfig?.enabledSections ?? {});
    currentEnabled[section] = enabled;
    
    final updated = widget.draftLayoutConfig?.copyWith(enabledSections: currentEnabled) ??
        HomeLayoutConfig.defaultConfig().copyWith(enabledSections: currentEnabled);
    widget.onUpdate(updated);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Module Paramètres', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Configuration globale du Studio et de la mise en page',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildStudioToggle(),
          const SizedBox(height: 24),
          _buildLayoutSettings(),
          const SizedBox(height: 24),
          _buildSectionsOrderEditor(),
        ],
      ),
    );
  }

  Widget _buildStudioToggle() {
    final studioEnabled = widget.draftLayoutConfig?.studioEnabled ?? true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A. Activation du Studio', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Studio activé'),
              subtitle: Text(
                studioEnabled
                    ? 'Les éléments Hero, Bandeaux et Popups sont visibles côté client'
                    : 'Tous les éléments sont masqués côté client',
                style: TextStyle(
                  color: studioEnabled ? AppColors.success : AppColors.error,
                ),
              ),
              value: studioEnabled,
              onChanged: _updateStudioEnabled,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Impact de la désactivation',
                          style: AppTextStyles.labelMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Le Hero ne sera pas affiché sur l\'écran d\'accueil\n'
                    '• Les bandeaux promotionnels seront masqués\n'
                    '• Les popups ne s\'afficheront pas\n'
                    '• Les configurations restent sauvegardées et peuvent être réactivées à tout moment',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('B. Paramètres généraux du layout', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.view_module),
              title: const Text('Organisation des sections'),
              subtitle: const Text('Gérez l\'ordre et la visibilité des sections ci-dessous'),
              trailing: const Icon(Icons.arrow_downward),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsOrderEditor() {
    final sections = widget.draftLayoutConfig?.sectionsOrder ?? ['hero', 'banner', 'popups'];
    final enabled = widget.draftLayoutConfig?.enabledSections ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('C. Ordre et visibilité des sections', style: AppTextStyles.titleMedium),
                ),
                Icon(
                  Icons.drag_handle,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Glissez pour réorganiser',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                final newSections = List<String>.from(sections);
                if (newIndex > oldIndex) newIndex--;
                final item = newSections.removeAt(oldIndex);
                newSections.insert(newIndex, item);
                _updateSectionsOrder(newSections);
              },
              children: sections.map((section) {
                final sectionTitle = _getSectionTitle(section);
                final sectionIcon = _getSectionIcon(section);
                final isEnabled = enabled[section] ?? false;

                return Card(
                  key: ValueKey(section),
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isEnabled ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                  child: ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.drag_handle),
                        const SizedBox(width: 8),
                        Icon(
                          sectionIcon,
                          color: isEnabled ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                    title: Text(
                      sectionTitle,
                      style: TextStyle(
                        color: isEnabled ? AppColors.primary : AppColors.onSurface,
                        fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      isEnabled ? 'Visible sur l\'écran d\'accueil' : 'Masqué',
                      style: TextStyle(
                        color: isEnabled ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                    ),
                    trailing: Switch(
                      value: isEnabled,
                      onChanged: (value) => _updateSectionEnabled(section, value),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.onTertiaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'L\'ordre des sections définit leur position sur l\'écran d\'accueil. '
                      'Les sections désactivées ne seront pas affichées.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSectionTitle(String section) {
    switch (section) {
      case 'hero':
        return 'Hero Banner';
      case 'banner':
        return 'Bandeaux promotionnels';
      case 'popups':
        return 'Popups et notifications';
      default:
        return section;
    }
  }

  IconData _getSectionIcon(String section) {
    switch (section) {
      case 'hero':
        return Icons.image;
      case 'banner':
        return Icons.flag;
      case 'popups':
        return Icons.campaign;
      default:
        return Icons.widgets;
    }
  }
}

