// lib/src/services/firestore_product_service.dart
// Service pour charger et sauvegarder les produits depuis Firestore
// Note: Nécessite les dépendances Firebase dans pubspec.yaml:
//   - cloud_firestore: ^4.13.0
//   - firebase_core: ^2.24.0

import 'dart:developer' as developer;
import '../models/product.dart';

// Interface abstraite pour permettre la compatibilité avec/sans Firebase
abstract class FirestoreProductService {
  Future<List<Product>> loadPizzas();
  Future<List<Product>> loadMenus();
  Future<bool> savePizza(Product pizza);
  Future<bool> saveMenu(Product menu);
  Future<bool> deletePizza(String pizzaId);
  Future<bool> deleteMenu(String menuId);
}

// Implémentation mock pour quand Firebase n'est pas disponible
class MockFirestoreProductService implements FirestoreProductService {
  @override
  Future<List<Product>> loadPizzas() async {
    developer.log('MockFirestoreProductService: Firebase non configuré, retourne liste vide');
    return [];
  }

  @override
  Future<List<Product>> loadMenus() async {
    developer.log('MockFirestoreProductService: Firebase non configuré, retourne liste vide');
    return [];
  }

  @override
  Future<bool> savePizza(Product pizza) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, sauvegarde ignorée');
    return false;
  }

  @override
  Future<bool> saveMenu(Product menu) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, sauvegarde ignorée');
    return false;
  }

  @override
  Future<bool> deletePizza(String pizzaId) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, suppression ignorée');
    return false;
  }

  @override
  Future<bool> deleteMenu(String menuId) async {
    developer.log('MockFirestoreProductService: Firebase non configuré, suppression ignorée');
    return false;
  }
}

// Implémentation réelle avec Firestore
// Décommentez et utilisez cette classe si vous avez Firebase configuré
/*
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProductServiceImpl implements FirestoreProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<List<Product>> loadPizzas() async {
    try {
      developer.log('🔥 FirestoreProductService: Chargement des pizzas depuis Firestore...');
      
      final snapshot = await _firestore
          .collection('pizzas')
          .get();
      
      final pizzas = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Assurer que l'ID est présent
            return Product.fromJson(data);
          })
          .toList();
      
      developer.log('📦 Nombre de pizzas trouvées dans Firestore: ${pizzas.length}');
      developer.log('✅ Pizzas chargées depuis Firestore et mises en cache localement');
      
      return pizzas;
    } catch (e) {
      developer.log('❌ Erreur lors du chargement des pizzas Firestore: $e');
      return [];
    }
  }

  @override
  Future<List<Product>> loadMenus() async {
    try {
      developer.log('🔥 FirestoreProductService: Chargement des menus depuis Firestore...');
      
      final snapshot = await _firestore
          .collection('menus')
          .get();
      
      final menus = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Product.fromJson(data);
          })
          .toList();
      
      developer.log('📦 Nombre de menus trouvés dans Firestore: ${menus.length}');
      
      return menus;
    } catch (e) {
      developer.log('❌ Erreur lors du chargement des menus Firestore: $e');
      return [];
    }
  }

  @override
  Future<bool> savePizza(Product pizza) async {
    try {
      await _firestore
          .collection('pizzas')
          .doc(pizza.id)
          .set(pizza.toJson());
      
      developer.log('✅ Pizza sauvegardée dans Firestore: ${pizza.name}');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la sauvegarde de la pizza: $e');
      return false;
    }
  }

  @override
  Future<bool> saveMenu(Product menu) async {
    try {
      await _firestore
          .collection('menus')
          .doc(menu.id)
          .set(menu.toJson());
      
      developer.log('✅ Menu sauvegardé dans Firestore: ${menu.name}');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la sauvegarde du menu: $e');
      return false;
    }
  }

  @override
  Future<bool> deletePizza(String pizzaId) async {
    try {
      await _firestore
          .collection('pizzas')
          .doc(pizzaId)
          .delete();
      
      developer.log('✅ Pizza supprimée de Firestore: $pizzaId');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la suppression de la pizza: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteMenu(String menuId) async {
    try {
      await _firestore
          .collection('menus')
          .doc(menuId)
          .delete();
      
      developer.log('✅ Menu supprimé de Firestore: $menuId');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la suppression du menu: $e');
      return false;
    }
  }
}
*/

// Factory pour créer le bon service selon la configuration
FirestoreProductService createFirestoreProductService() {
  // Si vous avez Firebase configuré, retournez FirestoreProductServiceImpl()
  // return FirestoreProductServiceImpl();
  
  // Sinon, retournez le mock
  return MockFirestoreProductService();
}
