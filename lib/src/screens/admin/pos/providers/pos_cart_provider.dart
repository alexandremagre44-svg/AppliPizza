// lib/src/screens/admin/pos/providers/pos_cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/product.dart';
import '../../../../providers/cart_provider.dart';

const _uuid = Uuid();

// =============================================
// POS CART STATE NOTIFIER
// =============================================

/// Provider for POS cart - separate from client and staff tablet cart
/// This allows POS to operate independently without interfering with other modules
final posCartProvider = StateNotifierProvider<PosCartNotifier, CartState>((ref) {
  return PosCartNotifier();
});

/// POS Cart Notifier - reuses CartState from main cart_provider
/// This ensures consistency with cart models across the application
class PosCartNotifier extends StateNotifier<CartState> {
  PosCartNotifier() : super(CartState([]));

  /// Add a product to the cart
  void addItem(Product product, {String? customDescription}) {
    final existingItem = state.items.firstWhere(
      (item) => item.productId == product.id && item.customDescription == customDescription && !item.isMenu,
      orElse: () => CartItem(
          id: '',
          productId: '',
          productName: '',
          price: 0,
          quantity: 0,
          imageUrl: '',
          customDescription: ''),
    );

    if (existingItem.id.isNotEmpty) {
      // If item exists, increment quantity
      incrementQuantity(existingItem.id);
    } else {
      // Otherwise, add new item
      final newItem = CartItem(
        id: _uuid.v4(),
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: 1,
        imageUrl: product.imageUrl,
        customDescription: customDescription,
        isMenu: product.isMenu,
      );
      state = CartState([...state.items, newItem]);
    }
  }

  /// Add a pre-built CartItem (for customized menus)
  void addExistingItem(CartItem item) {
    state = CartState([...state.items, item]);
  }

  /// Remove an item from cart
  void removeItem(String itemId) {
    state = CartState(state.items.where((item) => item.id != itemId).toList());
  }

  /// Update quantity of an item
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        item.quantity = newQuantity;
      }
      return item;
    }).toList();

    state = CartState([...updatedItems]);
  }

  /// Increment quantity of an item
  void incrementQuantity(String itemId) {
    final itemToUpdate = state.items.firstWhere((i) => i.id == itemId);
    itemToUpdate.quantity++;
    state = CartState([...state.items]);
  }

  /// Decrement quantity of an item
  void decrementQuantity(String itemId) {
    final itemToUpdate = state.items.firstWhere((i) => i.id == itemId);
    
    if (itemToUpdate.quantity <= 1) {
      removeItem(itemId);
    } else {
      itemToUpdate.quantity--;
      state = CartState([...state.items]);
    }
  }

  /// Clear the entire cart
  void clearCart() {
    state = CartState([]);
  }
}
