// lib/src/providers/loyalty_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/loyalty_service.dart';
import 'auth_provider.dart';
import 'restaurant_plan_provider.dart';
import '../../white_label/core/module_id.dart';

/// Provider pour les informations de fidélité de l'utilisateur connecté
/// Module guard: requires loyalty module to be enabled
final loyaltyInfoProvider = StreamProvider.autoDispose<Map<String, dynamic>?>(
  (ref) {
    // Module guard: loyalty module required
    final flags = ref.watch(restaurantFeatureFlagsProvider);
    if (flags != null && !flags.has(ModuleId.loyalty)) {
      return Stream.value(null);
    }
    
    final authState = ref.watch(authProvider);
    final uid = authState.userId;
    final loyaltyService = ref.watch(loyaltyServiceProvider);
    
    if (uid == null) {
      return Stream.value(null);
    }
    
    return loyaltyService.watchLoyaltyInfo(uid);
  },
  dependencies: [restaurantFeatureFlagsProvider, authProvider, loyaltyServiceProvider],
);
