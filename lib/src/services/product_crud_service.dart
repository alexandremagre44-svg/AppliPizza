// lib/src/services/product_crud_service.dart
// Service CRUD local pour pizzas et menus - utilise SharedPreferences

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../core/constants.dart';

class ProductCrudService {
  static final ProductCrudService _instance = ProductCrudService._internal();
  factory ProductCrudService() => _instance;
  ProductCrudService._internal();

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
}
