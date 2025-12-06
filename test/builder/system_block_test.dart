/// test/builder/system_block_test.dart
///
/// Tests unitaires pour SystemBlock et ses modules disponibles.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/models/builder_block.dart';

void main() {
  group('SystemBlock', () {
    test('availableModules ne contient pas de doublons', () {
      final modules = SystemBlock.availableModules;
      final uniqueModules = modules.toSet();
      expect(modules.length, equals(uniqueModules.length),
          reason: 'availableModules should not contain duplicates');
    });

    test('availableModules contient les modules essentiels', () {
      final modules = SystemBlock.availableModules;
      expect(modules, contains('roulette'));
      expect(modules, contains('loyalty'));
      expect(modules, contains('rewards'));
      expect(modules, contains('accountActivity'));
      expect(modules, contains('menu_catalog'));
      expect(modules, contains('cart_module'));
      expect(modules, contains('profile_module'));
    });

    test('availableModules ne contient pas roulette_module (évite duplication)', () {
      final modules = SystemBlock.availableModules;
      
      // Vérifie que 'roulette' est présent dans la liste
      expect(modules, contains('roulette'),
          reason: 'roulette should be in availableModules');
      
      // Vérifie que 'roulette_module' n'est PAS dans la liste pour éviter duplication
      // 'roulette_module' doit être géré comme un alias via getModuleLabel/getModuleIcon
      expect(modules, isNot(contains('roulette_module')),
          reason: 'roulette_module should not be in availableModules to avoid duplication with roulette');
    });

    test('getModuleLabel retourne le label correct pour roulette', () {
      expect(SystemBlock.getModuleLabel('roulette'), equals('Roulette'));
    });

    test('getModuleLabel retourne le label correct pour roulette_module (backward compat)', () {
      expect(SystemBlock.getModuleLabel('roulette_module'), equals('Roulette'));
    });

    test('getModuleLabel retourne le label correct pour menu_catalog', () {
      expect(SystemBlock.getModuleLabel('menu_catalog'), equals('Catalogue Menu'));
    });

    test('getModuleLabel retourne le label correct pour cart_module', () {
      expect(SystemBlock.getModuleLabel('cart_module'), equals('Panier'));
    });

    test('getModuleLabel retourne le label correct pour profile_module', () {
      expect(SystemBlock.getModuleLabel('profile_module'), equals('Profil'));
    });

    test('getModuleLabel retourne "Module inconnu" pour un module invalide', () {
      expect(SystemBlock.getModuleLabel('invalid_module'), equals('Module inconnu'));
    });

    test('getModuleIcon retourne l\'icône correcte pour roulette', () {
      expect(SystemBlock.getModuleIcon('roulette'), equals('🎰'));
    });

    test('getModuleIcon retourne l\'icône correcte pour roulette_module (backward compat)', () {
      expect(SystemBlock.getModuleIcon('roulette_module'), equals('🎰'));
    });

    test('getModuleIcon retourne l\'icône correcte pour menu_catalog', () {
      expect(SystemBlock.getModuleIcon('menu_catalog'), equals('🍕'));
    });

    test('getModuleIcon retourne l\'icône correcte pour cart_module', () {
      expect(SystemBlock.getModuleIcon('cart_module'), equals('🛒'));
    });

    test('getModuleIcon retourne l\'icône correcte pour profile_module', () {
      expect(SystemBlock.getModuleIcon('profile_module'), equals('👤'));
    });

    test('getModuleIcon retourne "❓" pour un module invalide', () {
      expect(SystemBlock.getModuleIcon('invalid_module'), equals('❓'));
    });

    test('tous les modules disponibles ont un label', () {
      for (final moduleType in SystemBlock.availableModules) {
        final label = SystemBlock.getModuleLabel(moduleType);
        expect(label, isNotNull);
        expect(label, isNot(equals('Module inconnu')),
            reason: 'Module "$moduleType" should have a valid label');
      }
    });

    test('tous les modules disponibles ont une icône', () {
      for (final moduleType in SystemBlock.availableModules) {
        final icon = SystemBlock.getModuleIcon(moduleType);
        expect(icon, isNotNull);
        expect(icon, isNot(equals('❓')),
            reason: 'Module "$moduleType" should have a valid icon');
      }
    });
  });
}
