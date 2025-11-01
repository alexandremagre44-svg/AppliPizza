// lib/src/screens/admin/admin_stats_screen.dart
import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/product_crud_service.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  final OrderService _orderService = OrderService();
  final ProductCrudService _productService = ProductCrudService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  Map<String, int> _productSales = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await _orderService.getSalesStats();
    final orders = await _orderService.loadAllOrders();
    
    // Calculer les produits les plus vendus
    final productSales = <String, int>{};
    for (final order in orders) {
      for (final item in order.items) {
        productSales[item.productName] = (productSales[item.productName] ?? 0) + item.quantity;
      }
    }
    
    // Trier par ventes
    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    setState(() {
      _stats = stats;
      _productSales = Map.fromEntries(sortedProducts.take(10));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                children: [
                  Text('Vue d\'ensemble', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildStatCard(
                        'Commandes totales',
                        _stats['totalOrders'].toString(),
                        Icons.shopping_bag,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Revenu total',
                        '${_stats['totalRevenue'].toStringAsFixed(2)}€',
                        Icons.euro,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Panier moyen',
                        '${_stats['averageOrderValue'].toStringAsFixed(2)}€',
                        Icons.trending_up,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Aujourd\'hui',
                        '${_stats['todayOrders']} cmd',
                        Icons.today,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Produits les plus vendus', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  if (_productSales.isEmpty)
                    const Center(child: Text('Aucune donnée'))
                  else
                    ..._productSales.entries.map((entry) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryRed.withOpacity(0.1),
                            child: Icon(Icons.local_pizza, color: AppTheme.primaryRed),
                          ),
                          title: Text(entry.key),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${entry.value}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
