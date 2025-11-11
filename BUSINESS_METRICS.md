# 📊 Service de Métriques Métier

## Vue d'ensemble

Le `BusinessMetricsService` est un service d'analyse qui fournit des insights sur les performances commerciales de l'application Pizza Deli'Zza.

## Fonctionnalités

### 1. Métriques de Revenus

#### Revenus Totaux
```dart
double totalRevenue = BusinessMetricsService.calculateTotalRevenue(orders);
// Exemple: 5248.50€
```

Calcule la somme de toutes les commandes.

#### Panier Moyen
```dart
double avgOrder = BusinessMetricsService.calculateAverageOrderValue(orders);
// Exemple: 24.75€
```

Revenu total ÷ Nombre de commandes = Panier moyen

### 2. Analyse des Commandes

#### Commandes par Statut
```dart
Map<String, int> ordersByStatus = BusinessMetricsService.countOrdersByStatus(orders);
// {
//   'Attente': 12,
//   'Préparation': 8,
//   'Prête': 5,
//   'Livrée': 156
// }
```

Répartition des commandes selon leur statut actuel.

#### Commandes par Heure
```dart
Map<int, int> ordersByHour = BusinessMetricsService.getOrdersByHour(orders);
// {
//   12: 15,  // 15 commandes à midi
//   19: 42,  // 42 commandes à 19h (heure de pointe!)
//   20: 38
// }
```

Identifie les heures de rush pour optimiser le personnel.

### 3. Analyse des Produits

#### Produits les Plus Vendus
```dart
List<ProductSalesMetric> topProducts = BusinessMetricsService.getMostSoldProducts(
  orders,
  limit: 10
);
// [
//   ProductSalesMetric(
//     productName: '4 Fromages',
//     quantitySold: 156,
//     revenue: 2496.00€
//   ),
//   ProductSalesMetric(
//     productName: 'Pepperoni',
//     quantitySold: 142,
//     revenue: 2115.80€
//   ),
//   ...
// ]
```

Top N produits triés par quantité vendue.

#### Revenus par Catégorie
```dart
Map<String, double> revenueByCategory = BusinessMetricsService.getRevenueByCategory(
  orders,
  allProducts
);
// {
//   'Pizza': 4200.50€,
//   'Boissons': 385.00€,
//   'Menu': 663.00€
// }
```

Permet d'identifier les catégories les plus rentables.

### 4. Métriques Client

#### Rétention Client
```dart
CustomerRetentionMetric retention = BusinessMetricsService.calculateCustomerRetention(orders);
// CustomerRetentionMetric(
//   totalCustomers: 87,
//   returningCustomers: 34,
//   retentionRate: 39.1%  // 34/87 * 100
// )
```

Mesure la fidélité des clients.

#### Taux de Conversion
```dart
double conversionRate = BusinessMetricsService.calculateConversionRate(
  totalVisits: 1200,
  completedOrders: 180
);
// 15.0%  // 180/1200 * 100
```

Visiteurs qui deviennent clients payants.

### 5. Métriques Opérationnelles

#### Temps Moyen de Préparation
```dart
Duration? avgPrepTime = BusinessMetricsService.calculateAveragePreparationTime(orders);
// Duration(minutes: 22)
```

Pour optimiser les processus de cuisine.

## Rapport Complet

### Génération d'un Rapport
```dart
BusinessReport report = BusinessMetricsService.generateReport(
  orders: allOrders,
  products: allProducts,
  totalVisits: 1200
);
```

### Contenu du Rapport
```dart
class BusinessReport {
  final double totalRevenue;              // 5248.50€
  final double averageOrderValue;         // 24.75€
  final int totalOrders;                  // 212
  final Map<String, int> ordersByStatus;  // Répartition
  final List<ProductSalesMetric> topProducts;  // Top 5
  final Map<String, double> revenueByCategory; // Par catégorie
  final double conversionRate;            // 15.0%
  final CustomerRetentionMetric customerRetention; // 39.1%
}
```

