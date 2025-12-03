// lib/services/runtime/kitchen_orders_runtime_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/models/order.dart';
import '../../src/providers/order_provider.dart';
import '../../src/services/firebase_order_service.dart';

/// Statuts de cuisine pour le module tablette
enum KitchenStatus {
  pending,
  preparing,
  ready,
  delivered,
}

/// Extension pour convertir les statuts de cuisine
extension KitchenStatusX on KitchenStatus {
  /// Convertit le statut de cuisine en statut d'ordre
  String toOrderStatus() {
    switch (this) {
      case KitchenStatus.pending:
        return OrderStatus.pending;
      case KitchenStatus.preparing:
        return OrderStatus.preparing;
      case KitchenStatus.ready:
        return OrderStatus.ready;
      case KitchenStatus.delivered:
        return OrderStatus.delivered;
    }
  }

  /// Crée un KitchenStatus à partir d'un statut d'ordre
  static KitchenStatus? fromOrderStatus(String orderStatus) {
    switch (orderStatus) {
      case OrderStatus.pending:
        return KitchenStatus.pending;
      case OrderStatus.preparing:
        return KitchenStatus.preparing;
      case OrderStatus.baking:
        // On traite la cuisson comme "en préparation" pour simplifier
        return KitchenStatus.preparing;
      case OrderStatus.ready:
        return KitchenStatus.ready;
      case OrderStatus.delivered:
        return KitchenStatus.delivered;
      default:
        return null;
    }
  }
}

/// Modèle de commande pour la cuisine
class KitchenOrder {
  final String id;
  final String orderNumber;
  final List<String> items;
  final DateTime createdAt;
  final DateTime? pickupTime;
  final KitchenStatus status;
  final bool isViewed;

  const KitchenOrder({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.createdAt,
    this.pickupTime,
    required this.status,
    required this.isViewed,
  });

  /// Crée un KitchenOrder à partir d'un Order
  factory KitchenOrder.fromOrder(Order order) {
    // Extraire les noms des produits
    final items = order.items.map((item) {
      final quantity = item.quantity;
      final name = item.productName;
      return '$quantity× $name';
    }).toList();

    // Parser la date/heure de pickup si disponible
    DateTime? pickupTime;
    if (order.pickupDate != null && order.pickupTimeSlot != null) {
      try {
        final dateParts = order.pickupDate!.split('/');
        final timeParts = order.pickupTimeSlot!.split(':');
        pickupTime = DateTime(
          int.parse(dateParts[2]), // year
          int.parse(dateParts[1]), // month
          int.parse(dateParts[0]), // day
          int.parse(timeParts[0]), // hour
          int.parse(timeParts[1]), // minute
        );
      } catch (e) {
        // Ignore parsing errors
      }
    }

    // Déterminer le statut de cuisine
    final kitchenStatus =
        KitchenStatusX.fromOrderStatus(order.status) ?? KitchenStatus.pending;

    // Générer le numéro de commande à partir de l'ID
    final orderNumber = order.id.substring(0, 8).toUpperCase();

    return KitchenOrder(
      id: order.id,
      orderNumber: orderNumber,
      items: items,
      createdAt: order.date,
      pickupTime: pickupTime,
      status: kitchenStatus,
      isViewed: order.isViewed,
    );
  }
}

/// Service runtime pour la gestion des commandes en cuisine
class KitchenOrdersRuntimeService {
  final Ref ref;

  KitchenOrdersRuntimeService(this.ref);

  /// Stream des commandes de cuisine en temps réel
  ///
  /// Filtre et trie les commandes par statut de cuisine
  Stream<List<KitchenOrder>> watchKitchenOrders() {
    // Watch le stream provider et transforme les données
    return ref.watch(ordersStreamProvider.stream).map((orders) {
      // Filtrer les commandes actives (non annulées)
      final activeOrders = orders
          .where((o) => o.status != OrderStatus.cancelled)
          .toList();

      // Convertir en KitchenOrder
      final kitchenOrders =
          activeOrders.map((o) => KitchenOrder.fromOrder(o)).toList();

      // Trier par statut puis par heure de création
      kitchenOrders.sort((a, b) {
        // D'abord par statut (ordre logique du workflow)
        final statusOrder = {
          KitchenStatus.pending: 0,
          KitchenStatus.preparing: 1,
          KitchenStatus.ready: 2,
          KitchenStatus.delivered: 3,
        };
        final statusComparison =
            statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
        if (statusComparison != 0) return statusComparison;

        // Ensuite par heure de création (plus ancien en premier)
        return a.createdAt.compareTo(b.createdAt);
      });

      return kitchenOrders;
    });
  }

  /// Met à jour le statut d'une commande
  Future<void> updateOrderStatus(
      String orderId, KitchenStatus newStatus) async {
    final orderService = ref.read(firebaseOrderServiceProvider);
    await orderService.updateOrderStatus(orderId, newStatus.toOrderStatus());
  }

  /// Marque une commande comme vue
  Future<void> markOrderAsViewed(String orderId) async {
    final orderService = ref.read(firebaseOrderServiceProvider);
    await orderService.markAsSeenByKitchen(orderId);
  }
}

/// Provider pour le service runtime des commandes de cuisine
final kitchenOrdersRuntimeServiceProvider =
    Provider<KitchenOrdersRuntimeService>((ref) {
  return KitchenOrdersRuntimeService(ref);
});
