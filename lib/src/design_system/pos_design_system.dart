// lib/src/design_system/pos_design_system.dart
/// 
/// Design System pour POS - Theme ShopCaisse Premium
/// 
/// Couleur primaire: #5557F6 (Indigo ShopCaisse)
/// Style: Clair, sobre, premium avec cartes et ombres légères
library;

import 'package:flutter/material.dart';

// =============================================
// COLORS - ShopCaisse Theme
// =============================================

/// Palette de couleurs POS ShopCaisse
class PosColors {
  PosColors._(); // Private constructor

  // Couleur primaire ShopCaisse
  static const Color primary = Color(0xFF5557F6);
  static const Color primaryLight = Color(0xFF7E80F8);
  static const Color primaryDark = Color(0xFF3B3DC4);
  
  // Surfaces et backgrounds
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F6F7);
  
  // Borders et dividers
  static const Color border = Color(0xFFE0E2E7);
  static const Color borderLight = Color(0xFFEBECF0);
  static const Color divider = Color(0xFFE8E9ED);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1A1C23);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Colors.white;
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  
  // Shadows
  static const Color shadow = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
}

// =============================================
// SPACING
// =============================================

/// Système d'espacement POS
class PosSpacing {
  PosSpacing._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// =============================================
// BORDER RADIUS
// =============================================

/// Système de border radius POS
class PosRadii {
  PosRadii._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
  
  // Convenience getters
  static BorderRadius get xsRadius => BorderRadius.circular(xs);
  static BorderRadius get smRadius => BorderRadius.circular(sm);
  static BorderRadius get mdRadius => BorderRadius.circular(md);
  static BorderRadius get lgRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get fullRadius => BorderRadius.circular(full);
}

// =============================================
// SHADOWS
// =============================================

/// Système d'ombres POS
class PosShadows {
  PosShadows._();
  
  static List<BoxShadow> get none => [];
  
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: PosColors.shadow,
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get md => [
    BoxShadow(
      color: PosColors.shadow,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get lg => [
    BoxShadow(
      color: PosColors.shadowMedium,
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get xl => [
    BoxShadow(
      color: PosColors.shadowMedium,
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

// =============================================
// TYPOGRAPHY
// =============================================

/// Système typographique POS
class PosTypography {
  PosTypography._();
  
  // Display text (grand titres)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: PosColors.textPrimary,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: PosColors.textPrimary,
  );
  
  // Heading text (titres sections)
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: PosColors.textPrimary,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: PosColors.textPrimary,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: PosColors.textPrimary,
  );
  
  // Body text (texte courant)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: PosColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: PosColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: PosColors.textSecondary,
  );
  
  // Label text (labels de champs, etc)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: PosColors.textPrimary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: PosColors.textSecondary,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: PosColors.textTertiary,
  );
  
  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
  );
  
  // Price text (grand format)
  static const TextStyle priceLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: PosColors.textPrimary,
  );
  
  static const TextStyle priceMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: PosColors.textPrimary,
  );
}

// =============================================
// ICON SIZES
// =============================================

/// Tailles d'icônes POS
class PosIconSize {
  PosIconSize._();
  
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
}

// =============================================
// ANIMATION DURATIONS
// =============================================

/// Durées d'animations POS
class PosDurations {
  PosDurations._();
  
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

// =============================================
// Z-INDEX / ELEVATION
// =============================================

/// Niveaux d'élévation POS
class PosElevation {
  PosElevation._();
  
  static const double flat = 0;
  static const double low = 1;
  static const double medium = 2;
  static const double high = 4;
  static const double highest = 8;
}
