/// lib/superadmin/models/user_admin_meta.dart
///
/// Modèle de métadonnées pour un utilisateur administrateur dans le module Super-Admin.
/// Ce modèle est isolé et indépendant du reste de l'application.
library;

/// Représente les métadonnées d'un utilisateur administrateur pour le Super-Admin.
class UserAdminMeta {
  /// Identifiant unique de l'utilisateur.
  final String id;

  /// Adresse email de l'utilisateur.
  final String email;

  /// Rôle de l'utilisateur (ex: super-admin, admin, manager).
  final String role;

  /// Liste des identifiants de restaurants attachés à cet utilisateur.
  final List<String> attachedRestaurants;

  /// Constructeur principal.
  const UserAdminMeta({
    required this.id,
    required this.email,
    required this.role,
    required this.attachedRestaurants,
  });

  /// Crée une copie de l'objet avec des valeurs modifiées.
  UserAdminMeta copyWith({
    String? id,
    String? email,
    String? role,
    List<String>? attachedRestaurants,
  }) {
    return UserAdminMeta(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      attachedRestaurants: attachedRestaurants ?? this.attachedRestaurants,
    );
  }

  @override
  String toString() {
    return 'UserAdminMeta(id: $id, email: $email, role: $role, attachedRestaurants: $attachedRestaurants)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserAdminMeta) return false;
    if (other.id != id ||
        other.email != email ||
        other.role != role ||
        other.attachedRestaurants.length != attachedRestaurants.length) {
      return false;
    }
    for (int i = 0; i < attachedRestaurants.length; i++) {
      if (other.attachedRestaurants[i] != attachedRestaurants[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(id, email, role, Object.hashAll(attachedRestaurants));
  }
}
