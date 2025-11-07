// lib/src/screens/menu/menu_customization_modal.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';

const _uuid = Uuid();

class MenuCustomizationModal extends ConsumerStatefulWidget {
  final Product menu;

  const MenuCustomizationModal({super.key, required this.menu});

  @override
  ConsumerState<MenuCustomizationModal> createState() => _MenuCustomizationModalState();
}

class _MenuCustomizationModalState extends ConsumerState<MenuCustomizationModal> {
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

    final cartNotifier = ref.read(cartProvider.notifier);
    
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

    // Utilise la méthode addExistingItem que nous avons ajoutée dans cart_provider
    cartNotifier.addExistingItem(newCartItem);
    
    Navigator.of(context).pop(); // Ferme le modal
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(
          selected != null ? Icons.check_circle : Icons.add_circle_outline,
          color: selected != null ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        title: Text(title),
        subtitle: Text(selected?.name ?? 'Cliquez pour sélectionner',
            style: TextStyle(
                color: selected != null ? Colors.black : Colors.red)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
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
            .where((p) => p.category == 'Pizza' && !p.isMenu)
            .toList();
        final drinkOptions = allProducts
            .where((p) => p.category == 'Boissons')
            .toList();
        
        return _buildContent(context, pizzaOptions, drinkOptions);
      },
      loading: () => _buildLoading(),
      error: (error, stack) => _buildError(error),
    );
  }

  Widget _buildLoading() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildError(Object error) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Erreur: $error'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Product> pizzaOptions,
    List<Product> drinkOptions,
  ) {

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
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
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Personnalisation du ${widget.menu.name}', 
                      style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const Divider(),
                    // --- Sélections de Pizzas ---
                    if (widget.menu.pizzaCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text('Sélectionnez vos Pizzas (${widget.menu.pizzaCount} requises)', 
                            style: Theme.of(context).textTheme.titleLarge),
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
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text('Sélectionnez vos Boissons (${widget.menu.drinkCount} requises)', 
                            style: Theme.of(context).textTheme.titleLarge),
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
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSelectionComplete ? _addToCart : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: _isSelectionComplete ? Theme.of(context).colorScheme.primary : Colors.grey,
                  ),
                  child: Text(
                    'Ajouter au Panier (${widget.menu.price.toStringAsFixed(2)} €)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return ListTile(
                  leading: option.imageUrl.isNotEmpty
                      ? Image.network(option.imageUrl, width: 40, height: 40, fit: BoxFit.cover)
                      : null,
                  title: Text(option.name),
                  subtitle: Text('${option.description.substring(0, option.description.length > 50 ? 50 : option.description.length)}${option.description.length > 50 ? '...' : ''}'),
                  trailing: Text('${option.price.toStringAsFixed(2)} €'),
                  onTap: () {
                    // Retourne le produit sélectionné
                    Navigator.of(context).pop(option); 
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}