// lib/src/kitchen/kitchen_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import 'kitchen_constants.dart';
import 'widgets/kitchen_order_card.dart';
import 'widgets/kitchen_order_detail.dart';
import 'services/kitchen_notifications.dart';
import 'services/kitchen_print_stub.dart';

/// Page principale du mode cuisine
/// Affichage plein écran avec fond noir et cartes de commandes
class KitchenPage extends ConsumerStatefulWidget {
  const KitchenPage({Key? key}) : super(key: key);

  @override
  ConsumerState<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends ConsumerState<KitchenPage> {
  final OrderService _orderService = OrderService();
  final KitchenNotificationService _notificationService = KitchenNotificationService();
  final KitchenPrintService _printService = KitchenPrintService();
  
  StreamSubscription? _ordersSubscription;
  Timer? _clockTimer;
  List<Order> _displayedOrders = [];
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    // Check if user has kitchen role
    _checkKitchenAccess();
    
    // Listen to order stream
    _ordersSubscription = _orderService.ordersStream.listen(_onOrdersUpdated);
    
    // Start clock timer for elapsed time updates
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
    
    // Setup notification callback
    _notificationService.onNewOrders = (orderIds) {
      if (mounted) {
        setState(() {});
      }
    };
    
    // Initial load
    _orderService.refresh();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    _clockTimer?.cancel();
    _notificationService.stopAlerts();
    super.dispose();
  }

