// lib/src/design_system/spacing.dart
// Système d'espacement cohérent - Design System Pizza Deli'Zza Material 3 (2025)

import 'package:flutter/material.dart';

/// Système d'espacement Material 3 basé sur une échelle de 4px
/// 
/// Spécifications Material 3: 4 / 8 / 12 / 16 / 24 / 32
/// Échelle complète: 4, 8, 12, 16, 24, 32, 48, 64, 96
/// Usage: Margins, Paddings, Gaps
class AppSpacing {
  // ═══════════════════════════════════════════════════════════════
  // ESPACEMENT DE BASE - Échelle de 4px
  // ═══════════════════════════════════════════════════════════════
  
  /// Extra Extra Small - 4px
  static const double xxs = 4.0;
  
  /// Extra Small - 8px
  static const double xs = 8.0;
  
  /// Small - 12px
  static const double sm = 12.0;
  
  /// Medium - 16px
  static const double md = 16.0;
  
  /// Large - 24px
  static const double lg = 24.0;
  
  /// Extra Large - 32px
  static const double xl = 32.0;
  
  /// Extra Extra Large - 48px
  static const double xxl = 48.0;
  
  /// Extra Extra Extra Large - 64px
  static const double xxxl = 64.0;
  
  /// Huge - 96px
  static const double huge = 96.0;

  // ═══════════════════════════════════════════════════════════════
  // PADDING - EdgeInsets prédéfinis
  // ═══════════════════════════════════════════════════════════════
  
  /// Padding XXS - 4px tout autour
  static const EdgeInsets paddingXXS = EdgeInsets.all(xxs);
  
