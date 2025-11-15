// lib/src/providers/cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart'; 

const _uuid = Uuid();

// =============================================
// MODÈLE DE DONNÉES DU PANIER (CartItem)
// =============================================

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  int quantity; // La quantité est mutable pour être mise à jour facilement
  final String imageUrl;
  final String? customDescription;
  final bool isMenu;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.customDescription,
    this.isMenu = false,
  });

  // Propriété calculée
  double get total => price * quantity;
}

// =============================================
// ÉTAT DU PANIER (CartState)
// =============================================

class CartState {
  final List<CartItem> items;
  final double? discountPercent;      // Pourcentage de réduction (ex: 10 pour 10%)
  final double? discountAmount;       // Montant fixe de réduction (ex: 5.0 pour 5€)
  final String? pendingFreeItemId;    // ID du produit gratuit en attente
  final String? pendingFreeItemType;  // Type: 'product' ou 'drink'

  CartState(
    this.items, {
    this.discountPercent,
    this.discountAmount,
    this.pendingFreeItemId,
    this.pendingFreeItemType,
  });

  // Propriété calculée pour le total du panier sans réduction
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  // Propriété calculée pour le montant de la réduction
  double get discountValue {
    double discount = 0.0;
    
    // Réduction en pourcentage
    if (discountPercent != null && discountPercent! > 0) {
      discount += subtotal * (discountPercent! / 100);
    }
    
    // Réduction en montant fixe
    if (discountAmount != null && discountAmount! > 0) {
      discount += discountAmount!;
    }
    
    // Ne pas dépasser le sous-total
    return discount > subtotal ? subtotal : discount;
  }

  // Propriété calculée pour le total du panier après réduction
  double get total {
    final totalAfterDiscount = subtotal - discountValue;
    return totalAfterDiscount < 0 ? 0 : totalAfterDiscount;
  }

  // Propriété calculée pour le nombre total d'articles (pour le badge)
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Indique si une réduction est active
  bool get hasDiscount {
    return (discountPercent != null && discountPercent! > 0) || 
           (discountAmount != null && discountAmount! > 0);
  }

  // Indique si un article gratuit est en attente
  bool get hasPendingFreeItem {
    return pendingFreeItemId != null && pendingFreeItemId!.isNotEmpty;
  }
}


