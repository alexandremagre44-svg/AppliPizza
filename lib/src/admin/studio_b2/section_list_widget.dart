// lib/src/admin/studio_b2/section_list_widget.dart
// Widget for displaying and managing sections list with drag & drop

import 'package:flutter/material.dart';
import '../../models/app_config.dart';
import '../../theme/app_theme.dart';
import 'section_editor/section_editor_dialog.dart';

/// Widget for managing home sections
/// 
/// Features:
/// - Reorderable list with drag & drop
/// - Add new section
/// - Edit existing section
/// - Toggle section active state
/// - Delete section
class SectionListWidget extends StatefulWidget {
  final AppConfig config;
  final String appId;
  final Function(AppConfig) onConfigUpdated;

  const SectionListWidget({
    super.key,
    required this.config,
    required this.appId,
    required this.onConfigUpdated,
  });

  @override
  State<SectionListWidget> createState() => _SectionListWidgetState();
}

class _SectionListWidgetState extends State<SectionListWidget> {
  List<HomeSectionConfig> _sections = [];

  @override
  void initState() {
    super.initState();
    _sections = List.from(widget.config.home.sections);
  }

  @override
  void didUpdateWidget(SectionListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config.home.sections != oldWidget.config.home.sections) {
      _sections = List.from(widget.config.home.sections);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with add button
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surfaceWhite,
          child: Row(
            children: [
              const Text(
                'Sections de l\'accueil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _handleAddSection,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une section'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Sections list
        Expanded(
          child: _sections.isEmpty
              ? _buildEmptyState()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sections.length,
                  onReorder: _handleReorder,
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    return _buildSectionCard(section, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.view_module_outlined,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune section',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez une section pour commencer',
            style: TextStyle(color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(HomeSectionConfig section, int index) {
    return Card(
      key: ValueKey(section.id),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const Icon(Icons.drag_indicator, color: AppColors.textMedium),
            const SizedBox(width: 8),
            // Section type icon
            _getSectionIcon(section.type),
          ],
        ),
        title: Text(
          section.id,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${section.type.value} • Ordre: ${section.order}',
          style: const TextStyle(fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Active toggle
            Switch(
              value: section.active,
              onChanged: (value) => _handleToggleActive(section, value),
              activeColor: AppColors.successGreen,
            ),
            const SizedBox(width: 8),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryRed),
              onPressed: () => _handleEditSection(section),
              tooltip: 'Éditer',
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.errorRed),
              onPressed: () => _handleDeleteSection(section),
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSectionIcon(HomeSectionType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case HomeSectionType.hero:
        iconData = Icons.photo_size_select_actual;
        color = Colors.blue;
        break;
      case HomeSectionType.promoBanner:
        iconData = Icons.campaign;
        color = Colors.orange;
        break;
      case HomeSectionType.popup:
        iconData = Icons.notifications_active;
        color = Colors.purple;
        break;
      case HomeSectionType.productGrid:
        iconData = Icons.grid_view;
        color = Colors.green;
        break;
      case HomeSectionType.categoryList:
        iconData = Icons.category;
        color = Colors.teal;
        break;
      case HomeSectionType.custom:
      default:
        iconData = Icons.extension;
        color = Colors.grey;
        break;
    }

    return Icon(iconData, color: color, size: 28);
  }

  void _handleReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final section = _sections.removeAt(oldIndex);
      _sections.insert(newIndex, section);

      // Update order values
      for (int i = 0; i < _sections.length; i++) {
        _sections[i] = _sections[i].copyWith(order: i + 1);
      }

      _saveConfig();
    });
  }

  void _handleToggleActive(HomeSectionConfig section, bool value) {
    setState(() {
      final index = _sections.indexWhere((s) => s.id == section.id);
      if (index != -1) {
        _sections[index] = section.copyWith(active: value);
        _saveConfig();
      }
    });
  }

  void _handleAddSection() {
    showDialog(
      context: context,
      builder: (context) => SectionEditorDialog(
        onSave: (newSection) {
          setState(() {
            _sections.add(newSection);
            _saveConfig();
          });
        },
      ),
    );
  }

  void _handleEditSection(HomeSectionConfig section) {
    showDialog(
      context: context,
      builder: (context) => SectionEditorDialog(
        section: section,
        onSave: (updatedSection) {
          setState(() {
            final index = _sections.indexWhere((s) => s.id == section.id);
            if (index != -1) {
              _sections[index] = updatedSection;
              _saveConfig();
            }
          });
        },
      ),
    );
  }

  void _handleDeleteSection(HomeSectionConfig section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la section'),
        content: Text('Voulez-vous vraiment supprimer la section "${section.id}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _sections.removeWhere((s) => s.id == section.id);
                _saveConfig();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _saveConfig() {
    final updatedConfig = widget.config.copyWith(
      home: widget.config.home.copyWith(
        sections: _sections,
      ),
    );
    widget.onConfigUpdated(updatedConfig);
  }
}
