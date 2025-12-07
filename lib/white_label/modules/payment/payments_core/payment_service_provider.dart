/// lib/white_label/modules/payment/payments_core/payment_service_provider.dart
///
/// Riverpod provider pour le service de paiement White-Label.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'payment_service.dart';

/// Internal state provider for cart service initialization
final _cartServiceInitProvider = FutureProvider<CartService>((ref) async {
  final service = CartService();
  await service.loadFromPreferences();
  return service;
});

/// Provider global pour le CartService
/// 
/// Ce provider fournit une instance singleton du CartService
/// qui gère le panier et le checkout.
/// Note: This returns a CartService even before async initialization completes.
/// For cart data, watch the cartItemCountProvider or similar computed providers.
final cartServiceProvider = Provider<CartService>((ref) {
  final service = CartService();
  
  // Trigger async loading in background (fire and forget)
  // The service will be populated once loadFromPreferences completes
  service.loadFromPreferences();
  
  return service;
});

/// Provider pour l'état du panier (nombre d'items)
/// 
/// Ce provider surveille le nombre total d'items dans le panier
/// et notifie les widgets dépendants lors des changements.
/// Note: This is a simple computed property. For more complex scenarios,
/// consider using a StateNotifier or ChangeNotifier for the CartService.
final cartItemCountProvider = Provider<int>((ref) {
  final service = ref.watch(cartServiceProvider);
  // Cache the calculation to avoid repeated fold operations
  // This is a simple provider, so recalculation happens on every access
  // For production, consider adding caching in CartService itself
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
