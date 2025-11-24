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
import '../../src/theme/app_theme.dart';
import '../../src/core/constants.dart';
import '../../src/screens/home/pizza_customization_modal.dart';
import '../../src/screens/menu/menu_customization_modal.dart';

class ProductListBlockRuntime extends ConsumerWidget {
  final BuilderBlock block;

  const ProductListBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = block.getConfig<String>('mode') ?? 'manual';
    final productIdsStr = block.getConfig<String>('productIds') ?? '';
    final productIds = productIdsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final productsAsync = ref.watch(productListProvider);

    return productsAsync.when(
      data: (allProducts) {
        List<Product> products;
        
        if (mode == 'manual' && productIds.isNotEmpty) {
          // Manual mode: filter by IDs
          products = allProducts.where((p) => productIds.contains(p.id)).toList();
        } else {
          // Auto mode or fallback: show featured/promo products
          products = allProducts
              .where((p) => p.isActive && (p.isFeatured || p.displaySpot == DisplaySpot.promotions))
              .take(6)
              .toList();
        }

        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

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
            itemBuilder: (context, index) {
              final product = products[index];
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
            },
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
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
