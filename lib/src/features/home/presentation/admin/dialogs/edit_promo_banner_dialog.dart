// lib/src/screens/admin/studio/dialogs/edit_promo_banner_dialog.dart
// Dialog for editing promotional banner configuration

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../models/home_config.dart';
import '../../../../shared/theme/app_theme.dart';

class EditPromoBannerDialog extends StatefulWidget {
  final PromoBannerConfig banner;
  final Function(PromoBannerConfig) onSave;

  const EditPromoBannerDialog({
    super.key,
    required this.banner,
    required this.onSave,
  });

  @override
  State<EditPromoBannerDialog> createState() => _EditPromoBannerDialogState();
}

class _EditPromoBannerDialogState extends State<EditPromoBannerDialog> {
  late TextEditingController _textController;
  late Color _backgroundColor;
  late Color _textColor;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.banner.text);
    
    // Parse colors from hex strings
    final bgColorValue = ColorConverter.hexToColor(widget.banner.backgroundColor);
    _backgroundColor = bgColorValue != null 
        ? Color(bgColorValue) 
        : AppColors.primaryRed;
    
    final textColorValue = ColorConverter.hexToColor(widget.banner.textColor);
    _textColor = textColorValue != null 
        ? Color(textColorValue) 
        : Colors.white;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _pickBackgroundColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la couleur de fond'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _backgroundColor,
            onColorChanged: (color) {
              setState(() {
                _backgroundColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            labelTypes: const [ColorLabelType.hex],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _pickTextColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la couleur du texte'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _textColor,
            onColorChanged: (color) {
              setState(() {
                _textColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            labelTypes: const [ColorLabelType.hex],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le texte est requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedBanner = widget.banner.copyWith(
      text: _textController.text.trim(),
      backgroundColor: ColorConverter.colorToHexWithoutAlpha(_backgroundColor.value),
      textColor: ColorConverter.colorToHexWithoutAlpha(_textColor.value),
    );

    widget.onSave(updatedBanner);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications, color: AppColors.primaryRed, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Modifier le bandeau promo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_offer, color: _textColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _textController.text.isEmpty 
                              ? 'Aperçu du texte' 
                              : _textController.text,
                          style: TextStyle(
                            color: _textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Text field
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: 'Texte du bandeau *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.text_fields),
                  ),
                  maxLines: 2,
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Background color picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                  title: const Text('Couleur de fond'),
                  subtitle: Text(
                    ColorConverter.colorToHexWithoutAlpha(_backgroundColor.value),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: _pickBackgroundColor,
                  ),
                ),
                const Divider(),

                // Text color picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _textColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  ),
                  title: const Text('Couleur du texte'),
                  subtitle: Text(
                    ColorConverter.colorToHexWithoutAlpha(_textColor.value),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: _pickTextColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
