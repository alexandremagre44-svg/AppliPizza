/// lib/superadmin/layout/superadmin_header.dart
///
/// Header du module Super-Admin.
/// Affiche le titre de la page courante et un placeholder pour les métriques.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/superadmin_mock_providers.dart';

/// Widget Header pour le layout Super-Admin.
/// Affiche une barre horizontale avec le titre dynamique de la page.
class SuperAdminHeader extends ConsumerWidget {
  const SuperAdminHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageTitle = ref.watch(currentPageTitleProvider);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Titre de la page courante
          Text(
            pageTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const Spacer(),
          // Placeholder pour futur tableau de bord metrics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.analytics_outlined, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'TODO: Metrics Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Avatar placeholder
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