### Affichage Formaté
```dart
print(report.toFormattedString());
```

Sortie :
```
═══════════════════════════════════════
        RAPPORT DE MÉTRIQUES MÉTIER
═══════════════════════════════════════

📊 REVENUS ET COMMANDES
  • Revenu total: 5248.50€
  • Panier moyen: 24.75€
  • Nombre de commandes: 212
  • Taux de conversion: 15.0%

📋 STATUT DES COMMANDES
  • Attente: 12
  • Préparation: 8
  • Prête: 5
  • Livrée: 156

🏆 TOP 5 PRODUITS LES PLUS VENDUS
  1. 4 Fromages - 156 vendus (2496.00€)
  2. Pepperoni - 142 vendus (2115.80€)
  3. Margherita Classique - 98 vendus (1225.00€)
  4. Menu Duo - 45 vendus (1170.00€)
  5. Chicken Barbecue - 38 vendus (589.00€)

💰 REVENUS PAR CATÉGORIE
  • Pizza: 4200.50€
  • Boissons: 385.00€
  • Menu: 663.00€

👥 RÉTENTION CLIENT
  • Total clients: 87
  • Clients récurrents: 34
  • Taux de rétention: 39.1%

═══════════════════════════════════════
```

## Utilisation dans l'Admin

### 1. Dashboard Admin

```dart
// Dans AdminDashboardScreen
class AdminDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final products = ref.watch(productListProvider);
    
    // Générer le rapport
    final report = BusinessMetricsService.generateReport(
      orders: orders,
      products: products,
      totalVisits: 1200 // À obtenir d'Analytics
    );
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildRevenueCard(report.totalRevenue, report.averageOrderValue),
            _buildOrdersCard(report.totalOrders, report.ordersByStatus),
            _buildTopProductsCard(report.topProducts),
            _buildRetentionCard(report.customerRetention),
          ],
        ),
      ),
    );
  }
}
```

### 2. Écran de Statistiques Détaillées

```dart
// Créer un nouvel écran
class StatisticsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final products = ref.watch(productListProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('Statistiques Détaillées')),
      body: FutureBuilder(
        future: _loadMetrics(orders, products),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          
          final report = snapshot.data as BusinessReport;
          
          return ListView(
            children: [
              // Graphiques de revenus
              RevenueChart(report: report),
              
              // Graphiques des commandes par heure
              OrdersHourlyChart(orders: orders),
              
              // Top produits
              TopProductsList(products: report.topProducts),
              
              // Métriques client
              CustomerMetricsCard(retention: report.customerRetention),
            ],
          );
        },
      ),
    );
  }
}
```

### 3. Export de Rapport

```dart
// Fonction pour exporter le rapport
Future<void> exportReport() async {
  final report = BusinessMetricsService.generateReport(
    orders: orders,
    products: products,
    totalVisits: 1200
  );
  
  // Format texte
  final textReport = report.toFormattedString();
  
  // Sauvegarder ou envoyer par email
  await saveToFile(textReport);
  // ou
  await sendByEmail(textReport);
}
```

## Cas d'Usage Métier

### 1. Planification du Personnel
```dart
// Identifier les heures de pointe
final ordersByHour = BusinessMetricsService.getOrdersByHour(orders);
final peakHours = ordersByHour.entries
    .where((entry) => entry.value > 30)
    .map((entry) => entry.key)
    .toList();

print('Heures de pointe: ${peakHours.join(', ')}h');
// Résultat: "Heures de pointe: 12, 13, 19, 20h"
// Action: Ajouter du personnel à ces heures
```

### 2. Gestion des Stocks
```dart
// Produits à réapprovisionner
final topProducts = BusinessMetricsService.getMostSoldProducts(orders, limit: 10);
for (final product in topProducts) {
  print('${product.productName}: ${product.quantitySold} unités');
  // Ajuster les commandes d'ingrédients selon les ventes
}
```

