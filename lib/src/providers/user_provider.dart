// lib/src/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/order.dart'; 
import '../services/order_service.dart';
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

  Future<void> addOrder({
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? comment,
    String? pickupDate,
    String? pickupTimeSlot,
  }) async {
    // Le type lu par _ref.read(cartProvider) est CartState
    final cartState = _ref.read(cartProvider); 
    
    // Utilisation de totalItems qui est la bonne propriété
    if (cartState.totalItems == 0) return; 

    final newOrder = Order.fromCart(
      cartState.items,
      cartState.total,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      comment: comment,
      pickupDate: pickupDate,
      pickupTimeSlot: pickupTimeSlot,
    );

    // Ajouter à l'historique local du profil
    final updatedHistory = [newOrder, ...state.orderHistory];
    state = state.copyWith(
      orderHistory: updatedHistory,
    );

    // Ajouter au service de commandes (pour l'admin)
    await OrderService().addOrder(newOrder);

    // Vider le panier après la commande (méthode de CartNotifier)
    _ref.read(cartProvider.notifier).clearCart();
  }
}