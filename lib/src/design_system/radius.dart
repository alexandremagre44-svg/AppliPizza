// lib/src/design_system/radius.dart
// Système de radius (coins arrondis) - Design System Pizza Deli'Zza Material 3 (2025)

import 'package:flutter/material.dart';

/// Système de radius Material 3 pour tous les composants
/// 
/// Spécifications Material 3:
/// - Global: 16px
/// - Buttons: 12px
/// - BottomSheets: 24px
/// - Chips: 16px
class AppRadius {
  // ═══════════════════════════════════════════════════════════════
  // RADIUS DE BASE - Valeurs numériques Material 3
  // ═══════════════════════════════════════════════════════════════
  
  /// Extra Small - 4px
  static const double xs = 4.0;
  
  /// Small - 8px
  static const double small = 8.0;
  
  /// Medium - 12px (Standard pour boutons Material 3)
  static const double medium = 12.0;
  
  /// Large - 16px (Global Material 3)
  static const double large = 16.0;
  
  /// Extra Large - 20px
  static const double xl = 20.0;
  
  /// Extra Extra Large - 24px (BottomSheets Material 3)
  static const double xxl = 24.0;
  
  /// Extra Extra Extra Large - 28px (Grande modales)
  static const double xxxl = 28.0;
  
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
  // RADIUS CONTEXTUELS - Material 3
  // ═══════════════════════════════════════════════════════════════
  
  // CARTES
  
  /// Radius standard pour cartes - 16px (Material 3 Global)
  static final BorderRadius card = radiusLarge;
  
  /// Radius pour grandes cartes - 16px
  static final BorderRadius cardLarge = radiusLarge;
  
  /// Radius pour petites cartes - 12px
  static final BorderRadius cardSmall = radiusMedium;
  
  /// Radius pour cartes de section - 16px
  static final BorderRadius cardSection = radiusLarge;
  
  // BOUTONS
  
  /// Radius standard pour boutons - 12px (Material 3)
  static final BorderRadius button = radiusMedium;
  
  /// Radius pour petits boutons - 12px
  static final BorderRadius buttonSmall = radiusMedium;
  
  /// Radius pour grands boutons - 12px
  static final BorderRadius buttonLarge = radiusMedium;
  
  /// Radius pour boutons ronds (icon buttons) - 9999px
  static final BorderRadius buttonRound = radiusFull;
  
  // INPUTS
  
  /// Radius standard pour inputs - 12px (Material 3)
  static final BorderRadius input = radiusMedium;
  
  /// Radius pour petits inputs - 12px
  static final BorderRadius inputSmall = radiusMedium;
  
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
  
  /// Radius pour modales standard - 24px (Material 3)
  static final BorderRadius dialog = radiusXXL;
  
  /// Radius pour grandes modales - 28px
  static final BorderRadius dialogLarge = BorderRadius.circular(xxxl);
  
  /// Radius pour petites modales - 16px
  static final BorderRadius dialogSmall = radiusLarge;
  
  // BOTTOM SHEETS
  
  /// Radius pour BottomSheets - 24px (Material 3)
  static final BorderRadius bottomSheet = radiusXXL;
  
  /// Radius pour grandes BottomSheets - 28px
  static final BorderRadius bottomSheetLarge = BorderRadius.circular(xxxl);
  
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
  
  /// Radius pour snackbars - 12px
  static final BorderRadius snackbar = radiusMedium;
  
  /// Radius pour chips - 16px (Material 3)
  static final BorderRadius chip = radiusLarge;
  
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
