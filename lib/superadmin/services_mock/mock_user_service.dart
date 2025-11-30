/// lib/superadmin/services_mock/mock_user_service.dart
///
/// Service mock pour la gestion des utilisateurs dans le module Super-Admin.
/// Fournit des données fictives pour le développement et les tests.
library;

import '../models/user_admin_meta.dart';

/// Service mock pour les opérations sur les utilisateurs administrateurs.
class MockUserService {
  /// Liste mock d'utilisateurs administrateurs pour le développement.
  static final List<UserAdminMeta> _mockUsers = [
    const UserAdminMeta(
      id: 'user-001',
      email: 'superadmin@delizza.com',
      role: 'super-admin',
      attachedRestaurants: ['resto-001', 'resto-002', 'resto-003', 'resto-004', 'resto-005'],
    ),
    const UserAdminMeta(
      id: 'user-002',
      email: 'admin.paris@delizza.com',
      role: 'admin',
      attachedRestaurants: ['resto-001'],
    ),
    const UserAdminMeta(
      id: 'user-003',
      email: 'admin.lyon@delizza.com',
      role: 'admin',
      attachedRestaurants: ['resto-002'],
    ),
    const UserAdminMeta(
      id: 'user-004',
      email: 'manager.marseille@delizza.com',
      role: 'manager',
      attachedRestaurants: ['resto-003'],
    ),
    const UserAdminMeta(
      id: 'user-005',
      email: 'multi.admin@delizza.com',
      role: 'admin',
      attachedRestaurants: ['resto-001', 'resto-002', 'resto-005'],
    ),
  ];

  /// Retourne la liste de tous les utilisateurs mock.
  List<UserAdminMeta> getAllUsers() {
    return List.unmodifiable(_mockUsers);
  }

  /// Retourne un utilisateur par son identifiant, ou null si non trouvé.
  UserAdminMeta? getUserById(String id) {
    try {
      return _mockUsers.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Retourne les utilisateurs filtrés par rôle.
  List<UserAdminMeta> getUsersByRole(String role) {
    return _mockUsers.where((u) => u.role == role).toList();
  }

  /// Retourne les utilisateurs attachés à un restaurant donné.
  List<UserAdminMeta> getUsersByRestaurant(String restaurantId) {
    return _mockUsers
        .where((u) => u.attachedRestaurants.contains(restaurantId))
        .toList();
  }

  /// Retourne le nombre total d'utilisateurs.
  int get totalCount => _mockUsers.length;

  /// Retourne le nombre de super-admins.
  int get superAdminCount =>
      _mockUsers.where((u) => u.role == 'super-admin').length;

  /// Retourne le nombre d'admins.
  int get adminCount => _mockUsers.where((u) => u.role == 'admin').length;

  /// Retourne le nombre de managers.
  int get managerCount => _mockUsers.where((u) => u.role == 'manager').length;
}
