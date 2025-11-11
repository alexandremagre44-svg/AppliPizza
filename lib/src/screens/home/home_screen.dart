// lib/src/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_detail_modal.dart';
import '../menu/menu_customization_modal.dart';
import 'elegant_pizza_customization_modal.dart';
import '../../core/constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Charger les produits depuis le provider (inclut mock + admin + Firestore)
    final productsAsync = ref.watch(productListProvider);
    
    return productsAsync.when(
      data: (products) => _buildContent(context, ref, products),
      loading: () => Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
      error: (error, stack) => Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverFillRemaining(
              child: Center(
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
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Product> products) {
    // Filtrage des produits pour la page d'accueil
    final featuredProducts = products.where((p) => p.isFeatured).take(5).toList();
    final popularPizzas = products.where((p) => p.category == 'Pizza').take(6).toList();
    final popularMenus = products.where((p) => p.isMenu == true).take(2).toList();
    final cartNotifier = ref.read(cartProvider.notifier);
    
    // Fonction d'ajout au panier
    void handleAddToCart(Product product) {
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
      // Pour les autres produits, ajout direct
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Rafraîchir les produits en invalidant le provider
          ref.invalidate(productListProvider);
          // Attendre que le nouveau chargement soit terminé
          await ref.read(productListProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            // Modern App Bar with Search
            _buildAppBar(context),
            
            // Welcome Section - Enhanced with card design
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.waving_hand,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenue !',
                                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Découvrez nos délicieuses pizzas italiennes',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Section Featured Products (only if there are featured products)
          if (featuredProducts.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                context,
                '⭐ Sélection du Chef',
                onSeeAll: () => context.go('/menu'),
              ),
            ),
            
            // Featured Products Carousel with Premium Design
            SliverToBoxAdapter(
              child: SizedBox(
                height: 320,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: featuredProducts.length,
                  itemBuilder: (context, index) {
                    final product = featuredProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        width: 200,
                        child: _buildFeaturedProductCard(
                          context,
                          product,
                          () => handleAddToCart(product),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
          
          // Section Header: Pizzas Populaires
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              'Pizzas Populaires 🍕',
              onSeeAll: () => context.go('/menu'),
            ),
          ),
          
          // Horizontal Pizzas List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: popularPizzas.length,
                itemBuilder: (context, index) {
                  final product = popularPizzas[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SizedBox(
                      width: 200,
                      child: ProductCard(
                        product: product,
                        onAddToCart: () => handleAddToCart(product),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          
          // Section Header: Menus
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              'Nos Meilleurs Menus 🎉',
              onSeeAll: () => context.go('/menu'),
            ),
          ),
          
          // Menus Grid - Grille homogène 2 colonnes, ratio 0.75
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: VisualConstants.gridCrossAxisCount,
                childAspectRatio: VisualConstants.gridChildAspectRatio,
                crossAxisSpacing: VisualConstants.gridSpacing,
                mainAxisSpacing: VisualConstants.gridSpacing,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = popularMenus[index];
                  return ProductCard(
                    product: product,
                    onAddToCart: () => handleAddToCart(product),
                  );
                },
                childCount: popularMenus.length,
              ),
            ),
          ),
          
          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
        ),
      ),
    );
  }
  
  // Widget pour construire l'AppBar avec design amélioré
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Pizza Deli\'Zza',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 8.0,
                color: Colors.black.withOpacity(0.4),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Enhanced Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            // Decorative Pizza Icons Pattern
            Positioned(
              top: 20,
              right: -30,
              child: Transform.rotate(
                angle: 0.3,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.local_pizza,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -20,
              child: Transform.rotate(
                angle: -0.2,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.local_pizza,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Subtle overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.search, size: 24),
            onPressed: () {
              context.go('/menu');
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.shopping_cart, size: 24),
            onPressed: () => context.go('/cart'),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  
  // Widget pour les produits featured avec design premium
  Widget _buildFeaturedProductCard(
    BuildContext context,
    Product product,
    VoidCallback onAddToCart,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: Colors.amber.shade300,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Featured Badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Coup de ❤️',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Product Content using ProductCard
          Padding(
            padding: const EdgeInsets.all(4),
            child: ProductCard(
              product: product,
              onAddToCart: onAddToCart,
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget utilitaire pour l'en-tête de section - Enhanced
  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                label: Text(
                  'Voir tout',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                icon: Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}