// lib/src/widgets/fixed_cart_bar.dart
// Barre panier fixe en bas avec animation pop

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

/// Barre panier fixe en bas de l'écran client
/// - Fond rouge avec coins supérieurs arrondis
/// - Icône panier + texte "Voir le panier" + total dynamique
/// - Animation "pop" lors de l'ajout d'un produit
/// 
/// ANIMATIONS:
/// 1. SlideTransition (400ms) - Entrée depuis le bas au premier produit
/// 2. ScaleTransition (300ms) - Pop sur l'icône panier à chaque ajout
/// Fichier: lib/src/widgets/fixed_cart_bar.dart
/// But: Donner un feedback visuel dynamique et attirer l'attention sur le panier
class FixedCartBar extends ConsumerStatefulWidget {
  const FixedCartBar({super.key});

  @override
  ConsumerState<FixedCartBar> createState() => _FixedCartBarState();
}

class _FixedCartBarState extends ConsumerState<FixedCartBar>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _scaleAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Animation "pop" quand un produit est ajouté
    _popController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _popController,
        curve: Curves.easeOutBack,
      ),
    );

    // Micro-animation: Slide-in depuis le bas au premier ajout
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _popController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Déclenche l'animation "pop" quand un produit est ajouté
  void _triggerPopAnimation() {
    _popController.forward().then((_) {
      _popController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final itemCount = cart.items.length;
    final total = cart.total;

    // Déclencher les animations selon l'état du panier
    ref.listen<CartState>(cartProvider, (previous, next) {
      // Premier produit ajouté: slide-in
      if ((previous == null || previous.items.isEmpty) && next.items.isNotEmpty) {
        _isVisible = true;
        _slideController.forward();
      }
      // Produit supplémentaire: pop
      else if (previous != null && next.items.length > previous.items.length) {
        _triggerPopAnimation();
      }
    });

    // Ne pas afficher la barre si le panier est vide
    if (itemCount == 0) {
      _isVisible = false;
      _slideController.reverse();
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
            onTap: () => context.push('/cart'),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icône panier avec badge de quantité
                    Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.shopping_bag,
                              color: AppTheme.surfaceWhite,
                              size: 28,
                            ),
                            // Badge quantité
                            if (itemCount > 0)
                              Positioned(
                                right: -8,
                                top: -8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.accentGold,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    itemCount.toString(),
                                    style: const TextStyle(
                                      color: AppTheme.textDark,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Voir le panier',
                          style: TextStyle(
                            color: AppTheme.surfaceWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    // Total avec animation
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${total.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: AppTheme.surfaceWhite,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
