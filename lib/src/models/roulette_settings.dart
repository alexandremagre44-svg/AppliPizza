// lib/src/models/roulette_settings.dart
// Modèle pour la configuration des paramètres de la roulette

import 'package:cloud_firestore/cloud_firestore.dart';

/// Configuration complète des règles d'activation de la roulette
/// 
/// Stockage Firestore:
/// - collection: "marketing"
/// - document: "roulette_settings"
class RouletteSettings {
  /// Activation globale de la roulette
  final bool isEnabled;
  
  /// Type de limite d'utilisation
  /// Valeurs possibles: 'none', 'per_day', 'per_week', 'per_month', 'total'
  final String limitType;
  
  /// Valeur de la limite (nombre d'utilisations)
  final int limitValue;
  
  /// Délai en heures entre deux utilisations (cooldown)
  final int cooldownHours;
  
  /// Date de début de validité (optionnel)
  final Timestamp? validFrom;
  
  /// Date de fin de validité (optionnel)
  final Timestamp? validTo;
  
  /// Jours actifs de la semaine
  /// Liste d'entiers: 1=lundi, 2=mardi, ..., 7=dimanche
  final List<int> activeDays;
  
  /// Heure de début d'activation (0-23)
  final int activeStartHour;
  
  /// Heure de fin d'activation (0-23)
  final int activeEndHour;
  
  /// Type d'éligibilité utilisateur
  /// Valeurs possibles: 'all', 'new_users', 'loyal_users', 'min_orders', 'min_spent'
  final String eligibilityType;
  
  /// Nombre minimum de commandes requises (si eligibilityType = 'min_orders')
  final int? minOrders;
  
  /// Montant minimum dépensé requis (si eligibilityType = 'min_spent')
  final double? minSpent;

  RouletteSettings({
    required this.isEnabled,
    this.limitType = 'none',
    this.limitValue = 0,
    this.cooldownHours = 0,
    this.validFrom,
    this.validTo,
    List<int>? activeDays,
    this.activeStartHour = 0,
    this.activeEndHour = 23,
    this.eligibilityType = 'all',
    this.minOrders,
    this.minSpent,
  }) : activeDays = activeDays ?? [1, 2, 3, 4, 5, 6, 7]; // Tous les jours par défaut

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'limitType': limitType,
      'limitValue': limitValue,
      'cooldownHours': cooldownHours,
      'validFrom': validFrom,
      'validTo': validTo,
      'activeDays': activeDays,
      'activeStartHour': activeStartHour,
      'activeEndHour': activeEndHour,
      'eligibilityType': eligibilityType,
      'minOrders': minOrders,
      'minSpent': minSpent,
    };
  }

  /// Création depuis Map Firestore
  factory RouletteSettings.fromMap(Map<String, dynamic> data) {
    return RouletteSettings(
      isEnabled: data['isEnabled'] as bool? ?? false,
      limitType: data['limitType'] as String? ?? 'none',
      limitValue: data['limitValue'] as int? ?? 0,
      cooldownHours: data['cooldownHours'] as int? ?? 0,
      validFrom: data['validFrom'] as Timestamp?,
      validTo: data['validTo'] as Timestamp?,
      activeDays: (data['activeDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [1, 2, 3, 4, 5, 6, 7],
      activeStartHour: data['activeStartHour'] as int? ?? 0,
      activeEndHour: data['activeEndHour'] as int? ?? 23,
      eligibilityType: data['eligibilityType'] as String? ?? 'all',
      minOrders: data['minOrders'] as int?,
      minSpent: (data['minSpent'] as num?)?.toDouble(),
    );
  }

  /// Configuration par défaut
  factory RouletteSettings.defaultSettings() {
    return RouletteSettings(
      isEnabled: false,
      limitType: 'per_day',
      limitValue: 1,
      cooldownHours: 24,
      activeDays: [1, 2, 3, 4, 5, 6, 7],
      activeStartHour: 0,
      activeEndHour: 23,
      eligibilityType: 'all',
    );
  }

  /// Copie avec modifications
  RouletteSettings copyWith({
    bool? isEnabled,
    String? limitType,
    int? limitValue,
    int? cooldownHours,
    Timestamp? validFrom,
    Timestamp? validTo,
    List<int>? activeDays,
    int? activeStartHour,
    int? activeEndHour,
    String? eligibilityType,
    int? minOrders,
    double? minSpent,
  }) {
    return RouletteSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      limitType: limitType ?? this.limitType,
      limitValue: limitValue ?? this.limitValue,
      cooldownHours: cooldownHours ?? this.cooldownHours,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      activeDays: activeDays ?? this.activeDays,
      activeStartHour: activeStartHour ?? this.activeStartHour,
      activeEndHour: activeEndHour ?? this.activeEndHour,
      eligibilityType: eligibilityType ?? this.eligibilityType,
      minOrders: minOrders ?? this.minOrders,
      minSpent: minSpent ?? this.minSpent,
    );
  }

  /// Vérifie si la roulette est active pour un jour donné
  bool isActiveOnDay(int dayOfWeek) {
    return activeDays.contains(dayOfWeek);
  }

  /// Vérifie si la roulette est active à une heure donnée
  bool isActiveAtHour(int hour) {
    if (activeStartHour <= activeEndHour) {
      return hour >= activeStartHour && hour <= activeEndHour;
    } else {
      // Cas où la plage horaire traverse minuit (ex: 22h-2h)
      return hour >= activeStartHour || hour <= activeEndHour;
    }
  }

  /// Vérifie si la roulette est actuellement dans sa période de validité
  bool isWithinValidityPeriod(DateTime now) {
    if (validFrom != null && now.isBefore(validFrom!.toDate())) {
      return false;
    }
    if (validTo != null && now.isAfter(validTo!.toDate())) {
      return false;
    }
    return true;
  }
}
