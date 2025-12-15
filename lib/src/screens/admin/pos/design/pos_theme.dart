// lib/src/screens/admin/pos/design/pos_theme.dart
// Design System POS - ShopCaisse Theme

import 'package:flutter/material.dart';

/// Palette de couleurs ShopCaisse avec couleur primaire #5557F6 (indigo)
class PosColors {
  // ═══════════════════════════════════════════════════════════════
  // COULEURS PRIMAIRES - Indigo ShopCaisse #5557F6
  // ═══════════════════════════════════════════════════════════════
  
  /// Indigo principal ShopCaisse #5557F6
  static const Color primary = Color(0xFF5557F6);
  
  /// Indigo clair pour hover et états actifs #7678F8
  static const Color primaryLight = Color(0xFF7678F8);
  
  /// Indigo foncé pour texte et ombres #3D3FCB
  static const Color primaryDark = Color(0xFF3D3FCB);
  
  /// Container primaire indigo très clair #E8E8FE
  static const Color primaryContainer = Color(0xFFE8E8FE);
  
  /// Blanc sur primaire
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════
  // SURFACE & BACKGROUND
  // ═══════════════════════════════════════════════════════════════
  
  /// Background principal #FAFAFA
  static const Color background = Color(0xFFFAFAFA);
  
  /// Surface blanche #FFFFFF
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Surface variant #F5F5F5
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // ═══════════════════════════════════════════════════════════════
  // TEXTE
  // ═══════════════════════════════════════════════════════════════
  
  /// Texte principal #1A1A1A
  static const Color textPrimary = Color(0xFF1A1A1A);
  
  /// Texte secondaire #616161
  static const Color textSecondary = Color(0xFF616161);
  
  /// Texte tertiaire #9E9E9E
  static const Color textTertiary = Color(0xFF9E9E9E);

  // ═══════════════════════════════════════════════════════════════
  // COULEURS D'ÉTAT
  // ═══════════════════════════════════════════════════════════════
  
  /// Vert succès #10B981
  static const Color success = Color(0xFF10B981);
  
  /// Vert succès clair #D1FAE5
  static const Color successLight = Color(0xFFD1FAE5);
  
  /// Orange avertissement #F59E0B
  static const Color warning = Color(0xFFF59E0B);
  
  /// Orange avertissement clair #FEF3C7
  static const Color warningLight = Color(0xFFFEF3C7);
  
  /// Rouge danger #EF4444
  static const Color danger = Color(0xFFEF4444);
  
  /// Rouge danger clair #FEE2E2
  static const Color dangerLight = Color(0xFFFEE2E2);
  
  /// Bleu information #3B82F6
  static const Color info = Color(0xFF3B82F6);
  
  /// Bleu information clair #DBEAFE
  static const Color infoLight = Color(0xFFDBEAFE);

  // ═══════════════════════════════════════════════════════════════
  // BORDURES
  // ═══════════════════════════════════════════════════════════════
  
  /// Bordure normale #E0E0E0
  static const Color border = Color(0xFFE0E0E0);
  
  /// Bordure forte #BDBDBD
  static const Color borderStrong = Color(0xFFBDBDBD);
  
  /// Bordure subtile #F5F5F5
  static const Color borderSubtle = Color(0xFFF5F5F5);

  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════
  
  /// Gradient primaire indigo
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Constantes d'espacement POS
class PosSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

/// Border radius POS
class PosRadii {
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

/// Box shadows POS
class PosShadows {
  /// Ombre subtile
  static List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Ombre pour carte
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Ombre élevée
  static List<BoxShadow> elevated = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  /// Glow primaire indigo
  static List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: PosColors.primary.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Glow succès
  static List<BoxShadow> successGlow = [
    BoxShadow(
      color: PosColors.success.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Styles de texte POS
class PosTextStyles {
  // Headers
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: PosColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: PosColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: PosColors.textPrimary,
    height: 1.3,
  );
  
  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: PosColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: PosColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: PosColors.textSecondary,
    height: 1.5,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PosColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: PosColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: PosColors.textSecondary,
    height: 1.2,
  );
  
  // Prix
  static const TextStyle priceDisplay = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: PosColors.primary,
    letterSpacing: -0.5,
  );
  
  static const TextStyle priceMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: PosColors.primary,
  );
  
  // Boutons
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}
