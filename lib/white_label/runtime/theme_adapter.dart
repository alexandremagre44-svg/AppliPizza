/// lib/white_label/runtime/theme_adapter.dart
///
/// Adapter pour convertir la configuration de thème WhiteLabel
/// vers le système de thème de l'application client.
///
/// Phase 4: Intégration du thème WhiteLabel dans l'application client.
library;

import 'package:flutter/material.dart';
import '../../src/design_system/app_theme.dart';
import '../modules/appearance/theme/theme_module_config.dart';
import '../restaurant/restaurant_plan_unified.dart';

/// Adapter pour convertir la configuration de thème WhiteLabel
/// vers le ThemeData de l'application Flutter.
class ThemeAdapter {
  /// Convertit une ThemeModuleConfig en ThemeData Flutter.
  ///
  /// Cette fonction lit les paramètres du module thème depuis
  /// le RestaurantPlanUnified et génère un ThemeData complet.
  ///
  /// Paramètres supportés dans config.settings:
  /// - `primaryColor` (String hex): Couleur principale
  /// - `secondaryColor` (String hex): Couleur secondaire
  /// - `accentColor` (String hex): Couleur d'accent
  /// - `backgroundColor` (String hex): Couleur de fond
  /// - `surfaceColor` (String hex): Couleur de surface
  /// - `errorColor` (String hex): Couleur d'erreur
  /// - `fontFamily` (String): Police de caractères
  /// - `borderRadius` (double): Rayon des bordures en pixels
  ///
  /// Exemple d'utilisation:
  /// ```dart
  /// final plan = await loadRestaurantPlan();
  /// if (plan.theme != null && plan.theme!.enabled) {
  ///   final themeData = ThemeAdapter.toAppTheme(plan.theme!);
  ///   MaterialApp(theme: themeData, ...);
  /// }
  /// ```
  static ThemeData toAppTheme(ThemeModuleConfig config) {
    // Extraire les paramètres depuis settings avec valeurs par défaut
    final settings = config.settings;
    
    // Parse colors with fallback to default AppColors
    final primaryColor = _parseColor(
      settings['primaryColor'],
      AppColors.primary,
    );
    final secondaryColor = _parseColor(
      settings['secondaryColor'],
      AppColors.secondary,
    );
    final accentColor = _parseColor(
      settings['accentColor'],
      AppColors.accentGold,
    );
    final backgroundColor = _parseColor(
      settings['backgroundColor'],
      AppColors.background,
    );
    final surfaceColor = _parseColor(
      settings['surfaceColor'],
      AppColors.surface,
    );
    final errorColor = _parseColor(
      settings['errorColor'],
      AppColors.error,
    );
    
    // Parse other parameters
    final fontFamily = settings['fontFamily'] as String? ?? 'Inter';
    final borderRadius = (settings['borderRadius'] as num?)?.toDouble() ?? 12.0;
    
    // Compute contrast colors for text
    final onPrimary = _contrastColor(primaryColor);
    final onSecondary = _contrastColor(secondaryColor);
    final onBackground = _contrastColor(backgroundColor);
    final onSurface = _contrastColor(surfaceColor);
    final onError = _contrastColor(errorColor);
    
    // Build Material 3 ThemeData
    return ThemeData(
      useMaterial3: true,
      
      // === Color Scheme ===
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: onPrimary,
        primaryContainer: primaryColor.withOpacity(0.12),
        onPrimaryContainer: primaryColor,
        secondary: secondaryColor,
        onSecondary: onSecondary,
        secondaryContainer: secondaryColor.withOpacity(0.12),
        onSecondaryContainer: secondaryColor,
        tertiary: accentColor,
        onTertiary: _contrastColor(accentColor),
        surface: surfaceColor,
        onSurface: onSurface,
        onSurfaceVariant: onSurface.withOpacity(0.7),
        error: errorColor,
        onError: onError,
        errorContainer: errorColor.withOpacity(0.12),
        onErrorContainer: errorColor,
        outline: Colors.grey.shade400,
        outlineVariant: Colors.grey.shade200,
        shadow: Colors.black,
        scrim: Colors.black54,
        brightness: Brightness.light,
      ),
      
      // === Background ===
      scaffoldBackgroundColor: backgroundColor,
      canvasColor: surfaceColor,
      
      // === AppBar Theme ===
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onPrimary,
        ),
        iconTheme: IconThemeData(color: onPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: onPrimary, size: 24),
      ),
      
      // === Card Theme ===
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius + 4),
        ),
        clipBehavior: Clip.antiAlias,
        color: surfaceColor,
        margin: EdgeInsets.zero,
      ),
      
      // === Button Themes ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          elevation: 0,
          shadowColor: primaryColor.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: Colors.grey.shade400),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
      
      // === Input Decoration Theme ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.grey.shade600,
        ),
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.grey.shade500,
        ),
      ),
      
      // === Bottom Navigation Bar ===
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      
      // === Dialog Theme ===
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius * 2),
        ),
      ),
      
      // === Snackbar Theme ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey.shade900,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // === Chip Theme ===
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: primaryColor.withOpacity(0.12),
        labelStyle: TextStyle(fontFamily: fontFamily),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      
      // === Divider Theme ===
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
      
      // === Typography ===
      fontFamily: fontFamily,
      fontFamilyFallback: const ['Roboto', 'sans-serif'],
      
      // === Colors ===
      splashColor: primaryColor.withOpacity(0.1),
      highlightColor: primaryColor.withOpacity(0.05),
      hoverColor: Colors.grey.shade50,
      focusColor: primaryColor.withOpacity(0.1),
      disabledColor: Colors.grey.shade400,
    );
  }
  
  /// Retourne un thème par défaut basé sur le templateId.
  ///
  /// Cette fonction génère un thème adapté au template sélectionné
  /// lorsque le module thème n'est pas activé.
  ///
  /// Templates supportés:
  /// - `classic`: Thème rouge classique (défaut)
  /// - `modern`: Thème bleu moderne
  /// - `elegant`: Thème or élégant
  /// - `fresh`: Thème vert frais
  ///
  /// Exemple:
  /// ```dart
  /// final plan = await loadRestaurantPlan();
  /// if (plan.theme == null || !plan.theme!.enabled) {
  ///   final themeData = ThemeAdapter.defaultThemeForTemplate(plan.templateId ?? 'classic');
  ///   MaterialApp(theme: themeData, ...);
  /// }
  /// ```
  static ThemeData defaultThemeForTemplate(String? templateId) {
    // Si pas de template spécifié, utiliser le thème legacy
    if (templateId == null || templateId.isEmpty) {
      return AppTheme.lightTheme;
    }
    
    // Générer un thème basé sur le template
    switch (templateId.toLowerCase()) {
      case 'modern':
        return _buildTemplateTheme(
          primary: const Color(0xFF1976D2), // Blue
          secondary: const Color(0xFF424242), // Dark gray
          accent: const Color(0xFFFFC107), // Amber
          templateId: 'modern',
        );
      
      case 'elegant':
        return _buildTemplateTheme(
          primary: const Color(0xFFB8860B), // Dark golden
          secondary: const Color(0xFF5D4037), // Brown
          accent: const Color(0xFFFFD700), // Gold
          templateId: 'elegant',
        );
      
      case 'fresh':
        return _buildTemplateTheme(
          primary: const Color(0xFF43A047), // Green
          secondary: const Color(0xFF66BB6A), // Light green
          accent: const Color(0xFFFFA726), // Orange
          templateId: 'fresh',
        );
      
      case 'classic':
      default:
        // Utiliser le thème legacy (rouge classique)
        return AppTheme.lightTheme;
    }
  }
  
  /// Construit un thème basé sur des couleurs de template.
  static ThemeData _buildTemplateTheme({
    required Color primary,
    required Color secondary,
    required Color accent,
    required String templateId,
  }) {
    return toAppTheme(
      ThemeModuleConfig(
        enabled: true,
        settings: {
          'primaryColor': _colorToHex(primary),
          'secondaryColor': _colorToHex(secondary),
          'accentColor': _colorToHex(accent),
          'backgroundColor': '#FAFAFA',
          'surfaceColor': '#FFFFFF',
          'errorColor': '#C62828',
          'fontFamily': 'Inter',
          'borderRadius': 12.0,
        },
      ),
    );
  }
  
  /// Parse une couleur depuis un format hex string.
  ///
  /// Formats supportés:
  /// - `#RRGGBB` (6 caractères hex)
  /// - `#AARRGGBB` (8 caractères hex avec alpha)
  /// - `RRGGBB` (sans #)
  ///
  /// Retourne [fallback] si le parsing échoue.
  static Color _parseColor(dynamic value, Color fallback) {
    if (value == null) return fallback;
    
    // Vérifier que la valeur est un type simple (String ou num)
    // pour éviter des conversions toString() inattendues
    if (value is! String && value is! num) {
      return fallback;
    }
    
    try {
      String hexString = value.toString().trim();
      
      // Retirer le # si présent
      if (hexString.startsWith('#')) {
        hexString = hexString.substring(1);
      }
      
      // Vérifier la longueur
      if (hexString.length == 6) {
        // Format RRGGBB → AARRGGBB (ajouter alpha FF)
        hexString = 'FF$hexString';
      } else if (hexString.length != 8) {
        // Format invalide
        return fallback;
      }
      
      // Parser en int
      final intValue = int.parse(hexString, radix: 16);
      return Color(intValue);
    } catch (e) {
      // Parsing échoué, utiliser la couleur de fallback
      return fallback;
    }
  }
  
  /// Convertit une couleur en string hex.
  /// 
  /// Convertit une Color Flutter en format hex "#RRGGBB".
  /// - toRadixString(16): Convertit en hexadécimal
  /// - padLeft(8, '0'): Assure le format AARRGGBB (8 caractères)
  /// - substring(2): Retire le composant alpha (AA) pour obtenir RRGGBB
  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
  
  /// Calcule la couleur de contraste (noir ou blanc) pour un fond donné.
  ///
  /// Utilise la luminance pour déterminer si le texte doit être noir ou blanc
  /// pour assurer une bonne lisibilité sur le fond donné.
  static Color _contrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
