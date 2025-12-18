// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/screens/admin/pos/widgets/pos_pizza_customization_modal.dart

import 'package:flutter/material.dart';
import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/product.dart';
import '../../../../design_system/app_theme.dart';
import '../../../../../white_label/theme/theme_extensions.dart';
import '../providers/pos_cart_provider.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../providers/ingredient_provider.dart';

const _uuid = Uuid();

/// Modal de personnalisation de pizza pour le module POS
/// Adapté du StaffPizzaCustomizationModal mais utilise posCartProvider
class PosPizzaCustomizationModal extends ConsumerStatefulWidget {
  final Product pizza;

  const PosPizzaCustomizationModal({super.key, required this.pizza});

  @override
  ConsumerState<PosPizzaCustomizationModal> createState() =>
      _PosPizzaCustomizationModalState();
}

class _PosPizzaCustomizationModalState
    extends ConsumerState<PosPizzaCustomizationModal> {
  
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
      details.add('Sup: ${addedNames.join(', ')}');
    }
    
    // Notes
    if (_notesController.text.trim().isNotEmpty) {
      details.add('Note: ${_notesController.text.trim()}');
    }
    
    return details.join(' | ');
  }

  void _addToCart() {
    final ingredientsAsync = ref.read(ingredientStreamProvider);
    
    ingredientsAsync.whenData((allIngredients) {
      final totalPrice = _getTotalPrice(allIngredients);
      final customDescription = _buildCustomDescription();
      
      // Utilise POS cart provider au lieu de staff tablet
      final cartNotifier = ref.read(posCartProvider.notifier);
      
      final customItem = CartItem(
        id: _uuid.v4(),
        productId: widget.pizza.id,
        productName: widget.pizza.name,
        price: totalPrice,
        quantity: 1,
        imageUrl: widget.pizza.imageUrl,
        customDescription: customDescription,
        isMenu: false,
      );
      
      cartNotifier.addExistingItem(customItem);
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: context.onPrimary),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final ingredientsAsync = ref.watch(ingredientStreamProvider);
    
    return ingredientsAsync.when(
      data: (allIngredients) {
        final totalPrice = _getTotalPrice(allIngredients);
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: context.onPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: widget.pizza.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.pizza.imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.white24,
                                child: const Icon(Icons.local_pizza, color: context.onPrimary, size: 35),
                              ),
                            )
                          : Container(
                              width: 70,
                              height: 70,
                              color: Colors.white24,
                              child: const Icon(Icons.local_pizza, color: context.onPrimary, size: 35),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.pizza.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: context.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Personnalisez votre pizza',
                            style: TextStyle(
                              fontSize: 15,
                              color: context.onPrimary.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: context.onPrimary, size: 28),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Size selection (simplified)
                      _buildSectionTitle('Taille', Icons.straighten),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SizeChip(
                              label: 'Moyenne',
                              isSelected: _selectedSize == 'Moyenne',
                              onTap: () => setState(() => _selectedSize = 'Moyenne'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SizeChip(
                              label: 'Grande (+3€)',
                              isSelected: _selectedSize == 'Grande',
                              onTap: () => setState(() => _selectedSize = 'Grande'),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      
                      // Base ingredients (simplified)
                      _buildSectionTitle('Ingrédients de base', Icons.inventory_2),
                      const SizedBox(height: 12),
                      Text(
                        'Tapez pour retirer un ingrédient',
                        style: TextStyle(fontSize: 14, color: context.colorScheme.surfaceVariant ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.pizza.baseIngredients.map((ingId) {
                          final ing = allIngredients.firstWhere(
                            (i) => i.id == ingId,
                            orElse: () => Ingredient(id: ingId, name: ingId, extraCost: 0),
                          );
                          final isIncluded = _baseIngredients.contains(ingId);
                          return _IngredientChip(
                            name: ing.name,
                            isSelected: isIncluded,
                            onTap: () {
                              setState(() {
                                if (isIncluded) {
                                  _baseIngredients.remove(ingId);
                                } else {
                                  _baseIngredients.add(ingId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer with price and add button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.onPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: context.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Prix total',
                          style: TextStyle(fontSize: 14, color: context.colorScheme.surfaceVariant ),
                        ),
                        Text(
                          '${totalPrice.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addToCart,
                        icon: const Icon(Icons.add_shopping_cart, size: 24),
                        label: const Text(
                          'Ajouter au panier',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: context.onPrimary,
                          minimumSize: const Size(0, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erreur: $err')),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLighter : context.colorScheme.surfaceVariant ,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : context.colorScheme.surfaceVariant ,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : context.colorScheme.surfaceVariant ,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _IngredientChip({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.success[50] : AppColors.error[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.success[300]! : AppColors.error[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.remove_circle,
                color: isSelected ? AppColors.success[700] : AppColors.error[700],
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.success[900] : AppColors.error[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
