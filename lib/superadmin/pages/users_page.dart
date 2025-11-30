/// lib/superadmin/pages/users_page.dart
///
/// Page gestion des utilisateurs du module Super-Admin.
/// Affiche tous les utilisateurs administrateurs du système.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/superadmin_mock_providers.dart';
import '../models/user_admin_meta.dart';

/// Page gestion des utilisateurs du Super-Admin.
class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(mockUsersProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Actions header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${users.length} users',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement user creation
                  debugPrint('TODO: Open user creation dialog');
                },
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Liste des utilisateurs
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: users.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _UserListItem(user: user);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget item de la liste des utilisateurs.
class _UserListItem extends StatelessWidget {
  final UserAdminMeta user;

  const _UserListItem({required this.user});

  Color _getRoleColor(String role) {
    switch (role) {
      case 'super-admin':
        return Colors.purple;
      case 'admin':
        return Colors.blue;
      case 'manager':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: _getRoleColor(user.role).withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              size: 24,
              color: _getRoleColor(user.role),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.attachedRestaurants.length} restaurant(s) attached',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getRoleColor(user.role),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Actions
          IconButton(
            onPressed: () {
              // TODO: Implement user edit
              debugPrint('TODO: Edit user ${user.id}');
            },
            icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600),
            tooltip: 'Edit user',
          ),
        ],
      ),
    );
  }
}
