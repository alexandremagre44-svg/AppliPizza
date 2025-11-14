// Test pour le staff tablet cart provider
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizza_delizza/src/staff_tablet/providers/staff_tablet_cart_provider.dart';
import 'package:pizza_delizza/src/providers/cart_provider.dart';
import 'package:pizza_delizza/src/models/product.dart';

void main() {
  group('StaffTabletCartProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Le panier staff devrait être vide initialement', () {
      final cartState = container.read(staffTabletCartProvider);
      expect(cartState.items.length, 0);
      expect(cartState.total, 0.0);
      expect(cartState.totalItems, 0);
    });

    test('Ajouter un produit simple devrait fonctionner', () {
      final product = Product(
        id: 'test1',
        name: 'Pizza Test',
        description: 'Une pizza de test',
        price: 12.50,
        imageUrl: 'https://test.com/image.jpg',
        category: ProductCategory.pizza,
      );

      container.read(staffTabletCartProvider.notifier).addItem(product);
      final cartState = container.read(staffTabletCartProvider);

      expect(cartState.items.length, 1);
      expect(cartState.items[0].productName, 'Pizza Test');
      expect(cartState.items[0].price, 12.50);
      expect(cartState.items[0].quantity, 1);
      expect(cartState.items[0].isMenu, false);
      expect(cartState.total, 12.50);
      expect(cartState.totalItems, 1);
    });

    test('Ajouter un menu via addExistingItem devrait fonctionner', () {
      final menuItem = CartItem(
        id: 'menu-test-1',
        productId: 'm1',
        productName: 'Menu Duo',
        price: 18.90,
        quantity: 1,
        imageUrl: 'https://test.com/menu.jpg',
        customDescription: 'Pizzas: Margherita - Boissons: Coca-Cola',
        isMenu: true,
      );

      container.read(staffTabletCartProvider.notifier).addExistingItem(menuItem);
      final cartState = container.read(staffTabletCartProvider);

      expect(cartState.items.length, 1);
      expect(cartState.items[0].productName, 'Menu Duo');
      expect(cartState.items[0].price, 18.90);
      expect(cartState.items[0].isMenu, true);
      expect(cartState.items[0].customDescription, 'Pizzas: Margherita - Boissons: Coca-Cola');
      expect(cartState.total, 18.90);
    });

    test('Ajouter plusieurs items (menu + produits) devrait fonctionner', () {
      // Ajouter un menu
      final menuItem = CartItem(
        id: 'menu-test-1',
        productId: 'm1',
        productName: 'Menu Duo',
        price: 18.90,
        quantity: 1,
        imageUrl: 'https://test.com/menu.jpg',
        customDescription: 'Pizzas: Margherita - Boissons: Coca-Cola',
        isMenu: true,
      );
      container.read(staffTabletCartProvider.notifier).addExistingItem(menuItem);

      // Ajouter un produit simple
      final product = Product(
        id: 'test1',
        name: 'Tiramisu',
        description: 'Un dessert de test',
        price: 4.50,
        imageUrl: 'https://test.com/dessert.jpg',
        category: ProductCategory.desserts,
      );
      container.read(staffTabletCartProvider.notifier).addItem(product);

      final cartState = container.read(staffTabletCartProvider);

      expect(cartState.items.length, 2);
      expect(cartState.totalItems, 2);
      expect(cartState.total, 23.40); // 18.90 + 4.50
    });

    test('Incrémenter la quantité d\'un menu devrait fonctionner', () {
      final menuItem = CartItem(
        id: 'menu-test-1',
        productId: 'm1',
        productName: 'Menu Duo',
        price: 18.90,
        quantity: 1,
        imageUrl: 'https://test.com/menu.jpg',
        customDescription: 'Pizzas: Margherita - Boissons: Coca-Cola',
        isMenu: true,
      );

      container.read(staffTabletCartProvider.notifier).addExistingItem(menuItem);
      container.read(staffTabletCartProvider.notifier).incrementQuantity('menu-test-1');
      final cartState = container.read(staffTabletCartProvider);

      expect(cartState.items[0].quantity, 2);
      expect(cartState.total, 37.80); // 18.90 * 2
    });

    test('Supprimer un menu devrait fonctionner', () {
      final menuItem = CartItem(
        id: 'menu-test-1',
        productId: 'm1',
        productName: 'Menu Duo',
        price: 18.90,
        quantity: 1,
        imageUrl: 'https://test.com/menu.jpg',
        customDescription: 'Pizzas: Margherita - Boissons: Coca-Cola',
        isMenu: true,
      );

      container.read(staffTabletCartProvider.notifier).addExistingItem(menuItem);
      container.read(staffTabletCartProvider.notifier).removeItem('menu-test-1');
      final cartState = container.read(staffTabletCartProvider);

      expect(cartState.items.length, 0);
      expect(cartState.total, 0.0);
    });

    test('Vider le panier avec menus et produits devrait fonctionner', () {
      // Ajouter un menu
      final menuItem = CartItem(
        id: 'menu-test-1',
        productId: 'm1',
        productName: 'Menu Duo',
        price: 18.90,
        quantity: 1,
        imageUrl: 'https://test.com/menu.jpg',
        customDescription: 'Pizzas: Margherita - Boissons: Coca-Cola',
        isMenu: true,
      );
      container.read(staffTabletCartProvider.notifier).addExistingItem(menuItem);

      // Ajouter des produits simples
      final product1 = Product(
        id: 'test1',
        name: 'Pizza Margherita',
        description: 'Une pizza classique',
        price: 10.00,
        imageUrl: 'https://test.com/pizza.jpg',
        category: ProductCategory.pizza,
      );
      final product2 = Product(
        id: 'test2',
        name: 'Coca-Cola',
        description: 'Boisson fraîche',
        price: 2.50,
        imageUrl: 'https://test.com/drink.jpg',
        category: ProductCategory.boissons,
      );

      container.read(staffTabletCartProvider.notifier).addItem(product1);
      container.read(staffTabletCartProvider.notifier).addItem(product2);

      // Vérifier que tout est ajouté
      final cartStateBefore = container.read(staffTabletCartProvider);
      expect(cartStateBefore.items.length, 3);

      // Vider le panier
      container.read(staffTabletCartProvider.notifier).clearCart();
      final cartStateAfter = container.read(staffTabletCartProvider);

      expect(cartStateAfter.items.length, 0);
      expect(cartStateAfter.total, 0.0);
      expect(cartStateAfter.totalItems, 0);
    });
  });
}
