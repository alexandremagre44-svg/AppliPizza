// lib/src/services/firestore_product_service.dart
// Service Firestore pour la gestion des produits (pizzas et menus)

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'product_crud_service.dart';

class FirestoreProductService {
  static final FirestoreProductService _instance = FirestoreProductService._internal();
  factory FirestoreProductService() => _instance;
  FirestoreProductService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductCrudService _localService = ProductCrudService();

  // Collections Firestore
  static const String _pizzasCollection = 'pizzas';
  static const String _menusCollection = 'menus';

  /// ========================================
  /// PIZZAS - Opérations Firestore
  /// ========================================

  /// Charger toutes les pizzas depuis Firestore
  Future<List<Product>> loadPizzasFromFirestore() async {
    try {
      final snapshot = await _firestore.collection(_pizzasCollection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Utiliser l'ID du document Firestore
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error loading pizzas from Firestore: $e');
      return [];
    }
  }

  /// Synchroniser les pizzas: Firestore → Local
  Future<List<Product>> syncPizzasFromCloud() async {
    try {
      final cloudPizzas = await loadPizzasFromFirestore();
      await _localService.savePizzas(cloudPizzas);
      return cloudPizzas;
    } catch (e) {
      print('Error syncing pizzas from cloud: $e');
      // En cas d'erreur, retourner les données locales
      return await _localService.loadPizzas();
    }
  }

  /// Charger les pizzas (Firestore d'abord, puis local en fallback)
  Future<List<Product>> loadPizzas() async {
    try {
      print('🔥 FirestoreProductService: Chargement des pizzas depuis Firestore...');
      
      // Essayer de charger depuis Firestore
      final cloudPizzas = await loadPizzasFromFirestore();
      
      print('📦 Nombre de pizzas trouvées dans Firestore: ${cloudPizzas.length}');
      
      // Sauvegarder localement pour cache
      await _localService.savePizzas(cloudPizzas);
      
      print('✅ Pizzas chargées depuis Firestore et mises en cache localement');
      return cloudPizzas;
    } catch (e) {
      print('❌ ERREUR Firestore: $e');
      print('📱 Fallback: chargement depuis le cache local');
      // Fallback: charger depuis le stockage local
      return await _localService.loadPizzas();
    }
  }

  /// Ajouter une pizza (Firestore + Local)
  Future<bool> addPizza(Product pizza) async {
    try {
      print('🔥 FirestoreProductService: Tentative d\'ajout de pizza "${pizza.name}" à Firestore...');
      
      // Créer le document dans Firestore
      final docRef = await _firestore.collection(_pizzasCollection).add(pizza.toJson());
      
      print('✅ Pizza ajoutée à Firestore avec ID: ${docRef.id}');
      
      // Mettre à jour l'ID avec celui de Firestore
      final pizzaWithId = pizza.copyWith(id: docRef.id);
      
      // Sauvegarder localement
      await _localService.addPizza(pizzaWithId);
      
      print('✅ Pizza sauvegardée localement');
      
      return true;
    } catch (e) {
      print('❌ ERREUR lors de l\'ajout à Firestore: $e');
      print('📱 Fallback: sauvegarde locale uniquement');
      // Fallback: sauvegarder uniquement en local
      return await _localService.addPizza(pizza);
    }
  }

  /// Modifier une pizza (Firestore + Local)
  Future<bool> updatePizza(Product updatedPizza) async {
    try {
      // Mettre à jour dans Firestore
      await _firestore
          .collection(_pizzasCollection)
          .doc(updatedPizza.id)
          .set(updatedPizza.toJson());
      
      // Mettre à jour localement
      await _localService.updatePizza(updatedPizza);
      
      return true;
    } catch (e) {
      print('Error updating pizza in Firestore: $e');
      // Fallback: mettre à jour uniquement en local
      return await _localService.updatePizza(updatedPizza);
    }
  }

  /// Supprimer une pizza (Firestore + Local)
  Future<bool> deletePizza(String pizzaId) async {
    try {
      // Supprimer de Firestore
      await _firestore.collection(_pizzasCollection).doc(pizzaId).delete();
      
      // Supprimer localement
      await _localService.deletePizza(pizzaId);
      
      return true;
    } catch (e) {
      print('Error deleting pizza from Firestore: $e');
      // Fallback: supprimer uniquement en local
      return await _localService.deletePizza(pizzaId);
    }
  }

  /// ========================================
  /// MENUS - Opérations Firestore
  /// ========================================

  /// Charger tous les menus depuis Firestore
  Future<List<Product>> loadMenusFromFirestore() async {
    try {
      final snapshot = await _firestore.collection(_menusCollection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Utiliser l'ID du document Firestore
        return Product.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error loading menus from Firestore: $e');
      return [];
    }
  }

  /// Synchroniser les menus: Firestore → Local
  Future<List<Product>> syncMenusFromCloud() async {
    try {
      final cloudMenus = await loadMenusFromFirestore();
      await _localService.saveMenus(cloudMenus);
      return cloudMenus;
    } catch (e) {
      print('Error syncing menus from cloud: $e');
      // En cas d'erreur, retourner les données locales
      return await _localService.loadMenus();
    }
  }

  /// Charger les menus (Firestore d'abord, puis local en fallback)
  Future<List<Product>> loadMenus() async {
    try {
      // Essayer de charger depuis Firestore
      final cloudMenus = await loadMenusFromFirestore();
      
      // Sauvegarder localement pour cache
      await _localService.saveMenus(cloudMenus);
      
      return cloudMenus;
    } catch (e) {
      print('Firestore unavailable, using local data: $e');
      // Fallback: charger depuis le stockage local
      return await _localService.loadMenus();
    }
  }

  /// Ajouter un menu (Firestore + Local)
  Future<bool> addMenu(Product menu) async {
    try {
      // Créer le document dans Firestore
      final docRef = await _firestore.collection(_menusCollection).add(menu.toJson());
      
      // Mettre à jour l'ID avec celui de Firestore
      final menuWithId = menu.copyWith(id: docRef.id);
      
      // Sauvegarder localement
      await _localService.addMenu(menuWithId);
      
      return true;
    } catch (e) {
      print('Error adding menu to Firestore: $e');
      // Fallback: sauvegarder uniquement en local
      return await _localService.addMenu(menu);
    }
  }

  /// Modifier un menu (Firestore + Local)
  Future<bool> updateMenu(Product updatedMenu) async {
    try {
      // Mettre à jour dans Firestore
      await _firestore
          .collection(_menusCollection)
          .doc(updatedMenu.id)
          .set(updatedMenu.toJson());
      
      // Mettre à jour localement
      await _localService.updateMenu(updatedMenu);
      
      return true;
    } catch (e) {
      print('Error updating menu in Firestore: $e');
      // Fallback: mettre à jour uniquement en local
      return await _localService.updateMenu(updatedMenu);
    }
  }

  /// Supprimer un menu (Firestore + Local)
  Future<bool> deleteMenu(String menuId) async {
    try {
      // Supprimer de Firestore
      await _firestore.collection(_menusCollection).doc(menuId).delete();
      
      // Supprimer localement
      await _localService.deleteMenu(menuId);
      
      return true;
    } catch (e) {
      print('Error deleting menu from Firestore: $e');
      // Fallback: supprimer uniquement en local
      return await _localService.deleteMenu(menuId);
    }
  }

  /// ========================================
  /// SYNCHRONISATION TEMPS RÉEL
  /// ========================================

  /// Stream temps réel des pizzas
  Stream<List<Product>> watchPizzas() {
    return _firestore.collection(_pizzasCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    });
  }

  /// Stream temps réel des menus
  Stream<List<Product>> watchMenus() {
    return _firestore.collection(_menusCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Product.fromJson(data);
      }).toList();
    });
  }

  /// ========================================
  /// MIGRATION & UTILS
  /// ========================================

  /// Migrer les données locales vers Firestore (à utiliser une seule fois)
  Future<void> migrateLocalToFirestore() async {
    try {
      // Migrer les pizzas
      final localPizzas = await _localService.loadPizzas();
      for (final pizza in localPizzas) {
        await _firestore.collection(_pizzasCollection).doc(pizza.id).set(pizza.toJson());
      }
      print('✅ ${localPizzas.length} pizzas migrées vers Firestore');

      // Migrer les menus
      final localMenus = await _localService.loadMenus();
      for (final menu in localMenus) {
        await _firestore.collection(_menusCollection).doc(menu.id).set(menu.toJson());
      }
      print('✅ ${localMenus.length} menus migrés vers Firestore');
    } catch (e) {
      print('❌ Erreur lors de la migration: $e');
    }
  }
}
