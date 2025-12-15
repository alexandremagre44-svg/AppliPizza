// lib/src/screens/admin/pos/providers/pos_cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../models/product.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../models/order_option_selection.dart';

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
  void addItem(Product product, {String? customDescription, List<OrderOptionSelection>? selections}) {
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
        selections: selections ?? [],
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

  /// Duplicate an existing item in cart
  /// Note: selections are the source of truth for customization
  void duplicateItem(String itemId) {
    final itemToDuplicate = state.items.firstWhere((i) => i.id == itemId);
    final duplicatedItem = CartItem(
      id: _uuid.v4(),
      productId: itemToDuplicate.productId,
      productName: itemToDuplicate.productName,
      price: itemToDuplicate.price,
      quantity: itemToDuplicate.quantity,
      imageUrl: itemToDuplicate.imageUrl,
      selections: List.from(itemToDuplicate.selections),
      // selections are the source of truth; no need for customDescription
      isMenu: itemToDuplicate.isMenu,
    );
    state = CartState([...state.items, duplicatedItem]);
  }

  /// Update an existing item (used for modify functionality)
  void updateItem(String itemId, CartItem updatedItem) {
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return updatedItem;
      }
      return item;
    }).toList();
    state = CartState([...updatedItems]);
  }

  /// Update quantity of an item
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final index = state.items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      final item = state.items[index];
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[index] = CartItem(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: newQuantity,
        imageUrl: item.imageUrl,
        selections: item.selections,
        customDescription: item.customDescription,
        isMenu: item.isMenu,
      );
      state = CartState(updatedItems);
    }
  }

  /// Increment quantity of an item
  void incrementQuantity(String itemId) {
    final index = state.items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      final item = state.items[index];
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[index] = CartItem(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: item.quantity + 1,
        imageUrl: item.imageUrl,
        selections: item.selections,
        customDescription: item.customDescription,
        isMenu: item.isMenu,
      );
      state = CartState(updatedItems);
    }
  }

  /// Decrement quantity of an item
  void decrementQuantity(String itemId) {
    final index = state.items.indexWhere((i) => i.id == itemId);
    if (index >= 0) {
      final item = state.items[index];
      
      if (item.quantity <= 1) {
        removeItem(itemId);
      } else {
        final updatedItems = List<CartItem>.from(state.items);
        updatedItems[index] = CartItem(
          id: item.id,
          productId: item.productId,
          productName: item.productName,
          price: item.price,
          quantity: item.quantity - 1,
          imageUrl: item.imageUrl,
          selections: item.selections,
          customDescription: item.customDescription,
          isMenu: item.isMenu,
        );
        state = CartState(updatedItems);
      }
    }
  }

  /// Clear the entire cart
  void clearCart() {
    state = CartState([]);
  }

  /// Validate cart items for required options
  /// Returns list of validation errors, empty if valid
  List<String> validateCart() {
    final errors = <String>[];
    
    for (final item in state.items) {
      // Check if menu items have proper customization
      if (item.isMenu && item.selections.isEmpty) {
        errors.add('Le menu "${item.productName}" nécessite une personnalisation');
      }
    }
    
    return errors;
  }

  /// Calculate total with price deltas from selections
  double calculateTotalWithSelections() {
    double total = 0.0;
    
    for (final item in state.items) {
      // Base price
      double itemTotal = item.price;
      
      // Add price deltas from selections
      for (final selection in item.selections) {
        itemTotal += selection.priceDelta / 100.0; // Convert cents to euros
      }
      
      // Multiply by quantity
      total += itemTotal * item.quantity;
    }
    
    return total;
  }
}
