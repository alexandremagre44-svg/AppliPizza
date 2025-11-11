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
import 'pizza_customization_modal.dart';
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
      // Si c'est une pizza, afficher la modal de personnalisation
      else if (product.category == 'Pizza') {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => PizzaCustomizationModal(pizza: product),
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
            
            // Welcome Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenue ! 👋',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Découvrez nos délicieuses pizzas italiennes',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
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
  
  // Widget pour construire l'AppBar
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Pizza Deli\'Zza',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Pizza Icon Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.local_pizza,
                  size: 200,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            context.go('/menu');
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => context.go('/cart'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
  
  // Widget utilitaire pour l'en-tête de section
  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (onSeeAll != null)
            TextButton.icon(
              onPressed: onSeeAll,
              icon: const Text('Voir tout'),
              label: const Icon(Icons.arrow_forward, size: 18),
            ),
        ],
      ),
    );
  }
}