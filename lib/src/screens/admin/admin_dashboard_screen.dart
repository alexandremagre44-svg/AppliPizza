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
      body: CustomScrollView(
        slivers: [
          // Enhanced Admin AppBar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Administration',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryRed,
                      AppTheme.secondaryAmber,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: 20,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          Icons.admin_panel_settings,
                          size: 150,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Grid of Admin Cards
          SliverPadding(
            padding: const EdgeInsets.all(VisualConstants.paddingMedium),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: VisualConstants.gridSpacing,
                mainAxisSpacing: VisualConstants.gridSpacing,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildListDelegate([
                _buildAdminCard(
                  context,
                  icon: Icons.local_pizza,
                  title: 'Pizzas',
                  subtitle: 'Gérer les pizzas',
                  colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                  onTap: () => context.push(AppRoutes.adminPizza),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.restaurant_menu,
                  title: 'Menus',
                  subtitle: 'Gérer les menus',
                  colors: [Colors.blue.shade400, Colors.indigo.shade600],
                  onTap: () => context.push(AppRoutes.adminMenu),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.local_drink,
                  title: 'Boissons',
                  subtitle: 'Gérer les boissons',
                  colors: [Colors.cyan.shade400, Colors.blue.shade600],
                  onTap: () => context.push(AppRoutes.adminDrinks),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.cake,
                  title: 'Desserts',
                  subtitle: 'Gérer les desserts',
                  colors: [Colors.pink.shade400, Colors.purple.shade600],
                  onTap: () => context.push(AppRoutes.adminDesserts),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.dashboard_customize,
                  title: 'Page Builder',
                  subtitle: 'Organiser l\'affichage',
                  colors: [Colors.green.shade400, Colors.teal.shade600],
                  onTap: () => context.push(AppRoutes.adminPageBuilder),
                ),
                _buildAdminCard(
                  context,
                  icon: Icons.settings,
                  title: 'Paramètres',
                  subtitle: 'À venir',
                  colors: [Colors.grey.shade400, Colors.blueGrey.shade600],
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité à venir')),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shadowColor: colors[0].withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors[0].withOpacity(0.1),
              colors[1].withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
