/// lib/white_label/theme/theme_extensions.dart
///
/// WHITE-LABEL V2 - Extensions pour Accès Simplifié au Thème
///
/// Fournit des extensions pour accéder facilement aux propriétés du thème
/// depuis n'importe quel widget avec BuildContext.
///
/// Usage:
/// ```dart
/// // Au lieu de: Theme.of(context).colorScheme.primary
/// context.primaryColor
///
/// // Au lieu de: Theme.of(context).textTheme.bodyLarge
/// context.bodyLarge
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_settings.dart';
import 'unified_theme_provider.dart';

/// Extension sur BuildContext pour accès rapide au thème.
extension ThemeContextExtension on BuildContext {
  // ========== Theme & ColorScheme ==========
  
  /// Accès au ThemeData complet.
  ThemeData get theme => Theme.of(this);
  
  /// Accès au ColorScheme Material 3.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Accès au TextTheme.
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // ========== Couleurs Primaires ==========
  
  /// Couleur primaire du thème.
  Color get primaryColor => colorScheme.primary;
  
  /// Couleur de texte sur primaire.
  Color get onPrimary => colorScheme.onPrimary;
  
  /// Container primaire (version atténuée).
  Color get primaryContainer => colorScheme.primaryContainer;
  
  /// Couleur de texte sur container primaire.
  Color get onPrimaryContainer => colorScheme.onPrimaryContainer;
  
  // ========== Couleurs Secondaires ==========
  
  /// Couleur secondaire du thème.
  Color get secondaryColor => colorScheme.secondary;
  
  /// Couleur de texte sur secondaire.
  Color get onSecondary => colorScheme.onSecondary;
  
  /// Container secondaire (version atténuée).
  Color get secondaryContainer => colorScheme.secondaryContainer;
  
  /// Couleur de texte sur container secondaire.
  Color get onSecondaryContainer => colorScheme.onSecondaryContainer;
  
  // ========== Surface & Background ==========
  
  /// Couleur de surface (cards, modals).
  Color get surfaceColor => colorScheme.surface;
  
  /// Couleur de texte sur surface.
  Color get onSurface => colorScheme.onSurface;
  
  /// Couleur de fond de l'application.
  Color get backgroundColor => colorScheme.background;
  
  /// Couleur de texte sur fond.
  Color get onBackground => colorScheme.onBackground;
  
  /// Couleur de texte secondaire (labels, descriptions).
  Color get textSecondary => colorScheme.onSurfaceVariant;
  
  // ========== Error & States ==========
  
  /// Couleur d'erreur.
  Color get errorColor => colorScheme.error;
  
  /// Couleur de texte sur erreur.
  Color get onError => colorScheme.onError;
  
  /// Container d'erreur.
  Color get errorContainer => colorScheme.errorContainer;
  
  /// Outline (bordures).
  Color get outlineColor => colorScheme.outline;
  
  /// Outline variant (bordures subtiles).
  Color get outlineVariant => colorScheme.outlineVariant;
  
  // ========== Text Styles ==========
  
  /// Display large (96px).
  TextStyle? get displayLarge => textTheme.displayLarge;
  
  /// Display medium (60px).
  TextStyle? get displayMedium => textTheme.displayMedium;
  
  /// Display small (48px).
  TextStyle? get displaySmall => textTheme.displaySmall;
  
  /// Headline large (32px).
  TextStyle? get headlineLarge => textTheme.headlineLarge;
  
  /// Headline medium (28px).
  TextStyle? get headlineMedium => textTheme.headlineMedium;
  
  /// Headline small (24px).
  TextStyle? get headlineSmall => textTheme.headlineSmall;
  
  /// Title large (22px).
  TextStyle? get titleLarge => textTheme.titleLarge;
  
  /// Title medium (16px).
  TextStyle? get titleMedium => textTheme.titleMedium;
  
  /// Title small (14px).
  TextStyle? get titleSmall => textTheme.titleSmall;
  
  /// Body large (16px).
  TextStyle? get bodyLarge => textTheme.bodyLarge;
  
  /// Body medium (14px).
  TextStyle? get bodyMedium => textTheme.bodyMedium;
  
  /// Body small (12px).
  TextStyle? get bodySmall => textTheme.bodySmall;
  
  /// Label large (14px).
  TextStyle? get labelLarge => textTheme.labelLarge;
  
  /// Label medium (12px).
  TextStyle? get labelMedium => textTheme.labelMedium;
  
