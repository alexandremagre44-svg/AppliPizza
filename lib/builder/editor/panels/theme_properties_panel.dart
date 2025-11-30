// lib/builder/editor/panels/theme_properties_panel.dart
// Theme configuration panel for Builder B3 system
//
// Allows editing theme configuration values:
// - primaryColor
// - secondaryColor
// - backgroundColor
// - buttonRadius
// - cardRadius
// - textHeadingSize
// - textBodySize
// - spacing
// - brightnessMode

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/theme_config.dart';

/// Theme properties panel for Builder B3 editor
///
/// This panel provides controls for editing ThemeConfig values.
/// All changes are reported via [onThemeChanged] callback.
///
/// Usage in the editor:
/// ```dart
/// ThemePropertiesPanel(
///   theme: currentTheme,
///   onThemeChanged: (updates) {
///     // Apply updates to draft theme
///   },
/// )
/// ```
class ThemePropertiesPanel extends StatefulWidget {
  /// Current theme configuration
  final ThemeConfig theme;

  /// Callback when theme values change
  /// The updates map contains only the changed values
  final void Function(Map<String, dynamic> updates) onThemeChanged;

  /// Callback when user wants to publish theme
  final VoidCallback? onPublishTheme;

  /// Callback when user wants to reset to defaults
  final VoidCallback? onResetToDefaults;

  /// Whether there are unsaved changes
  final bool hasChanges;

  const ThemePropertiesPanel({
    super.key,
    required this.theme,
    required this.onThemeChanged,
    this.onPublishTheme,
    this.onResetToDefaults,
    this.hasChanges = false,
  });

  @override
  State<ThemePropertiesPanel> createState() => _ThemePropertiesPanelState();
}

class _ThemePropertiesPanelState extends State<ThemePropertiesPanel> {
  // Track expanded sections
  bool _colorsExpanded = true;
  bool _radiusExpanded = true;
  bool _typographyExpanded = false;
  bool _spacingExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Scrollable content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Colors section
                _buildColorsSection(),

                const SizedBox(height: 8),

                // Radius section
                _buildRadiusSection(),

                const SizedBox(height: 8),

                // Typography section
                _buildTypographySection(),

                const SizedBox(height: 8),

                // Spacing section
                _buildSpacingSection(),

                const SizedBox(height: 8),

                // Brightness mode section
                _buildBrightnessModeSection(),

                const SizedBox(height: 24),

                // Actions
                _buildActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.palette,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration du thème',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Personnalisez l\'apparence de l\'application',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
          if (widget.hasChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Modifié',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColorsSection() {
    return _buildExpansionSection(
      title: 'Couleurs',
      icon: Icons.color_lens,
      isExpanded: _colorsExpanded,
      onToggle: () => setState(() => _colorsExpanded = !_colorsExpanded),
      children: [
        _buildColorPicker(
          label: 'Couleur primaire',
          description: 'Couleur principale des boutons et accents',
          color: widget.theme.primaryColor,
          onColorChanged: (color) => _updateTheme('primaryColor', _colorToHex(color)),
        ),
        const SizedBox(height: 12),
        _buildColorPicker(
          label: 'Couleur secondaire',
          description: 'Couleur complémentaire pour les éléments secondaires',
          color: widget.theme.secondaryColor,
          onColorChanged: (color) => _updateTheme('secondaryColor', _colorToHex(color)),
        ),
        const SizedBox(height: 12),
        _buildColorPicker(
          label: 'Couleur de fond',
          description: 'Arrière-plan des pages builder',
          color: widget.theme.backgroundColor,
          onColorChanged: (color) => _updateTheme('backgroundColor', _colorToHex(color)),
        ),
      ],
    );
  }

  Widget _buildRadiusSection() {
    return _buildExpansionSection(
      title: 'Arrondis',
      icon: Icons.rounded_corner,
      isExpanded: _radiusExpanded,
      onToggle: () => setState(() => _radiusExpanded = !_radiusExpanded),
      children: [
        _buildSliderField(
          label: 'Arrondi des boutons',
          value: widget.theme.buttonRadius,
          min: 0,
          max: 32,
          divisions: 32,
          unit: 'px',
          onChanged: (value) => _updateTheme('buttonRadius', value),
        ),
        const SizedBox(height: 16),
        _buildSliderField(
          label: 'Arrondi des cartes',
          value: widget.theme.cardRadius,
          min: 0,
          max: 32,
          divisions: 32,
          unit: 'px',
          onChanged: (value) => _updateTheme('cardRadius', value),
        ),
      ],
    );
  }

