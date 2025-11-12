// lib/src/theme/app_theme.dart
// Pizza Deli'Zza Visual Identity - Système de design centralisé
// refactor: centralisation complète du design system → app_theme standard

import 'package:flutter/material.dart';

/// Classe centralisée pour toutes les couleurs de l'application
class AppColors {
  // === CHARTE VISUELLE OFFICIELLE Pizza Deli'Zza ===
  // Palette rouge/blanc moderne et minimaliste
  static const Color primaryRed = Color(0xFFB00020);        // Rouge profond #B00020 (OFFICIEL)
  static const Color primaryRedLight = Color(0xFFE53935);   // Rouge clair #E53935 (OFFICIEL)
  static const Color primaryRedDark = Color(0xFF8E0000);    // Rouge foncé pour ombres
  
  // Couleurs neutres
  static const Color surfaceWhite = Color(0xFFFFFFFF);      // Blanc pur #FFFFFF (OFFICIEL)
  static const Color backgroundLight = Color(0xFFF5F5F5);   // Gris très clair #F5F5F5 (OFFICIEL)
  static const Color textDark = Color(0xFF212121);          // Noir/gris foncé #212121 (OFFICIEL)
  static const Color textMedium = Color(0xFF666666);        // Gris moyen
  static const Color textLight = Color(0xFF999999);         // Gris clair
  
  // Accent colors
  static const Color accentGold = Color(0xFFFFD700);        // Gold accent
  static const Color accentGreen = Color(0xFF4CAF50);       // Green accent
  
  // Status Colors uniquement (pas d'accents orange/jaune)
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);     // Réservé uniquement aux alertes
  static const Color infoBlue = Color(0xFF2196F3);
  
  // MaterialColor pour le theme
  static const MaterialColor primaryRedSwatch = MaterialColor(
    0xFFB00020,
    <int, Color>{
      50: Color(0xFFFFEBEE),
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(0xFFB00020),  // Couleur principale officielle
      600: Color(0xFFE53935),
      700: Color(0xFFD32F2F),
      800: Color(0xFFB00020),
      900: Color(0xFF8E0000),
    },
  );
}

/// Classe centralisée pour tous les styles de texte
class AppTextStyles {
  // Grands titres
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: -0.5,
    fontFamily: 'Poppins',
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: -0.3,
    fontFamily: 'Poppins',
  );
  
  // Titres de section
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );
  
  // Titres de cartes
  static const TextStyle titleLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    fontFamily: 'Poppins',
  );
  
  // Corps de texte
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    height: 1.5,
    fontFamily: 'Poppins',
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textMedium,
    height: 1.5,
    fontFamily: 'Poppins',
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    height: 1.4,
    fontFamily: 'Poppins',
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    letterSpacing: 0.3,
    fontFamily: 'Poppins',
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMedium,
    letterSpacing: 0.3,
    fontFamily: 'Poppins',
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textLight,
    letterSpacing: 0.3,
    fontFamily: 'Poppins',
  );
  
  // Boutons
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    fontFamily: 'Poppins',
  );
  
  // Prix
  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryRed,
    fontFamily: 'Poppins',
  );
  
  static const TextStyle priceLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryRed,
    fontFamily: 'Poppins',
  );
}

/// Classe centralisée pour tous les espacements (marges et paddings)
class AppSpacing {
  // Espacements standard
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  
  // EdgeInsets prédéfinis
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXXXL = EdgeInsets.all(xxxl);
  
  // Padding horizontal
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets paddingHorizontalXXL = EdgeInsets.symmetric(horizontal: xxl);
  
  // Padding vertical
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);
  
  // Padding pour boutons (standardisé pour 44-48px de hauteur)
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: xxl, vertical: 15);  // ~48px total
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(horizontal: lg, vertical: 12); // ~44px total
  
  // Padding pour cartes
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(xxl);
  
  // Padding pour écrans
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets screenPaddingLarge = EdgeInsets.all(xxl);
}

/// Classe centralisée pour tous les radius (coins arrondis)
class AppRadius {
  // Radius standard
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  
  // BorderRadius prédéfinis
  static final BorderRadius radiusXS = BorderRadius.circular(xs);
  static final BorderRadius radiusSM = BorderRadius.circular(sm);
  static final BorderRadius radiusMD = BorderRadius.circular(md);
  static final BorderRadius radiusLG = BorderRadius.circular(lg);
  static final BorderRadius radiusXL = BorderRadius.circular(xl);
  static final BorderRadius radiusXXL = BorderRadius.circular(xxl);
  