// =============================================
// NOTIFIER (LOGIQUE MÉTIER)
// =============================================

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState([]));

  // Ajoute un produit simple ou un menu standard au panier
  void addItem(Product product, {String? customDescription}) {
    final existingItem = state.items.firstWhere(
      (item) => item.productId == product.id && item.customDescription == customDescription && !item.isMenu,
      orElse: () => CartItem( // Créer un CartItem bidon si non trouvé
          id: '',
          productId: '',
          productName: '',
          price: 0,
          quantity: 0,
          imageUrl: '',
          customDescription: ''),
    );

    if (existingItem.id.isNotEmpty) {
      // Si l'article existe (et non un menu customisé), augmentez la quantité
      incrementQuantity(existingItem.id);
    } else {
      // Sinon, ajoutez un nouvel article
      final newItem = CartItem(
        id: _uuid.v4(),
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: 1,
        imageUrl: product.imageUrl,
        customDescription: customDescription,
        isMenu: product.isMenu,
      );
      state = CartState(
        [...state.items, newItem],
        discountPercent: state.discountPercent,
        discountAmount: state.discountAmount,
        pendingFreeItemId: state.pendingFreeItemId,
        pendingFreeItemType: state.pendingFreeItemType,
      );
    }
  }
  
  // NOUVEAU: Ajoute un CartItem pré-construit (utilisé pour les menus customisés)
  void addExistingItem(CartItem item) {
    state = CartState(
      [...state.items, item],
      discountPercent: state.discountPercent,
      discountAmount: state.discountAmount,
      pendingFreeItemId: state.pendingFreeItemId,
      pendingFreeItemType: state.pendingFreeItemType,
    );
  }


  void removeItem(String itemId) {
    state = CartState(
      state.items.where((item) => item.id != itemId).toList(),
      discountPercent: state.discountPercent,
      discountAmount: state.discountAmount,
      pendingFreeItemId: state.pendingFreeItemId,
      pendingFreeItemType: state.pendingFreeItemType,
    );
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        item.quantity = newQuantity;
      }
      return item;
    }).toList();

    state = CartState(
      [...updatedItems],
      discountPercent: state.discountPercent,
      discountAmount: state.discountAmount,
      pendingFreeItemId: state.pendingFreeItemId,
      pendingFreeItemType: state.pendingFreeItemType,
    );
  }

  void incrementQuantity(String itemId) {
    final itemToUpdate = state.items.firstWhere((i) => i.id == itemId);
    // On mute l'objet et on recrée le State pour que Riverpod rafraîchisse l'UI
    itemToUpdate.quantity++; 
    state = CartState(
      [...state.items],
      discountPercent: state.discountPercent,
      discountAmount: state.discountAmount,
      pendingFreeItemId: state.pendingFreeItemId,
      pendingFreeItemType: state.pendingFreeItemType,
    );
  }

  void decrementQuantity(String itemId) {
    final itemToUpdate = state.items.firstWhere((i) => i.id == itemId);
    
    if (itemToUpdate.quantity <= 1) {
      removeItem(itemId);
    } else {
      itemToUpdate.quantity--;
      state = CartState(
        [...state.items],
        discountPercent: state.discountPercent,
        discountAmount: state.discountAmount,
        pendingFreeItemId: state.pendingFreeItemId,
        pendingFreeItemType: state.pendingFreeItemType,
      );
    }
  }
  
  // NOUVEAU: Ajout de la méthode clearCart
  void clearCart() {
    state = CartState([]);
  }

  // =============================================
  // GESTION DES RÉCOMPENSES DE LA ROUE
  // =============================================

  /// Applique une réduction en pourcentage (ex: 10 pour 10%)
  void applyPercentageDiscount(double percent) {
    state = CartState(
      state.items,
      discountPercent: percent,
      discountAmount: state.discountAmount,
      pendingFreeItemId: state.pendingFreeItemId,
      pendingFreeItemType: state.pendingFreeItemType,
    );
  }

  /// Applique une réduction en montant fixe (ex: 5.0 pour 5€)
  void applyFixedAmountDiscount(double amount) {
    state = CartState(
      state.items,
      discountPercent: state.discountPercent,
      discountAmount: amount,
      pendingFreeItemId: state.pendingFreeItemId,
      pendingFreeItemType: state.pendingFreeItemType,
    );
  }

  /// Définit un produit gratuit en attente d'ajout au panier
  void setPendingFreeItem(String productId, String type) {
    state = CartState(
      state.items,
      discountPercent: state.discountPercent,
      discountAmount: state.discountAmount,
      pendingFreeItemId: productId,
      pendingFreeItemType: type,
    );
  }

  /// Supprime toutes les réductions actives
  void clearDiscounts() {
    state = CartState(
      state.items,
      discountPercent: null,
      discountAmount: null,
      pendingFreeItemId: state.pendingFreeItemId,
      pendingFreeItemType: state.pendingFreeItemType,
    );
  }

  /// Supprime l'article gratuit en attente
  void clearPendingFreeItem() {
    state = CartState(
      state.items,
      discountPercent: state.discountPercent,
      discountAmount: state.discountAmount,
      pendingFreeItemId: null,
      pendingFreeItemType: null,
    );
  }

  /// Supprime toutes les récompenses (réductions + articles gratuits)
  void clearAllRewards() {
    state = CartState(
      state.items,
      discountPercent: null,
      discountAmount: null,
      pendingFreeItemId: null,
      pendingFreeItemType: null,
    );
  }
}