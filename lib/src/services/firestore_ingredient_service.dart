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
  
  /// Écoute en temps réel des ingrédients
  Stream<List<Ingredient>> watchIngredients();
  
  /// Sauvegarder un ingrédient
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
          .orderBy('order')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Ingredient.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
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
          .orderBy('order')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Ingredient.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
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
          .orderBy('order')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Ingredient.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      developer.log('Erreur lors du chargement des ingrédients par catégorie: $e');
      return [];
    }
  }

  @override
  Stream<List<Ingredient>> watchIngredients() {
    return _firestore
        .collection(_collectionName)
        .orderBy('order')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ingredient.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

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
