/// lib/white_label/theme/pos_theme_adapter.dart
///
/// WHITE-LABEL V2 - Adaptateur POS
///
/// Permet de teinter le POS Design System avec les couleurs du thème WL
/// SANS modifier pos_design_system.dart (respect architecture existante).
///
/// Responsabilités:
/// - Générer couleurs POS adaptées depuis ThemeSettings
/// - Conserver couleurs critiques (success, danger, warning)
/// - Garantir cohérence visuelle avec le reste de l'app
/// - Fallback sur PosColors par défaut
library;

import 'package:flutter/material.dart';
import 'theme_settings.dart';
import '../../src/design_system/pos_design_system.dart' show PosColors;

/// Adaptateur pour teinter le POS avec le thème White-Label.
///
/// Cette classe permet d'adapter les couleurs du POS Design System
/// aux couleurs configurées dans ThemeSettings, tout en préservant:
/// - Les couleurs de statut critiques (success, warning, error)
/// - Le style premium sobre du POS
/// - La cohérence avec pos_design_system.dart
///
/// Usage:
/// ```dart
/// final settings = ThemeSettings.defaultConfig();
/// final posTheme = PosThemeAdapter.fromThemeSettings(settings);
/// 
/// // Utiliser dans widgets POS
/// Container(
///   color: posTheme.primary,
///   child: Text('POS', style: TextStyle(color: posTheme.textOnPrimary)),
/// )
/// ```
class PosThemeAdapter {
  /// Couleur primaire POS (teinté depuis ThemeSettings).
  final Color primary;

  /// Couleur primaire claire.
  final Color primaryLight;

  /// Couleur primaire foncée.
  final Color primaryDark;

  /// Background POS.
  final Color background;

  /// Surface POS.
  final Color surface;

  /// Couleur de texte primaire.
  final Color textPrimary;

  /// Couleur de texte secondaire.
  final Color textSecondary;

  /// Texte sur couleur primaire.
  final Color textOnPrimary;

  // ========== Couleurs Critiques (NON MODIFIABLES) ==========
  // Ces couleurs sont clampées et ne peuvent pas être personnalisées
  // pour garantir la sécurité UX dans le contexte POS.

  /// Success (toujours vert, non personnalisable).
  final Color success = PosColors.success;

  /// Warning (toujours orange, non personnalisable).
  final Color warning = PosColors.warning;

  /// Error (toujours rouge, non personnalisable).
  final Color error = PosColors.error;

  /// Info (toujours bleu, non personnalisable).
  final Color info = PosColors.info;

  /// Constructeur.
  const PosThemeAdapter({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnPrimary,
  });

  /// Crée un PosThemeAdapter depuis ThemeSettings.
  ///
  /// Cette méthode adapte les couleurs du thème WL pour le POS:
  /// - Primary: Utilisée depuis ThemeSettings.primaryColor
  /// - Background/Surface: Utilisées depuis ThemeSettings
  /// - Texte: Utilisé depuis ThemeSettings
  /// - Statuts (success/warning/error): TOUJOURS les couleurs PosColors par défaut
  ///
  /// Fallback: Si parsing échoue, retourne les couleurs PosColors par défaut.
  factory PosThemeAdapter.fromThemeSettings(ThemeSettings settings) {
    try {
      // Parser couleur primaire
      final primary = _parseColorSafe(
        settings.primaryColor,
        PosColors.primary,
      );

      // Générer nuances primary
      final primaryLight = Color.lerp(primary, Colors.white, 0.2)!;
      final primaryDark = Color.lerp(primary, Colors.black, 0.2)!;

      // Parser autres couleurs
      final background = _parseColorSafe(
        settings.backgroundColor,
        PosColors.background,
      );

      final surface = _parseColorSafe(
        settings.surfaceColor,
        PosColors.surface,
      );

      final textPrimary = _parseColorSafe(
        settings.textPrimary,
        PosColors.textPrimary,
      );

      final textSecondary = _parseColorSafe(
        settings.textSecondary,
        PosColors.textSecondary,
      );

      // Calculer texte sur primary
      final textOnPrimary = _computeContrastColor(primary);

      return PosThemeAdapter(
        primary: primary,
        primaryLight: primaryLight,
        primaryDark: primaryDark,
        background: background,
        surface: surface,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        textOnPrimary: textOnPrimary,
      );
    } catch (e) {
      debugPrint('PosThemeAdapter: Error parsing settings, using defaults: $e');
      return PosThemeAdapter.defaultTheme();
    }
  }

  /// Thème POS par défaut (PosColors standard).
  ///
  /// Utilisé comme fallback si:
  /// - Parsing ThemeSettings échoue
  /// - Module theme désactivé
  /// - Erreur critique
  factory PosThemeAdapter.defaultTheme() {
    return const PosThemeAdapter(
      primary: PosColors.primary,
      primaryLight: PosColors.primaryLight,
      primaryDark: PosColors.primaryDark,
      background: PosColors.background,
      surface: PosColors.surface,
      textPrimary: PosColors.textPrimary,
      textSecondary: PosColors.textSecondary,
      textOnPrimary: PosColors.textOnPrimary,
    );
  }

  // ========== Helpers ==========

  /// Parse couleur hex de manière sûre.
  static Color _parseColorSafe(String hex, Color fallback) {
    try {
      final cleaned = hex.replaceAll('#', '');
      if (cleaned.length == 6) {
        return Color(int.parse('FF$cleaned', radix: 16));
      } else if (cleaned.length == 8) {
        return Color(int.parse(cleaned, radix: 16));
      }
      return fallback;
    } catch (e) {
      return fallback;
    }
  }

  /// Calcule couleur de contraste pour un fond.
  static Color _computeContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // ========== Getters Additionnels ==========

  /// Couleurs de border (même logique que PosColors).
  Color get border => const Color(0xFFE0E2E7);

  /// Couleurs de divider.
  Color get divider => const Color(0xFFE8E9ED);

  /// Success light (backgrounds).
  Color get successLight => PosColors.successLight;

  /// Warning light (backgrounds).
  Color get warningLight => PosColors.warningLight;

  /// Error light (backgrounds).
  Color get errorLight => PosColors.errorLight;

  /// Info light (backgrounds).
  Color get infoLight => PosColors.infoLight;
}
