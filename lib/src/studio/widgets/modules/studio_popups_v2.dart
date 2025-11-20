// lib/src/studio/widgets/modules/studio_popups_v2.dart
// Popups module V2 - Ultimate popup manager with advanced features

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../design_system/app_theme.dart';
import '../../models/popup_v2_model.dart';

class StudioPopupsV2 extends StatefulWidget {
  final List<PopupV2Model> popups;
  final Function(List<PopupV2Model>) onUpdate;

  const StudioPopupsV2({
    super.key,
    required this.popups,
    required this.onUpdate,
  });

  @override
  State<StudioPopupsV2> createState() => _StudioPopupsV2State();
}

class _StudioPopupsV2State extends State<StudioPopupsV2> {
  @override
  Widget build(BuildContext context) {
    // Sort popups by priority then order
    final sortedPopups = List<PopupV2Model>.from(widget.popups)
      ..sort((a, b) {
        final priorityCompare = b.priority.compareTo(a.priority);
        if (priorityCompare != 0) return priorityCompare;
        return a.order.compareTo(b.order);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popups Ultimate',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Système avancé de popups avec triggers et conditions',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _addPopup,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nouveau popup'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Popups list or empty state
          if (sortedPopups.isEmpty)
            _buildEmptyState()
          else
            ...sortedPopups.map((popup) => _buildPopupCard(popup)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun popup configuré',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez des popups pour engager vos clients au bon moment',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _addPopup,
              icon: const Icon(Icons.add),
              label: const Text('Créer un popup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupCard(PopupV2Model popup) {
    final now = DateTime.now();
    final isScheduled = popup.startDate != null && popup.startDate!.isAfter(now);
    final isExpired = popup.endDate != null && popup.endDate!.isBefore(now);
    final isActive = popup.isEnabled && !isExpired;

    String statusText;
    Color statusColor;
    if (isExpired) {
      statusText = 'Expiré';
      statusColor = Colors.grey;
    } else if (isScheduled) {
      statusText = 'Planifié';
      statusColor = Colors.orange;
    } else if (isActive) {
      statusText = 'Actif';
      statusColor = Colors.green;
    } else {
      statusText = 'Désactivé';
      statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _editPopup(popup),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Type Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getColorForType(popup.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getIconForType(popup.type),
                        color: _getColorForType(popup.type),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            popup.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              // Type badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getTypeLabel(popup.type),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              // Trigger badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt, size: 12, color: Colors.purple[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getTriggerLabel(popup.triggerCondition),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.purple[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Priority indicator
                              if (popup.priority > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.priority_high, size: 12, color: Colors.orange[700]),
                                      const SizedBox(width: 4),
                                      Text(
                                        'P${popup.priority}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (popup.message.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              popup.message,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: popup.isEnabled,
                          onChanged: (value) {
                            _togglePopup(popup, value);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showPopupMenu(popup),
                        ),
                      ],
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

  IconData _getIconForType(PopupTypeV2 type) {
    switch (type) {
      case PopupTypeV2.image:
        return Icons.image_outlined;
      case PopupTypeV2.coupon:
        return Icons.local_offer_outlined;
      case PopupTypeV2.emojiReaction:
        return Icons.emoji_emotions_outlined;
      case PopupTypeV2.bigPromo:
        return Icons.campaign_outlined;
      case PopupTypeV2.text:
        return Icons.message_outlined;
    }
  }

  Color _getColorForType(PopupTypeV2 type) {
    switch (type) {
      case PopupTypeV2.image:
        return Colors.purple;
      case PopupTypeV2.coupon:
        return Colors.green;
      case PopupTypeV2.emojiReaction:
        return Colors.orange;
      case PopupTypeV2.bigPromo:
        return Colors.red;
      case PopupTypeV2.text:
        return Colors.blue;
    }
  }

  String _getTypeLabel(PopupTypeV2 type) {
    switch (type) {
      case PopupTypeV2.image:
        return 'Image';
      case PopupTypeV2.coupon:
        return 'Coupon';
      case PopupTypeV2.emojiReaction:
        return 'Emoji';
      case PopupTypeV2.bigPromo:
        return 'Big Promo';
      case PopupTypeV2.text:
        return 'Texte';
    }
  }

  String _getTriggerLabel(PopupTriggerCondition trigger) {
    switch (trigger) {
      case PopupTriggerCondition.delay:
        return 'Délai';
      case PopupTriggerCondition.firstVisit:
        return '1ère visite';
      case PopupTriggerCondition.everyVisit:
        return 'Chaque visite';
      case PopupTriggerCondition.limitedPerDay:
        return 'Limité/jour';
      case PopupTriggerCondition.onScroll:
        return 'Au scroll';
      case PopupTriggerCondition.onAction:
        return 'Sur action';
    }
  }

  void _addPopup() {
    final newPopup = PopupV2Model.defaultPopup(order: widget.popups.length);
    _editPopup(newPopup, isNew: true);
  }

  void _editPopup(PopupV2Model popup, {bool isNew = false}) {
    showDialog(
      context: context,
      builder: (context) => _PopupEditDialog(
        popup: popup,
        isNew: isNew,
        onSave: (updatedPopup) {
          setState(() {
            if (isNew) {
              widget.onUpdate([...widget.popups, updatedPopup]);
            } else {
              final updated = widget.popups.map((p) {
                return p.id == updatedPopup.id ? updatedPopup : p;
              }).toList();
              widget.onUpdate(updated);
            }
          });
        },
      ),
    );
  }

  void _togglePopup(PopupV2Model popup, bool value) {
    final updated = widget.popups.map((p) {
      return p.id == popup.id ? p.copyWith(isEnabled: value) : p;
    }).toList();
    widget.onUpdate(updated);
  }

  void _showPopupMenu(PopupV2Model popup) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                _editPopup(popup);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePopup(popup);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Augmenter priorité'),
              onTap: () {
                Navigator.pop(context);
                _changePriority(popup, 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_downward),
              title: const Text('Diminuer priorité'),
              enabled: popup.priority > 0,
              onTap: popup.priority > 0
                  ? () {
                      Navigator.pop(context);
                      _changePriority(popup, -1);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _deletePopup(PopupV2Model popup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer le popup ?'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${popup.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final updated = widget.popups.where((p) => p.id != popup.id).toList();
              widget.onUpdate(updated);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _changePriority(PopupV2Model popup, int delta) {
    final updated = widget.popups.map((p) {
      return p.id == popup.id
          ? p.copyWith(priority: (p.priority + delta).clamp(0, 10))
          : p;
    }).toList();
    widget.onUpdate(updated);
  }
}

// Popup Edit Dialog (simplified version - full implementation would be larger)
class _PopupEditDialog extends StatefulWidget {
  final PopupV2Model popup;
  final bool isNew;
  final Function(PopupV2Model) onSave;

  const _PopupEditDialog({
    required this.popup,
    required this.isNew,
    required this.onSave,
  });

  @override
  State<_PopupEditDialog> createState() => _PopupEditDialogState();
}

class _PopupEditDialogState extends State<_PopupEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late PopupV2Model _editedPopup;

  @override
  void initState() {
    super.initState();
    _editedPopup = widget.popup;
    _titleController = TextEditingController(text: widget.popup.title);
    _messageController = TextEditingController(text: widget.popup.message);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.isNew ? 'Nouveau popup' : 'Modifier le popup',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Basic fields
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _editedPopup = _editedPopup.copyWith(title: value);
                  });
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    _editedPopup = _editedPopup.copyWith(message: value);
                  });
                },
              ),
              const SizedBox(height: 16),

              // Type selector
              DropdownButtonFormField<PopupTypeV2>(
                value: _editedPopup.type,
                decoration: const InputDecoration(
                  labelText: 'Type de popup',
                  border: OutlineInputBorder(),
                ),
                items: PopupTypeV2.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getIconForType(type), size: 18),
                        const SizedBox(width: 8),
                        Text(_getTypeLabel(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _editedPopup = _editedPopup.copyWith(type: value);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Trigger condition
              DropdownButtonFormField<PopupTriggerCondition>(
                value: _editedPopup.triggerCondition,
                decoration: const InputDecoration(
                  labelText: 'Condition d\'affichage',
                  border: OutlineInputBorder(),
                ),
                items: PopupTriggerCondition.values.map((trigger) {
                  return DropdownMenuItem(
                    value: trigger,
                    child: Text(_getTriggerLabel(trigger)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _editedPopup = _editedPopup.copyWith(triggerCondition: value);
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _titleController.text.isEmpty ? null : _save,
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(PopupTypeV2 type) {
    switch (type) {
      case PopupTypeV2.image:
        return Icons.image_outlined;
      case PopupTypeV2.coupon:
        return Icons.local_offer_outlined;
      case PopupTypeV2.emojiReaction:
        return Icons.emoji_emotions_outlined;
      case PopupTypeV2.bigPromo:
        return Icons.campaign_outlined;
      case PopupTypeV2.text:
        return Icons.message_outlined;
    }
  }

  String _getTypeLabel(PopupTypeV2 type) {
    switch (type) {
      case PopupTypeV2.image:
        return 'Image';
      case PopupTypeV2.coupon:
        return 'Coupon';
      case PopupTypeV2.emojiReaction:
        return 'Emoji Reaction';
      case PopupTypeV2.bigPromo:
        return 'Grande Promo';
      case PopupTypeV2.text:
        return 'Texte';
    }
  }

  String _getTriggerLabel(PopupTriggerCondition trigger) {
    switch (trigger) {
      case PopupTriggerCondition.delay:
        return 'Après un délai';
      case PopupTriggerCondition.firstVisit:
        return 'Première visite';
      case PopupTriggerCondition.everyVisit:
        return 'Chaque visite';
      case PopupTriggerCondition.limitedPerDay:
        return 'Limité par jour';
      case PopupTriggerCondition.onScroll:
        return 'Au scroll';
      case PopupTriggerCondition.onAction:
        return 'Sur action';
    }
  }

  void _save() {
    final finalPopup = _editedPopup.copyWith(
      title: _titleController.text,
      message: _messageController.text,
      updatedAt: DateTime.now(),
    );
    widget.onSave(finalPopup);
    Navigator.pop(context);
  }
}
