/// lib/superadmin/models/user_admin_meta.dart
///
/// Modèle de métadonnées pour un utilisateur administrateur dans le module Super-Admin.
/// Ce modèle est isolé et indépendant du reste de l'application.
library;

import 'package:flutter/foundation.dart';

/// Rôles possibles pour un utilisateur administrateur.
enum AdminRole {
  /// Super-administrateur avec accès total.
  superAdmin,
  /// Propriétaire d'un ou plusieurs restaurants.
  restaurantOwner,
  /// Gérant/Manager d'un restaurant.
  restaurantManager,
  /// Staff d'un restaurant.
  restaurantStaff,
}

/// Extension pour convertir AdminRole en/depuis String.
extension AdminRoleExtension on AdminRole {
  String get value {
    switch (this) {
      case AdminRole.superAdmin:
        return 'super-admin';
      case AdminRole.restaurantOwner:
        return 'owner';
      case AdminRole.restaurantManager:
        return 'manager';
      case AdminRole.restaurantStaff:
        return 'staff';
    }
  }

  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.restaurantOwner:
        return 'Owner';
      case AdminRole.restaurantManager:
        return 'Manager';
      case AdminRole.restaurantStaff:
        return 'Staff';
    }
  }

  static AdminRole fromString(String? value) {
    switch (value) {
      case 'super-admin':
      case 'superadmin':
        return AdminRole.superAdmin;
      case 'owner':
      case 'admin':
        return AdminRole.restaurantOwner;
      case 'manager':
        return AdminRole.restaurantManager;
      case 'staff':
        return AdminRole.restaurantStaff;
      default:
        return AdminRole.restaurantStaff;
    }
  }
}

/// Statut d'un compte utilisateur.
enum UserStatus {
  /// Compte actif.
  active,
  /// Compte en attente de validation.
  pending,
  /// Compte suspendu.
  suspended,
  /// Compte désactivé.
  disabled,
}

/// Extension pour convertir UserStatus en/depuis String.
extension UserStatusExtension on UserStatus {
  String get value {
    switch (this) {
      case UserStatus.active:
        return 'active';
      case UserStatus.pending:
        return 'pending';
      case UserStatus.suspended:
        return 'suspended';
      case UserStatus.disabled:
        return 'disabled';
    }
  }

  static UserStatus fromString(String? value) {
    switch (value) {
      case 'active':
        return UserStatus.active;
      case 'pending':
        return UserStatus.pending;
      case 'suspended':
        return UserStatus.suspended;
      case 'disabled':
        return UserStatus.disabled;
      default:
        return UserStatus.pending;
    }
  }
}

/// Représente les métadonnées d'un utilisateur administrateur pour le Super-Admin.
class UserAdminMeta {
  /// Identifiant unique de l'utilisateur (Firebase UID).
  final String id;

  /// Adresse email de l'utilisateur.
  final String email;

  /// Nom d'affichage de l'utilisateur.
  final String? displayName;

  /// URL de la photo de profil.
  final String? photoUrl;

  /// Rôle de l'utilisateur.
  final AdminRole role;

  /// Rôle sous forme de string (pour compatibilité).
  final String roleString;

  /// Statut du compte.
  final UserStatus status;

  /// Liste des identifiants de restaurants attachés à cet utilisateur.
  final List<String> attachedRestaurants;

  /// Date de création du compte.
  final DateTime? createdAt;

  /// Date de dernière connexion.
  final DateTime? lastLoginAt;

  /// Permissions personnalisées (optionnel).
  final Map<String, bool>? permissions;

  /// Constructeur principal.
  const UserAdminMeta({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = AdminRole.restaurantStaff,
    this.roleString = 'staff',
    this.status = UserStatus.pending,
    this.attachedRestaurants = const [],
    this.createdAt,
    this.lastLoginAt,
    this.permissions,
  });

  /// Crée une instance depuis un Map.
  factory UserAdminMeta.fromMap(Map<String, dynamic> map) {
    final roleStr = map['role'] as String? ?? 'staff';
    return UserAdminMeta(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: AdminRoleExtension.fromString(roleStr),
      roleString: roleStr,
      status: UserStatusExtension.fromString(map['status'] as String?),
      attachedRestaurants:
          (map['attachedRestaurants'] as List?)?.cast<String>() ?? [],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt'] as DateTime
              : DateTime.tryParse(map['createdAt'].toString()))
          : null,
      lastLoginAt: map['lastLoginAt'] != null
          ? (map['lastLoginAt'] is DateTime
              ? map['lastLoginAt'] as DateTime
              : DateTime.tryParse(map['lastLoginAt'].toString()))
          : null,
      permissions: map['permissions'] != null
          ? Map<String, bool>.from(map['permissions'] as Map)
          : null,
    );
  }

  /// Convertit l'instance en Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'role': role.value,
      'status': status.value,
      'attachedRestaurants': attachedRestaurants,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
      if (permissions != null) 'permissions': permissions,
    };
  }

  /// Crée une copie de l'objet avec des valeurs modifiées.
  UserAdminMeta copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    AdminRole? role,
    String? roleString,
    UserStatus? status,
    List<String>? attachedRestaurants,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, bool>? permissions,
  }) {
    return UserAdminMeta(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      roleString: roleString ?? this.roleString,
      status: status ?? this.status,
      attachedRestaurants: attachedRestaurants ?? this.attachedRestaurants,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      permissions: permissions ?? this.permissions,
    );
  }

  /// Vérifie si l'utilisateur est super-admin.
  bool get isSuperAdmin => role == AdminRole.superAdmin;

  /// Vérifie si l'utilisateur est propriétaire.
  bool get isOwner => role == AdminRole.restaurantOwner;

  /// Vérifie si l'utilisateur est manager.
  bool get isManager => role == AdminRole.restaurantManager;

  /// Vérifie si l'utilisateur est staff.
  bool get isStaff => role == AdminRole.restaurantStaff;

  /// Vérifie si l'utilisateur a accès à un restaurant spécifique.
  bool hasAccessTo(String restaurantId) =>
      isSuperAdmin || attachedRestaurants.contains(restaurantId);

  /// Vérifie si l'utilisateur a une permission spécifique.
  bool hasPermission(String permissionKey) =>
      permissions?[permissionKey] ?? false;

  @override
  String toString() {
    return 'UserAdminMeta(id: $id, email: $email, role: ${role.value}, '
        'status: ${status.value}, attachedRestaurants: $attachedRestaurants)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserAdminMeta) return false;
    return other.id == id &&
        other.email == email &&
        other.role == role &&
        other.status == status &&
        listEquals(other.attachedRestaurants, attachedRestaurants);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      role,
      status,
      Object.hashAll(attachedRestaurants),
    );
  }
}
