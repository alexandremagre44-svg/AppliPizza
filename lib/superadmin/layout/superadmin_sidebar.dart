/// lib/superadmin/layout/superadmin_sidebar.dart
///
/// Sidebar de navigation du module Super-Admin.
/// Contient les liens vers toutes les sections du module.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/superadmin_mock_providers.dart';

/// Item de navigation dans la sidebar.
class _SidebarItem {
  final String label;
  final IconData icon;
  final String route;
  final String pageTitle;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.pageTitle,
  });
}

/// Liste des items de navigation du Super-Admin.
const List<_SidebarItem> _sidebarItems = [
  _SidebarItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    route: '/superadmin/dashboard',
    pageTitle: 'Dashboard',
  ),
  _SidebarItem(
    label: 'Restaurants',
    icon: Icons.restaurant_outlined,
    route: '/superadmin/restaurants',
    pageTitle: 'Restaurants',
  ),
  _SidebarItem(
    label: 'Users',
    icon: Icons.people_outlined,
    route: '/superadmin/users',
    pageTitle: 'Users',
  ),
  _SidebarItem(
    label: 'Modules',
    icon: Icons.extension_outlined,
    route: '/superadmin/modules',
    pageTitle: 'Modules',
  ),
  _SidebarItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    route: '/superadmin/settings',
    pageTitle: 'Settings',
  ),
  _SidebarItem(
    label: 'Logs',
    icon: Icons.receipt_long_outlined,
    route: '/superadmin/logs',
    pageTitle: 'Activity Logs',
  ),
];

/// Widget Sidebar pour le layout Super-Admin.
class SuperAdminSidebar extends ConsumerWidget {
  const SuperAdminSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(2, 0),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo / Titre du module
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings, size: 32, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Super Admin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Control Panel',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          // Items de navigation
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _sidebarItems.length,
              itemBuilder: (context, index) {
                final item = _sidebarItems[index];
                final isSelected = currentRoute.startsWith(item.route);

                return _SidebarItemWidget(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    // Met à jour le titre de la page
                    ref.read(currentPageTitleProvider.notifier).state =
                        item.pageTitle;
                    // Navigation
                    context.go(item.route);
                  },
                );
              },
            ),
          ),
          // Footer
          const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.logout, size: 18, color: Colors.white54),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: Implement logout logic
                    debugPrint('TODO: Implement Super-Admin logout');
                  },
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
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

/// Widget pour un item individuel de la sidebar.
class _SidebarItemWidget extends StatelessWidget {
  final _SidebarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