  Widget _buildTypographySection() {
    return _buildExpansionSection(
      title: 'Typographie',
      icon: Icons.text_fields,
      isExpanded: _typographyExpanded,
      onToggle: () => setState(() => _typographyExpanded = !_typographyExpanded),
      children: [
        _buildSliderField(
          label: 'Taille des titres',
          value: widget.theme.textHeadingSize,
          min: 16,
          max: 48,
          divisions: 32,
          unit: 'px',
          onChanged: (value) => _updateTheme('textHeadingSize', value),
        ),
        const SizedBox(height: 8),
        // Preview
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Exemple de titre',
            style: TextStyle(
              fontSize: widget.theme.textHeadingSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSliderField(
          label: 'Taille du texte',
          value: widget.theme.textBodySize,
          min: 12,
          max: 24,
          divisions: 12,
          unit: 'px',
          onChanged: (value) => _updateTheme('textBodySize', value),
        ),
        const SizedBox(height: 8),
        // Preview
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Exemple de texte normal avec plusieurs mots pour voir le rendu.',
            style: TextStyle(
              fontSize: widget.theme.textBodySize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpacingSection() {
    return _buildExpansionSection(
      title: 'Espacement',
      icon: Icons.space_bar,
      isExpanded: _spacingExpanded,
      onToggle: () => setState(() => _spacingExpanded = !_spacingExpanded),
      children: [
        _buildSliderField(
          label: 'Espacement vertical entre blocs',
          value: widget.theme.spacing,
          min: 0,
          max: 48,
          divisions: 48,
          unit: 'px',
          onChanged: (value) => _updateTheme('spacing', value),
        ),
        const SizedBox(height: 8),
        // Preview
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: widget.theme.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(child: Text('Bloc 1', style: TextStyle(fontSize: 10))),
              ),
              SizedBox(height: widget.theme.spacing),
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: widget.theme.secondaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(child: Text('Bloc 2', style: TextStyle(fontSize: 10))),
              ),
              SizedBox(height: widget.theme.spacing),
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: widget.theme.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(child: Text('Bloc 3', style: TextStyle(fontSize: 10))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrightnessModeSection() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.brightness_6,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mode d\'affichage',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<BrightnessMode>(
              segments: const [
                ButtonSegment(
                  value: BrightnessMode.light,
                  label: Text('Clair'),
                  icon: Icon(Icons.light_mode, size: 18),
                ),
                ButtonSegment(
                  value: BrightnessMode.dark,
                  label: Text('Sombre'),
                  icon: Icon(Icons.dark_mode, size: 18),
                ),
                ButtonSegment(
                  value: BrightnessMode.auto,
                  label: Text('Auto'),
                  icon: Icon(Icons.brightness_auto, size: 18),
                ),
              ],
              selected: {widget.theme.brightnessMode},
              onSelectionChanged: (selection) {
                _updateTheme('brightnessMode', selection.first.toJson());
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getBrightnessModeDescription(widget.theme.brightnessMode),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        // Publish button
        if (widget.onPublishTheme != null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.onPublishTheme,
              icon: const Icon(Icons.publish, size: 18),
              label: const Text('Publier le thème'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

        const SizedBox(height: 12),

        // Reset button
        if (widget.onResetToDefaults != null)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmReset(),
              icon: const Icon(Icons.restore, size: 18),
              label: const Text('Réinitialiser par défaut'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExpansionSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColorPicker({
    required String label,
    required String description,
    required Color color,
    required void Function(Color) onColorChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showColorPickerDialog(
            currentColor: color,
            onColorSelected: onColorChanged,
          ),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.black26,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _colorToHex(color),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                  ),
                ),
                Icon(
                  Icons.edit,
                  size: 18,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderField({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${value.round()}$unit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showColorPickerDialog({
    required Color currentColor,
    required void Function(Color) onColorSelected,
  }) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une couleur'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            enableAlpha: false,
            displayThumbColor: true,
            pickerAreaHeightPercent: 0.8,
            labelTypes: const [],
            pickerAreaBorderRadius: BorderRadius.circular(8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              onColorSelected(pickerColor);
              Navigator.of(context).pop();
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser le thème'),
        content: const Text(
          'Voulez-vous vraiment réinitialiser le thème aux valeurs par défaut ? '
          'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onResetToDefaults?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _updateTheme(String key, dynamic value) {
    widget.onThemeChanged({key: value});
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  String _getBrightnessModeDescription(BrightnessMode mode) {
    switch (mode) {
      case BrightnessMode.light:
        return 'L\'application utilisera toujours le thème clair';
      case BrightnessMode.dark:
        return 'L\'application utilisera toujours le thème sombre';
      case BrightnessMode.auto:
        return 'Le thème s\'adaptera aux préférences système de l\'utilisateur';
    }
  }
}
