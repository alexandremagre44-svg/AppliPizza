// lib/src/utils/order_test_data.dart
// Générateur de données de test pour les commandes

import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../../../cart/application/cart_provider.dart';

class OrderTestData {
  static const _uuid = Uuid();
  
  /// Génère des commandes de test
  static List<Order> generateTestOrders(int count) {
    final orders = <Order>[];
    final now = DateTime.now();
    
    final customerNames = [
      'Marie Dupont',
      'Jean Martin',
      'Sophie Bernard',
      'Pierre Dubois',
      'Claire Moreau',
      'Antoine Lefebvre',
      'Julie Lambert',
      'Thomas Rousseau',
    ];
    
    final phones = [
      '06 12 34 56 78',
      '06 23 45 67 89',
      '06 34 56 78 90',
      '06 45 67 89 01',
      '06 56 78 90 12',
    ];
    
    final pizzaNames = [
      'Margherita',
      'Regina',
      'Quattro Formaggi',
      'Calzone',
      'Napolitaine',
      'Végétarienne',
    ];
    
    final statuses = [
      OrderStatus.pending,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.delivered,
    ];
    
    final timeSlots = [
      '11:30 - 12:00',
      '12:00 - 12:30',
      '18:30 - 19:00',
      '19:00 - 19:30',
      '19:30 - 20:00',
    ];
    
    for (int i = 0; i < count; i++) {
      // Générer items aléatoires
      final itemCount = 1 + (i % 3);
      final items = <CartItem>[];
      double total = 0;
      
      for (int j = 0; j < itemCount; j++) {
        final pizzaName = pizzaNames[j % pizzaNames.length];
        final price = 8.90 + (j * 2.5);
        final quantity = 1 + (j % 2);
        
        items.add(CartItem(
          id: _uuid.v4(),
          productId: 'pizza_$j',
          productName: pizzaName,
          price: price,
          quantity: quantity,
          imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=$pizzaName',
        ));
        
        total += price * quantity;
      }
      
      // Ajouter des boissons parfois
      if (i % 3 == 0) {
        items.add(CartItem(
          id: _uuid.v4(),
          productId: 'drink_1',
          productName: 'Coca-Cola 33cl',
          price: 2.50,
          quantity: 1,
          imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=Coca',
        ));
        total += 2.50;
      }
      
      // Varier les dates (certaines aujourd'hui, d'autres hier, etc.)
      final daysAgo = i % 3;
      final hoursAgo = i % 6;
      final orderDate = now.subtract(Duration(days: daysAgo, hours: hoursAgo));
      
      final status = i < 3 ? OrderStatus.pending : statuses[i % statuses.length];
      final isViewed = i >= 3; // Les 3 premières sont non vues
      
      final customerName = customerNames[i % customerNames.length];
      final phone = phones[i % phones.length];
      
      final pickupDay = orderDate.add(const Duration(hours: 2));
      final pickupDate = '${pickupDay.day}/${pickupDay.month}/${pickupDay.year}';
      final pickupTimeSlot = timeSlots[i % timeSlots.length];
      
      final statusHistory = <OrderStatusHistory>[
        OrderStatusHistory(
          status: OrderStatus.pending,
          timestamp: orderDate,
          note: 'Commande créée',
        ),
      ];
      
      // Ajouter historique pour commandes plus avancées
      if (status != OrderStatus.pending) {
        statusHistory.add(OrderStatusHistory(
          status: OrderStatus.preparing,
          timestamp: orderDate.add(const Duration(minutes: 5)),
          note: 'Mise en préparation',
        ));
      }
      
      if (status == OrderStatus.ready || status == OrderStatus.delivered) {
        statusHistory.add(OrderStatusHistory(
          status: OrderStatus.ready,
          timestamp: orderDate.add(const Duration(minutes: 20)),
          note: 'Prête pour retrait',
        ));
      }
      
      if (status == OrderStatus.delivered) {
        statusHistory.add(OrderStatusHistory(
          status: OrderStatus.delivered,
          timestamp: orderDate.add(const Duration(minutes: 30)),
          note: 'Remise au client',
        ));
      }
      
      final comment = i % 4 == 0 
          ? 'Merci de bien cuire la pizza' 
          : (i % 5 == 0 ? 'Sans oignons SVP' : null);
      
      orders.add(Order(
        id: _uuid.v4(),
        total: total,
        date: orderDate,
        items: items,
        status: status,
        customerName: customerName,
        customerPhone: phone,
        customerEmail: '${customerName.toLowerCase().replaceAll(' ', '.')}@example.com',
        comment: comment,
        pickupDate: pickupDate,
        pickupTimeSlot: pickupTimeSlot,
        statusHistory: statusHistory,
        isViewed: isViewed,
        viewedAt: isViewed ? orderDate.add(const Duration(minutes: 2)) : null,
      ));
    }
    
    // Trier par date décroissante
    orders.sort((a, b) => b.date.compareTo(a.date));
    
    return orders;
  }
}
