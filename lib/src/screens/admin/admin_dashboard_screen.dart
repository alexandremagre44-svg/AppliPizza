// lib/src/screens/admin/admin_dashboard_screen.dart
// Tableau de bord admin - Redesign Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';

/// Dashboard admin avec design cohérent Pizza Deli'Zza
/// - En-tête rouge avec logo et bouton déconnexion
/// - Navigation vers les différentes sections de gestion
/// - Cartes avec icônes et design harmonisé
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            // Logo à gauche
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_pizza,
                color: AppTheme.surfaceWhite,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pizza Deli\'Zza',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.surfaceWhite,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Administration',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.surfaceWhite,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppTheme.primaryRed,
        elevation: 2, // Légère ombre pour l'admin
        shadowColor: Colors.black.withOpacity(0.2),
        actions: [
          // Nom utilisateur (simulé)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(
                'Admin',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.surfaceWhite,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          // Bouton déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              // TODO: Implémenter la déconnexion
              context.go('/login');
            },
          ),
        ],
      ),
      // refactor admin dashboard → app_theme standard
      body: CustomScrollView(
        slivers: [
          // En-tête avec message de bienvenue
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingXL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tableau de bord',
                    style: AppTextStyles.headlineLarge,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Gérez votre pizzeria Pizza Deli\'Zza',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          // Section Opérations
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingHorizontalLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Opérations',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Gestion quotidienne de la pizzeria',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: AppSpacing.paddingHorizontalLG,
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildAdminCard(
                  context,
                  icon: Icons.shopping_bag,
                  title: 'Commandes',
                  subtitle: 'Gérer les commandes',
                  onTap: () => context.push(AppRoutes.adminOrders),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.restaurant,
                  title: 'Cuisine',
                  subtitle: 'Mode cuisine',
                  onTap: () => context.push(AppRoutes.kitchen),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.local_pizza,
                  title: 'Pizzas',
                  subtitle: 'Gérer les pizzas',
                  onTap: () => context.push(AppRoutes.adminPizza),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.restaurant_menu,
                  title: 'Menus',
                  subtitle: 'Gérer les menus',
                  onTap: () => context.push(AppRoutes.adminMenu),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.local_drink,
                  title: 'Boissons',
                  subtitle: 'Gérer les boissons',
                  onTap: () => context.push(AppRoutes.adminDrinks),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.cake,
                  title: 'Desserts',
                  subtitle: 'Gérer les desserts',
                  onTap: () => context.push(AppRoutes.adminDesserts),
                ),
              ]),
            ),
          ),

          // Section Communication
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingHorizontalLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Communication',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Marketing, promotions et fidélité',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: AppSpacing.paddingHorizontalLG,
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildAdminCard(
                  context,
                  icon: Icons.email,
                  title: 'Mailing',
                  subtitle: 'Campagnes & Newsletters',
                  onTap: () => context.push(AppRoutes.adminMailing),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.local_offer,
                  title: 'Promotions',
                  subtitle: 'Gérer les promos',
                  onTap: () => context.push(AppRoutes.communicationPromotions),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.loyalty,
                  title: 'Fidélité & Segments',
                  subtitle: 'Programme de fidélité',
                  onTap: () => context.push(AppRoutes.communicationLoyalty),
                ),
              ]),
            ),
          ),

          // Section Studio
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingHorizontalLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Studio',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Configuration et personnalisation de l\'app',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: AppSpacing.paddingHorizontalLG,
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
                _buildAdminCard(
                  context,
                  icon: Icons.home,
                  title: 'Page d\'accueil',
                  subtitle: 'Bannières & Blocs',
                  onTap: () => context.push(AppRoutes.studioHomeConfig),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.card_giftcard,
                  title: 'Popups & Roulette',
                  subtitle: 'Animations & Gains',
                  onTap: () => context.push(AppRoutes.studioPopupsRoulette),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.text_fields,
                  title: 'Textes & Messages',
                  subtitle: 'Personnaliser l\'app',
                  onTap: () => context.push(AppRoutes.studioTexts),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.star,
                  title: 'Mise en avant',
                  subtitle: 'Tags produits',
                  onTap: () => context.push(AppRoutes.studioFeaturedProducts),
                ),
              ]),
            ),
          ),
          
          // Espace en bas
          SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  /// Carte admin avec design Pizza Deli'Zza et animation hover
  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      // Micro-animation: FadeIn pour l'apparition des cartes
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      // refactor card style → app_theme standard (radius, padding, colors, text)
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardLarge,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardLarge,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: AppRadius.cardLarge,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // Icône avec fond rouge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: AppColors.primaryRed,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              // Titre
              Text(
                title,
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xs),
              // Sous-titre
              Text(
                subtitle,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
