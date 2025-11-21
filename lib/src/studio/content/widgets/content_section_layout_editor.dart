// lib/src/studio/content/widgets/content_section_layout_editor.dart
// Widget for managing the global layout order of home sections

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../../../services/home_layout_service.dart';
import '../../../models/home_layout_config.dart';
import '../../../providers/home_layout_provider.dart';

class ContentSectionLayoutEditor extends ConsumerStatefulWidget {
  const ContentSectionLayoutEditor({super.key});

  @override
  ConsumerState<ContentSectionLayoutEditor> createState() => _ContentSectionLayoutEditorState();
}

class _ContentSectionLayoutEditorState extends ConsumerState<ContentSectionLayoutEditor> {
  final _homeLayoutService = HomeLayoutService();
  List<String> _sections = [];
  Map<String, bool> _enabledSections = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadLayout();
  }

  Future<void> _loadLayout() async {
    final layout = await _homeLayoutService.getHomeLayout();
    if (layout != null && mounted) {
      setState(() {
        _sections = List.from(layout.sectionsOrder);
        _enabledSections = Map.from(layout.enabledSections);
      });
    }
  }

  Future<void> _saveLayout() async {
    setState(() => _isSaving = true);
    try {
      final currentLayout = await _homeLayoutService.getHomeLayout() ?? 
          HomeLayoutConfig.defaultConfig();
      
      final updatedLayout = currentLayout.copyWith(
        sectionsOrder: _sections,
        enabledSections: _enabledSections,
        updatedAt: DateTime.now(),
      );

      await _homeLayoutService.updateHomeLayout(updatedLayout);
      ref.invalidate(homeLayoutProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Layout sauvegardé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _getSectionLabel(String key) {
    switch (key) {
      case 'hero':
        return 'Hero Banner';
      case 'banner':
        return 'Bandeau promotionnel';
      case 'popups':
        return 'Popups';
      case 'featured_products':
        return 'Produits mis en avant';
      case 'categories':
        return 'Catégories';
      default:
        if (key.startsWith('custom_')) {
          return 'Section: ${key.replaceFirst('custom_', '')}';
        }
        return key;
    }
  }

  IconData _getSectionIcon(String key) {
    switch (key) {
      case 'hero':
        return Icons.image_outlined;
      case 'banner':
        return Icons.notifications_outlined;
      case 'popups':
        return Icons.campaign_outlined;
      case 'featured_products':
        return Icons.star_outline;
      case 'categories':
        return Icons.category_outlined;
      default:
        return Icons.view_module_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          _buildInstructions(),
          Expanded(
            child: _buildSectionsList(),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Glissez-déposez les sections pour réorganiser l\'ordre d\'affichage. '
              'Activez/désactivez les sections avec les interrupteurs.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsList() {
    if (_sections.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sections.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _sections.removeAt(oldIndex);
          _sections.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final sectionKey = _sections[index];
        final isEnabled = _enabledSections[sectionKey] ?? true;

        return Card(
          key: ValueKey(sectionKey),
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSectionIcon(sectionKey),
                color: AppColors.primary,
              ),
            ),
            title: Text(
              _getSectionLabel(sectionKey),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text('Ordre: ${index + 1}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _enabledSections[sectionKey] = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.drag_handle),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _saveLayout,
          icon: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(_isSaving ? 'Sauvegarde...' : 'Sauvegarder le layout'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
