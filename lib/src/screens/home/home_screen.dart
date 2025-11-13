// lib/src/screens/home/home_screen.dart
// HomeScreen - Professional showcase page for Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../models/home_config.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/home_config_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/home/hero_banner.dart';
import '../../widgets/home/section_header.dart';
import '../../widgets/home/promo_card_compact.dart';
import '../../widgets/home/category_shortcuts.dart';
import '../../widgets/home/info_banner.dart';
import '../menu/menu_customization_modal.dart';
import 'pizza_customization_modal.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';

/// Home screen - Professional showcase page
/// Displays hero banner, promos, bestsellers, category shortcuts, and info
/// This is DISTINCT from the Menu page
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    final homeConfigAsync = ref.watch(homeConfigProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: productsAsync.when(
        data: (products) => homeConfigAsync.when(
          data: (homeConfig) => _buildContent(context, ref, products, homeConfig),
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryRed,
            ),
          ),
          error: (error, stack) => _buildContent(context, ref, products, null),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryRed,
          ),
        ),
        error: (error, stack) => _buildErrorState(context, ref, error),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pizza Deli\'Zza',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.surfaceWhite,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            'À emporter uniquement',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.surfaceWhite.withOpacity(0.8),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: AppColors.primaryRed,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined),
          onPressed: () => context.push(AppRoutes.cart),
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => context.push(AppRoutes.profile),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Product> allProducts, dynamic homeConfig) {
    // Filter active products
    final activeProducts = allProducts.where((p) => p.isActive).toList();
    
    // Get promo products (max 3)
    final promoProducts = activeProducts
        .where((p) => p.displaySpot == DisplaySpot.promotions)
        .take(3)
        .toList();
    
    // Get best sellers - use isFeatured or fallback to first pizzas
    final bestSellers = activeProducts.where((p) => p.isFeatured).toList();
    final fallbackBestSellers = bestSellers.isEmpty
        ? activeProducts.where((p) => p.category == ProductCategory.pizza).take(4).toList()
        : bestSellers.take(4).toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(productListProvider);
        await ref.read(productListProvider.future);
      },
      color: AppColors.primaryRed,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSpacing.lg),
            
            // 1. Hero Banner (from home config or default)
            if (homeConfig?.hero?.isActive ?? true)
              HeroBanner(
                title: homeConfig?.hero?.title ?? 'Bienvenue chez\nPizza Deli\'Zza',
                subtitle: homeConfig?.hero?.subtitle ?? 'Découvrez nos pizzas artisanales et nos menus gourmands',
                buttonText: homeConfig?.hero?.ctaText ?? 'Voir le menu',
                imageUrl: homeConfig?.hero?.imageUrl,
                onPressed: () {
                  final action = homeConfig?.hero?.ctaAction ?? AppRoutes.menu;
                  if (action.startsWith('/')) {
                    context.push(action);
                  } else {
                    context.push(AppRoutes.menu);
                  }
                },
              ),
            
            // Promo banner (if active)
            if (homeConfig?.promoBanner?.isCurrentlyActive ?? false)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: InfoBanner(
                  text: homeConfig!.promoBanner!.text,
                  icon: Icons.local_offer,
                  backgroundColor: homeConfig.promoBanner!.backgroundColor != null
                      ? Color(ColorConverter.hexToColor(homeConfig.promoBanner!.backgroundColor) ?? 0xFFD32F2F)
                      : AppColors.primaryRed,
                  textColor: homeConfig.promoBanner!.textColor != null
                      ? Color(ColorConverter.hexToColor(homeConfig.promoBanner!.textColor) ?? 0xFFFFFFFF)
                      : Colors.white,
                ),
              ),
            
            SizedBox(height: AppSpacing.xxxl),
            
            // 2. Dynamic blocks from configuration
            if (homeConfig?.blocks != null && homeConfig!.blocks.isNotEmpty)
              ..._buildDynamicBlocks(context, ref, homeConfig.blocks, activeProducts)
            else
              // Fallback to default sections if no blocks configured
              ..._buildDefaultSections(context, ref, promoProducts, fallbackBestSellers),
            
            SizedBox(height: AppSpacing.xxxl),
            
            // 3. Category shortcuts (always shown)
            const SectionHeader(
              title: 'Nos catégories',
            ),
            SizedBox(height: AppSpacing.lg),
            const CategoryShortcuts(),
            
            SizedBox(height: AppSpacing.xxxl),
            
            // 5. Info banner
            const InfoBanner(
              text: 'À emporter uniquement — 11h–21h (Mar→Dim)',
              icon: Icons.info_outline,
            ),
            
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySection(String message) {
    return Padding(
      padding: AppSpacing.paddingXXL,
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: AppColors.errorRed,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Erreur de chargement',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Padding(
            padding: AppSpacing.paddingHorizontalXXL,
            child: Text(
              error.toString(),
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () => ref.refresh(productListProvider),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  // Build dynamic blocks based on configuration
  List<Widget> _buildDynamicBlocks(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> blocks,
    List<Product> allProducts,
  ) {
    // Sort blocks by order and filter visible ones
    final sortedBlocks = blocks
        .where((b) => b.isActive == true)
        .toList()
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    final widgets = <Widget>[];

    for (final block in sortedBlocks) {
      widgets.addAll(_buildBlockContent(context, ref, block, allProducts));
      widgets.add(SizedBox(height: AppSpacing.xxxl));
    }

    return widgets;
  }

  // Build content for a specific block type
  List<Widget> _buildBlockContent(
    BuildContext context,
    WidgetRef ref,
    dynamic block,
    List<Product> allProducts,
  ) {
    final widgets = <Widget>[];
    final maxItems = block.maxItems ?? 6;

    switch (block.type) {
      case 'featuredProducts':
      case 'featured_products':
        // Show featured products
        final featured = allProducts
            .where((p) => p.isFeatured)
            .take(maxItems)
            .toList();
        
        if (featured.isNotEmpty) {
          widgets.add(SectionHeader(title: block.title ?? '⭐ Produits phares'));
          widgets.add(SizedBox(height: AppSpacing.lg));
          widgets.add(_buildProductGrid(context, ref, featured));
        }
        break;

      case 'bestSellers':
        // Show best sellers (use isFeatured as proxy or first pizzas)
        final bestSellers = allProducts.where((p) => p.isFeatured).toList();
        final products = bestSellers.isEmpty
            ? allProducts.where((p) => p.category == ProductCategory.pizza).take(maxItems).toList()
            : bestSellers.take(maxItems).toList();
        
        if (products.isNotEmpty) {
          widgets.add(SectionHeader(title: block.title ?? '🔥 Best-sellers'));
          widgets.add(SizedBox(height: AppSpacing.lg));
          widgets.add(_buildProductGrid(context, ref, products));
        }
        break;

      case 'categories':
        // Show categories section
        widgets.add(SectionHeader(title: block.title ?? 'Nos catégories'));
        widgets.add(SizedBox(height: AppSpacing.lg));
        widgets.add(const CategoryShortcuts());
        break;

      case 'promotions':
        // Show promo products
        final promos = allProducts
            .where((p) => p.displaySpot == DisplaySpot.promotions)
            .take(maxItems)
            .toList();
        
        if (promos.isNotEmpty) {
          widgets.add(SectionHeader(title: block.title ?? '🔥 Promos du moment'));
          widgets.add(SizedBox(height: AppSpacing.lg));
          widgets.add(_buildPromoCarousel(context, ref, promos));
        }
        break;

      default:
        // Unknown block type, skip
        break;
    }

    return widgets;
  }

  // Build default sections (fallback when no blocks configured)
  List<Widget> _buildDefaultSections(
    BuildContext context,
    WidgetRef ref,
    List<Product> promoProducts,
    List<Product> bestSellers,
  ) {
    final widgets = <Widget>[];

    // Promos section
    if (promoProducts.isNotEmpty) {
      widgets.add(const SectionHeader(title: '🔥 Promos du moment'));
      widgets.add(SizedBox(height: AppSpacing.lg));
      widgets.add(_buildPromoCarousel(context, ref, promoProducts));
      widgets.add(SizedBox(height: AppSpacing.xxxl));
    }

    // Best sellers section
    widgets.add(const SectionHeader(title: '⭐ Best-sellers'));
    widgets.add(SizedBox(height: AppSpacing.lg));
    if (bestSellers.isEmpty) {
      widgets.add(_buildEmptySection('Aucun best-seller disponible'));
    } else {
      widgets.add(_buildProductGrid(context, ref, bestSellers));
    }

    return widgets;
  }

  // Build product grid
  Widget _buildProductGrid(BuildContext context, WidgetRef ref, List<Product> products) {
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
  }

  // Build promo carousel
  Widget _buildPromoCarousel(BuildContext context, WidgetRef ref, List<Product> products) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingHorizontalLG,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return PromoCardCompact(
            product: product,
            onTap: () => _handleProductTap(context, ref, product),
          );
        },
      ),
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

