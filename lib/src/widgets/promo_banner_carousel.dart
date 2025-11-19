// lib/src/widgets/promo_banner_carousel.dart
// Carousel de bannières promotionnelles avec animations

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Carousel de bannières promotionnelles
/// - Images pleine largeur
/// - Texte et CTA "Je commande maintenant"
/// - Animations douces (fade ou slide)
class PromoBannerCarousel extends StatefulWidget {
  final List<PromoBanner> banners;

  const PromoBannerCarousel({
    super.key,
    required this.banners,
  });

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Auto-scroll toutes les 5 secondes
    Future.delayed(const Duration(seconds: 5), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;
    
    final nextPage = (_currentPage + 1) % widget.banners.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    
    Future.delayed(const Duration(seconds: 5), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              return _buildBannerCard(widget.banners[index]);
            },
          ),
        ),
        SizedBox(height: AppSpacing.md),
        // Indicateurs de page
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => _buildPageIndicator(index == _currentPage),
          ),
        ),
      ],
    );
  }

  // refactor banner card → app_theme standard (spacing, radius, shadow)
  Widget _buildBannerCard(PromoBanner banner) {
    return Container(
      margin: AppSpacing.paddingHorizontalLG,
      decoration: BoxDecoration(
        borderRadius: AppRadius.radiusXL,
        boxShadow: AppShadows.medium,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusXL,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image de fond
            Image.network(
              banner.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppColors.primaryRedLight,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.surfaceWhite,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.primaryRedLight,
                  child: const Center(
                    child: Icon(
                      Icons.local_pizza,
                      size: 60,
                      color: AppColors.surfaceWhite,
                    ),
                  ),
                );
              },
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
              ),
            ),
            // Contenu texte
            // refactor text and button → app_theme standard
            Positioned(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.xl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.surfaceWhite,
                    ),
                  ),
                  if (banner.subtitle != null) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      banner.subtitle!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.surfaceWhite.withOpacity(0.9),
                      ),
                    ),
                  ],
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: banner.onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceWhite,
                      foregroundColor: AppColors.primaryRed,
                      padding: AppSpacing.buttonPadding.copyWith(
                        top: AppSpacing.md,
                        bottom: AppSpacing.md,
                      ),
                    ),
                    child: const Text('Je commande maintenant'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // refactor page indicator → app_theme standard
  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryRed : AppColors.textLight,
        borderRadius: AppRadius.radiusXS,
      ),
    );
  }
}

/// Modèle de bannière promotionnelle
class PromoBanner {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  PromoBanner({
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.onTap,
  });
}
