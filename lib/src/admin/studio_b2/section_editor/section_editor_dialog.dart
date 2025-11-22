// lib/src/admin/studio_b2/section_editor/section_editor_dialog.dart
// Dialog for creating and editing sections

import 'package:flutter/material.dart';
import '../../../models/app_config.dart';
import '../../../theme/app_theme.dart';
import 'hero_section_editor.dart';
import 'promo_banner_editor.dart';
import 'popup_editor.dart';

/// Dialog for editing or creating a section
class SectionEditorDialog extends StatefulWidget {
  final HomeSectionConfig? section;
  final Function(HomeSectionConfig) onSave;

  const SectionEditorDialog({
    super.key,
    this.section,
    required this.onSave,
  });

  @override
  State<SectionEditorDialog> createState() => _SectionEditorDialogState();
}

class _SectionEditorDialogState extends State<SectionEditorDialog> {
  late TextEditingController _idController;
  late HomeSectionType _selectedType;
  late bool _active;
  late int _order;
  Map<String, dynamic> _data = {};

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.section?.id ?? '');
    _selectedType = widget.section?.type ?? HomeSectionType.hero;
    _active = widget.section?.active ?? true;
    _order = widget.section?.order ?? 1;
    _data = Map.from(widget.section?.data ?? {});
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primaryRed,
              child: Row(
                children: [
                  Text(
                    widget.section == null ? 'Nouvelle section' : 'Éditer la section',
                    style: const TextStyle(
                      color: AppColors.surfaceWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.surfaceWhite),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID field
                    TextField(
                      controller: _idController,
                      decoration: const InputDecoration(
                        labelText: 'ID de la section',
                        helperText: 'Identifiant unique (ex: hero_1, banner_promo)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Type selector
                    DropdownButtonFormField<HomeSectionType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type de section',
                        border: OutlineInputBorder(),
                      ),
                      items: HomeSectionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getSectionTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                            _data = {}; // Reset data when type changes
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Order field
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ordre d\'affichage',
                        helperText: 'Plus petit = plus haut',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: _order.toString()),
                      onChanged: (value) {
                        _order = int.tryParse(value) ?? 1;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Active toggle
                    SwitchListTile(
                      title: const Text('Section active'),
                      subtitle: const Text('Afficher cette section sur l\'écran d\'accueil'),
                      value: _active,
                      onChanged: (value) {
                        setState(() {
                          _active = value;
                        });
                      },
                    ),
                    const Divider(height: 32),
                    // Section-specific editor
                    _buildSectionEditor(),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                    ),
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionEditor() {
    switch (_selectedType) {
      case HomeSectionType.hero:
        return HeroSectionEditor(
          data: _data,
          onDataChanged: (newData) {
            setState(() {
              _data = newData;
            });
          },
        );
      case HomeSectionType.promoBanner:
        return PromoBannerEditor(
          data: _data,
          onDataChanged: (newData) {
            setState(() {
              _data = newData;
            });
          },
        );
      case HomeSectionType.popup:
        return PopupEditor(
          data: _data,
          onDataChanged: (newData) {
            setState(() {
              _data = newData;
            });
          },
        );
      case HomeSectionType.productGrid:
      case HomeSectionType.categoryList:
      case HomeSectionType.custom:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Éditeur pour ${_getSectionTypeLabel(_selectedType)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cet éditeur n\'est pas encore implémenté.',
              style: TextStyle(color: AppColors.textMedium),
            ),
          ],
        );
    }
  }

  String _getSectionTypeLabel(HomeSectionType type) {
    switch (type) {
      case HomeSectionType.hero:
        return 'Hero Banner';
      case HomeSectionType.promoBanner:
        return 'Bannière Promo';
      case HomeSectionType.popup:
        return 'Popup';
      case HomeSectionType.productGrid:
        return 'Grille de Produits';
      case HomeSectionType.categoryList:
        return 'Liste de Catégories';
      case HomeSectionType.custom:
        return 'Section Personnalisée';
    }
  }

  void _handleSave() {
    if (_idController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'ID de la section est requis'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final section = HomeSectionConfig(
      id: _idController.text.trim(),
      type: _selectedType,
      order: _order,
      active: _active,
      data: _data,
    );

    widget.onSave(section);
    Navigator.pop(context);
  }
}
