// Test pour le provider de panier
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizza_delizza/src/providers/cart_provider.dart';
import 'package:pizza_delizza/src/models/product.dart';

void main() {
  group('CartProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Le panier devrait être vide initialement', () {
      final cartState = container.read(cartProvider);
      expect(cartState.items.length, 0);
      expect(cartState.total, 0.0);
      expect(cartState.totalItems, 0);
    });

    test('Ajouter un produit au panier devrait fonctionner', () {
      final product = Product(
        id: 'test1',
        name: 'Pizza Test',
        description: 'Une pizza de test',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      container.read(cartProvider.notifier).addItem(product);
      final cartState = container.read(cartProvider);

      expect(cartState.items.length, 1);
      expect(cartState.items[0].productName, 'Pizza Test');
      expect(cartState.items[0].price, 12.50);
      expect(cartState.items[0].quantity, 1);
      expect(cartState.total, 12.50);
      expect(cartState.totalItems, 1);
    });

    test('Ajouter le même produit deux fois devrait augmenter la quantité', () {
      final product = Product(
        id: 'test1',
        name: 'Pizza Test',
        description: 'Une pizza de test',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      container.read(cartProvider.notifier).addItem(product);
      container.read(cartProvider.notifier).addItem(product);
      final cartState = container.read(cartProvider);

      expect(cartState.items.length, 1);
      expect(cartState.items[0].quantity, 2);
      expect(cartState.total, 25.00);
      expect(cartState.totalItems, 2);
    });

    test('Supprimer un produit devrait fonctionner', () {
      final product = Product(
        id: 'test1',
        name: 'Pizza Test',
        description: 'Une pizza de test',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      container.read(cartProvider.notifier).addItem(product);
      final cartState1 = container.read(cartProvider);
      final itemId = cartState1.items[0].id;

      container.read(cartProvider.notifier).removeItem(itemId);
      final cartState2 = container.read(cartProvider);

      expect(cartState2.items.length, 0);
      expect(cartState2.total, 0.0);
    });

    test('Incrémenter la quantité devrait fonctionner', () {
      final product = Product(
        id: 'test1',
        name: 'Pizza Test',
        description: 'Une pizza de test',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      container.read(cartProvider.notifier).addItem(product);
      final cartState1 = container.read(cartProvider);
      final itemId = cartState1.items[0].id;

      container.read(cartProvider.notifier).incrementQuantity(itemId);
      final cartState2 = container.read(cartProvider);

      expect(cartState2.items[0].quantity, 2);
      expect(cartState2.total, 25.00);
    });

    test('Décrémenter la quantité devrait fonctionner', () {
      final product = Product(
        id: 'test1',
        name: 'Pizza Test',
        description: 'Une pizza de test',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      container.read(cartProvider.notifier).addItem(product);
      container.read(cartProvider.notifier).addItem(product);
      final cartState1 = container.read(cartProvider);
      final itemId = cartState1.items[0].id;

      container.read(cartProvider.notifier).decrementQuantity(itemId);
      final cartState2 = container.read(cartProvider);

      expect(cartState2.items[0].quantity, 1);
      expect(cartState2.total, 12.50);
    });

    test('Décrémenter à 0 devrait supprimer le produit', () {
      final product = Product(
        id: 'test1',
        name: 'Pizza Test',
        description: 'Une pizza de test',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      container.read(cartProvider.notifier).addItem(product);
      final cartState1 = container.read(cartProvider);
      final itemId = cartState1.items[0].id;

      container.read(cartProvider.notifier).decrementQuantity(itemId);
      final cartState2 = container.read(cartProvider);

      expect(cartState2.items.length, 0);
      expect(cartState2.total, 0.0);
    });

    test('Vider le panier devrait fonctionner', () {
      final product1 = Product(
        id: 'test1',
        name: 'Pizza Test 1',
        description: 'Une pizza de test',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      final product2 = Product(
        id: 'test2',
        name: 'Pizza Test 2',
        description: 'Une autre pizza de test',
        price: 14.90,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      container.read(cartProvider.notifier).addItem(product1);
      container.read(cartProvider.notifier).addItem(product2);
      
      container.read(cartProvider.notifier).clearCart();
      final cartState = container.read(cartProvider);

      expect(cartState.items.length, 0);
      expect(cartState.total, 0.0);
      expect(cartState.totalItems, 0);
    });

    test('Calculer le total de plusieurs produits devrait être correct', () {
      final product1 = Product(
        id: 'test1',
        name: 'Pizza Test 1',
        description: 'Une pizza de test',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      final product2 = Product(
        id: 'test2',
        name: 'Pizza Test 2',
        description: 'Une autre pizza de test',
        price: 14.90,
        imageUrl: 'https://test.com/image.jpg',
        category: 'Pizza',
      );

      container.read(cartProvider.notifier).addItem(product1);
      container.read(cartProvider.notifier).addItem(product1);
      container.read(cartProvider.notifier).addItem(product2);
      final cartState = container.read(cartProvider);

      expect(cartState.items.length, 2);
      expect(cartState.totalItems, 3);
      expect(cartState.total, 39.90); // (12.50 * 2) + 14.90
    });
  });
}
