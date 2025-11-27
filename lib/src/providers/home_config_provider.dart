// lib/src/providers/home_config_provider.dart
// Provider for home configuration

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_config.dart';
import '../services/home_config_service.dart';
import 'restaurant_provider.dart';

// Service provider
final homeConfigServiceProvider = Provider<HomeConfigService>((ref) {
  final config = ref.watch(currentRestaurantProvider);
  // Use default 'delizza' if config is invalid (should not happen in normal usage)
  final appId = config.isValid ? config.id : 'delizza';
  return HomeConfigService(appId: appId);
});

// Home config provider
final homeConfigProvider = StreamProvider<HomeConfig?>((ref) {
  final service = ref.watch(homeConfigServiceProvider);
  return service.watchHomeConfig();
});

// Async version for one-time fetch
final homeConfigFutureProvider = FutureProvider<HomeConfig?>((ref) async {
  final service = ref.watch(homeConfigServiceProvider);
  final config = await service.getHomeConfig();
  
  // Initialize default config if none exists
  if (config == null) {
    await service.initializeDefaultConfig();
    return await service.getHomeConfig();
  }
  
  return config;
});
