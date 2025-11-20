// lib/src/screens/admin/studio/modules/studio_banner_module.dart
// Banner module - Multiple programmable banners with CRUD

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../design_system/app_theme.dart';
import '../../../../models/banner_config.dart';
import '../../../../models/home_config.dart';

class StudioBannerModule extends StatefulWidget {
  final List<BannerConfig> draftBanners;
  final Function(List<BannerConfig>) onUpdate;

  const StudioBannerModule({
    super.key,
    required this.draftBanners,
    required this.onUpdate,
  });

  @override
  State<StudioBannerModule> createState() => _StudioBannerModuleState();
}

class _StudioBannerModuleState extends State<StudioBannerModule> {
  void _addBanner() {
    final newBanner = BannerConfig.defaultBanner(order: widget.draftBanners.length);
    widget.onUpdate([...widget.draftBanners, newBanner]);
  }

  void _editBanner(BannerConfig banner) {
    showDialog(
      context: context,
      builder: (context) => _BannerEditorDialog(
        banner: banner,
        onSave: (updatedBanner) {
          final index = widget.draftBanners.indexWhere((b) => b.id == banner.id);
          if (index != -1) {
            final updated = List<BannerConfig>.from(widget.draftBanners);
            updated[index] = updatedBanner;
            widget.onUpdate(updated);
          }
        },
      ),
    );
  }

  void _deleteBanner(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce bandeau ?'),
        content: const Text('Cette action est irréversible après publication.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              widget.onUpdate(widget.draftBanners.where((b) => b.id != id).toList());
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _toggleBanner(String id, bool isEnabled) {
    final index = widget.draftBanners.indexWhere((b) => b.id == id);
    if (index != -1) {
      final updated = List<BannerConfig>.from(widget.draftBanners);
      updated[index] = updated[index].copyWith(isEnabled: isEnabled);
      widget.onUpdate(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Module Bandeaux', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Gérez plusieurs bandeaux programmables',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _addBanner,
                icon: const Icon(Icons.add),
                label: const Text('Nouveau bandeau'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.draftBanners.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.flag, size: 48, color: AppColors.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun bandeau configuré',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Créez votre premier bandeau promotionnel',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) {
                final updated = List<BannerConfig>.from(widget.draftBanners);
                if (newIndex > oldIndex) newIndex--;
                final item = updated.removeAt(oldIndex);
                updated.insert(newIndex, item);
                // Update order field
                for (int i = 0; i < updated.length; i++) {
                  updated[i] = updated[i].copyWith(order: i);
                }
                widget.onUpdate(updated);
              },
              children: widget.draftBanners.map((banner) {
                final bgColor = Color(ColorConverter.hexToColor(banner.backgroundColor) ?? 0xFFD32F2F);
                final textColor = Color(ColorConverter.hexToColor(banner.textColor) ?? 0xFFFFFFFF);

                return Card(
                  key: ValueKey(banner.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.drag_handle),
                    title: Text(
                      banner.text.isEmpty ? 'Bandeau sans titre' : banner.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      banner.isEnabled ? 'Actif' : 'Inactif',
                      style: TextStyle(
                        color: banner.isEnabled ? AppColors.success : AppColors.onSurfaceVariant,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(banner.iconData ?? Icons.campaign, color: textColor, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: banner.isEnabled,
                          onChanged: (value) => _toggleBanner(banner.id, value),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editBanner(banner),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => _deleteBanner(banner.id),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _BannerEditorDialog extends StatefulWidget {
  final BannerConfig banner;
  final Function(BannerConfig) onSave;

  const _BannerEditorDialog({
    required this.banner,
    required this.onSave,
  });

  @override
  State<_BannerEditorDialog> createState() => _BannerEditorDialogState();
}

class _BannerEditorDialogState extends State<_BannerEditorDialog> {
  late TextEditingController _textController;
  late Color _bgColor;
  late Color _textColor;
  String _selectedIcon = 'campaign';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<Map<String, dynamic>> _iconOptions = [
    {'value': 'campaign', 'icon': Icons.campaign},
    {'value': 'star', 'icon': Icons.star},
    {'value': 'local_fire_department', 'icon': Icons.local_fire_department},
    {'value': 'local_offer', 'icon': Icons.local_offer},
    {'value': 'new_releases', 'icon': Icons.new_releases},
    {'value': 'celebration', 'icon': Icons.celebration},
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.banner.text);
    _bgColor = Color(ColorConverter.hexToColor(widget.banner.backgroundColor) ?? 0xFFD32F2F);
    _textColor = Color(ColorConverter.hexToColor(widget.banner.textColor) ?? 0xFFFFFFFF);
    _selectedIcon = widget.banner.icon ?? 'campaign';
    _startDate = widget.banner.startDate;
    _endDate = widget.banner.endDate;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.banner.copyWith(
      text: _textController.text,
      icon: _selectedIcon,
      backgroundColor: ColorConverter.colorToHex(_bgColor.value),
      textColor: ColorConverter.colorToHex(_textColor.value),
      startDate: _startDate,
      endDate: _endDate,
      updatedAt: DateTime.now(),
    );
    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Éditer le bandeau'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Texte du bandeau *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text('Icône', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _iconOptions.map((option) {
                  final isSelected = _selectedIcon == option['value'];
                  return ChoiceChip(
                    label: Icon(option['icon'] as IconData, size: 20),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedIcon = option['value'] as String);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Couleurs', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickColor(true),
                      icon: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _bgColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outline),
                        ),
                      ),
                      label: const Text('Fond'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickColor(false),
                      icon: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _textColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.outline),
                        ),
                      ),
                      label: const Text('Texte'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Planification (optionnel)', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(true),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_startDate != null ? 'Début: ${_startDate!.day}/${_startDate!.month}' : 'Date début'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(false),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_endDate != null ? 'Fin: ${_endDate!.day}/${_endDate!.month}' : 'Date fin'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }

  void _pickColor(bool isBackground) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBackground ? 'Couleur de fond' : 'Couleur du texte'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: isBackground ? _bgColor : _textColor,
            onColorChanged: (color) {
              setState(() {
                if (isBackground) {
                  _bgColor = color;
                } else {
                  _textColor = color;
                }
              });
            },
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

  Future<void> _pickDate(bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }
}
