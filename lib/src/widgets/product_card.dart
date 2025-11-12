// lib/src/widgets/product_card.dart
// Carte produit redesignée - Style Pizza Deli'Zza

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

/// Carte produit avec le nouveau design Pizza Deli'Zza
/// - Cartes arrondies avec photo, nom, description courte, prix
/// - Badge "Personnaliser" rouge en bas à droite en overlay pour pizzas/menus
/// - Badge quantité si dans le panier
/// - Effet shadow et animation scale subtile au tap
/// 
/// ANIMATION: ScaleTransition sur tap (150ms) - Feedback visuel subtil
/// Fichier: lib/src/widgets/product_card.dart
/// But: Améliorer l'expérience utilisateur en donnant un feedback visuel au tap
class ProductCard extends StatefulWidget {
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
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Animation scale subtile au tap - Micro-animation pour améliorer l'UX
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      // refactor card style → app_theme standard (8px radius)
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onAddToCart,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Image du produit avec badges - Ratio 3:2 pour plus de hauteur
              AspectRatio(
                aspectRatio: 3 / 2, // Ratio 3:2 pour images plus hautes
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image - suppression du pin gris placeholder si pas d'image
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.sm),
                      ),
                      child: widget.product.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.product.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: AppColors.backgroundLight,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.primaryRed,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.backgroundLight,
                                  child: const Center(
                                    child: Icon(
                                      Icons.local_pizza,
                                      size: 48,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppColors.backgroundLight,
                              child: const Center(
                                child: Icon(
                                  Icons.local_pizza,
                                  size: 48,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ),
                    ),
                    // Badge "Personnaliser" en overlay semi-transparent en bas à droite
                    // refactor badge style → app_theme standard (8px radius, spacing)
                    if (widget.product.category == 'Pizza' || widget.product.isMenu)
                      Positioned(
                        bottom: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withOpacity(0.9),
                            borderRadius: AppRadius.badge,
                            boxShadow: AppShadows.soft,
                          ),
                          child: Text(
                            'Personnaliser',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.surfaceWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Badge quantité si dans le panier
                    // refactor badge style → app_theme standard
                    if (widget.cartQuantity != null && widget.cartQuantity! > 0)
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: AppRadius.badge,
                            boxShadow: AppShadows.soft,
                          ),
                          child: Text(
                            'x${widget.cartQuantity}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Contenu texte
              // refactor padding and text styles → app_theme standard
              Expanded(
                child: Padding(
                  padding: AppSpacing.paddingMD,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du produit - 2 lignes max
                      Text(
                        widget.product.name,
                        style: AppTextStyles.titleSmall.copyWith(
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      // Description courte
                      Expanded(
                        child: Text(
                          widget.product.description,
                          style: AppTextStyles.labelSmall.copyWith(
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      // Prix - Rouge #C62828, bold, taille 16
                      // refactor price style → app_theme standard
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.product.price.toStringAsFixed(2)} €',
                            style: AppTextStyles.price,
                          ),
                          // Icône panier
                          // refactor icon button → app_theme standard
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed,
                              borderRadius: AppRadius.badge,
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              size: 18,
                              color: AppColors.surfaceWhite,
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
      ),
    );
  }
}
