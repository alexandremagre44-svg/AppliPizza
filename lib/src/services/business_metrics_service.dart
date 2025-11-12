// lib/src/services/business_metrics_service.dart

import '../models/order.dart';
import '../models/product.dart';

/// Service de métriques métier pour analyser les performances de l'application
class BusinessMetricsService {
  /// Calcule les revenus totaux d'une liste de commandes
  static double calculateTotalRevenue(List<Order> orders) {
    return orders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  /// Calcule le panier moyen
  static double calculateAverageOrderValue(List<Order> orders) {
    if (orders.isEmpty) return 0.0;
    return calculateTotalRevenue(orders) / orders.length;
  }

  /// Compte le nombre de commandes par statut
  static Map<String, int> countOrdersByStatus(List<Order> orders) {
    final Map<String, int> counts = {
      'Attente': 0,
      'Préparation': 0,
      'Prête': 0,
      'Livrée': 0,
    };

    for (final order in orders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }

    return counts;
  }

  /// Identifie les produits les plus vendus
  static List<ProductSalesMetric> getMostSoldProducts(
    List<Order> orders, {
    int limit = 10,
  }) {
    final Map<String, ProductSalesMetric> productMetrics = {};

    for (final order in orders) {
      for (final item in order.items) {
        final productId = item.productId;
        
        if (!productMetrics.containsKey(productId)) {
          productMetrics[productId] = ProductSalesMetric(
            productId: productId,
            productName: item.productName,
            quantitySold: 0,
            revenue: 0.0,
          );
        }

        productMetrics[productId] = productMetrics[productId]!.copyWith(
          quantitySold: productMetrics[productId]!.quantitySold + item.quantity,
          revenue: productMetrics[productId]!.revenue + (item.price * item.quantity),
        );
      }
    }

    final sortedMetrics = productMetrics.values.toList()
      ..sort((a, b) => b.quantitySold.compareTo(a.quantitySold));

    return sortedMetrics.take(limit).toList();
  }

  /// Calcule les revenus par catégorie de produits
  static Map<String, double> getRevenueByCategory(
    List<Order> orders,
    List<Product> allProducts,
  ) {
    final Map<String, double> categoryRevenue = {};

    // Créer une map pour accéder rapidement aux produits
    final productMap = {for (var p in allProducts) p.id: p};

    for (final order in orders) {
      for (final item in order.items) {
        final product = productMap[item.productId];
        if (product != null) {
          final category = product.category.value;
          categoryRevenue[category] = 
              (categoryRevenue[category] ?? 0.0) + (item.price * item.quantity);
        }
      }
    }

    return categoryRevenue;
  }

  /// Calcule le taux de conversion (commandes / visiteurs)
  static double calculateConversionRate({
    required int totalVisits,
    required int completedOrders,
  }) {
    if (totalVisits == 0) return 0.0;
    return (completedOrders / totalVisits) * 100;
  }

  /// Identifie les heures de pointe pour les commandes
  static Map<int, int> getOrdersByHour(List<Order> orders) {
    final Map<int, int> hourlyOrders = {};

    for (final order in orders) {
      final hour = order.createdAt.hour;
      hourlyOrders[hour] = (hourlyOrders[hour] ?? 0) + 1;
    }

    return Map.fromEntries(
      hourlyOrders.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  /// Calcule la rétention client (clients récurrents)
  static CustomerRetentionMetric calculateCustomerRetention(List<Order> orders) {
    final Map<String, int> customerOrderCounts = {};

    for (final order in orders) {
      customerOrderCounts[order.userId] = 
          (customerOrderCounts[order.userId] ?? 0) + 1;
    }

    final totalCustomers = customerOrderCounts.length;
    final returningCustomers = 
        customerOrderCounts.values.where((count) => count > 1).length;
    final retentionRate = totalCustomers > 0
        ? (returningCustomers / totalCustomers) * 100
        : 0.0;

    return CustomerRetentionMetric(
      totalCustomers: totalCustomers,
      returningCustomers: returningCustomers,
      retentionRate: retentionRate,
    );
  }

  /// Calcule la durée moyenne de préparation des commandes
  static Duration? calculateAveragePreparationTime(List<Order> orders) {
    final completedOrders = orders.where(
      (order) => order.status == 'Livrée' || order.status == 'Prête',
    ).toList();

    if (completedOrders.isEmpty) return null;

    int totalMinutes = 0;
    for (final order in completedOrders) {
      // Simuler un temps de préparation basé sur le nombre d'articles
      // En production, vous utiliseriez un champ réel
      totalMinutes += order.items.length * 15; // 15 min par article
    }

    return Duration(minutes: totalMinutes ~/ completedOrders.length);
  }

  /// Génère un rapport complet des métriques
  static BusinessReport generateReport({
    required List<Order> orders,
    required List<Product> products,
    int totalVisits = 0,
  }) {
    final totalRevenue = calculateTotalRevenue(orders);
    final averageOrderValue = calculateAverageOrderValue(orders);
    final ordersByStatus = countOrdersByStatus(orders);
    final topProducts = getMostSoldProducts(orders, limit: 5);
    final revenueByCategory = getRevenueByCategory(orders, products);
    final completedOrders = orders.where((o) => o.status == 'Livrée').length;
    final conversionRate = calculateConversionRate(
      totalVisits: totalVisits,
      completedOrders: completedOrders,
    );
    final customerRetention = calculateCustomerRetention(orders);

    return BusinessReport(
      totalRevenue: totalRevenue,
      averageOrderValue: averageOrderValue,
      totalOrders: orders.length,
      ordersByStatus: ordersByStatus,
      topProducts: topProducts,
      revenueByCategory: revenueByCategory,
      conversionRate: conversionRate,
      customerRetention: customerRetention,
    );
  }
}

/// Métrique de vente pour un produit
class ProductSalesMetric {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;

  ProductSalesMetric({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.revenue,
  });

  ProductSalesMetric copyWith({
    String? productId,
    String? productName,
    int? quantitySold,
    double? revenue,
  }) {
    return ProductSalesMetric(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantitySold: quantitySold ?? this.quantitySold,
      revenue: revenue ?? this.revenue,
    );
  }
}

/// Métrique de rétention client
class CustomerRetentionMetric {
  final int totalCustomers;
  final int returningCustomers;
  final double retentionRate;

  CustomerRetentionMetric({
    required this.totalCustomers,
    required this.returningCustomers,
    required this.retentionRate,
  });
}

/// Rapport complet des métriques métier
class BusinessReport {
  final double totalRevenue;
  final double averageOrderValue;
  final int totalOrders;
  final Map<String, int> ordersByStatus;
  final List<ProductSalesMetric> topProducts;
  final Map<String, double> revenueByCategory;
  final double conversionRate;
  final CustomerRetentionMetric customerRetention;

  BusinessReport({
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.totalOrders,
    required this.ordersByStatus,
    required this.topProducts,
    required this.revenueByCategory,
    required this.conversionRate,
    required this.customerRetention,
  });

  /// Formate le rapport en texte lisible
  String toFormattedString() {
    final buffer = StringBuffer();
    
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('        RAPPORT DE MÉTRIQUES MÉTIER');
    buffer.writeln('═══════════════════════════════════════\n');
    
    buffer.writeln('📊 REVENUS ET COMMANDES');
    buffer.writeln('  • Revenu total: ${totalRevenue.toStringAsFixed(2)}€');
    buffer.writeln('  • Panier moyen: ${averageOrderValue.toStringAsFixed(2)}€');
    buffer.writeln('  • Nombre de commandes: $totalOrders');
    buffer.writeln('  • Taux de conversion: ${conversionRate.toStringAsFixed(1)}%\n');
    
    buffer.writeln('📋 STATUT DES COMMANDES');
    ordersByStatus.forEach((status, count) {
      buffer.writeln('  • $status: $count');
    });
    buffer.writeln();
    
    buffer.writeln('🏆 TOP 5 PRODUITS LES PLUS VENDUS');
    for (var i = 0; i < topProducts.length; i++) {
      final product = topProducts[i];
      buffer.writeln(
        '  ${i + 1}. ${product.productName} - ${product.quantitySold} vendus (${product.revenue.toStringAsFixed(2)}€)',
      );
    }
    buffer.writeln();
    
    buffer.writeln('💰 REVENUS PAR CATÉGORIE');
    revenueByCategory.forEach((category, revenue) {
      buffer.writeln('  • $category: ${revenue.toStringAsFixed(2)}€');
    });
    buffer.writeln();
    
    buffer.writeln('👥 RÉTENTION CLIENT');
    buffer.writeln('  • Total clients: ${customerRetention.totalCustomers}');
    buffer.writeln('  • Clients récurrents: ${customerRetention.returningCustomers}');
    buffer.writeln('  • Taux de rétention: ${customerRetention.retentionRate.toStringAsFixed(1)}%\n');
    
    buffer.writeln('═══════════════════════════════════════');
    
    return buffer.toString();
  }
}
