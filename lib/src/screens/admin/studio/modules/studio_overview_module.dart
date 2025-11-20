// lib/src/screens/admin/studio/modules/studio_overview_module.dart
// Overview module - Dashboard with quick stats and actions

import 'package:flutter/material.dart';
import '../../../../design_system/app_theme.dart';
import '../../../../models/home_config.dart';
import '../../../../models/home_layout_config.dart';
import '../../../../models/popup_config.dart';
import '../../../../models/banner_config.dart';

class StudioOverviewModule extends StatelessWidget {
  final HomeConfig? draftHomeConfig;
  final HomeLayoutConfig? draftLayoutConfig;
  final List<PopupConfig> draftPopups;
  final List<BannerConfig> draftBanners;
  final VoidCallback onReload;
  final Function(bool) onToggleStudio;

  const StudioOverviewModule({
    super.key,
    required this.draftHomeConfig,
    required this.draftLayoutConfig,
    required this.draftPopups,
    required this.draftBanners,
    required this.onReload,
    required this.onToggleStudio,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vue d\'ensemble', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Récapitulatif des modules du Studio Admin',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final activePopups = draftPopups.where((p) => p.isCurrentlyActive).length;
    final activeBanners = draftBanners.where((b) => b.isCurrentlyActive).length;
    final heroActive = draftHomeConfig?.hero?.isActive == true;
    final studioEnabled = draftLayoutConfig?.studioEnabled == true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('État des modules', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard(
                  'Studio',
                  studioEnabled ? 'Activé' : 'Désactivé',
                  studioEnabled ? Icons.visibility : Icons.visibility_off,
                  studioEnabled,
                ),
                _buildStatCard(
                  'Hero',
                  heroActive ? 'Actif' : 'Inactif',
                  Icons.image,
                  heroActive,
                ),
                _buildStatCard(
                  'Bandeaux',
                  '$activeBanners actif(s)',
                  Icons.flag,
                  activeBanners > 0,
                ),
                _buildStatCard(
                  'Popups',
                  '$activePopups active(s)',
                  Icons.campaign,
                  activePopups > 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, bool isActive) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(
                  color: isActive ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final studioEnabled = draftLayoutConfig?.studioEnabled == true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actions rapides', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.refresh, color: AppColors.primary),
              ),
              title: const Text('Recharger depuis Firestore'),
              subtitle: const Text('Actualiser toutes les configurations'),
              onTap: onReload,
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: studioEnabled ? AppColors.errorContainer : AppColors.successContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  studioEnabled ? Icons.visibility_off : Icons.visibility,
                  color: studioEnabled ? AppColors.error : AppColors.success,
                ),
              ),
              title: Text(studioEnabled ? 'Désactiver tout le studio' : 'Activer le studio'),
              subtitle: Text(
                studioEnabled
                    ? 'Masquer Hero, Bandeaux et Popups côté client'
                    : 'Afficher tous les éléments configurés',
              ),
              onTap: () => onToggleStudio(!studioEnabled),
            ),
          ],
        ),
      ),
    );
  }
}
