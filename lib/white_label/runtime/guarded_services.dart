/// lib/white_label/runtime/guarded_services.dart
/// Guarded Service Wrappers
///
/// This file provides non-intrusive wrappers around existing services
/// that add module guards to protect business operations.
///
/// NON-INTRUSIVE: Original services remain unchanged.
/// These wrappers can be used optionally where needed.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/module_id.dart';
import '../../src/services/loyalty_service.dart';
import '../../src/services/roulette_service.dart';
import '../../src/services/promotion_service.dart';
import '../../src/models/roulette_config.dart';
import '../../src/providers/restaurant_provider.dart';
import 'service_guard.dart';

/// Guarded wrapper for LoyaltyService.
///
/// Adds module guard checks before delegating to the inner service.
/// All methods throw [ModuleDisabledException] if loyalty module is disabled.
///
/// Usage:
/// ```dart
/// final guardedLoyalty = GuardedLoyaltyService(
///   inner: loyaltyService,
///   guard: serviceGuard,
/// );
///
/// // Throws if loyalty module is disabled
/// await guardedLoyalty.addPointsFromOrder(userId, total);
/// ```
class GuardedLoyaltyService {
  /// The underlying loyalty service.
  final LoyaltyService inner;

  /// The service guard.
  final ServiceGuard guard;

  GuardedLoyaltyService({
    required this.inner,
    required this.guard,
  });

  /// Initialize loyalty with guard check.
  Future<void> initializeLoyalty(String uid) async {
    guard.ensureEnabled(ModuleId.loyalty, 'initializeLoyalty');
    return inner.initializeLoyalty(uid);
  }

  /// Add points from order with guard check.
  Future<void> addPointsFromOrder(String uid, double orderTotalInEuros) async {
    guard.ensureEnabled(ModuleId.loyalty, 'addPointsFromOrder');
    return inner.addPointsFromOrder(uid, orderTotalInEuros);
  }

  /// Add manual points with guard check.
  Future<void> addManualPoints(String uid, int points, String reason) async {
    guard.ensureEnabled(ModuleId.loyalty, 'addManualPoints');
    return inner.addManualPoints(uid, points, reason);
  }

  /// Use reward with guard check.
  Future<bool> useReward(String uid, String rewardId) async {
    guard.ensureEnabled(ModuleId.loyalty, 'useReward');
    return inner.useReward(uid, rewardId);
  }

  /// Get user loyalty data with guard check.
  Future<Map<String, dynamic>?> getUserLoyaltyData(String uid) async {
    guard.ensureEnabled(ModuleId.loyalty, 'getUserLoyaltyData');
    return inner.getUserLoyaltyData(uid);
  }

  /// Add available spin with guard check.
  Future<void> addAvailableSpin(String uid) async {
    guard.ensureEnabled(ModuleId.loyalty, 'addAvailableSpin');
    return inner.addAvailableSpin(uid);
  }

  /// Use spin with guard check.
  Future<bool> useSpin(String uid) async {
    guard.ensureEnabled(ModuleId.loyalty, 'useSpin');
    return inner.useSpin(uid);
  }

  /// Get app ID.
  String get appId => inner.appId;
}

/// Guarded wrapper for RouletteService.
///
/// Adds module guard checks before delegating to the inner service.
/// All methods throw [ModuleDisabledException] if roulette module is disabled.
///
/// Usage:
/// ```dart
/// final guardedRoulette = GuardedRouletteService(
///   inner: rouletteService,
///   guard: serviceGuard,
/// );
///
/// // Throws if roulette module is disabled
/// await guardedRoulette.recordSpin(userId, segment);
/// ```
class GuardedRouletteService {
  /// The underlying roulette service.
  final RouletteService inner;

  /// The service guard.
  final ServiceGuard guard;

  GuardedRouletteService({
    required this.inner,
    required this.guard,
  });

  /// Record spin with guard check.
  Future<bool> recordSpin(String userId, RouletteSegment segment) async {
    guard.ensureEnabled(ModuleId.roulette, 'recordSpin');
    return inner.recordSpin(userId, segment);
  }

