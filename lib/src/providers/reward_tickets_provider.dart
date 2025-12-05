// lib/src/providers/reward_tickets_provider.dart
// Provider for active reward tickets and app texts configuration

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_ticket.dart';
import '../services/reward_service.dart';
import 'auth_provider.dart';
import 'restaurant_plan_provider.dart';
import '../../white_label/core/module_id.dart';

/// Provider for active reward tickets (not used, not expired)
/// Module guard: requires loyalty module
final activeRewardTicketsProvider = StreamProvider.autoDispose<List<RewardTicket>>(
  (ref) {
    // Module guard: loyalty module required
    final flags = ref.watch(restaurantFeatureFlagsProvider);
    if (flags != null && !flags.has(ModuleId.loyalty)) {
      return Stream.value([]);
    }
    
    final authState = ref.watch(authProvider);
    final userId = authState.userId;
    
    if (userId == null) {
      return Stream.value([]);
    }
    
    final rewardService = ref.watch(rewardServiceProvider);
    return rewardService.watchUserTickets(userId).map((tickets) {
      return tickets.where((ticket) => ticket.isActive).toList();
    });
  },
  dependencies: [restaurantFeatureFlagsProvider, authProvider, rewardServiceProvider],
);

// Note: appTextsServiceProvider and appTextsConfigProvider are now defined in app_texts_provider.dart
// Use those providers from that file instead.
