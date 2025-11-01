// lib/src/services/order_service.dart
// Service pour gérer toutes les commandes (admin)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';

class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  static const String _ordersKey = 'all_orders';

  /// Charger toutes les commandes
  Future<List<Order>> loadAllOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersJson = prefs.getString(_ordersKey);
    
    if (ordersJson == null || ordersJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(ordersJson);
      return decoded.map((json) => _orderFromJson(json)).toList();
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }

  /// Sauvegarder toutes les commandes
  Future<bool> saveAllOrders(List<Order> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = orders.map((o) => _orderToJson(o)).toList();
      final String encoded = jsonEncode(jsonList);
      return await prefs.setString(_ordersKey, encoded);
    } catch (e) {
      print('Error saving orders: $e');
      return false;
    }
  }

  /// Ajouter une nouvelle commande
  Future<bool> addOrder(Order order) async {
    final orders = await loadAllOrders();
    orders.insert(0, order); // Ajouter au début pour avoir les plus récentes en premier
    return await saveAllOrders(orders);
  }

  /// Mettre à jour le statut d'une commande
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    final orders = await loadAllOrders();
    final index = orders.indexWhere((o) => o.id == orderId);
    
    if (index == -1) return false;
    
    final updatedOrder = Order(
      id: orders[index].id,
      total: orders[index].total,
      date: orders[index].date,
      items: orders[index].items,
      status: newStatus,
    );
    
    orders[index] = updatedOrder;
    return await saveAllOrders(orders);
  }

  /// Filtrer les commandes par statut
  Future<List<Order>> getOrdersByStatus(String status) async {
    final orders = await loadAllOrders();
    return orders.where((o) => o.status == status).toList();
  }

  /// Filtrer les commandes par date
  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
    final orders = await loadAllOrders();
    return orders.where((o) {
      return o.date.isAfter(start.subtract(const Duration(days: 1))) && 
             o.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Statistiques de ventes
  Future<Map<String, dynamic>> getSalesStats() async {
    final orders = await loadAllOrders();
    
    if (orders.isEmpty) {
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'averageOrderValue': 0.0,
        'todayOrders': 0,
        'todayRevenue': 0.0,
      };
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final todayOrders = orders.where((o) {
      final orderDate = DateTime(o.date.year, o.date.month, o.date.day);
      return orderDate.isAtSameMomentAs(today);
    }).toList();

    final totalRevenue = orders.fold<double>(0, (sum, order) => sum + order.total);
    final todayRevenue = todayOrders.fold<double>(0, (sum, order) => sum + order.total);
    
    return {
      'totalOrders': orders.length,
      'totalRevenue': totalRevenue,
      'averageOrderValue': orders.isEmpty ? 0.0 : totalRevenue / orders.length,
      'todayOrders': todayOrders.length,
      'todayRevenue': todayRevenue,
    };
  }

  /// Conversion Order -> JSON
  Map<String, dynamic> _orderToJson(Order order) {
    return {
      'id': order.id,
      'total': order.total,
      'date': order.date.toIso8601String(),
      'status': order.status,
      'items': order.items.map((item) => {
        'id': item.id,
        'productId': item.productId,
        'productName': item.productName,
        'price': item.price,
        'quantity': item.quantity,
        'imageUrl': item.imageUrl,
        'customDescription': item.customDescription,
        'isMenu': item.isMenu,
      }).toList(),
    };
  }

  /// Conversion JSON -> Order
  Order _orderFromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>).map((itemJson) {
        return CartItem(
          id: itemJson['id'] as String,
          productId: itemJson['productId'] as String,
          productName: itemJson['productName'] as String,
          price: (itemJson['price'] as num).toDouble(),
          quantity: itemJson['quantity'] as int,
          imageUrl: itemJson['imageUrl'] as String,
          customDescription: itemJson['customDescription'] as String?,
          isMenu: itemJson['isMenu'] as bool? ?? false,
        );
      }).toList(),
    );
  }
}
