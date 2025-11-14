// lib/src/design_system/colors.dart
// Palette de couleurs complète - Design System Pizza Deli'Zza Material 3 (2025)

import 'package:flutter/material.dart';

/// Palette de couleurs officielle Pizza Deli'Zza - Material 3 (2025)
/// 
/// Organisation Material 3:
/// - Couleurs primaires (Rouge Deli'Zza #D32F2F)
/// - Couleurs secondaires (#8E4C4C)
/// - Surface & Background
/// - Success, Warning, Error
/// - Outline & Borders
class AppColors {
  // ═══════════════════════════════════════════════════════════════
  // PALETTE PRIMAIRE - Rouge Pizza Deli'Zza (Material 3)
  // ═══════════════════════════════════════════════════════════════
  
  /// Rouge principal Pizza Deli'Zza #D32F2F (Material 3 Primary)
  static const Color primary = Color(0xFFD32F2F);
  
  /// Blanc sur primaire #FFFFFF
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  /// Container primaire #F9DEDE
  static const Color primaryContainer = Color(0xFFF9DEDE);
  
  /// Texte sur container primaire #7A1212
  static const Color onPrimaryContainer = Color(0xFF7A1212);
  
  // Aliases pour compatibilité
  /// Rouge clair pour survol et états actifs #E53935
  static const Color primaryLight = Color(0xFFE53935);
  
  /// Rouge très clair pour backgrounds #FFEBEE (alias de primaryContainer)
  static const Color primaryLighter = primaryContainer;
  
  /// Rouge foncé pour texte et ombres #8E0000
  static const Color primaryDark = Color(0xFF8E0000);
  
  /// Rouge très foncé #6D0000
  static const Color primaryDarker = Color(0xFF6D0000);

  // ═══════════════════════════════════════════════════════════════
  // COULEURS SECONDAIRES - Material 3
  // ═══════════════════════════════════════════════════════════════
  
  /// Secondaire #8E4C4C
  static const Color secondary = Color(0xFF8E4C4C);
  
  /// Blanc sur secondaire #FFFFFF
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  /// Container secondaire #F5E3E3
  static const Color secondaryContainer = Color(0xFFF5E3E3);

  // ═══════════════════════════════════════════════════════════════
  // SURFACE & BACKGROUND - Material 3
  // ═══════════════════════════════════════════════════════════════
  
  /// Background principal #FAFAFA
  static const Color background = Color(0xFFFAFAFA);
  
  /// Surface blanche #FFFFFF
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Surface Container Low #F5F5F5
  static const Color surfaceContainerLow = Color(0xFFF5F5F5);
  
  /// Surface Container #EEEEEE
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  
  /// Surface Container High #E6E6E6
  static const Color surfaceContainerHigh = Color(0xFFE6E6E6);
  
  /// Texte sur surface #323232
  static const Color onSurface = Color(0xFF323232);
  
  /// Texte sur surface variant #5A5A5A
  static const Color onSurfaceVariant = Color(0xFF5A5A5A);
  
  /// Outline #BEBEBE
  static const Color outline = Color(0xFFBEBEBE);
  
  /// Outline Variant #E0E0E0
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // ═══════════════════════════════════════════════════════════════
  // COULEURS NEUTRES - Échelle de gris (pour compatibilité)
  // ═══════════════════════════════════════════════════════════════
  
  /// Gris 50 - Background le plus clair #FAFAFA
  static const Color neutral50 = background;
  
  /// Gris 100 - Background secondaire #F5F5F5
  static const Color neutral100 = surfaceContainerLow;
  
  /// Gris 200 - Bordures subtiles #EEEEEE
  static const Color neutral200 = surfaceContainer;
  
  /// Gris 300 - Bordures normales #E0E0E0
  static const Color neutral300 = outlineVariant;
  
  /// Gris 400 - Bordures accentuées #BDBDBD
  static const Color neutral400 = Color(0xFFBDBDBD);
  
  /// Gris 500 - Texte désactivé #9E9E9E
  static const Color neutral500 = Color(0xFF9E9E9E);
  
  /// Gris 600 - Texte secondaire #757575
  static const Color neutral600 = Color(0xFF757575);
  
  /// Gris 700 - Texte normal #616161
  static const Color neutral700 = Color(0xFF616161);
  
  /// Gris 800 - Texte foncé #424242
  static const Color neutral800 = Color(0xFF424242);
  
  /// Gris 900 - Texte principal #212121
  static const Color neutral900 = Color(0xFF212121);

  // ═══════════════════════════════════════════════════════════════
  // COULEURS D'ÉTAT - Material 3
  // ═══════════════════════════════════════════════════════════════
  
  /// Vert succès #3FA35B
  static const Color success = Color(0xFF3FA35B);
  
  /// Container succès #E5F5EB
  static const Color successContainer = Color(0xFFE5F5EB);
  
  /// Vert succès clair pour backgrounds (alias)
  static const Color successLight = successContainer;
  
  /// Vert succès foncé pour texte #2E7D32
  static const Color successDark = Color(0xFF2E7D32);
  
  /// Orange avertissement #F2994A
  static const Color warning = Color(0xFFF2994A);
  
