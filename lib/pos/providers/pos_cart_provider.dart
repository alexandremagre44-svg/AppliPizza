/// POS Cart Provider - manages the shopping cart in POS mode
/// 
/// This provider is completely separate from the client cart and staff tablet cart,
/// allowing the POS to operate independently.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/pos_cart_item.dart';

const _uuid = Uuid();

/// Cart state for POS
class PosCartState {
  final List<PosCartItem> items;
  
  const PosCartState(this.items);
  
  /// Calculate total price of all items
  double get total {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }
  
  /// Get total number of items (considering quantities)
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;
  
  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;
}

/// Provider for POS cart
final posCartProvider = StateNotifierProvider<PosCartNotifier, PosCartState>((ref) {
  return PosCartNotifier();
});

/// POS Cart Notifier
class PosCartNotifier extends StateNotifier<PosCartState> {
  PosCartNotifier() : super(const PosCartState([]));
  
  /// Add a product to the cart
  void addItem(
    String productId,
    String productName,
    double price, {
    String imageUrl = '',
    String? customDescription,
    bool isMenu = false,
    List<PosCartItem>? menuItems,
  }) {
    // Check if a similar item already exists (same product and customization)
    final existingIndex = state.items.indexWhere(
      (item) =>
          item.productId == productId &&
          item.customDescription == customDescription &&
          !item.isMenu, // Don't merge menu items
    );
    
    if (existingIndex >= 0 && !isMenu) {
      // If item exists and is not a menu, increment quantity
      final updatedItems = List<PosCartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = PosCartState(updatedItems);
    } else {
      // Otherwise, add new item
      final newItem = PosCartItem(
        id: _uuid.v4(),
        productId: productId,
        productName: productName,
        price: price,
        quantity: 1,
        imageUrl: imageUrl,
        customDescription: customDescription,
        isMenu: isMenu,
        menuItems: menuItems,
      );
      state = PosCartState([...state.items, newItem]);
    }
  }
  
  /// Add a pre-built cart item (for customized items)
  void addCartItem(PosCartItem item) {
    state = PosCartState([...state.items, item]);
  }
  
  /// Remove an item from the cart
  void removeItem(String itemId) {
    final updatedItems = state.items.where((item) => item.id != itemId).toList();
    state = PosCartState(updatedItems);
  }
  
  /// Update quantity of an item
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }
    
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
    
    state = PosCartState(updatedItems);
  }
  
  /// Increment quantity of an item
  void incrementQuantity(String itemId) {
    final itemIndex = state.items.indexWhere((item) => item.id == itemId);
    if (itemIndex >= 0) {
      final updatedItems = List<PosCartItem>.from(state.items);
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
        quantity: updatedItems[itemIndex].quantity + 1,
      );
      state = PosCartState(updatedItems);
    }
  }
  
  /// Decrement quantity of an item
  void decrementQuantity(String itemId) {
    final itemIndex = state.items.indexWhere((item) => item.id == itemId);
    if (itemIndex >= 0) {
      final currentQuantity = state.items[itemIndex].quantity;
      if (currentQuantity <= 1) {
        removeItem(itemId);
      } else {
        final updatedItems = List<PosCartItem>.from(state.items);
        updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
          quantity: currentQuantity - 1,
        );
        state = PosCartState(updatedItems);
      }
    }
  }
  
  /// Clear the entire cart
  void clearCart() {
    state = const PosCartState([]);
  }
}
