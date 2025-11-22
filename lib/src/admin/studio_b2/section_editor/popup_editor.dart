// lib/src/admin/studio_b2/section_editor/popup_editor.dart
// Editor for popup sections

import 'package:flutter/material.dart';

/// Editor for popup section data
class PopupEditor extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;

  const PopupEditor({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<PopupEditor> createState() => _PopupEditorState();
}

class _PopupEditorState extends State<PopupEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool _showOnAppStart;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.data['title'] as String? ?? '');
    _contentController = TextEditingController(text: widget.data['content'] as String? ?? '');
    _showOnAppStart = widget.data['showOnAppStart'] as bool? ?? true;

    _titleController.addListener(_updateData);
    _contentController.addListener(_updateData);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateData() {
    widget.onDataChanged({
      'title': _titleController.text,
      'content': _contentController.text,
      'showOnAppStart': _showOnAppStart,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuration Popup',
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
            helperText: 'Titre du popup',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contentController,
          decoration: const InputDecoration(
            labelText: 'Contenu',
            helperText: 'Message à afficher dans le popup',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Afficher au démarrage'),
          subtitle: const Text('Afficher le popup lorsque l\'app démarre'),
          value: _showOnAppStart,
          onChanged: (value) {
            setState(() {
              _showOnAppStart = value;
              _updateData();
            });
          },
        ),
      ],
    );
  }
}
