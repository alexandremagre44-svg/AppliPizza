// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/staff_tablet/widgets/staff_menu_customization_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../providers/staff_tablet_cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product.dart';
import '../../design_system/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';

const _uuid = Uuid();

/// Modal de personnalisation de menu pour le module Staff Tablet
/// Adapté pour le mode caisse, utilise staffTabletCartProvider
class StaffMenuCustomizationModal extends ConsumerStatefulWidget {
  final Product menu;

  const StaffMenuCustomizationModal({super.key, required this.menu});

  @override
  ConsumerState<StaffMenuCustomizationModal> createState() => _StaffMenuCustomizationModalState();
}

class _StaffMenuCustomizationModalState extends ConsumerState<StaffMenuCustomizationModal> {
  // Liste pour stocker les pizzas sélectionnées (par défaut à la taille du menu)
  late List<Product?> _selectedPizzas;
  // Liste pour stocker les boissons sélectionnées
  late List<Product?> _selectedDrinks;

  @override
  void initState() {
    super.initState();
    // Initialisation avec des valeurs nulles
    _selectedPizzas = List.filled(widget.menu.pizzaCount, null);
    _selectedDrinks = List.filled(widget.menu.drinkCount, null);
  }

  // Vérifie si toutes les sélections obligatoires sont faites
  bool get _isSelectionComplete {
    return _selectedPizzas.every((p) => p != null) &&
        _selectedDrinks.every((d) => d != null);
  }

  // Construit la description pour le CartItem
  String _buildCustomDescription() {
    final pizzaNames = _selectedPizzas.whereType<Product>().map((p) => p.name).join(', ');
    final drinkNames = _selectedDrinks.whereType<Product>().map((d) => d.name).join(', ');

    String description = '';
    if (pizzaNames.isNotEmpty) {
      description += 'Pizzas: $pizzaNames';
    }
    if (drinkNames.isNotEmpty) {
      if (description.isNotEmpty) description += ' - ';
      description += 'Boissons: $drinkNames';
    }
    return description.isEmpty ? 'Menu standard' : description;
  }

  void _addToCart() {
    if (!_isSelectionComplete) return;

    final cartNotifier = ref.read(staffTabletCartProvider.notifier);
    
    // Crée le nouvel article de panier (CartItem) pour le menu
    final newCartItem = CartItem(
      id: _uuid.v4(),
      productId: widget.menu.id,
      productName: widget.menu.name,
      price: widget.menu.price, // Le prix est celui du menu, pas la somme des composants
      quantity: 1,
      imageUrl: widget.menu.imageUrl,
      customDescription: _buildCustomDescription(),
      isMenu: true,
    );

    // Utilise la méthode addExistingItem
    cartNotifier.addExistingItem(newCartItem);
    
    if (mounted) {
      Navigator.of(context).pop(); // Ferme le modal
      
      // Afficher une confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: context.onPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${widget.menu.name} ajouté au panier',
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

  // Affiche un modal de sélection pour une pizza ou une boisson
  Future<void> _showSelectionModal({
    required String title,
    required List<Product> options,
    required int index,
    required bool isPizza,
  }) async {
    final selectedProduct = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _SelectionOptionsModal(
          title: title,
          options: options,
        );
      },
    );

    if (selectedProduct != null) {
      setState(() {
        if (isPizza) {
          _selectedPizzas[index] = selectedProduct;
        } else {
          _selectedDrinks[index] = selectedProduct;
        }
      });
    }
  }

  Widget _buildSelectionTile(String title, Product? selected, VoidCallback onTap) {
    final isSelected = selected != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight.withOpacity(0.1) : context.onPrimary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppColors.primary : context.colorScheme.surfaceVariant // was Colors.grey.shade300,
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          else
            BoxShadow(
              color: context.colorScheme.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : context.colorScheme.surfaceVariant // was Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected ? context.onPrimary : context.colorScheme.surfaceVariant // was Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: context.colorScheme.surfaceVariant // was Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selected?.name ?? 'Cliquez pour sélectionner',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : context.colorScheme.surfaceVariant // was Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: isSelected ? AppColors.primary : context.colorScheme.surfaceVariant // was Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Charger les produits depuis le provider (inclut mock + admin + Firestore)
    final productsAsync = ref.watch(productListProvider);
    
    return productsAsync.when(
      data: (allProducts) {
        final pizzaOptions = allProducts
            .where((p) => p.category == ProductCategory.pizza && !p.isMenu)
            .toList();
        final drinkOptions = allProducts
            .where((p) => p.category == ProductCategory.boissons)
            .toList();
        
        return _buildContent(context, pizzaOptions, drinkOptions);
      },
      loading: () => _buildLoading(),
      error: (error, stack) => _buildError(error),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: AppColors.error[300]),
            const SizedBox(height: 16),
            Text('Erreur: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Product> pizzaOptions,
    List<Product> drinkOptions,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Poignée de glissement et titre
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          'PERSONNALISATION DU ${widget.menu.name.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 8),
                // --- Sélections de Pizzas ---
                if (widget.menu.pizzaCount > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_pizza,
                            color: context.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sélectionnez vos Pizzas (${widget.menu.pizzaCount} requises)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ...List.generate(widget.menu.pizzaCount, (index) {
                  return _buildSelectionTile(
                    'Pizza n°${index + 1}',
                    _selectedPizzas[index],
                    () => _showSelectionModal(
                      title: 'Choisir la Pizza n°${index + 1}',
                      options: pizzaOptions,
                      index: index,
                      isPizza: true,
                    ),
                  );
                }),

                // --- Sélections de Boissons ---
                if (widget.menu.drinkCount > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_drink,
                            color: context.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sélectionnez vos Boissons (${widget.menu.drinkCount} requises)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ...List.generate(widget.menu.drinkCount, (index) {
                  return _buildSelectionTile(
                    'Boisson n°${index + 1}',
                    _selectedDrinks[index],
                    () => _showSelectionModal(
                      title: 'Choisir la Boisson n°${index + 1}',
                      options: drinkOptions,
                      index: index,
                      isPizza: false,
                    ),
                  );
                }),
                const SizedBox(height: 100), // Espace pour le bouton en bas
              ],
            ),
          ),

          // Bouton Ajouter au Panier
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: context.onPrimary,
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.shadow.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: _isSelectionComplete ? AppColors.primary : context.colorScheme.surfaceVariant // was Colors.grey.shade400,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isSelectionComplete
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: _isSelectionComplete ? _addToCart : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      size: 24,
                      color: context.onPrimary,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AJOUTER AU PANIER',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: context.onPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.onPrimary.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.menu.price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: context.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modal interne pour choisir les options (Pizza ou Boisson)
class _SelectionOptionsModal extends StatelessWidget {
  final String title;
  final List<Product> options;

  const _SelectionOptionsModal({
    required this.title,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // Title
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_basket, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Product list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: context.onPrimary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.colorScheme.shadow.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(option),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            if (option.imageUrl.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    option.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: context.colorScheme.surfaceVariant // was Colors.grey.shade200,
                                        child: Icon(Icons.image_not_supported, color: context.colorScheme.surfaceVariant // was Colors.grey.shade400),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: context.colorScheme.surfaceVariant // was Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.description.length > 50
                                        ? '${option.description.substring(0, 50)}...'
                                        : option.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: context.colorScheme.surfaceVariant // was Colors.grey.shade600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLighter,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${option.price.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
