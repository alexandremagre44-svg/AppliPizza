// lib/src/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/order.dart'; 
import '../services/firebase_order_service.dart';
import '../services/user_profile_service.dart';
import 'cart_provider.dart';
import 'auth_provider.dart';
import 'restaurant_provider.dart';
import 'order_provider.dart';

/// Provider for the UserProfileService
/// Watches currentRestaurantProvider to inject the appId for multi-tenant isolation
final userProfileServiceProvider = Provider<UserProfileService>(
  (ref) {
    final config = ref.watch(currentRestaurantProvider);
    return UserProfileService(appId: config.id);
  },
  dependencies: [currentRestaurantProvider],
);

final userProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(UserProfile.initial());

  /// Get the UserProfileService instance from the provider
  UserProfileService get _profileService => _ref.read(userProfileServiceProvider);

  /// Charger le profil utilisateur depuis Firestore
  Future<void> loadProfile(String userId) async {
    final profile = await _profileService.getUserProfile(userId);
    if (profile != null) {
      state = profile;
    }
  }

  /// Sauvegarder le profil utilisateur dans Firestore
  Future<bool> saveProfile() async {
    return await _profileService.saveUserProfile(state);
  }

  /// Basculer un produit dans les favoris
  Future<void> toggleFavorite(String productId) async {
    final favorites = [...state.favoriteProducts];
    final wasInFavorites = favorites.contains(productId);
    
    if (wasInFavorites) {
      favorites.remove(productId);
      await _profileService.removeFromFavorites(state.id, productId);
    } else {
      favorites.add(productId);
      await _profileService.addToFavorites(state.id, productId);
    }
    
    state = state.copyWith(favoriteProducts: favorites);
  }

  /// Mettre à jour l'adresse
  Future<void> updateAddress(String address) async {
    await _profileService.updateAddress(state.id, address);
    state = state.copyWith(address: address);
  }

  /// Mettre à jour l'image de profil
  Future<void> updateProfileImage(String imageUrl) async {
    await _profileService.updateProfileImage(state.id, imageUrl);
    state = state.copyWith(imageUrl: imageUrl);
  }

  Future<void> addOrder({
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? comment,
    String? pickupDate,
    String? pickupTimeSlot,
    // Delivery fields
    String? deliveryMode,
    Map<String, dynamic>? deliveryAddress,
    String? deliveryAreaId,
    double? deliveryFee,
  }) async {
    // Le type lu par _ref.read(cartProvider) est CartState
    final cartState = _ref.read(cartProvider); 
    
    // Utilisation de totalItems qui est la bonne propriété
    if (cartState.totalItems == 0) return; 

    // Récupérer l'email de l'utilisateur connecté si non fourni
    final authState = _ref.read(authProvider);
    final email = customerEmail ?? authState.userEmail;

    // Créer la commande dans Firebase using the provider for multi-tenant isolation
    try {
      final orderService = _ref.read(firebaseOrderServiceProvider);
      await orderService.createOrder(
        items: cartState.items,
        total: cartState.total,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: email,
        comment: comment,
        pickupDate: pickupDate,
        pickupTimeSlot: pickupTimeSlot,
        // Delivery fields
        deliveryMode: deliveryMode,
        deliveryAddress: deliveryAddress,
        deliveryAreaId: deliveryAreaId,
        deliveryFee: deliveryFee,
      );

      // Vider le panier après la commande (méthode de CartNotifier)
      _ref.read(cartProvider.notifier).clearCart();
    } catch (e) {
      // Propager l'erreur pour qu'elle soit gérée par l'UI
      rethrow;
    }
  }
}