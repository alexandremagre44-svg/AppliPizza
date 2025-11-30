/// lib/src/models/auth_roles.dart
///
/// Modèle pour la gestion des rôles et permissions utilisateur.
/// Encapsule les informations de rôle provenant des Custom Claims Firebase
/// et de Firestore pour les rôles restaurant-spécifiques.
///
/// Ce modèle est COMPLÉMENTAIRE au modèle User existant.
library;

import 'package:flutter/foundation.dart';

/// Représente les rôles et permissions d'un utilisateur.
///
/// Les rôles sont hiérarchisés :
/// - SUPER_ADMIN : Accès total à tous les restaurants (via Custom Claims Firebase)
/// - RESTAURANT_OWNER : Propriétaire d'un ou plusieurs restaurants (via Firestore)
/// - RESTAURANT_STAFF : Staff d'un ou plusieurs restaurants (via Firestore)
/// - CUSTOMER : Client standard (par défaut)
class AuthRoles {
  /// Valeur brute du rôle ("superadmin" | "admin" | "staff" | "customer")
  final String? rawRole;

  /// True si l'utilisateur est un Super-Admin (géré via Custom Claims Firebase)
  final bool isSuperAdmin;

  /// Liste des restaurantId où l'utilisateur est OWNER/ADMIN
  final List<String> adminOf;

  /// Liste des restaurantId où l'utilisateur est STAFF
  final List<String> staffOf;

  /// Constructeur principal
  const AuthRoles({
    this.rawRole,
    this.isSuperAdmin = false,
    this.adminOf = const [],
    this.staffOf = const [],
  });

  /// True si l'utilisateur est admin d'au moins un restaurant
  bool get isAdmin => adminOf.isNotEmpty;

  /// True si l'utilisateur est staff d'au moins un restaurant
  bool get isStaff => staffOf.isNotEmpty;

  /// True si l'utilisateur a un rôle privilégié (super-admin, admin, ou staff)
  bool get hasPrivilegedAccess => isSuperAdmin || isAdmin || isStaff;

  /// Vérifie si l'utilisateur est admin d'un restaurant spécifique
  bool isAdminOf(String restaurantId) => adminOf.contains(restaurantId);

  /// Vérifie si l'utilisateur est staff d'un restaurant spécifique
  bool isStaffOf(String restaurantId) => staffOf.contains(restaurantId);

  /// Vérifie si l'utilisateur a accès (admin ou staff) à un restaurant spécifique
  bool hasAccessTo(String restaurantId) =>
      isSuperAdmin || isAdminOf(restaurantId) || isStaffOf(restaurantId);

  /// Factory constructor pour créer AuthRoles à partir des Custom Claims Firebase.
  ///
  /// Structure attendue des claims :
  /// ```json
  /// {
  ///   "role": "superadmin" | "admin" | "staff" | "customer",
  ///   "isSuperAdmin": true,
  ///   "adminOf": ["resto-001", "resto-002"],
  ///   "staffOf": ["resto-003"]
  /// }
  /// ```
  ///
  /// Est robuste si les clés n'existent pas (retourne des valeurs par défaut).
  factory AuthRoles.fromClaims(Map<String, dynamic>? claims) {
    if (claims == null) {
      return const AuthRoles();
    }

    // Lecture du rôle brut
    final rawRole = claims['role'] as String?;

    // Lecture de isSuperAdmin (peut être dans 'isSuperAdmin' ou 'superadmin')
    final isSuperAdmin = claims['isSuperAdmin'] == true ||
        claims['superadmin'] == true ||
        rawRole == 'superadmin';

    // Lecture de adminOf (robuste si absent ou mauvais type)
    List<String> adminOf = [];
    if (claims['adminOf'] is List) {
      adminOf = (claims['adminOf'] as List)
          .whereType<String>()
          .toList();
    }

    // Lecture de staffOf (robuste si absent ou mauvais type)
    List<String> staffOf = [];
    if (claims['staffOf'] is List) {
      staffOf = (claims['staffOf'] as List)
          .whereType<String>()
          .toList();
    }

    return AuthRoles(
      rawRole: rawRole,
      isSuperAdmin: isSuperAdmin,
      adminOf: adminOf,
      staffOf: staffOf,
    );
  }

  /// Factory constructor pour un utilisateur sans rôles/claims.
  factory AuthRoles.empty() => const AuthRoles();

  /// Crée une copie avec des valeurs modifiées.
  AuthRoles copyWith({
    String? rawRole,
    bool? isSuperAdmin,
    List<String>? adminOf,
    List<String>? staffOf,
  }) {
    return AuthRoles(
      rawRole: rawRole ?? this.rawRole,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      adminOf: adminOf ?? this.adminOf,
      staffOf: staffOf ?? this.staffOf,
    );
  }

  @override
  String toString() {
    return 'AuthRoles(rawRole: $rawRole, isSuperAdmin: $isSuperAdmin, '
        'adminOf: $adminOf, staffOf: $staffOf)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AuthRoles) return false;
    if (other.rawRole != rawRole || other.isSuperAdmin != isSuperAdmin) {
      return false;
    }
    // Use listEquals for efficient list comparison
    return listEquals(other.adminOf, adminOf) && 
           listEquals(other.staffOf, staffOf);
  }

  @override
  int get hashCode => Object.hash(
        rawRole,
        isSuperAdmin,
        Object.hashAll(adminOf),
        Object.hashAll(staffOf),
      );
}
