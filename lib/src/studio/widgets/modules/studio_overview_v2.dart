// lib/src/studio/widgets/modules/studio_overview_v2.dart
// Overview module - Dashboard showing Studio status

import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';
import '../../controllers/studio_state_controller.dart';

class StudioOverviewV2 extends StatelessWidget {
  final StudioDraftState draftState;

  const StudioOverviewV2({
    super.key,
    required this.draftState,
  });

  @override
  Widget build(BuildContext context) {
    final activeBanners = draftState.banners.where((b) => b.isEnabled).length;
    final activePopups = draftState.popupsV2.where((p) => p.isEnabled).length;
    final enabledTextBlocks = draftState.textBlocks.where((t) => t.isEnabled).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Vue d\'ensemble du Studio',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aperçu de votre configuration actuelle',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Status cards
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.toggle_on,
                  title: 'Studio',
                  value: draftState.layoutConfig?.studioEnabled ?? false
                      ? 'Activé'
                      : 'Désactivé',
                  color: draftState.layoutConfig?.studioEnabled ?? false
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.notifications_outlined,
                  title: 'Bandeaux actifs',
                  value: '$activeBanners',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.campaign_outlined,
                  title: 'Popups actifs',
                  value: '$activePopups',
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.text_fields_outlined,
                  title: 'Blocs de texte',
                  value: '$enabledTextBlocks',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Hero status
          _buildSectionPreview(
            title: 'Section Hero',
            isEnabled: draftState.homeConfig?.heroEnabled ?? false,
            children: [
              if (draftState.homeConfig?.heroEnabled ?? false) ...[
                Text(
                  'Titre: ${draftState.homeConfig?.heroTitle ?? "Non défini"}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sous-titre: ${draftState.homeConfig?.heroSubtitle ?? "Non défini"}',
                  style: const TextStyle(fontSize: 14),
                ),
              ] else
                const Text('Section désactivée', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),

          // Sections order
          _buildSectionPreview(
            title: 'Ordre des sections',
            isEnabled: true,
            children: [
              ...?draftState.layoutConfig?.sectionsOrder.map((section) {
                final isEnabled = draftState.layoutConfig?.enabledSections[section] ?? false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        isEnabled ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: isEnabled ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        section.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isEnabled ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionPreview({
    required String title,
    required bool isEnabled,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isEnabled ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isEnabled ? 'Activé' : 'Désactivé',
                  style: TextStyle(
                    fontSize: 12,
                    color: isEnabled ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
