/// lib/superadmin/models/restaurant_meta.dart
///
/// Modèle de métadonnées pour un restaurant dans le module Super-Admin.
/// Ce modèle est isolé et indépendant du reste de l'application.
library;

/// Représente les métadonnées d'un restaurant pour le Super-Admin.
class RestaurantMeta {
  /// Identifiant unique du restaurant.
  final String id;

  /// Nom du restaurant.
  final String name;

  /// Type de restaurant (ex: pizzeria, fast-food, etc.).
  final String type;

  /// Statut du restaurant (ex: active, inactive, pending).
  final String status;

  /// Date de création du restaurant.
  final DateTime createdAt;

  /// Constructeur principal.
  const RestaurantMeta({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  /// Crée une copie de l'objet avec des valeurs modifiées.
  RestaurantMeta copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
    DateTime? createdAt,
  }) {
    return RestaurantMeta(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'RestaurantMeta(id: $id, name: $name, type: $type, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantMeta &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, type, status, createdAt);
  }
}
