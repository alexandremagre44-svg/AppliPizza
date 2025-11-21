// lib/src/studio/preview/simulation_state.dart
// Model for holding all simulation parameters for the preview

import 'package:flutter/material.dart';

/// User simulation types
enum SimulatedUserType {
  newCustomer,
  returningCustomer,
  cartFilled,
  frequentBuyer,
  vipLoyalty,
}

/// Simulation state for preview
class SimulationState {
  // User simulation
  final SimulatedUserType userType;
  final String userId;
  
  // Time simulation
  final int simulatedHour; // 0-23
  final int simulatedDay; // 1=Monday, 7=Sunday
  
  // Cart simulation
  final int cartItemCount; // 0, 1, 2, etc.
  final double? manualCartAmount;
  final bool hasCombo;
  
  // Order history simulation
  final int previousOrdersCount; // 0-20
  
  // Theme simulation
  final ThemeMode themeMode;

  const SimulationState({
    this.userType = SimulatedUserType.newCustomer,
    this.userId = 'preview_user_123',
    this.simulatedHour = 12,
    this.simulatedDay = 3, // Wednesday
    this.cartItemCount = 0,
    this.manualCartAmount,
    this.hasCombo = false,
    this.previousOrdersCount = 0,
    this.themeMode = ThemeMode.light,
  });

  SimulationState copyWith({
    SimulatedUserType? userType,
    String? userId,
    int? simulatedHour,
    int? simulatedDay,
    int? cartItemCount,
    double? manualCartAmount,
    bool? hasCombo,
    int? previousOrdersCount,
    ThemeMode? themeMode,
  }) {
    return SimulationState(
      userType: userType ?? this.userType,
      userId: userId ?? this.userId,
      simulatedHour: simulatedHour ?? this.simulatedHour,
      simulatedDay: simulatedDay ?? this.simulatedDay,
      cartItemCount: cartItemCount ?? this.cartItemCount,
      manualCartAmount: manualCartAmount ?? this.manualCartAmount,
      hasCombo: hasCombo ?? this.hasCombo,
      previousOrdersCount: previousOrdersCount ?? this.previousOrdersCount,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  /// Get simulated DateTime based on current simulation parameters
  DateTime get simulatedDateTime {
    final now = DateTime.now();
    // Find the next occurrence of the simulated day
    final daysUntilTarget = (simulatedDay - now.weekday) % 7;
    final targetDate = now.add(Duration(days: daysUntilTarget));
    
    return DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      simulatedHour,
      0,
      0,
    );
  }

  /// Get user display name based on type
  String get userDisplayName {
    switch (userType) {
      case SimulatedUserType.newCustomer:
        return 'Nouveau Client';
      case SimulatedUserType.returningCustomer:
        return 'Client Habituel';
      case SimulatedUserType.cartFilled:
        return 'Client Panier Rempli';
      case SimulatedUserType.frequentBuyer:
        return 'Client Fréquent (5 commandes)';
      case SimulatedUserType.vipLoyalty:
        return 'Client VIP Fidélité';
    }
  }

  /// Get day name in French
  String get dayName {
    switch (simulatedDay) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return 'Lundi';
    }
  }
}
