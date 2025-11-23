// lib/src/providers/ingredient_provider.dart
// TODO: Uses legacy version. Bridge to new module under construction.
// Nouveau module: lib/modules/customization/data/providers/customization_providers.dart
// Ce fichier reste la source ACTIVE pour l'instant. Ne pas modifier sans coordination.
// 
// Provider pour gérer l'état des ingrédients

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/firestore_ingredient_service.dart';

/// Provider du service Firestore pour les ingrédients
final ingredientServiceProvider = Provider<FirestoreIngredientService>((ref) {
  return createFirestoreIngredientService();
});

/// Provider pour charger tous les ingrédients (mode snapshot, non recommandé)
/// ⚠️ Utilisez ingredientStreamProvider pour des mises à jour en temps réel
final ingredientListProvider = FutureProvider<List<Ingredient>>((ref) async {
  final service = ref.watch(ingredientServiceProvider);
  return await service.loadIngredients();
});

/// Provider pour charger uniquement les ingrédients actifs (mode snapshot, non recommandé)
/// ⚠️ Utilisez activeIngredientStreamProvider pour des mises à jour en temps réel
@Deprecated('Utilisez activeIngredientStreamProvider pour des mises à jour en temps réel')
final activeIngredientListProvider = FutureProvider<List<Ingredient>>((ref) async {
  final service = ref.watch(ingredientServiceProvider);
  return await service.loadActiveIngredients();
});

/// Provider pour écouter tous les ingrédients en temps réel (RECOMMANDÉ)
/// Ce provider utilise un Stream pour recevoir les modifications instantanément
/// Toute création/modification/suppression d'ingrédient sera reflétée automatiquement
final ingredientStreamProvider = StreamProvider<List<Ingredient>>((ref) {
  final service = ref.watch(ingredientServiceProvider);
  return service.watchIngredients();
});

/// Provider pour écouter uniquement les ingrédients actifs en temps réel (RECOMMANDÉ)
/// Ce provider utilise un Stream pour recevoir les modifications instantanément
/// Idéal pour les écrans de création/modification de pizza
final activeIngredientStreamProvider = StreamProvider<List<Ingredient>>((ref) {
  final service = ref.watch(ingredientServiceProvider);
  return service.watchIngredients().map((ingredients) {
    return ingredients.where((ing) => ing.isActive).toList();
  });
});

/// Provider pour charger les ingrédients par catégorie (mode snapshot, non recommandé)
/// ⚠️ Considérez utiliser ingredientStreamProvider avec filtrage manuel pour le temps réel
final ingredientsByCategoryProvider = FutureProvider.family<List<Ingredient>, IngredientCategory>(
  (ref, category) async {
    final service = ref.watch(ingredientServiceProvider);
    return await service.loadIngredientsByCategory(category);
  },
);
