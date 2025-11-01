// lib/src/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/order.dart'; 
import 'cart_provider.dart';
// Note: L'ancienne importation vers '../models/cart.dart' est retirée

final userProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(UserProfile.initial());

  void toggleFavorite(String productId) {
    final favorites = [...state.favoriteProducts];
    if (favorites.contains(productId)) {
      favorites.remove(productId);
    } else {
      favorites.add(productId);
    }
    state = state.copyWith(favoriteProducts: favorites);
  }

  void addOrder() {
    // Le type lu par _ref.read(cartProvider) est CartState
    final cartState = _ref.read(cartProvider); 
    
    // Utilisation de totalQuantity qui est la bonne propriété
    if (cartState.totalQuantity == 0) return; 

    final newOrder = Order.fromCart(
      cartState.items,
      cartState.total,
    );

    final updatedHistory = [newOrder, ...state.orderHistory];

    state = state.copyWith(
      orderHistory: updatedHistory,
    );

    // Vider le panier après la commande (méthode de CartNotifier)
    _ref.read(cartProvider.notifier).clearCart();
  }
}