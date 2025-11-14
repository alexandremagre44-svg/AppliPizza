// lib/src/features/content/presentation/admin/debouncer.dart
// Utility class for debouncing rapid function calls

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer utility to delay function execution until after a specified duration
/// Useful for preventing excessive API calls during rapid user input
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({required this.duration});

  /// Call this method with the function to debounce
  /// The function will only execute after [duration] has passed without another call
  void call(VoidCallback callback) {
    // Cancel the previous timer if it exists
    _timer?.cancel();
    
    // Create a new timer
    _timer = Timer(duration, callback);
  }

  /// Cancel any pending debounced calls
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debouncer
  void dispose() {
    _timer?.cancel();
  }
}
