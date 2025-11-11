// lib/src/widgets/product_card.dart
// Carte produit redesignée - Style Pizza Deli'Zza

import 'package:flutter/material.dart';
import '../models/widget.product.dart';
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
  final int? widget.cartQuantity; // Quantité dans le panier (optionnel)

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.widget.cartQuantity,
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
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onAddToCart,
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surfaceWhite,
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: widget.product.imageUrl.isNotEmpty
                          ? Image.network(
                              widget.product.imageUrl,
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
                            )
                          : Container(
                              color: AppTheme.backgroundLight,
                              child: const Center(
                                child: Icon(
                                  Icons.local_pizza,
                                  size: 48,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ),
                    ),
                    // Badge "Personnaliser" en overlay semi-transparent en bas à droite
                    if (widget.product.category == 'Pizza' || widget.product.isMenu)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed.withOpacity(0.9), // Semi-transparent
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
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
                    if (widget.cartQuantity != null && widget.cartQuantity! > 0)
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
                            'x$widget.cartQuantity',
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
                        widget.product.name,
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
                          widget.product.description,
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
                      // Prix - Rouge #C62828, bold, taille 16
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.product.price.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              color: Color(0xFFC62828), // Rouge exact #C62828
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
