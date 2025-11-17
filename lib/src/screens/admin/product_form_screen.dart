// lib/src/screens/admin/product_form_screen.dart
// Formulaire de création/modification de produit

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../design_system/app_theme.dart';
import '../../models/product.dart';
import '../../services/firestore_product_service.dart';
import '../../providers/ingredient_provider.dart';

/// Écran de formulaire pour créer ou modifier un produit
class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product; // null si création, non-null si modification
  final ProductCategory initialCategory;

  const ProductFormScreen({
    super.key,
    this.product,
    required this.initialCategory,
  });

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _orderController = TextEditingController();
  
  final FirestoreProductService _firestoreService = createFirestoreProductService();
  final _uuid = const Uuid();
  
  late ProductCategory _selectedCategory;
  late DisplaySpot _selectedDisplaySpot;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isBestSeller = false;
  bool _isNew = false;
  bool _isChefSpecial = false;
  bool _isKidFriendly = false;
  bool _isMenu = false;
  int _pizzaCount = 1;
  int _drinkCount = 0;
  bool _isSaving = false;
  
  // Nouveaux champs pour la gestion des ingrédients
  Set<String> _selectedBaseIngredients = {};
  Set<String> _selectedAllowedSupplements = {};

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    
    if (widget.product != null) {
      // Mode modification
      final product = widget.product!;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(2);
      _imageUrlController.text = product.imageUrl;
      _orderController.text = product.order.toString();
      _selectedCategory = product.category;
      _selectedDisplaySpot = product.displaySpot;
      _isActive = product.isActive;
      _isFeatured = product.isFeatured;
      _isBestSeller = product.isBestSeller;
      _isNew = product.isNew;
      _isChefSpecial = product.isChefSpecial;
      _isKidFriendly = product.isKidFriendly;
      _isMenu = product.isMenu;
      _pizzaCount = product.pizzaCount;
      _drinkCount = product.drinkCount;
      _selectedBaseIngredients = Set<String>.from(product.baseIngredients);
      _selectedAllowedSupplements = Set<String>.from(product.allowedSupplements);
    } else {
      // Mode création - valeurs par défaut
      _selectedDisplaySpot = DisplaySpot.all;
      _orderController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le produit' : 'Nouveau produit'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // Catégorie
            _buildSectionTitle('Informations de base'),
            _buildCategorySelector(),
            SizedBox(height: AppSpacing.md),
            
            // Nom
            _buildTextField(
              controller: _nameController,
              label: 'Nom du produit',
              hint: 'Ex: Pizza Margherita',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le nom est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),
            
            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Décrivez le produit',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La description est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),
            
            // Prix
            _buildTextField(
              controller: _priceController,
              label: 'Prix (€)',
              hint: 'Ex: 12.90',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            SizedBox(height: AppSpacing.md),
            
            // Image URL
            _buildTextField(
              controller: _imageUrlController,
              label: 'URL de l\'image',
              hint: 'https://...',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'URL de l\'image est obligatoire';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Paramètres d'affichage
            _buildSectionTitle('Paramètres d\'affichage'),
            _buildDisplaySpotSelector(),
            SizedBox(height: AppSpacing.md),
            
            _buildTextField(
              controller: _orderController,
              label: 'Ordre d\'affichage (priorité)',
              hint: '0',
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppSpacing.lg),
            
            // Caractéristiques
            _buildSectionTitle('Caractéristiques'),
            _buildSwitchTile('Produit actif', _isActive, (value) {
              setState(() => _isActive = value);
            }),
            _buildSwitchTile('Mis en avant', _isFeatured, (value) {
              setState(() => _isFeatured = value);
            }),
            _buildSwitchTile('Best-seller', _isBestSeller, (value) {
              setState(() => _isBestSeller = value);
            }),
            _buildSwitchTile('Nouveau', _isNew, (value) {
              setState(() => _isNew = value);
            }),
            _buildSwitchTile('Spécialité du chef', _isChefSpecial, (value) {
              setState(() => _isChefSpecial = value);
            }),
            _buildSwitchTile('Adapté aux enfants', _isKidFriendly, (value) {
              setState(() => _isKidFriendly = value);
            }),
            
            // Options menu (si catégorie Menus)
            if (_selectedCategory == ProductCategory.menus) ...[
              SizedBox(height: AppSpacing.lg),
              _buildSectionTitle('Options Menu'),
              _buildSwitchTile('Est un menu', _isMenu, (value) {
                setState(() => _isMenu = value);
              }),
              if (_isMenu) ...[
                SizedBox(height: AppSpacing.md),
                _buildNumberField(
                  label: 'Nombre de pizzas',
                  value: _pizzaCount,
                  onChanged: (value) => setState(() => _pizzaCount = value),
                ),
                SizedBox(height: AppSpacing.md),
                _buildNumberField(
                  label: 'Nombre de boissons',
                  value: _drinkCount,
                  onChanged: (value) => setState(() => _drinkCount = value),
                ),
              ],
            ],
            
            // Gestion des ingrédients (uniquement pour les pizzas)
            if (_selectedCategory == ProductCategory.pizza) ...[
              SizedBox(height: AppSpacing.lg),
              _buildSectionTitle('Ingrédients de base (retirables par le client)'),
              _buildIngredientSelector(isBaseIngredient: true),
              SizedBox(height: AppSpacing.lg),
              _buildSectionTitle('Suppléments autorisés'),
              _buildIngredientSelector(isBaseIngredient: false),
            ],
            
            SizedBox(height: AppSpacing.xl),
            
            // Bouton de sauvegarde
            FilledButton(
              onPressed: _isSaving ? null : _saveProduct,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppColors.primary,
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
                      isEditing ? 'Enregistrer les modifications' : 'Créer le produit',
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
        fillColor: AppColors.surface,
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
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Catégorie', style: AppTextStyles.labelLarge),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: ProductCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category.value),
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

  Widget _buildDisplaySpotSelector() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zone d\'affichage', style: AppTextStyles.labelLarge),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: DisplaySpot.values.map((spot) {
                final isSelected = _selectedDisplaySpot == spot;
                return ChoiceChip(
                  label: Text(spot.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedDisplaySpot = spot);
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
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.bodyMedium),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              value.toString(),
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientSelector({required bool isBaseIngredient}) {
    final ingredientsAsync = ref.watch(activeIngredientListProvider);
    
    return ingredientsAsync.when(
      data: (ingredients) {
        if (ingredients.isEmpty) {
          return Card(
            elevation: 0,
            color: AppColors.surface,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Aucun ingrédient disponible. Créez d\'abord des ingrédients dans la section "Ingrédients".',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        }
        
        return Card(
          elevation: 0,
          color: AppColors.surface,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBaseIngredient && _selectedBaseIngredients.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'Sélectionnez les ingrédients inclus par défaut',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (!isBaseIngredient && _selectedAllowedSupplements.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      'Sélectionnez les ingrédients autorisés en supplément',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: ingredients.map((ingredient) {
                    final isSelected = isBaseIngredient
                        ? _selectedBaseIngredients.contains(ingredient.id)
                        : _selectedAllowedSupplements.contains(ingredient.id);
                    
                    return FilterChip(
                      label: Text(
                        '${ingredient.name}${ingredient.extraCost > 0 ? ' (+${ingredient.extraCost.toStringAsFixed(2)}€)' : ''}',
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (isBaseIngredient) {
                            if (selected) {
                              _selectedBaseIngredients.add(ingredient.id);
                            } else {
                              _selectedBaseIngredients.remove(ingredient.id);
                            }
                          } else {
                            if (selected) {
                              _selectedAllowedSupplements.add(ingredient.id);
                            } else {
                              _selectedAllowedSupplements.remove(ingredient.id);
                            }
                          }
                        });
                      },
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Card(
        elevation: 0,
        color: AppColors.errorContainer,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Erreur lors du chargement des ingrédients: $error',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final product = Product(
        id: widget.product?.id ?? _uuid.v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: _imageUrlController.text.trim(),
        category: _selectedCategory,
        isActive: _isActive,
        displaySpot: _selectedDisplaySpot,
        order: int.tryParse(_orderController.text.trim()) ?? 0,
        isFeatured: _isFeatured,
        isBestSeller: _isBestSeller,
        isNew: _isNew,
        isChefSpecial: _isChefSpecial,
        isKidFriendly: _isKidFriendly,
        isMenu: _isMenu,
        pizzaCount: _pizzaCount,
        drinkCount: _drinkCount,
        baseIngredients: _selectedBaseIngredients.toList(),
        allowedSupplements: _selectedAllowedSupplements.toList(),
      );

      bool success = false;
      switch (_selectedCategory) {
        case ProductCategory.pizza:
          success = await _firestoreService.savePizza(product);
          break;
        case ProductCategory.menus:
          success = await _firestoreService.saveMenu(product);
          break;
        case ProductCategory.boissons:
          success = await _firestoreService.saveDrink(product);
          break;
        case ProductCategory.desserts:
          success = await _firestoreService.saveDessert(product);
          break;
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context, true); // Retourner true pour indiquer le succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product != null
                    ? 'Produit modifié avec succès'
                    : 'Produit créé avec succès',
              ),
            ),
          );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
