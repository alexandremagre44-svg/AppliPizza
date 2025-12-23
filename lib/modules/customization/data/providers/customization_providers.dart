// lib/modules/customization/data/providers/customization_providers.dart
// TODO: migration future — ce fichier est une copie, le code original reste la source active.
// Source originale: lib/src/providers/ingredient_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customization_option.dart';
import '../services/customization_service.dart';

/// Provider du service de customization
final customizationServiceProvider = Provider<CustomizationService>((ref) {
  return createCustomizationService();
});

/// Provider pour charger tous les ingrédients (mode snapshot, non recommandé)
/// ⚠️ Utilisez ingredientStreamProvider pour des mises à jour en temps réel
final ingredientListProvider = FutureProvider<List<Ingredient>>((ref) async {
  final service = ref.watch(customizationServiceProvider);
  return await service.loadIngredients();
});

/// Provider pour charger uniquement les ingrédients actifs (mode snapshot, non recommandé)
/// ⚠️ Utilisez activeIngredientStreamProvider pour des mises à jour en temps réel
@Deprecated('Utilisez activeIngredientStreamProvider pour des mises à jour en temps réel')
final activeIngredientListProvider = FutureProvider<List<Ingredient>>((ref) async {
  final service = ref.watch(customizationServiceProvider);
  return await service.loadActiveIngredients();
});

/// Provider pour écouter tous les ingrédients en temps réel (RECOMMANDÉ)
/// Ce provider utilise un Stream pour recevoir les modifications instantanément
/// Toute création/modification/suppression d'ingrédient sera reflétée automatiquement
final ingredientStreamProvider = StreamProvider<List<Ingredient>>((ref) {
  final service = ref.watch(customizationServiceProvider);
  return service.watchIngredients();
});

/// Provider pour écouter uniquement les ingrédients actifs en temps réel (RECOMMANDÉ)
/// Ce provider utilise un Stream pour recevoir les modifications instantanément
/// Idéal pour les écrans de création/modification de pizza
final activeIngredientStreamProvider = StreamProvider<List<Ingredient>>((ref) {
  final service = ref.watch(customizationServiceProvider);
  return service.watchIngredients().map((ingredients) {
    return ingredients.where((ing) => ing.isActive).toList();
  });
});

/// Provider pour charger les ingrédients par catégorie (mode snapshot, non recommandé)
/// ⚠️ Considérez utiliser ingredientStreamProvider avec filtrage manuel pour le temps réel
final ingredientsByCategoryProvider = FutureProvider.family<List<Ingredient>, IngredientCategory>(
  (ref, category) async {
    final service = ref.watch(customizationServiceProvider);
    return await service.loadIngredientsByCategory(category);
  },
);

/// Provider pour l'état de personnalisation en cours
/// TODO: À implémenter lors de la migration pour gérer l'état de customisation d'un produit
/// class CustomizationState {
///   final List<String> selectedIngredients;
///   final List<String> removedIngredients;
///   final String? specialInstructions;
///   ...
/// }

/// Bridge provider pour faciliter la transition entre ancien et nouveau système
/// TODO: Utilisé lors de la Phase 3 pour mapper les providers legacy vers les nouveaux
final customizationBridgeProvider = Provider<dynamic>((ref) {
  // TODO: Futur mapping depuis les providers legacy (ingredient_provider.dart)
  // Permet de faire coexister ancien et nouveau système pendant la migration
  // return CustomizationBridge(
  //   legacyProvider: ref.watch(ingredientStreamProvider),
  //   newProvider: ref.watch(ingredientStreamProvider),
  // );
  return null; // Non utilisé pour le moment - Phase 3
});

/// Provider bridge pour la compatibilité avec l'ancien système
/// TODO: À activer lors de la Phase 3 de migration
final legacyCompatibilityProvider = Provider<bool>((ref) {
  // TODO: Flag pour activer/désactiver le mode compatibilité
  // false = utilise l'ancien système (actuel)
  // true = utilise le nouveau module (futur)
  return false; // Toujours false en Phase 2
});
