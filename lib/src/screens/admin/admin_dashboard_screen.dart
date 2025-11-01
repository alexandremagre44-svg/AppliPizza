// lib/src/screens/admin/admin_dashboard_screen.dart
// Tableau de bord admin avec accès aux écrans CRUD

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(VisualConstants.paddingMedium),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: VisualConstants.gridSpacing,
          mainAxisSpacing: VisualConstants.gridSpacing,
          children: [
            _buildAdminCard(
              context,
              icon: Icons.local_pizza,
              title: 'Pizzas',
              subtitle: 'Gérer les pizzas',
              color: Colors.orange,
              onTap: () => context.push(AppRoutes.adminPizza),
            ),
            _buildAdminCard(
              context,
              icon: Icons.restaurant_menu,
              title: 'Menus',
              subtitle: 'Gérer les menus',
              color: Colors.blue,
              onTap: () => context.push(AppRoutes.adminMenu),
            ),
            _buildAdminCard(
              context,
              icon: Icons.access_time,
              title: 'Horaires',
              subtitle: 'À venir',
              color: Colors.green,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir')),
                );
              },
            ),
            _buildAdminCard(
              context,
              icon: Icons.settings,
              title: 'Paramètres',
              subtitle: 'À venir',
              color: Colors.grey,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VisualConstants.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(VisualConstants.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
