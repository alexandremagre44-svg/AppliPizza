// lib/src/widgets/product_card.dart
// Carte produit redesignée - Style Pizza Deli'Zza
// MIGRATED to WL V2 Theme - Uses Theme.of(context) for all colors

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../../white_label/theme/theme_extensions.dart';

/// Carte produit avec le nouveau design Pizza Deli'Zza
/// - Cartes arrondies avec photo, nom, description courte, prix
/// - Badge "Personnaliser" rouge en bas à droite en overlay pour pizzas/menus
/// - Badge quantité si dans le panier
/// - Effet shadow et animation scale subtile au tap
/// 
/// ANIMATION: ScaleTransition sur tap (150ms) - Feedback visuel subtil
/// Fichier: lib/src/widgets/product_card.dart
/// But: Améliorer l'expérience utilisateur en donnant un feedback visuel au tap
/// 
/// WL V2 MIGRATION: All colors now use Theme.of(context).colorScheme
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
      // Card inherits style from Theme.cardTheme (UnifiedThemeAdapter)
      child: Card(
        // elevation, shadowColor, shape inherited from cardTheme
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onAddToCart,
          child: Container(
            decoration: BoxDecoration(
              color: context.surfaceColor, // WL V2: Uses theme surface color
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
                                  color: context.backgroundColor, // WL V2: Theme background
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: context.primaryColor, // WL V2: Theme primary
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: context.backgroundColor, // WL V2: Theme background
                                  child: Center(
                                    child: Icon(
                                      Icons.local_pizza,
                                      size: 48,
                                      color: context.textSecondary, // WL V2: Theme text secondary
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: context.backgroundColor, // WL V2: Theme background
                              child: Center(
                                child: Icon(
                                  Icons.local_pizza,
                                  size: 48,
                                  color: context.textSecondary, // WL V2: Theme text secondary
                                ),
                              ),
                            ),
                    ),
                    // Badge "Personnaliser" - WL V2: Uses theme primary color
                    if (widget.product.category == ProductCategory.pizza || widget.product.isMenu)
                      Positioned(
                        bottom: AppSpacing.sm,
                        right: AppSpacing.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withOpacity(0.9), // WL V2: Theme primary
                            borderRadius: AppRadius.badge,
                            boxShadow: AppShadows.soft,
                          ),
                          child: Text(
                            'Personnaliser',
                            style: context.labelSmall?.copyWith( // WL V2: Theme text style
                              color: context.onPrimary, // WL V2: Contrast color
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Badge quantité - WL V2: Uses theme primary color
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
                            color: context.primaryContainer, // WL V2: Theme primary container
                            borderRadius: AppRadius.badge,
                            boxShadow: AppShadows.soft,
                          ),
                          child: Text(
                            'x${widget.cartQuantity}',
                            style: context.labelSmall?.copyWith( // WL V2: Theme text style
                              color: context.onPrimaryContainer, // WL V2: Contrast color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Product tags badges in top right corner
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // WL V2 NOTE: Semantic colors (warning=orange, success=green)
                          // are kept as AppColors for consistency across themes
                          if (widget.product.isBestSeller)
                            Container(
                              margin: EdgeInsets.only(bottom: AppSpacing.xs),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.95), // Semantic: orange
                                borderRadius: AppRadius.badge,
                                boxShadow: AppShadows.soft,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.trending_up, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Best-seller',
                                    style: context.labelSmall?.copyWith( // WL V2: Theme text
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.product.isNew)
                            Container(
                              margin: EdgeInsets.only(bottom: AppSpacing.xs),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.95), // Semantic: green
                                borderRadius: AppRadius.badge,
                                boxShadow: AppShadows.soft,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.new_releases, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Nouveau',
                                    style: context.labelSmall?.copyWith( // WL V2: Theme text
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.product.isChefSpecial)
                            Container(
                              margin: EdgeInsets.only(bottom: AppSpacing.xs),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentGold.withOpacity(0.95), // Semantic: gold
                                borderRadius: AppRadius.badge,
                                boxShadow: AppShadows.soft,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Spécial Chef',
                                    style: context.labelSmall?.copyWith( // WL V2: Theme text
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.product.isKidFriendly)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.secondaryColor.withOpacity(0.95), // WL V2: Theme secondary
                                borderRadius: AppRadius.badge,
                                boxShadow: AppShadows.soft,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.child_care, size: 12, color: context.onSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Enfants',
                                    style: context.labelSmall?.copyWith( // WL V2: Theme text
                                      color: context.onSecondary, // WL V2: Contrast color
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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
                          // Icône panier - WL V2: Uses theme primary color
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: context.primaryColor, // WL V2: Theme primary
                              borderRadius: AppRadius.badge,
                            ),
                            child: Icon(
                              Icons.add_shopping_cart,
                              size: 18,
                              color: context.onPrimary, // WL V2: Contrast color
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
