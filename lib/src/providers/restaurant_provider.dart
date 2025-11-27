// lib/src/providers/restaurant_provider.dart
// Riverpod provider for current restaurant configuration in multi-tenant architecture

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant_config.dart';

/// Provider for the current restaurant configuration
///
/// CRITICAL: Default value is set to 'delizza' to maintain backwards compatibility
/// during migration. This can be overridden in ProviderScope at app startup.
///
/// Usage:
/// ```dart
/// // Read the current restaurant config
/// final config = ref.watch(currentRestaurantProvider);
/// 
/// // Access the restaurant ID
/// final appId = config.id;
/// ```
final currentRestaurantProvider = Provider<RestaurantConfig>((ref) {
  // Default value for backwards compatibility during migration
  return const RestaurantConfig(
    id: 'delizza',
    name: 'Delizza Default',
  );
});
