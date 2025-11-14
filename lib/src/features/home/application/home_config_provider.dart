// lib/src/providers/home_config_provider.dart
// Provider for home configuration

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/home_config.dart';
import 'package:pizza_delizza/src/features/home/data/repositories/home_config_repository.dart';

// Service provider
final homeConfigRepositoryProvider = Provider<HomeConfigRepository>((ref) {
  return HomeConfigRepository();
});

// Home config provider
final homeConfigProvider = StreamProvider<HomeConfig?>((ref) {
  final service = ref.watch(homeConfigRepositoryProvider);
  return service.watchHomeConfig();
});

// Async version for one-time fetch
final homeConfigFutureProvider = FutureProvider<HomeConfig?>((ref) async {
  final service = ref.watch(homeConfigRepositoryProvider);
  final config = await service.getHomeConfig();
  
  // Initialize default config if none exists
  if (config == null) {
    await service.initializeDefaultConfig();
    return await service.getHomeConfig();
  }
  
  return config;
});
