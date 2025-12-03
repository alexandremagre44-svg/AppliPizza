// lib/src/screens/admin/ingredient_form_screen.dart
// Formulaire de création/modification d'ingrédient

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../design_system/app_theme.dart'; // Keep for AppSpacing, AppRadius, AppTextStyles
import '../../models/product.dart';
import '../../services/firestore_ingredient_service.dart';

/// Écran de formulaire pour créer ou modifier un ingrédient
class IngredientFormScreen extends ConsumerStatefulWidget {
  final Ingredient? ingredient; // null si création, non-null si modification

  const IngredientFormScreen({
    super.key,
    this.ingredient,
  });

  @override
  ConsumerState<IngredientFormScreen> createState() => _IngredientFormScreenState();
}

class _IngredientFormScreenState extends ConsumerState<IngredientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _orderController = TextEditingController();
  
  final _uuid = const Uuid();
  
  // Use getter to access service when needed (avoids initState ref.read issue)
  FirestoreIngredientService get _firestoreService => ref.read(firestoreIngredientServiceProvider);
  
  late IngredientCategory _selectedCategory;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.ingredient != null) {
      // Mode modification
      final ingredient = widget.ingredient!;
      _nameController.text = ingredient.name;
      _priceController.text = ingredient.extraCost.toStringAsFixed(2);
      _orderController.text = ingredient.order.toString();
      _selectedCategory = ingredient.category;
      _isActive = ingredient.isActive;
    } else {
      // Mode création - valeurs par défaut
      _selectedCategory = IngredientCategory.autre;
      _priceController.text = '0.00';
      _orderController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ingredient != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier l\'ingrédient' : 'Nouvel ingrédient'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // Informations de base
            _buildSectionTitle('Informations de base'),
            
            // Nom
            _buildTextField(
              controller: _nameController,
              label: 'Nom de l\'ingrédient',
              hint: 'Ex: Mozzarella, Jambon, Tomate',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),
            
            // Prix
            _buildTextField(
              controller: _priceController,
              label: 'Prix supplémentaire (€)',
              hint: 'Ex: 1.50',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le prix est obligatoire';
                }
                if (double.tryParse(value) == null) {
                  return 'Prix invalide';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Catégorie
            _buildSectionTitle('Catégorie'),
            _buildCategorySelector(),
            SizedBox(height: AppSpacing.lg),
            
            // Paramètres d'affichage
            _buildSectionTitle('Paramètres d\'affichage'),
            _buildTextField(
              controller: _orderController,
              label: 'Ordre d\'affichage (priorité)',
              hint: '0',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppSpacing.md),
            
            // Statut actif/inactif
            _buildSwitchTile('Ingrédient actif', _isActive, (value) {
              setState(() => _isActive = value);
            }),
            
            SizedBox(height: AppSpacing.md),
            
            // Info box
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: AppRadius.radiusSmall,
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Cet ingrédient sera disponible pour toutes les pizzas. '
                      'Les clients pourront l\'ajouter lors de la personnalisation.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.xl),
            
            // Bouton de sauvegarde
            FilledButton(
              onPressed: _isSaving ? null : _saveIngredient,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: colorScheme.primary,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isEditing ? 'Enregistrer les modifications' : 'Créer l\'ingrédient',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusSmall,
          borderSide: BorderSide.none,
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildCategorySelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sélectionnez une catégorie', style: AppTextStyles.labelLarge),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: IngredientCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.bodyMedium),
        value: value,
        onChanged: onChanged,
        activeColor: colorScheme.primary,
      ),
    );
  }

  Future<void> _saveIngredient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final ingredient = Ingredient(
        id: widget.ingredient?.id ?? _uuid.v4(),
        name: _nameController.text.trim(),
        extraCost: double.parse(_priceController.text),
        category: _selectedCategory,
        isActive: _isActive,
        order: int.tryParse(_orderController.text) ?? 0,
      );

      final success = await _firestoreService.saveIngredient(ingredient);

      if (mounted) {
        setState(() => _isSaving = false);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.ingredient != null 
                    ? 'Ingrédient modifié avec succès'
                    : 'Ingrédient créé avec succès',
              ),
            ),
          );
          Navigator.of(context).pop(true); // Retourne true pour indiquer le succès
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la sauvegarde'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
