// lib/src/kitchen/widgets/kitchen_colors.dart

import 'package:flutter/material.dart';

/// Color palette for kitchen mode status cards
/// High contrast colors designed for visibility at 2m distance on black background
class KitchenColors {
  // Status background colors - full card background
  static const Color pendingBackground = Color(0xFF0D47A1); // Deep blue
  static const Color preparingBackground = Color(0xFFAD1457); // Raspberry/Magenta
  static const Color bakingBackground = Color(0xFFE65100); // Dark orange
  static const Color readyBackground = Color(0xFF1B5E20); // Dark green
  static const Color archivedBackground = Color(0xFF424242); // Grey
  
  // Text colors - always white for maximum contrast
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xCCFFFFFF); // White at 80% opacity
  
  // Icon colors
  static const Color iconPrimary = Color(0xCCFFFFFF); // White at 80% opacity
  
  // Elapsed time badge colors
  static const Color elapsedNormal = Color(0xFF757575); // Grey for <15 min
  static const Color elapsedWarning = Color(0xFFFFA726); // Orange/Yellow for >=15 min
  static const Color elapsedCritical = Color(0xFFE53935); // Red for >=25 min
  
  // Shadow color for cards
  static const Color cardShadow = Color(0x8A000000); // Black at 54% opacity
  
  /// Get background color for a given order status
  static Color getStatusBackgroundColor(String status) {
    switch (status) {
      case 'En attente':
        return pendingBackground;
      case 'En préparation':
        return preparingBackground;
      case 'En cuisson':
        return bakingBackground;
      case 'Prête':
      case 'Livrée':
        return readyBackground;
      case 'Annulée':
        return archivedBackground;
      default:
        return pendingBackground;
    }
  }
  
  /// Get elapsed time badge color based on minutes
  static Color getElapsedTimeColor(int minutes) {
    if (minutes >= 25) {
      return elapsedCritical;
    } else if (minutes >= 15) {
      return elapsedWarning;
    } else {
      return elapsedNormal;
    }
  }
}
