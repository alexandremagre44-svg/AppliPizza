// lib/src/screens/admin/studio/modules/studio_popups_module.dart
// Popups module - Complete CRUD for popups with scheduling and targeting

import 'package:flutter/material.dart';
import '../../../../design_system/app_theme.dart';
import '../../../../models/popup_config.dart';

class StudioPopupsModule extends StatefulWidget {
  final List<PopupConfig> draftPopups;
  final Function(List<PopupConfig>) onUpdate;

  const StudioPopupsModule({
    super.key,
    required this.draftPopups,
    required this.onUpdate,
  });

  @override
  State<StudioPopupsModule> createState() => _StudioPopupsModuleState();
}

class _StudioPopupsModuleState extends State<StudioPopupsModule> {
  void _addPopup() {
    final newPopup = PopupConfig(
      id: 'popup_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Nouveau popup',
      message: '',
      isEnabled: false,
      priority: widget.draftPopups.length,
      createdAt: DateTime.now(),
      type: 'info',
    );
    widget.onUpdate([...widget.draftPopups, newPopup]);
    _editPopup(newPopup);
  }

  void _editPopup(PopupConfig popup) {
    showDialog(
      context: context,
      builder: (context) => _PopupEditorDialog(
        popup: popup,
        onSave: (updatedPopup) {
          final index = widget.draftPopups.indexWhere((p) => p.id == popup.id);
          if (index != -1) {
            final updated = List<PopupConfig>.from(widget.draftPopups);
            updated[index] = updatedPopup;
            widget.onUpdate(updated);
          }
        },
      ),
    );
  }

  void _deletePopup(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce popup ?'),
        content: const Text('Cette action est irréversible après publication.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              widget.onUpdate(widget.draftPopups.where((p) => p.id != id).toList());
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _togglePopup(String id, bool isEnabled) {
    final index = widget.draftPopups.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updated = List<PopupConfig>.from(widget.draftPopups);
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
                    Text('Module Popups', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Gérez les popups et notifications de l\'application',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _addPopup,
                icon: const Icon(Icons.add),
                label: const Text('Nouveau popup'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (widget.draftPopups.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.campaign, size: 48, color: AppColors.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun popup configuré',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Créez votre premier popup promotionnel',
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
                final updated = List<PopupConfig>.from(widget.draftPopups);
                if (newIndex > oldIndex) newIndex--;
                final item = updated.removeAt(oldIndex);
                updated.insert(newIndex, item);
                // Update priority
                for (int i = 0; i < updated.length; i++) {
                  updated[i] = updated[i].copyWith(priority: i);
                }
                widget.onUpdate(updated);
              },
              children: widget.draftPopups.map((popup) {
                final typeColor = popup.type == 'promo'
                    ? AppColors.success
                    : popup.type == 'warning'
                        ? AppColors.error
                        : AppColors.primary;

                return Card(
                  key: ValueKey(popup.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.drag_handle),
                    title: Text(
                      popup.title.isEmpty ? 'Popup sans titre' : popup.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          popup.message.isEmpty ? 'Sans message' : popup.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                popup.type ?? 'info',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: typeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              popup.isEnabled ? 'Actif' : 'Inactif',
                              style: TextStyle(
                                fontSize: 12,
                                color: popup.isEnabled ? AppColors.success : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: popup.isEnabled,
                          onChanged: (value) => _togglePopup(popup.id, value),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editPopup(popup),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () => _deletePopup(popup.id),
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

class _PopupEditorDialog extends StatefulWidget {
  final PopupConfig popup;
  final Function(PopupConfig) onSave;

  const _PopupEditorDialog({
    required this.popup,
    required this.onSave,
  });

  @override
  State<_PopupEditorDialog> createState() => _PopupEditorDialogState();
}

class _PopupEditorDialogState extends State<_PopupEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late TextEditingController _buttonTextController;
  late TextEditingController _buttonLinkController;
  late TextEditingController _imageUrlController;
  String _selectedType = 'info';
  DateTime? _startDate;
  DateTime? _endDate;
  PopupTrigger _trigger = PopupTrigger.onAppOpen;
  PopupAudience _audience = PopupAudience.all;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.popup.title);
    _messageController = TextEditingController(text: widget.popup.message);
    _buttonTextController = TextEditingController(text: widget.popup.buttonText ?? '');
    _buttonLinkController = TextEditingController(text: widget.popup.buttonLink ?? '');
    _imageUrlController = TextEditingController(text: widget.popup.imageUrl ?? '');
    _selectedType = widget.popup.type ?? 'info';
    _startDate = widget.popup.startDate;
    _endDate = widget.popup.endDate;
    _trigger = widget.popup.trigger;
    _audience = widget.popup.audience;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _buttonTextController.dispose();
    _buttonLinkController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.popup.copyWith(
      title: _titleController.text,
      message: _messageController.text,
      buttonText: _buttonTextController.text.isEmpty ? null : _buttonTextController.text,
      buttonLink: _buttonLinkController.text.isEmpty ? null : _buttonLinkController.text,
      imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      type: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      trigger: _trigger,
      audience: _audience,
    );
    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Éditer le popup'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text('Type', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'info', label: Text('Info'), icon: Icon(Icons.info)),
                  ButtonSegment(value: 'promo', label: Text('Promo'), icon: Icon(Icons.local_offer)),
                  ButtonSegment(value: 'warning', label: Text('Alerte'), icon: Icon(Icons.warning)),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String> selection) {
                  setState(() => _selectedType = selection.first);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Image (optionnel)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _buttonTextController,
                      decoration: const InputDecoration(
                        labelText: 'Texte bouton',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _buttonLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Lien',
                        hintText: '/menu',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Planification', style: AppTextStyles.labelMedium),
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