  // BorderRadius pour cartes (8px standard)
  static final BorderRadius card = BorderRadius.circular(sm);
  static final BorderRadius cardLarge = BorderRadius.circular(lg);
  
  // BorderRadius pour boutons (24px standard)
  static final BorderRadius button = BorderRadius.circular(md);
  static final BorderRadius buttonLarge = BorderRadius.circular(xxl);
  
  // BorderRadius pour inputs
  static final BorderRadius input = BorderRadius.circular(md);
  
  // BorderRadius pour badges
  static final BorderRadius badge = BorderRadius.circular(sm);
}

/// Classe centralisée pour toutes les ombres
class AppShadows {
  // Ombre douce (soft)
  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Ombre moyenne
  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Ombre profonde (deep)
  static List<BoxShadow> deep = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  // Ombre avec couleur rouge (pour éléments primaires)
  static List<BoxShadow> primary = [
    BoxShadow(
      color: AppColors.primaryRed.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Ombre pour cartes
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // Ombre pour éléments flottants
  static List<BoxShadow> floating = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppTheme {
  // Rétrocompatibilité: Aliases vers AppColors
  static const Color primaryRed = AppColors.primaryRed;
  static const Color primaryRedLight = AppColors.primaryRedLight;
  static const Color primaryRedDark = AppColors.primaryRedDark;
  static const Color surfaceWhite = AppColors.surfaceWhite;
  static const Color backgroundLight = AppColors.backgroundLight;
  static const Color textDark = AppColors.textDark;
  static const Color textMedium = AppColors.textMedium;
  static const Color textLight = AppColors.textLight;
  static const Color accentGold = AppColors.accentGold;
  static const Color accentGreen = AppColors.accentGreen;
  static const Color successGreen = AppColors.successGreen;
  static const Color errorRed = AppColors.errorRed;
  static const Color warningOrange = AppColors.warningOrange;
  static const Color infoBlue = AppColors.infoBlue;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // === Color Scheme Pizza Deli'Zza ===
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryRed,
        primary: AppColors.primaryRed,
        secondary: AppColors.primaryRedLight,
        tertiary: AppColors.accentGold,
        surface: AppColors.surfaceWhite,
        background: AppColors.backgroundLight,
        error: AppColors.errorRed,
        brightness: Brightness.light,
      ),
      
      scaffoldBackgroundColor: AppColors.backgroundLight,
      
      // === AppBar Theme - Fixed Red Header ===
      // En-tête rouge fixe avec logo centré pour client
      // En-tête rouge avec logo et bouton déconnexion pour admin
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.primaryRed,
        foregroundColor: AppColors.surfaceWhite,
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.surfaceWhite,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.surfaceWhite,
          size: 24,
        ),
      ),
      
      // === Card Theme - Cartes produits arrondies ===
      // Cartes avec ombres douces et coins arrondis (8px radius standard)
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
        clipBehavior: Clip.antiAlias,
        color: AppColors.surfaceWhite,
      ),
      
      // === Button Themes - Boutons arrondis rouges (24px radius standard) ===
      // Bouton principal rouge avec coins arrondis
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.surfaceWhite,
          elevation: 2,
          shadowColor: AppColors.primaryRed.withOpacity(0.3),
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // Bouton secondaire transparent
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          padding: AppSpacing.buttonPaddingSmall,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTextStyles.titleSmall,
        ),
      ),
      
      // Bouton avec bordure rouge
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryRed,
          side: const BorderSide(color: AppColors.primaryRed, width: 1.5),
          padding: AppSpacing.buttonPadding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      
      // === Bottom Navigation Bar - Non utilisé pour le fixed cart bar ===
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      
      // === Input Decoration Theme - Champs de formulaire ===
      // Champs arrondis avec label au-dessus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: AppSpacing.paddingLG,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        labelStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textMedium,
        ),
        floatingLabelStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.primaryRed,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // === Snackbar / Alertes - Fond rouge clair + texte blanc ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryRed,
        contentTextStyle: AppTextStyles.titleSmall.copyWith(
          color: AppColors.surfaceWhite,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.button,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 3,
      ),
      
      // === Typography - Police Poppins (ou Nunito) ===
      // Hiérarchie typographique claire avec Poppins via AppTextStyles
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
      ),
      
      // Famille de police par défaut
      fontFamily: 'Poppins',
    );
  }
}
