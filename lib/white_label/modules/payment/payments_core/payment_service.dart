/// lib/white_label/modules/payment/payments_core/payment_service.dart
///
/// Service de gestion du panier et du paiement pour le module White-Label.
library;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// =============================================
// MODÈLES DE DONNÉES
// =============================================

/// Item du panier
class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  int quantity;
  final String? imageUrl;
  final String? customDescription;
  final bool isMenu;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.customDescription,
    this.isMenu = false,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'customDescription': customDescription,
      'isMenu': isMenu,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
      customDescription: json['customDescription'] as String?,
      isMenu: json['isMenu'] as bool? ?? false,
    );
  }
}

/// État du panier
class CartModel {
  final List<CartItem> items;
  final double? discountPercent;
  final double? discountAmount;

  CartModel({
    required this.items,
    this.discountPercent,
    this.discountAmount,
  });

  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  double get discountValue {
    double discount = 0.0;
    if (discountPercent != null && discountPercent! > 0) {
      discount += subtotal * (discountPercent! / 100);
    }
    if (discountAmount != null && discountAmount! > 0) {
      discount += discountAmount!;
    }
    return discount > subtotal ? subtotal : discount;
  }

  double get total {
    final totalAfterDiscount = subtotal - discountValue;
    return totalAfterDiscount < 0 ? 0 : totalAfterDiscount;
  }

  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
    };
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return CartModel(
      items: itemsList.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList(),
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
    );
  }
}

/// État du checkout
class CheckoutState {
  final String? deliveryAddress;
  final String? deliverySlot;
  final String? deliveryZoneId;
  final double? deliveryFee;
  final String? clickCollectSlot;
  final bool isDelivery;

  CheckoutState({
    this.deliveryAddress,
    this.deliverySlot,
    this.deliveryZoneId,
    this.deliveryFee,
    this.clickCollectSlot,
    this.isDelivery = true,
  });

  CheckoutState copyWith({
    String? deliveryAddress,
    String? deliverySlot,
    String? deliveryZoneId,
    double? deliveryFee,
    String? clickCollectSlot,
    bool? isDelivery,
  }) {
    return CheckoutState(
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliverySlot: deliverySlot ?? this.deliverySlot,
      deliveryZoneId: deliveryZoneId ?? this.deliveryZoneId,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      clickCollectSlot: clickCollectSlot ?? this.clickCollectSlot,
      isDelivery: isDelivery ?? this.isDelivery,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryAddress': deliveryAddress,
      'deliverySlot': deliverySlot,
      'deliveryZoneId': deliveryZoneId,
      'deliveryFee': deliveryFee,
      'clickCollectSlot': clickCollectSlot,
      'isDelivery': isDelivery,
    };
  }

  factory CheckoutState.fromJson(Map<String, dynamic> json) {
    return CheckoutState(
      deliveryAddress: json['deliveryAddress'] as String?,
      deliverySlot: json['deliverySlot'] as String?,
      deliveryZoneId: json['deliveryZoneId'] as String?,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      clickCollectSlot: json['clickCollectSlot'] as String?,
      isDelivery: json['isDelivery'] as bool? ?? true,
    );
  }
}

// =============================================
// SERVICE DE PANIER ET PAIEMENT
// =============================================

/// Service de gestion du panier et des paiements
class CartService {
  static const String _cartKey = 'wl_cart_data';
  static const String _checkoutKey = 'wl_checkout_state';

  final List<CartItem> items = [];
  CheckoutState checkoutState = CheckoutState();

  /// Ajoute un produit au panier
  void add(String productId, String productName, double price, int qty, {String? imageUrl, String? customDescription, bool isMenu = false}) {
    try {
      final existingItem = items.firstWhere(
        (item) => item.productId == productId && item.customDescription == customDescription && !item.isMenu,
      );
      existingItem.quantity += qty;
      items.add(CartItem(
        id: _uuid.v4(),
        productId: productId,
        productName: productName,
        price: price,
        quantity: qty,
        imageUrl: imageUrl,
        customDescription: customDescription,
        isMenu: isMenu,
      ));
    }
    _saveToPreferences();
  }

  /// Supprime un produit du panier
  void remove(String itemId) {
    items.removeWhere((item) => item.id == itemId);
    _saveToPreferences();
  }

  /// Met à jour la quantité d'un produit
  void updateQty(String itemId, int newQty) {
    if (newQty <= 0) {
      remove(itemId);
      return;
    }

    try {
      final item = items.firstWhere((i) => i.id == itemId);
      item.quantity = newQty;
      _saveToPreferences();
    } catch (_) {
      // Item not found, ignore
    }
  }

  /// Vide le panier
  void clear() {
    items.clear();
    _saveToPreferences();
  }

  /// Calcule le sous-total
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  /// Met à jour l'état du checkout
  void updateCheckoutState(CheckoutState newState) {
    checkoutState = newState;
    _saveCheckoutToPreferences();
  }

  /// Sauvegarde le panier dans SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartModel = CartModel(items: List.from(items));
      await prefs.setString(_cartKey, jsonEncode(cartModel.toJson()));
    } catch (e) {
      // Ignore errors silently to avoid blocking the UI
    }
  }

  /// Sauvegarde l'état du checkout dans SharedPreferences
  Future<void> _saveCheckoutToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_checkoutKey, jsonEncode(checkoutState.toJson()));
    } catch (e) {
      // Ignore errors silently
    }
  }

  /// Charge le panier depuis SharedPreferences
  Future<void> loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString(_cartKey);
      if (cartData != null) {
        final cartModel = CartModel.fromJson(jsonDecode(cartData) as Map<String, dynamic>);
        items.clear();
        items.addAll(cartModel.items);
      }

      final checkoutData = prefs.getString(_checkoutKey);
      if (checkoutData != null) {
        checkoutState = CheckoutState.fromJson(jsonDecode(checkoutData) as Map<String, dynamic>);
      }
    } catch (e) {
      // Ignore errors and start with empty cart
    }
  }

  /// Crée une commande et l'enregistre dans Firestore
  Future<String> createOrder(String restaurantId, {String? userId}) async {
    final orderId = _uuid.v4();
    final now = DateTime.now();

    final orderData = {
      'id': orderId,
      'items': items.map((item) => item.toJson()).toList(),
      'deliveryAddress': checkoutState.deliveryAddress,
      'deliverySlot': checkoutState.deliverySlot,
      'deliveryZoneId': checkoutState.deliveryZoneId,
      'deliveryFee': checkoutState.deliveryFee ?? 0.0,
      'clickCollectSlot': checkoutState.clickCollectSlot,
      'isDelivery': checkoutState.isDelivery,
      'subtotal': subtotal,
      'total': subtotal + (checkoutState.deliveryFee ?? 0.0),
      'createdAt': Timestamp.fromDate(now),
      'status': 'pending',
      'userId': userId,
    };

    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .collection('orders')
        .doc(orderId)
        .set(orderData);

    // Clear cart after order creation
    clear();
    checkoutState = CheckoutState();
    await _saveCheckoutToPreferences();

    return orderId;
  }
}
