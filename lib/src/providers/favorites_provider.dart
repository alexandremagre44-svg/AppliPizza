// lib/src/providers/favorites_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider pour gérer les favoris
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({});

  // Toggle favori
  void toggleFavorite(String productId) {
    final newState = Set<String>.from(state);
    if (newState.contains(productId)) {
      newState.remove(productId);
    } else {
      newState.add(productId);
    }
    state = newState;
  }

  // Vérifier si un produit est favori
  bool isFavorite(String productId) {
    return state.contains(productId);
  }

  // Obtenir tous les favoris
  Set<String> get favoriteIds => state;

  // Retirer un favori
  void removeFavorite(String productId) {
    final newState = Set<String>.from(state);
    newState.remove(productId);
    state = newState;
  }

  // Ajouter un favori
  void addFavorite(String productId) {
    final newState = Set<String>.from(state);
    newState.add(productId);
    state = newState;
  }

  // Effacer tous les favoris
  void clearFavorites() {
    state = {};
  }
}
