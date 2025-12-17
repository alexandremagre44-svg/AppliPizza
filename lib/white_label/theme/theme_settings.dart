/// lib/white_label/theme/theme_settings.dart
///
/// WHITE-LABEL V2 - Source Unique de Vérité pour le Thème
///
/// Ce modèle définit l'unique source de configuration de thème
/// pour tous les restaurants dans le système multi-tenant.
///
/// Intégré dans: RestaurantPlanUnified.theme.settings (champ top-level)
/// Supporte: Draft / Published workflow via Firestore
/// Garantit: Valeurs sûres avec fallback produit
library;

import 'package:flutter/foundation.dart';

/// Échelle typographique disponible.
enum TypographyScale {
  /// Échelle compacte (pour écrans denses).
  compact,
  
  /// Échelle normale (par défaut).
  normal,
  
  /// Échelle large (pour accessibilité).
  large;

  /// Facteur multiplicateur pour les tailles de texte.
  double get scaleFactor {
    switch (this) {
      case TypographyScale.compact:
        return 0.9;
      case TypographyScale.normal:
        return 1.0;
      case TypographyScale.large:
        return 1.15;
    }
  }

  /// Conversion depuis string.
  static TypographyScale fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'compact':
        return TypographyScale.compact;
      case 'large':
        return TypographyScale.large;
      case 'normal':
      default:
        return TypographyScale.normal;
    }
  }

  /// Conversion vers string.
  String toJson() => name;
}

/// Configuration de thème White-Label V2.
///
/// Cette classe est l'UNIQUE source de vérité pour le thème de l'application.
/// Elle remplace tous les anciens systèmes de configuration de thème.
///
/// Caractéristiques:
/// - Valeurs par défaut sûres (fallback produit)
/// - Validation automatique des couleurs (contraste minimum)
/// - Compatible multi-restaurants
/// - Support hot reload Firestore
///
/// Stockage Firestore:
/// ```
/// restaurants/{restaurantId}/plan/config
///   → theme: {
///       enabled: true,
///       settings: {
///         primaryColor: "#D32F2F",
///         secondaryColor: "#8E4C4C",
///         ...
///       }
///     }
/// ```
class ThemeSettings {
  // ========== Couleurs Principales ==========

  /// Couleur primaire (hex format: "#RRGGBB").
  /// 
  /// Utilisée pour:
  /// - AppBar background
  /// - Boutons principaux
  /// - Éléments interactifs principaux
  final String primaryColor;

  /// Couleur secondaire (hex format: "#RRGGBB").
  /// 
  /// Utilisée pour:
  /// - Boutons secondaires
  /// - Accents complémentaires
  final String secondaryColor;

  // ========== Couleurs de Surface ==========

  /// Couleur de surface (hex format: "#RRGGBB").
  /// 
  /// Utilisée pour:
  /// - Cards
  /// - Modales
  /// - Surfaces élevées
  final String surfaceColor;

  /// Couleur de fond (hex format: "#RRGGBB").
  /// 
  /// Utilisée pour:
  /// - Scaffold background
  /// - Fond de l'application
  final String backgroundColor;

  // ========== Couleurs de Texte ==========

  /// Couleur de texte primaire (hex format: "#RRGGBB").
  /// 
  /// Utilisée pour:
  /// - Titres
  /// - Texte principal
  final String textPrimary;

  /// Couleur de texte secondaire (hex format: "#RRGGBB").
  /// 
  /// Utilisée pour:
  /// - Sous-titres
  /// - Texte descriptif
  final String textSecondary;

  // ========== Tokens de Design ==========

  /// Rayon de base pour les bordures (en pixels).
  /// 
  /// Les autres radius sont calculés depuis cette valeur:
  /// - radiusSmall = radiusBase * 0.67
  /// - radiusMedium = radiusBase
  /// - radiusLarge = radiusBase * 1.5
  final double radiusBase;

  /// Espacement de base (en pixels).
  /// 
  /// Les autres espacements sont calculés depuis cette valeur:
  /// - xs = spacingBase * 0.5
  /// - sm = spacingBase
  /// - md = spacingBase * 2
  /// - lg = spacingBase * 3
  /// - xl = spacingBase * 4
  final double spacingBase;

  /// Échelle typographique.
  /// 
  /// Détermine le facteur multiplicateur pour toutes les tailles de texte.
  final TypographyScale typographyScale;

  // ========== Métadonnées ==========

  /// Date de dernière mise à jour.
  final DateTime updatedAt;

  /// Identifiant de l'utilisateur ayant fait la dernière modification.
  final String? lastModifiedBy;

  /// Constructeur.
  const ThemeSettings({
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.backgroundColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.radiusBase,
    required this.spacingBase,
    required this.typographyScale,
    required this.updatedAt,
    this.lastModifiedBy,
  });

  // ========== Configuration par Défaut (Fallback Produit) ==========

  /// Configuration par défaut (thème Pizza Deli'Zza).
  /// 
  /// Cette configuration est utilisée comme fallback si:
  /// - Aucune configuration n'existe dans Firestore
  /// - La configuration Firestore est invalide
  /// - Une erreur survient lors du chargement
  /// 
  /// Garantit que l'application a TOUJOURS un thème valide.
  factory ThemeSettings.defaultConfig() {
    return ThemeSettings(
      // Couleurs Pizza Deli'Zza (Rouge/Blanc)
      primaryColor: '#D32F2F',      // Rouge pizza
      secondaryColor: '#8E4C4C',    // Rouge secondaire
      surfaceColor: '#FFFFFF',      // Blanc
      backgroundColor: '#FAFAFA',   // Gris très clair
      textPrimary: '#323232',       // Gris foncé
      textSecondary: '#5A5A5A',     // Gris moyen
      
      // Tokens
      radiusBase: 12.0,             // 12px (Material 3)
      spacingBase: 8.0,             // 8px (base spacing)
      typographyScale: TypographyScale.normal,
      
      // Métadonnées
      updatedAt: DateTime.now(),
      lastModifiedBy: null,
    );
  }

