/// lib/superadmin/services/user_roles_service.dart
///
/// Service pour la gestion des rôles utilisateurs via Firestore.
/// Ce service gère les rôles RESTAURANT_OWNER et RESTAURANT_STAFF
/// qui sont stockés dans Firestore (contrairement au SUPER_ADMIN qui
/// utilise les Custom Claims Firebase).
///
/// PHASE 1: Structure de base, usage limité.
/// TODO: Implémenter les opérations CRUD complètes.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Structure d'un rôle utilisateur dans Firestore.
/// 
/// Collection: `user_roles/{userId}`
/// Document structure:
/// ```json
/// {
///   "userId": "abc123",
///   "email": "user@example.com",
///   "adminOf": ["resto-001", "resto-002"],
///   "staffOf": ["resto-003"],
///   "createdAt": Timestamp,
///   "updatedAt": Timestamp
/// }
/// ```
class UserRoleDocument {
  final String userId;
  final String? email;
  final List<String> adminOf;
  final List<String> staffOf;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserRoleDocument({
    required this.userId,
    this.email,
    this.adminOf = const [],
    this.staffOf = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Crée une instance depuis un document Firestore.
  factory UserRoleDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserRoleDocument(userId: doc.id);
    }

    return UserRoleDocument(
      userId: doc.id,
      email: data['email'] as String?,
      adminOf: (data['adminOf'] as List?)?.cast<String>() ?? [],
      staffOf: (data['staffOf'] as List?)?.cast<String>() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convertit l'instance en Map pour Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      if (email != null) 'email': email,
      'adminOf': adminOf,
      'staffOf': staffOf,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Crée une copie avec des valeurs modifiées.
  UserRoleDocument copyWith({
    String? userId,
    String? email,
    List<String>? adminOf,
    List<String>? staffOf,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserRoleDocument(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      adminOf: adminOf ?? this.adminOf,
      staffOf: staffOf ?? this.staffOf,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Service pour la gestion des rôles utilisateurs via Firestore.
/// 
/// TODO: Ce service est une base minimale. Les opérations complètes
/// seront implémentées dans une phase ultérieure.
class UserRolesService {
  final FirebaseFirestore _firestore;
  
  /// Nom de la collection Firestore
  static const String collectionName = 'user_roles';

  UserRolesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Référence à la collection user_roles
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionName);

  /// Récupère le document de rôles d'un utilisateur.
  /// Retourne null si l'utilisateur n'a pas de rôles définis.
  Future<UserRoleDocument?> getUserRoles(String userId) async {
    try {
      final doc = await _collection.doc(userId).get();
      if (!doc.exists) {
        return null;
      }
      return UserRoleDocument.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user roles for $userId: $e');
      }
      return null;
    }
  }

  /// Stream des rôles d'un utilisateur pour écouter les changements en temps réel.
  Stream<UserRoleDocument?> watchUserRoles(String userId) {
    return _collection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserRoleDocument.fromFirestore(doc);
    });
  }

  /// Vérifie si un utilisateur est admin d'un restaurant spécifique.
  Future<bool> isAdminOf(String userId, String restaurantId) async {
    final roles = await getUserRoles(userId);
    return roles?.adminOf.contains(restaurantId) ?? false;
  }

  /// Vérifie si un utilisateur est staff d'un restaurant spécifique.
  Future<bool> isStaffOf(String userId, String restaurantId) async {
    final roles = await getUserRoles(userId);
    return roles?.staffOf.contains(restaurantId) ?? false;
  }

  /// Vérifie si un utilisateur a accès à un restaurant (admin ou staff).
  Future<bool> hasAccessTo(String userId, String restaurantId) async {
    final roles = await getUserRoles(userId);
    if (roles == null) return false;
    return roles.adminOf.contains(restaurantId) ||
        roles.staffOf.contains(restaurantId);
  }

  // =========================================================================
  // TODO: Méthodes d'écriture à implémenter dans une phase ultérieure
  // =========================================================================

  /// TODO: Créer ou mettre à jour les rôles d'un utilisateur.
  Future<void> setUserRoles(UserRoleDocument roles) async {
    // TODO: Implémenter
    throw UnimplementedError('setUserRoles not yet implemented');
  }

  /// TODO: Ajouter un utilisateur comme admin d'un restaurant.
  Future<void> addAsAdmin(String userId, String restaurantId) async {
    // TODO: Implémenter
    throw UnimplementedError('addAsAdmin not yet implemented');
  }

  /// TODO: Ajouter un utilisateur comme staff d'un restaurant.
  Future<void> addAsStaff(String userId, String restaurantId) async {
    // TODO: Implémenter
    throw UnimplementedError('addAsStaff not yet implemented');
  }

  /// TODO: Retirer un utilisateur des admins d'un restaurant.
  Future<void> removeAsAdmin(String userId, String restaurantId) async {
    // TODO: Implémenter
    throw UnimplementedError('removeAsAdmin not yet implemented');
  }

  /// TODO: Retirer un utilisateur des staffs d'un restaurant.
  Future<void> removeAsStaff(String userId, String restaurantId) async {
    // TODO: Implémenter
    throw UnimplementedError('removeAsStaff not yet implemented');
  }

  /// TODO: Supprimer tous les rôles d'un utilisateur.
  Future<void> deleteUserRoles(String userId) async {
    // TODO: Implémenter
    throw UnimplementedError('deleteUserRoles not yet implemented');
  }
}
