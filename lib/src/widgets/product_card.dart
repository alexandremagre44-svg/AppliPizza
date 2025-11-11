// lib/src/widgets/product_card.dart
// Carte produit redesignée - Style Pizza Deli'Zza

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Carte produit avec le nouveau design Pizza Deli'Zza
/// - Cartes arrondies avec photo, nom, description courte, prix
/// - Badge "Personnaliser" rouge en haut à droite pour pizzas/menus
/// - Badge quantité si dans le panier
/// - Effet shadow et hover subtil
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final int? cartQuantity; // Quantité dans le panier (optionnel)

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.cartQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onAddToCart,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceWhite,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image du produit avec badges - Hauteur fixe
              SizedBox(
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppTheme.backgroundLight,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.primaryRed,
                                ),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.backgroundLight,
                            child: const Center(
                              child: Icon(
                                Icons.local_pizza,
                                size: 48,
                                color: AppTheme.textLight,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Badge "Personnaliser" pour pizzas/menus
                    if (product.category == 'Pizza' || product.isMenu)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Personnaliser',
                            style: TextStyle(
                              color: AppTheme.surfaceWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    // Badge quantité si dans le panier
                    if (cartQuantity != null && cartQuantity! > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'x$cartQuantity',
                            style: const TextStyle(
                              color: AppTheme.textDark,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Contenu texte
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du produit - 2 lignes max
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Description courte
                      Expanded(
                        child: Text(
                          product.description,
                          style: const TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Prix
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              color: AppTheme.primaryRed,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          // Icône panier
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              size: 18,
                              color: AppTheme.surfaceWhite,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
