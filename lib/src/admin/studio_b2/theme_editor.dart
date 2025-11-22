// lib/src/admin/studio_b2/theme_editor.dart
// Editor for theme configuration

import 'package:flutter/material.dart';
import '../../models/app_config.dart';
import '../../theme/app_theme.dart';

/// Editor for theme configuration
class ThemeEditor extends StatefulWidget {
  final AppConfig config;
  final String appId;
  final Function(AppConfig) onConfigUpdated;

  const ThemeEditor({
    super.key,
    required this.config,
    required this.appId,
    required this.onConfigUpdated,
  });

  @override
  State<ThemeEditor> createState() => _ThemeEditorState();
}

class _ThemeEditorState extends State<ThemeEditor> {
  late TextEditingController _primaryColorController;
  late TextEditingController _secondaryColorController;
  late TextEditingController _accentColorController;
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _primaryColorController = TextEditingController(
      text: widget.config.home.theme.primaryColor,
    );
    _secondaryColorController = TextEditingController(
      text: widget.config.home.theme.secondaryColor,
    );
    _accentColorController = TextEditingController(
      text: widget.config.home.theme.accentColor,
    );
    _darkMode = widget.config.home.theme.darkMode;
  }

  @override
  void dispose() {
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _accentColorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceWhite,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.palette, size: 28, color: AppColors.primaryRed),
                const SizedBox(width: 12),
                const Text(
                  'Thème de l\'application',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Configurez les couleurs du thème',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const Divider(height: 32),
            // Primary color
            const Text(
              'Couleur primaire',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _primaryColorController,
              decoration: InputDecoration(
                labelText: 'Couleur primaire',
                helperText: 'Code couleur hex (ex: #D62828)',
                border: const OutlineInputBorder(),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _parseColor(_primaryColorController.text),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Secondary color
            const Text(
              'Couleur secondaire',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _secondaryColorController,
              decoration: InputDecoration(
                labelText: 'Couleur secondaire',
                helperText: 'Code couleur hex (ex: #000000)',
                border: const OutlineInputBorder(),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _parseColor(_secondaryColorController.text),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Accent color
            const Text(
              'Couleur d\'accentuation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _accentColorController,
              decoration: InputDecoration(
                labelText: 'Couleur d\'accentuation',
                helperText: 'Code couleur hex (ex: #FFFFFF)',
                border: const OutlineInputBorder(),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _parseColor(_accentColorController.text),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Dark mode
            SwitchListTile(
              title: const Text('Mode sombre'),
              subtitle: const Text('Activer le thème sombre'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
            const SizedBox(height: 32),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer les modifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
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

  void _handleSave() {
    final updatedTheme = ThemeConfigV2(
      primaryColor: _primaryColorController.text,
      secondaryColor: _secondaryColorController.text,
      accentColor: _accentColorController.text,
      darkMode: _darkMode,
    );

    final updatedConfig = widget.config.copyWith(
      home: widget.config.home.copyWith(
        theme: updatedTheme,
      ),
    );

    widget.onConfigUpdated(updatedConfig);
  }
}
