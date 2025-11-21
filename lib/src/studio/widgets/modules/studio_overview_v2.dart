// lib/src/studio/widgets/modules/studio_overview_v2.dart
// Overview module - Professional dashboard showing Studio status (Shopify-level)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/home_layout_config.dart';
import '../../controllers/studio_state_controller.dart';

class StudioOverviewV2 extends ConsumerWidget {
  final StudioDraftState draftState;

  const StudioOverviewV2({
    super.key,
    required this.draftState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBanners = draftState.banners.where((b) => b.isEnabled).length;
    final totalBanners = draftState.banners.length;
    final activePopups = draftState.popupsV2.where((p) => p.isEnabled).length;
    final totalPopups = draftState.popupsV2.length;
    final enabledTextBlocks = draftState.textBlocks.where((t) => t.isEnabled).length;
    final studioEnabled = draftState.layoutConfig?.studioEnabled ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vue d\'ensemble',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aperçu et gestion de votre configuration Studio',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Quick action: Reload from database
              OutlinedButton.icon(
                onPressed: () => _reloadFromDatabase(context, ref),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Recharger'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // KPI Cards (Shopify-style)
          _buildKPIGrid(
            studioEnabled: studioEnabled,
            activeBanners: activeBanners,
            totalBanners: totalBanners,
            activePopups: activePopups,
            totalPopups: totalPopups,
            enabledTextBlocks: enabledTextBlocks,
          ),
          const SizedBox(height: 32),

          // Studio state section
          _buildStudioStateSection(context, ref),
          const SizedBox(height: 24),

          // Module status cards
          _buildModuleStatusGrid(context, ref),
          const SizedBox(height: 32),

          // Quick actions section
          _buildQuickActionsSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildKPIGrid({
    required bool studioEnabled,
    required int activeBanners,
    required int totalBanners,
    required int activePopups,
    required int totalPopups,
    required int enabledTextBlocks,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildKPICard(
              context: context,
              icon: Icons.power_settings_new,
              title: 'État du studio',
              value: studioEnabled ? 'Activé' : 'Désactivé',
              subtitle: studioEnabled ? 'Studio opérationnel' : 'Studio en pause',
              color: studioEnabled ? Colors.green : Colors.orange,
              trend: null,
              width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
            ),
            _buildKPICard(
              context: context,
              icon: Icons.notifications_active_outlined,
              title: 'Bandeaux',
              value: '$activeBanners / $totalBanners',
              subtitle: '$activeBanners actif${activeBanners > 1 ? 's' : ''}',
              color: AppColors.primary,
              trend: activeBanners > 0 ? 'Actifs' : null,
              width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
            ),
            _buildKPICard(
              context: context,
              icon: Icons.campaign_outlined,
              title: 'Popups',
              value: '$activePopups / $totalPopups',
              subtitle: '$activePopups actif${activePopups > 1 ? 's' : ''}',
              color: Colors.purple,
              trend: activePopups > 0 ? 'Actifs' : null,
              width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
            ),
            _buildKPICard(
              context: context,
              icon: Icons.text_fields_outlined,
              title: 'Blocs de texte',
              value: '$enabledTextBlocks',
              subtitle: 'Bloc${enabledTextBlocks > 1 ? 's' : ''} activé${enabledTextBlocks > 1 ? 's' : ''}',
              color: Colors.blue,
              trend: null,
              width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required String? trend,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioStateSection(BuildContext context, WidgetRef ref) {
    final studioEnabled = draftState.layoutConfig?.studioEnabled ?? false;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'État du studio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: studioEnabled 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      studioEnabled ? Icons.check_circle : Icons.warning_amber,
                      size: 16,
                      color: studioEnabled ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      studioEnabled ? 'Actif' : 'Désactivé',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: studioEnabled ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Modules de configuration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          _buildModuleStatusRow(
            icon: Icons.image_outlined,
            name: 'Section Hero',
            status: draftState.homeConfig?.heroEnabled ?? false,
          ),
          _buildModuleStatusRow(
            icon: Icons.notifications_outlined,
            name: 'Bandeaux',
            status: draftState.banners.any((b) => b.isEnabled),
          ),
          _buildModuleStatusRow(
            icon: Icons.campaign_outlined,
            name: 'Popups',
            status: draftState.popupsV2.any((p) => p.isEnabled),
          ),
          _buildModuleStatusRow(
            icon: Icons.text_fields_outlined,
            name: 'Textes dynamiques',
            status: draftState.textBlocks.any((t) => t.isEnabled),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleStatusRow({
    required IconData icon,
    required String name,
    required bool status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: status 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status ? 'Actif' : 'Inactif',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: status ? Colors.green : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleStatusGrid(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accès rapide aux modules',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildModuleCard(
                  context: context,
                  ref: ref,
                  icon: Icons.image_outlined,
                  title: 'Hero',
                  description: 'Bannière principale',
                  section: 'hero',
                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                ),
                _buildModuleCard(
                  context: context,
                  ref: ref,
                  icon: Icons.notifications_outlined,
                  title: 'Bandeaux',
                  description: 'Gestion des bandeaux',
                  section: 'banners',
                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                ),
                _buildModuleCard(
                  context: context,
                  ref: ref,
                  icon: Icons.campaign_outlined,
                  title: 'Popups',
                  description: 'Popups avancés',
                  section: 'popups',
                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                ),
                _buildModuleCard(
                  context: context,
                  ref: ref,
                  icon: Icons.text_fields_outlined,
                  title: 'Textes',
                  description: 'Blocs de texte',
                  section: 'texts',
                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String description,
    required String section,
    required double width,
  }) {
    return InkWell(
      onTap: () => _navigateToModule(ref, section),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    final studioEnabled = draftState.layoutConfig?.studioEnabled ?? false;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions rapides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => _reloadFromDatabase(context, ref),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Recharger depuis la base'),
              ),
              studioEnabled
                  ? OutlinedButton.icon(
                      onPressed: () => _toggleStudio(ref, false),
                      icon: const Icon(Icons.power_settings_new, size: 18),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                      label: const Text('Désactiver le studio'),
                    )
                  : FilledButton.icon(
                      onPressed: () => _toggleStudio(ref, true),
                      icon: const Icon(Icons.power_settings_new, size: 18),
                      label: const Text('Activer le studio'),
                    ),
              OutlinedButton.icon(
                onPressed: () => _navigateToModule(ref, 'settings'),
                icon: const Icon(Icons.settings, size: 18),
                label: const Text('Paramètres'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToModule(WidgetRef ref, String section) {
    ref.read(studioSelectedSectionProvider.notifier).state = section;
  }

  void _toggleStudio(WidgetRef ref, bool enabled) {
    final currentConfig = draftState.layoutConfig ?? HomeLayoutConfig.defaultConfig();
    ref.read(studioDraftStateProvider.notifier).setLayoutConfig(
      currentConfig.copyWith(studioEnabled: enabled),
    );
  }

  void _reloadFromDatabase(BuildContext context, WidgetRef ref) {
    // Trigger reload by invalidating providers
    // This will be handled by the parent screen's refresh logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pour recharger, utilisez le bouton "Annuler" en haut'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
