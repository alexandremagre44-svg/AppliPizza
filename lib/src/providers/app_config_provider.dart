// lib/src/providers/app_config_provider.dart
// Provider for application configuration (including B3 pages)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_config.dart';
import '../services/app_config_service.dart';

// Service provider
final appConfigServiceProvider = Provider<AppConfigService>((ref) {
  return AppConfigService();
});

// Published AppConfig stream provider (for live pages)
// Auto-creates config with B3 pages on first access if it doesn't exist
final appConfigProvider = StreamProvider<AppConfig?>((ref) async* {
  final service = ref.watch(appConfigServiceProvider);
  const appId = 'pizza_delizza';
  
  // First, try to get the config (which will auto-create if needed)
  final initialConfig = await service.getConfig(
    appId: appId, 
    draft: false, 
    autoCreate: true,
  );
  
  // Yield the initial config immediately
  if (initialConfig != null) {
    yield initialConfig;
  }
  
  // Then switch to watching for real-time updates
  await for (final config in service.watchConfig(appId: appId, draft: false)) {
    if (config != null) {
      yield config;
    }
  }
});

// Draft AppConfig stream provider (for Studio B3 editing)
// Auto-creates draft from published on first access if it doesn't exist
final appConfigDraftProvider = StreamProvider<AppConfig?>((ref) async* {
  final service = ref.watch(appConfigServiceProvider);
  const appId = 'pizza_delizza';
  
  // First, try to get the draft config (which will auto-create if needed)
  final initialConfig = await service.getConfig(
    appId: appId, 
    draft: true, 
    autoCreate: true,
  );
  
  // Yield the initial config immediately
  if (initialConfig != null) {
    yield initialConfig;
  }
  
  // Then switch to watching for real-time updates
  await for (final config in service.watchConfig(appId: appId, draft: true)) {
    if (config != null) {
      yield config;
    }
  }
});

// Future provider for one-time fetch with auto-initialization
final appConfigFutureProvider = FutureProvider<AppConfig?>((ref) async {
  final service = ref.watch(appConfigServiceProvider);
  const appId = 'pizza_delizza';
  
  // Get published config, auto-creating if needed
  final config = await service.getConfig(appId: appId, draft: false, autoCreate: true);
  
  return config;
});
