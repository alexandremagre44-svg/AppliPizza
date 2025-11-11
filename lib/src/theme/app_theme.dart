// lib/src/theme/app_theme.dart
// Pizza Deli'Zza Visual Identity - Refonte complète

import 'package:flutter/material.dart';

class AppTheme {
  // === Pizza Deli'Zza Brand Colors ===
  // Palette principale inspirée du style Pizza Hut premium
  static const Color primaryRed = Color(0xFFC62828);        // Rouge principal Pizza Deli'Zza
  static const Color primaryRedLight = Color(0xFFEF5350);   // Rouge clair pour hover/accents
  static const Color primaryRedDark = Color(0xFF8E0000);    // Rouge foncé pour ombres
  
  // Couleurs neutres
  static const Color surfaceWhite = Color(0xFFFFFFFF);      // Blanc pur
  static const Color backgroundLight = Color(0xFFF5F5F5);   // Gris très clair
  static const Color textDark = Color(0xFF222222);          // Noir doux
  static const Color textMedium = Color(0xFF666666);        // Gris moyen
  static const Color textLight = Color(0xFF999999);         // Gris clair
  
  // Couleurs d'accentuation (utilisées avec parcimonie)
  static const Color accentGold = Color(0xFFFFB300);        // Or/jaune pour badges premium
  
  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF2196F3);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // === Color Scheme Pizza Deli'Zza ===
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        primary: primaryRed,
        secondary: primaryRedLight,
        tertiary: accentGold,
        surface: surfaceWhite,
        background: backgroundLight,
        error: errorRed,
        brightness: Brightness.light,
      ),
      
      scaffoldBackgroundColor: backgroundLight,
      
      // === AppBar Theme - Fixed Red Header ===
      // En-tête rouge fixe avec logo centré pour client
      // En-tête rouge avec logo et bouton déconnexion pour admin
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: primaryRed,
        foregroundColor: surfaceWhite,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: surfaceWhite,
          letterSpacing: 0.5,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(
          color: surfaceWhite,
          size: 24,
        ),
      ),
      
      // === Card Theme - Cartes produits arrondies ===
      // Cartes avec ombres douces et coins arrondis
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        color: surfaceWhite,
      ),
      
      // === Button Themes - Boutons arrondis rouges ===
      // Bouton principal rouge avec coins arrondis
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: surfaceWhite,
          elevation: 2,
          shadowColor: primaryRed.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      
      // Bouton secondaire transparent
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryRed,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      
      // Bouton avec bordure rouge
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryRed,
          side: const BorderSide(color: primaryRed, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      
      // === Bottom Navigation Bar - Non utilisé pour le fixed cart bar ===
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceWhite,
        selectedItemColor: primaryRed,
        unselectedItemColor: textLight,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
          fontFamily: 'Poppins',
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      
      // === Input Decoration Theme - Champs de formulaire ===
      // Champs arrondis avec label au-dessus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryRed, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(
          color: textMedium,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryRed,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      
      // === Snackbar / Alertes - Fond rouge clair + texte blanc ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryRed,
        contentTextStyle: const TextStyle(
          color: surfaceWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 3,
      ),
      
      // === Typography - Police Poppins (ou Nunito) ===
      // Hiérarchie typographique claire avec Poppins
      textTheme: const TextTheme(
        // Grands titres
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.5,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.3,
          fontFamily: 'Poppins',
        ),
        // Titres de section
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        // Titres de cartes
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
          fontFamily: 'Poppins',
        ),
        // Corps de texte
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textDark,
          height: 1.5,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textMedium,
          height: 1.5,
          fontFamily: 'Poppins',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textLight,
          height: 1.4,
          fontFamily: 'Poppins',
        ),
        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
          letterSpacing: 0.3,
          fontFamily: 'Poppins',
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textMedium,
          letterSpacing: 0.3,
          fontFamily: 'Poppins',
        ),
      ),
      
      // Famille de police par défaut
      fontFamily: 'Poppins',
    );
  }
}
