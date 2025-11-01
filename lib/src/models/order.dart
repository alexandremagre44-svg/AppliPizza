// lib/src/models/order.dart

import 'package:uuid/uuid.dart';
import '../providers/cart_provider.dart'; 
// Assurez-vous d'avoir 'package:uuid/uuid.dart' dans votre pubspec.yaml

class Order {
  final String id;
  final double total;
  final DateTime date;
  final List<CartItem> items; 
  final String status; // <<< AJOUTÉ : Statut de la commande

  Order({
    required this.id,
    required this.total,
    required this.date,
    required this.items,
    this.status = 'En préparation', // <<< Initialisation par défaut
  });

  // Factory pour créer une commande à partir du contenu du panier
  factory Order.fromCart(List<CartItem> cartItems, double cartTotal) {
    
    final itemsCopy = cartItems.map((item) => CartItem(
      id: item.id,
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
      imageUrl: item.imageUrl,
      customDescription: item.customDescription,
      isMenu: item.isMenu,
    )).toList();
    
    return Order(
      id: const Uuid().v4(), 
      total: cartTotal,
      date: DateTime.now(),
      items: itemsCopy,
      status: 'En préparation', // <<< Définition du statut initial
    );
  }
}