// lib/builder/blocks/product_list_block_runtime.dart
// Runtime version of ProductListBlock - uses real product data and providers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/builder_block.dart';
import '../../src/models/product.dart';
import '../../src/providers/product_provider.dart';
import '../../src/providers/cart_provider.dart';
import '../../src/widgets/product_card.dart';
import '../../src/widgets/home/promo_card_compact.dart';
import '../../src/theme/app_theme.dart';
import '../../src/core/constants.dart';
import '../../src/screens/home/pizza_customization_modal.dart';
import '../../src/screens/menu/menu_customization_modal.dart';

/// Enhanced ProductListBlockRuntime with multiple layouts and modes
/// 
/// Configuration options:
/// - mode: 'manual' (specific IDs), 'featured', 'top_selling', 'promo'
/// - productIds: Comma-separated list of product IDs (for manual mode)
/// - layout: 'grid', 'carousel', 'list'
/// - title: Optional title for the product section
/// - limit: Maximum number of products to show (default 6)
class ProductListBlockRuntime extends ConsumerWidget {
  final BuilderBlock block;

  const ProductListBlockRuntime({
    super.key,
    required this.block,
  });

  // Helper getters for configuration
  String get _mode => block.getConfig<String>('mode') ?? 'featured';
  String get _layout => block.getConfig<String>('layout') ?? 'grid';
  String? get _title => block.getConfig<String>('title');
  int get _limit => block.getConfig<int>('limit') ?? 6;
  
  List<String> get _productIds {
    final idsStr = block.getConfig<String>('productIds') ?? '';
    return idsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);

    return productsAsync.when(
      data: (allProducts) {
        final products = _filterProducts(allProducts);

        if (products.isEmpty) {
          // Graceful fallback for empty list
          return Padding(
            padding: AppSpacing.paddingHorizontalLG,
            child: Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: AppRadius.card,
              ),
              child: Center(
                child: Text(
                  'Aucun produit disponible',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_title != null && _title!.isNotEmpty) ...[
              Padding(
                padding: AppSpacing.paddingHorizontalLG,
                child: Text(
                  _title!,
                  style: AppTextStyles.headlineMedium,
                ),
              ),
              SizedBox(height: AppSpacing.md),
            ],
            _buildLayout(context, ref, products),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) {
        // Graceful error handling
        debugPrint('Error loading products: $error');
        return const SizedBox.shrink();
      },
    );
  }

  List<Product> _filterProducts(List<Product> allProducts) {
    List<Product> filtered;

    switch (_mode) {
      case 'manual':
        // Manual mode: filter by specific IDs
        if (_productIds.isEmpty) {
          return [];
        }
        filtered = allProducts
            .where((p) => _productIds.contains(p.id) && p.isActive)
            .toList();
        // Preserve order from productIds
        filtered.sort((a, b) {
          final indexA = _productIds.indexOf(a.id);
          final indexB = _productIds.indexOf(b.id);
          return indexA.compareTo(indexB);
        });
        break;

      case 'featured':
        // Featured products
        filtered = allProducts
            .where((p) => p.isActive && p.isFeatured)
            .take(_limit)
            .toList();
        break;

      case 'top_selling':
        // Top selling products (using isBestSeller property)
        filtered = allProducts
            .where((p) => p.isActive && p.isBestSeller)
            .take(_limit)
            .toList();
        break;

      case 'promo':
        // Promo products
        filtered = allProducts
            .where((p) => p.isActive && p.displaySpot == DisplaySpot.promotions)
            .take(_limit)
            .toList();
        break;

      default:
        // Fallback: featured or active products
        filtered = allProducts
            .where((p) => p.isActive && p.isFeatured)
            .take(_limit)
            .toList();
    }

    return filtered;
  }

  Widget _buildLayout(BuildContext context, WidgetRef ref, List<Product> products) {
    switch (_layout) {
      case 'carousel':
        return _buildCarousel(context, ref, products);
      case 'list':
        return _buildList(context, ref, products);
      case 'grid':
      default:
        return _buildGrid(context, ref, products);
    }
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<Product> products) {
    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => _buildProductCard(context, ref, products[index]),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, WidgetRef ref, List<Product> products) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingHorizontalLG,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.md),
            child: PromoCardCompact(
              product: product,
              onTap: () => _handleProductTap(context, ref, product),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<Product> products) {
    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: Column(
        children: products
            .map((product) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildProductCard(context, ref, product),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, WidgetRef ref, Product product) {
    final cart = ref.watch(cartProvider);
    final cartItem = cart.items.cast<CartItem?>().firstWhere(
      (item) => item?.productId == product.id,
      orElse: () => null,
    );

    return ProductCard(
      product: product,
      onAddToCart: () => _handleProductTap(context, ref, product),
      cartQuantity: cartItem?.quantity,
    );
  }

  void _handleProductTap(BuildContext context, WidgetRef ref, Product product) {
    final cartNotifier = ref.read(cartProvider.notifier);
    
    // If menu, show menu customization modal
    if (product.isMenu) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => MenuCustomizationModal(menu: product),
      );
    }
    // If pizza, show pizza customization modal
    else if (product.category == ProductCategory.pizza) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PizzaCustomizationModal(pizza: product),
      );
    }
    // For other products, add directly to cart
    else {
      cartNotifier.addItem(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🍕', style: TextStyle(fontSize: 20)),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('${product.name} ajouté au panier !'),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryRed,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        ),
      );
    }
  }
}
