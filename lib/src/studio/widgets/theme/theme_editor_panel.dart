// lib/src/studio/widgets/theme/theme_editor_panel.dart
// Theme editor panel with all customization controls

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/theme_config.dart';

class ThemeEditorPanel extends StatefulWidget {
  final ThemeConfig config;
  final Function(ThemeConfig) onConfigChanged;
  final VoidCallback onResetToDefaults;

  const ThemeEditorPanel({
    super.key,
    required this.config,
    required this.onConfigChanged,
    required this.onResetToDefaults,
  });

  @override
  State<ThemeEditorPanel> createState() => _ThemeEditorPanelState();
}

class _ThemeEditorPanelState extends State<ThemeEditorPanel> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateColors(ThemeColorsConfig colors) {
    widget.onConfigChanged(widget.config.copyWith(colors: colors));
  }

  void _updateTypography(TypographyConfig typography) {
    widget.onConfigChanged(widget.config.copyWith(typography: typography));
  }

  void _updateRadius(RadiusConfig radius) {
    widget.onConfigChanged(widget.config.copyWith(radius: radius));
  }

  void _updateShadows(ShadowsConfig shadows) {
    widget.onConfigChanged(widget.config.copyWith(shadows: shadows));
  }

  void _updateSpacing(SpacingConfig spacing) {
    widget.onConfigChanged(widget.config.copyWith(spacing: spacing));
  }

  void _updateDarkMode(bool darkMode) {
    widget.onConfigChanged(widget.config.copyWith(darkMode: darkMode));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header with reset button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.outline),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Theme Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: widget.onResetToDefaults,
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Reset to Defaults'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColorsSection(),
                  const SizedBox(height: 32),
                  _buildTypographySection(),
                  const SizedBox(height: 32),
                  _buildRadiusSection(),
                  const SizedBox(height: 32),
                  _buildShadowsSection(),
                  const SizedBox(height: 32),
                  _buildSpacingSection(),
                  const SizedBox(height: 32),
                  _buildDarkModeSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsSection() {
    return _buildSection(
      title: 'Colors',
      icon: Icons.color_lens,
      children: [
        _buildColorPicker(
          'Primary',
          widget.config.colors.primary,
          (color) => _updateColors(widget.config.colors.copyWith(primary: color)),
        ),
        _buildColorPicker(
          'Secondary',
          widget.config.colors.secondary,
          (color) => _updateColors(widget.config.colors.copyWith(secondary: color)),
        ),
        _buildColorPicker(
          'Background',
          widget.config.colors.background,
          (color) => _updateColors(widget.config.colors.copyWith(background: color)),
        ),
        _buildColorPicker(
          'Surface',
          widget.config.colors.surface,
          (color) => _updateColors(widget.config.colors.copyWith(surface: color)),
        ),
        _buildColorPicker(
          'Text Primary',
          widget.config.colors.textPrimary,
          (color) => _updateColors(widget.config.colors.copyWith(textPrimary: color)),
        ),
        _buildColorPicker(
          'Text Secondary',
          widget.config.colors.textSecondary,
          (color) => _updateColors(widget.config.colors.copyWith(textSecondary: color)),
        ),
        _buildColorPicker(
          'Success',
          widget.config.colors.success,
          (color) => _updateColors(widget.config.colors.copyWith(success: color)),
        ),
        _buildColorPicker(
          'Warning',
          widget.config.colors.warning,
          (color) => _updateColors(widget.config.colors.copyWith(warning: color)),
        ),
        _buildColorPicker(
          'Error',
          widget.config.colors.error,
          (color) => _updateColors(widget.config.colors.copyWith(error: color)),
        ),
      ],
    );
  }

  Widget _buildTypographySection() {
    return _buildSection(
      title: 'Typography',
      icon: Icons.text_fields,
      children: [
        _buildSlider(
          'Base Size',
          widget.config.typography.baseSize,
          10.0,
          24.0,
          (value) => _updateTypography(
            widget.config.typography.copyWith(baseSize: value),
          ),
          suffix: 'px',
        ),
        _buildSlider(
          'Scale Factor',
          widget.config.typography.scaleFactor,
          1.0,
          1.5,
          (value) => _updateTypography(
            widget.config.typography.copyWith(scaleFactor: value),
          ),
        ),
        _buildFontSelector(
          'Font Family',
          widget.config.typography.fontFamily,
          (font) => _updateTypography(
            widget.config.typography.copyWith(fontFamily: font),
          ),
        ),
      ],
    );
  }

  Widget _buildRadiusSection() {
    return _buildSection(
      title: 'Border Radius',
      icon: Icons.rounded_corner,
      children: [
        _buildSlider(
          'Small',
          widget.config.radius.small,
          0.0,
          16.0,
          (value) => _updateRadius(
            widget.config.radius.copyWith(small: value),
          ),
          suffix: 'px',
        ),
        _buildSlider(
          'Medium',
          widget.config.radius.medium,
          0.0,
          24.0,
          (value) => _updateRadius(
            widget.config.radius.copyWith(medium: value),
          ),
          suffix: 'px',
        ),
        _buildSlider(
          'Large',
          widget.config.radius.large,
          0.0,
          32.0,
          (value) => _updateRadius(
            widget.config.radius.copyWith(large: value),
          ),
          suffix: 'px',
        ),
      ],
    );
  }

  Widget _buildShadowsSection() {
    return _buildSection(
      title: 'Shadows',
      icon: Icons.shadow,
      children: [
        _buildSlider(
          'Card Shadow',
          widget.config.shadows.card,
          0.0,
          16.0,
          (value) => _updateShadows(
            widget.config.shadows.copyWith(card: value),
          ),
          suffix: 'px',
        ),
        _buildSlider(
          'Modal Shadow',
          widget.config.shadows.modal,
          0.0,
          24.0,
          (value) => _updateShadows(
            widget.config.shadows.copyWith(modal: value),
          ),
          suffix: 'px',
        ),
        _buildSlider(
          'Navbar Shadow',
          widget.config.shadows.navbar,
          0.0,
          16.0,
          (value) => _updateShadows(
            widget.config.shadows.copyWith(navbar: value),
          ),
          suffix: 'px',
        ),
      ],
    );
  }

  Widget _buildSpacingSection() {
    return _buildSection(
      title: 'Spacing',
      icon: Icons.space_bar,
      children: [
        _buildSlider(
          'Padding Small',
          widget.config.spacing.paddingSmall,
          4.0,
          16.0,
          (value) => _updateSpacing(
            widget.config.spacing.copyWith(paddingSmall: value),
          ),
          suffix: 'px',
        ),
        _buildSlider(
          'Padding Medium',
          widget.config.spacing.paddingMedium,
          8.0,
          32.0,
          (value) => _updateSpacing(
            widget.config.spacing.copyWith(paddingMedium: value),
          ),
          suffix: 'px',
        ),
        _buildSlider(
          'Padding Large',
          widget.config.spacing.paddingLarge,
          16.0,
          48.0,
          (value) => _updateSpacing(
            widget.config.spacing.copyWith(paddingLarge: value),
          ),
          suffix: 'px',
        ),
      ],
    );
  }

  Widget _buildDarkModeSection() {
    return _buildSection(
      title: 'Dark Mode',
      icon: Icons.dark_mode,
      children: [
        SwitchListTile(
          title: const Text('Enable Dark Mode'),
          subtitle: const Text('Switch between light and dark theme'),
          value: widget.config.darkMode,
          onChanged: _updateDarkMode,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(
    String label,
    Color color,
    Function(Color) onColorChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          InkWell(
            onTap: () => _showColorPickerDialog(label, color, onColorChanged),
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: AppColors.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: TextStyle(
                    color: _getContrastColor(color),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Future<void> _showColorPickerDialog(
    String label,
    Color color,
    Function(Color) onColorChanged,
  ) async {
    Color pickerColor = color;
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick $label Color'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (Color color) {
                    pickerColor = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                ),
                const SizedBox(height: 16),
                MaterialPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (Color color) {
                    pickerColor = color;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    String suffix = '',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '${value.toStringAsFixed(1)}$suffix',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) * 2).toInt(),
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildFontSelector(
    String label,
    String currentFont,
    Function(String) onFontChanged,
  ) {
    final fonts = [
      'Roboto',
      'Open Sans',
      'Lato',
      'Montserrat',
      'Oswald',
      'Raleway',
      'PT Sans',
      'Merriweather',
      'Nunito',
      'Playfair Display',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: fonts.contains(currentFont) ? currentFont : fonts[0],
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: fonts.map((font) {
              return DropdownMenuItem(
                value: font,
                child: Text(font),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onFontChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
