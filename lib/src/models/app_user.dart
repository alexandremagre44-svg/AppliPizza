// lib/src/models/app_user.dart
// Modèle d'utilisateur pour la gestion admin

import '../models/order.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin' ou 'client'
  final bool isBlocked;
  final DateTime createdAt;
  final List<Order> orderHistory;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isBlocked = false,
    required this.createdAt,
    this.orderHistory = const [],
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isBlocked,
    DateTime? createdAt,
    List<Order>? orderHistory,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      orderHistory: orderHistory ?? this.orderHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isBlocked': isBlocked,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isBlocked: json['isBlocked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
