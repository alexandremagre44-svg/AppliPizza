// lib/src/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/mock_data.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filtrage des produits pour la page d'accueil
    final popularPizzas = mockProducts.where((p) => p.category == 'Pizza').take(4).toList();
    final popularMenus = mockProducts.where((p) => p.isMenu == true).take(2).toList();
    final cartNotifier = ref.read(cartProvider.notifier);
    
    // Fonction d'ajout au panier
    void handleAddToCart(Product product) {
      cartNotifier.addItem(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ajouté au panier !'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizza Deli\'Zza', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Pizzas Populaires
            _buildSectionHeader(context, 'Pizzas Populaires'),
            SizedBox(
              height: 300, // Hauteur fixe pour le ListView horizontal
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: popularPizzas.length,
                itemBuilder: (context, index) {
                  final product = popularPizzas[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: SizedBox(
                      width: 200,
                      child: ProductCard(
                        product: product,
                        // CORRECTION : onTap a été retiré. La navigation est gérée dans ProductCard.
                        onAddToCart: () => handleAddToCart(product),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Section Menus & Formules
            _buildSectionHeader(context, 'Nos Meilleurs Menus'),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // Important dans un SingleChildScrollView
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7, // Ratio légèrement ajusté pour les cartes
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: popularMenus.length,
              itemBuilder: (context, index) {
                final product = popularMenus[index];
                return ProductCard(
                  product: product,
                  // CORRECTION : onTap a été retiré.
                  onAddToCart: () => handleAddToCart(product),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  // Widget utilitaire pour l'en-tête de section
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w800),
          ),
          TextButton(
            onPressed: () => context.go('/menu'), // Naviguer vers l'écran Menu
            child: const Text('Voir tout >'),
          ),
        ],
      ),
    );
  }
}