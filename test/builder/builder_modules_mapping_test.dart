/// test/builder/builder_modules_mapping_test.dart
///
/// Tests unitaires pour le mapping des modules Builder vers ModuleId white-label.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/builder/utils/builder_modules.dart';
import 'package:pizza_delizza/white_label/core/module_id.dart';

void main() {
  group('Builder Module ID Mapping', () {
    test('getModuleIdCode retourne le code correct pour menu_catalog', () {
      final code = getModuleIdCode('menu_catalog');
      expect(code, equals('ordering'));
    });

    test('getModuleIdCode retourne le code correct pour cart_module', () {
      final code = getModuleIdCode('cart_module');
      expect(code, equals('ordering'));
    });

    test('getModuleIdCode retourne le code correct pour profile_module', () {
      final code = getModuleIdCode('profile_module');
      expect(code, equals('ordering'));
    });

    test('getModuleIdCode retourne le code correct pour roulette_module', () {
      final code = getModuleIdCode('roulette_module');
      expect(code, equals('roulette'));
    });

    test('getModuleIdCode retourne le code correct pour roulette (alias)', () {
      final code = getModuleIdCode('roulette');
      expect(code, equals('roulette'));
    });

    test('getModuleIdCode retourne null pour un module inconnu', () {
      final code = getModuleIdCode('unknown_module');
      expect(code, isNull);
    });

    test('getModuleId retourne ModuleId.ordering pour menu_catalog', () {
      final moduleId = getModuleId('menu_catalog');
      expect(moduleId, equals(ModuleId.ordering));
    });

    test('getModuleId retourne ModuleId.ordering pour cart_module', () {
      final moduleId = getModuleId('cart_module');
      expect(moduleId, equals(ModuleId.ordering));
    });

    test('getModuleId retourne ModuleId.ordering pour profile_module', () {
      final moduleId = getModuleId('profile_module');
      expect(moduleId, equals(ModuleId.ordering));
    });

    test('getModuleId retourne ModuleId.roulette pour roulette_module', () {
      final moduleId = getModuleId('roulette_module');
      expect(moduleId, equals(ModuleId.roulette));
    });

    test('getModuleId retourne ModuleId.roulette pour roulette (alias)', () {
      final moduleId = getModuleId('roulette');
      expect(moduleId, equals(ModuleId.roulette));
    });

    test('getModuleId retourne null pour un module inconnu', () {
      final moduleId = getModuleId('unknown_module');
      expect(moduleId, isNull);
    });

    test('moduleIdMapping contient tous les modules Builder', () {
      expect(moduleIdMapping, containsPair('menu_catalog', 'ordering'));
      expect(moduleIdMapping, containsPair('cart_module', 'ordering'));
      expect(moduleIdMapping, containsPair('profile_module', 'ordering'));
      expect(moduleIdMapping, containsPair('roulette_module', 'roulette'));
      expect(moduleIdMapping, containsPair('roulette', 'roulette'));
    });

    test('builderModules contient tous les modules définis', () {
      expect(builderModules, contains('menu_catalog'));
      expect(builderModules, contains('cart_module'));
      expect(builderModules, contains('profile_module'));
      expect(builderModules, contains('roulette_module'));
    });

    test('tous les modules Builder sont mappés vers des ModuleId valides', () {
      for (final builderId in builderModules.keys) {
        final moduleId = getModuleId(builderId);
        expect(moduleId, isNotNull,
            reason: 'Builder module "$builderId" should map to a valid ModuleId');
      }
    });
  });
}
