/// lib/superadmin/models/restaurant_meta.dart
///
/// Modèle de métadonnées pour un restaurant dans le module Super-Admin.
/// Ce modèle est une version simplifiée du RestaurantBlueprint complet,
/// utilisé pour l'affichage dans le Super-Admin.
/// 
/// Ce modèle est isolé et indépendant du reste de l'application.
library;

import 'package:flutter/foundation.dart';

/// Statuts possibles pour un restaurant.
enum RestaurantStatus {
  /// Restaurant en cours de configuration.
  draft,
  /// Restaurant en attente de validation.
  pending,
  /// Restaurant actif et opérationnel.
  active,
  /// Restaurant temporairement suspendu.
  suspended,
  /// Restaurant archivé (non supprimé).
  archived,
}

/// Extension pour convertir RestaurantStatus en/depuis String.
extension RestaurantStatusExtension on RestaurantStatus {
  String get value {
    switch (this) {
      case RestaurantStatus.draft:
        return 'draft';
      case RestaurantStatus.pending:
        return 'pending';
      case RestaurantStatus.active:
        return 'active';
      case RestaurantStatus.suspended:
        return 'suspended';
      case RestaurantStatus.archived:
        return 'archived';
    }
  }

  static RestaurantStatus fromString(String? value) {
    switch (value) {
      case 'draft':
        return RestaurantStatus.draft;
      case 'pending':
        return RestaurantStatus.pending;
      case 'active':
        return RestaurantStatus.active;
      case 'suspended':
        return RestaurantStatus.suspended;
      case 'archived':
        return RestaurantStatus.archived;
      default:
        return RestaurantStatus.draft;
    }
  }
}

/// Représente les métadonnées d'un restaurant pour le Super-Admin.
/// 
/// Ce modèle est une version légère du RestaurantBlueprint, contenant
/// uniquement les informations essentielles pour l'affichage dans les listes
/// et les tableaux de bord du Super-Admin.
class RestaurantMeta {
  /// Identifiant unique du restaurant (ex: "delizza-paris").
  final String id;

  /// Nom d'affichage du restaurant.
  final String name;

  /// Slug URL-friendly (ex: "pizza-delizza-paris").
  final String slug;

  /// Nom de la marque/enseigne (ex: "Pizza Delizza").
  final String brandName;

  /// Type de restaurant (ex: pizzeria, fast-food, etc.).
  final String type;

  /// Identifiant du template utilisé pour ce restaurant.
  final String? templateId;

  /// Liste des modules activés pour ce restaurant.
  final List<String> modulesEnabled;

  /// Statut du restaurant.
  final RestaurantStatus status;

  /// Date de création du restaurant.
  final DateTime createdAt;

  /// Date de dernière mise à jour.
  final DateTime? updatedAt;

  /// Blueprint complet (optionnel, pour accès aux données détaillées).
  /// Peut contenir toute la configuration du restaurant.
  final Map<String, dynamic>? blueprint;

  /// Constructeur principal.
  const RestaurantMeta({
    required this.id,
    required this.name,
    this.slug = '',
    this.brandName = '',
    required this.type,
    this.templateId,
    this.modulesEnabled = const [],
    this.status = RestaurantStatus.draft,
    required this.createdAt,
    this.updatedAt,
    this.blueprint,
  });

  /// Crée une instance depuis un document Firestore ou Map.
  factory RestaurantMeta.fromMap(Map<String, dynamic> map) {
    return RestaurantMeta(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      slug: map['slug'] as String? ?? '',
      brandName: map['brandName'] as String? ?? map['name'] as String? ?? '',
      type: map['type'] as String? ?? 'restaurant',
      templateId: map['templateId'] as String?,
      modulesEnabled: (map['modulesEnabled'] as List?)?.cast<String>() ?? [],
      status: RestaurantStatusExtension.fromString(map['status'] as String?),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt'] as DateTime
              : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime
              ? map['updatedAt'] as DateTime
              : DateTime.tryParse(map['updatedAt'].toString()))
          : null,
      blueprint: map['blueprint'] as Map<String, dynamic>?,
    );
  }

  /// Convertit l'instance en Map pour Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'brandName': brandName,
      'type': type,
      if (templateId != null) 'templateId': templateId,
      'modulesEnabled': modulesEnabled,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (blueprint != null) 'blueprint': blueprint,
    };
  }

  /// Crée une copie de l'objet avec des valeurs modifiées.
  RestaurantMeta copyWith({
    String? id,
    String? name,
    String? slug,
    String? brandName,
    String? type,
    String? templateId,
    List<String>? modulesEnabled,
    RestaurantStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? blueprint,
  }) {
    return RestaurantMeta(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      brandName: brandName ?? this.brandName,
      type: type ?? this.type,
      templateId: templateId ?? this.templateId,
      modulesEnabled: modulesEnabled ?? this.modulesEnabled,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      blueprint: blueprint ?? this.blueprint,
    );
  }

  /// Vérifie si un module spécifique est activé.
  bool hasModule(String moduleName) => modulesEnabled.contains(moduleName);

  /// Retourne le statut sous forme de String (pour compatibilité).
  String get statusString => status.value;

  @override
  String toString() {
    return 'RestaurantMeta(id: $id, name: $name, slug: $slug, brandName: $brandName, '
        'type: $type, templateId: $templateId, modulesEnabled: $modulesEnabled, '
        'status: ${status.value}, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RestaurantMeta) return false;
    return other.id == id &&
        other.name == name &&
        other.slug == slug &&
        other.brandName == brandName &&
        other.type == type &&
        other.templateId == templateId &&
        listEquals(other.modulesEnabled, modulesEnabled) &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      slug,
      brandName,
      type,
      templateId,
      Object.hashAll(modulesEnabled),
      status,
      createdAt,
    );
  }
}
