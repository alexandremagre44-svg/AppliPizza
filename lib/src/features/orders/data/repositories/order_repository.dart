// lib/src/features/orders/data/repositories/order_repository.dart
// DEPRECATED: Use FirebaseOrderRepository instead
// Service de gestion des commandes avec stockage local (SharedPreferences)
// Support pour le temps réel via Stream

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pizza_delizza/src/features/orders/data/models/order.dart';

@deprecated
class OrderRepository {
  static const String _ordersKey = 'orders_list';
  
  // StreamController pour diffuser les changements en temps réel
  final _ordersController = StreamController<List<Order>>.broadcast();
  
  // Cache local des commandes
  List<Order> _cachedOrders = [];
  
  // Singleton
  static final OrderRepository _instance = OrderRepository._internal();
  factory OrderRepository() => _instance;
  OrderRepository._internal() {
    _loadOrders();
  }
  
  // Stream pour écouter les changements
  Stream<List<Order>> get ordersStream => _ordersController.stream;
  
  // Obtenir toutes les commandes (cache)
  List<Order> get orders => List.unmodifiable(_cachedOrders);
  
  // Charger les commandes depuis SharedPreferences
  Future<void> _loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString(_ordersKey);
      
      if (ordersJson != null && ordersJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(ordersJson);
        _cachedOrders = decoded.map((json) => Order.fromJson(json)).toList();
        
        // Trier par date décroissante (plus récentes en premier)
        _cachedOrders.sort((a, b) => b.date.compareTo(a.date));
      }
      
      // Notifier les listeners
      _ordersController.add(_cachedOrders);
    } catch (e) {
      print('Erreur lors du chargement des commandes: $e');
      _cachedOrders = [];
      _ordersController.add(_cachedOrders);
    }
  }
  
  // Sauvegarder les commandes dans SharedPreferences
  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = jsonEncode(_cachedOrders.map((o) => o.toJson()).toList());
      await prefs.setString(_ordersKey, ordersJson);
      
      // Notifier les listeners du changement
      _ordersController.add(_cachedOrders);
    } catch (e) {
      print('Erreur lors de la sauvegarde des commandes: $e');
    }
  }
  
  // Ajouter une nouvelle commande
  Future<void> addOrder(Order order) async {
    _cachedOrders.insert(0, order); // Ajouter au début (plus récent)
    await _saveOrders();
  }
  
  // Mettre à jour une commande existante
  Future<void> updateOrder(Order order) async {
    final index = _cachedOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      _cachedOrders[index] = order;
      await _saveOrders();
    }
  }
  
  // Changer le statut d'une commande
  Future<void> updateOrderStatus(String orderId, String newStatus, {String? note}) async {
    final index = _cachedOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _cachedOrders[index];
      final newHistory = List<OrderStatusHistory>.from(order.statusHistory ?? []);
      newHistory.add(OrderStatusHistory(
        status: newStatus,
        timestamp: DateTime.now(),
        note: note,
      ));
      
      _cachedOrders[index] = order.copyWith(
        status: newStatus,
        statusHistory: newHistory,
      );
      await _saveOrders();
    }
  }
  
  // Marquer une commande comme vue
  Future<void> markOrderAsViewed(String orderId) async {
    final index = _cachedOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _cachedOrders[index] = _cachedOrders[index].copyWith(
        isViewed: true,
        viewedAt: DateTime.now(),
      );
      await _saveOrders();
    }
  }
  
  // Supprimer une commande
  Future<void> deleteOrder(String orderId) async {
    _cachedOrders.removeWhere((o) => o.id == orderId);
    await _saveOrders();
  }
  
  // Obtenir une commande par ID
  Order? getOrderById(String orderId) {
    try {
      return _cachedOrders.firstWhere((o) => o.id == orderId);
    } catch (e) {
      return null;
    }
  }
  
  // Obtenir les commandes non vues
  List<Order> getUnviewedOrders() {
    return _cachedOrders.where((o) => !o.isViewed).toList();
  }
  
  // Obtenir les commandes par statut
  List<Order> getOrdersByStatus(String status) {
    return _cachedOrders.where((o) => o.status == status).toList();
  }
  
  // Obtenir les commandes par période
  List<Order> getOrdersByDateRange(DateTime start, DateTime end) {
    return _cachedOrders.where((o) {
      return o.date.isAfter(start.subtract(const Duration(days: 1))) &&
             o.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
  
  // Rechercher des commandes
  List<Order> searchOrders(String query) {
    final lowerQuery = query.toLowerCase();
    return _cachedOrders.where((o) {
      return o.id.toLowerCase().contains(lowerQuery) ||
             (o.customerName?.toLowerCase().contains(lowerQuery) ?? false) ||
             (o.customerPhone?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
  
  // Rafraîchir les commandes (recharger depuis SharedPreferences)
  Future<void> refresh() async {
    await _loadOrders();
  }
  
  // Nettoyer les ressources
  void dispose() {
    _ordersController.close();
  }
}
