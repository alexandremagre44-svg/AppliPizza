// lib/src/screens/menu/menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_detail_modal.dart';
import 'menu_customization_modal.dart';
import '../home/elegant_pizza_customization_modal.dart';
import '../../core/constants.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String _selectedCategory = 'Pizza';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Tous',
    'Pizza',
    'Menus',
    'Boissons',
    'Desserts',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _filterProducts(List<Product> allProducts) {
    // 1. Filter only active products
    var products = allProducts.where((p) => p.isActive).toList();
    
    // 2. Filter by category
    if (_selectedCategory != 'Tous') {
      products = products.where((p) => p.category == _selectedCategory).toList();
    }

    // 3. Filter by search query
    if (_searchQuery.isNotEmpty) {
      products = products.where((p) {
        return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    // Charger les produits depuis le provider (inclut mock + admin + Firestore)
    final productsAsync = ref.watch(productListProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notre Menu',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Enhanced Search Bar
          Container(
            padding: const EdgeInsets.all(VisualConstants.paddingMedium),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF), // Fond blanc pur
                borderRadius: BorderRadius.circular(30), // Bords arrondis 30
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15), // Ombre douce
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une pizza, boisson...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: false,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Match container radius
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),

          // Enhanced Category Selector
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: VisualConstants.paddingMedium),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey[300]!,
                        width: 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Résultats avec Grid optimisé
          Expanded(
            child: productsAsync.when(
              data: (allProducts) {
                final filteredProducts = _filterProducts(allProducts);
                return filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          // Rafraîchir les produits en invalidant le provider
                          ref.invalidate(productListProvider);
                          // Attendre que le nouveau chargement soit terminé
                          await ref.read(productListProvider.future);
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: VisualConstants.gridCrossAxisCount,
                            childAspectRatio: VisualConstants.gridChildAspectRatio,
                            crossAxisSpacing: VisualConstants.gridSpacing,
                            mainAxisSpacing: VisualConstants.gridSpacing,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ProductCard(
                              product: product,
                              onAddToCart: () {
                                // Si c'est un menu, afficher la modal de customisation
                                if (product.isMenu) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => MenuCustomizationModal(menu: product),
                                  );
                                } 
                                // Si c'est une pizza, afficher la modal de personnalisation élégante
                                else if (product.category == 'Pizza') {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => ElegantPizzaCustomizationModal(pizza: product),
                                  );
                                }
                              // Pour les autres produits (boissons, desserts), ajout direct
                              else {
                                cartNotifier.addItem(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text('${product.name} ajouté au panier !'),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text('Erreur de chargement: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(productListProvider),
                      child: const Text('Réessayer'),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat trouvé',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier votre recherche',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}