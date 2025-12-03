// lib/src/screens/admin/products_admin_screen.dart
// Écran d'administration pour gérer le catalogue produits (Pizzas, Menus, Boissons, Desserts)

// TODO(PHASE2): Migrate legacy theme → unified WL theme

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../services/firestore_product_service.dart';
import 'product_form_screen.dart';

/// Écran principal de gestion du catalogue produits
/// Permet de voir, créer, modifier et supprimer les produits par catégorie
class ProductsAdminScreen extends ConsumerStatefulWidget {
  const ProductsAdminScreen({super.key});

  @override
  ConsumerState<ProductsAdminScreen> createState() => _ProductsAdminScreenState();
}

class _ProductsAdminScreenState extends ConsumerState<ProductsAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Use getter to access service when needed (avoids initState ref.read issue)
  FirestoreProductService get _firestoreService => ref.read(firestoreProductServiceProvider);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Catalogue Produits'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.local_pizza), text: 'Pizzas'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Menus'),
            Tab(icon: Icon(Icons.local_drink), text: 'Boissons'),
            Tab(icon: Icon(Icons.cake), text: 'Desserts'),
          ],
        ),
      ),
      body: productsAsync.when(
        data: (products) {
          final pizzas = products.where((p) => p.category == ProductCategory.pizza).toList();
          final menus = products.where((p) => p.category == ProductCategory.menus).toList();
          final boissons = products.where((p) => p.category == ProductCategory.boissons).toList();
          final desserts = products.where((p) => p.category == ProductCategory.desserts).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProductList(pizzas, ProductCategory.pizza),
              _buildProductList(menus, ProductCategory.menus),
              _buildProductList(boissons, ProductCategory.boissons),
              _buildProductList(desserts, ProductCategory.desserts),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToProductForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau produit'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildProductList(List<Product> products, ProductCategory category) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Aucun produit',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Ajoutez votre premier ${category.value.toLowerCase()}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: InkWell(
        onTap: () => _navigateToProductForm(product),
        borderRadius: AppRadius.card,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Image du produit
              ClipRRect(
                borderRadius: AppRadius.radiusSmall,
                child: Image.network(
                  product.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: AppColors.surfaceContainerLow,
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Informations du produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!product.isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer,
                              borderRadius: AppRadius.radiusSmall,
                            ),
                            child: Text(
                              'Inactif',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.onErrorContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      product.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(2)} €',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (product.isFeatured)
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.tertiary,
                          ),
                        if (product.isNew)
                          Padding(
                            padding: EdgeInsets.only(left: AppSpacing.sm),
                            child: Icon(
                              Icons.fiber_new,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleProductAction(value, product),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(product.isActive ? Icons.visibility_off : Icons.visibility),
                        const SizedBox(width: 8),
                        Text(product.isActive ? 'Désactiver' : 'Activer'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleProductAction(String action, Product product) async {
    switch (action) {
      case 'edit':
        _navigateToProductForm(product);
        break;
      case 'toggle':
        await _toggleProductStatus(product);
        break;
      case 'delete':
        _confirmDelete(product);
        break;
    }
  }

  Future<void> _toggleProductStatus(Product product) async {
    final updatedProduct = product.copyWith(isActive: !product.isActive);
    bool success = false;

    switch (product.category) {
      case ProductCategory.pizza:
        success = await _firestoreService.savePizza(updatedProduct);
        break;
      case ProductCategory.menus:
        success = await _firestoreService.saveMenu(updatedProduct);
        break;
      case ProductCategory.boissons:
        success = await _firestoreService.saveDrink(updatedProduct);
        break;
      case ProductCategory.desserts:
        success = await _firestoreService.saveDessert(updatedProduct);
        break;
    }

    if (success && mounted) {
      ref.invalidate(productListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedProduct.isActive ? 'Produit activé' : 'Produit désactivé',
          ),
        ),
      );
    }
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${product.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    bool success = false;

    switch (product.category) {
      case ProductCategory.pizza:
        success = await _firestoreService.deletePizza(product.id);
        break;
      case ProductCategory.menus:
        success = await _firestoreService.deleteMenu(product.id);
        break;
      case ProductCategory.boissons:
        success = await _firestoreService.deleteDrink(product.id);
        break;
      case ProductCategory.desserts:
        success = await _firestoreService.deleteDessert(product.id);
        break;
    }

    if (success && mounted) {
      ref.invalidate(productListProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit supprimé')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  void _navigateToProductForm(Product? product) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(
          product: product,
          initialCategory: product?.category ?? 
            ProductCategory.values[_tabController.index],
        ),
      ),
    );

    // Si un produit a été créé/modifié, rafraîchir la liste
    if (result == true && mounted) {
      ref.invalidate(productListProvider);
    }
  }
}
