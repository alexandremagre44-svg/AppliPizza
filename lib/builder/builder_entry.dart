// lib/builder/builder_entry.dart
// Entry point for Builder B3 Studio
// Clean architecture - NEW implementation (all old builder code removed)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/models.dart';
import 'page_list/page_list.dart';
import 'utils/utils.dart';

/// Builder Studio Screen - Main entry point for the B3 Builder interface
/// 
/// This is the root widget for the new Builder B3 system.
/// It provides a clean, modular architecture for multi-page, multi-resto builder.
/// 
/// Features:
/// - Multi-resto support with app switching (for super admin)
/// - Role-based access control (super_admin, admin_resto, studio)
/// - Page list with edit buttons
/// - Navigate to page editor for each page
/// 
/// Usage:
/// - Navigate to this screen from admin menu
/// - Super admin can switch between restaurants
/// - Admin resto is locked to their restaurant
class BuilderStudioScreen extends ConsumerStatefulWidget {
  const BuilderStudioScreen({super.key});

  @override
  ConsumerState<BuilderStudioScreen> createState() => _BuilderStudioScreenState();
}

class _BuilderStudioScreenState extends ConsumerState<BuilderStudioScreen> {
  @override
  Widget build(BuildContext context) {
    final appContext = ref.watch(appContextProvider);
    
    // Check if user has Builder access
    if (!appContext.hasBuilderAccess) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Builder B3 Studio'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Accès refusé',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vous n\'avez pas les permissions pour accéder au Builder B3',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Builder B3 Studio'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(appContextProvider.notifier).refresh();
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App selector (for super admin only)
          if (appContext.canSwitchApps) ...[
            _buildAppSelector(appContext),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
          ],
          
          // Current restaurant info
          _buildRestaurantInfo(appContext),
          const SizedBox(height: 24),
          
          // Pages list button - navigate to new page list screen
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.pages, color: Colors.blue),
              ),
              title: const Text(
                'Gérer les pages',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Voir, créer et éditer les pages'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BuilderPageListScreen(
                      appId: appContext.currentAppId,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // System info
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          _buildSystemInfo(appContext),
        ],
      ),
    );
  }

  Widget _buildAppSelector(AppContextState appContext) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Super Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Restaurant actif:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: appContext.currentAppId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: appContext.accessibleApps.map((app) {
                return DropdownMenuItem(
                  value: app.appId,
                  child: Text('${app.name} (${app.appId})'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(appContextProvider.notifier).switchApp(value);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${appContext.accessibleApps.length} restaurant(s) accessible(s)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo(AppContextState appContext) {
    final currentApp = appContext.accessibleApps.firstWhere(
      (app) => app.appId == appContext.currentAppId,
      orElse: () => AppInfo(
        appId: appContext.currentAppId,
        name: 'Restaurant',
        description: '',
      ),
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.restaurant, color: Colors.orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentApp.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${currentApp.appId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (currentApp.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      currentApp.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleColor(appContext.userRole),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getRoleLabel(appContext.userRole),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfo(AppContextState appContext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations système',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Rôle:', _getRoleLabel(appContext.userRole)),
        _buildInfoRow('Restaurant:', appContext.currentAppId),
        if (appContext.userId != null)
          _buildInfoRow('User ID:', appContext.userId!),
        const SizedBox(height: 16),
        const Text(
          'Architecture Builder B3',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text('✅ lib/builder/models/ - Data models'),
        const Text('✅ lib/builder/services/ - Firestore service'),
        const Text('✅ lib/builder/editor/ - Page editor'),
        const Text('✅ lib/builder/blocks/ - Block widgets'),
        const Text('✅ lib/builder/preview/ - Preview system'),
        const Text('✅ lib/builder/utils/ - Utilities + Multi-resto'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case BuilderRole.superAdmin:
        return Colors.purple;
      case BuilderRole.adminResto:
        return Colors.blue;
      case BuilderRole.studio:
        return Colors.green;
      case BuilderRole.admin:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case BuilderRole.superAdmin:
        return 'Super Admin';
      case BuilderRole.adminResto:
        return 'Admin Resto';
      case BuilderRole.studio:
        return 'Studio';
      case BuilderRole.admin:
        return 'Admin';
      default:
        return role;
    }
  }
}
