// MIGRATED to WL V2 Theme - Uses theme colors
/// lib/superadmin/pages/dashboard_page.dart
///
/// Page Dashboard du module Super-Admin.
/// Affiche un aperçu global avec les statistiques principales.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';
import '../providers/superadmin_mock_providers.dart';

/// Page Dashboard du Super-Admin.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(mockStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques principales
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                title: 'Total Restaurants',
                value: stats.totalRestaurants.toString(),
                icon: Icons.restaurant,
                color: context.primaryColor,
              ),
              _StatCard(
                title: 'Active Restaurants',
                value: stats.activeRestaurants.toString(),
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
              _StatCard(
                title: 'Total Users',
                value: stats.totalUsers.toString(),
                icon: Icons.people,
                color: AppColors.warning,
              ),
              _StatCard(
                title: 'Today Orders',
                value: stats.todayOrders.toString(),
                icon: Icons.shopping_cart,
                color: Colors.purple,
              ),
              _StatCard(
                title: 'Today Revenue',
                value: '€${stats.todayRevenue.toStringAsFixed(2)}',
                icon: Icons.euro,
                color: Colors.teal,
              ),
              _StatCard(
                title: 'Active Modules',
                value: stats.activeModules.toString(),
                icon: Icons.extension,
                color: Colors.indigo,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Placeholder pour contenu futur
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.onPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.outlineVariant),
            ),
            child: const Column(
              children: [
                Icon(Icons.dashboard, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'TODO: Implement Dashboard Charts & Activity Feed',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget carte de statistique.
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.onPrimary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
