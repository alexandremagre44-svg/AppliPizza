// lib/src/studio/widgets/modules/section_editor_dialog.dart
// Section Editor Dialog for Dynamic Sections Builder PRO

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../models/dynamic_section_model.dart';
import 'custom_field_builder.dart';

class SectionEditorDialog extends StatefulWidget {
  final DynamicSection? section;
  final Function(DynamicSection) onSave;

  const SectionEditorDialog({
    super.key,
    this.section,
    required this.onSave,
  });

  @override
  State<SectionEditorDialog> createState() => _SectionEditorDialogState();
}

class _SectionEditorDialogState extends State<SectionEditorDialog> {
  late DynamicSectionType _selectedType;
  late DynamicSectionLayout _selectedLayout;
  late bool _isActive;
  late Map<String, dynamic> _content;
  late SectionConditions _conditions;

  // Condition form controllers
  List<int> _selectedDays = [];
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _requireLoggedIn = false;
  int? _requireOrdersMin;
  double? _requireCartMin;
  bool _applyOncePerSession = false;

  // Content controllers
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _textController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _ctaTextController = TextEditingController();
  final _ctaUrlController = TextEditingController();

  // Custom fields for free-layout sections
  List<CustomField> _customFields = [];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    
    if (widget.section != null) {
      // Edit mode
      _selectedType = widget.section!.type;
      _selectedLayout = widget.section!.layout;
      _isActive = widget.section!.active;
      _content = Map<String, dynamic>.from(widget.section!.content);
      _conditions = widget.section!.conditions;
      
      // Initialize condition fields
      _selectedDays = List<int>.from(_conditions.days ?? []);
      _requireLoggedIn = _conditions.requireLoggedIn;
      _requireOrdersMin = _conditions.requireOrdersMin;
      _requireCartMin = _conditions.requireCartMin;
      _applyOncePerSession = _conditions.applyOncePerSession;
      
      if (_conditions.hoursStart != null) {
        final parts = _conditions.hoursStart!.split(':');
        _startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      if (_conditions.hoursEnd != null) {
        final parts = _conditions.hoursEnd!.split(':');
        _endTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      
      // Initialize content fields
      _titleController.text = _content['title'] ?? '';
      _subtitleController.text = _content['subtitle'] ?? '';
      _textController.text = _content['text'] ?? '';
      _imageUrlController.text = _content['imageUrl'] ?? '';
      _ctaTextController.text = _content['ctaText'] ?? '';
      _ctaUrlController.text = _content['ctaUrl'] ?? '';
      
      // Initialize custom fields if it's a free-layout section
      if (_selectedType == DynamicSectionType.freeLayout && _content['customFields'] != null) {
        try {
          _customFields = (_content['customFields'] as List<dynamic>)
              .map((e) => CustomField.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          debugPrint('Error parsing custom fields: $e');
          _customFields = [];
        }
      }
    } else {
      // Create mode
      _selectedType = DynamicSectionType.text;
      _selectedLayout = DynamicSectionLayout.full;
      _isActive = true;
      _content = {};
      _conditions = const SectionConditions();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _textController.dispose();
    _imageUrlController.dispose();
    _ctaTextController.dispose();
    _ctaUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: screenWidth > 800 ? 800 : screenWidth * 0.9,
        height: screenHeight > 700 ? 700 : screenHeight * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.section != null ? 'Éditer la section' : 'Nouvelle section',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Stepper
            Expanded(
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: _onStepContinue,
                onStepCancel: _onStepCancel,
                onStepTapped: (step) => setState(() => _currentStep = step),
                controlsBuilder: (context, details) {
                  return Row(
                    children: [
                      if (_currentStep < 2)
                        FilledButton(
                          onPressed: details.onStepContinue,
                          child: const Text('Suivant'),
                        ),
                      if (_currentStep == 2)
                        FilledButton(
                          onPressed: _saveSection,
                          child: const Text('Enregistrer'),
                        ),
                      const SizedBox(width: 8),
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Précédent'),
                        ),
                    ],
                  );
                },
                steps: [
                  Step(
                    title: const Text('Type et Layout'),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                    content: _buildTypeStep(),
                  ),
                  Step(
                    title: const Text('Contenu'),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                    content: _buildContentStep(),
                  ),
                  Step(
                    title: const Text('Conditions'),
                    isActive: _currentStep >= 2,
                    content: _buildConditionsStep(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de section',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: DynamicSectionType.values.map((type) {
            final isSelected = _selectedType == type;
            return ChoiceChip(
              label: Text(_getSectionTypeName(type)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedType = type);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Text(
          'Layout',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: DynamicSectionLayout.values.map((layout) {
            final isSelected = _selectedLayout == layout;
            return ChoiceChip(
              label: Text(layout.value.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedLayout = layout);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Section active'),
          value: _isActive,
          onChanged: (value) => setState(() => _isActive = value),
        ),
      ],
    );
  }

  Widget _buildContentStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contenu de la section',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          
          // Common fields for most section types
          if (_shouldShowField('title'))
            _buildTextField(
              controller: _titleController,
              label: 'Titre',
              hint: 'Entrez le titre de la section',
            ),
          
          if (_shouldShowField('subtitle'))
            _buildTextField(
              controller: _subtitleController,
              label: 'Sous-titre',
              hint: 'Entrez le sous-titre (optionnel)',
            ),
          
          if (_shouldShowField('text'))
            _buildTextField(
              controller: _textController,
              label: 'Texte',
              hint: 'Entrez le contenu textuel',
              maxLines: 4,
            ),
          
          if (_shouldShowField('image'))
            _buildTextField(
              controller: _imageUrlController,
              label: 'URL de l\'image',
              hint: 'https://...',
            ),
          
          if (_shouldShowField('cta'))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 32),
                const Text(
                  'Call-to-Action',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _ctaTextController,
                  label: 'Texte du bouton',
                  hint: 'Ex: Commander maintenant',
                ),
                _buildTextField(
                  controller: _ctaUrlController,
                  label: 'URL de destination',
                  hint: 'Ex: /menu',
                ),
              ],
            ),
          
          // Custom fields for free-layout sections
          if (_selectedType == DynamicSectionType.freeLayout)
            Column(
              children: [
                const Divider(height: 32),
                CustomFieldBuilder(
                  fields: _customFields,
                  onUpdate: (fields) {
                    setState(() => _customFields = fields);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildConditionsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conditions d\'affichage',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configurez quand et pour qui cette section doit être visible',
            style: TextStyle(color: Color(0xFF757575), fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          // Days of week
          const Text('Jours de la semaine', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildDayChip(1, 'Lun'),
              _buildDayChip(2, 'Mar'),
              _buildDayChip(3, 'Mer'),
              _buildDayChip(4, 'Jeu'),
              _buildDayChip(5, 'Ven'),
              _buildDayChip(6, 'Sam'),
              _buildDayChip(7, 'Dim'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Time range
          const Text('Plage horaire', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectTime(true),
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    _startTime != null
                        ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                        : 'Heure début',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _selectTime(false),
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    _endTime != null
                        ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                        : 'Heure fin',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // User requirements
          const Text('Conditions utilisateur', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Utilisateur connecté uniquement'),
            value: _requireLoggedIn,
            onChanged: (value) => setState(() => _requireLoggedIn = value),
          ),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Nombre minimum de commandes',
              hintText: 'Ex: 3',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(
              text: _requireOrdersMin?.toString() ?? '',
            ),
            onChanged: (value) {
              _requireOrdersMin = int.tryParse(value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Montant minimum du panier (€)',
              hintText: 'Ex: 25.00',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: TextEditingController(
              text: _requireCartMin?.toString() ?? '',
            ),
            onChanged: (value) {
              _requireCartMin = double.tryParse(value);
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Afficher une seule fois par session'),
            value: _applyOncePerSession,
            onChanged: (value) => setState(() => _applyOncePerSession = value),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDayChip(int day, String label) {
    final isSelected = _selectedDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(day);
          } else {
            _selectedDays.remove(day);
          }
        });
      },
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final time = await showTimePicker(
      context: context,
      initialTime: (isStart ? _startTime : _endTime) ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  bool _shouldShowField(String fieldName) {
    switch (_selectedType) {
      case DynamicSectionType.hero:
        return ['title', 'subtitle', 'image', 'cta'].contains(fieldName);
      case DynamicSectionType.promoSimple:
        return ['title', 'text', 'cta'].contains(fieldName);
      case DynamicSectionType.promoAdvanced:
        return ['title', 'subtitle', 'text', 'image', 'cta'].contains(fieldName);
      case DynamicSectionType.text:
        return ['title', 'text'].contains(fieldName);
      case DynamicSectionType.image:
        return ['title', 'image'].contains(fieldName);
      case DynamicSectionType.grid:
      case DynamicSectionType.carousel:
      case DynamicSectionType.categories:
      case DynamicSectionType.products:
        return ['title', 'subtitle'].contains(fieldName);
      case DynamicSectionType.freeLayout:
        return true; // All fields for custom layouts
    }
  }

  String _getSectionTypeName(DynamicSectionType type) {
    switch (type) {
      case DynamicSectionType.hero:
        return 'Hero';
      case DynamicSectionType.promoSimple:
        return 'Promo Simple';
      case DynamicSectionType.promoAdvanced:
        return 'Promo Avancée';
      case DynamicSectionType.text:
        return 'Texte';
      case DynamicSectionType.image:
        return 'Image';
      case DynamicSectionType.grid:
        return 'Grille';
      case DynamicSectionType.carousel:
        return 'Carrousel';
      case DynamicSectionType.categories:
        return 'Catégories';
      case DynamicSectionType.products:
        return 'Produits';
      case DynamicSectionType.freeLayout:
        return 'Layout Libre';
    }
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _saveSection() {
    // Build content map from controllers
    _content = {
      if (_titleController.text.isNotEmpty) 'title': _titleController.text,
      if (_subtitleController.text.isNotEmpty) 'subtitle': _subtitleController.text,
      if (_textController.text.isNotEmpty) 'text': _textController.text,
      if (_imageUrlController.text.isNotEmpty) 'imageUrl': _imageUrlController.text,
      if (_ctaTextController.text.isNotEmpty) 'ctaText': _ctaTextController.text,
      if (_ctaUrlController.text.isNotEmpty) 'ctaUrl': _ctaUrlController.text,
    };

    // Add custom fields for free-layout sections
    if (_selectedType == DynamicSectionType.freeLayout && _customFields.isNotEmpty) {
      _content['customFields'] = _customFields.map((f) => f.toJson()).toList();
    }

    // Build conditions
    _conditions = SectionConditions(
      days: _selectedDays.isEmpty ? null : _selectedDays,
      hoursStart: _startTime != null
          ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
          : null,
      hoursEnd: _endTime != null
          ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
          : null,
      requireLoggedIn: _requireLoggedIn,
      requireOrdersMin: _requireOrdersMin,
      requireCartMin: _requireCartMin,
      applyOncePerSession: _applyOncePerSession,
    );

    // Create or update section
    final section = widget.section?.copyWith(
      type: _selectedType,
      layout: _selectedLayout,
      active: _isActive,
      content: _content,
      conditions: _conditions,
      updatedAt: DateTime.now(),
    ) ?? DynamicSection(
      type: _selectedType,
      layout: _selectedLayout,
      active: _isActive,
      content: _content,
      conditions: _conditions,
    );

    widget.onSave(section);
    Navigator.of(context).pop();
  }
}
