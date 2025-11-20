// lib/src/studio/widgets/modules/studio_texts_v2.dart
// Texts module V2 - Professional dynamic CRUD text blocks system

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../models/text_block_model.dart';

class StudioTextsV2 extends StatefulWidget {
  final List<TextBlockModel> textBlocks;
  final Function(List<TextBlockModel>) onUpdate;

  const StudioTextsV2({
    super.key,
    required this.textBlocks,
    required this.onUpdate,
  });

  @override
  State<StudioTextsV2> createState() => _StudioTextsV2State();
}

class _StudioTextsV2State extends State<StudioTextsV2> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    // Get unique categories
    final categories = {'all', ...widget.textBlocks.map((b) => b.category)}.toList();
    
    // Filter blocks by category
    final filteredBlocks = _selectedCategory == 'all'
        ? widget.textBlocks
        : widget.textBlocks.where((b) => b.category == _selectedCategory).toList();
    
    // Sort by order
    final sortedBlocks = List<TextBlockModel>.from(filteredBlocks)
      ..sort((a, b) => a.order.compareTo(b.order));

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
                      'Textes Dynamiques',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Système flexible de blocs de texte pour personnalisation complète',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _addTextBlock,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Nouveau bloc'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Category filter
          if (categories.length > 1)
            Wrap(
              spacing: 8,
              children: categories.map((category) {
                final isSelected = category == _selectedCategory;
                final count = category == 'all'
                    ? widget.textBlocks.length
                    : widget.textBlocks.where((b) => b.category == category).length;
                
                return FilterChip(
                  label: Text('${category.toUpperCase()} ($count)'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),

          // Text blocks list or empty state
          if (sortedBlocks.isEmpty)
            _buildEmptyState()
          else
            ...sortedBlocks.map((block) => _buildTextBlockCard(block)),
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
              Icons.text_fields_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun bloc de texte',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez des blocs de texte réutilisables pour votre application',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _addTextBlock,
              icon: const Icon(Icons.add),
              label: const Text('Créer un bloc'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextBlockCard(TextBlockModel block) {
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
          onTap: () => _editTextBlock(block),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getColorForType(block.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconForType(block.type),
                    color: _getColorForType(block.type),
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
                        block.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              block.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getTypeLabel(block.type),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                          // Slug badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.tag, size: 12, color: Colors.grey[700]),
                                const SizedBox(width: 4),
                                Text(
                                  block.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (block.content.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          block.content,
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
                      value: block.isEnabled,
                      onChanged: (value) {
                        _toggleTextBlock(block, value);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showTextBlockMenu(block),
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

  Color _getColorForType(TextBlockType type) {
    switch (type) {
      case TextBlockType.short:
        return Colors.blue;
      case TextBlockType.long:
        return Colors.green;
      case TextBlockType.markdown:
        return Colors.orange;
      case TextBlockType.html:
        return Colors.purple;
    }
  }

  String _getTypeLabel(TextBlockType type) {
    switch (type) {
      case TextBlockType.short:
        return 'Court';
      case TextBlockType.long:
        return 'Long';
      case TextBlockType.markdown:
        return 'Markdown';
      case TextBlockType.html:
        return 'HTML';
    }
  }

  void _addTextBlock() {
    final newBlock = TextBlockModel.defaultBlock(
      category: _selectedCategory == 'all' ? 'home' : _selectedCategory,
      order: widget.textBlocks.length,
    );
    _editTextBlock(newBlock, isNew: true);
  }

  void _editTextBlock(TextBlockModel block, {bool isNew = false}) {
    showDialog(
      context: context,
      builder: (context) => _TextBlockEditDialog(
        block: block,
        isNew: isNew,
        existingNames: widget.textBlocks.where((b) => b.id != block.id).map((b) => b.name).toSet(),
        onSave: (updatedBlock) {
          setState(() {
            if (isNew) {
              widget.onUpdate([...widget.textBlocks, updatedBlock]);
            } else {
              final updated = widget.textBlocks.map((b) {
                return b.id == updatedBlock.id ? updatedBlock : b;
              }).toList();
              widget.onUpdate(updated);
            }
          });
        },
      ),
    );
  }

  void _toggleTextBlock(TextBlockModel block, bool value) {
    final updated = widget.textBlocks.map((b) {
      return b.id == block.id ? b.copyWith(isEnabled: value) : b;
    }).toList();
    widget.onUpdate(updated);
  }

  void _showTextBlockMenu(TextBlockModel block) {
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
                _editTextBlock(block);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteTextBlock(block);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTextBlock(TextBlockModel block) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer le bloc ?'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${block.displayName}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final updated = widget.textBlocks.where((b) => b.id != block.id).toList();
              widget.onUpdate(updated);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// Text Block Edit Dialog (simplified)
class _TextBlockEditDialog extends StatefulWidget {
  final TextBlockModel block;
  final bool isNew;
  final Set<String> existingNames;
  final Function(TextBlockModel) onSave;

  const _TextBlockEditDialog({
    required this.block,
    required this.isNew,
    required this.existingNames,
    required this.onSave,
  });

  @override
  State<_TextBlockEditDialog> createState() => _TextBlockEditDialogState();
}

class _TextBlockEditDialogState extends State<_TextBlockEditDialog> {
  late TextEditingController _displayNameController;
  late TextEditingController _nameController;
  late TextEditingController _contentController;
  late TextEditingController _categoryController;
  late TextBlockModel _editedBlock;

  @override
  void initState() {
    super.initState();
    _editedBlock = widget.block;
    _displayNameController = TextEditingController(text: widget.block.displayName);
    _nameController = TextEditingController(text: widget.block.name);
    _contentController = TextEditingController(text: widget.block.content);
    _categoryController = TextEditingController(text: widget.block.category);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _nameController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNameTaken = !widget.isNew && widget.existingNames.contains(_nameController.text);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
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
                      widget.isNew ? 'Nouveau bloc de texte' : 'Modifier le bloc',
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

              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom affiché *',
                  helperText: 'Nom visible dans l\'interface admin',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _editedBlock = _editedBlock.copyWith(displayName: value);
                  });
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Slug (identifiant technique) *',
                  helperText: isNameTaken 
                      ? 'Ce slug est déjà utilisé'
                      : 'Identifiant unique en lecture seule après création',
                  errorText: isNameTaken ? 'Slug déjà utilisé' : null,
                  border: const OutlineInputBorder(),
                ),
                enabled: widget.isNew,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: widget.isNew ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  helperText: 'Ex: home, menu, cart, profile',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _editedBlock = _editedBlock.copyWith(category: value);
                  });
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<TextBlockType>(
                value: _editedBlock.type,
                decoration: const InputDecoration(
                  labelText: 'Type de contenu',
                  border: OutlineInputBorder(),
                ),
                items: TextBlockType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _editedBlock = _editedBlock.copyWith(type: value);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  helperText: 'Texte affiché dans l\'application',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                onChanged: (value) {
                  setState(() {
                    _editedBlock = _editedBlock.copyWith(content: value);
                  });
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
                    onPressed: _displayNameController.text.isEmpty || 
                               _nameController.text.isEmpty ||
                               isNameTaken
                        ? null
                        : _save,
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

  String _getTypeLabel(TextBlockType type) {
    switch (type) {
      case TextBlockType.short:
        return 'Court (1 ligne)';
      case TextBlockType.long:
        return 'Long (paragraphe)';
      case TextBlockType.markdown:
        return 'Markdown';
      case TextBlockType.html:
        return 'HTML';
    }
  }

  void _save() {
    final finalBlock = _editedBlock.copyWith(
      displayName: _displayNameController.text,
      name: _nameController.text,
      category: _categoryController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );
    widget.onSave(finalBlock);
    Navigator.pop(context);
  }
}
