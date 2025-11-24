// lib/src/screens/home/home_screen.dart
// HomeScreen - Professional showcase page for Pizza Deli'Zza
// PROMPT 3F - Uses centralized text system
// BUILDER B3 INTEGRATION - Loads published layouts from Builder B3

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../models/home_config.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/home_config_provider.dart';
import '../../providers/app_texts_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/home/hero_banner.dart';
import '../../widgets/home/section_header.dart';
import '../../widgets/home/promo_card_compact.dart';
import '../../widgets/home/category_shortcuts.dart';
import '../../widgets/home/info_banner.dart';
import '../../widgets/home/home_shimmer_loading.dart';
import '../menu/menu_customization_modal.dart';
import 'pizza_customization_modal.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';
import '../../services/roulette_rules_service.dart';
import '../../../builder/models/models.dart';
import '../../../builder/services/services.dart';
import '../../../builder/preview/builder_runtime_renderer.dart';

/// Home screen - Professional showcase page
/// Displays hero banner, promos, bestsellers, category shortcuts, and info
/// This is DISTINCT from the Menu page
/// BUILDER B3: Attempts to load published layout, falls back to default behavior
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // App ID for multi-resto support (configure as needed)
  static const String appId = 'pizza_delizza';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productListProvider);
    final homeConfigAsync = ref.watch(homeConfigProvider);
    final appTextsAsync = ref.watch(appTextsConfigProvider);

    return Scaffold(
      appBar: appTextsAsync.when(
        data: (texts) => _buildAppBar(context, texts.home),
        loading: () => _buildAppBar(context, null),
        error: (_, __) => _buildAppBar(context, null),
      ),
      body: productsAsync.when(
        data: (products) => homeConfigAsync.when(
          data: (homeConfig) => appTextsAsync.when(
            data: (appTexts) => _buildContentWithBuilderIntegration(context, ref, products, homeConfig, appTexts.home),
            loading: () => const HomeShimmerLoading(),
            error: (error, stack) => _buildContentWithBuilderIntegration(context, ref, products, homeConfig, null),
          ),
          loading: () => const HomeShimmerLoading(),
          error: (error, stack) => appTextsAsync.when(
            data: (appTexts) => _buildContentWithBuilderIntegration(context, ref, products, null, appTexts.home),
            loading: () => const HomeShimmerLoading(),
            error: (_, __) => _buildContentWithBuilderIntegration(context, ref, products, null, null),
          ),
        ),
        loading: () => const HomeShimmerLoading(),
        error: (error, stack) => appTextsAsync.when(
          data: (appTexts) => _buildErrorState(context, ref, error, appTexts.home),
          loading: () => _buildErrorState(context, ref, error, null),
          error: (_, __) => _buildErrorState(context, ref, error, null),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, dynamic homeTexts) {
    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            homeTexts?.appName ?? 'Pizza Deli\'Zza',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.surfaceWhite,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            homeTexts?.slogan ?? 'À emporter uniquement',
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

  /// Wrapper with Builder B3 integration and fade-in animation
  /// Tries to load published layout from Builder B3, falls back to default
  Widget _buildContentWithBuilderIntegration(BuildContext context, WidgetRef ref, List<Product> allProducts, dynamic homeConfig, dynamic homeTexts) {
    return FutureBuilder<BuilderPage?>(
      future: BuilderLayoutService().loadPublished(appId, BuilderPageId.home),
      builder: (context, snapshot) {
        // If we have a published layout, use it
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.blocks.isNotEmpty) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(productListProvider);
                await ref.read(productListProvider.future);
              },
              color: AppColors.primaryRed,
              child: BuilderRuntimeRenderer(
                blocks: snapshot.data!.blocks,
                backgroundColor: Colors.white,
                wrapInScrollView: true,
              ),
            ),
          );
        }
        
        // Fallback to default behavior if no layout or error
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: _buildContent(context, ref, allProducts, homeConfig, homeTexts),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Product> allProducts, dynamic homeConfig, dynamic homeTexts) {
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
            
            // 1. Hero banner
            if (homeConfig?.hero != null && homeConfig!.hero.isActive)
              HeroBanner(
                imageUrl: homeConfig.hero.imageUrl,
                title: homeConfig.hero.title,
                subtitle: homeConfig.hero.subtitle,
                buttonText: homeConfig.hero.ctaText,
                onTap: () {
                  // Navigate to menu or specific product
                  context.go(AppRoutes.menu);
                },
              ),
            
            // 2. Roulette promotional banner (conditionally displayed)
            _buildRouletteBanner(context, ref),
            
            SizedBox(height: AppSpacing.xxxl),
            
            // 3. Promo banner (if configured)
            if (homeConfig?.promoBanner != null && homeConfig!.promoBanner.isActive) ...[
              SectionHeader(
                title: homeTexts?.promoBannerTitle ?? '🎉 Promotions',
              ),
              SizedBox(height: AppSpacing.lg),
              if (promoProducts.isNotEmpty)
                _buildPromotionsSection(context, ref, promoProducts)
              else
                _buildEmptySection('Aucune promotion pour le moment'),
              SizedBox(height: AppSpacing.xxxl),
            ],
            
            // 4. Best sellers section
            SectionHeader(
              title: homeTexts?.bestsellersTitle ?? '⭐ Nos meilleures ventes',
            ),
            SizedBox(height: AppSpacing.lg),
            if (fallbackBestSellers.isNotEmpty)
              _buildBestsellersGrid(context, ref, fallbackBestSellers)
            else
              _buildEmptySection('Aucun produit disponible'),
            
            SizedBox(height: AppSpacing.xxxl),
            
            // 5. Category shortcuts (always shown)
            SectionHeader(
              title: homeTexts?.categoriesTitle ?? 'Nos catégories',
            ),
            SizedBox(height: AppSpacing.lg),
            const CategoryShortcuts(),
            
            SizedBox(height: AppSpacing.xxxl),
            
            // 6. Info banner
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

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error, dynamic homeTexts) {
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
            child: Text(homeTexts?.retryButton ?? 'Réessayer'),
          ),
        ],
      ),
    );
  }


  // Build default sections (fallback when no blocks configured)
  List<Widget> _buildDefaultSections(
    BuildContext context,
    WidgetRef ref,
    List<Product> promoProducts,
    List<Product> bestSellers,
    dynamic homeTexts,
  ) {
    final widgets = <Widget>[];

    // Promos section
    if (promoProducts.isNotEmpty) {
      widgets.add(SectionHeader(title: homeTexts?.promosTitle ?? '🔥 Promos du moment'));
      widgets.add(SizedBox(height: AppSpacing.lg));
      widgets.add(_buildPromoCarousel(context, ref, promoProducts));
      widgets.add(SizedBox(height: AppSpacing.xxxl));
    }

    // Best sellers section
    widgets.add(SectionHeader(title: homeTexts?.bestSellersTitle ?? '⭐ Best-sellers'));
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

  // Build promotions section (for promo products)
  Widget _buildPromotionsSection(BuildContext context, WidgetRef ref, List<Product> products) {
    return _buildPromoCarousel(context, ref, products);
  }

  // Build bestsellers grid
  Widget _buildBestsellersGrid(BuildContext context, WidgetRef ref, List<Product> products) {
    return _buildProductGrid(context, ref, products);
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

  /// Build the roulette promotional banner
  /// Only displayed when roulette is enabled and all conditions are met
  Widget _buildRouletteBanner(BuildContext context, WidgetRef ref) {
    return FutureBuilder<RouletteRules?>(
      future: RouletteRulesService().getRules(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final rules = snapshot.data!;
        final now = DateTime.now();

        // Check all conditions
        if (!rules.isEnabled) return const SizedBox.shrink();
        
        // Check time slot restrictions
        final currentHour = now.hour;
        final isWithinHours = _isWithinAllowedHours(currentHour, rules);
        if (!isWithinHours) return const SizedBox.shrink();

        // All conditions met - show the banner
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.card,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.card,
              ),
              child: Padding(
                padding: AppSpacing.paddingLG,
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppRadius.cardSmall,
                      ),
                      child: const Icon(
                        Icons.casino,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: AppSpacing.lg),
                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tentez votre chance !',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            'Tournez la roue et gagnez des récompenses 🎁',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    // CTA Button
                    ElevatedButton(
                      onPressed: () => context.push(AppRoutes.rewards),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.button,
                        ),
                      ),
                      child: const Text(
                        'Jouer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Check if current hour is within allowed hours
  bool _isWithinAllowedHours(int currentHour, RouletteRules rules) {
    if (rules.allowedStartHour <= rules.allowedEndHour) {
      // Normal case: 11h - 22h
      return currentHour >= rules.allowedStartHour && 
             currentHour <= rules.allowedEndHour;
    } else {
      // Crosses midnight: 22h - 2h
      return currentHour >= rules.allowedStartHour || 
             currentHour <= rules.allowedEndHour;
    }
  }
}