  void _checkKitchenAccess() {
    final authState = ref.read(authProvider);
    if (authState.userRole != UserRole.kitchen) {
      // If not kitchen role, show warning but allow access for testing
      // In production, you might want to redirect
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mode Cuisine - Accès Développement'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  void _onOrdersUpdated(List<Order> orders) {
    if (!mounted) return;
    
    setState(() {
      _displayedOrders = _filterAndSortOrders(orders);
    });
    
    // Check for unseen orders and trigger notifications
    final unseenOrders = _displayedOrders.where((o) => !o.isViewed).toList();
    if (unseenOrders.isNotEmpty) {
      _notificationService.startAlerts(unseenOrders);
    } else {
      _notificationService.stopAlerts();
    }
  }

  List<Order> _filterAndSortOrders(List<Order> orders) {
    // Filter out cancelled and delivered orders
    final activeOrders = orders.where((o) {
      return o.status != OrderStatus.cancelled && 
             o.status != OrderStatus.delivered;
    }).toList();
    
    // Apply planning window logic if pickup time is available
    final now = DateTime.now();
    final pastThreshold = now.subtract(
      Duration(minutes: KitchenConstants.planningWindowPastMin),
    );
    final futureThreshold = now.add(
      Duration(minutes: KitchenConstants.planningWindowFutureMin),
    );
    
    final filteredOrders = activeOrders.where((order) {
      // If no pickup time, show all orders
      if (order.pickupDate == null || order.pickupTimeSlot == null) {
        return true;
      }
      
      // Parse pickup time
      try {
        final pickupDateParts = order.pickupDate!.split('/');
        final pickupTimeParts = order.pickupTimeSlot!.split(':');
        
        final pickupDateTime = DateTime(
          int.parse(pickupDateParts[2]), // year
          int.parse(pickupDateParts[1]), // month
          int.parse(pickupDateParts[0]), // day
          int.parse(pickupTimeParts[0]), // hour
          int.parse(pickupTimeParts[1]), // minute
        );
        
        // Check if within planning window
        return pickupDateTime.isAfter(pastThreshold) &&
               pickupDateTime.isBefore(futureThreshold);
      } catch (e) {
        // If parsing fails, show the order
        return true;
      }
    }).toList();
    
    // Sort orders: first by pickup time (if available), then by creation time
    filteredOrders.sort((a, b) {
      // Try to parse pickup times
      DateTime? pickupA;
      DateTime? pickupB;
      
      try {
        if (a.pickupDate != null && a.pickupTimeSlot != null) {
          final parts = a.pickupDate!.split('/');
          final timeParts = a.pickupTimeSlot!.split(':');
          pickupA = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      } catch (e) {
        // Ignore parsing errors
      }
      
      try {
        if (b.pickupDate != null && b.pickupTimeSlot != null) {
          final parts = b.pickupDate!.split('/');
          final timeParts = b.pickupTimeSlot!.split(':');
          pickupB = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );
        }
      } catch (e) {
        // Ignore parsing errors
      }
      
      // If both have pickup times, sort by pickup time, then by creation time as tiebreaker
      if (pickupA != null && pickupB != null) {
        final pickupComparison = pickupA.compareTo(pickupB);
        if (pickupComparison != 0) {
          return pickupComparison;
        }
        // Same pickup time, use creation time as tiebreaker (first ordered comes first)
        return a.date.compareTo(b.date);
      }
      
      // If only one has pickup time, prioritize it
      if (pickupA != null) return -1;
      if (pickupB != null) return 1;
      
      // Otherwise sort by creation time
      return a.date.compareTo(b.date);
    });
    
    return filteredOrders;
  }

  int _getMinutesSinceCreation(Order order) {
    return _now.difference(order.date).inMinutes;
  }

  Future<void> _changeOrderStatus(Order order, String newStatus) async {
    await _orderService.updateOrderStatus(order.id, newStatus);
    
    // Mark as viewed if not already
    if (!order.isViewed) {
      await _orderService.markOrderAsViewed(order.id);
      _notificationService.markOrderAsSeen(order.id);
    }
  }

  Future<void> _onPreviousStatus(Order order) async {
    final previousStatus = KitchenConstants.getPreviousStatus(order.status);
    if (previousStatus != null) {
      await _changeOrderStatus(order, previousStatus);
    }
  }

  Future<void> _onNextStatus(Order order) async {
    final nextStatus = KitchenConstants.getNextStatus(order.status);
    if (nextStatus != null) {
      await _changeOrderStatus(order, nextStatus);
    }
  }

  Future<void> _showOrderDetail(Order order) async {
    // Mark as viewed
    if (!order.isViewed) {
      await _orderService.markOrderAsViewed(order.id);
      _notificationService.markOrderAsSeen(order.id);
    }
    
    if (!mounted) return;
    
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => KitchenOrderDetail(
          order: order,
          onPreviousStatus: KitchenConstants.getPreviousStatus(order.status) != null
              ? () {
                  _onPreviousStatus(order);
                  Navigator.of(context).pop();
                }
              : null,
          onNextStatus: KitchenConstants.getNextStatus(order.status) != null
              ? () {
                  _onNextStatus(order);
                  Navigator.of(context).pop();
                }
              : null,
          minutesSinceCreation: _getMinutesSinceCreation(order),
        ),
      ),
    );
  }

  Future<void> _printAllNewOrders() async {
    final newOrders = _displayedOrders.where((o) => !o.isViewed).toList();
    
    if (newOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune nouvelle commande à imprimer'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    await _printService.printAllNewTickets(newOrders);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newOrders.length} ticket(s) envoyé(s) à l\'imprimante'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unseenCount = _notificationService.unseenOrderCount;
    
    return Scaffold(
      backgroundColor: KitchenConstants.kitchenBackground,
      appBar: AppBar(
        backgroundColor: KitchenConstants.kitchenBackground,
        elevation: 0,
        title: const Text(
          'MODE CUISINE',
          style: TextStyle(
            color: KitchenConstants.kitchenText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          // Unseen orders badge
          if (unseenCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$unseenCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Print all button
          IconButton(
            icon: const Icon(
              Icons.print,
              color: KitchenConstants.kitchenText,
            ),
            tooltip: 'Imprimer toutes les nouvelles',
            onPressed: _printAllNewOrders,
          ),
          
          // Refresh button
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: KitchenConstants.kitchenText,
            ),
            tooltip: 'Actualiser',
            onPressed: () => _orderService.refresh(),
          ),
          
          // Exit button
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: KitchenConstants.kitchenText,
            ),
            tooltip: 'Quitter le mode cuisine',
            onPressed: () => context.go(AppRoutes.home),
          ),
        ],
      ),
      body: SafeArea(
        child: _displayedOrders.isEmpty
            ? _buildEmptyState()
            : _buildOrdersGrid(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune commande en cours',
            style: TextStyle(
              color: KitchenConstants.kitchenTextSecondary,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Calculate number of columns based on screen width
        final int cols;
        if (width >= 2000) {
          cols = 4;
        } else if (width >= 1400) {
          cols = 3;
        } else if (width >= 900) {
          cols = 2;
        } else {
          cols = 1;
        }
        
        // Calculate column width and aspect ratio
        const padding = KitchenConstants.gridSpacing;
        final colWidth = (width - (cols - 1) * KitchenConstants.gridSpacing - padding * 2) / cols;
        final childAspectRatio = colWidth / KitchenConstants.targetCardHeight;
        
        return GridView.builder(
          padding: const EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: KitchenConstants.gridSpacing,
            mainAxisSpacing: KitchenConstants.gridSpacing,
          ),
          itemCount: _displayedOrders.length,
          itemBuilder: (context, index) {
            final order = _displayedOrders[index];
            final previousStatus = KitchenConstants.getPreviousStatus(order.status);
            final nextStatus = KitchenConstants.getNextStatus(order.status);
            
            return KitchenOrderCard(
              order: order,
              onTap: () => _showOrderDetail(order),
              onPreviousStatus: previousStatus != null
                  ? () => _onPreviousStatus(order)
                  : null,
              onNextStatus: nextStatus != null
                  ? () => _onNextStatus(order)
                  : null,
              minutesSinceCreation: _getMinutesSinceCreation(order),
            );
          },
        );
      },
    );
  }
}
