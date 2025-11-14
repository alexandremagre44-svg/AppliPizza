// lib/src/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile.dart';
import '../../orders/data/models/order.dart'; 
import 'package:pizza_delizza/src/features/orders/data/repositories/firebase_order_repository.dart';
import 'package:pizza_delizza/src/features/auth/data/repositories/user_profile_repository.dart';
import 'cart_provider.dart';
import 'auth_provider.dart';

final userProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final Ref _ref;
  final UserProfileRepository _profileRepository = UserProfileRepository();

  UserProfileNotifier(this._ref) : super(UserProfile.initial());

  /// Charger le profil utilisateur depuis Firestore
  Future<void> loadProfile(String userId) async {
    final profile = await _profileRepository.getUserProfile(userId);
    if (profile != null) {
      state = profile;
    }
  }

  /// Sauvegarder le profil utilisateur dans Firestore
  Future<bool> saveProfile() async {
    return await _profileRepository.saveUserProfile(state);
  }

  /// Basculer un produit dans les favoris
  Future<void> toggleFavorite(String productId) async {
    final favorites = [...state.favoriteProducts];
    final wasInFavorites = favorites.contains(productId);
    
    if (wasInFavorites) {
      favorites.remove(productId);
      await _profileRepository.removeFromFavorites(state.id, productId);
    } else {
      favorites.add(productId);
      await _profileRepository.addToFavorites(state.id, productId);
    }
    
    state = state.copyWith(favoriteProducts: favorites);
  }

  /// Mettre à jour l'adresse
  Future<void> updateAddress(String address) async {
    await _profileRepository.updateAddress(state.id, address);
    state = state.copyWith(address: address);
  }

  /// Mettre à jour l'image de profil
  Future<void> updateProfileImage(String imageUrl) async {
    await _profileRepository.updateProfileImage(state.id, imageUrl);
    state = state.copyWith(imageUrl: imageUrl);
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
      await FirebaseOrderRepository().createOrder(
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