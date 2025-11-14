// lib/src/screens/admin/studio/dialogs/edit_block_dialog.dart
// Dialog for creating/editing dynamic blocks

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/dynamic_block_model.dart';
import '../../../../shared/theme/app_theme.dart';

class EditBlockDialog extends StatefulWidget {
  final DynamicBlock? block;
  final Function(DynamicBlock) onSave;

  const EditBlockDialog({
    super.key,
    this.block,
    required this.onSave,
  });

  @override
  State<EditBlockDialog> createState() => _EditBlockDialogState();
}

class _EditBlockDialogState extends State<EditBlockDialog> {
  late TextEditingController _titleController;
  late TextEditingController _maxItemsController;
  late TextEditingController _orderController;
  
  String _selectedType = 'featuredProducts';
  bool _isVisible = true;

  bool get _isEditing => widget.block != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      _titleController = TextEditingController(text: widget.block!.title);
      _maxItemsController = TextEditingController(text: widget.block!.maxItems.toString());
      _orderController = TextEditingController(text: widget.block!.order.toString());
      _selectedType = widget.block!.type;
      _isVisible = widget.block!.isVisible;
    } else {
      _titleController = TextEditingController();
      _maxItemsController = TextEditingController(text: '6');
      _orderController = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _maxItemsController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le titre est requis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final maxItems = int.tryParse(_maxItemsController.text) ?? 6;
    final order = int.tryParse(_orderController.text) ?? 0;

    if (maxItems < 1 || maxItems > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nombre d\'items doit être entre 1 et 20'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final block = _isEditing
        ? widget.block!.copyWith(
            type: _selectedType,
            title: _titleController.text.trim(),
            maxItems: maxItems,
            order: order,
            isVisible: _isVisible,
          )
        : DynamicBlock(
            id: const Uuid().v4(),
            type: _selectedType,
            title: _titleController.text.trim(),
            maxItems: maxItems,
            order: order,
            isVisible: _isVisible,
          );

    widget.onSave(block);
    Navigator.of(context).pop();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'featuredProducts':
        return Icons.star;
      case 'categories':
        return Icons.category;
      case 'bestSellers':
        return Icons.trending_up;
      default:
        return Icons.view_agenda;
    }
  }

  String _getDescriptionForType(String type) {
    switch (type) {
      case 'featuredProducts':
        return 'Produits mis en avant';
      case 'categories':
        return 'Liste des catégories';
      case 'bestSellers':
        return 'Produits les plus vendus';
      default:
        return '';
    }
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
                    Icon(
                      _isEditing ? Icons.edit : Icons.add_box,
                      color: AppColors.primaryRed,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isEditing ? 'Modifier le bloc' : 'Nouveau bloc',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Type selector
                const Text(
                  'Type de bloc',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...DynamicBlock.validTypes.map((type) {
                  return RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: type,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                    title: Row(
                      children: [
                        Icon(_getIconForType(type), size: 20),
                        const SizedBox(width: 8),
                        Text(_getDescriptionForType(type)),
                      ],
                    ),
                    activeColor: AppColors.primaryRed,
                  );
                }),
                const Divider(height: 32),

                // Title field
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.title),
                    helperText: 'Ex: "Nos spécialités", "Best-sellers"',
                  ),
                ),
                const SizedBox(height: 16),

                // Max items and order in a row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _maxItemsController,
                        decoration: InputDecoration(
                          labelText: 'Nombre max',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.format_list_numbered),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _orderController,
                        decoration: InputDecoration(
                          labelText: 'Position',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.sort),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Visibility toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Bloc visible'),
                  subtitle: Text(
                    _isVisible ? 'Le bloc sera affiché' : 'Le bloc sera masqué',
                    style: TextStyle(
                      color: _isVisible ? Colors.green : Colors.grey,
                    ),
                  ),
                  value: _isVisible,
                  activeColor: AppColors.primaryRed,
                  onChanged: (value) {
                    setState(() {
                      _isVisible = value;
                    });
                  },
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
                      child: Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
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
