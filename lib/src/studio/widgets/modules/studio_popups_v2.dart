// lib/src/studio/widgets/modules/studio_popups_v2.dart
// Popups module V2 - Ultimate popup manager with advanced features

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../models/popup_v2_model.dart';

class StudioPopupsV2 extends StatelessWidget {
  final List<PopupV2Model> popups;
  final Function(List<PopupV2Model>) onUpdate;

  const StudioPopupsV2({
    super.key,
    required this.popups,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Popups Ultimate', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Gérez vos popups avancés', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _addPopup(context),
                icon: const Icon(Icons.add),
                label: const Text('Nouveau popup'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (popups.isEmpty)
            const Center(child: Text('Aucun popup configuré'))
          else
            ...popups.map((popup) => _buildPopupCard(context, popup)),
        ],
      ),
    );
  }

  Widget _buildPopupCard(BuildContext context, PopupV2Model popup) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(_getIconForType(popup.type)),
        title: Text(popup.title),
        subtitle: Text(popup.type.name.toUpperCase()),
        trailing: Switch(
          value: popup.isEnabled,
          onChanged: (value) {
            final updated = popups.map((p) {
              return p.id == popup.id ? p.copyWith(isEnabled: value) : p;
            }).toList();
            onUpdate(updated);
          },
        ),
      ),
    );
  }

  IconData _getIconForType(PopupTypeV2 type) {
    switch (type) {
      case PopupTypeV2.image:
        return Icons.image;
      case PopupTypeV2.coupon:
        return Icons.local_offer;
      case PopupTypeV2.emojiReaction:
        return Icons.emoji_emotions;
      case PopupTypeV2.bigPromo:
        return Icons.campaign;
      default:
        return Icons.message;
    }
  }

  void _addPopup(BuildContext context) {
    final newPopup = PopupV2Model.defaultPopup(order: popups.length);
    onUpdate([...popups, newPopup]);
  }
}
