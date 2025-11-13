// Test pour le modèle DynamicBlock
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/dynamic_block_model.dart';

void main() {
  group('DynamicBlock Model Tests', () {
    test('Créer un DynamicBlock avec ID auto-généré devrait fonctionner', () {
      final block = DynamicBlock(
        type: 'featuredProducts',
        title: 'Nos spécialités',
        maxItems: 6,
        order: 0,
      );

      expect(block.id, isNotEmpty);
      expect(block.type, 'featuredProducts');
      expect(block.title, 'Nos spécialités');
      expect(block.maxItems, 6);
      expect(block.order, 0);
      expect(block.isVisible, true);
    });

    test('Créer un DynamicBlock avec ID fourni devrait fonctionner', () {
      final block = DynamicBlock(
        id: 'custom-id',
        type: 'bestSellers',
        title: 'Best-sellers',
      );

      expect(block.id, 'custom-id');
      expect(block.type, 'bestSellers');
      expect(block.title, 'Best-sellers');
    });

    test('toJson devrait sérialiser correctement', () {
      final block = DynamicBlock(
        id: 'block1',
        type: 'featuredProducts',
        title: 'Nos spécialités',
        maxItems: 6,
        order: 0,
        isVisible: true,
      );

      final json = block.toJson();

      expect(json['id'], 'block1');
      expect(json['type'], 'featuredProducts');
      expect(json['title'], 'Nos spécialités');
      expect(json['maxItems'], 6);
      expect(json['order'], 0);
      expect(json['isVisible'], true);
    });

    test('fromJson devrait désérialiser correctement', () {
      final json = {
        'id': 'block1',
        'type': 'featuredProducts',
        'title': 'Nos spécialités',
        'maxItems': 6,
        'order': 0,
        'isVisible': true,
      };

      final block = DynamicBlock.fromJson(json);

      expect(block.id, 'block1');
      expect(block.type, 'featuredProducts');
      expect(block.title, 'Nos spécialités');
      expect(block.maxItems, 6);
      expect(block.order, 0);
      expect(block.isVisible, true);
    });

    test('fromJson avec données partielles devrait utiliser les valeurs par défaut', () {
      final json = {
        'type': 'categories',
        'title': 'Catégories',
      };

      final block = DynamicBlock.fromJson(json);

      expect(block.id, isNotEmpty); // Auto-généré
      expect(block.type, 'categories');
      expect(block.title, 'Catégories');
      expect(block.maxItems, 6); // Valeur par défaut
      expect(block.order, 0); // Valeur par défaut
      expect(block.isVisible, true); // Valeur par défaut
    });

    test('copyWith devrait créer une copie avec modifications', () {
      final block = DynamicBlock(
        id: 'block1',
        type: 'featuredProducts',
        title: 'Titre original',
        maxItems: 6,
        order: 0,
        isVisible: true,
      );

      final updated = block.copyWith(
        title: 'Nouveau titre',
        maxItems: 8,
        isVisible: false,
      );

      expect(updated.id, 'block1');
      expect(updated.type, 'featuredProducts');
      expect(updated.title, 'Nouveau titre');
      expect(updated.maxItems, 8);
      expect(updated.order, 0);
      expect(updated.isVisible, false);
    });

    test('isValidType devrait retourner true pour les types valides', () {
      final validTypes = ['featuredProducts', 'categories', 'bestSellers'];

      for (final type in validTypes) {
        final block = DynamicBlock(
          type: type,
          title: 'Test',
        );

        expect(block.isValidType, true, reason: '$type devrait être valide');
      }
    });

    test('isValidType devrait retourner false pour les types invalides', () {
      final block = DynamicBlock(
        type: 'invalidType',
        title: 'Test',
      );

      expect(block.isValidType, false);
    });

    test('validTypes devrait contenir tous les types supportés', () {
      expect(DynamicBlock.validTypes, contains('featuredProducts'));
      expect(DynamicBlock.validTypes, contains('categories'));
      expect(DynamicBlock.validTypes, contains('bestSellers'));
      expect(DynamicBlock.validTypes.length, 3);
    });

    test('toString devrait retourner une représentation lisible', () {
      final block = DynamicBlock(
        id: 'block1',
        type: 'featuredProducts',
        title: 'Nos spécialités',
        maxItems: 6,
        order: 0,
        isVisible: true,
      );

      final str = block.toString();

      expect(str, contains('block1'));
      expect(str, contains('featuredProducts'));
      expect(str, contains('Nos spécialités'));
      expect(str, contains('6'));
      expect(str, contains('0'));
      expect(str, contains('true'));
    });

    test('Deux DynamicBlock avec le même ID devraient être égaux', () {
      final block1 = DynamicBlock(
        id: 'block1',
        type: 'featuredProducts',
        title: 'Titre 1',
      );

      final block2 = DynamicBlock(
        id: 'block1',
        type: 'bestSellers',
        title: 'Titre 2',
      );

      expect(block1, equals(block2));
      expect(block1.hashCode, equals(block2.hashCode));
    });

    test('Deux DynamicBlock avec des IDs différents ne devraient pas être égaux', () {
      final block1 = DynamicBlock(
        id: 'block1',
        type: 'featuredProducts',
        title: 'Titre',
      );

      final block2 = DynamicBlock(
        id: 'block2',
        type: 'featuredProducts',
        title: 'Titre',
      );

      expect(block1, isNot(equals(block2)));
    });

    test('Type featuredProducts devrait être créé correctement', () {
      final block = DynamicBlock(
        type: 'featuredProducts',
        title: 'Produits en vedette',
      );

      expect(block.type, 'featuredProducts');
      expect(block.isValidType, true);
    });

    test('Type categories devrait être créé correctement', () {
      final block = DynamicBlock(
        type: 'categories',
        title: 'Nos catégories',
      );

      expect(block.type, 'categories');
      expect(block.isValidType, true);
    });

    test('Type bestSellers devrait être créé correctement', () {
      final block = DynamicBlock(
        type: 'bestSellers',
        title: 'Meilleures ventes',
      );

      expect(block.type, 'bestSellers');
      expect(block.isValidType, true);
    });

    test('maxItems devrait avoir une valeur par défaut de 6', () {
      final block = DynamicBlock(
        type: 'featuredProducts',
        title: 'Test',
      );

      expect(block.maxItems, 6);
    });

    test('order devrait avoir une valeur par défaut de 0', () {
      final block = DynamicBlock(
        type: 'featuredProducts',
        title: 'Test',
      );

      expect(block.order, 0);
    });

    test('isVisible devrait avoir une valeur par défaut de true', () {
      final block = DynamicBlock(
        type: 'featuredProducts',
        title: 'Test',
      );

      expect(block.isVisible, true);
    });
  });
}
