// lib/src/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/order.dart'; 
import '../services/firebase_order_service.dart';
import 'cart_provider.dart';
import 'auth_provider.dart';
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

    // Récupérer l'email de l'utilisateur connecté si non fourni
    final authState = _ref.read(authProvider);
    final email = customerEmail ?? authState.userEmail;

    // Créer la commande dans Firebase
    try {
      await FirebaseOrderService().createOrder(
        items: cartState.items,
        total: cartState.total,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: email,
        comment: comment,
        pickupDate: pickupDate,
        pickupTimeSlot: pickupTimeSlot,
      );

      // Vider le panier après la commande (méthode de CartNotifier)
      _ref.read(cartProvider.notifier).clearCart();
    } catch (e) {
      // Propager l'erreur pour qu'elle soit gérée par l'UI
      rethrow;
    }
  }
}