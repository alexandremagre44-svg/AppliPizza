// lib/src/screens/cart/cart_screen.dart
// CartScreen redesigné - Style Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart'; 
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';

/// Écran du panier - Redesign Pizza Deli'Zza
/// Style cohérent avec le reste de l'application
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: AppTheme.surfaceWhite,
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

  // refactor empty cart → app_theme standard (colors, spacing, text styles)
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXXXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 70,
                color: AppColors.textLight,
              ),
            ),
            SizedBox(height: AppSpacing.xxxl),
            Text(
              'Votre panier est vide',
              style: AppTextStyles.headlineMedium,
            ),
            SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Ajoutez de délicieuses pizzas pour commencer votre commande',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.xxxl + AppSpacing.sm),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.local_pizza, size: 22),
                label: Text(
                  'Découvrir le menu',
                  style: AppTextStyles.titleLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Carte d'article du panier - Style Pizza Deli'Zza
  /// refactor card style → app_theme standard (radius, shadow, padding)
  Widget _buildCartItemCard(
      BuildContext context, CartItem item, CartNotifier notifier) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image produit
            ClipRRect(
              borderRadius: AppRadius.badge,
              child: Image.network(
                item.imageUrl,
                width: 70, 
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 70,
                    height: 70,
                    color: AppColors.backgroundLight,
                    child: const Icon(
                      Icons.local_pizza,
                      size: 30,
                      color: AppColors.textLight,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // Détails du produit
            Expanded( 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppTheme.textDark,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.price.toStringAsFixed(2)} € / unité',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMedium,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  
                  if (item.customDescription != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        item.customDescription!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMedium,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  
                  const SizedBox(height: 8),

                  // Contrôle de quantité
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          color: AppTheme.primaryRed,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32), 
                          onPressed: () => notifier.decrementQuantity(item.id),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          color: AppTheme.surfaceWhite,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () => notifier.incrementQuantity(item.id),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            
            // Prix et supprimer
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 22),
                  color: AppTheme.errorRed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32), 
                  onPressed: () => notifier.removeItem(item.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Résumé du panier - À emporter uniquement (pas de frais de livraison)
  Widget _buildSummary(BuildContext context, WidgetRef ref, double total) {
    void handleOrder() {
      ref.read(userProvider.notifier).addOrder();
      context.go('/profile'); 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.surfaceWhite),
              SizedBox(width: 12),
              Text('Commande à emporter confirmée !'),
            ],
          ),
          backgroundColor: AppTheme.primaryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Info: À emporter uniquement
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: 18,
                    color: AppTheme.primaryRed,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Commande à emporter',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sous-total',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textMedium,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total à payer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${total.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRed,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: total > 0 ? () => context.push('/checkout') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: AppTheme.surfaceWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Valider ma commande',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}