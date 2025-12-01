/// test/white_label/theme_provider_integration_test.dart
///
/// Tests d'intégration pour le unifiedThemeProvider.
///
/// Ces tests vérifient que le provider retourne le bon thème dans chaque situation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizza_delizza/src/providers/theme_providers.dart';
import 'package:pizza_delizza/src/providers/restaurant_plan_provider.dart';
import 'package:pizza_delizza/src/design_system/app_theme.dart';
import 'package:pizza_delizza/white_label/restaurant/restaurant_plan_unified.dart';
import 'package:pizza_delizza/white_label/modules/appearance/theme/theme_module_config.dart';

void main() {
  group('unifiedThemeProvider Integration', () {
    test('retourne le thème legacy quand aucun plan n\'est disponible', () {
      final container = ProviderContainer(
        overrides: [
          // Simuler l'absence de plan
          restaurantPlanUnifiedProvider.overrideWith(
            (ref) => Future.value(null),
          ),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(unifiedThemeProvider);

      // Doit retourner le thème legacy
      expect(theme.colorScheme.primary, equals(AppTheme.lightTheme.colorScheme.primary));
    });

    test('retourne le thème du template quand le module thème est désactivé', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        templateId: 'modern',
        activeModules: ['ordering'],
        theme: const ThemeModuleConfig(
          enabled: false, // Module désactivé
          settings: {},
        ),
      );

      final container = ProviderContainer(
        overrides: [
          restaurantPlanUnifiedProvider.overrideWith(
            (ref) => Future.value(plan),
          ),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(unifiedThemeProvider);

      // Doit retourner le thème "modern" (bleu)
      expect(theme.colorScheme.primary.value, equals(0xFF1976D2));
    });

    test('retourne le thème WhiteLabel quand le module thème est activé', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        templateId: 'classic',
        activeModules: ['ordering', 'theme'],
        theme: const ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#FF5733',
            'secondaryColor': '#C70039',
            'fontFamily': 'Roboto',
          },
        ),
      );

      final container = ProviderContainer(
        overrides: [
          restaurantPlanUnifiedProvider.overrideWith(
            (ref) => Future.value(plan),
          ),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(unifiedThemeProvider);

      // Doit retourner le thème WhiteLabel avec la couleur personnalisée
      expect(theme.colorScheme.primary.value, equals(0xFFFF5733));
      expect(theme.colorScheme.secondary.value, equals(0xFFC70039));
      expect(theme.fontFamily, equals('Roboto'));
    });

    test('retourne le thème du template quand le module thème est null', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        templateId: 'elegant',
        activeModules: ['ordering'],
        theme: null, // Pas de config thème
      );

      final container = ProviderContainer(
        overrides: [
          restaurantPlanUnifiedProvider.overrideWith(
            (ref) => Future.value(plan),
          ),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(unifiedThemeProvider);

      // Doit retourner le thème "elegant" (doré)
      expect(theme.colorScheme.primary.value, equals(0xFFB8860B));
    });

    test('retourne le thème legacy quand le templateId est null', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        templateId: null,
        activeModules: ['ordering'],
        theme: null,
      );

      final container = ProviderContainer(
        overrides: [
          restaurantPlanUnifiedProvider.overrideWith(
            (ref) => Future.value(plan),
          ),
        ],
      );
      addTearDown(container.dispose);

      final theme = container.read(unifiedThemeProvider);

      // Doit retourner le thème legacy
      expect(theme.colorScheme.primary, equals(AppTheme.lightTheme.colorScheme.primary));
    });

    test('supporte les changements de plan dynamiques', () {
      // Premier plan avec thème moderne
      final plan1 = RestaurantPlanUnified(
        restaurantId: 'test123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        templateId: 'modern',
        activeModules: ['ordering'],
      );

      // Deuxième plan avec thème personnalisé
      final plan2 = RestaurantPlanUnified(
        restaurantId: 'test123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        templateId: 'modern',
        activeModules: ['ordering', 'theme'],
        theme: const ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': '#00FF00',
          },
        ),
      );

      final planStateProvider = StateProvider<RestaurantPlanUnified?>((ref) => plan1);

      final container = ProviderContainer(
        overrides: [
          restaurantPlanUnifiedProvider.overrideWith(
            (ref) => Future.value(ref.watch(planStateProvider)),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Vérifier le premier thème (modern)
      var theme = container.read(unifiedThemeProvider);
      expect(theme.colorScheme.primary.value, equals(0xFF1976D2));

      // Changer le plan
      container.read(planStateProvider.notifier).state = plan2;

      // Le thème devrait se mettre à jour avec la nouvelle couleur
      theme = container.read(unifiedThemeProvider);
      expect(theme.colorScheme.primary.value, equals(0xFF00FF00));
    });
  });

  group('unifiedThemeProvider - Cas d\'erreur', () {
    test('gère un plan avec une configuration invalide sans crasher', () {
      final plan = RestaurantPlanUnified(
        restaurantId: 'test123',
        name: 'Test Restaurant',
        slug: 'test-restaurant',
        templateId: 'modern',
        activeModules: ['ordering', 'theme'],
        theme: const ThemeModuleConfig(
          enabled: true,
          settings: {
            'primaryColor': 'invalid_color_value',
            'borderRadius': 'not_a_number',
          },
        ),
      );

      final container = ProviderContainer(
        overrides: [
          restaurantPlanUnifiedProvider.overrideWith(
            (ref) => Future.value(plan),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        () => container.read(unifiedThemeProvider),
        returnsNormally,
      );

      // Vérifie que le thème retourné est valide avec des fallbacks
      final theme = container.read(unifiedThemeProvider);
      expect(theme, isA<ThemeData>());
      expect(theme.useMaterial3, isTrue);
    });

    test('gère un AsyncValue en état d\'erreur', () {
      final container = ProviderContainer(
        overrides: [
          restaurantPlanUnifiedProvider.overrideWith(
            (ref) => Future.error(Exception('Network error')),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Doit retourner le thème legacy même en cas d'erreur
      final theme = container.read(unifiedThemeProvider);
      expect(theme.colorScheme.primary, equals(AppTheme.lightTheme.colorScheme.primary));
    });

    test('gère un AsyncValue en état loading', () {
      final container = ProviderContainer(
        overrides: [
          restaurantPlanUnifiedProvider.overrideWith(
            (ref) => Future.delayed(
              const Duration(seconds: 10),
              () => null,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Doit retourner le thème legacy pendant le chargement
      final theme = container.read(unifiedThemeProvider);
      expect(theme.colorScheme.primary, equals(AppTheme.lightTheme.colorScheme.primary));
    });
  });
}
