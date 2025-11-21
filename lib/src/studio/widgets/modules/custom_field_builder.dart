// lib/src/studio/widgets/modules/custom_field_builder.dart
// Custom field builder for free-layout sections

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../models/dynamic_section_model.dart';

class CustomFieldBuilder extends StatefulWidget {
  final List<CustomField> fields;
  final Function(List<CustomField>) onUpdate;

  const CustomFieldBuilder({
    super.key,
    required this.fields,
    required this.onUpdate,
  });

  @override
  State<CustomFieldBuilder> createState() => _CustomFieldBuilderState();
}

class _CustomFieldBuilderState extends State<CustomFieldBuilder> {
  late List<CustomField> _fields;

  @override
  void initState() {
    super.initState();
    _fields = List<CustomField>.from(widget.fields);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Champs personnalisés',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _showAddFieldDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter un champ'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (_fields.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.dashboard_customize_outlined,
                    size: 48,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun champ personnalisé',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fields.length,
            onReorder: _onReorder,
            itemBuilder: (context, index) {
              final field = _fields[index];
              return _buildFieldCard(field, index, key: ValueKey(field.key));
            },
          ),
      ],
    );
  }

  Widget _buildFieldCard(CustomField field, int index, {required Key key}) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.drag_indicator,
              color: Color(0xFF9E9E9E),
              size: 20,
            ),
          ),
        ),
        title: Text(
          field.label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_getFieldTypeLabel(field.type)} • ${field.key}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _editField(index, field),
              icon: const Icon(Icons.edit, size: 20),
              tooltip: 'Éditer',
            ),
            IconButton(
              onPressed: () => _deleteField(index),
              icon: const Icon(Icons.delete_outline, size: 20),
              tooltip: 'Supprimer',
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _fields.removeAt(oldIndex);
      _fields.insert(newIndex, item);
      widget.onUpdate(_fields);
    });
  }

  void _showAddFieldDialog() {
    _showFieldDialog(null, null);
  }

  void _editField(int index, CustomField field) {
    _showFieldDialog(index, field);
  }

  void _deleteField(int index) {
    setState(() {
      _fields.removeAt(index);
      widget.onUpdate(_fields);
    });
  }

  void _showFieldDialog(int? index, CustomField? field) {
    final keyController = TextEditingController(text: field?.key ?? '');
    final labelController = TextEditingController(text: field?.label ?? '');
    CustomFieldType selectedType = field?.type ?? CustomFieldType.textShort;
    final valueController = TextEditingController(
      text: field?.value?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(field != null ? 'Éditer le champ' : 'Nouveau champ'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: keyController,
                    decoration: const InputDecoration(
                      labelText: 'Clé du champ *',
                      hintText: 'Ex: heroTitle, promoText',
                      border: OutlineInputBorder(),
                      helperText: 'Identifiant unique (pas d\'espaces)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(
                      labelText: 'Libellé *',
                      hintText: 'Ex: Titre du hero, Texte promo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CustomFieldType>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type de champ',
                      border: OutlineInputBorder(),
                    ),
                    items: CustomFieldType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getFieldTypeIcon(type), size: 20),
                            const SizedBox(width: 8),
                            Text(_getFieldTypeLabel(type)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valueController,
                    decoration: InputDecoration(
                      labelText: 'Valeur par défaut',
                      hintText: _getFieldValueHint(selectedType),
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: selectedType == CustomFieldType.textLong ||
                            selectedType == CustomFieldType.json
                        ? 4
                        : 1,
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
              onPressed: () {
                final key = keyController.text.trim();
                final label = labelController.text.trim();

                if (key.isEmpty || label.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La clé et le libellé sont requis'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Check for duplicate keys (except when editing the same field)
                final duplicateExists = _fields.any((f) =>
                    f.key == key && (index == null || _fields[index].key != key));
                if (duplicateExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cette clé existe déjà'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final newField = CustomField(
                  key: key,
                  label: label,
                  type: selectedType,
                  value: valueController.text.isNotEmpty
                      ? valueController.text
                      : null,
                );

                setState(() {
                  if (index != null) {
                    _fields[index] = newField;
                  } else {
                    _fields.add(newField);
                  }
                  widget.onUpdate(_fields);
                });

                Navigator.of(context).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  String _getFieldTypeLabel(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.textShort:
        return 'Texte court';
      case CustomFieldType.textLong:
        return 'Texte long';
      case CustomFieldType.image:
        return 'Image';
      case CustomFieldType.color:
        return 'Couleur';
      case CustomFieldType.cta:
        return 'Call-to-Action';
      case CustomFieldType.list:
        return 'Liste';
      case CustomFieldType.json:
        return 'JSON';
    }
  }

  IconData _getFieldTypeIcon(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.textShort:
        return Icons.short_text;
      case CustomFieldType.textLong:
        return Icons.notes;
      case CustomFieldType.image:
        return Icons.image;
      case CustomFieldType.color:
        return Icons.palette;
      case CustomFieldType.cta:
        return Icons.touch_app;
      case CustomFieldType.list:
        return Icons.list;
      case CustomFieldType.json:
        return Icons.code;
    }
  }

  String _getFieldValueHint(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.textShort:
        return 'Texte simple';
      case CustomFieldType.textLong:
        return 'Texte multiligne';
      case CustomFieldType.image:
        return 'URL de l\'image';
      case CustomFieldType.color:
        return '#RRGGBB';
      case CustomFieldType.cta:
        return '{"text": "...", "url": "..."}';
      case CustomFieldType.list:
        return '["item1", "item2"]';
      case CustomFieldType.json:
        return '{"key": "value"}';
    }
  }
}
