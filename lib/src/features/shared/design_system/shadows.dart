// lib/src/design_system/shadows.dart
// Système d'ombres cohérent - Design System Pizza Deli'Zza

import 'package:flutter/material.dart';
import 'colors.dart';

/// Système d'ombres cohérent pour donner de la profondeur
/// 
/// Niveaux: None, Soft, Medium, Strong, Floating
/// Usage: Cartes, Boutons, Modales, Éléments flottants
class AppShadows {
  // ═══════════════════════════════════════════════════════════════
  // OMBRES STANDARD - Niveaux de profondeur
  // ═══════════════════════════════════════════════════════════════
  
  /// Aucune ombre
  static const List<BoxShadow> none = [];
  
  /// Ombre très douce - Pour cartes au repos
  /// Blur: 4px, Offset: (0, 1), Opacity: 0.05
  static final List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre douce - Pour cartes et composants standards
  /// Blur: 8px, Offset: (0, 2), Opacity: 0.08
  static final List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre forte - Pour éléments au hover
  /// Blur: 12px, Offset: (0, 4), Opacity: 0.12
  static final List<BoxShadow> strong = [
    BoxShadow(
      color: AppColors.black.withOpacity(0.12),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre profonde - Pour modales et éléments flottants
  /// Blur: 16px, Offset: (0, 6), Opacity: 0.15
  static final List<BoxShadow> deep = [
    BoxShadow(
      color: AppColors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre flottante - Pour éléments très élevés (FAB, Snackbar)
  /// Blur: 20px, Offset: (0, 8), Opacity: 0.18
  static final List<BoxShadow> floating = [
    BoxShadow(
      color: AppColors.black.withOpacity(0.18),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════
  // OMBRES COLORÉES - Pour éléments avec couleur primaire
  // ═══════════════════════════════════════════════════════════════
  
  /// Ombre rouge douce - Pour boutons primaires au repos
  /// Blur: 8px, Offset: (0, 2), Opacity: 0.2
  static final List<BoxShadow> primary = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre rouge forte - Pour boutons primaires au hover
  /// Blur: 12px, Offset: (0, 4), Opacity: 0.3
  static final List<BoxShadow> primaryStrong = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre verte - Pour éléments de succès
  /// Blur: 8px, Offset: (0, 2), Opacity: 0.2
  static final List<BoxShadow> success = [
    BoxShadow(
      color: AppColors.success.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre orange - Pour éléments d'avertissement
  /// Blur: 8px, Offset: (0, 2), Opacity: 0.2
  static final List<BoxShadow> warning = [
    BoxShadow(
      color: AppColors.warning.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre rouge - Pour éléments de danger
  /// Blur: 8px, Offset: (0, 2), Opacity: 0.2
  static final List<BoxShadow> danger = [
    BoxShadow(
      color: AppColors.danger.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre bleue - Pour éléments d'information
  /// Blur: 8px, Offset: (0, 2), Opacity: 0.2
  static final List<BoxShadow> info = [
    BoxShadow(
      color: AppColors.info.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════
  // OMBRES CONTEXTUELLES - Pour composants spécifiques
  // ═══════════════════════════════════════════════════════════════
  
  /// Ombre pour cartes standard
  static final List<BoxShadow> card = medium;
  
  /// Ombre pour cartes au hover
  static final List<BoxShadow> cardHover = strong;
  
  /// Ombre pour boutons
  static final List<BoxShadow> button = soft;
  
  /// Ombre pour boutons au hover
  static final List<BoxShadow> buttonHover = medium;
  
  /// Ombre pour boutons primaires
  static final List<BoxShadow> buttonPrimary = primary;
  
  /// Ombre pour boutons primaires au hover
  static final List<BoxShadow> buttonPrimaryHover = primaryStrong;
  
  /// Ombre pour modales/dialogs
  static final List<BoxShadow> dialog = deep;
  
  /// Ombre pour éléments flottants (FAB, Snackbar)
  static final List<BoxShadow> fab = floating;
  
  /// Ombre pour AppBar (légère)
  static final List<BoxShadow> appBar = [
    BoxShadow(
      color: AppColors.black.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre pour navigation bar
  static final List<BoxShadow> navBar = [
    BoxShadow(
      color: AppColors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, -2),
      spreadRadius: 0,
    ),
  ];
  
  /// Ombre pour dropdown/menu
  static final List<BoxShadow> dropdown = strong;
  
  /// Ombre pour tooltip
  static final List<BoxShadow> tooltip = medium;

  // ═══════════════════════════════════════════════════════════════
  // OMBRES INTERNES - BoxShadow avec inset (pour TextField focus)
  // ═══════════════════════════════════════════════════════════════
  
  /// Note: Flutter ne supporte pas directement inset shadows via BoxShadow
  /// Pour un effet inset, utiliser des bordures ou des gradients

  // ═══════════════════════════════════════════════════════════════
  // ÉLÉVATION - Conversion Material elevation en shadow
  // ═══════════════════════════════════════════════════════════════
  
  /// Élévation 0 (aucune ombre)
  static const double elevation0 = 0;
  
  /// Élévation 1 (ombre très légère)
  static const double elevation1 = 1;
  
  /// Élévation 2 (ombre légère - cartes)
  static const double elevation2 = 2;
  
  /// Élévation 4 (ombre moyenne - boutons)
  static const double elevation4 = 4;
  
  /// Élévation 6 (ombre forte - AppBar)
  static const double elevation6 = 6;
  
  /// Élévation 8 (ombre profonde - modales)
  static const double elevation8 = 8;
  
  /// Élévation 12 (ombre très profonde - FAB)
  static const double elevation12 = 12;

  // ═══════════════════════════════════════════════════════════════
  // HELPERS - Création d'ombres personnalisées
  // ═══════════════════════════════════════════════════════════════
  
  /// Créer une ombre personnalisée
  static List<BoxShadow> custom({
    required Color color,
    required double blurRadius,
    required Offset offset,
    double spreadRadius = 0,
    double opacity = 1.0,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blurRadius,
        offset: offset,
        spreadRadius: spreadRadius,
      ),
    ];
  }
  
  /// Créer une ombre avec couleur et opacité personnalisées
  static List<BoxShadow> withColor(List<BoxShadow> shadows, Color color) {
    return shadows.map((shadow) {
      return BoxShadow(
        color: color.withOpacity(shadow.color.opacity),
        blurRadius: shadow.blurRadius,
        offset: shadow.offset,
        spreadRadius: shadow.spreadRadius,
      );
    }).toList();
  }
}
