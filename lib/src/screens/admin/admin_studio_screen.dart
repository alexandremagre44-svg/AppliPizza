// lib/src/screens/admin/admin_studio_screen.dart
// Studio Builder - Écran d'accueil avec choix entre ancien et nouveau studio

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../core/constants.dart';
import 'admin_studio_screen_refactored.dart';
import 'studio/roulette_segments_list_screen.dart';
import 'studio/roulette_admin_settings_screen.dart';
import '../../features/content/presentation/admin/content_studio_screen.dart';
import 'products_admin_screen.dart';
import 'ingredients_admin_screen.dart';
import 'mailing_admin_screen.dart';
import 'promotions_admin_screen.dart';

/// Studio Builder - Point d'entrée principal
/// PHASE 4 MIGRATION: Redirects to unified AdminStudioScreenRefactored
/// Old screens (Hero, Banner, Popups, Textes) moved to _deprecated/
class AdminStudioScreen extends StatelessWidget {
  const AdminStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Studio Admin'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          SizedBox(height: AppSpacing.md),
          
          // Studio unifié - PRINCIPAL
          _buildHighlightedBlock(
            context,
            iconData: Icons.auto_awesome,
            title: '🎨 Studio Unifié',
            subtitle: 'Gestion complète : Hero, Bandeau, Popups, Textes\nPrévisualisation live • Mode brouillon • Drag & drop',
            onTap: () {
              context.push(AppRoutes.adminStudioNew);
            },
            isNew: true,
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              'Modules de gestion',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          
          SizedBox(height: AppSpacing.md),
          
          _buildStudioBlock(
            context,
            iconData: Icons.inventory_2_rounded,
            title: 'Catalogue Produits',
            subtitle: 'Pizzas, menus, boissons, desserts',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductsAdminScreen()),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildStudioBlock(
            context,
            iconData: Icons.restaurant_rounded,
            title: 'Ingrédients Universels',
            subtitle: 'Gérer les ingrédients pour toutes les pizzas',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const IngredientsAdminScreen()),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildStudioBlock(
            context,
            iconData: Icons.local_offer_rounded,
            title: 'Promotions',
            subtitle: 'Gérer les promotions et réductions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PromotionsAdminScreen()),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildStudioBlock(
            context,
            iconData: Icons.email_rounded,
            title: 'Mailing',
            subtitle: 'Gérer les abonnés et campagnes email',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MailingAdminScreen()),
              );
            },
          ),
          SizedBox(height: AppSpacing.lg),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              'Autres modules',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          
          _buildStudioBlock(
            context,
            iconData: Icons.casino_rounded,
            title: 'Roue de la chance',
            subtitle: 'Gérer les segments de la roulette',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RouletteSegmentsListScreen()),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildStudioBlock(
            context,
            iconData: Icons.settings_outlined,
            title: 'Paramètres de la roulette',
            subtitle: 'Configuration, règles et limites d\'utilisation',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RouletteAdminSettingsScreen()),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildStudioBlock(
            context,
            iconData: Icons.widgets_rounded,
            title: 'Contenu',
            subtitle: 'Studio de contenu',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContentStudioScreen()),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  /// Highlighted block for the new unified studio
  Widget _buildHighlightedBlock(
    BuildContext context, {
    required IconData iconData,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isNew = false,
  }) {
    return Card(
      elevation: 4,
      color: AppColors.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: AppColors.primary, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Standard block for other sections
  Widget _buildStudioBlock(
    BuildContext context, {
    required IconData iconData,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: AppColors.primary,
                  size: 24,
                  weight: 300,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onSurfaceVariant,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
