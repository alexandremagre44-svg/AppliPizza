// lib/src/providers/app_texts_provider.dart
// Provider for app texts configuration with real-time updates from Firestore

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_texts_config.dart';
import '../services/app_texts_service.dart';
import 'restaurant_provider.dart';

/// Provider for AppTextsService
final appTextsServiceProvider = Provider<AppTextsService>((ref) {
  final appId = ref.watch(currentRestaurantProvider).id;
  return AppTextsService(appId: appId);
});

/// Stream provider for real-time app texts configuration
/// Watches Firestore for changes and updates automatically
final appTextsConfigProvider = StreamProvider<AppTextsConfig>((ref) {
  final service = ref.watch(appTextsServiceProvider);
  return service.watchAppTextsConfig();
});

/// AsyncValue provider for one-time fetch of app texts
/// Useful for initialization or when stream is not needed
final appTextsConfigFutureProvider = FutureProvider<AppTextsConfig>((ref) async {
  final service = ref.watch(appTextsServiceProvider);
  return await service.getAppTextsConfig();
});
