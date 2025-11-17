// lib/src/staff_tablet/widgets/staff_pizza_customization_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/product.dart';
import '../../design_system/app_theme.dart';
import '../providers/staff_tablet_cart_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/ingredient_provider.dart';

const _uuid = Uuid();

/// Modal de personnalisation de pizza pour le module Staff Tablet
/// Adapté pour tablette 10-11 pouces avec le système de couleurs Delizza
class StaffPizzaCustomizationModal extends ConsumerStatefulWidget {
  final Product pizza;

  const StaffPizzaCustomizationModal({super.key, required this.pizza});

  @override
  ConsumerState<StaffPizzaCustomizationModal> createState() =>
      _StaffPizzaCustomizationModalState();
}

class _StaffPizzaCustomizationModalState
    extends ConsumerState<StaffPizzaCustomizationModal> {
  
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
    final ingredientsAsync = ref.read(activeIngredientListProvider);
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
    final cartNotifier = ref.read(staffTabletCartProvider.notifier);
    
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
    
    if (mounted) {
      Navigator.of(context).pop();
      
      // Afficher une confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${widget.pizza.name} personnalisée ajoutée au panier',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // Catégorisation des ingrédients par catégorie
  List<Ingredient> _getIngredientsByCategory(List<Ingredient> ingredients, IngredientCategory category) {
    return ingredients.where((ing) => ing.category == category && ing.isActive).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(activeIngredientListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
    const primaryColor = AppColors.primary;
    
    // Filter ingredients to only show those allowed for this pizza
    final allowedIngredients = ingredients.where((ingredient) {
      return widget.pizza.allowedSupplements.contains(ingredient.id);
    }).toList();
    
    // Catégoriser les ingrédients
    final fromageIngredients = _getIngredientsByCategory(allowedIngredients, IngredientCategory.fromage);
    final viandeIngredients = _getIngredientsByCategory(allowedIngredients, IngredientCategory.viande);
    final legumeIngredients = _getIngredientsByCategory(allowedIngredients, IngredientCategory.legume);

    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 16),
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
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
                _buildPizzaPreview(primaryColor),
                
                const SizedBox(height: 24),
                
                // Section Base (Taille)
                _buildCategorySection(
                  title: 'Taille',
                  icon: Icons.straighten,
                  primaryColor: primaryColor,
                  child: _buildSizeOptions(primaryColor),
                ),
                
                const SizedBox(height: 24),
                
                // Section Ingrédients de base
                _buildCategorySection(
                  title: 'Ingrédients de base',
                  subtitle: 'Retirez ce que vous ne souhaitez pas',
                  icon: Icons.inventory_2,
                  primaryColor: primaryColor,
                  child: _buildBaseIngredientsOptions(primaryColor),
                ),
                
                const SizedBox(height: 24),
                
                // Section Fromages
                if (fromageIngredients.isNotEmpty) ...[
                  _buildCategorySection(
                    title: 'Fromages',
                    subtitle: 'Ajoutez des fromages supplémentaires',
                    icon: Icons.restaurant,
                    primaryColor: primaryColor,
                    child: _buildSupplementOptions(fromageIngredients, primaryColor),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Section Viandes
                if (viandeIngredients.isNotEmpty) ...[
                  _buildCategorySection(
                    title: 'Viandes',
                    subtitle: 'Protéines et charcuterie',
                    icon: Icons.food_bank,
                    primaryColor: primaryColor,
                    child: _buildSupplementOptions(viandeIngredients, primaryColor),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Section Légumes
                if (legumeIngredients.isNotEmpty) ...[
                  _buildCategorySection(
                    title: 'Légumes',
                    subtitle: 'Légumes frais',
                    icon: Icons.eco,
                    primaryColor: primaryColor,
                    child: _buildSupplementOptions(legumeIngredients, primaryColor),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Section Instructions spéciales
                _buildCategorySection(
                  title: 'Instructions spéciales',
                  subtitle: 'Notes pour votre commande',
                  icon: Icons.edit_note,
                  primaryColor: primaryColor,
                  child: _buildNotesField(primaryColor),
                ),
                
                const SizedBox(height: 100), // Espace pour la barre fixe
              ],
            ),
          ),
        ),
        
        // Barre de résumé fixe en bas
        _buildFixedSummaryBar(primaryColor, ingredients),
      ],
    );
  }

  Widget _buildPizzaPreview(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image de la pizza
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.pizza.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.local_pizza,
                      size: 80,
                      color: primaryColor.withOpacity(0.3),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Nom de la pizza
          Text(
            widget.pizza.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            widget.pizza.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Prix de base
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
            ),
            child: Text(
              'Prix de base : ${widget.pizza.price.toStringAsFixed(2)}€',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color primaryColor,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSizeOptions(Color primaryColor) {
    final sizes = [
      {'name': 'Moyenne', 'size': '30 cm', 'price': 0.0},
      {'name': 'Grande', 'size': '40 cm', 'price': 3.0},
    ];
    
    return Row(
      children: sizes.map((size) {
        final isSelected = _selectedSize == size['name'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              onTap: () => setState(() => _selectedSize = size['name'] as String),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withOpacity(0.15) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey[300]!,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.local_pizza,
                      size: size['name'] == 'Grande' ? 40 : 32,
                      color: isSelected ? primaryColor : Colors.grey[600],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      size['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected ? primaryColor : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      size['size'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    if ((size['price'] as double) > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${(size['price'] as double).toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBaseIngredientsOptions(Color primaryColor) {
    final ingredientsAsync = ref.watch(activeIngredientListProvider);
    
    return ingredientsAsync.when(
      data: (allIngredients) {
        // Create a map of ingredient IDs to names
        Map<String, String> ingredientNames = {};
        for (final ing in allIngredients) {
          ingredientNames[ing.id] = ing.name;
        }
        
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.pizza.baseIngredients.map((ingredientId) {
            final isSelected = _baseIngredients.contains(ingredientId);
            final ingredientName = ingredientNames[ingredientId] ?? ingredientId;
            
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _baseIngredients.remove(ingredientId);
                  } else {
                    _baseIngredients.add(ingredientId);
                  }
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor.withOpacity(0.15) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey[300]!,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: isSelected ? primaryColor : Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ingredientName,
                      style: TextStyle(
                        color: isSelected ? primaryColor : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
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

  Widget _buildSupplementOptions(List<Ingredient> ingredients, Color primaryColor) {
    return Column(
      children: ingredients.map((ingredient) {
        final isSelected = _extraIngredients.contains(ingredient.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey[200]!,
              width: isSelected ? 2 : 1.5,
            ),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.add,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
            ),
            title: Text(
              ingredient.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
                color: isSelected ? primaryColor : AppColors.textPrimary,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '+${ingredient.extraCost.toStringAsFixed(2)}€',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField(Color primaryColor) {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Ex: Bien cuite, peu d\'ail, sans sel...',
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildFixedSummaryBar(Color primaryColor, List<Ingredient> ingredients) {
    final totalPrice = _getTotalPrice(ingredients);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Récapitulatif du prix
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prix total',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalPrice.toStringAsFixed(2)}€',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.euro,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton Ajouter au panier
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _addToCart(ingredients),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Ajouter au panier',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
