// lib/src/screens/admin/admin_studio_screen.dart
// Studio Builder - Écran principal unifié pour la gestion de l'apparence

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../core/constants.dart';
import 'studio/hero_block_editor.dart';
import 'studio/banner_block_editor.dart';
import 'studio/popup_block_list.dart';
import 'studio/studio_texts_screen.dart';
import 'studio/roulette_segments_list_screen.dart';
import 'studio/roulette_settings_screen.dart';
import '../../features/content/presentation/admin/content_studio_screen.dart';

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
/// - Contenu: CMS Headless pour le contenu
/// - Paramètres: Configuration de l'application
class AdminStudioScreen extends StatelessWidget {
  const AdminStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Studio'),
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
          _buildStudioBlock(
            context,
            iconData: Icons.image_rounded,
            title: 'Hero',
            subtitle: 'Modifier la bannière principale',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HeroBlockEditor()),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildStudioBlock(
            context,
            iconData: Icons.flag_rounded,
            title: 'Bandeau',
            subtitle: 'Gérer le bandeau promotionnel',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BannerBlockEditor()),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildStudioBlock(
            context,
            iconData: Icons.campaign_rounded,
            title: 'Popups',
            subtitle: 'Popups, messages, roulette',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PopupBlockList()),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildStudioBlock(
            context,
            iconData: Icons.casino_rounded,
            title: 'Roue de la chance',
            subtitle: 'Segments et configuration',
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
            subtitle: 'Règles, limites et conditions d\'utilisation',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RouletteSettingsScreen()),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
          _buildStudioBlock(
            context,
            iconData: Icons.notes_rounded,
            title: 'Textes',
            subtitle: 'Textes et messages de l\'application',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudioTextsScreen()),
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
          _buildStudioBlock(
            context,
            iconData: Icons.settings_rounded,
            title: 'Paramètres',
            subtitle: 'Paramètres de l\'application',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Section Paramètres - À venir'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  /// Construit un bloc de section cliquable avec le style Material 3
  /// 
  /// Design:
  /// - Card Material 3 avec background surface (#FFFFFF)
  /// - Padding: 16px
  /// - Radius: 16px
  /// - Avatar circulaire tonal avec icône
  /// - Titre + sous-titre + chevron
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
              // Avatar circulaire tonal
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
              // Titre et sous-titre
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
              // Chevron
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
