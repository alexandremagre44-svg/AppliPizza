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

  CartState(this.items);

  // Propriété calculée pour le total du panier
  double get total {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  // Propriété calculée pour le nombre total d'articles (pour le badge)
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
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
      state = CartState([...state.items, newItem]);
    }
  }
  
  // NOUVEAU: Ajoute un CartItem pré-construit (utilisé pour les menus customisés)
  void addExistingItem(CartItem item) {
    state = CartState([...state.items, item]);
  }


  void removeItem(String itemId) {
    state = CartState(state.items.where((item) => item.id != itemId).toList());
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

    state = CartState([...updatedItems]);
  }

  void incrementQuantity(String itemId) {
    final itemToUpdate = state.items.firstWhere((i) => i.id == itemId);
    // On mute l'objet et on recrée le State pour que Riverpod rafraîchisse l'UI
    itemToUpdate.quantity++; 
    state = CartState([...state.items]);
  }

  void decrementQuantity(String itemId) {
    final itemToUpdate = state.items.firstWhere((i) => i.id == itemId);
    
    if (itemToUpdate.quantity <= 1) {
      removeItem(itemId);
    } else {
      itemToUpdate.quantity--;
      state = CartState([...state.items]);
    }
  }
  
  // NOUVEAU: Ajout de la méthode clearCart
  void clearCart() {
    state = CartState([]);
  }
}