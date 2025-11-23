// lib/src/providers/app_config_provider.dart
// Provider for application configuration (including B3 pages)

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_config.dart';
import '../services/app_config_service.dart';
import '../core/constants.dart';

// Service provider
final appConfigServiceProvider = Provider<AppConfigService>((ref) {
  return AppConfigService();
});

// Published AppConfig stream provider (for live pages)
// Auto-creates config with B3 pages on first access if it doesn't exist
final appConfigProvider = StreamProvider<AppConfig?>((ref) async* {
  final service = ref.watch(appConfigServiceProvider);
  final appId = AppConstants.appId;
  
  debugPrint('📡 AppConfigProvider: Loading published config for appId: $appId');
  
  // First, try to get the config (which will auto-create if needed)
  final initialConfig = await service.getConfig(
    appId: appId, 
    draft: false, 
    autoCreate: true,
  );
  
  // Yield the initial config immediately
  if (initialConfig != null) {
    debugPrint('📡 AppConfigProvider: Published config loaded with ${initialConfig.pages.pages.length} pages');
    yield initialConfig;
  } else {
    debugPrint('📡 AppConfigProvider: WARNING - Published config is null');
  }
  
  // Then switch to watching for real-time updates
  debugPrint('📡 AppConfigProvider: Now watching for real-time updates');
  await for (final config in service.watchConfig(appId: appId, draft: false)) {
    if (config != null) {
      debugPrint('📡 AppConfigProvider: Published config updated (${config.pages.pages.length} pages)');
      yield config;
    }
  }
});

// Draft AppConfig stream provider (for Studio B3 editing)
// Auto-creates draft from published on first access if it doesn't exist
final appConfigDraftProvider = StreamProvider<AppConfig?>((ref) async* {
  final service = ref.watch(appConfigServiceProvider);
  final appId = AppConstants.appId;
  
  debugPrint('📝 AppConfigDraftProvider: Loading draft config for appId: $appId');
  
  // First, try to get the draft config (which will auto-create if needed)
  final initialConfig = await service.getConfig(
    appId: appId, 
    draft: true, 
    autoCreate: true,
  );
  
  // Yield the initial config immediately
  if (initialConfig != null) {
    debugPrint('📝 AppConfigDraftProvider: Draft config loaded with ${initialConfig.pages.pages.length} pages');
    yield initialConfig;
  } else {
    debugPrint('📝 AppConfigDraftProvider: WARNING - Draft config is null');
  }
  
  // Then switch to watching for real-time updates
  debugPrint('📝 AppConfigDraftProvider: Now watching for real-time updates');
  await for (final config in service.watchConfig(appId: appId, draft: true)) {
    if (config != null) {
      debugPrint('📝 AppConfigDraftProvider: Draft config updated (${config.pages.pages.length} pages)');
      yield config;
    }
  }
});

// Future provider for one-time fetch with auto-initialization
// Note: This is useful for non-reactive contexts where a Stream is not needed
// For most UI code, prefer using appConfigProvider which provides real-time updates
final appConfigFutureProvider = FutureProvider<AppConfig?>((ref) async {
  final service = ref.watch(appConfigServiceProvider);
  final appId = AppConstants.appId;
  
  // Get published config, auto-creating if needed
  final config = await service.getConfig(appId: appId, draft: false, autoCreate: true);
  
  return config;
});
