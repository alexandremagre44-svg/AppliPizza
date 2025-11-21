// lib/src/studio/widgets/modules/studio_sections_v3.dart
// Dynamic Sections Builder PRO - Module 1

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../models/dynamic_section_model.dart';
import 'section_editor_dialog.dart';

class StudioSectionsV3 extends StatefulWidget {
  final List<DynamicSection> sections;
  final Function(List<DynamicSection>) onUpdate;

  const StudioSectionsV3({
    super.key,
    required this.sections,
    required this.onUpdate,
  });

  @override
  State<StudioSectionsV3> createState() => _StudioSectionsV3State();
}

class _StudioSectionsV3State extends State<StudioSectionsV3> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _buildHeader(),
        
        // Sections list
        Expanded(
          child: widget.sections.isEmpty
              ? _buildEmptyState()
              : _buildSectionsList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.view_module_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sections Dynamiques PRO',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Créez et gérez vos sections dynamiques avec conditions avancées',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: _showCreateSectionDialog,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Nouvelle section'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.view_module_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune section dynamique',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre première section pour commencer',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showCreateSectionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Créer une section'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: widget.sections.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        final section = widget.sections[index];
        return _buildSectionCard(section, index, key: ValueKey(section.id));
      },
    );
  }

  Widget _buildSectionCard(DynamicSection section, int index, {required Key key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      child: InkWell(
        onTap: () => _editSection(section),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.drag_indicator,
                    color: Color(0xFF9E9E9E),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Section icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSectionColor(section.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getSectionIcon(section.type),
                  color: _getSectionColor(section.type),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Section info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getSectionTypeName(section.type),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            section.layout.value.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSectionDescription(section),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Active toggle
                  Switch(
                    value: section.active,
                    onChanged: (value) => _toggleActive(section, value),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  
                  // Duplicate button
                  IconButton(
                    onPressed: () => _duplicateSection(section),
                    icon: const Icon(Icons.content_copy),
                    tooltip: 'Dupliquer',
                    iconSize: 20,
                  ),
                  
                  // Delete button
                  IconButton(
                    onPressed: () => _deleteSection(section),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Supprimer',
                    iconSize: 20,
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      
      final sections = List<DynamicSection>.from(widget.sections);
      final item = sections.removeAt(oldIndex);
      sections.insert(newIndex, item);
      
      // Update order values
      for (var i = 0; i < sections.length; i++) {
        sections[i] = sections[i].copyWith(order: i);
      }
      
      widget.onUpdate(sections);
    });
  }

  void _toggleActive(DynamicSection section, bool value) {
    final updatedSections = widget.sections.map((s) {
      if (s.id == section.id) {
        return s.copyWith(active: value);
      }
      return s;
    }).toList();
    
    widget.onUpdate(updatedSections);
  }

  void _duplicateSection(DynamicSection section) {
    final duplicated = section.duplicate();
    final updatedSections = List<DynamicSection>.from(widget.sections)
      ..add(duplicated);
    
    widget.onUpdate(updatedSections);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Section dupliquée'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteSection(DynamicSection section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la section ?'),
        content: const Text(
          'Cette action est irréversible. Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              final updatedSections = widget.sections
                  .where((s) => s.id != section.id)
                  .toList();
              
              widget.onUpdate(updatedSections);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Section supprimée'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _editSection(DynamicSection section) {
    showDialog(
      context: context,
      builder: (context) => SectionEditorDialog(
        section: section,
        onSave: (updatedSection) {
          final updatedSections = widget.sections.map((s) {
            if (s.id == section.id) {
              return updatedSection;
            }
            return s;
          }).toList();
          
          widget.onUpdate(updatedSections);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Section mise à jour'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showCreateSectionDialog() {
    showDialog(
      context: context,
      builder: (context) => SectionEditorDialog(
        onSave: (newSection) {
          final updatedSections = List<DynamicSection>.from(widget.sections)
            ..add(newSection);
          
          widget.onUpdate(updatedSections);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Section créée'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  IconData _getSectionIcon(DynamicSectionType type) {
    switch (type) {
      case DynamicSectionType.hero:
        return Icons.landscape;
      case DynamicSectionType.promoSimple:
      case DynamicSectionType.promoAdvanced:
        return Icons.local_offer;
      case DynamicSectionType.text:
        return Icons.text_fields;
      case DynamicSectionType.image:
        return Icons.image;
      case DynamicSectionType.grid:
        return Icons.grid_view;
      case DynamicSectionType.carousel:
        return Icons.view_carousel;
      case DynamicSectionType.categories:
        return Icons.category;
      case DynamicSectionType.products:
        return Icons.shopping_bag;
      case DynamicSectionType.freeLayout:
        return Icons.dashboard_customize;
    }
  }

  Color _getSectionColor(DynamicSectionType type) {
    switch (type) {
      case DynamicSectionType.hero:
        return Colors.purple;
      case DynamicSectionType.promoSimple:
      case DynamicSectionType.promoAdvanced:
        return Colors.orange;
      case DynamicSectionType.text:
        return Colors.blue;
      case DynamicSectionType.image:
        return Colors.green;
      case DynamicSectionType.grid:
        return Colors.teal;
      case DynamicSectionType.carousel:
        return Colors.pink;
      case DynamicSectionType.categories:
        return Colors.indigo;
      case DynamicSectionType.products:
        return Colors.red;
      case DynamicSectionType.freeLayout:
        return Colors.amber;
    }
  }

  String _getSectionTypeName(DynamicSectionType type) {
    switch (type) {
      case DynamicSectionType.hero:
        return 'Hero';
      case DynamicSectionType.promoSimple:
        return 'Promo Simple';
      case DynamicSectionType.promoAdvanced:
        return 'Promo Avancée';
      case DynamicSectionType.text:
        return 'Bloc Texte';
      case DynamicSectionType.image:
        return 'Bloc Image';
      case DynamicSectionType.grid:
        return 'Grille';
      case DynamicSectionType.carousel:
        return 'Carrousel';
      case DynamicSectionType.categories:
        return 'Catégories';
      case DynamicSectionType.products:
        return 'Produits';
      case DynamicSectionType.freeLayout:
        return 'Layout Libre';
    }
  }

  String _getSectionDescription(DynamicSection section) {
    if (section.content.containsKey('title') && section.content['title'] != null) {
      return section.content['title'] as String? ?? '';
    }
    if (section.content.containsKey('text') && section.content['text'] != null) {
      return section.content['text'] as String? ?? '';
    }
    return 'Section ${_getSectionTypeName(section.type)}';
  }
}
