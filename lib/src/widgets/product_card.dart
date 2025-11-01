// lib/src/widgets/product_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import nécessaire pour context.push
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  // CORRECTION : 'onTap' a été retiré du constructeur
  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Navigation au clic de la carte (utilise le produit)
      onTap: () {
        context.push('/details', extra: product); 
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit (FLEX: 2)
            Expanded(
              flex: 2, 
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.grey[200], 
                      child: const CircularProgressIndicator.adaptive(),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            
            // Détails et Prix (FLEX: 3)
            Expanded(
              flex: 3, 
              child: Padding(
                padding: const EdgeInsets.all(8.0), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nom du produit
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold), 
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Description (raccourcie)
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600]), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Prix
                        Text(
                          '${product.price.toStringAsFixed(2)} €',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.primary, // Rouge
                          ),
                        ),
                        
                        // Bouton Ajouter au Panier (style épuré)
                        SizedBox(
                          height: 32, 
                          child: ElevatedButton(
                            onPressed: onAddToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary, 
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 8), 
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), 
                            ),
                            child: const Icon(Icons.add_shopping_cart, size: 18), 
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