### 3. Stratégie Marketing
```dart
// Cibler les clients inactifs
final retention = BusinessMetricsService.calculateCustomerRetention(orders);
final inactiveCustomers = retention.totalCustomers - retention.returningCustomers;

print('$inactiveCustomers clients n\'ont commandé qu\'une seule fois');
// Action: Envoyer un code promo pour les faire revenir
```

### 4. Optimisation des Prix
```dart
// Analyser le panier moyen
final avgOrder = BusinessMetricsService.calculateAverageOrderValue(orders);

if (avgOrder < 20.0) {
  print('Panier moyen faible. Suggestions:');
  print('- Créer des menus attractifs');
  print('- Proposer des suppléments');
  print('- Offrir la livraison gratuite à partir de 25€');
}
```

### 5. Évaluation des Promotions
```dart
// Comparer avant/après promotion
final beforePromo = BusinessMetricsService.calculateTotalRevenue(ordersBefore);
final afterPromo = BusinessMetricsService.calculateTotalRevenue(ordersAfter);
final increase = ((afterPromo - beforePromo) / beforePromo) * 100;

print('Augmentation des revenus: ${increase.toStringAsFixed(1)}%');
```

## KPIs (Indicateurs Clés de Performance)

### Objectifs Recommandés

| Métrique | Objectif | Bon | Excellent |
|----------|----------|-----|-----------|
| Panier Moyen | >20€ | >25€ | >30€ |
| Taux de Conversion | >10% | >15% | >20% |
| Taux de Rétention | >30% | >40% | >50% |
| Temps de Préparation | <30min | <20min | <15min |

### Suivi dans le Temps
```dart
// Comparer mois par mois
final thisMonth = BusinessMetricsService.calculateTotalRevenue(ordersThisMonth);
final lastMonth = BusinessMetricsService.calculateTotalRevenue(ordersLastMonth);
final growth = ((thisMonth - lastMonth) / lastMonth) * 100;

print('Croissance mensuelle: ${growth.toStringAsFixed(1)}%');
```

## Intégration avec Firebase Analytics

```dart
// Envoyer les métriques à Firebase
void logBusinessMetrics(BusinessReport report) {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  analytics.logEvent(
    name: 'business_metrics',
    parameters: {
      'total_revenue': report.totalRevenue,
      'avg_order_value': report.averageOrderValue,
      'total_orders': report.totalOrders,
      'conversion_rate': report.conversionRate,
      'retention_rate': report.customerRetention.retentionRate,
    },
  );
}
```

## Limitations et Évolutions

### Limitations Actuelles
- Temps de préparation simulé (pas de données réelles)
- Pas de comparaison périodique automatique
- Pas de prédictions/forecasting

### Évolutions Futures
1. **Machine Learning** : Prédire les ventes futures
2. **A/B Testing** : Comparer différentes stratégies
3. **Segmentation Client** : Groupes VIP, occasionnels, nouveaux
4. **Alertes** : Notifications si KPI en baisse
5. **Export** : PDF, Excel, CSV

## Architecture Technique

### Classe Principale
```dart
class BusinessMetricsService {
  // Méthodes statiques (sans état)
  static double calculateTotalRevenue(List<Order> orders) { }
  static double calculateAverageOrderValue(List<Order> orders) { }
  // ...
}
```

### Modèles de Données
```dart
class ProductSalesMetric {
  final String productId;
  final String productName;
  final int quantitySold;
  final double revenue;
}

class CustomerRetentionMetric {
  final int totalCustomers;
  final int returningCustomers;
  final double retentionRate;
}

class BusinessReport {
  // Regroupe toutes les métriques
}
```

### Performance
- Complexité algorithmique : O(n) pour la plupart des calculs
- Recommandation : Cache les rapports si >1000 commandes
- Possibilité d'ajouter des index pour optimiser

---

**Version** : 1.0  
**Date** : Novembre 2025  
**Auteur** : GitHub Copilot  
**Statut** : ✅ Production Ready
