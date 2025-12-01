/// test/white_label/theme_integration_test.dart
///
/// Tests d'intégration pour la Phase 4 - Intégration du thème WhiteLabel.
///
/// Ces tests vérifient que le système de thème WhiteLabel fonctionne
/// correctement dans tous les cas de figure.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/white_label/runtime/theme_adapter.dart';
import 'package:pizza_delizza/white_label/modules/appearance/theme/theme_module_config.dart';
import 'package:pizza_delizza/src/design_system/app_theme.dart';

void main() {
  group('ThemeAdapter - Color Parsing', () {
    test('parse couleur hex avec #', () {
      final color = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#FF5733',
          },
        ),
      );
      
      // Vérifier que la couleur primaire a été parsée correctement
      expect(color.colorScheme.primary.value, equals(0xFFFF5733));
    });
    
    test('parse couleur hex sans #', () {
      final color = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': 'FF5733',
          },
        ),
      );
      
      expect(color.colorScheme.primary.value, equals(0xFFFF5733));
    });
    
    test('parse couleur hex avec alpha', () {
      final color = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#80FF5733',
          },
        ),
      );
      
      expect(color.colorScheme.primary.value, equals(0x80FF5733));
    });
    
    test('fallback sur couleur par défaut si parsing échoue', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': 'invalid_color',
          },
        ),
      );
      
      // Doit fallback sur AppColors.primary
      expect(theme.colorScheme.primary, equals(AppColors.primary));
    });
    
    test('fallback sur couleur par défaut si valeur null', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {}, // Pas de primaryColor
        ),
      );
      
      expect(theme.colorScheme.primary, equals(AppColors.primary));
    });
  });
  
  group('ThemeAdapter - Theme Configuration', () {
    test('applique toutes les couleurs du config', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#D32F2F',
            'secondaryColor': '#8E4C4C',
            'accentColor': '#FFD700',
            'backgroundColor': '#FAFAFA',
            'surfaceColor': '#FFFFFF',
            'errorColor': '#C62828',
          },
        ),
      );
      
      expect(theme.colorScheme.primary.value, equals(0xFFD32F2F));
      expect(theme.colorScheme.secondary.value, equals(0xFF8E4C4C));
      expect(theme.colorScheme.tertiary.value, equals(0xFFFFD700));
      expect(theme.scaffoldBackgroundColor.value, equals(0xFFFAFAFA));
      expect(theme.colorScheme.surface.value, equals(0xFFFFFFFF));
      expect(theme.colorScheme.error.value, equals(0xFFC62828));
    });
    
    test('applique la font family', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'fontFamily': 'Roboto',
          },
        ),
      );
      
      expect(theme.fontFamily, equals('Roboto'));
    });
    
    test('applique le border radius', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'borderRadius': 16.0,
          },
        ),
      );
      
      // Vérifier que le radius est appliqué aux boutons
      final buttonStyle = theme.elevatedButtonTheme.style;
      final shape = buttonStyle?.shape?.resolve({}) as RoundedRectangleBorder?;
      final radius = shape?.borderRadius as BorderRadius?;
      
      expect(radius?.topLeft.x, equals(16.0));
    });
    
    test('utilise valeurs par défaut si paramètres absents', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {}, // Config vide
        ),
      );
      
      // Vérifier les valeurs par défaut
      expect(theme.fontFamily, equals('Inter'));
      expect(theme.colorScheme.primary, equals(AppColors.primary));
    });
  });
  
  group('ThemeAdapter - Template Themes', () {
    test('classic template retourne le thème legacy', () {
      final theme = ThemeAdapter.defaultThemeForTemplate('classic');
      
      // Le thème classic doit être identique au thème legacy
      expect(theme.colorScheme.primary, equals(AppTheme.lightTheme.colorScheme.primary));
    });
    
    test('modern template utilise des couleurs bleues', () {
      final theme = ThemeAdapter.defaultThemeForTemplate('modern');
      
      // Vérifier que c'est bien un thème bleu
      expect(theme.colorScheme.primary.value, equals(0xFF1976D2));
    });
    
    test('elegant template utilise des couleurs dorées', () {
      final theme = ThemeAdapter.defaultThemeForTemplate('elegant');
      
      // Vérifier que c'est bien un thème doré
      expect(theme.colorScheme.primary.value, equals(0xFFB8860B));
    });
    
    test('fresh template utilise des couleurs vertes', () {
      final theme = ThemeAdapter.defaultThemeForTemplate('fresh');
      
      // Vérifier que c'est bien un thème vert
      expect(theme.colorScheme.primary.value, equals(0xFF43A047));
    });
    
    test('template null retourne le thème legacy', () {
      final theme = ThemeAdapter.defaultThemeForTemplate(null);
      
      expect(theme.colorScheme.primary, equals(AppTheme.lightTheme.colorScheme.primary));
    });
    
    test('template vide retourne le thème legacy', () {
      final theme = ThemeAdapter.defaultThemeForTemplate('');
      
      expect(theme.colorScheme.primary, equals(AppTheme.lightTheme.colorScheme.primary));
    });
    
    test('template inconnu retourne le thème classic (legacy)', () {
      final theme = ThemeAdapter.defaultThemeForTemplate('unknown_template');
      
      expect(theme.colorScheme.primary, equals(AppTheme.lightTheme.colorScheme.primary));
    });
  });
  
  group('ThemeAdapter - Contrast Colors', () {
    test('calcule blanc sur fond sombre', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#000000', // Noir
          },
        ),
      );
      
      // Sur fond noir, le texte doit être blanc
      expect(theme.colorScheme.onPrimary, equals(Colors.white));
    });
    
    test('calcule noir sur fond clair', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#FFFFFF', // Blanc
          },
        ),
      );
      
      // Sur fond blanc, le texte doit être noir
      expect(theme.colorScheme.onPrimary, equals(Colors.black));
    });
    
    test('calcule contraste correct pour couleurs moyennes', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#FF5733', // Orange/rouge
          },
        ),
      );
      
      // Sur fond orange/rouge, vérifier que le contraste est calculé
      final onPrimary = theme.colorScheme.onPrimary;
      expect(onPrimary == Colors.white || onPrimary == Colors.black, isTrue);
    });
  });
  
  group('ThemeAdapter - Material 3 Components', () {
    test('configure AppBar correctement', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#D32F2F',
          },
        ),
      );
      
      expect(theme.appBarTheme.backgroundColor?.value, equals(0xFFD32F2F));
      expect(theme.appBarTheme.elevation, equals(0));
      expect(theme.appBarTheme.centerTitle, isTrue);
    });
    
    test('configure les boutons correctement', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#D32F2F',
            'borderRadius': 12.0,
          },
        ),
      );
      
      final buttonStyle = theme.elevatedButtonTheme.style;
      expect(buttonStyle?.backgroundColor?.resolve({}), equals(const Color(0xFFD32F2F)));
      expect(buttonStyle?.elevation?.resolve({}), equals(0));
    });
    
    test('configure les inputs correctement', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#D32F2F',
            'surfaceColor': '#FFFFFF',
          },
        ),
      );
      
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.inputDecorationTheme.fillColor?.value, equals(0xFFFFFFFF));
    });
    
    test('configure la bottom navigation bar correctement', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#D32F2F',
            'surfaceColor': '#FFFFFF',
          },
        ),
      );
      
      expect(theme.bottomNavigationBarTheme.backgroundColor?.value, equals(0xFFFFFFFF));
      expect(theme.bottomNavigationBarTheme.selectedItemColor?.value, equals(0xFFD32F2F));
      expect(theme.bottomNavigationBarTheme.type, equals(BottomNavigationBarType.fixed));
    });
  });
  
  group('ThemeAdapter - Edge Cases', () {
    test('gère config avec settings null', () {
      expect(
        () => ThemeAdapter.toAppTheme(
          const ThemeModuleConfig(
            enabled: true,
            settings: {},
          ),
        ),
        returnsNormally,
      );
    });
    
    test('gère types de données invalides gracieusement', () {
      final theme = ThemeAdapter.toAppTheme(
        ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': 12345, // Nombre au lieu de string
            'borderRadius': 'invalid', // String au lieu de nombre
          },
        ),
      );
      
      // Doit utiliser les fallbacks sans crasher
      expect(theme.colorScheme.primary, equals(AppColors.primary));
    });
    
    test('gère config minimal sans crasher', () {
      final theme = ThemeAdapter.toAppTheme(
        const ThemeModuleConfig(enabled: true),
      );
      
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
    });
  });
}
