// lib/modules/customization/presentation/widgets/pizza_customization_widget.dart
// TODO: migration future — ce fichier est une copie, le code original reste la source active.
// Source originale: lib/src/screens/home/pizza_customization_modal.dart
// 
// Ce widget gère la personnalisation d'une pizza avec :
// - Sélection de la taille
// - Retrait d'ingrédients de base
// - Ajout d'ingrédients supplémentaires (fromages, viandes, légumes, sauces, herbes)
// - Instructions spéciales
// - Calcul du prix total

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/ingredient_provider.dart';
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

  // Cache pour les ingrédients avec leur coût
  final Map<String, double> _ingredientCosts = {};

  double _getTotalPrice(List<Ingredient> allIngredients) {
    double price = widget.pizza.price;
    
    // Ajustement selon la taille
    if (_selectedSize == 'Grande') {
      price += 3.0;
    }
    
    // Coût des suppléments
    for (final ingredientId in _extraIngredients) {
      final ingredient = allIngredients.firstWhere(
        (ing) => ing.id == ingredientId,
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
    
    // Get ingredient names from IDs
    final ingredientsAsync = ref.read(ingredientStreamProvider);
    Map<String, String> ingredientNames = {};
    ingredientsAsync.whenData((allIngredients) {
      for (final ing in allIngredients) {
        ingredientNames[ing.id] = ing.name;
      }
    });
    
    // Ingrédients retirés
    final removed = widget.pizza.baseIngredients
        .where((ingId) => !_baseIngredients.contains(ingId))
        .map((ingId) => ingredientNames[ingId] ?? ingId)
        .toList();
    if (removed.isNotEmpty) {
      details.add('Sans: ${removed.join(', ')}');
    }
    
    // Ingrédients ajoutés
    if (_extraIngredients.isNotEmpty) {
      final addedNames = _extraIngredients
          .map((ingId) => ingredientNames[ingId] ?? ingId)
          .toList();
      details.add('Avec: ${addedNames.join(', ')}');
    }
    
    // Note
    if (_notesController.text.isNotEmpty) {
      details.add('Note: ${_notesController.text}');
    }
    
    return details.join(' • ');
  }

  void _addToCart(List<Ingredient> allIngredients) {
    final cartNotifier = ref.read(cartProvider.notifier);
    
    final newCartItem = CartItem(
      id: _uuid.v4(),
      productId: widget.pizza.id,
      productName: widget.pizza.name,
      price: _getTotalPrice(allIngredients),
      quantity: 1,
      imageUrl: widget.pizza.imageUrl,
      customDescription: _buildCustomDescription(),
      isMenu: false,
    );

    cartNotifier.addExistingItem(newCartItem);
    Navigator.of(context).pop();
  }

  // Catégorisation des ingrédients par catégorie
  List<Ingredient> _getIngredientsByCategory(List<Ingredient> ingredients, IngredientCategory category) {
    return ingredients.where((ing) => ing.category == category && ing.isActive).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(ingredientStreamProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: AppRadius.bottomSheet.topLeft),
      ),
      child: ingredientsAsync.when(
        data: (ingredients) => _buildContent(context, ingredients),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur de chargement des ingrédients: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Ingredient> ingredients) {
    // Filter ingredients to only show those allowed for this pizza
    final allowedIngredients = ingredients.where((ingredient) {
      return widget.pizza.allowedSupplements.contains(ingredient.id);
    }).toList();
    
    // Catégoriser les ingrédients
    final fromageIngredients = _getIngredientsByCategory(allowedIngredients, IngredientCategory.fromage);
    final viandeIngredients = _getIngredientsByCategory(allowedIngredients, IngredientCategory.viande);
    final legumeIngredients = _getIngredientsByCategory(allowedIngredients, IngredientCategory.legume);
    final sauceIngredients = _getIngredientsByCategory(allowedIngredients, IngredientCategory.sauce);
    final herbeIngredients = _getIngredientsByCategory(allowedIngredients, IngredientCategory.herbe);

    return Column(
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
                if (fromageIngredients.isNotEmpty) ...[
                  _buildCategorySection(
                    title: 'Fromages',
                    subtitle: 'Ajoutez des fromages supplémentaires',
                    icon: Icons.restaurant,
                    child: _buildSupplementOptions(fromageIngredients),
                  ),
                  AppSpacing.verticalSpaceLG,
                ],
                
                // Section Viandes
                if (viandeIngredients.isNotEmpty) ...[
                  _buildCategorySection(
                    title: 'Viandes',
                    subtitle: 'Protéines et charcuterie',
                    icon: Icons.food_bank,
                    child: _buildSupplementOptions(viandeIngredients),
                  ),
                  AppSpacing.verticalSpaceLG,
                ],
                
                // Section Légumes
                if (legumeIngredients.isNotEmpty) ...[
                  _buildCategorySection(
                    title: 'Légumes',
                    subtitle: 'Légumes frais',
                    icon: Icons.eco,
                    child: _buildSupplementOptions(legumeIngredients),
                  ),
                  AppSpacing.verticalSpaceLG,
                ],
                
                // Section Sauces
                if (sauceIngredients.isNotEmpty) ...[
                  _buildCategorySection(
                    title: 'Sauces',
                    subtitle: 'Sauces supplémentaires',
                    icon: Icons.water_drop,
                    child: _buildSupplementOptions(sauceIngredients),
                  ),
                  AppSpacing.verticalSpaceLG,
                ],
                
                // Section Herbes et épices
                if (herbeIngredients.isNotEmpty) ...[
                  _buildCategorySection(
                    title: 'Herbes & Épices',
                    subtitle: 'Aromates',
                    icon: Icons.spa,
                    child: _buildSupplementOptions(herbeIngredients),
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
        _buildFixedSummaryBar(context, ingredients),
      ],
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
    final ingredientsAsync = ref.watch(ingredientStreamProvider);
    
    return ingredientsAsync.when(
      data: (allIngredients) {
        // Create a map of ingredient IDs to names
        Map<String, String> ingredientNames = {};
        for (final ing in allIngredients) {
          ingredientNames[ing.id] = ing.name;
        }
        
        return Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: widget.pizza.baseIngredients.map((ingredientId) {
            final isSelected = _baseIngredients.contains(ingredientId);
            final ingredientName = ingredientNames[ingredientId] ?? ingredientId;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                selected: isSelected,
                label: Text(ingredientName),
                avatar: Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 18,
                ),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _baseIngredients.add(ingredientId);
                    } else {
                      _baseIngredients.remove(ingredientId);
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(
        'Erreur lors du chargement des ingrédients',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildSupplementOptions(List<Ingredient> ingredients) {
    return Column(
      children: ingredients.map((ingredient) {
        final isSelected = _extraIngredients.contains(ingredient.id);
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
                  _extraIngredients.remove(ingredient.id);
                } else {
                  _extraIngredients.add(ingredient.id);
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

  Widget _buildFixedSummaryBar(BuildContext context, List<Ingredient> ingredients) {
    final totalPrice = _getTotalPrice(ingredients);
    
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
                          '${totalPrice.toStringAsFixed(2)}€',
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
              onPressed: () => _addToCart(ingredients),
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
