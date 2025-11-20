// lib/src/studio/widgets/modules/studio_texts_v2.dart
// Texts module V2 - Dynamic CRUD text blocks system

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../models/text_block_model.dart';

class StudioTextsV2 extends StatelessWidget {
  final List<TextBlockModel> textBlocks;
  final Function(List<TextBlockModel>) onUpdate;

  const StudioTextsV2({
    super.key,
    required this.textBlocks,
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
                    Text('Textes Dynamiques', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Système CRUD pour blocs de texte illimités', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _addTextBlock(context),
                icon: const Icon(Icons.add),
                label: const Text('Nouveau bloc'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (textBlocks.isEmpty)
            const Center(child: Text('Aucun bloc de texte configuré'))
          else
            ...textBlocks.map((block) => _buildTextBlockCard(context, block)),
        ],
      ),
    );
  }

  Widget _buildTextBlockCard(BuildContext context, TextBlockModel block) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(_getIconForType(block.type)),
        title: Text(block.displayName),
        subtitle: Text('${block.category} • ${block.type.name}'),
        trailing: Switch(
          value: block.isEnabled,
          onChanged: (value) {
            final updated = textBlocks.map((t) {
              return t.id == block.id ? t.copyWith(isEnabled: value) : t;
            }).toList();
            onUpdate(updated);
          },
        ),
      ),
    );
  }

  IconData _getIconForType(TextBlockType type) {
    switch (type) {
      case TextBlockType.short:
        return Icons.short_text;
      case TextBlockType.long:
        return Icons.notes;
      case TextBlockType.markdown:
        return Icons.code;
      case TextBlockType.html:
        return Icons.html;
    }
  }

  void _addTextBlock(BuildContext context) {
    final newBlock = TextBlockModel.defaultBlock(
      category: 'home',
      order: textBlocks.length,
    );
    onUpdate([...textBlocks, newBlock]);
  }
}
