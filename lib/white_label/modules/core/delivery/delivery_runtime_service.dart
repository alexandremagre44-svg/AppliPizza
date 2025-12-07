/// lib/white_label/modules/core/delivery/delivery_runtime_service.dart
///
/// Service runtime pour la gestion des livraisons (zones, tarifs, créneaux).
library;

import 'delivery_area.dart';
import 'delivery_settings.dart';

/// Zone de livraison étendue avec support runtime
typedef DeliveryZone = DeliveryArea;

/// Service de calcul des prix de livraison
class DeliveryPriceCalculator {
  final DeliverySettings settings;

  DeliveryPriceCalculator(this.settings);

  /// Calcule les frais de livraison pour une adresse donnée
  /// 
  /// Retourne les frais de livraison basés sur :
  /// - La zone de livraison (code postal)
  /// - Le montant de la commande (livraison gratuite si seuil atteint)
  double calculateFee(String? postalCode, double orderAmount) {
    // Si code postal fourni, chercher la zone correspondante
    if (postalCode != null && postalCode.isNotEmpty) {
      final area = settings.findAreaByPostalCode(postalCode);
      if (area != null) {
        // Vérifier si livraison gratuite
        if (settings.isFreeDelivery(orderAmount)) {
          return 0.0;
        }
        return area.deliveryFee;
      }
    }

    // Fallback: frais de base
    if (settings.isFreeDelivery(orderAmount)) {
      return 0.0;
    }
    return settings.deliveryFee;
  }

  /// Vérifie si la livraison est disponible pour un code postal
  bool isDeliveryAvailable(String? postalCode) {
    if (postalCode == null || postalCode.isEmpty) {
      return false;
    }
    return settings.findAreaByPostalCode(postalCode) != null;
  }

  /// Retourne le montant minimum de commande pour une zone
  double getMinimumOrderAmount(String? postalCode) {
    if (postalCode != null && postalCode.isNotEmpty) {
      final area = settings.findAreaByPostalCode(postalCode);
      if (area != null) {
        return area.minimumOrderAmount;
      }
    }
    return settings.minimumOrderAmount;
  }

  /// Retourne le temps de livraison estimé pour une zone
  int getEstimatedDeliveryTime(String? postalCode) {
    if (postalCode != null && postalCode.isNotEmpty) {
      final area = settings.findAreaByPostalCode(postalCode);
      if (area != null) {
        return area.estimatedMinutes;
      }
    }
    return settings.estimatedDeliveryMinutes;
  }
}

/// Service de gestion des créneaux de livraison
class DeliveryTimeslots {
  final DeliverySettings settings;

  DeliveryTimeslots(this.settings);

  /// Retourne la liste des créneaux disponibles pour aujourd'hui
  List<String> listTimeSlots({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final weekday = targetDate.weekday - 1; // 0 = lundi, 6 = dimanche

    // Vérifier si le restaurant livre ce jour
    if (!settings.schedule.containsKey(weekday)) {
      return _getDefaultSlots();
    }

    final daySchedule = settings.schedule[weekday]!;
    final openTime = daySchedule['open'];
    final closeTime = daySchedule['close'];

    if (openTime == null || closeTime == null) {
      return _getDefaultSlots();
    }

    return _generateSlots(openTime, closeTime);
  }

  /// Génère les créneaux horaires entre deux heures
  List<String> _generateSlots(String openTime, String closeTime) {
    final slots = <String>[];

    try {
      final openParts = openTime.split(':');
      final closeParts = closeTime.split(':');

      final openHour = int.parse(openParts[0]);
      final openMinute = int.parse(openParts[1]);
      final closeHour = int.parse(closeParts[0]);
      final closeMinute = int.parse(closeParts[1]);

      var currentHour = openHour;
      var currentMinute = openMinute;

      while (currentHour < closeHour || (currentHour == closeHour && currentMinute < closeMinute)) {
        final startTime = '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
        
        // Avancer de 30 minutes
        currentMinute += 30;
        if (currentMinute >= 60) {
          currentMinute -= 60;
          currentHour += 1;
        }

        // Ne pas dépasser l'heure de fermeture
        if (currentHour > closeHour || (currentHour == closeHour && currentMinute > closeMinute)) {
          break;
        }

        final endTime = '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
        slots.add('$startTime - $endTime');
      }
    } catch (e) {
      return _getDefaultSlots();
    }

    return slots;
  }

  /// Retourne des créneaux par défaut
  List<String> _getDefaultSlots() {
    return [
      '12:00 - 12:30',
      '12:30 - 13:00',
      '13:00 - 13:30',
      '19:00 - 19:30',
      '19:30 - 20:00',
      '20:00 - 20:30',
      '20:30 - 21:00',
    ];
  }

  /// Vérifie si un créneau est disponible
  bool isSlotAvailable(String slot, {DateTime? date}) {
    final availableSlots = listTimeSlots(date: date);
    return availableSlots.contains(slot);
  }
}

/// Service runtime principal pour les livraisons
class DeliveryRuntimeService {
  final DeliverySettings settings;
  late final DeliveryPriceCalculator priceCalculator;
  late final DeliveryTimeslots timeslots;

  DeliveryRuntimeService(this.settings) {
    priceCalculator = DeliveryPriceCalculator(settings);
    timeslots = DeliveryTimeslots(settings);
  }

  /// Calcule les frais de livraison pour une adresse
  Future<double> calculateDeliveryFee(String? address, double orderAmount) async {
    // Extraire le code postal de l'adresse (simplification)
    final postalCode = _extractPostalCode(address);
    return priceCalculator.calculateFee(postalCode, orderAmount);
  }

  /// Valide une adresse de livraison
  Future<String?> validateAddress(String? address) async {
    if (address == null || address.isEmpty) {
      return 'Veuillez saisir une adresse de livraison';
    }

    if (address.length < 10) {
      return 'L\'adresse saisie est trop courte';
    }

    final postalCode = _extractPostalCode(address);
    if (postalCode == null) {
      return 'Code postal non trouvé dans l\'adresse';
    }

    if (!priceCalculator.isDeliveryAvailable(postalCode)) {
      return 'Livraison non disponible dans cette zone';
    }

    return null; // Validation réussie
  }

  /// Liste les créneaux de livraison disponibles
  List<String> listTimeSlots({DateTime? date}) {
    return timeslots.listTimeSlots(date: date);
  }

  /// Extrait le code postal d'une adresse (regex simple)
  String? _extractPostalCode(String? address) {
    if (address == null) return null;

    // Regex pour code postal français (5 chiffres)
    final regExp = RegExp(r'\b\d{5}\b');
    final match = regExp.firstMatch(address);
    return match?.group(0);
  }

  /// Retourne toutes les zones de livraison actives
  List<DeliveryZone> getActiveZones() {
    return settings.activeAreas;
  }

  /// Vérifie si une commande atteint le montant minimum
  bool meetsMinimumOrder(double orderAmount, String? postalCode) {
    final minimumAmount = priceCalculator.getMinimumOrderAmount(postalCode);
    return orderAmount >= minimumAmount;
  }
}
