// lib/src/widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../core/constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          context.push('/details', extra: product);
        },
        borderRadius: BorderRadius.circular(VisualConstants.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit avec badge
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(VisualConstants.radiusLarge)),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          alignment: Alignment.center,
                          color: Colors.grey[200],
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_pizza, size: 50, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Image non disponible',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Badge pour les menus - Positionné en haut à gauche
                  if (product.isMenu)
                    Positioned(
                      top: VisualConstants.paddingSmall,
                      left: VisualConstants.paddingSmall,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(VisualConstants.radiusMedium),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.restaurant_menu, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'MENU',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Gradient overlay at bottom for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
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
                  ),
                ],
              ),
            ),

            // Détails et Prix
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nom du produit avec overflow handling
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: VisualConstants.maxLinesTitle,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description avec overflow handling
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: VisualConstants.maxLinesDescription,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Prix et bouton
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Prix avec style amélioré
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(VisualConstants.radiusSmall),
                            ),
                            child: Text(
                              '${product.price.toStringAsFixed(2)} €',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // Bouton Ajouter au Panier
                        Material(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: onAddToCart,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
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
    );
  }
}