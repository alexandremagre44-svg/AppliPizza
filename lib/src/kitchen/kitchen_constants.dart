// lib/src/kitchen/kitchen_constants.dart

import 'package:flutter/material.dart';

/// Constantes pour le mode cuisine
class KitchenConstants {
  // Planning window configuration
  static const int planningWindowPastMin = 15;
  static const int planningWindowFutureMin = 45;
  static const int backlogMaxVisible = 7;
  
  // Notification configuration
  static const int notificationRepeatSeconds = 12;
  
  // Grid configuration
  static const int minVisibleCards = 6;
  static const int gridCrossAxisCount = 2; // 2x3 by default
  static const double gridChildAspectRatio = 1.3;
  
  // Card dimensions for responsive layout
  static const double targetCardHeight = 280.0; // Target height for desktop cards (more horizontal)
  static const double gridSpacing = 16.0; // Gap between cards
  
  // Status colors for kitchen mode (high contrast on black background)
  static const Color statusPending = Color(0xFF2196F3); // Blue
  static const Color statusPreparing = Color(0xFFE91E63); // Pink/Magenta
  static const Color statusBaking = Color(0xFFF44336); // Red
  static const Color statusReady = Color(0xFF4CAF50); // Green
  static const Color statusCancelled = Color(0xFF757575); // Grey
  
  // Status labels (mapping to OrderStatus values)
  static const String statusLabelPending = 'En attente';
  static const String statusLabelPreparing = 'En préparation';
  static const String statusLabelBaking = 'En cuisson';
  static const String statusLabelReady = 'Prête';
  static const String statusLabelCancelled = 'Annulée';
  
  // Kitchen background
  static const Color kitchenBackground = Color(0xFF000000);
  static const Color kitchenSurface = Color(0xFF1A1A1A);
  static const Color kitchenText = Color(0xFFFFFFFF);
  static const Color kitchenTextSecondary = Color(0xFFB0B0B0);
  
  /// Get status color based on status label
  static Color getStatusColor(String status) {
    switch (status) {
      case statusLabelPending:
        return statusPending;
      case statusLabelPreparing:
        return statusPreparing;
      case statusLabelBaking:
      case 'En cuisson':
        return statusBaking;
      case statusLabelReady:
      case 'Prête':
      case 'Livrée':
        return statusReady;
      case statusLabelCancelled:
        return statusCancelled;
      default:
        return statusPending;
    }
  }
  
  /// Get next status in the workflow
  static String? getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case statusLabelPending:
        return statusLabelPreparing;
      case statusLabelPreparing:
        return statusLabelBaking;
      case statusLabelBaking:
        return statusLabelReady;
      case statusLabelReady:
        return null; // No next status after ready
      default:
        return null;
    }
  }
  
  /// Get previous status in the workflow
  static String? getPreviousStatus(String currentStatus) {
    switch (currentStatus) {
      case statusLabelReady:
        return statusLabelBaking;
      case statusLabelBaking:
        return statusLabelPreparing;
      case statusLabelPreparing:
        return statusLabelPending;
      case statusLabelPending:
        return null; // No previous status before pending
      default:
        return null;
    }
  }
}
