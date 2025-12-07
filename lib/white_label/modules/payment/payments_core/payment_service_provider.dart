/// lib/white_label/modules/payment/payments_core/payment_service_provider.dart
///
/// Riverpod provider pour le service de paiement White-Label.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'payment_service.dart';

/// Provider global pour le CartService
/// 
/// Ce provider fournit une instance singleton du CartService
/// qui gère le panier et le checkout.
final cartServiceProvider = Provider<CartService>((ref) {
  final service = CartService();
  
  // Charger le panier depuis SharedPreferences au démarrage
  service.loadFromPreferences();
  
  return service;
});

/// Provider pour l'état du panier (nombre d'items)
/// 
/// Ce provider surveille le nombre total d'items dans le panier
/// et notifie les widgets dépendants lors des changements.
final cartItemCountProvider = Provider<int>((ref) {
  final service = ref.watch(cartServiceProvider);
  return service.items.fold(0, (sum, item) => sum + item.quantity);
});

/// Provider pour le sous-total du panier
final cartSubtotalProvider = Provider<double>((ref) {
  final service = ref.watch(cartServiceProvider);
  return service.subtotal;
});

/// Provider pour vérifier si le panier est vide
final isCartEmptyProvider = Provider<bool>((ref) {
  final service = ref.watch(cartServiceProvider);
  return service.items.isEmpty;
});
