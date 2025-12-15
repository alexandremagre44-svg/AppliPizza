// lib/src/screens/admin/pos/design/pos_theme.dart
/// POS Design System - ShopCaisse Theme
/// 
/// Premium design system for Point of Sale interface
/// Primary color: #5557F6 (indigo)

library;

import 'package:flutter/material.dart';

/// POS Color Palette - ShopCaisse Theme with indigo primary (#5557F6)
class PosColors {
  // ═══════════════════════════════════════════════════════════════
  // PRIMARY - Indigo ShopCaisse (#5557F6)
  // ═══════════════════════════════════════════════════════════════
  
  /// Primary indigo color #5557F6
  static const Color primary = Color(0xFF5557F6);
  
  /// Light indigo for hover states #6D6FF8
  static const Color primaryLight = Color(0xFF6D6FF8);
  
  /// Dark indigo for pressed states #3D3FD4
  static const Color primaryDark = Color(0xFF3D3FD4);
  
  /// Primary container - very light indigo #E8E8FE
  static const Color primaryContainer = Color(0xFFE8E8FE);
  
  // ═══════════════════════════════════════════════════════════════
  // SURFACES & BACKGROUNDS
  // ═══════════════════════════════════════════════════════════════
  
  /// Main surface white #FFFFFF
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Surface variant light gray #F5F5F7
  static const Color surfaceVariant = Color(0xFFF5F5F7);
  
  /// Background light gray #FAFAFA
  static const Color background = Color(0xFFFAFAFA);
  
  // ═══════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════
  
  /// Primary text color #1A1A1A
  static const Color textPrimary = Color(0xFF1A1A1A);
  
  /// Secondary text color #6B6B6B
  static const Color textSecondary = Color(0xFF6B6B6B);
  
  /// Tertiary text color #9B9B9B
  static const Color textTertiary = Color(0xFF9B9B9B);
  
  /// Text on primary color (white) #FFFFFF
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════
  
  /// Success green #10B981
  static const Color success = Color(0xFF10B981);
  
  /// Success light background #D1FAE5
  static const Color successLight = Color(0xFFD1FAE5);
  
  /// Success dark #059669
  static const Color successDark = Color(0xFF059669);
  
  /// Warning orange #F59E0B
  static const Color warning = Color(0xFFF59E0B);
  
  /// Warning light background #FEF3C7
  static const Color warningLight = Color(0xFFFEF3C7);
  
  /// Warning dark #D97706
  static const Color warningDark = Color(0xFFD97706);
  
  /// Danger red #EF4444
  static const Color danger = Color(0xFFEF4444);
  
  /// Danger light background #FEE2E2
  static const Color dangerLight = Color(0xFFFEE2E2);
  
  /// Danger dark #DC2626
  static const Color dangerDark = Color(0xFFDC2626);
  
  /// Info blue #3B82F6
  static const Color info = Color(0xFF3B82F6);
  
  /// Info light background #DBEAFE
  static const Color infoLight = Color(0xFFDBEAFE);
  
  /// Info dark #2563EB
  static const Color infoDark = Color(0xFF2563EB);
  
  // ═══════════════════════════════════════════════════════════════
  // BORDERS
  // ═══════════════════════════════════════════════════════════════
  
  /// Default border color #E5E5E5
  static const Color border = Color(0xFFE5E5E5);
  
  /// Strong border color #BEBEBE
  static const Color borderStrong = Color(0xFFBEBEBE);
  
  /// Subtle border color #F0F0F0
  static const Color borderSubtle = Color(0xFFF0F0F0);
  
  // ═══════════════════════════════════════════════════════════════
  // GRADIENTS
  // ═══════════════════════════════════════════════════════════════
  
  /// Primary gradient (indigo)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// POS Spacing Constants
class PosSpacing {
  /// Extra extra small: 4px
  static const double xxs = 4.0;
  
  /// Extra small: 8px
  static const double xs = 8.0;
  
  /// Small: 12px
  static const double sm = 12.0;
  
  /// Medium: 16px
  static const double md = 16.0;
  
  /// Large: 20px
  static const double lg = 20.0;
  
  /// Extra large: 24px
  static const double xl = 24.0;
  
  /// Extra extra large: 32px
  static const double xxl = 32.0;
}

/// POS Border Radius Constants
class PosRadii {
  /// Extra small: 6px
  static const double xs = 6.0;
  
  /// Small: 8px
  static const double sm = 8.0;
  
  /// Medium: 12px
  static const double md = 12.0;
  
  /// Large: 16px
  static const double lg = 16.0;
  
  /// Extra large: 20px
  static const double xl = 20.0;
  
  /// Extra extra large: 24px
  static const double xxl = 24.0;
}

/// POS Box Shadows
class PosShadows {
  /// Subtle shadow for light elevation
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Card shadow for standard elevation
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Elevated shadow for prominent elements
  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Primary glow effect (indigo)
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: PosColors.primary.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Success glow effect (green)
  static List<BoxShadow> get successGlow => [
    BoxShadow(
      color: PosColors.success.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

/// POS Text Styles
class PosTextStyles {
  // ═══════════════════════════════════════════════════════════════
  // HEADINGS
  // ═══════════════════════════════════════════════════════════════
  
  /// Heading 1 - 32px, Bold
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: PosColors.textPrimary,
    height: 1.2,
  );
  
  /// Heading 2 - 24px, Bold
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: PosColors.textPrimary,
    height: 1.3,
  );
  
  /// Heading 3 - 20px, SemiBold
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: PosColors.textPrimary,
    height: 1.3,
  );
  
  // ═══════════════════════════════════════════════════════════════
  // BODY TEXT
  // ═══════════════════════════════════════════════════════════════
  
  /// Body Large - 16px, Regular
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: PosColors.textPrimary,
    height: 1.5,
  );
  
  /// Body Medium - 14px, Regular
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: PosColors.textPrimary,
    height: 1.5,
  );
  
  /// Body Small - 12px, Regular
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: PosColors.textSecondary,
    height: 1.4,
  );
  
  // ═══════════════════════════════════════════════════════════════
  // LABELS
  // ═══════════════════════════════════════════════════════════════
  
  /// Label Large - 14px, SemiBold
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PosColors.textPrimary,
    height: 1.4,
  );
  
  /// Label Medium - 12px, SemiBold
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: PosColors.textPrimary,
    height: 1.4,
  );
  
  /// Label Small - 10px, SemiBold
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: PosColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  // ═══════════════════════════════════════════════════════════════
  // SPECIAL PURPOSE
  // ═══════════════════════════════════════════════════════════════
  
  /// Price Display Large - 26px, ExtraBold
  static const TextStyle priceDisplay = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: PosColors.primary,
    letterSpacing: -0.5,
  );
  
  /// Price Medium - 17px, ExtraBold
  static const TextStyle priceMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: PosColors.primary,
  );
  
  /// Button Large - 16px, SemiBold
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  /// Button Medium - 14px, SemiBold
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );
}
