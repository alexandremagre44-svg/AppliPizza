// lib/src/features/product/data/repositories/product_crud_repository.dart
// Service CRUD local pour pizzas et menus - utilise SharedPreferences

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pizza_delizza/src/features/product/data/models/product.dart';
import '../core/constants.dart';

class ProductCrudRepository {
  static final ProductCrudRepository _instance = ProductCrudRepository._internal();
  factory ProductCrudRepository() => _instance;
  ProductCrudRepository._internal();

  /// Charger les pizzas depuis le stockage local
  Future<List<Product>> loadPizzas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pizzasJson = prefs.getString(StorageKeys.pizzasList);
    
    if (pizzasJson == null || pizzasJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(pizzasJson);
      return decoded.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error loading pizzas: $e');
      return [];
    }
  }

  /// Sauvegarder les pizzas dans le stockage local
  Future<bool> savePizzas(List<Product> pizzas) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = pizzas.map((p) => p.toJson()).toList();
      final String encoded = jsonEncode(jsonList);
      return await prefs.setString(StorageKeys.pizzasList, encoded);
    } catch (e) {
      print('Error saving pizzas: $e');
      return false;
    }
  }

  /// Charger les menus depuis le stockage local
  Future<List<Product>> loadMenus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? menusJson = prefs.getString(StorageKeys.menusList);
    
    if (menusJson == null || menusJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(menusJson);
      return decoded.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error loading menus: $e');
      return [];
    }
  }

  /// Sauvegarder les menus dans le stockage local
  Future<bool> saveMenus(List<Product> menus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = menus.map((m) => m.toJson()).toList();
      final String encoded = jsonEncode(jsonList);
      return await prefs.setString(StorageKeys.menusList, encoded);
    } catch (e) {
      print('Error saving menus: $e');
      return false;
    }
  }

  /// Ajouter une pizza
  Future<bool> addPizza(Product pizza) async {
    final pizzas = await loadPizzas();
    pizzas.add(pizza);
    return await savePizzas(pizzas);
  }

  /// Modifier une pizza
  Future<bool> updatePizza(Product updatedPizza) async {
    final pizzas = await loadPizzas();
    final index = pizzas.indexWhere((p) => p.id == updatedPizza.id);
    
    if (index == -1) return false;
    
    pizzas[index] = updatedPizza;
    return await savePizzas(pizzas);
  }

  /// Supprimer une pizza
  Future<bool> deletePizza(String pizzaId) async {
    final pizzas = await loadPizzas();
    pizzas.removeWhere((p) => p.id == pizzaId);
    return await savePizzas(pizzas);
  }

  /// Ajouter un menu
  Future<bool> addMenu(Product menu) async {
    final menus = await loadMenus();
    menus.add(menu);
    return await saveMenus(menus);
  }

  /// Modifier un menu
  Future<bool> updateMenu(Product updatedMenu) async {
    final menus = await loadMenus();
    final index = menus.indexWhere((m) => m.id == updatedMenu.id);
    
    if (index == -1) return false;
    
    menus[index] = updatedMenu;
    return await saveMenus(menus);
  }

  /// Supprimer un menu
  Future<bool> deleteMenu(String menuId) async {
    final menus = await loadMenus();
    menus.removeWhere((m) => m.id == menuId);
    return await saveMenus(menus);
  }

  // ========================================
  // CRUD pour les Boissons
  // ========================================

  /// Charger les boissons depuis le stockage local
  Future<List<Product>> loadDrinks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? drinksJson = prefs.getString(StorageKeys.drinksList);
    
    if (drinksJson == null || drinksJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(drinksJson);
      return decoded.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error loading drinks: $e');
      return [];
    }
  }

  /// Sauvegarder les boissons dans le stockage local
  Future<bool> saveDrinks(List<Product> drinks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = drinks.map((d) => d.toJson()).toList();
      final String encoded = jsonEncode(jsonList);
      return await prefs.setString(StorageKeys.drinksList, encoded);
    } catch (e) {
      print('Error saving drinks: $e');
      return false;
    }
  }

  /// Ajouter une boisson
  Future<bool> addDrink(Product drink) async {
    final drinks = await loadDrinks();
    drinks.add(drink);
    return await saveDrinks(drinks);
  }

  /// Modifier une boisson
  Future<bool> updateDrink(Product updatedDrink) async {
    final drinks = await loadDrinks();
    final index = drinks.indexWhere((d) => d.id == updatedDrink.id);
    
    if (index == -1) return false;
    
    drinks[index] = updatedDrink;
    return await saveDrinks(drinks);
  }

  /// Supprimer une boisson
  Future<bool> deleteDrink(String drinkId) async {
    final drinks = await loadDrinks();
    drinks.removeWhere((d) => d.id == drinkId);
    return await saveDrinks(drinks);
  }

  // ========================================
  // CRUD pour les Desserts
  // ========================================

  /// Charger les desserts depuis le stockage local
  Future<List<Product>> loadDesserts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dessertsJson = prefs.getString(StorageKeys.dessertsList);
    
    if (dessertsJson == null || dessertsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(dessertsJson);
      return decoded.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error loading desserts: $e');
      return [];
    }
  }

  /// Sauvegarder les desserts dans le stockage local
  Future<bool> saveDesserts(List<Product> desserts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = desserts.map((d) => d.toJson()).toList();
      final String encoded = jsonEncode(jsonList);
      return await prefs.setString(StorageKeys.dessertsList, encoded);
    } catch (e) {
      print('Error saving desserts: $e');
      return false;
    }
  }

  /// Ajouter un dessert
  Future<bool> addDessert(Product dessert) async {
    final desserts = await loadDesserts();
    desserts.add(dessert);
    return await saveDesserts(desserts);
  }

  /// Modifier un dessert
  Future<bool> updateDessert(Product updatedDessert) async {
    final desserts = await loadDesserts();
    final index = desserts.indexWhere((d) => d.id == updatedDessert.id);
    
    if (index == -1) return false;
    
    desserts[index] = updatedDessert;
    return await saveDesserts(desserts);
  }

  /// Supprimer un dessert
  Future<bool> deleteDessert(String dessertId) async {
    final desserts = await loadDesserts();
    desserts.removeWhere((d) => d.id == dessertId);
    return await saveDesserts(desserts);
  }
}