  /// Container avertissement #FDE9D9
  static const Color warningContainer = Color(0xFFFDE9D9);
  
  /// Orange avertissement clair pour backgrounds (alias)
  static const Color warningLight = warningContainer;
  
  /// Orange avertissement foncé pour texte #E65100
  static const Color warningDark = Color(0xFFE65100);
  
  /// Rouge erreur #C62828
  static const Color error = Color(0xFFC62828);
  
  /// Container erreur #F9DADA
  static const Color errorContainer = Color(0xFFF9DADA);
  
  /// Rouge danger (alias de error)
  static const Color danger = error;
  
  /// Rouge danger clair pour backgrounds (alias)
  static const Color dangerLight = errorContainer;
  
  /// Rouge danger foncé pour texte #B71C1C
  static const Color dangerDark = Color(0xFFB71C1C);
  
  /// Bleu information #2196F3
  static const Color info = Color(0xFF2196F3);
  
  /// Bleu information clair pour backgrounds #E3F2FD
  static const Color infoLight = Color(0xFFE3F2FD);
  
  /// Bleu information foncé pour texte #1565C0
  static const Color infoDark = Color(0xFF1565C0);

  // ═══════════════════════════════════════════════════════════════
  // COULEURS SPÉCIALES - Accent & Effets
  // ═══════════════════════════════════════════════════════════════
  
  /// Or accent #FFD700
  static const Color accentGold = Color(0xFFFFD700);
  
  /// Or accent clair #FFF9E6
  static const Color accentGoldLight = Color(0xFFFFF9E6);
  
  /// Vert accent #4CAF50
  static const Color accentGreen = Color(0xFF4CAF50);

  // ═══════════════════════════════════════════════════════════════
  // COULEURS DE BASE
  // ═══════════════════════════════════════════════════════════════
  
  /// Blanc pur #FFFFFF
  static const Color white = Color(0xFFFFFFFF);
  
  /// Noir pur #000000
  static const Color black = Color(0xFF000000);

  // ═══════════════════════════════════════════════════════════════
  // COULEURS SÉMANTIQUES - Alias pour usage contextuel
  // ═══════════════════════════════════════════════════════════════
  
  /// Texte principal #323232 (utilise onSurface)
  static const Color textPrimary = onSurface;
  
  /// Texte secondaire #5A5A5A (utilise onSurfaceVariant)
  static const Color textSecondary = onSurfaceVariant;
  
  /// Texte tertiaire (gris clair)
  static const Color textTertiary = neutral500;
  
  /// Texte désactivé
  static const Color textDisabled = neutral400;
  
  /// Texte sur fond rouge
  static const Color textOnPrimary = onPrimary;
  
  /// Bordure subtile (utilise outlineVariant)
  static const Color borderSubtle = outlineVariant;
  
  /// Bordure normale (utilise outline)
  static const Color border = outline;
  
  /// Bordure accentuée
  static const Color borderStrong = neutral400;
  
  /// Overlay sombre (pour modales)
  static const Color overlay = Color(0x80000000); // 50% noir
  
  /// Overlay clair
  static const Color overlayLight = Color(0x26000000); // 15% noir

  // ═══════════════════════════════════════════════════════════════
  // RÉTROCOMPATIBILITÉ - Aliases anciens noms
  // ═══════════════════════════════════════════════════════════════
  
  @Deprecated('Use AppColors.primary instead')
  static const Color primaryRed = primary;
  
  @Deprecated('Use AppColors.primaryLight instead')
  static const Color primaryRedLight = primaryLight;
  
  @Deprecated('Use AppColors.primaryDark instead')
  static const Color primaryRedDark = primaryDark;
  
  @Deprecated('Use AppColors.white instead')
  static const Color surfaceWhite = white;
  
  @Deprecated('Use AppColors.background instead')
  static const Color backgroundLight = background;
  
  @Deprecated('Use AppColors.textPrimary instead')
  static const Color textDark = textPrimary;
  
  @Deprecated('Use AppColors.textSecondary instead')
  static const Color textMedium = textSecondary;
  
  @Deprecated('Use AppColors.textTertiary instead')
  static const Color textLight = textTertiary;
  
  @Deprecated('Use AppColors.success instead')
  static const Color successGreen = success;
  
  @Deprecated('Use AppColors.danger instead')
  static const Color errorRed = danger;
  
  @Deprecated('Use AppColors.warning instead')
  static const Color warningOrange = warning;
  
  @Deprecated('Use AppColors.info instead')
  static const Color infoBlue = info;

  // ═══════════════════════════════════════════════════════════════
  // MATERIAL COLOR SWATCH - Pour ThemeData
  // ═══════════════════════════════════════════════════════════════
  
  static const MaterialColor primarySwatch = MaterialColor(
    0xFFD32F2F, // Primary #D32F2F
    <int, Color>{
      50: Color(0xFFF9DEDE),  // primaryContainer
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(0xFFD32F2F), // primary
      600: Color(0xFFC62828),
      700: Color(0xFFB71C1C),
      800: Color(0xFF7A1212), // onPrimaryContainer
      900: Color(0xFF8E0000),
    },
  );
}
