// lib/screens/kitchen_tablet/kitchen_tablet_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/runtime/kitchen_orders_runtime_service.dart';
import 'kitchen_tablet_order_card.dart';

/// Écran principal du module Tablette Cuisine
///
/// Interface professionnelle en 3 colonnes pour tablette (min 700px)
/// - Colonne 1: Commandes en attente (Pending)
/// - Colonne 2: Commandes en préparation (Preparing)
/// - Colonne 3: Commandes prêtes (Ready)
class KitchenTabletScreen extends ConsumerStatefulWidget {
  const KitchenTabletScreen({super.key});

  @override
  ConsumerState<KitchenTabletScreen> createState() =>
      _KitchenTabletScreenState();
}

class _KitchenTabletScreenState extends ConsumerState<KitchenTabletScreen> {
  /// Filtre les commandes par statut
  List<KitchenOrder> _filterByStatus(
      List<KitchenOrder> orders, KitchenStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  /// Met à jour le statut d'une commande
  Future<void> _updateOrderStatus(
      String orderId, KitchenStatus newStatus) async {
    final service = ref.read(kitchenOrdersRuntimeServiceProvider);
    try {
      await service.updateOrderStatus(orderId, newStatus);
      
      // Marquer comme vue si ce n'est pas déjà fait
      await service.markOrderAsViewed(orderId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Statut mis à jour'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(kitchenOrdersRuntimeServiceProvider);
    final ordersStream = service.watchKitchenOrders();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'TABLETTE CUISINE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          // Bouton de rafraîchissement
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<KitchenOrder>>(
          stream: ordersStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            final orders = snapshot.data ?? [];
            
            // Séparer les commandes par statut
            final pendingOrders = _filterByStatus(orders, KitchenStatus.pending);
            final preparingOrders =
                _filterByStatus(orders, KitchenStatus.preparing);
            final readyOrders = _filterByStatus(orders, KitchenStatus.ready);

            // Responsive: adapter le layout selon la largeur
            return LayoutBuilder(
              builder: (context, constraints) {
                final isTabletSize = constraints.maxWidth >= 700;

                if (!isTabletSize) {
                  // Layout mobile: une seule colonne avec tabs
                  return _buildMobileLayout(
                    pendingOrders,
                    preparingOrders,
                    readyOrders,
                  );
                }

                // Layout tablette: 3 colonnes
                return _buildTabletLayout(
                  pendingOrders,
                  preparingOrders,
                  readyOrders,
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Layout pour tablette (3 colonnes)
  Widget _buildTabletLayout(
    List<KitchenOrder> pendingOrders,
    List<KitchenOrder> preparingOrders,
    List<KitchenOrder> readyOrders,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne 1: En attente (Pending)
        Expanded(
          child: _buildColumn(
            title: 'En attente',
            icon: Icons.schedule,
            color: Theme.of(context).colorScheme.surfaceVariant,
            orders: pendingOrders,
            onAction: (order) =>
                _updateOrderStatus(order.id, KitchenStatus.preparing),
          ),
        ),
        const SizedBox(width: 16),

        // Colonne 2: En préparation (Preparing)
        Expanded(
          child: _buildColumn(
            title: 'En préparation',
            icon: Icons.restaurant,
            color: Theme.of(context).colorScheme.primaryContainer,
            orders: preparingOrders,
            onAction: (order) =>
                _updateOrderStatus(order.id, KitchenStatus.ready),
          ),
        ),
        const SizedBox(width: 16),

        // Colonne 3: Prête (Ready)
        Expanded(
          child: _buildColumn(
            title: 'Prêtes',
            icon: Icons.check_circle,
            color: Theme.of(context).colorScheme.tertiaryContainer,
            orders: readyOrders,
            onAction: (order) =>
                _updateOrderStatus(order.id, KitchenStatus.delivered),
          ),
        ),
      ],
    );
  }

  /// Layout pour mobile (avec tabs)
  Widget _buildMobileLayout(
    List<KitchenOrder> pendingOrders,
    List<KitchenOrder> preparingOrders,
    List<KitchenOrder> readyOrders,
  ) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'En attente (${pendingOrders.length})'),
              Tab(text: 'En cours (${preparingOrders.length})'),
              Tab(text: 'Prêtes (${readyOrders.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildColumn(
                  title: 'En attente',
                  icon: Icons.schedule,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  orders: pendingOrders,
                  onAction: (order) =>
                      _updateOrderStatus(order.id, KitchenStatus.preparing),
                  showHeader: false,
                ),
                _buildColumn(
                  title: 'En préparation',
                  icon: Icons.restaurant,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  orders: preparingOrders,
                  onAction: (order) =>
                      _updateOrderStatus(order.id, KitchenStatus.ready),
                  showHeader: false,
                ),
                _buildColumn(
                  title: 'Prêtes',
                  icon: Icons.check_circle,
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  orders: readyOrders,
                  onAction: (order) =>
                      _updateOrderStatus(order.id, KitchenStatus.delivered),
                  showHeader: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit une colonne de commandes
  Widget _buildColumn({
    required String title,
    required IconData icon,
    required Color color,
    required List<KitchenOrder> orders,
    required Future<void> Function(KitchenOrder) onAction,
    bool showHeader = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          // En-tête de colonne
          if (showHeader)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '$title (${orders.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Liste des commandes
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aucune commande',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: KitchenTabletOrderCard(
                          order: order,
                          onStartPreparing: order.status == KitchenStatus.pending
                              ? () => onAction(order)
                              : null,
                          onMarkReady: order.status == KitchenStatus.preparing
                              ? () => onAction(order)
                              : null,
                          onMarkDelivered: order.status == KitchenStatus.ready
                              ? () => onAction(order)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
