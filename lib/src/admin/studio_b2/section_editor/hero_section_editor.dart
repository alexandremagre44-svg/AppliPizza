// lib/src/admin/studio_b2/section_editor/hero_section_editor.dart
// Editor for hero banner sections

import 'package:flutter/material.dart';

/// Editor for hero section data
class HeroSectionEditor extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;

  const HeroSectionEditor({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<HeroSectionEditor> createState() => _HeroSectionEditorState();
}

class _HeroSectionEditorState extends State<HeroSectionEditor> {
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _imageUrlController;
  late TextEditingController _ctaLabelController;
  late TextEditingController _ctaTargetController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data['title'] as String? ?? '');
    _subtitleController = TextEditingController(text: widget.data['subtitle'] as String? ?? '');
    _imageUrlController = TextEditingController(text: widget.data['imageUrl'] as String? ?? '');
    _ctaLabelController = TextEditingController(text: widget.data['ctaLabel'] as String? ?? '');
    _ctaTargetController = TextEditingController(text: widget.data['ctaTarget'] as String? ?? '');

    _titleController.addListener(_updateData);
    _subtitleController.addListener(_updateData);
    _imageUrlController.addListener(_updateData);
    _ctaLabelController.addListener(_updateData);
    _ctaTargetController.addListener(_updateData);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageUrlController.dispose();
    _ctaLabelController.dispose();
    _ctaTargetController.dispose();
    super.dispose();
  }

  void _updateData() {
    widget.onDataChanged({
      'title': _titleController.text,
      'subtitle': _subtitleController.text,
      'imageUrl': _imageUrlController.text,
      'ctaLabel': _ctaLabelController.text,
      'ctaTarget': _ctaTargetController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuration Hero Banner',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Titre',
            helperText: 'Titre principal de la bannière',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _subtitleController,
          decoration: const InputDecoration(
            labelText: 'Sous-titre',
            helperText: 'Texte secondaire',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: 'URL de l\'image',
            helperText: 'Laisser vide pour le gradient par défaut',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ctaLabelController,
          decoration: const InputDecoration(
            labelText: 'Texte du bouton',
            helperText: 'Label du bouton call-to-action',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ctaTargetController,
          decoration: const InputDecoration(
            labelText: 'Cible du bouton',
            helperText: 'Route de navigation (ex: menu, /products)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
