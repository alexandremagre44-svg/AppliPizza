// lib/src/providers/order_provider.dart
// Provider Riverpod pour gérer l'état des commandes

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/firebase_order_service.dart';
import 'auth_provider.dart';
import 'restaurant_provider.dart';

/// Provider pour le service de commandes Firebase
/// Watches currentRestaurantProvider to inject the appId for multi-tenant isolation
final firebaseOrderServiceProvider = Provider<FirebaseOrderService>(
  (ref) {
    final config = ref.watch(currentRestaurantProvider);
    return FirebaseOrderService(appId: config.id);
  },
  dependencies: [currentRestaurantProvider],
);

/// Provider pour le stream des commandes (temps réel)
/// Affiche toutes les commandes pour admin/kitchen, seulement les commandes de l'utilisateur pour client
final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  final service = ref.watch(firebaseOrderServiceProvider);
  final authState = ref.watch(authProvider);
  final authService = ref.watch(firebaseAuthServiceProvider);
  
  // Si admin ou kitchen, afficher toutes les commandes
  if (authState.isAdmin || authState.isKitchen) {
    return service.watchAllOrders();
  }
  
  // Si client connecté, afficher uniquement ses commandes
  if (authState.isLoggedIn) {
    final user = authService.currentUser;
    if (user != null) {
      return service.watchUserOrders(user.uid);
    }
  }
  
  // Par défaut, retourner un stream vide
  return Stream.value([]);
});

/// Provider pour obtenir les commandes non vues
final unviewedOrdersProvider = Provider<List<Order>>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);
  return ordersAsync.when(
    data: (orders) => orders.where((o) => !o.isViewed).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider pour compter les commandes non vues
final unviewedOrdersCountProvider = Provider<int>((ref) {
  return ref.watch(unviewedOrdersProvider).length;
});

/// État des filtres et options d'affichage
class OrdersViewState {
  final String? statusFilter;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;
  final String searchQuery;
  final OrdersSortBy sortBy;
  final bool sortAscending;
  final bool isTableView; // true = table, false = cards
  
  OrdersViewState({
    this.statusFilter,
    this.startDateFilter,
    this.endDateFilter,
    this.searchQuery = '',
    this.sortBy = OrdersSortBy.date,
    this.sortAscending = false,
    this.isTableView = true,
  });
  
  OrdersViewState copyWith({
    String? statusFilter,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
    String? searchQuery,
    OrdersSortBy? sortBy,
    bool? sortAscending,
    bool? isTableView,
    bool clearStatusFilter = false,
    bool clearDateFilters = false,
  }) {
    return OrdersViewState(
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      startDateFilter: clearDateFilters ? null : (startDateFilter ?? this.startDateFilter),
      endDateFilter: clearDateFilters ? null : (endDateFilter ?? this.endDateFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      isTableView: isTableView ?? this.isTableView,
    );
  }
}

enum OrdersSortBy {
  date,
  total,
  status,
  customer,
}

/// Notifier pour gérer l'état de la vue
class OrdersViewNotifier extends StateNotifier<OrdersViewState> {
  OrdersViewNotifier() : super(OrdersViewState());
  
  void setStatusFilter(String? status) {
    state = state.copyWith(statusFilter: status, clearStatusFilter: status == null);
  }
  
  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDateFilter: start,
      endDateFilter: end,
      clearDateFilters: start == null && end == null,
    );
  }
  
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
  
  void setSortBy(OrdersSortBy sortBy) {
    // Si on clique sur le même tri, inverser l'ordre
    if (state.sortBy == sortBy) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(sortBy: sortBy, sortAscending: false);
    }
  }
  
  void toggleView() {
    state = state.copyWith(isTableView: !state.isTableView);
  }
  
  void clearFilters() {
    state = OrdersViewState(
      isTableView: state.isTableView,
      sortBy: state.sortBy,
      sortAscending: state.sortAscending,
    );
  }
}

/// Provider pour l'état de la vue
final ordersViewProvider = StateNotifierProvider<OrdersViewNotifier, OrdersViewState>((ref) {
  return OrdersViewNotifier();
});

/// Provider pour les commandes filtrées et triées
final filteredOrdersProvider = Provider<List<Order>>((ref) {
  final ordersAsync = ref.watch(ordersStreamProvider);
  final viewState = ref.watch(ordersViewProvider);
  
  return ordersAsync.when(
    data: (orders) {
      List<Order> filtered = orders;
      
      // Appliquer filtre de statut
      if (viewState.statusFilter != null) {
        filtered = filtered.where((o) => o.status == viewState.statusFilter).toList();
      }
      
      // Appliquer filtre de date
      if (viewState.startDateFilter != null && viewState.endDateFilter != null) {
        filtered = filtered.where((o) {
          return o.date.isAfter(viewState.startDateFilter!.subtract(const Duration(days: 1))) &&
                 o.date.isBefore(viewState.endDateFilter!.add(const Duration(days: 1)));
        }).toList();
      }
      
      // Appliquer recherche
      if (viewState.searchQuery.isNotEmpty) {
        final query = viewState.searchQuery.toLowerCase();
        filtered = filtered.where((o) {
          return o.id.toLowerCase().contains(query) ||
                 (o.customerName?.toLowerCase().contains(query) ?? false) ||
                 (o.customerPhone?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
      
      // Appliquer tri
      filtered.sort((a, b) {
        int comparison = 0;
        switch (viewState.sortBy) {
          case OrdersSortBy.date:
            comparison = a.date.compareTo(b.date);
            break;
          case OrdersSortBy.total:
            comparison = a.total.compareTo(b.total);
            break;
          case OrdersSortBy.status:
            comparison = a.status.compareTo(b.status);
            break;
          case OrdersSortBy.customer:
            comparison = (a.customerName ?? '').compareTo(b.customerName ?? '');
            break;
        }
        return viewState.sortAscending ? comparison : -comparison;
      });
      
      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
