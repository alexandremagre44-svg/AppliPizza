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
    UserAdminMeta(
      id: 'user-001',
      email: 'superadmin@delizza.com',
      displayName: 'Super Admin',
      role: AdminRole.superAdmin,
      roleString: 'super-admin',
      status: UserStatus.active,
      attachedRestaurants: const ['resto-001', 'resto-002', 'resto-003', 'resto-004', 'resto-005'],
      createdAt: DateTime(2022, 1, 1),
      lastLoginAt: DateTime.now(),
    ),
    UserAdminMeta(
      id: 'user-002',
      email: 'admin.paris@delizza.com',
      displayName: 'Admin Paris',
      role: AdminRole.restaurantOwner,
      roleString: 'owner',
      status: UserStatus.active,
      attachedRestaurants: const ['resto-001'],
      createdAt: DateTime(2023, 1, 15),
    ),
    UserAdminMeta(
      id: 'user-003',
      email: 'admin.lyon@delizza.com',
      displayName: 'Admin Lyon',
      role: AdminRole.restaurantOwner,
      roleString: 'owner',
      status: UserStatus.active,
      attachedRestaurants: const ['resto-002'],
      createdAt: DateTime(2023, 3, 20),
    ),
    UserAdminMeta(
      id: 'user-004',
      email: 'manager.marseille@delizza.com',
      displayName: 'Manager Marseille',
      role: AdminRole.restaurantManager,
      roleString: 'manager',
      status: UserStatus.pending,
      attachedRestaurants: const ['resto-003'],
      createdAt: DateTime(2023, 6, 10),
    ),
    UserAdminMeta(
      id: 'user-005',
      email: 'multi.admin@delizza.com',
      displayName: 'Multi Admin',
      role: AdminRole.restaurantOwner,
      roleString: 'owner',
      status: UserStatus.active,
      attachedRestaurants: const ['resto-001', 'resto-002', 'resto-005'],
      createdAt: DateTime(2023, 2, 1),
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

  /// Retourne les utilisateurs filtrés par rôle (enum).
  List<UserAdminMeta> getUsersByRole(AdminRole role) {
    return _mockUsers.where((u) => u.role == role).toList();
  }

  /// Retourne les utilisateurs filtrés par rôle (string pour compatibilité).
  List<UserAdminMeta> getUsersByRoleString(String role) {
    return _mockUsers.where((u) => u.roleString == role).toList();
  }

  /// Retourne les utilisateurs filtrés par statut.
  List<UserAdminMeta> getUsersByStatus(UserStatus status) {
    return _mockUsers.where((u) => u.status == status).toList();
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
      _mockUsers.where((u) => u.role == AdminRole.superAdmin).length;

  /// Retourne le nombre de propriétaires.
  int get ownerCount =>
      _mockUsers.where((u) => u.role == AdminRole.restaurantOwner).length;

  /// Retourne le nombre de managers.
  int get managerCount =>
      _mockUsers.where((u) => u.role == AdminRole.restaurantManager).length;

  /// Retourne le nombre de staff.
  int get staffCount =>
      _mockUsers.where((u) => u.role == AdminRole.restaurantStaff).length;

  /// Retourne le nombre d'utilisateurs actifs.
  int get activeCount =>
      _mockUsers.where((u) => u.status == UserStatus.active).length;
}
