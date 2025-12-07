/// lib/white_label/modules/core/delivery/delivery_runtime_provider.dart
///
/// Riverpod provider pour les services runtime de livraison.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'delivery_runtime_service.dart';
import 'delivery_settings.dart';
import '../../../../src/providers/restaurant_provider.dart';

/// Provider pour les paramètres de livraison du restaurant courant
/// 
/// Ce provider charge les paramètres de livraison depuis Firestore
/// pour le restaurant actif.
final deliverySettingsProvider = FutureProvider<DeliverySettings>((ref) async {
  final restaurantConfig = ref.watch(currentRestaurantProvider);
  
  // TODO: Charger depuis Firestore
  // Pour l'instant, retourne des paramètres par défaut
  return DeliverySettings.defaults();
});

/// Provider pour le service runtime de livraison
final deliveryRuntimeServiceProvider = Provider<DeliveryRuntimeService?>((ref) {
  final settingsAsync = ref.watch(deliverySettingsProvider);
  
  return settingsAsync.when(
    data: (settings) => DeliveryRuntimeService(settings),
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider pour les créneaux de livraison disponibles
final deliveryTimeslotsProvider = Provider<List<String>>((ref) {
  final service = ref.watch(deliveryRuntimeServiceProvider);
  if (service == null) return [];
  
  return service.listTimeSlots();
});

/// Provider pour les zones de livraison actives
final activeDeliveryZonesProvider = Provider<List<DeliveryZone>>((ref) {
  final service = ref.watch(deliveryRuntimeServiceProvider);
  if (service == null) return [];
  
  return service.getActiveZones();
});
