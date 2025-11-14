// lib/src/screens/admin/admin_studio_screen.dart
// Studio Builder - Écran principal unifié pour la gestion de l'apparence

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../core/constants.dart';

/// Studio Builder - Interface unifiée pour gérer l'apparence de l'application
/// 
/// Cet écran sert de point d'entrée unique pour tous les modules de configuration
/// visuels et de contenu de l'application. Il remplace progressivement les anciennes
/// pages admin éclatées.
/// 
/// Sections disponibles:
/// - Hero: Configuration du bandeau principal
/// - Bandeau: Gestion des bannières
/// - Popups: Configuration des popups et animations
/// - Textes: Personnalisation des messages
/// - Mise en avant: Gestion des tags produits
/// - Contenu: CMS Headless pour le contenu
class AdminStudioScreen extends StatelessWidget {
  const AdminStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            // Logo Studio Builder
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.palette,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Studio Builder',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Configuration de l\'app',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // En-tête avec description
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingXL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gérez l\'apparence de votre app',
                    style: AppTextStyles.headlineLarge,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Configurez tous les aspects visuels et le contenu de votre application depuis un seul endroit.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grille des sections
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildListDelegate([
                _buildSectionCard(
                  context,
                  icon: Icons.panorama,
                  title: 'Hero',
                  subtitle: 'Bandeau principal',
                  color: AppColors.primary,
                  onTap: () {
                    // TODO: Navigation vers la page Hero (à créer)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Section Hero - À venir'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildSectionCard(
                  context,
                  icon: Icons.view_carousel,
                  title: 'Bandeau',
                  subtitle: 'Bannières',
                  color: AppColors.accentGold,
                  onTap: () {
                    // TODO: Navigation vers la page Bandeau (à créer)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Section Bandeau - À venir'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildSectionCard(
                  context,
                  icon: Icons.celebration,
                  title: 'Popups',
                  subtitle: 'Animations & Gains',
                  color: AppColors.info,
                  onTap: () {
                    // Navigation vers l'écran Popups existant
                    context.push(AppRoutes.studioPopupsRoulette);
                  },
                ),
                _buildSectionCard(
                  context,
                  icon: Icons.text_fields,
                  title: 'Textes',
                  subtitle: 'Messages personnalisés',
                  color: AppColors.accentGreen,
                  onTap: () {
                    // Navigation vers l'écran Textes existant
                    context.push(AppRoutes.studioTexts);
                  },
                ),
                _buildSectionCard(
                  context,
                  icon: Icons.star,
                  title: 'Mise en avant',
                  subtitle: 'Tags produits',
                  color: AppColors.warning,
                  onTap: () {
                    // Navigation vers l'écran Mise en avant existant
                    context.push(AppRoutes.studioFeaturedProducts);
                  },
                ),
                _buildSectionCard(
                  context,
                  icon: Icons.article,
                  title: 'Contenu',
                  subtitle: 'CMS Headless',
                  color: AppColors.secondary,
                  onTap: () {
                    // Navigation vers l'écran Contenu existant
                    context.push(AppRoutes.studioContent);
                  },
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

  /// Construit une carte de section cliquable avec le style Material 3
  /// 
  /// Design:
  /// - Radius: 16px (Material 3 standard)
  /// - Background: surfaceContainerLow (#F5F5F5)
  /// - Spacing: 16px entre les cartes
  /// - Animation de hover/tap
  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.05),
      color: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card, // 16px
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône avec fond coloré
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              // Titre
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.xs),
              // Sous-titre
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
