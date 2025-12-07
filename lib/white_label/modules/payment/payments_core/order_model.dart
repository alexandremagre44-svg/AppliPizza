/// lib/white_label/modules/payment/payments_core/order_model.dart
///
/// Modèle de commande pour le système de paiement White-Label.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_service.dart';

/// Modèle de commande
class OrderModel {
  final String id;
  final List<CartItem> items;
  final String? deliveryAddress;
  final String? deliverySlot;
  final String? deliveryZoneId;
  final String? clickCollectSlot;
  final bool isDelivery;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final DateTime createdAt;
  final String status;
  final String? userId;

  OrderModel({
    required this.id,
    required this.items,
    this.deliveryAddress,
    this.deliverySlot,
    this.deliveryZoneId,
    this.clickCollectSlot,
    this.isDelivery = true,
    required this.subtotal,
    this.deliveryFee = 0.0,
    required this.total,
    required this.createdAt,
    this.status = 'pending',
    this.userId,
  });

  /// Sérialise la commande en JSON pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': deliveryAddress,
      'deliverySlot': deliverySlot,
      'deliveryZoneId': deliveryZoneId,
      'clickCollectSlot': clickCollectSlot,
      'isDelivery': isDelivery,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'userId': userId,
    };
  }

  /// Désérialise une commande depuis Firestore
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final createdAtTimestamp = json['createdAt'] as Timestamp?;
    
    return OrderModel(
      id: json['id'] as String,
      items: itemsList.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList(),
      deliveryAddress: json['deliveryAddress'] as String?,
      deliverySlot: json['deliverySlot'] as String?,
      deliveryZoneId: json['deliveryZoneId'] as String?,
      clickCollectSlot: json['clickCollectSlot'] as String?,
      isDelivery: json['isDelivery'] as bool? ?? true,
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      createdAt: createdAtTimestamp?.toDate() ?? DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      userId: json['userId'] as String?,
    );
  }

  /// Crée une copie de la commande avec les champs modifiés
  OrderModel copyWith({
    String? id,
    List<CartItem>? items,
    String? deliveryAddress,
    String? deliverySlot,
    String? deliveryZoneId,
    String? clickCollectSlot,
    bool? isDelivery,
    double? subtotal,
    double? deliveryFee,
    double? total,
    DateTime? createdAt,
    String? status,
    String? userId,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliverySlot: deliverySlot ?? this.deliverySlot,
      deliveryZoneId: deliveryZoneId ?? this.deliveryZoneId,
      clickCollectSlot: clickCollectSlot ?? this.clickCollectSlot,
      isDelivery: isDelivery ?? this.isDelivery,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, total: $total, status: $status, createdAt: $createdAt)';
  }
}
