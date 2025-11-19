// lib/src/screens/menu/menu_screen.dart
// OPTIMIZED VERSION: Reduced rebuilds, better widget separation, uses StreamProvider

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import 'menu_customization_modal.dart';
import '../home/pizza_customization_modal.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String _selectedCategory = 'Pizza';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _categories = [
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
      products = products.where((p) => p.category.value == _selectedCategory).toList();
    }

    // 3. Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      products = products.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query);
      }).toList();
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
    // OPTIMIZED: Use StreamProvider for better performance and caching
    final productsAsync = ref.watch(productStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notre Menu',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // OPTIMIZED: Extract search bar to reduce rebuilds
            _SearchBar(
              controller: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onClear: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
            ),

            // OPTIMIZED: Extract category selector
            _CategorySelector(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),

            // Product Grid
            Expanded(
              child: productsAsync.when(
                data: (allProducts) {
                  final filteredProducts = _filterProducts(allProducts);
                  return filteredProducts.isEmpty
                      ? const _EmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(productStreamProvider);
                          },
                          child: _ProductGrid(
                            products: filteredProducts,
                          ),
                        );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _ErrorState(
                  error: error,
                  onRetry: () => ref.invalidate(productStreamProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// OPTIMIZED: Extract search bar to prevent unnecessary rebuilds
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(VisualConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Rechercher une pizza, boisson...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                  )
                : null,
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: onSearchChanged,
        ),
      ),
    );
  }
}

// OPTIMIZED: Extract category selector
class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: VisualConstants.paddingMedium),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryChip(
            category: category,
            isSelected: selectedCategory == category,
            onTap: () => onCategorySelected(category),
          );
        },
      ),
    );
  }
}

// OPTIMIZED: Extract category chip
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Colors.white,
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
            onTap: onTap,
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
  }
}

// OPTIMIZED: Extract product grid as separate widget
class _ProductGrid extends ConsumerWidget {
  const _ProductGrid({
    required this.products,
  });

  final List<Product> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartNotifier = ref.read(cartProvider.notifier);

    return GridView.builder(
      padding: const EdgeInsets.all(VisualConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: VisualConstants.gridCrossAxisCount,
        childAspectRatio: VisualConstants.gridChildAspectRatio,
        crossAxisSpacing: VisualConstants.gridSpacing,
        mainAxisSpacing: VisualConstants.gridSpacing,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
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
            else if (product.category == ProductCategory.pizza) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => PizzaCustomizationModal(pizza: product),
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
    );
  }
}

// OPTIMIZED: Extract empty state as const widget
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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

// OPTIMIZED: Extract error state
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Erreur de chargement'),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
