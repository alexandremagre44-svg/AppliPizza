// lib/src/screens/home/home_screen.dart
// HomeScreen redesigné - Style Pizza Deli'Zza (à emporter uniquement)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/category_tabs.dart';
import '../../widgets/fixed_cart_bar.dart';
import '../../widgets/promo_banner_carousel.dart';
import '../menu/menu_customization_modal.dart';
import 'elegant_pizza_customization_modal.dart';
import '../../theme/app_theme.dart';

/// Écran d'accueil client - Interface complètement redesignée
/// - Header fixe rouge avec logo centré et sous-texte "À emporter uniquement"
/// - Barre d'onglets catégories (Promos, Pizzas, Boissons, Desserts, Menus)
/// - Bannière promo carousel
/// - Liste produits en grille 2 colonnes
/// - Barre panier fixe en bas
/// 
/// ANIMATIONS AJOUTÉES:
/// 1. TweenAnimationBuilder - Apparition séquentielle des produits (FadeInUp avec 100ms d'intervalle)
/// 2. SnackBar avec emoji 🍕 - Confirmation d'ajout au panier
/// 3. Header réduit à 60px pour gagner de l'espace
/// Fichier: lib/src/screens/home/home_screen.dart
/// But: Créer une expérience utilisateur fluide et professionnelle
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'Tous';
  
  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    
    return productsAsync.when(
      data: (products) => _buildContent(context, ref, products),
      loading: () => Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryRed,
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: _buildAppBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: AppTheme.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(productListProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Product> products) {
    // Filtrage des produits actifs
    final activeProducts = products.where((p) => p.isActive).toList();
    
    // Filtrer par catégorie sélectionnée
    List<Product> filteredProducts;
    if (_selectedCategory == 'Tous') {
      filteredProducts = activeProducts;
    } else if (_selectedCategory == 'Promos') {
      filteredProducts = activeProducts.where((p) => 
        p.displaySpot == 'promotions'
      ).toList();
    } else if (_selectedCategory == 'Menus') {
      filteredProducts = activeProducts.where((p) => p.isMenu).toList();
    } else {
      filteredProducts = activeProducts.where((p) => 
        p.category == _selectedCategory
      ).toList();
    }
    
    // Produits en promotion pour le carousel
    final promoProducts = activeProducts.where((p) => 
      p.displaySpot == 'promotions'
    ).take(3).toList();
    
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    
    // Fonction d'ajout au panier avec animation
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
          builder: (context) => ElegantPizzaCustomizationModal(pizza: product),
        );
      }
      // Pour les autres produits, ajout direct avec animation et toast
      else {
        cartNotifier.addItem(product);
        // Micro-animation: SnackBar stylé avec emoji pizza
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('🍕', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${product.name} ajouté au panier !'),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryRed,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Contenu principal avec pull-to-refresh
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(productListProvider);
              await ref.read(productListProvider.future);
            },
            color: AppTheme.primaryRed,
            child: CustomScrollView(
              slivers: [
                // Barre de catégories horizontale avec scroll
                SliverToBoxAdapter(
                  child: CategoryTabs(
                    categories: const [
                      'Tous',
                      'Promos',
                      'Pizzas',
                      'Boissons',
                      'Desserts',
                      'Menus',
                    ],
                    selectedCategory: _selectedCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                
                // Bannière promotionnelle carousel (si promos disponibles)
                if (promoProducts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: PromoBannerCarousel(
                      banners: promoProducts.map((product) {
                        return PromoBanner(
                          imageUrl: product.imageUrl,
                          title: product.name,
                          subtitle: '${product.price.toStringAsFixed(2)} €',
                          onTap: () => handleAddToCart(product),
                        );
                      }).toList(),
                    ),
                  ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                
                // En-tête de section centré et bold avec bouton filtres
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Titre centré et bold
                        Text(
                          _getCategoryTitle(_selectedCategory),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Bouton filtres centré en dessous
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _showFiltersModal(context);
                            },
                            icon: const Icon(
                              Icons.tune,
                              size: 18,
                            ),
                            label: const Text('Filtres'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                
                // Grille de produits 2 colonnes
                if (filteredProducts.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: AppTheme.textLight,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Aucun produit dans cette catégorie',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textMedium,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = filteredProducts[index];
                          // Obtenir la quantité dans le panier pour ce produit
                          final cartItem = cart.items.cast<CartItem?>().firstWhere(
                            (item) => item?.productId == product.id,
                            orElse: () => null,
                          );
                          
                          // Micro-animation: Apparition séquentielle avec FadeInUp (100ms d'intervalle)
                          return TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 300 + (index * 100)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: ProductCard(
                              product: product,
                              onAddToCart: () => handleAddToCart(product),
                              cartQuantity: cartItem?.quantity,
                            ),
                          );
                        },
                        childCount: filteredProducts.length,
                      ),
                    ),
                  ),
                
                // Espace pour la barre panier fixe
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
          
          // Barre panier fixe en bas
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FixedCartBar(),
          ),
        ],
      ),
    );
  }
  
  /// Construit l'AppBar fixe rouge avec logo centré
  /// Hauteur réduite pour gagner de l'espace
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 60, // Hauteur réduite
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pizza Deli\'Zza',
            style: TextStyle(
              fontSize: 18, // Taille réduite
              fontWeight: FontWeight.bold,
              color: AppTheme.surfaceWhite,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            'À emporter uniquement',
            style: TextStyle(
              fontSize: 10, // Taille réduite et gris clair
              fontWeight: FontWeight.w400,
              color: AppTheme.surfaceWhite.withOpacity(0.7),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: AppTheme.primaryRed,
      elevation: 0,
      actions: [
        // Icône panier
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined),
          onPressed: () => context.push('/cart'),
        ),
        // Icône profil
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => context.push('/profile'),
        ),
      ],
    );
  }
  
  /// Retourne le titre de la catégorie sélectionnée
  String _getCategoryTitle(String category) {
    switch (category) {
      case 'Tous':
        return 'Tous nos produits';
      case 'Promos':
        return '🔥 Promotions';
      case 'Pizzas':
        return '🍕 Nos pizzas';
      case 'Boissons':
        return '🥤 Boissons';
      case 'Desserts':
        return '🍰 Desserts';
      case 'Menus':
        return '🎉 Menus';
      default:
        return category;
    }
  }
  
  /// Affiche la modal de filtres avec animation d'entrée
  void _showFiltersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // Micro-animation: Entrée fluide de la modal
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: Navigator.of(context),
      ),
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtres',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fonctionnalité à venir...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMedium,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
