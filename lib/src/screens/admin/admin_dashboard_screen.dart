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
      body: CustomScrollView(
        slivers: [
          // En-tête avec message de bienvenue
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tableau de bord',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gérez votre pizzeria Pizza Deli\'Zza',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMedium,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Grille de cartes admin
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildListDelegate([
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
                _buildAdminCard(
                  context,
                  icon: Icons.dashboard_customize,
                  title: 'Page Builder',
                  subtitle: 'Organiser l\'affichage',
                  onTap: () => context.push(AppRoutes.adminPageBuilder),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.email,
                  title: 'Mailing',
                  subtitle: 'Marketing & Newsletters',
                  onTap: () => context.push(AppRoutes.adminMailing),
                ),
              ]),
            ),
          ),
          
          // Espace en bas
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
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
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            // Micro-animation: Légère ombre au hover
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
            ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône avec fond rouge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: AppTheme.primaryRed,
                ),
              ),
              const SizedBox(height: 12),
              // Titre
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              // Sous-titre
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMedium,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
