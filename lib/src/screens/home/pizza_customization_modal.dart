// lib/src/screens/home/pizza_customization_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/product.dart';
import '../../data/mock_data.dart';
import '../../providers/cart_provider.dart';
import '../../design_system/app_theme.dart';

const _uuid = Uuid();

class PizzaCustomizationModal extends ConsumerStatefulWidget {
  final Product pizza;

  const PizzaCustomizationModal({super.key, required this.pizza});

  @override
  ConsumerState<PizzaCustomizationModal> createState() =>
      _PizzaCustomizationModalState();
}

class _PizzaCustomizationModalState
    extends ConsumerState<PizzaCustomizationModal> {
  
  // Ingrédients de base (peuvent être retirés)
  late Set<String> _baseIngredients;
  
  // Ingrédients supplémentaires (ajoutés par l'utilisateur)
  final Set<String> _extraIngredients = {};
  
  // Taille sélectionnée
  String _selectedSize = 'Moyenne';
  
  // Note spéciale
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _baseIngredients = Set<String>.from(widget.pizza.baseIngredients);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double price = widget.pizza.price;
    
    // Ajustement selon la taille
    if (_selectedSize == 'Grande') {
      price += 3.0;
    }
    
    // Coût des suppléments
    for (final ingredientName in _extraIngredients) {
      final ingredient = mockIngredients.firstWhere(
        (ing) => ing.name == ingredientName,
        orElse: () => Ingredient(id: '', name: '', extraCost: 1.0),
      );
      price += ingredient.extraCost;
    }
    
    return price;
  }

  String _buildCustomDescription() {
    final List<String> details = [];
    
    // Taille
    details.add('Taille: $_selectedSize');
    
    // Ingrédients retirés
    final removed = widget.pizza.baseIngredients
        .where((ing) => !_baseIngredients.contains(ing))
        .toList();
    if (removed.isNotEmpty) {
      details.add('Sans: ${removed.join(', ')}');
    }
    
    // Ingrédients ajoutés
    if (_extraIngredients.isNotEmpty) {
      details.add('Avec: ${_extraIngredients.join(', ')}');
    }
    
    // Note
    if (_notesController.text.isNotEmpty) {
      details.add('Note: ${_notesController.text}');
    }
    
    return details.join(' • ');
  }

  void _addToCart() {
    final cartNotifier = ref.read(cartProvider.notifier);
    
    final newCartItem = CartItem(
      id: _uuid.v4(),
      productId: widget.pizza.id,
      productName: widget.pizza.name,
      price: _totalPrice,
      quantity: 1,
      imageUrl: widget.pizza.imageUrl,
      customDescription: _buildCustomDescription(),
      isMenu: false,
    );

    cartNotifier.addExistingItem(newCartItem);
    Navigator.of(context).pop();
  }

  // Catégorisation des ingrédients
  List<Ingredient> get _fromageIngredients {
    return mockIngredients.where((ing) => 
      ing.name.toLowerCase().contains('mozza') ||
      ing.name.toLowerCase().contains('cheddar') ||
      ing.name.toLowerCase().contains('fromage')
    ).toList();
  }

  List<Ingredient> get _garnituresIngredients {
    return mockIngredients.where((ing) => 
      ing.name.toLowerCase().contains('jambon') ||
      ing.name.toLowerCase().contains('poulet') ||
      ing.name.toLowerCase().contains('chorizo')
    ).toList();
  }

  List<Ingredient> get _supplementsIngredients {
    return mockIngredients.where((ing) => 
      ing.name.toLowerCase().contains('oignon') ||
      ing.name.toLowerCase().contains('champignon') ||
      ing.name.toLowerCase().contains('olive')
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: AppRadius.bottomSheet.topLeft),
      ),
      child: Column(
        children: [
          // Drag handle Material 3
          Padding(
            padding: AppSpacing.paddingVerticalSM,
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: AppRadius.radiusFull,
              ),
            ),
          ),
          
          // Contenu avec scroll unique
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visuel de la pizza en haut
                  _buildPizzaPreview(context),
                  
                  AppSpacing.verticalSpaceLG,
                  
                  // Section Taille avec SegmentedButton
                  _buildCategorySection(
                    title: 'Taille',
                    icon: Icons.straighten_rounded,
                    child: _buildSizeOptions(),
                  ),
                  
                  AppSpacing.verticalSpaceLG,
                  
                  // Section Ingrédients de base
                  _buildCategorySection(
                    title: 'Ingrédients de base',
                    subtitle: 'Retirez ce que vous ne souhaitez pas',
                    icon: Icons.inventory_2_rounded,
                    child: _buildBaseIngredientsOptions(),
                  ),
                  
                  AppSpacing.verticalSpaceLG,
                  
                  // Section Fromages
                  if (_fromageIngredients.isNotEmpty) ...[
                    _buildCategorySection(
                      title: 'Fromages',
                      subtitle: 'Ajoutez des fromages supplémentaires',
                      icon: Icons.add_circle_outline_rounded,
                      child: _buildSupplementOptions(_fromageIngredients),
                    ),
                    AppSpacing.verticalSpaceLG,
                  ],
                  
                  // Section Garnitures principales
                  if (_garnituresIngredients.isNotEmpty) ...[
                    _buildCategorySection(
                      title: 'Garnitures principales',
                      subtitle: 'Viandes et protéines',
                      icon: Icons.restaurant_rounded,
                      child: _buildSupplementOptions(_garnituresIngredients),
                    ),
                    AppSpacing.verticalSpaceLG,
                  ],
                  
                  // Section Suppléments / Extras
                  if (_supplementsIngredients.isNotEmpty) ...[
                    _buildCategorySection(
                      title: 'Suppléments / Extras',
                      subtitle: 'Légumes et accompagnements',
                      icon: Icons.add_shopping_cart_rounded,
                      child: _buildSupplementOptions(_supplementsIngredients),
                    ),
                    AppSpacing.verticalSpaceLG,
                  ],
                  
                  // Section Instructions spéciales
                  _buildCategorySection(
                    title: 'Instructions spéciales',
                    subtitle: 'Notes pour votre commande',
                    icon: Icons.edit_note_rounded,
                    child: _buildNotesField(),
                  ),
                  
                  SizedBox(height: 100 + AppSpacing.lg), // Espace pour la barre fixe
                ],
              ),
            ),
          ),
          
          // Barre de résumé fixe en bas
          _buildFixedSummaryBar(context),
        ],
      ),
    );
  }

  Widget _buildPizzaPreview(BuildContext context) {
    return Container(
      margin: AppSpacing.paddingHorizontalMD,
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.outlineVariant),
        ),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            children: [
              // Image de la pizza
              ClipRRect(
                borderRadius: AppRadius.radiusMedium,
                child: Image.network(
                  widget.pizza.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: AppRadius.radiusMedium,
                      ),
                      child: Icon(
                        Icons.local_pizza_rounded,
                        size: 80,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    );
                  },
                ),
              ),
              
              AppSpacing.verticalSpaceMD,
              
              // Nom de la pizza
              Text(
                widget.pizza.name,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              
              AppSpacing.verticalSpaceXS,
              
              // Description
              Text(
                widget.pizza.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              AppSpacing.verticalSpaceSM,
              
              // Prix de base badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.badge,
                ),
                child: Text(
                  'Prix de base : ${widget.pizza.price.toStringAsFixed(2)}€',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    String? subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: AppSpacing.paddingHorizontalMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de section Material 3
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.radiusMedium,
                  ),
                  child: Icon(icon, color: AppColors.onPrimary, size: 24),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium,
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildSizeOptions() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(
          value: 'Moyenne',
          label: Text('Moyenne'),
          icon: Icon(Icons.local_pizza_rounded, size: 20),
        ),
        ButtonSegment<String>(
          value: 'Grande',
          label: Text('Grande'),
          icon: Icon(Icons.local_pizza_rounded, size: 24),
        ),
      ],
      selected: {_selectedSize},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _selectedSize = newSelection.first;
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primaryContainer;
            }
            return AppColors.surface;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppColors.primary;
            }
            return AppColors.onSurfaceVariant;
          },
        ),
        side: MaterialStateProperty.all(
          BorderSide(color: AppColors.outline),
        ),
        textStyle: MaterialStateProperty.all(AppTextStyles.labelLarge),
      ),
    );
  }

  Widget _buildBaseIngredientsOptions() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: widget.pizza.baseIngredients.map((ingredient) {
        final isSelected = _baseIngredients.contains(ingredient);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: FilterChip(
            selected: isSelected,
            label: Text(ingredient),
            avatar: Icon(
              isSelected ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 18,
            ),
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _baseIngredients.add(ingredient);
                } else {
                  _baseIngredients.remove(ingredient);
                }
              });
            },
            selectedColor: AppColors.primaryContainer,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.outline,
              width: isSelected ? 1.5 : 1,
            ),
            labelStyle: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSupplementOptions(List<Ingredient> ingredients) {
    return Column(
      children: ingredients.map((ingredient) {
        final isSelected = _extraIngredients.contains(ingredient.name);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surface,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? AppShadows.soft : [],
          ),
          child: ListTile(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _extraIngredients.remove(ingredient.name);
                } else {
                  _extraIngredients.add(ingredient.name);
                }
              });
            },
            contentPadding: AppSpacing.paddingMD,
            leading: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                borderRadius: AppRadius.radiusMedium,
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.add_rounded,
                color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                size: 24,
              ),
            ),
            title: Text(
              ingredient.name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                borderRadius: AppRadius.badge,
              ),
              child: Text(
                '+${ingredient.extraCost.toStringAsFixed(2)}€',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Ex: Bien cuite, peu d\'ail, sans sel...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: AppSpacing.paddingMD,
      ),
      style: AppTextStyles.bodyMedium,
    );
  }

  Widget _buildFixedSummaryBar(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.navBar,
        borderRadius: BorderRadius.vertical(top: AppRadius.card.topLeft),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Récapitulatif du prix
            Card(
              elevation: 0,
              color: AppColors.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.card,
              ),
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prix total',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          '${_totalPrice.toStringAsFixed(2)}€',
                          style: AppTextStyles.priceXL,
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.radiusMedium,
                      ),
                      child: Icon(
                        Icons.euro_rounded,
                        color: AppColors.onPrimary,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalSpaceMD,
            
            // Bouton Ajouter au panier
            FilledButton(
              onPressed: _addToCart,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(56),
                padding: AppSpacing.buttonPadding,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_rounded, size: 24),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Ajouter au panier',
                    style: AppTextStyles.buttonLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
