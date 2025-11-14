// lib/src/design_system/radius.dart
// Système de radius (coins arrondis) - Design System Pizza Deli'Zza

import 'package:flutter/material.dart';

/// Système de radius cohérent pour tous les composants
/// 
/// Échelle: 4, 8, 12, 16, 20, 24
/// Usage: Cartes, Boutons, Inputs, Badges, Modales
class AppRadius {
  // ═══════════════════════════════════════════════════════════════
  // RADIUS DE BASE - Valeurs numériques
  // ═══════════════════════════════════════════════════════════════
  
  /// Extra Small - 4px
  static const double xs = 4.0;
  
  /// Small - 8px (Standard pour cartes)
  static const double small = 8.0;
  
  /// Medium - 12px (Standard pour boutons et inputs)
  static const double medium = 12.0;
  
  /// Large - 16px (Pour grandes cartes)
  static const double large = 16.0;
  
  /// Extra Large - 20px
  static const double xl = 20.0;
  
  /// Extra Extra Large - 24px
  static const double xxl = 24.0;
  
  /// Circulaire complet - 9999px
  static const double full = 9999.0;

  // ═══════════════════════════════════════════════════════════════
  // BORDER RADIUS - Objets BorderRadius prédéfinis
  // ═══════════════════════════════════════════════════════════════
  
  /// Border radius XS - 4px
  static final BorderRadius radiusXS = BorderRadius.circular(xs);
  
  /// Border radius Small - 8px
  static final BorderRadius radiusSmall = BorderRadius.circular(small);
  
  /// Border radius Medium - 12px
  static final BorderRadius radiusMedium = BorderRadius.circular(medium);
  
  /// Border radius Large - 16px
  static final BorderRadius radiusLarge = BorderRadius.circular(large);
  
  /// Border radius XL - 20px
  static final BorderRadius radiusXL = BorderRadius.circular(xl);
  
  /// Border radius XXL - 24px
  static final BorderRadius radiusXXL = BorderRadius.circular(xxl);
  
  /// Border radius complet (circulaire)
  static final BorderRadius radiusFull = BorderRadius.circular(full);

  // ═══════════════════════════════════════════════════════════════
  // RADIUS CONTEXTUELS - Pour composants spécifiques
  // ═══════════════════════════════════════════════════════════════
  
  // CARTES
  
  /// Radius standard pour cartes - 8px
  static final BorderRadius card = radiusSmall;
  
  /// Radius pour grandes cartes - 12px
  static final BorderRadius cardLarge = radiusMedium;
  
  /// Radius pour petites cartes - 8px
  static final BorderRadius cardSmall = radiusSmall;
  
  /// Radius pour cartes de section - 12px
  static final BorderRadius cardSection = radiusMedium;
  
  // BOUTONS
  
  /// Radius standard pour boutons - 12px
  static final BorderRadius button = radiusMedium;
  
  /// Radius pour petits boutons - 8px
  static final BorderRadius buttonSmall = radiusSmall;
  
  /// Radius pour grands boutons - 16px
  static final BorderRadius buttonLarge = radiusLarge;
  
  /// Radius pour boutons ronds (icon buttons) - 9999px
  static final BorderRadius buttonRound = radiusFull;
  
  // INPUTS
  
  /// Radius standard pour inputs - 12px
  static final BorderRadius input = radiusMedium;
  
  /// Radius pour petits inputs - 8px
  static final BorderRadius inputSmall = radiusSmall;
  
  /// Radius pour grands inputs - 12px
  static final BorderRadius inputLarge = radiusMedium;
  
  // BADGES & TAGS
  
  /// Radius pour badges - 8px
  static final BorderRadius badge = radiusSmall;
  
  /// Radius pour tags - 4px
  static final BorderRadius tag = radiusXS;
  
  /// Radius pour badges ronds - 9999px
  static final BorderRadius badgeRound = radiusFull;
  
  // MODALES & DIALOGS
  
  /// Radius pour modales standard - 16px
  static final BorderRadius dialog = radiusLarge;
  
  /// Radius pour grandes modales - 20px
  static final BorderRadius dialogLarge = radiusXL;
  
  /// Radius pour petites modales - 12px
  static final BorderRadius dialogSmall = radiusMedium;
  
  // IMAGES
  
  /// Radius pour images dans cartes - 8px
  static final BorderRadius image = radiusSmall;
  
  /// Radius pour avatars - 9999px
  static final BorderRadius avatar = radiusFull;
  
  /// Radius pour vignettes d'images - 4px
  static final BorderRadius thumbnail = radiusXS;
  
  // AUTRES
  
  /// Radius pour tooltips - 8px
  static final BorderRadius tooltip = radiusSmall;
  
  /// Radius pour snackbars - 8px
  static final BorderRadius snackbar = radiusSmall;
  
  /// Radius pour chips - 9999px
  static final BorderRadius chip = radiusFull;
  
  /// Radius pour tabs - 12px en haut uniquement
  static const BorderRadius tab = BorderRadius.only(
    topLeft: Radius.circular(medium),
    topRight: Radius.circular(medium),
  );

  // ═══════════════════════════════════════════════════════════════
  // RADIUS DIRECTIONNELS - Pour coins spécifiques
  // ═══════════════════════════════════════════════════════════════
  
  /// Radius haut uniquement - 12px
  static const BorderRadius topMedium = BorderRadius.only(
    topLeft: Radius.circular(medium),
    topRight: Radius.circular(medium),
  );
  
  /// Radius haut uniquement - 16px
  static const BorderRadius topLarge = BorderRadius.only(
    topLeft: Radius.circular(large),
    topRight: Radius.circular(large),
  );
  
  /// Radius bas uniquement - 12px
  static const BorderRadius bottomMedium = BorderRadius.only(
    bottomLeft: Radius.circular(medium),
    bottomRight: Radius.circular(medium),
  );
  
  /// Radius bas uniquement - 16px
  static const BorderRadius bottomLarge = BorderRadius.only(
    bottomLeft: Radius.circular(large),
    bottomRight: Radius.circular(large),
  );
  
  /// Radius gauche uniquement - 12px
  static const BorderRadius leftMedium = BorderRadius.only(
    topLeft: Radius.circular(medium),
    bottomLeft: Radius.circular(medium),
  );
  
  /// Radius droite uniquement - 12px
  static const BorderRadius rightMedium = BorderRadius.only(
    topRight: Radius.circular(medium),
    bottomRight: Radius.circular(medium),
  );

  // ═══════════════════════════════════════════════════════════════
  // RÉTROCOMPATIBILITÉ - Aliases anciens noms
  // ═══════════════════════════════════════════════════════════════
  
  @Deprecated('Use AppRadius.small instead')
  static const double sm = small;
  
  @Deprecated('Use AppRadius.medium instead')
  static const double md = medium;
  
  @Deprecated('Use AppRadius.large instead')
  static const double lg = large;
  
  @Deprecated('Use AppRadius.radiusSmall instead')
  static final BorderRadius radiusSM = radiusSmall;
  
  @Deprecated('Use AppRadius.radiusMedium instead')
  static final BorderRadius radiusMD = radiusMedium;
  
  @Deprecated('Use AppRadius.radiusLarge instead')
  static final BorderRadius radiusLG = radiusLarge;
}
