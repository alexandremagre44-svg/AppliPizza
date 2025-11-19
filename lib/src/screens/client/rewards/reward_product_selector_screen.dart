// lib/src/screens/client/rewards/reward_product_selector_screen.dart
// Screen for selecting a free product when using a reward ticket

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../models/reward_ticket.dart';
import '../../../models/reward_action.dart';
import '../../../models/product.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../services/reward_service.dart';

/// Screen for selecting a product to redeem with a reward ticket
/// 
/// This screen displays eligible products based on the ticket's reward type:
/// - free_product: Shows the specific product (if productId is set)
/// - free_category: Shows products from the specified category
/// - free_any_pizza: Shows all pizzas
/// - free_drink: Shows all drinks
class RewardProductSelectorScreen extends ConsumerStatefulWidget {
  final RewardTicket ticket;

  const RewardProductSelectorScreen({
    super.key,
    required this.ticket,
  });

  @override
  ConsumerState<RewardProductSelectorScreen> createState() =>
      _RewardProductSelectorScreenState();
}

class _RewardProductSelectorScreenState
    extends ConsumerState<RewardProductSelectorScreen> {
  final RewardService _rewardService = RewardService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisissez votre produit'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: productsAsync.when(
        data: (products) {
          final eligibleProducts = _getEligibleProducts(products);

          if (eligibleProducts.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Header with reward info
              Container(
                width: double.infinity,
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      widget.ticket.action.label ?? 'Produit offert',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.ticket.action.description != null) ...[
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.ticket.action.description!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),

              // Product grid
              Expanded(
                child: GridView.builder(
                  padding: AppSpacing.paddingLG,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: eligibleProducts.length,
                  itemBuilder: (context, index) {
                    final product = eligibleProducts[index];
                    return _buildProductCard(product);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  /// Get products eligible for this reward
  List<Product> _getEligibleProducts(List<Product> allProducts) {
    final action = widget.ticket.action;

    switch (action.type) {
      case RewardType.freeProduct:
        // Specific product
        if (action.productId != null) {
          return allProducts
              .where((p) => p.id == action.productId)
              .toList();
        }
        return [];

      case RewardType.freeCategory:
        // Products from a category
        if (action.categoryId != null) {
          return allProducts
              .where((p) => p.category.value == action.categoryId)
              .where((p) => p.isActive)
              .toList();
        }
        return [];

      case RewardType.freeAnyPizza:
        // All pizzas
        return allProducts
            .where((p) => p.category == ProductCategory.pizza)
            .where((p) => p.isActive)
            .toList();

      case RewardType.freeDrink:
        // All drinks
        return allProducts
            .where((p) => p.category == ProductCategory.boissons)
            .where((p) => p.isActive)
            .toList();

      default:
        return [];
    }
  }

  /// Build product card
  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: InkWell(
        onTap: _isProcessing ? null : () => _selectProduct(product),
        borderRadius: AppRadius.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surfaceContainerLow,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Icon(
                          Icons.fastfood,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
            ),

            // Product info
            Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  
                  // Price strikethrough + "OFFERT" badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} €',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: AppRadius.badge,
                        ),
                        child: Text(
                          'OFFERT',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 80,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Aucun produit disponible',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Les produits éligibles pour cette récompense ne sont pas disponibles pour le moment.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Handle product selection
  Future<void> _selectProduct(Product product) async {
    setState(() => _isProcessing = true);

    try {
      // Add product to cart with price 0
      final cartNotifier = ref.read(cartProvider.notifier);
      final freeProduct = product.copyWith(price: 0.0);
      cartNotifier.addItem(
        freeProduct,
        customDescription: '🎁 Offert (${widget.ticket.action.label})',
      );

      // Mark ticket as used
      await _rewardService.markTicketUsed(
        widget.ticket.userId,
        widget.ticket.id,
      );

      if (mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 28,
                ),
                SizedBox(width: AppSpacing.sm),
                const Text('Produit ajouté !'),
              ],
            ),
            content: Text(
              '${product.name} a été ajouté gratuitement à votre panier.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close selector
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
