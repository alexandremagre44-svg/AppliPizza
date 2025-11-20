// lib/src/services/firestore_ingredient_service.dart
// Service pour gérer les ingrédients dans Firestore

import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

/// Interface abstraite pour le service des ingrédients
abstract class FirestoreIngredientService {
  /// Charger tous les ingrédients
  Future<List<Ingredient>> loadIngredients();
  
  /// Charger les ingrédients actifs uniquement
  Future<List<Ingredient>> loadActiveIngredients();
  
  /// Charger les ingrédients par catégorie
  Future<List<Ingredient>> loadIngredientsByCategory(IngredientCategory category);
  
  /// Écoute en temps réel des ingrédients (RECOMMANDÉ pour UI réactive)
  Stream<List<Ingredient>> watchIngredients();
  
  /// Récupérer tous les ingrédients sous forme de Stream (alias pour watchIngredients)
  Stream<List<Ingredient>> getAllIngredients() => watchIngredients();
  
  /// Ajouter un nouvel ingrédient
  Future<bool> addIngredient(Ingredient ingredient) => saveIngredient(ingredient.copyWith(id: ''));
  
  /// Mettre à jour un ingrédient existant
  Future<bool> updateIngredient(Ingredient ingredient) => saveIngredient(ingredient);
  
  /// Sauvegarder un ingrédient (création ou mise à jour)
  Future<bool> saveIngredient(Ingredient ingredient);
  
  /// Supprimer un ingrédient
  Future<bool> deleteIngredient(String ingredientId);
}

/// Implémentation réelle avec Firebase
class RealFirestoreIngredientService implements FirestoreIngredientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'ingredients';

  @override
  Future<List<Ingredient>> loadIngredients() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .get();

      final ingredients = snapshot.docs
          .map((doc) => Ingredient.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort in Dart to avoid composite index requirement
      ingredients.sort((a, b) {
        final orderCompare = a.order.compareTo(b.order);
        if (orderCompare != 0) return orderCompare;
        return a.name.compareTo(b.name);
      });
      
      return ingredients;
    } catch (e) {
      developer.log('Erreur lors du chargement des ingrédients: $e');
      return [];
    }
  }

  @override
  Future<List<Ingredient>> loadActiveIngredients() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('isActive', isEqualTo: true)
          .get();

      final ingredients = snapshot.docs
          .map((doc) => Ingredient.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort in Dart to avoid composite index requirement
      ingredients.sort((a, b) {
        final orderCompare = a.order.compareTo(b.order);
        if (orderCompare != 0) return orderCompare;
        return a.name.compareTo(b.name);
      });
      
      return ingredients;
    } catch (e) {
      developer.log('Erreur lors du chargement des ingrédients actifs: $e');
      return [];
    }
  }

  @override
  Future<List<Ingredient>> loadIngredientsByCategory(IngredientCategory category) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category.name)
          .where('isActive', isEqualTo: true)
          .get();

      final ingredients = snapshot.docs
          .map((doc) => Ingredient.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort in Dart to avoid composite index requirement
      ingredients.sort((a, b) {
        final orderCompare = a.order.compareTo(b.order);
        if (orderCompare != 0) return orderCompare;
        return a.name.compareTo(b.name);
      });
      
      return ingredients;
    } catch (e) {
      developer.log('Erreur lors du chargement des ingrédients par catégorie: $e');
      return [];
    }
  }

  @override
  Stream<List<Ingredient>> watchIngredients() {
    // Stream en temps réel des ingrédients
    // Toute modification dans Firestore sera automatiquement reflétée
    // dans tous les widgets qui écoutent ce stream
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) {
          final ingredients = snapshot.docs
              .map((doc) => Ingredient.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
          
          // Sort in Dart to avoid composite index requirement
          ingredients.sort((a, b) {
            final orderCompare = a.order.compareTo(b.order);
            if (orderCompare != 0) return orderCompare;
            return a.name.compareTo(b.name);
          });
          
          return ingredients;
        });
  }

  @override
  Stream<List<Ingredient>> getAllIngredients() => watchIngredients();

  @override
  Future<bool> addIngredient(Ingredient ingredient) => saveIngredient(ingredient.copyWith(id: ''));

  @override
  Future<bool> updateIngredient(Ingredient ingredient) => saveIngredient(ingredient);

  @override
  Future<bool> saveIngredient(Ingredient ingredient) async {
    try {
      final data = ingredient.toJson();
      data.remove('id'); // L'ID est géré par Firestore

      if (ingredient.id.isEmpty) {
        // Création d'un nouvel ingrédient
        await _firestore.collection(_collectionName).add(data);
      } else {
        // Mise à jour d'un ingrédient existant
        await _firestore.collection(_collectionName).doc(ingredient.id).set(data);
      }
      
      developer.log('Ingrédient sauvegardé: ${ingredient.name}');
      return true;
    } catch (e) {
      developer.log('Erreur lors de la sauvegarde de l\'ingrédient: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteIngredient(String ingredientId) async {
    try {
      await _firestore.collection(_collectionName).doc(ingredientId).delete();
      developer.log('Ingrédient supprimé: $ingredientId');
      return true;
    } catch (e) {
      developer.log('Erreur lors de la suppression de l\'ingrédient: $e');
      return false;
    }
  }
}

/// Implémentation mock pour les tests ou quand Firebase n'est pas configuré
class MockFirestoreIngredientService implements FirestoreIngredientService {
  @override
  Future<List<Ingredient>> loadIngredients() async {
    developer.log('MockFirestoreIngredientService: Firebase non configuré');
    return [];
  }

  @override
  Future<List<Ingredient>> loadActiveIngredients() async {
    developer.log('MockFirestoreIngredientService: Firebase non configuré');
    return [];
  }

  @override
  Future<List<Ingredient>> loadIngredientsByCategory(IngredientCategory category) async {
    developer.log('MockFirestoreIngredientService: Firebase non configuré');
    return [];
  }

  @override
  Stream<List<Ingredient>> watchIngredients() {
    developer.log('MockFirestoreIngredientService: Firebase non configuré');
    return Stream.value([]);
  }

  @override
  Stream<List<Ingredient>> getAllIngredients() => watchIngredients();

  @override
  Future<bool> addIngredient(Ingredient ingredient) => saveIngredient(ingredient.copyWith(id: ''));

  @override
  Future<bool> updateIngredient(Ingredient ingredient) => saveIngredient(ingredient);

  @override
  Future<bool> saveIngredient(Ingredient ingredient) async {
    developer.log('MockFirestoreIngredientService: Firebase non configuré');
    return false;
  }

  @override
  Future<bool> deleteIngredient(String ingredientId) async {
    developer.log('MockFirestoreIngredientService: Firebase non configuré');
    return false;
  }
}

/// Factory pour créer le service approprié
FirestoreIngredientService createFirestoreIngredientService() {
  try {
    FirebaseFirestore.instance;
    return RealFirestoreIngredientService();
  } catch (e) {
    developer.log('Firebase non initialisé, utilisation du service mock');
    return MockFirestoreIngredientService();
  }
}
