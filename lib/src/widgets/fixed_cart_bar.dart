// lib/src/widgets/fixed_cart_bar.dart
// Barre panier fixe en bas avec animation pop
// MIGRATED to WL V2 Theme - Uses theme primary color

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../../white_label/theme/theme_extensions.dart';

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
/// 
/// WL V2 MIGRATION: Uses Theme.of(context).colorScheme.primary for background
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
        // WL V2: Uses theme primary color for background
        child: Container(
          decoration: BoxDecoration(
            color: context.primaryColor, // WL V2: Theme primary
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
            boxShadow: AppShadows.medium,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
            onTap: () => context.push('/cart'),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
            child: SafeArea(
              top: false,
              // refactor padding → app_theme standard
              child: Padding(
                padding: AppSpacing.paddingLG.copyWith(
                  top: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icône panier avec badge de quantité
                    Row(
                      children: [
                        // WL V2: Uses theme colors
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.shopping_bag,
                              color: context.onPrimary, // WL V2: Contrast color
                              size: 28,
                            ),
                            // Badge quantité
                            if (itemCount > 0)
                              Positioned(
                                right: -8,
                                top: -8,
                                child: Container(
                                  padding: AppSpacing.paddingXS,
                                  decoration: BoxDecoration(
                                    color: context.surfaceColor, // WL V2: Theme surface
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    itemCount.toString(),
                                    style: context.labelSmall?.copyWith( // WL V2: Theme text
                                      color: context.primaryColor, // WL V2: Theme primary
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: AppSpacing.lg),
                        Text(
                          'Voir le panier',
                          style: context.titleLarge?.copyWith( // WL V2: Theme text
                            color: context.onPrimary, // WL V2: Contrast color
                          ),
                        ),
                      ],
                    ),
                    // Total avec animation - WL V2: Uses theme colors
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: context.onPrimary.withOpacity(0.2), // WL V2: Contrast with opacity
                        borderRadius: AppRadius.radiusXL,
                      ),
                      child: Text(
                        '${total.toStringAsFixed(2)} €',
                        style: context.titleLarge?.copyWith( // WL V2: Theme text
                          color: context.onPrimary, // WL V2: Contrast color
                          fontWeight: FontWeight.bold,
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
