// lib/src/providers/ingredient_provider.dart
// Provider pour gérer l'état des ingrédients

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/firestore_ingredient_service.dart';

/// Provider du service Firestore pour les ingrédients
final ingredientServiceProvider = Provider<FirestoreIngredientService>((ref) {
  return createFirestoreIngredientService();
});

/// Provider pour charger tous les ingrédients
final ingredientListProvider = FutureProvider<List<Ingredient>>((ref) async {
  final service = ref.watch(ingredientServiceProvider);
  return await service.loadIngredients();
});

/// Provider pour charger uniquement les ingrédients actifs
final activeIngredientListProvider = FutureProvider<List<Ingredient>>((ref) async {
  final service = ref.watch(ingredientServiceProvider);
  return await service.loadActiveIngredients();
});

/// Provider pour écouter les ingrédients en temps réel
final ingredientStreamProvider = StreamProvider<List<Ingredient>>((ref) {
  final service = ref.watch(ingredientServiceProvider);
  return service.watchIngredients();
});

/// Provider pour charger les ingrédients par catégorie
final ingredientsByCategoryProvider = FutureProvider.family<List<Ingredient>, IngredientCategory>(
  (ref, category) async {
    final service = ref.watch(ingredientServiceProvider);
    return await service.loadIngredientsByCategory(category);
  },
);
