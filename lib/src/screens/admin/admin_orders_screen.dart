// lib/src/screens/admin/admin_orders_screen.dart
// Écran de gestion des commandes (Admin)

import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  String _selectedStatus = 'Tous';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _statusOptions = [
    'Tous',
    'En préparation',
    'En livraison',
    'Livrée',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await _orderService.loadAllOrders();
    setState(() {
      _orders = orders;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    _filteredOrders = _orders.where((order) {
      // Filtre par statut
      if (_selectedStatus != 'Tous' && order.status != _selectedStatus) {
        return false;
      }
      
      // Filtre par date
      if (_startDate != null && order.date.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && order.date.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }
      
      return true;
    }).toList();
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    final success = await _orderService.updateOrderStatus(order.id, newStatus);
    if (success) {
      _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour: $newStatus')),
        );
      }
    }
  }

  Future<void> _showStatsDialog() async {
    final stats = await _orderService.getSalesStats();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques des Ventes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Commandes totales', stats['totalOrders'].toString()),
              _buildStatRow('Revenu total', '${stats['totalRevenue'].toStringAsFixed(2)} €'),
              _buildStatRow('Panier moyen', '${stats['averageOrderValue'].toStringAsFixed(2)} €'),
              const Divider(height: 24),
              Text('Aujourd\'hui', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildStatRow('Commandes', stats['todayOrders'].toString()),
              _buildStatRow('Revenu', '${stats['todayRevenue'].toStringAsFixed(2)} €'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _applyFilters();
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Commandes'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showStatsDialog,
            tooltip: 'Statistiques',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.all(VisualConstants.paddingMedium),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _selectDateRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(_startDate != null ? 'Filtré' : 'Date'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _startDate != null ? AppTheme.primaryRed : null,
                        foregroundColor: _startDate != null ? Colors.white : null,
                      ),
                    ),
                    if (_startDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearDateFilter,
                      ),
                  ],
                ),
                if (_startDate != null && _endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Du ${_startDate!.day}/${_startDate!.month}/${_startDate!.year} au ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),

          // Liste des commandes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune commande',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedStatus != 'Tous' || _startDate != null
                                  ? 'Aucune commande avec ces filtres'
                                  : 'Les commandes apparaîtront ici',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            return _buildOrderCard(order);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final formattedDate = '${order.date.day.toString().padLeft(2, '0')}/'
        '${order.date.month.toString().padLeft(2, '0')}/'
        '${order.date.year} ${order.date.hour.toString().padLeft(2, '0')}:'
        '${order.date.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(order.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getStatusIcon(order.status),
            color: _getStatusColor(order.status),
          ),
        ),
        title: Text(
          'Commande #${order.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(formattedDate),
            const SizedBox(height: 4),
            _buildStatusChip(order.status),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${order.total.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: AppTheme.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          // Liste des articles
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: Icon(Icons.local_pizza, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${item.quantity} x ${item.price.toStringAsFixed(2)}€',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          if (item.customDescription != null)
                            Text(
                              item.customDescription!,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.total.toStringAsFixed(2)}€',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          // Actions de changement de statut
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Changer le statut:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (order.status != 'En préparation')
                _buildStatusButton(order, 'En préparation', Colors.orange),
              if (order.status != 'En livraison')
                _buildStatusButton(order, 'En livraison', Colors.blue),
              if (order.status != 'Livrée')
                _buildStatusButton(order, 'Livrée', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(Order order, String status, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _updateOrderStatus(order, status),
      icon: Icon(_getStatusIcon(status), size: 16),
      label: Text(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'livrée':
        return Colors.green;
      case 'en préparation':
        return Colors.orange;
      case 'en livraison':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'livrée':
        return Icons.check_circle;
      case 'en préparation':
        return Icons.restaurant;
      case 'en livraison':
        return Icons.delivery_dining;
      default:
        return Icons.info;
    }
  }
}
