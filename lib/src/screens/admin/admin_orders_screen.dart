// lib/src/screens/admin/admin_orders_screen.dart
// Écran de gestion des commandes pour admin - Vue complète

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_status_badge.dart';
import '../../widgets/order_detail_panel.dart';
import '../../widgets/new_order_notification.dart';

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});
  
  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  Order? _selectedOrder;
  final _searchController = TextEditingController();
  int _previousUnviewedCount = 0;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _showOrderDetail(Order order) {
    setState(() {
      _selectedOrder = order;
    });
  }
  
  void _closeOrderDetail() {
    setState(() {
      _selectedOrder = null;
    });
  }
  
  Future<void> _refresh() async {
    await OrderService().refresh();
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final viewState = ref.watch(ordersViewProvider);
    final filteredOrders = ref.watch(filteredOrdersProvider);
    final unviewedCount = ref.watch(unviewedOrdersCountProvider);
    
    // Détecter nouvelles commandes non vues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (unviewedCount > _previousUnviewedCount && _previousUnviewedCount > 0) {
        OrderNotificationOverlay.show(
          context,
          orderCount: unviewedCount,
          onViewOrder: () {
            // Afficher la première commande non vue
            final unviewed = ref.read(unviewedOrdersProvider);
            if (unviewed.isNotEmpty) {
              _showOrderDetail(unviewed.first);
            }
          },
        );
      }
      _previousUnviewedCount = unviewedCount;
    });
    
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final showSplitView = isLandscape && _selectedOrder != null;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shopping_bag, size: 24),
            const SizedBox(width: 12),
            const Text('Gestion des Commandes'),
            if (unviewedCount > 0) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unviewedCount',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          // Toggle vue
          IconButton(
            icon: Icon(
              viewState.isTableView ? Icons.grid_view : Icons.table_rows,
            ),
            onPressed: () {
              ref.read(ordersViewProvider.notifier).toggleView();
            },
            tooltip: viewState.isTableView ? 'Vue cartes' : 'Vue tableau',
          ),
          // Filtres
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtres',
          ),
          // Rafraîchir
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: showSplitView
          ? Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildOrdersList(filteredOrders, viewState),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 2,
                  child: OrderDetailPanel(
                    order: _selectedOrder!,
                    onClose: _closeOrderDetail,
                  ),
                ),
              ],
            )
          : Stack(
              children: [
                _buildOrdersList(filteredOrders, viewState),
                if (_selectedOrder != null)
                  OrderDetailPanel(
                    order: _selectedOrder!,
                    onClose: _closeOrderDetail,
                  ),
              ],
            ),
    );
  }
  
  Widget _buildOrdersList(List<Order> orders, OrdersViewState viewState) {
    return Column(
      children: [
        // Barre de recherche et filtres actifs
        Container(
          padding: AppSpacing.paddingMD,
          color: AppColors.surfaceWhite,
          child: Column(
            children: [
              // Barre de recherche
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher (n° commande, client...)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(ordersViewProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                  ),
                  contentPadding: AppSpacing.paddingMD,
                ),
                onChanged: (value) {
                  ref.read(ordersViewProvider.notifier).setSearchQuery(value);
                },
              ),
              
              // Filtres actifs
              if (viewState.statusFilter != null ||
                  viewState.startDateFilter != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (viewState.statusFilter != null)
                        Chip(
                          label: Text(viewState.statusFilter!),
                          onDeleted: () {
                            ref.read(ordersViewProvider.notifier).setStatusFilter(null);
                          },
                        ),
                      if (viewState.startDateFilter != null)
                        Chip(
                          label: Text(
                            'Période: ${DateFormat('dd/MM').format(viewState.startDateFilter!)} - ${DateFormat('dd/MM').format(viewState.endDateFilter!)}',
                          ),
                          onDeleted: () {
                            ref.read(ordersViewProvider.notifier).setDateRange(null, null);
                          },
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Effacer'),
                        onPressed: () {
                          ref.read(ordersViewProvider.notifier).clearFilters();
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        // Liste des commandes
        Expanded(
          child: orders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: viewState.isTableView
                      ? _buildTableView(orders)
                      : _buildCardView(orders),
                ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune commande',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les commandes apparaîtront ici',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTableView(List<Order> orders) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            AppColors.primaryRed.withOpacity(0.1),
          ),
          columns: [
            DataColumn(
              label: Text('N° Commande', style: AppTextStyles.labelLarge),
              onSort: (_, __) {
                ref.read(ordersViewProvider.notifier).setSortBy(OrdersSortBy.date);
              },
            ),
            DataColumn(
              label: Text('Client', style: AppTextStyles.labelLarge),
              onSort: (_, __) {
                ref.read(ordersViewProvider.notifier).setSortBy(OrdersSortBy.customer);
              },
            ),
            DataColumn(
              label: Text('Heure', style: AppTextStyles.labelLarge),
              onSort: (_, __) {
                ref.read(ordersViewProvider.notifier).setSortBy(OrdersSortBy.date);
              },
            ),
            DataColumn(
              label: Text('Total', style: AppTextStyles.labelLarge),
              numeric: true,
              onSort: (_, __) {
                ref.read(ordersViewProvider.notifier).setSortBy(OrdersSortBy.total);
              },
            ),
            DataColumn(
              label: Text('Statut', style: AppTextStyles.labelLarge),
              onSort: (_, __) {
                ref.read(ordersViewProvider.notifier).setSortBy(OrdersSortBy.status);
              },
            ),
            const DataColumn(
              label: Text('Actions'),
            ),
          ],
          rows: orders.map((order) {
            return DataRow(
              selected: !order.isViewed,
              cells: [
                DataCell(
                  Text(
                    '#${order.id.substring(0, 8)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: order.isViewed ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  onTap: () => _showOrderDetail(order),
                ),
                DataCell(
                  Text(
                    order.customerName ?? 'Client',
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () => _showOrderDetail(order),
                ),
                DataCell(
                  Text(
                    DateFormat('HH:mm').format(order.date),
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () => _showOrderDetail(order),
                ),
                DataCell(
                  Text(
                    '${order.total.toStringAsFixed(2)} €',
                    style: AppTextStyles.price,
                  ),
                  onTap: () => _showOrderDetail(order),
                ),
                DataCell(
                  OrderStatusBadge(status: order.status, compact: true),
                  onTap: () => _showOrderDetail(order),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _showOrderDetail(order),
                    tooltip: 'Voir détails',
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildCardView(List<Order> orders) {
    return GridView.builder(
      padding: AppSpacing.paddingMD,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.2,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }
  
  Widget _buildOrderCard(Order order) {
    return Card(
      elevation: order.isViewed ? 2 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardLarge,
        side: order.isViewed
            ? BorderSide.none
            : const BorderSide(color: AppColors.primaryRed, width: 2),
      ),
      child: InkWell(
        onTap: () => _showOrderDetail(order),
        borderRadius: AppRadius.cardLarge,
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '#${order.id.substring(0, 8)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: order.isViewed ? FontWeight.w600 : FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!order.isViewed)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Client et heure
              Text(
                order.customerName ?? 'Client',
                style: AppTextStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(order.date),
                style: AppTextStyles.bodySmall,
              ),
              
              const Spacer(),
              
              // Statut
              OrderStatusBadge(status: order.status, compact: true),
              
              const SizedBox(height: 8),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '${order.total.toStringAsFixed(2)} €',
                    style: AppTextStyles.price,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(ordersViewProvider);
    
    return AlertDialog(
      title: const Text('Filtres'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtre par statut
            Text(
              'Statut',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: OrderStatus.all.map((status) {
                final isSelected = viewState.statusFilter == status;
                return FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (selected) {
                    ref.read(ordersViewProvider.notifier).setStatusFilter(
                      selected ? status : null,
                    );
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Filtre par période
            Text(
              'Période',
              style: AppTextStyles.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Aujourd\'hui'),
                  selected: _isToday(viewState),
                  onSelected: (selected) {
                    if (selected) {
                      final now = DateTime.now();
                      ref.read(ordersViewProvider.notifier).setDateRange(
                        DateTime(now.year, now.month, now.day),
                        DateTime(now.year, now.month, now.day, 23, 59, 59),
                      );
                    } else {
                      ref.read(ordersViewProvider.notifier).setDateRange(null, null);
                    }
                  },
                ),
                FilterChip(
                  label: const Text('Cette semaine'),
                  selected: _isThisWeek(viewState),
                  onSelected: (selected) {
                    if (selected) {
                      final now = DateTime.now();
                      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                      ref.read(ordersViewProvider.notifier).setDateRange(
                        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
                        DateTime(now.year, now.month, now.day, 23, 59, 59),
                      );
                    } else {
                      ref.read(ordersViewProvider.notifier).setDateRange(null, null);
                    }
                  },
                ),
                FilterChip(
                  label: const Text('Ce mois'),
                  selected: _isThisMonth(viewState),
                  onSelected: (selected) {
                    if (selected) {
                      final now = DateTime.now();
                      ref.read(ordersViewProvider.notifier).setDateRange(
                        DateTime(now.year, now.month, 1),
                        DateTime(now.year, now.month, now.day, 23, 59, 59),
                      );
                    } else {
                      ref.read(ordersViewProvider.notifier).setDateRange(null, null);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(ordersViewProvider.notifier).clearFilters();
            Navigator.of(context).pop();
          },
          child: const Text('Réinitialiser'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
  
  bool _isToday(OrdersViewState state) {
    if (state.startDateFilter == null) return false;
    final now = DateTime.now();
    return state.startDateFilter!.year == now.year &&
           state.startDateFilter!.month == now.month &&
           state.startDateFilter!.day == now.day;
  }
  
  bool _isThisWeek(OrdersViewState state) {
    if (state.startDateFilter == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return state.startDateFilter!.year == startOfWeek.year &&
           state.startDateFilter!.month == startOfWeek.month &&
           state.startDateFilter!.day == startOfWeek.day;
  }
  
  bool _isThisMonth(OrdersViewState state) {
    if (state.startDateFilter == null) return false;
    final now = DateTime.now();
    return state.startDateFilter!.year == now.year &&
           state.startDateFilter!.month == now.month &&
           state.startDateFilter!.day == 1;
  }
}
