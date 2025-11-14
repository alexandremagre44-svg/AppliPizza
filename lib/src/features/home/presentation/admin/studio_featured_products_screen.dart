// lib/src/screens/admin/studio/studio_featured_products_screen.dart
// Screen for managing product tags and featured status

import 'package:flutter/material.dart';
import '../../../models/product.dart';
import '../../../services/product_crud_service.dart';
import '../../../shared/theme/app_theme.dart';

class StudioFeaturedProductsScreen extends StatefulWidget {
  const StudioFeaturedProductsScreen({super.key});

  @override
  State<StudioFeaturedProductsScreen> createState() =>
      _StudioFeaturedProductsScreenState();
}

class _StudioFeaturedProductsScreenState
    extends State<StudioFeaturedProductsScreen>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Mise en avant produits',
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
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryRed,
                  unselectedLabelColor: AppTheme.textMedium,
                  indicatorColor: AppTheme.primaryRed,
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

          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProductList(_pizzas, 'Pizza'),
                      _buildProductList(_menus, 'Menus'),
                      _buildProductList(_drinks, 'Boissons'),
                      _buildProductList(_desserts, 'Desserts'),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products, String category) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.textLight,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Aucun produit',
              style: AppTextStyles.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: AppSpacing.paddingLG,
      children: [
        Card(
          elevation: 2,
          color: AppColors.primaryRed.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primaryRed),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Activez les tags pour mettre en avant vos produits',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        
        ...products.map((product) => _buildProductCard(product, category)),
      ],
    );
  }

  Widget _buildProductCard(Product product, String category) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: ExpansionTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.backgroundLight,
          ),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.local_pizza,
              color: AppColors.primaryRed,
            ),
          ),
        ),
        title: Text(product.name, style: AppTextStyles.titleMedium),
        subtitle: Text(
          '${product.price.toStringAsFixed(2)} €',
          style: AppTextStyles.bodySmall,
        ),
        children: [
          Padding(
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tags de mise en avant', style: AppTextStyles.labelLarge),
                SizedBox(height: AppSpacing.md),
                
                _buildTagToggle(
                  'Best-seller',
                  Icons.trending_up,
                  product.isBestSeller,
                  (value) => _updateProductTag(
                    product,
                    category,
                    product.copyWith(isBestSeller: value),
                  ),
                ),
                _buildTagToggle(
                  'Nouveau',
                  Icons.new_releases,
                  product.isNew,
                  (value) => _updateProductTag(
                    product,
                    category,
                    product.copyWith(isNew: value),
                  ),
                ),
                _buildTagToggle(
                  'Spécialité du chef',
                  Icons.star,
                  product.isChefSpecial,
                  (value) => _updateProductTag(
                    product,
                    category,
                    product.copyWith(isChefSpecial: value),
                  ),
                ),
                _buildTagToggle(
                  'Adapté aux enfants',
                  Icons.child_care,
                  product.isKidFriendly,
                  (value) => _updateProductTag(
                    product,
                    category,
                    product.copyWith(isKidFriendly: value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagToggle(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return CheckboxListTile(
      dense: true,
      title: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryRed),
          SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
      value: value,
      activeColor: AppColors.primaryRed,
      onChanged: (newValue) => onChanged(newValue ?? false),
    );
  }

  Future<void> _updateProductTag(
    Product oldProduct,
    String category,
    Product newProduct,
  ) async {
    bool success = false;
    
    switch (category) {
      case 'Pizza':
        success = await _crudService.updatePizza(newProduct);
        break;
      case 'Menus':
        success = await _crudService.updateMenu(newProduct);
        break;
      case 'Boissons':
        success = await _crudService.updateDrink(newProduct);
        break;
      case 'Desserts':
        success = await _crudService.updateDessert(newProduct);
        break;
    }

    if (success) {
      _loadAllProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tags mis à jour'),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        ),
      );
    }
  }
}