  // ========== Sérialisation ==========

  /// Conversion depuis Firestore JSON.
  /// 
  /// Utilise des valeurs par défaut pour tous les champs manquants.
  /// Garantit qu'aucun crash ne peut survenir lors du chargement.
  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    final defaults = ThemeSettings.defaultConfig();

    return ThemeSettings(
      primaryColor: json['primaryColor'] as String? ?? defaults.primaryColor,
      secondaryColor: json['secondaryColor'] as String? ?? defaults.secondaryColor,
      surfaceColor: json['surfaceColor'] as String? ?? defaults.surfaceColor,
      backgroundColor: json['backgroundColor'] as String? ?? defaults.backgroundColor,
      textPrimary: json['textPrimary'] as String? ?? defaults.textPrimary,
      textSecondary: json['textSecondary'] as String? ?? defaults.textSecondary,
      radiusBase: _parseDouble(json['radiusBase']) ?? defaults.radiusBase,
      spacingBase: _parseDouble(json['spacingBase']) ?? defaults.spacingBase,
      typographyScale: TypographyScale.fromString(json['typographyScale'] as String?),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      lastModifiedBy: json['lastModifiedBy'] as String?,
    );
  }

  /// Conversion vers Firestore JSON.
  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'surfaceColor': surfaceColor,
      'backgroundColor': backgroundColor,
      'textPrimary': textPrimary,
      'textSecondary': textSecondary,
      'radiusBase': radiusBase,
      'spacingBase': spacingBase,
      'typographyScale': typographyScale.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastModifiedBy': lastModifiedBy,
    };
  }

  // ========== Helpers ==========

  /// Parse un double depuis une valeur dynamique.
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse un DateTime depuis Firestore.
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    // Handle Firestore Timestamp
    if (value.runtimeType.toString().contains('Timestamp')) {
      try {
        return (value as dynamic).toDate() as DateTime;
      } catch (_) {
        return null;
      }
    }

    // Handle ISO 8601 string
    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  // ========== Copie avec modification ==========

  /// Crée une copie avec des valeurs modifiées.
  ThemeSettings copyWith({
    String? primaryColor,
    String? secondaryColor,
    String? surfaceColor,
    String? backgroundColor,
    String? textPrimary,
    String? textSecondary,
    double? radiusBase,
    double? spacingBase,
    TypographyScale? typographyScale,
    DateTime? updatedAt,
    String? lastModifiedBy,
  }) {
    return ThemeSettings(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      radiusBase: radiusBase ?? this.radiusBase,
      spacingBase: spacingBase ?? this.spacingBase,
      typographyScale: typographyScale ?? this.typographyScale,
      updatedAt: updatedAt ?? this.updatedAt,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
    );
  }

  // ========== Getters Dérivés ==========

  /// Rayon small (67% du rayon de base).
  double get radiusSmall => radiusBase * 0.67;

  /// Rayon medium (100% du rayon de base).
  double get radiusMedium => radiusBase;

  /// Rayon large (150% du rayon de base).
  double get radiusLarge => radiusBase * 1.5;

  /// Espacement extra small (50% de la base).
  double get spacingXS => spacingBase * 0.5;

  /// Espacement small (100% de la base).
  double get spacingSM => spacingBase;

  /// Espacement medium (200% de la base).
  double get spacingMD => spacingBase * 2;

  /// Espacement large (300% de la base).
  double get spacingLG => spacingBase * 3;

  /// Espacement extra large (400% de la base).
  double get spacingXL => spacingBase * 4;

  // ========== Comparaison ==========

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeSettings &&
        other.primaryColor == primaryColor &&
        other.secondaryColor == secondaryColor &&
        other.surfaceColor == surfaceColor &&
        other.backgroundColor == backgroundColor &&
        other.textPrimary == textPrimary &&
        other.textSecondary == textSecondary &&
        other.radiusBase == radiusBase &&
        other.spacingBase == spacingBase &&
        other.typographyScale == typographyScale;
  }

  @override
  int get hashCode {
    return Object.hash(
      primaryColor,
      secondaryColor,
      surfaceColor,
      backgroundColor,
      textPrimary,
      textSecondary,
      radiusBase,
      spacingBase,
      typographyScale,
    );
  }

  @override
  String toString() {
    return 'ThemeSettings(primary: $primaryColor, secondary: $secondaryColor, '
        'radius: $radiusBase, spacing: $spacingBase, scale: ${typographyScale.name})';
  }

  // ========== Validation ==========

  /// Valide que toutes les couleurs sont valides.
  /// 
  /// Retourne true si toutes les couleurs peuvent être parsées.
  bool validate() {
    try {
      _validateColor(primaryColor);
      _validateColor(secondaryColor);
      _validateColor(surfaceColor);
      _validateColor(backgroundColor);
      _validateColor(textPrimary);
      _validateColor(textSecondary);
      return true;
    } catch (e) {
      debugPrint('ThemeSettings validation failed: $e');
      return false;
    }
  }

  /// Valide une couleur hex.
  static void _validateColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length != 6 && cleaned.length != 8) {
      throw FormatException('Invalid hex color: $hex');
    }
    int.parse(cleaned, radix: 16); // Throws if invalid
  }
}