  /// Get user spin history with guard check.
  Future<List<Map<String, dynamic>>> getUserSpinHistory(
    String userId, {
    int limit = 10,
  }) async {
    guard.ensureEnabled(ModuleId.roulette, 'getUserSpinHistory');
    return inner.getUserSpinHistory(userId, limit: limit);
  }

  /// Spin wheel with guard check.
  RouletteSegment spinWheel(List<RouletteSegment> segments) {
    guard.ensureEnabled(ModuleId.roulette, 'spinWheel');
    return inner.spinWheel(segments);
  }

  /// Get app ID.
  String get appId => inner.appId;
}

/// Guarded wrapper for PromotionService.
///
/// Adds module guard checks before delegating to the inner service.
/// All methods throw [ModuleDisabledException] if promotions module is disabled.
///
/// Usage:
/// ```dart
/// final guardedPromo = GuardedPromotionService(
///   inner: promoService,
///   guard: serviceGuard,
/// );
///
/// // Throws if promotions module is disabled
/// final promos = await guardedPromo.getActivePromotions();
/// ```
class GuardedPromotionService {
  /// The underlying promotion service.
  final PromotionService inner;

  /// The service guard.
  final ServiceGuard guard;

  GuardedPromotionService({
    required this.inner,
    required this.guard,
  });

  /// Get active promotions with guard check.
  Future<List<Map<String, dynamic>>> getActivePromotions() async {
    guard.ensureEnabled(ModuleId.promotions, 'getActivePromotions');
    return inner.getActivePromotions();
  }

  /// Apply promo code with guard check.
  Future<Map<String, dynamic>?> applyPromoCode(String code) async {
    guard.ensureEnabled(ModuleId.promotions, 'applyPromoCode');
    return inner.applyPromoCode(code);
  }

  /// Get app ID.
  String get appId => inner.appId;
}

/// Provider for GuardedLoyaltyService.
///
/// Automatically wraps the loyalty service with guard checks.
///
/// Usage:
/// ```dart
/// final guardedLoyalty = ref.watch(guardedLoyaltyServiceProvider);
/// await guardedLoyalty.addPointsFromOrder(userId, total);
/// ```
final guardedLoyaltyServiceProvider = Provider<GuardedLoyaltyService>((ref) {
  final loyaltyService = ref.watch(loyaltyServiceProvider);
  final guard = ref.watch(serviceGuardProvider);

  return GuardedLoyaltyService(
    inner: loyaltyService,
    guard: guard,
  );
});

/// Provider for GuardedRouletteService.
///
/// Automatically wraps the roulette service with guard checks.
///
/// Usage:
/// ```dart
/// final guardedRoulette = ref.watch(guardedRouletteServiceProvider);
/// await guardedRoulette.recordSpin(userId, segment);
/// ```
final guardedRouletteServiceProvider = Provider<GuardedRouletteService>((ref) {
  final rouletteService = ref.watch(rouletteServiceProvider);
  final guard = ref.watch(serviceGuardProvider);

  return GuardedRouletteService(
    inner: rouletteService,
    guard: guard,
  );
});

/// Provider for GuardedPromotionService.
///
/// Automatically wraps the promotion service with guard checks.
///
/// Usage:
/// ```dart
/// final guardedPromo = ref.watch(guardedPromotionServiceProvider);
/// final promos = await guardedPromo.getActivePromotions();
/// ```
final guardedPromotionServiceProvider = Provider<GuardedPromotionService>((ref) {
  final promotionService = ref.watch(promotionServiceProvider);
  final guard = ref.watch(serviceGuardProvider);

  return GuardedPromotionService(
    inner: promotionService,
    guard: guard,
  );
});

/// Helper extension for creating guarded services manually.
extension GuardedServiceExtension on ServiceGuard {
  /// Wrap a loyalty service with this guard.
  GuardedLoyaltyService wrapLoyalty(LoyaltyService service) {
    return GuardedLoyaltyService(inner: service, guard: this);
  }

  /// Wrap a roulette service with this guard.
  GuardedRouletteService wrapRoulette(RouletteService service) {
    return GuardedRouletteService(inner: service, guard: this);
  }

  /// Wrap a promotion service with this guard.
  GuardedPromotionService wrapPromotion(PromotionService service) {
    return GuardedPromotionService(inner: service, guard: this);
  }
}
