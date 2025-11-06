// Test pour le modèle Product
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('Créer un produit devrait fonctionner', () {
      final product = Product(
        id: 'p1',
        name: 'Margherita',
        description: 'Tomate, Mozzarella',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      expect(product.id, 'p1');
      expect(product.name, 'Margherita');
      expect(product.price, 12.50);
      expect(product.category, 'Pizza');
      expect(product.isMenu, false);
    });

    test('Créer un menu devrait fonctionner', () {
      final menu = Product(
        id: 'm1',
        name: 'Menu Duo',
        description: '1 pizza + 1 boisson',
        price: 18.90,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Menus',
        isMenu: true,
        pizzaCount: 1,
        drinkCount: 1,
      );

      expect(menu.id, 'm1');
      expect(menu.isMenu, true);
      expect(menu.pizzaCount, 1);
      expect(menu.drinkCount, 1);
    });

    test('copyWith devrait créer une copie avec modifications', () {
      final product = Product(
        id: 'p1',
        name: 'Margherita',
        description: 'Tomate, Mozzarella',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      final updatedProduct = product.copyWith(
        name: 'Margherita XL',
        price: 15.00,
      );

      expect(updatedProduct.id, 'p1');
      expect(updatedProduct.name, 'Margherita XL');
      expect(updatedProduct.price, 15.00);
      expect(updatedProduct.description, 'Tomate, Mozzarella');
    });

    test('toJson devrait sérialiser correctement', () {
      final product = Product(
        id: 'p1',
        name: 'Margherita',
        description: 'Tomate, Mozzarella',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
        baseIngredients: ['Tomate', 'Mozzarella'],
      );

      final json = product.toJson();

      expect(json['id'], 'p1');
      expect(json['name'], 'Margherita');
      expect(json['price'], 12.50);
      expect(json['category'], 'Pizza');
      expect(json['baseIngredients'], ['Tomate', 'Mozzarella']);
    });

    test('fromJson devrait désérialiser correctement', () {
      final json = {
        'id': 'p1',
        'name': 'Margherita',
        'description': 'Tomate, Mozzarella',
        'price': 12.50,
        'imageUrl': 'https://test.com/image.jpg',
        'category': 'Pizza',
        'isMenu': false,
        'baseIngredients': ['Tomate', 'Mozzarella'],
        'pizzaCount': 1,
        'drinkCount': 0,
      };

      final product = Product.fromJson(json);

      expect(product.id, 'p1');
      expect(product.name, 'Margherita');
      expect(product.price, 12.50);
      expect(product.category, 'Pizza');
      expect(product.isMenu, false);
      expect(product.baseIngredients.length, 2);
    });

    test('fromJson avec données partielles devrait utiliser les valeurs par défaut', () {
      final json = {
        'id': 'p1',
        'name': 'Margherita',
        'description': 'Tomate, Mozzarella',
        'price': 12.50,
        'imageUrl': 'https://test.com/image.jpg',
        'category': 'Pizza',
      };

      final product = Product.fromJson(json);

      expect(product.id, 'p1');
      expect(product.isMenu, false);
      expect(product.baseIngredients.length, 0);
      expect(product.pizzaCount, 1);
      expect(product.drinkCount, 0);
    });
  });
}
