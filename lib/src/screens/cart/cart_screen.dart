// lib/src/screens/cart/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart'; 
import '../../providers/user_provider.dart'; 

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), 
        ),
      ),
      body: cartState.items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: cartState.items.length,
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return _buildCartItemCard(context, item, cartNotifier); 
                    },
                  ),
                ),
                _buildSummary(context, ref, cartState.total), 
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Votre panier est vide !',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Ajoutez-y de délicieuses pizzas pour commander.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => context.go('/menu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB00020),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Voir le menu', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
  
  // CORRECTION : Espacement réduit et utilisation de Flexible/Contraintes pour éviter l'overflow
  Widget _buildCartItemCard(
      BuildContext context, CartItem item, CartNotifier notifier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image (70x70)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 70, 
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                    return Container(width: 70, height: 70, color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 30, color: Colors.grey));
                },
              ),
            ),
            const SizedBox(width: 8),

            // Détails du produit (Expanded pour corriger l'overflow)
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('${item.price.toStringAsFixed(2)} € / unité', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  
                  if (item.customDescription != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        item.customDescription!,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  const SizedBox(height: 8),

                  // Contrôle de quantité
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 24),
                        color: Colors.grey,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24), 
                        onPressed: () => notifier.decrementQuantity(item.id),
                      ),
                      // CORRECTION APPLIQUÉE ICI : RETRAIT DU 'const' sur Padding
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 24),
                        color: Colors.grey,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        onPressed: () => notifier.incrementQuantity(item.id),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            
            // Prix et Supprimer (Flexible pour éviter le débordement)
            Flexible( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.total.toStringAsFixed(2)} €',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: const Color(0xFFB00020), fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 24),
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24), 
                    onPressed: () => notifier.removeItem(item.id),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummary(BuildContext context, WidgetRef ref, double total) {
    // Dans ce projet, nous allons introduire des frais de livraison fixes pour l'exemple
    const double deliveryFee = 5.00; 
    final finalTotal = total + deliveryFee;

    void handleOrder() {
      ref.read(userProvider.notifier).addOrder();

      context.go('/profile'); 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande passée avec succès !'),
          backgroundColor: Color(0xFFB00020),
        ),
      );
    }
    
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sous-total',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                '${total.toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Frais de livraison',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              Text(
                '${deliveryFee.toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total à payer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${finalTotal.toStringAsFixed(2)} €',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: const Color(0xFFB00020),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: total > 0 ? handleOrder : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB00020),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Passer la commande', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}