// lib/src/staff_tablet/screens/staff_tablet_catalog_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../providers/staff_tablet_cart_provider.dart';
import '../providers/staff_tablet_auth_provider.dart';
import '../widgets/staff_tablet_cart_summary.dart';

class StaffTabletCatalogScreen extends ConsumerStatefulWidget {
  const StaffTabletCatalogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffTabletCatalogScreen> createState() => _StaffTabletCatalogScreenState();
}

class _StaffTabletCatalogScreenState extends ConsumerState<StaffTabletCatalogScreen> {
  ProductCategory _selectedCategory = ProductCategory.pizza;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final cart = ref.watch(staffTabletCartProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.orange[700],
        title: const Text(
          'Mode Caisse - Prise de Commande',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history, size: 28),
            onPressed: () => context.push('/staff-tablet/history'),
            tooltip: 'Historique',
            color: Colors.white,
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            onPressed: () async {
              await ref.read(staffTabletAuthProvider.notifier).logout();
              if (mounted) {
                context.go('/home');
              }
            },
            tooltip: 'Déconnexion',
            color: Colors.white,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Left side - Categories and Products
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Category tabs
                Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildCategoryChip(ProductCategory.pizza, 'Pizzas', Icons.local_pizza),
                        const SizedBox(width: 12),
                        _buildCategoryChip(ProductCategory.menus, 'Menus', Icons.restaurant_menu),
                        const SizedBox(width: 12),
                        _buildCategoryChip(ProductCategory.boissons, 'Boissons', Icons.local_drink),
                        const SizedBox(width: 12),
                        _buildCategoryChip(ProductCategory.desserts, 'Desserts', Icons.cake),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Products grid
                Expanded(
                  child: productsAsync.when(
                    data: (products) {
                      final filteredProducts = products
                          .where((p) => p.category == _selectedCategory && p.isActive)
                          .toList();

                      if (filteredProducts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun produit dans cette catégorie',
                                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text('Erreur: $error', style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right side - Cart
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: const StaffTabletCartSummary(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ProductCategory category, String label, IconData icon) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.orange[700]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.orange[700],
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedCategory = category;
          });
        }
      },
      selectedColor: Colors.orange[700],
      backgroundColor: Colors.orange[50],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ref.read(staffTabletCartProvider.notifier).addItem(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} ajouté au panier'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green[700],
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey[400]),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Icon(Icons.fastfood, size: 48, color: Colors.grey[400]),
                      ),
              ),
            ),

            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange[700],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
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
