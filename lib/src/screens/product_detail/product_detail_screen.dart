// lib/src/screens/product_detail/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/ingredient_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final Product product;
  
  // Constructeur pour recevoir l'objet Product
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Le Notifier du panier
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image en pleine largeur
            Image.network(
              product.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du produit et Prix
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),

                  // Section Ingrédients de Base (si non Menu)
                  if (!product.isMenu) 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingrédients de base',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Consumer(
                          builder: (context, ref, child) {
                            final ingredientsAsync = ref.watch(ingredientStreamProvider);
                            return ingredientsAsync.when(
                              data: (allIngredients) {
                                // Create a map of ingredient IDs to names
                                Map<String, String> ingredientNames = {};
                                for (final ing in allIngredients) {
                                  ingredientNames[ing.id] = ing.name;
                                }
                                
                                return Wrap(
                                  spacing: 8.0,
                                  children: product.baseIngredients!
                                      .map((ingId) {
                                        final ingredientName = ingredientNames[ingId] ?? ingId;
                                        return Chip(
                                          label: Text(ingredientName),
                                          backgroundColor: Colors.grey[200],
                                          labelStyle: const TextStyle(fontSize: 14),
                                        );
                                      })
                                      .toList(),
                                );
                              },
                              loading: () => const SizedBox(
                                height: 20,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              error: (error, stack) => Text(
                                'Erreur lors du chargement des ingrédients',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Barre du bas pour l'ajout au panier
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea( // Utiliser SafeArea pour ne pas interférer avec la barre d'accueil
          minimum: const EdgeInsets.only(bottom: 0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            label: Text('Ajouter au panier (${product.price.toStringAsFixed(2)} €)'),
            onPressed: () {
              // Ajout de l'article au panier
              cartNotifier.addItem(product);
              
              // Affichage d'une confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} a été ajouté au panier !'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ),
    );
  }
}