// lib/src/design_system/colors.dart
// Palette de couleurs complète - Design System Pizza Deli'Zza

import 'package:flutter/material.dart';

/// Palette de couleurs complète et cohérente pour Pizza Deli'Zza
/// 
/// Organisation:
/// - Couleurs primaires (Rouge Deli'Zza + variantes)
/// - Couleurs neutres (Gris 50 → 900)
/// - Couleurs d'état (Success, Warning, Danger, Info)
/// - Couleurs d'effets (Shadow, Overlay, Border)
class AppColors {
  // ═══════════════════════════════════════════════════════════════
  // PALETTE PRIMAIRE - Rouge Pizza Deli'Zza
  // ═══════════════════════════════════════════════════════════════
  
  /// Rouge principal Pizza Deli'Zza #B00020
  static const Color primary = Color(0xFFB00020);
  
  /// Rouge clair pour survol et états actifs #E53935
  static const Color primaryLight = Color(0xFFE53935);
  
  /// Rouge très clair pour backgrounds #FFEBEE
  static const Color primaryLighter = Color(0xFFFFEBEE);
  
  /// Rouge foncé pour texte et ombres #8E0000
  static const Color primaryDark = Color(0xFF8E0000);
  
  /// Rouge très foncé #6D0000
  static const Color primaryDarker = Color(0xFF6D0000);

  // ═══════════════════════════════════════════════════════════════
  // COULEURS NEUTRES - Échelle de gris cohérente
  // ═══════════════════════════════════════════════════════════════
  
  /// Gris 50 - Background le plus clair #FAFAFA
  static const Color neutral50 = Color(0xFFFAFAFA);
  
  /// Gris 100 - Background secondaire #F5F5F5
  static const Color neutral100 = Color(0xFFF5F5F5);
  
  /// Gris 200 - Bordures subtiles #EEEEEE
  static const Color neutral200 = Color(0xFFEEEEEE);
  
  /// Gris 300 - Bordures normales #E0E0E0
  static const Color neutral300 = Color(0xFFE0E0E0);
  
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
  // COULEURS D'ÉTAT - Success, Warning, Danger, Info
  // ═══════════════════════════════════════════════════════════════
  
  /// Vert succès #4CAF50
  static const Color success = Color(0xFF4CAF50);
  
  /// Vert succès clair pour backgrounds #E8F5E9
  static const Color successLight = Color(0xFFE8F5E9);
  
  /// Vert succès foncé pour texte #2E7D32
  static const Color successDark = Color(0xFF2E7D32);
  
  /// Orange avertissement #FF9800
  static const Color warning = Color(0xFFFF9800);
  
  /// Orange avertissement clair pour backgrounds #FFF3E0
  static const Color warningLight = Color(0xFFFFF3E0);
  
  /// Orange avertissement foncé pour texte #E65100
  static const Color warningDark = Color(0xFFE65100);
  
  /// Rouge danger #D32F2F
  static const Color danger = Color(0xFFD32F2F);
  
  /// Rouge danger clair pour backgrounds #FFEBEE
  static const Color dangerLight = Color(0xFFFFEBEE);
  
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
  // COULEURS DE BASE - Surface & Background
  // ═══════════════════════════════════════════════════════════════
  
  /// Blanc pur #FFFFFF
  static const Color white = Color(0xFFFFFFFF);
  
  /// Noir pur #000000
  static const Color black = Color(0xFF000000);
  
  /// Surface blanche (cartes, modales)
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Background principal
  static const Color background = Color(0xFFF5F5F5);

  // ═══════════════════════════════════════════════════════════════
  // COULEURS SÉMANTIQUES - Alias pour usage contextuel
  // ═══════════════════════════════════════════════════════════════
  
  /// Texte principal (noir/gris très foncé)
  static const Color textPrimary = neutral900;
  
  /// Texte secondaire (gris moyen)
  static const Color textSecondary = neutral600;
  
  /// Texte tertiaire (gris clair)
  static const Color textTertiary = neutral500;
  
  /// Texte désactivé
  static const Color textDisabled = neutral400;
  
  /// Texte sur fond rouge
  static const Color textOnPrimary = white;
  
  /// Bordure subtile
  static const Color borderSubtle = neutral200;
  
  /// Bordure normale
  static const Color border = neutral300;
  
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
    0xFFB00020,
    <int, Color>{
      50: Color(0xFFFFEBEE),
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(0xFFB00020),
      600: Color(0xFFE53935),
      700: Color(0xFFD32F2F),
      800: Color(0xFFB00020),
      900: Color(0xFF8E0000),
    },
  );
}
