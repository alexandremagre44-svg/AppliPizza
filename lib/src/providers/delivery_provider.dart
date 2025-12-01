/// lib/src/providers/delivery_provider.dart
///
/// Provider Riverpod pour gérer l'état de la livraison dans le flux commande.
///
/// Ce provider est utilisé pour:
/// - Stocker le mode de retrait (sur place / livraison)
/// - Stocker l'adresse de livraison sélectionnée
/// - Stocker la zone de livraison sélectionnée
/// - Calculer les frais de livraison et vérifier le minimum

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../white_label/modules/core/delivery/delivery_area.dart';
import '../../white_label/modules/core/delivery/delivery_settings.dart';

/// Mode de retrait de la commande.
enum DeliveryMode {
  /// Pas de mode sélectionné
  none,

  /// Retrait sur place (Click & Collect)
  takeAway,

  /// Livraison à domicile
  delivery,
}

/// Adresse de livraison saisie par le client.
class DeliveryAddress {
  final String address;
  final String postalCode;
  final String? complement;
  final String? driverInstructions;

  const DeliveryAddress({
    required this.address,
    required this.postalCode,
    this.complement,
    this.driverInstructions,
  });

  /// Sérialise l'adresse en JSON.
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'postalCode': postalCode,
      'complement': complement,
      'driverInstructions': driverInstructions,
    };
  }

  /// Désérialise l'adresse depuis un JSON.
  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      address: json['address'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      complement: json['complement'] as String?,
      driverInstructions: json['driverInstructions'] as String?,
    );
  }

  /// Retourne l'adresse formatée pour l'affichage.
  String get formattedAddress {
    final parts = <String>[address, postalCode];
    if (complement != null && complement!.isNotEmpty) {
      parts.add(complement!);
    }
    return parts.join(', ');
  }

  @override
  String toString() {
    return 'DeliveryAddress(address: $address, postalCode: $postalCode)';
  }
}

/// État complet de la livraison.
class DeliveryState {
  final DeliveryMode mode;
  final DeliveryAddress? selectedAddress;
  final DeliveryArea? selectedArea;

  const DeliveryState({
    this.mode = DeliveryMode.none,
    this.selectedAddress,
    this.selectedArea,
  });

  /// Crée une copie de l'état avec les champs modifiés.
  /// Use explicit null to clear a field.
  DeliveryState copyWith({
    DeliveryMode? mode,
    DeliveryAddress? selectedAddress,
    DeliveryArea? selectedArea,
    bool clearAddress = false,
    bool clearArea = false,
  }) {
    return DeliveryState(
      mode: mode ?? this.mode,
      selectedAddress: clearAddress ? null : (selectedAddress ?? this.selectedAddress),
      selectedArea: clearArea ? null : (selectedArea ?? this.selectedArea),
    );
  }

  /// Retourne true si la livraison est sélectionnée.
  bool get isDeliverySelected => mode == DeliveryMode.delivery;

  /// Retourne true si le retrait sur place est sélectionné.
  bool get isTakeAwaySelected => mode == DeliveryMode.takeAway;

  /// Retourne true si un mode a été sélectionné.
  bool get hasSelectedMode => mode != DeliveryMode.none;

  /// Retourne true si la livraison est complètement configurée.
  bool get isDeliveryConfigured =>
      isDeliverySelected && selectedAddress != null && selectedArea != null;

  @override
  String toString() {
    return 'DeliveryState(mode: $mode, address: $selectedAddress, area: ${selectedArea?.name})';
  }
}

/// Notifier pour gérer l'état de la livraison.
class DeliveryNotifier extends StateNotifier<DeliveryState> {
  DeliveryNotifier() : super(const DeliveryState());

  /// Sélectionne le mode de retrait.
  void setMode(DeliveryMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Définit l'adresse de livraison.
  void setAddress(DeliveryAddress address) {
    state = state.copyWith(selectedAddress: address);
  }

  /// Définit la zone de livraison sélectionnée.
  void setArea(DeliveryArea area) {
    state = state.copyWith(selectedArea: area);
  }

  /// Réinitialise l'état de la livraison.
  void reset() {
    state = const DeliveryState();
  }

  /// Réinitialise uniquement l'adresse et la zone (garde le mode).
  void resetDeliveryDetails() {
    state = state.copyWith(clearAddress: true, clearArea: true);
  }
}

/// Provider pour l'état de la livraison.
final deliveryProvider =
    StateNotifierProvider<DeliveryNotifier, DeliveryState>((ref) {
  return DeliveryNotifier();
});

// =============================================================================
// BUSINESS LOGIC FUNCTIONS
// =============================================================================

/// Calcule les frais de livraison.
///
/// - Si le total du panier >= seuil de livraison gratuite, retourne 0
/// - Sinon, retourne les frais de la zone
double computeDeliveryFee(
    DeliverySettings settings, DeliveryArea area, double cartTotal) {
  if (settings.freeDeliveryThreshold != null &&
      cartTotal >= settings.freeDeliveryThreshold!) {
    return 0;
  }
  return area.deliveryFee;
}

/// Vérifie si le minimum de commande est atteint.
///
/// Compare le total du panier avec le minimum global des settings
/// et le minimum spécifique de la zone.
bool isMinimumReached(
    DeliverySettings settings, DeliveryArea? area, double cartTotal) {
  // Vérifier le minimum global
  if (cartTotal < settings.minimumOrderAmount) {
    return false;
  }
  // Vérifier le minimum de la zone si défini
  if (area != null && cartTotal < area.minimumOrderAmount) {
    return false;
  }
  return true;
}

/// Retourne le montant minimum requis (le plus élevé entre global et zone).
double getMinimumOrderAmount(DeliverySettings settings, DeliveryArea? area) {
  final globalMin = settings.minimumOrderAmount;
  final areaMin = area?.minimumOrderAmount ?? 0;
  return globalMin > areaMin ? globalMin : areaMin;
}

// =============================================================================
// COMPUTED PROVIDERS
// =============================================================================

/// Provider pour les frais de livraison calculés.
///
/// This provider requires both deliveryProvider and deliverySettingsProvider.
/// It's designed to be used where deliverySettingsProvider is available.
/// Returns null if delivery is not selected or not configured.
///
/// Note: For use in checkout, the fee calculation is done directly
/// using the computeDeliveryFee function with deliverySettingsProvider.
final computedDeliveryFeeProvider = Provider.family<double?, double>((ref, cartTotal) {
  final deliveryState = ref.watch(deliveryProvider);
  
  if (!deliveryState.isDeliverySelected || deliveryState.selectedArea == null) {
    return null;
  }
  
  // Return the area's fee as a fallback
  // The checkout screen should use deliverySettingsProvider for more accurate calculation
  return deliveryState.selectedArea!.deliveryFee;
});

/// Provider pour vérifier si le minimum est atteint.
///
/// This is a simplified version that only checks the area minimum.
/// For full validation including global settings, use isMinimumReached
/// function directly with deliverySettingsProvider.
final computedMinimumOkProvider = Provider.family<bool, double>((ref, cartTotal) {
  final deliveryState = ref.watch(deliveryProvider);
  
  if (!deliveryState.isDeliverySelected) {
    return true; // Pas de minimum pour le retrait sur place
  }
  
  // Check only the area minimum as a fallback
  if (deliveryState.selectedArea != null) {
    return cartTotal >= deliveryState.selectedArea!.minimumOrderAmount;
  }
  
  return true;
});
