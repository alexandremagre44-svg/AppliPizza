// lib/src/screens/cart/cart_screen.dart
// CartScreen redesigné - Style Pizza Deli'Zza
// PROMPT 3F - Uses centralized text system
// MIGRATED to WL V2 Theme - Uses theme colors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart'; 
import '../../providers/user_provider.dart';
import '../../providers/app_texts_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/restaurant_plan_provider.dart';
import '../../theme/app_theme.dart';
import '../../../white_label/core/module_id.dart';
import '../delivery/delivery_summary_widget.dart';
import '../delivery/delivery_not_available_widget.dart';
import '../../../white_label/theme/theme_extensions.dart';

/// Écran du panier - Redesign Pizza Deli'Zza
/// Style cohérent avec le reste de l'application
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final appTextsAsync = ref.watch(appTextsProvider);

    return appTextsAsync.when(
      data: (appTexts) => Scaffold(
        appBar: AppBar(
          title: Text(appTexts.cart.title),
          centerTitle: true,
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: AppTheme.surfaceWhite,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/menu'), 
          ),
        ),
        body: cartState.items.isEmpty
            ? _buildEmptyCart(context, appTexts.cart)
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
                  _buildSummary(context, ref, cartState.total, appTexts.cart), 
                ],
              ),
      ),
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Mon Panier'),
          centerTitle: true,
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: AppTheme.surfaceWhite,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(
          title: const Text('Mon Panier'),
          centerTitle: true,
          backgroundColor: AppTheme.primaryRed,
          foregroundColor: AppTheme.surfaceWhite,
        ),
        body: cartState.items.isEmpty
            ? _buildEmptyCart(context, null)
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
                  _buildSummary(context, ref, cartState.total, null), 
                ],
              ),
      ),
    );
  }

  // refactor empty cart → app_theme standard (colors, spacing, text styles)
  Widget _buildEmptyCart(BuildContext context, dynamic cartTexts) {
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
                color: context.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 70,
                color: context.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.xxxl),
            Text(
              cartTexts?.emptyTitle ?? 'Votre panier est vide',
              style: AppTextStyles.headlineMedium,
            ),
            SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                cartTexts?.emptyMessage ?? 'Ajoutez de délicieuses pizzas pour commencer votre commande',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.xxxl + AppSpacing.sm),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/menu'),
                icon: const Icon(Icons.local_pizza, size: 22),
                label: Text(
                  cartTexts?.ctaViewMenu ?? 'Découvrir le menu',
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
      shadowColor: context.colorScheme.shadow.withOpacity(0.1),
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
                    color: context.backgroundColor,
                    child: const Icon(
                      Icons.local_pizza,
                      size: 30,
                      color: context.textSecondary,
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
  
  /// Résumé du panier avec support livraison
  Widget _buildSummary(BuildContext context, WidgetRef ref, double total, dynamic cartTexts) {
    final deliveryState = ref.watch(deliveryProvider);
    final deliverySettings = ref.watch(deliverySettingsProvider);
    final isDeliveryEnabled = ref.watch(isDeliveryEnabledProvider);
    final flags = ref.watch(restaurantFeatureFlagsProvider);
    
    // Calculer les frais de livraison
    double deliveryFee = 0.0;
    if (deliveryState.isDeliverySelected && deliveryState.selectedArea != null) {
      if (deliverySettings != null) {
        deliveryFee = computeDeliveryFee(
          deliverySettings,
          deliveryState.selectedArea!,
          total,
        );
      } else {
        deliveryFee = deliveryState.selectedArea!.deliveryFee;
      }
    }
    
    // Vérifier le minimum de commande
    final minimumOk = !deliveryState.isDeliverySelected ||
        (deliverySettings != null
            ? isMinimumReached(deliverySettings, deliveryState.selectedArea, total)
            : (deliveryState.selectedArea == null ||
                total >= deliveryState.selectedArea!.minimumOrderAmount));
    
    final finalTotal = total + deliveryFee;
    
    // Obtenir le montant minimum requis
    final minimumAmount = deliverySettings != null && deliveryState.selectedArea != null
        ? getMinimumOrderAmount(deliverySettings, deliveryState.selectedArea)
        : (deliveryState.selectedArea?.minimumOrderAmount ?? 0);
    
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
            // Mode de retrait
            _buildDeliveryModeIndicator(context, ref, deliveryState, isDeliveryEnabled),
            
            const SizedBox(height: 12),
            
            // Avertissement minimum non atteint (seulement si livraison et minimum non atteint)
            if (isDeliveryEnabled && 
                deliveryState.isDeliverySelected && 
                !minimumOk &&
                (flags?.has(ModuleId.delivery) ?? false))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DeliveryMinimumWarning(
                  minimumAmount: minimumAmount,
                  currentAmount: total,
                  onAddItems: () => context.go('/menu'),
                ),
              ),
            
            // Récapitulatif livraison compact
            if (deliveryState.isDeliveryConfigured &&
                (flags?.has(ModuleId.delivery) ?? false))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDeliveryInfo(context, deliveryState, deliveryFee),
              ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cartTexts?.subtotalLabel ?? 'Sous-total',
                  style: const TextStyle(
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
            
            // Frais de livraison (si applicable)
            if (deliveryState.isDeliverySelected && 
                (flags?.has(ModuleId.delivery) ?? false)) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.delivery_dining, size: 16, color: AppTheme.textMedium),
                      const SizedBox(width: 4),
                      const Text(
                        'Frais de livraison',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textMedium,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  Text(
                    deliveryFee > 0 
                        ? '${deliveryFee.toStringAsFixed(2)} €'
                        : 'Gratuit',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: deliveryFee == 0 ? AppColors.success : context.onSurface,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
            
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cartTexts?.totalLabel ?? 'Total à payer',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  '${finalTotal.toStringAsFixed(2)} €',
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
                // Désactiver si minimum non atteint
                onPressed: total > 0 && minimumOk 
                    ? () => context.push('/checkout') 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: AppTheme.surfaceWhite,
                  disabledBackgroundColor: context.colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  minimumOk 
                      ? (cartTexts?.ctaCheckout ?? 'Valider ma commande')
                      : 'Minimum non atteint',
                  style: const TextStyle(
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
  
  /// Indicateur du mode de retrait
  Widget _buildDeliveryModeIndicator(
    BuildContext context, 
    WidgetRef ref, 
    DeliveryState deliveryState, 
    bool isDeliveryEnabled,
  ) {
    final flags = ref.watch(restaurantFeatureFlagsProvider);
    
    // Si livraison non activée, afficher seulement le mode à emporter
    if (!isDeliveryEnabled || !(flags?.has(ModuleId.delivery) ?? false)) {
      return Container(
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
      );
    }
    
    // Mode livraison activé - afficher les deux options
    return Row(
      children: [
        Expanded(
          child: _buildModeButton(
            context,
            ref,
            icon: Icons.shopping_bag,
            label: 'À emporter',
            isSelected: !deliveryState.isDeliverySelected,
            onTap: () {
              ref.read(deliveryProvider.notifier).setMode(DeliveryMode.takeAway);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildModeButton(
            context,
            ref,
            icon: Icons.delivery_dining,
            label: 'Livraison',
            isSelected: deliveryState.isDeliverySelected,
            onTap: () {
              ref.read(deliveryProvider.notifier).setMode(DeliveryMode.delivery);
              // Naviguer vers l'écran d'adresse si pas encore configuré
              if (!deliveryState.isDeliveryConfigured) {
                context.push('/delivery/address');
              }
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildModeButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed.withOpacity(0.1) : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? context.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppTheme.primaryRed : AppTheme.textMedium,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryRed : AppTheme.textMedium,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Info de livraison compacte
  Widget _buildDeliveryInfo(BuildContext context, DeliveryState deliveryState, double deliveryFee) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppTheme.primaryRed),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  deliveryState.selectedAddress?.formattedAddress ?? 'Adresse non définie',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textDark,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/delivery/address'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Modifier',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          if (deliveryState.selectedArea != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppTheme.textMedium),
                const SizedBox(width: 6),
                Text(
                  '${deliveryState.selectedArea!.estimatedMinutes} min • Zone ${deliveryState.selectedArea!.name}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMedium,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}