  /// Padding XS - 8px tout autour
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  
  /// Padding SM - 12px tout autour
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  
  /// Padding MD - 16px tout autour
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  
  /// Padding LG - 24px tout autour
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  
  /// Padding XL - 32px tout autour
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  /// Padding XXL - 48px tout autour
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);
  
  /// Padding XXXL - 64px tout autour
  static const EdgeInsets paddingXXXL = EdgeInsets.all(xxxl);

  // ═══════════════════════════════════════════════════════════════
  // PADDING HORIZONTAL
  // ═══════════════════════════════════════════════════════════════
  
  /// Padding horizontal XXS - 4px
  static const EdgeInsets paddingHorizontalXXS = EdgeInsets.symmetric(horizontal: xxs);
  
  /// Padding horizontal XS - 8px
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  
  /// Padding horizontal SM - 12px
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  
  /// Padding horizontal MD - 16px
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  
  /// Padding horizontal LG - 24px
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  
  /// Padding horizontal XL - 32px
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);
  
  /// Padding horizontal XXL - 48px
  static const EdgeInsets paddingHorizontalXXL = EdgeInsets.symmetric(horizontal: xxl);

  // ═══════════════════════════════════════════════════════════════
  // PADDING VERTICAL
  // ═══════════════════════════════════════════════════════════════
  
  /// Padding vertical XXS - 4px
  static const EdgeInsets paddingVerticalXXS = EdgeInsets.symmetric(vertical: xxs);
  
  /// Padding vertical XS - 8px
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  
  /// Padding vertical SM - 12px
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  
  /// Padding vertical MD - 16px
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  
  /// Padding vertical LG - 24px
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  
  /// Padding vertical XL - 32px
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);
  
  /// Padding vertical XXL - 48px
  static const EdgeInsets paddingVerticalXXL = EdgeInsets.symmetric(vertical: xxl);

  // ═══════════════════════════════════════════════════════════════
  // PADDING CONTEXTUELS - Pour composants spécifiques
  // ═══════════════════════════════════════════════════════════════
  
  /// Padding pour boutons standard (horizontal: 24, vertical: 14)
  /// Hauteur totale: ~48px avec texte 16px
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: 14,
  );
  
  /// Padding pour petits boutons (horizontal: 16, vertical: 10)
  /// Hauteur totale: ~40px avec texte 14px
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 10,
  );
  
  /// Padding pour grands boutons (horizontal: 32, vertical: 16)
  /// Hauteur totale: ~56px avec texte 16px
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );
  
  /// Padding pour cartes standard
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  
  /// Padding pour grandes cartes
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(lg);
  
  /// Padding pour petites cartes
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(sm);
  
  /// Padding pour inputs/champs de formulaire
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 12,
  );
  
  /// Padding pour inputs compacts
  static const EdgeInsets inputPaddingSmall = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );
  
  /// Padding pour écrans (page principale)
  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  
  /// Padding pour écrans larges (desktop)
  static const EdgeInsets screenPaddingLarge = EdgeInsets.all(lg);
  
  /// Padding pour sections
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );
  
  /// Padding pour sections larges
  static const EdgeInsets sectionPaddingLarge = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: xl,
  );
  
  /// Padding pour modales/dialogs
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);
  
  /// Padding pour header de modales
  static const EdgeInsets dialogHeaderPadding = EdgeInsets.all(lg);
  
  /// Padding pour footer de modales
  static const EdgeInsets dialogFooterPadding = EdgeInsets.all(lg);
  
  /// Padding pour badges
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xxs,
  );
  
  /// Padding pour tags
  static const EdgeInsets tagPadding = EdgeInsets.symmetric(
    horizontal: xs,
    vertical: xxs,
  );
  
  /// Padding pour cellules de tableau
  static const EdgeInsets tableCellPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // ═══════════════════════════════════════════════════════════════
  // GAPS - Pour Row, Column, Wrap, Flex
  // ═══════════════════════════════════════════════════════════════
  
  /// Gap XXS - 4px
  static const double gapXXS = xxs;
  
  /// Gap XS - 8px
  static const double gapXS = xs;
  
  /// Gap SM - 12px
  static const double gapSM = sm;
  
  /// Gap MD - 16px
  static const double gapMD = md;
  
  /// Gap LG - 24px
  static const double gapLG = lg;
  
  /// Gap XL - 32px
  static const double gapXL = xl;
  
  /// Gap XXL - 48px
  static const double gapXXL = xxl;

  // ═══════════════════════════════════════════════════════════════
  // SIZED BOX - Pour espacements rapides
  // ═══════════════════════════════════════════════════════════════
  
  /// Vertical space XXS - 4px
  static const Widget verticalSpaceXXS = SizedBox(height: xxs);
  
  /// Vertical space XS - 8px
  static const Widget verticalSpaceXS = SizedBox(height: xs);
  
  /// Vertical space SM - 12px
  static const Widget verticalSpaceSM = SizedBox(height: sm);
  
  /// Vertical space MD - 16px
  static const Widget verticalSpaceMD = SizedBox(height: md);
  
  /// Vertical space LG - 24px
  static const Widget verticalSpaceLG = SizedBox(height: lg);
  
  /// Vertical space XL - 32px
  static const Widget verticalSpaceXL = SizedBox(height: xl);
  
  /// Vertical space XXL - 48px
  static const Widget verticalSpaceXXL = SizedBox(height: xxl);
  
  /// Horizontal space XXS - 4px
  static const Widget horizontalSpaceXXS = SizedBox(width: xxs);
  
  /// Horizontal space XS - 8px
  static const Widget horizontalSpaceXS = SizedBox(width: xs);
  
  /// Horizontal space SM - 12px
  static const Widget horizontalSpaceSM = SizedBox(width: sm);
  
  /// Horizontal space MD - 16px
  static const Widget horizontalSpaceMD = SizedBox(width: md);
  
  /// Horizontal space LG - 24px
  static const Widget horizontalSpaceLG = SizedBox(width: lg);
  
  /// Horizontal space XL - 32px
  static const Widget horizontalSpaceXL = SizedBox(width: xl);
  
  /// Horizontal space XXL - 48px
  static const Widget horizontalSpaceXXL = SizedBox(width: xxl);

  // ═══════════════════════════════════════════════════════════════
  // RÉTROCOMPATIBILITÉ - Aliases anciens noms
  // ═══════════════════════════════════════════════════════════════
  
  // Note: Les anciennes valeurs lg, xl, xxl existent déjà dans la section ESPACEMENT DE BASE
  // Pas d'aliases nécessaires car les noms sont identiques
}