  /// Label small (11px).
  TextStyle? get labelSmall => textTheme.labelSmall;
}

/// Extension sur WidgetRef pour accéder à ThemeSettings directement.
///
/// Usage dans un ConsumerWidget:
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   final radiusBase = ref.themeSettings.radiusBase;
///   final primaryHex = ref.themeSettings.primaryColor;
/// }
/// ```
extension ThemeRefExtension on WidgetRef {
  /// Accès direct à ThemeSettings.
  ThemeSettings get themeSettings => watch(themeSettingsProvider);
  
  /// Vérifie si un thème custom est actif.
  bool get isCustomThemeActive => watch(isCustomThemeActiveProvider);
}

/// Helper pour créer des radius depuis ThemeSettings.
///
/// ⚠️ **IMPORTANT**: Ces méthodes retournent des valeurs Material 3 par défaut
/// car BuildContext seul ne peut pas accéder à ThemeSettings.
///
/// **Utilisation recommandée**:
/// - Pour ConsumerWidget: Utiliser `ref.themeSettings.radiusBase` directement
/// - Pour StatelessWidget sans WidgetRef: Utiliser ces helpers (valeur fixe M3)
/// - Pour widgets stylés: Hériter du thème (ex: Card hérite de cardTheme.shape)
///
/// Usage:
/// ```dart
/// // ConsumerWidget (RECOMMANDÉ)
/// BorderRadius.circular(ref.themeSettings.radiusBase)
///
/// // StatelessWidget (Fallback Material 3)
/// BorderRadius.circular(ThemeRadius.base(context))
/// ```
class ThemeRadius {
  ThemeRadius._();
  
  /// Rayon de base Material 3 (12.0).
  /// 
  /// ⚠️ ATTENTION: Retourne une valeur fixe Material 3, pas la valeur du thème.
  /// Pour obtenir la vraie valeur dynamique du thème, utiliser:
  /// `ref.themeSettings.radiusBase` dans un ConsumerWidget.
  static double base(BuildContext context) {
    return 12.0; // Material 3 default
  }
  
  /// Rayon petit (67% du rayon de base).
  static double small(BuildContext context) {
    return base(context) * 0.67;
  }
  
  /// Rayon moyen (100% du rayon de base).
  static double medium(BuildContext context) {
    return base(context);
  }
  
  /// Rayon large (150% du rayon de base).
  static double large(BuildContext context) {
    return base(context) * 1.5;
  }
}

/// Helper pour créer des espacements depuis ThemeSettings.
///
/// ⚠️ **IMPORTANT**: Ces méthodes retournent des valeurs Material 3 par défaut
/// car BuildContext seul ne peut pas accéder à ThemeSettings.
///
/// **Utilisation recommandée**:
/// - Pour ConsumerWidget: Utiliser `ref.themeSettings.spacingBase` directement
/// - Pour StatelessWidget sans WidgetRef: Utiliser ces helpers (valeur fixe M3)
///
/// Usage:
/// ```dart
/// // ConsumerWidget (RECOMMANDÉ)
/// padding: EdgeInsets.all(ref.themeSettings.spacingBase * 2)
///
/// // StatelessWidget (Fallback Material 3)
/// padding: EdgeInsets.all(ThemeSpacing.md(context))
/// ```
class ThemeSpacing {
  ThemeSpacing._();
  
  /// Espacement de base Material 3 (8.0).
  /// 
  /// ⚠️ ATTENTION: Retourne une valeur fixe Material 3, pas la valeur du thème.
  /// Pour obtenir la vraie valeur dynamique du thème, utiliser:
  /// `ref.themeSettings.spacingBase` dans un ConsumerWidget.
  static double base(BuildContext context) {
    return 8.0; // Material 3 default
  }
  
  /// Espacement extra small (50% de la base = 4px).
  static double xs(BuildContext context) {
    return base(context) * 0.5;
  }
  
  /// Espacement small (100% de la base = 8px).
  static double sm(BuildContext context) {
    return base(context);
  }
  
  /// Espacement medium (200% de la base = 16px).
  static double md(BuildContext context) {
    return base(context) * 2;
  }
  
  /// Espacement large (300% de la base = 24px).
  static double lg(BuildContext context) {
    return base(context) * 3;
  }
  
  /// Espacement extra large (400% de la base = 32px).
  static double xl(BuildContext context) {
    return base(context) * 4;
  }
}
