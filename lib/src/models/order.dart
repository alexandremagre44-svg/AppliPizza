// lib/src/models/order.dart

import 'package:uuid/uuid.dart';
import '../providers/cart_provider.dart'; 
// Assurez-vous d'avoir 'package:uuid/uuid.dart' dans votre pubspec.yaml

/// Statuts possibles pour une commande
class OrderStatus {
  static const String pending = 'En attente';
  static const String preparing = 'En préparation';
  static const String ready = 'Prête';
  static const String delivered = 'Livrée';
  static const String cancelled = 'Annulée';
  
  static List<String> get all => [pending, preparing, ready, delivered, cancelled];
}

/// Historique de changement de statut
class OrderStatusHistory {
  final String status;
  final DateTime timestamp;
  final String? note;
  
  OrderStatusHistory({
    required this.status,
    required this.timestamp,
    this.note,
  });
  
  Map<String, dynamic> toJson() => {
    'status': status,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
  };
  
  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) => OrderStatusHistory(
    status: json['status'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    note: json['note'] as String?,
  );
}

class Order {
  final String id;
  final double total;
  final DateTime date;
  final List<CartItem> items; 
  final String status;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? comment;
  final List<OrderStatusHistory>? statusHistory;
  final bool isViewed;
  final DateTime? viewedAt;
  final String? pickupDate;
  final String? pickupTimeSlot;

  Order({
    required this.id,
    required this.total,
    required this.date,
    required this.items,
    this.status = OrderStatus.pending,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.comment,
    this.statusHistory,
    this.isViewed = false,
    this.viewedAt,
    this.pickupDate,
    this.pickupTimeSlot,
  });

  // Factory pour créer une commande à partir du contenu du panier
  factory Order.fromCart(
    List<CartItem> cartItems,
    double cartTotal, {
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? comment,
    String? pickupDate,
    String? pickupTimeSlot,
  }) {
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
    
    final now = DateTime.now();
    
    return Order(
      id: const Uuid().v4(), 
      total: cartTotal,
      date: now,
      items: itemsCopy,
      status: OrderStatus.pending,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      comment: comment,
      pickupDate: pickupDate,
      pickupTimeSlot: pickupTimeSlot,
      statusHistory: [
        OrderStatusHistory(
          status: OrderStatus.pending,
          timestamp: now,
          note: 'Commande créée',
        ),
      ],
    );
  }
  
  // Copier avec modifications
  Order copyWith({
    String? id,
    double? total,
    DateTime? date,
    List<CartItem>? items,
    String? status,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? comment,
    List<OrderStatusHistory>? statusHistory,
    bool? isViewed,
    DateTime? viewedAt,
    String? pickupDate,
    String? pickupTimeSlot,
  }) {
    return Order(
      id: id ?? this.id,
      total: total ?? this.total,
      date: date ?? this.date,
      items: items ?? this.items,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      comment: comment ?? this.comment,
      statusHistory: statusHistory ?? this.statusHistory,
      isViewed: isViewed ?? this.isViewed,
      viewedAt: viewedAt ?? this.viewedAt,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTimeSlot: pickupTimeSlot ?? this.pickupTimeSlot,
    );
  }
  
  // Conversion JSON pour stockage
  Map<String, dynamic> toJson() => {
    'id': id,
    'total': total,
    'date': date.toIso8601String(),
    'items': items.map((item) => {
      'id': item.id,
      'productId': item.productId,
      'productName': item.productName,
      'price': item.price,
      'quantity': item.quantity,
      'imageUrl': item.imageUrl,
      'customDescription': item.customDescription,
      'isMenu': item.isMenu,
    }).toList(),
    'status': status,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'customerEmail': customerEmail,
    'comment': comment,
    'statusHistory': statusHistory?.map((h) => h.toJson()).toList(),
    'isViewed': isViewed,
    'viewedAt': viewedAt?.toIso8601String(),
    'pickupDate': pickupDate,
    'pickupTimeSlot': pickupTimeSlot,
  };
  
  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    total: (json['total'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
    items: (json['items'] as List).map((item) => CartItem(
      id: item['id'] as String,
      productId: item['productId'] as String,
      productName: item['productName'] as String,
      price: (item['price'] as num).toDouble(),
      quantity: item['quantity'] as int,
      imageUrl: item['imageUrl'] as String,
      customDescription: item['customDescription'] as String?,
      isMenu: item['isMenu'] as bool? ?? false,
    )).toList(),
    status: json['status'] as String? ?? OrderStatus.pending,
    customerName: json['customerName'] as String?,
    customerPhone: json['customerPhone'] as String?,
    customerEmail: json['customerEmail'] as String?,
    comment: json['comment'] as String?,
    statusHistory: (json['statusHistory'] as List?)
        ?.map((h) => OrderStatusHistory.fromJson(h as Map<String, dynamic>))
        .toList(),
    isViewed: json['isViewed'] as bool? ?? false,
    viewedAt: json['viewedAt'] != null 
        ? DateTime.parse(json['viewedAt'] as String) 
        : null,
    pickupDate: json['pickupDate'] as String?,
    pickupTimeSlot: json['pickupTimeSlot'] as String?,
  );
}