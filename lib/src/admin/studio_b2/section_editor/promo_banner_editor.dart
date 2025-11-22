// lib/src/admin/studio_b2/section_editor/promo_banner_editor.dart
// Editor for promotional banner sections

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

/// Editor for promo banner section data
class PromoBannerEditor extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onDataChanged;

  const PromoBannerEditor({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  @override
  State<PromoBannerEditor> createState() => _PromoBannerEditorState();
}

class _PromoBannerEditorState extends State<PromoBannerEditor> {
  late TextEditingController _textController;
  late TextEditingController _backgroundColorController;
  late TextEditingController _textColorController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.data['text'] as String? ?? '');
    _backgroundColorController = TextEditingController(
      text: widget.data['backgroundColor'] as String? ?? '#D62828',
    );
    _textColorController = TextEditingController(
      text: widget.data['textColor'] as String? ?? '#FFFFFF',
    );

    _textController.addListener(_updateData);
    _backgroundColorController.addListener(_updateData);
    _textColorController.addListener(_updateData);
  }

  @override
  void dispose() {
    _textController.dispose();
    _backgroundColorController.dispose();
    _textColorController.dispose();
    super.dispose();
  }

  void _updateData() {
    widget.onDataChanged({
      'text': _textController.text,
      'backgroundColor': _backgroundColorController.text,
      'textColor': _textColorController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuration Bannière Promo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Texte de la bannière',
            helperText: 'Message promotionnel à afficher',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _backgroundColorController,
          decoration: InputDecoration(
            labelText: 'Couleur de fond',
            helperText: 'Code couleur hex (ex: #D62828)',
            border: const OutlineInputBorder(),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _parseColor(_backgroundColorController.text),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textColorController,
          decoration: InputDecoration(
            labelText: 'Couleur du texte',
            helperText: 'Code couleur hex (ex: #FFFFFF)',
            border: const OutlineInputBorder(),
            suffixIcon: Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _parseColor(_textColorController.text),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hexString) {
    try {
      final hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      // Return default on error
    }
    return AppColors.primaryRed;
  }
}
