// lib/src/design_system/text_styles.dart
// Hiérarchie typographique complète - Design System Pizza Deli'Zza Material 3 (2025)

import 'package:flutter/material.dart';
import 'colors.dart';

/// Hiérarchie typographique Material 3 pour Pizza Deli'Zza
/// 
/// Famille: Inter (fallback Roboto)
/// 
/// Organisation Material 3:
/// - Display (32-40px) - Titres très grands
/// - Headline (20-28px) - Titres de section
/// - Title (14-20px) - Titres de cartes
/// - Body (14-16px) - Corps de texte
/// - Label (11-14px) - Labels et badges
/// 
/// Poids: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)
class AppTextStyles {
  // Police par défaut - Inter avec fallback Roboto
  static const String _fontFamily = 'Inter';
  static const List<String> _fontFamilyFallback = ['Inter', 'Roboto'];

  // ═══════════════════════════════════════════════════════════════
  // DISPLAY - Titres très grands (Hero sections, Landing)
  // ═══════════════════════════════════════════════════════════════
  
  /// Display Extra Large - 40px / Bold
  static const TextStyle displayXL = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Display Large - 36px / Bold
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Display Medium - 32px / Bold
  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Display Small - 28px / Bold
  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );

  // ═══════════════════════════════════════════════════════════════
  // HEADLINE - Titres de section (H1, H2, H3)
  // ═══════════════════════════════════════════════════════════════
  
  /// Headline Large (H1) - 28px / Bold
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Headline Large - 24px / Bold
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Headline Medium (H2) - 22px / SemiBold
  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Headline Medium - 20px / SemiBold
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Headline Small (H3) - 18px / SemiBold
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Headline Small - 18px / SemiBold
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );

  // ═══════════════════════════════════════════════════════════════
  // TITLE - Titres de cartes et sous-sections (Material 3)
  // ═══════════════════════════════════════════════════════════════
  
  /// Title Large - 20px / SemiBold (Material 3)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Title Medium - 18px / SemiBold (Material 3)
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Title Small - 14px / SemiBold
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );

  // ═══════════════════════════════════════════════════════════════
  // SUBTITLE - Sous-titres
  // ═══════════════════════════════════════════════════════════════
  
  /// Subtitle Large - 16px / Medium
  static const TextStyle subtitleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
  );
  
  /// Subtitle Medium - 14px / Medium
  static const TextStyle subtitleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
  );
  
  /// Subtitle Small - 12px / Medium
  static const TextStyle subtitleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
  );

  // ═══════════════════════════════════════════════════════════════
  // BODY - Corps de texte (Material 3)
  // ═══════════════════════════════════════════════════════════════
  
  /// Body Large - 16px / Regular (Material 3)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Body Large Medium - 16px / Medium
  static const TextStyle bodyLargeMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Body Medium - 14px / Regular (Material 3)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Body Medium SemiBold - 14px / SemiBold
  static const TextStyle bodyMediumSemiBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Body Small - 12px / Regular
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
  );
  
  /// Body Small Medium - 12px / Medium
  static const TextStyle bodySmallMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
  );

  // ═══════════════════════════════════════════════════════════════
  // LABEL - Labels de formulaire, boutons, badges (Material 3)
  // ═══════════════════════════════════════════════════════════════
  
  /// Label Large - 14px / Medium (Material 3)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    fontFamily: _fontFamily,
  );
  
  /// Label Medium - 13px / Medium (Material 3)
  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
  );
  
  /// Label Small - 11px / Medium (Material 3)
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
    fontFamily: _fontFamily,
  );

  // ═══════════════════════════════════════════════════════════════
  // CAPTION - Texte très petit
  // ═══════════════════════════════════════════════════════════════
  
  /// Caption Large - 12px / Regular
  static const TextStyle captionLarge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textTertiary,
    fontFamily: _fontFamily,
  );
  
  /// Caption Medium - 11px / Regular
  static const TextStyle captionMedium = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textTertiary,
    fontFamily: _fontFamily,
  );
  
  /// Caption Small - 10px / Regular
  static const TextStyle captionSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.3,
    letterSpacing: 0.3,
    color: AppColors.textTertiary,
    fontFamily: _fontFamily,
  );

  // ═══════════════════════════════════════════════════════════════
  // BUTTON - Styles spécifiques aux boutons
  // ═══════════════════════════════════════════════════════════════
  
  /// Button Large - 16px / SemiBold
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.4,
    fontFamily: _fontFamily,
  );
  
  /// Button Medium - 15px / SemiBold
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.4,
    fontFamily: _fontFamily,
  );
  
  /// Button Small - 14px / SemiBold
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.3,
    fontFamily: _fontFamily,
  );

  // ═══════════════════════════════════════════════════════════════
  // PRICE - Styles pour les prix
  // ═══════════════════════════════════════════════════════════════
  
  /// Price Extra Large - 24px / Bold
  static const TextStyle priceXL = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.primary,
    fontFamily: _fontFamily,
  );
  
  /// Price Large - 20px / Bold
  static const TextStyle priceLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.primary,
    fontFamily: _fontFamily,
  );
  
  /// Price Medium - 16px / Bold
  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.primary,
    fontFamily: _fontFamily,
  );
  
  /// Price Small - 14px / SemiBold
  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.primary,
    fontFamily: _fontFamily,
  );

  // ═══════════════════════════════════════════════════════════════
  // HELPERS - Méthodes utilitaires
  // ═══════════════════════════════════════════════════════════════
  
  /// Créer une variante avec une couleur différente
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Créer une variante avec un poids différent
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// Créer une variante avec une taille différente
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
