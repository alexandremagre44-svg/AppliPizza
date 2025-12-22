/// lib/domain/module_exposure.dart
///
/// Modèle minimal pour l'exposition des modules sur différentes surfaces.
/// Ce fichier est un stub temporaire pour satisfaire la compilation.
library;

import 'package:flutter/foundation.dart';

/// Surfaces d'exposition disponibles pour un module.
enum ModuleSurface {
  /// Interface client (application mobile/web pour les clients).
  client,
  
  /// Point de vente (caisse).
  pos,
  
  /// Interface cuisine (écran de préparation).
  kitchen,
  
  /// Interface administrateur.
  admin,
}

/// Extension pour convertir ModuleSurface en/depuis String.
extension ModuleSurfaceExtension on ModuleSurface {
  String get value {
    switch (this) {
      case ModuleSurface.client:
        return 'client';
      case ModuleSurface.pos:
        return 'pos';
      case ModuleSurface.kitchen:
        return 'kitchen';
      case ModuleSurface.admin:
        return 'admin';
    }
  }

  static ModuleSurface fromString(String? value) {
    switch (value) {
      case 'client':
        return ModuleSurface.client;
      case 'pos':
        return ModuleSurface.pos;
      case 'kitchen':
        return ModuleSurface.kitchen;
      case 'admin':
        return ModuleSurface.admin;
      default:
        return ModuleSurface.client;
    }
  }
}

/// Configuration d'exposition d'un module sur différentes surfaces.
class ModuleExposure {
  /// Indique si le module est activé.
  final bool enabled;
  
  /// Liste des surfaces sur lesquelles le module est exposé.
  final List<ModuleSurface> surfaces;

  /// Constructeur principal.
  const ModuleExposure({
    this.enabled = false,
    this.surfaces = const [],
  });

  /// Crée une instance depuis un Map JSON.
  factory ModuleExposure.fromJson(Map<String, dynamic> json) {
    final surfacesList = json['surfaces'] as List<dynamic>?;
    final surfaces = surfacesList
        ?.map((s) => ModuleSurfaceExtension.fromString(s as String?))
        .toList() ?? [];
    
    return ModuleExposure(
      enabled: json['enabled'] as bool? ?? false,
      surfaces: surfaces,
    );
  }

  /// Convertit l'instance en Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'surfaces': surfaces.map((s) => s.value).toList(),
    };
  }

  /// Crée une copie de l'objet avec des valeurs modifiées.
  ModuleExposure copyWith({
    bool? enabled,
    List<ModuleSurface>? surfaces,
  }) {
    return ModuleExposure(
      enabled: enabled ?? this.enabled,
      surfaces: surfaces ?? this.surfaces,
    );
  }

  @override
  String toString() {
    return 'ModuleExposure(enabled: $enabled, surfaces: $surfaces)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ModuleExposure &&
        other.enabled == enabled &&
        listEquals(other.surfaces, surfaces);
  }

  @override
  int get hashCode => Object.hash(enabled, Object.hashAll(surfaces));
}
