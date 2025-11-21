// lib/src/studio/content/widgets/content_custom_sections.dart
// Widget for managing custom sections on home screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../models/content_section_model.dart';
import '../services/content_section_service.dart';
import '../providers/content_providers.dart';

class ContentCustomSections extends ConsumerStatefulWidget {
  const ContentCustomSections({super.key});

  @override
  ConsumerState<ContentCustomSections> createState() => _ContentCustomSectionsState();
}

class _ContentCustomSectionsState extends ConsumerState<ContentCustomSections> {
  final _sectionService = ContentSectionService();
  List<ContentSection> _sections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  Future<void> _loadSections() async {
    setState(() => _isLoading = true);
    try {
      final sections = await _sectionService.getAllSections();
      if (mounted) {
        setState(() {
          _sections = sections;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => _SectionEditorDialog(
        onConfirm: (section) async {
          try {
            await _sectionService.createSection(section);
            ref.invalidate(customSectionsProvider);
            _loadSections();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Section créée avec succès'),
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
          }
        },
      ),
    );
  }

  void _showEditDialog(ContentSection section) {
    showDialog(
      context: context,
      builder: (context) => _SectionEditorDialog(
        section: section,
        onConfirm: (updatedSection) async {
          try {
            await _sectionService.updateSection(updatedSection);
            ref.invalidate(customSectionsProvider);
            _loadSections();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Section mise à jour avec succès'),
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
          }
        },
      ),
    );
  }

  Future<void> _deleteSection(ContentSection section) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer la section "${section.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _sectionService.deleteSection(section.id);
        ref.invalidate(customSectionsProvider);
        _loadSections();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Section supprimée avec succès'),
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _sections.isEmpty ? _buildEmptyState() : _buildSectionsList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sections personnalisées',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Créez des sections thématiques pour votre page d\'accueil',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle section'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
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
          Icon(Icons.view_module_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Aucune section personnalisée',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Créez votre première section pour commencer',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text('Créer une section'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsList() {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sections.length,
      onReorder: (oldIndex, newIndex) async {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _sections.removeAt(oldIndex);
          _sections.insert(newIndex, item);
        });

        try {
          await _sectionService.updateSectionsOrder(_sections);
          ref.invalidate(customSectionsProvider);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      itemBuilder: (context, index) {
        final section = _sections[index];
        
        return Card(
          key: ValueKey(section.id),
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: section.isActive
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getSectionIcon(section.displayType),
                color: section.isActive ? AppColors.primary : Colors.grey,
                size: 28,
              ),
            ),
            title: Text(
              section.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: section.isActive ? Colors.black : Colors.grey,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(section.subtitle ?? 'Aucun sous-titre'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getDisplayTypeLabel(section.displayType),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getContentModeLabel(section.contentMode),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: section.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    section.isActive ? 'Actif' : 'Inactif',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: section.isActive
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        Duration.zero,
                        () => _showEditDialog(section),
                      ),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            section.isActive ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(section.isActive ? 'Désactiver' : 'Activer'),
                        ],
                      ),
                      onTap: () async {
                        try {
                          await _sectionService.toggleSectionActive(
                            section.id,
                            !section.isActive,
                          );
                          ref.invalidate(customSectionsProvider);
                          _loadSections();
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        Duration.zero,
                        () => _deleteSection(section),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.drag_handle, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getSectionIcon(SectionDisplayType type) {
    switch (type) {
      case SectionDisplayType.carousel:
        return Icons.view_carousel_outlined;
      case SectionDisplayType.grid:
        return Icons.grid_view_outlined;
      case SectionDisplayType.largeBanner:
        return Icons.image_outlined;
    }
  }

  String _getDisplayTypeLabel(SectionDisplayType type) {
    switch (type) {
      case SectionDisplayType.carousel:
        return 'Carrousel';
      case SectionDisplayType.grid:
        return 'Grille';
      case SectionDisplayType.largeBanner:
        return 'Grande bannière';
    }
  }

  String _getContentModeLabel(SectionContentMode mode) {
    switch (mode) {
      case SectionContentMode.manual:
        return 'Manuel';
      case SectionContentMode.auto:
        return 'Automatique';
    }
  }
}

class _SectionEditorDialog extends StatefulWidget {
  final ContentSection? section;
  final Function(ContentSection) onConfirm;

  const _SectionEditorDialog({
    this.section,
    required this.onConfirm,
  });

  @override
  State<_SectionEditorDialog> createState() => _SectionEditorDialogState();
}

class _SectionEditorDialogState extends State<_SectionEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late SectionDisplayType _displayType;
  late SectionContentMode _contentMode;
  SectionAutoSortType? _autoSortType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section?.title ?? '');
    _subtitleController = TextEditingController(text: widget.section?.subtitle ?? '');
    _displayType = widget.section?.displayType ?? SectionDisplayType.carousel;
    _contentMode = widget.section?.contentMode ?? SectionContentMode.manual;
    _autoSortType = widget.section?.autoSortType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.section == null ? 'Nouvelle section' : 'Modifier la section'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Sous-titre (optionnel)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SectionDisplayType>(
              value: _displayType,
              decoration: const InputDecoration(
                labelText: 'Type d\'affichage',
                border: OutlineInputBorder(),
              ),
              items: SectionDisplayType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getDisplayTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _displayType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SectionContentMode>(
              value: _contentMode,
              decoration: const InputDecoration(
                labelText: 'Mode de contenu',
                border: OutlineInputBorder(),
              ),
              items: SectionContentMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(_getContentModeLabel(mode)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _contentMode = value!;
                  if (_contentMode == SectionContentMode.manual) {
                    _autoSortType = null;
                  } else {
                    _autoSortType = SectionAutoSortType.bestSeller;
                  }
                });
              },
            ),
            if (_contentMode == SectionContentMode.auto) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<SectionAutoSortType>(
                value: _autoSortType ?? SectionAutoSortType.bestSeller,
                decoration: const InputDecoration(
                  labelText: 'Tri automatique',
                  border: OutlineInputBorder(),
                ),
                items: SectionAutoSortType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getAutoSortTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _autoSortType = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (_titleController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Le titre est requis'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final section = ContentSection(
              id: widget.section?.id ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
              title: _titleController.text,
              subtitle: _subtitleController.text.isEmpty ? null : _subtitleController.text,
              displayType: _displayType,
              contentMode: _contentMode,
              autoSortType: _autoSortType,
              productIds: widget.section?.productIds ?? [],
              isActive: widget.section?.isActive ?? true,
              order: widget.section?.order ?? 0,
              createdAt: widget.section?.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
            );

            widget.onConfirm(section);
            Navigator.pop(context);
          },
          child: const Text('Confirmer'),
        ),
      ],
    );
  }

  String _getDisplayTypeLabel(SectionDisplayType type) {
    switch (type) {
      case SectionDisplayType.carousel:
        return 'Carrousel';
      case SectionDisplayType.grid:
        return 'Grille';
      case SectionDisplayType.largeBanner:
        return 'Grande bannière';
    }
  }

  String _getContentModeLabel(SectionContentMode mode) {
    switch (mode) {
      case SectionContentMode.manual:
        return 'Manuel';
      case SectionContentMode.auto:
        return 'Automatique';
    }
  }

  String _getAutoSortTypeLabel(SectionAutoSortType type) {
    switch (type) {
      case SectionAutoSortType.bestSeller:
        return 'Meilleures ventes';
      case SectionAutoSortType.price:
        return 'Prix';
      case SectionAutoSortType.newest:
        return 'Nouveautés';
      case SectionAutoSortType.promo:
        return 'Promotions';
    }
  }
}
