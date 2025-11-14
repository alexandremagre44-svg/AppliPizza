// lib/src/screens/admin/admin_page_builder_screen.dart
// Écran de gestion du Page Builder pour mettre en avant des produits

import 'package:flutter/material.dart';
import '../../../product/data/models/product.dart';
import 'package:pizza_delizza/src/services/product_crud_service.dart';
import '../../../shared/constants/constants.dart';
import '../../../shared/theme/app_theme.dart';

class AdminPageBuilderScreen extends StatefulWidget {
  const AdminPageBuilderScreen({super.key});

  @override
  State<AdminPageBuilderScreen> createState() => _AdminPageBuilderScreenState();
}

class _AdminPageBuilderScreenState extends State<AdminPageBuilderScreen> with SingleTickerProviderStateMixin {
  final ProductCrudService _crudService = ProductCrudService();
  late TabController _tabController;
  
  List<Product> _pizzas = [];
  List<Product> _menus = [];
  List<Product> _drinks = [];
  List<Product> _desserts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProducts() async {
    setState(() => _isLoading = true);
    
    final pizzas = await _crudService.loadPizzas();
    final menus = await _crudService.loadMenus();
    final drinks = await _crudService.loadDrinks();
    final desserts = await _crudService.loadDesserts();
    
    setState(() {
      _pizzas = pizzas;
      _menus = menus;
      _drinks = drinks;
      _desserts = desserts;
      _isLoading = false;
    });
  }

  Future<void> _toggleFeatured(Product product, String category) async {
    final updatedProduct = product.copyWith(isFeatured: !product.isFeatured);
    
    bool success = false;
    switch (category) {
      case 'Pizza':
        success = await _crudService.updatePizza(updatedProduct);
        break;
      case 'Menus':
        success = await _crudService.updateMenu(updatedProduct);
        break;
      case 'Boissons':
        success = await _crudService.updateDrink(updatedProduct);
        break;
      case 'Desserts':
        success = await _crudService.updateDessert(updatedProduct);
        break;
    }

    if (success) {
      _loadAllProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  updatedProduct.isFeatured ? Icons.star : Icons.star_border,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        updatedProduct.isFeatured
                            ? '${product.name} mis en avant !'
                            : '${product.name} retiré',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (updatedProduct.isFeatured)
                        const Text(
                          'Apparaîtra dans "Sélection du Chef" sur l\'accueil',
                          style: TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: updatedProduct.isFeatured
                ? Colors.amber.shade600
                : Colors.grey.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced SliverAppBar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Page Builder',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: 20,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          Icons.dashboard_customize,
                          size: 150,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.teal.shade700,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorColor: Colors.teal.shade700,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Pizzas', icon: Icon(Icons.local_pizza, size: 20)),
                    Tab(text: 'Menus', icon: Icon(Icons.restaurant_menu, size: 20)),
                    Tab(text: 'Boissons', icon: Icon(Icons.local_drink, size: 20)),
                    Tab(text: 'Desserts', icon: Icon(Icons.cake, size: 20)),
                  ],
                ),
              ),
            ),
          ),

          // Content
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductList(_pizzas, 'Pizza', AppColors.primarySwatch),
                      _buildProductList(_menus, 'Menus', Colors.blue),
                      _buildProductList(_drinks, 'Boissons', Colors.cyan),
                      _buildProductList(_desserts, 'Desserts', Colors.pink),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products, String category, MaterialColor themeColor) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: themeColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun produit dans cette catégorie',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // Trier: featured en premier
    final sortedProducts = List<Product>.from(products)
      ..sort((a, b) {
        if (a.isFeatured && !b.isFeatured) return -1;
        if (!a.isFeatured && b.isFeatured) return 1;
        return 0;
      });
    
    // Compter les produits mis en avant
    final featuredCount = sortedProducts.where((p) => p.isFeatured).length;

    return ListView(
      padding: const EdgeInsets.all(VisualConstants.paddingMedium),
      children: [
        // Info card with counter
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: themeColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: themeColor.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Activez l\'étoile pour mettre un produit en avant sur la page d\'accueil',
                      style: TextStyle(
                        fontSize: 13,
                        color: themeColor.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              if (featuredCount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '$featuredCount produit${featuredCount > 1 ? 's' : ''} mis en avant',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Products
        ...sortedProducts.map((product) => _buildProductCard(product, category, themeColor)),
      ],
    );
  }

  Widget _buildProductCard(Product product, String category, MaterialColor themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleFeatured(product, category),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primaryRed,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[100],
                          child: Icon(
                            _getCategoryIcon(category),
                            color: themeColor.shade600,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: themeColor.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                // Featured toggle
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: product.isFeatured
                        ? Colors.amber.shade100
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    product.isFeatured ? Icons.star : Icons.star_border,
                    color: product.isFeatured
                        ? Colors.amber.shade700
                        : Colors.grey.shade600,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pizza':
        return Icons.local_pizza;
      case 'Menus':
        return Icons.restaurant_menu;
      case 'Boissons':
        return Icons.local_drink;
      case 'Desserts':
        return Icons.cake;
      default:
        return Icons.fastfood;
    }
  }
}
