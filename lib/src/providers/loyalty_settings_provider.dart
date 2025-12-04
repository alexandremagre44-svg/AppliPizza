// lib/src/providers/loyalty_settings_provider.dart
// Provider for loyalty settings service with multi-tenant support

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loyalty_settings.dart';
import '../services/loyalty_settings_service.dart';
import 'restaurant_provider.dart';
import 'restaurant_plan_provider.dart';
import '../../white_label/core/module_id.dart';

/// Provider for LoyaltySettingsService scoped to the current restaurant
final loyaltySettingsServiceProvider = Provider<LoyaltySettingsService>((ref) {
  final config = ref.watch(currentRestaurantProvider);
  final appId = config.isValid ? config.id : 'delizza';
  return LoyaltySettingsService(appId: appId);
});

/// Stream provider for loyalty settings
/// Module guard: requires loyalty module
final loyaltySettingsProvider = StreamProvider<LoyaltySettings>((ref) {
  // Module guard: loyalty module required
  final flags = ref.watch(restaurantFeatureFlagsProvider);
  if (flags != null && !flags.has(ModuleId.loyalty)) {
    return Stream.value(LoyaltySettings.defaultSettings());
  }
  
  final service = ref.watch(loyaltySettingsServiceProvider);
  return service.watchLoyaltySettings();
});

/// Future provider for one-time fetch
/// Module guard: requires loyalty module
final loyaltySettingsFutureProvider = FutureProvider<LoyaltySettings>((ref) async {
  // Module guard: loyalty module required
  final flags = ref.watch(restaurantFeatureFlagsProvider);
  if (flags != null && !flags.has(ModuleId.loyalty)) {
    return LoyaltySettings.defaultSettings();
  }
  
  final service = ref.watch(loyaltySettingsServiceProvider);
  final settings = await service.getLoyaltySettings();
  
  // Initialize default settings if none exists
  if (settings == LoyaltySettings.defaultSettings()) {
    await service.initializeDefaultSettings();
    return await service.getLoyaltySettings();
  }
  
  return settings;
});
