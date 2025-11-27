// lib/src/providers/reward_tickets_provider.dart
// Provider for active reward tickets and app texts configuration

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_ticket.dart';
import '../services/reward_service.dart';
import 'auth_provider.dart';

/// Provider for active reward tickets (not used, not expired)
final activeRewardTicketsProvider = StreamProvider.autoDispose<List<RewardTicket>>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.userId;
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  final rewardService = RewardService();
  return rewardService.watchUserTickets(userId).map((tickets) {
    return tickets.where((ticket) => ticket.isActive).toList();
  });
});

// Note: appTextsServiceProvider and appTextsConfigProvider are now defined in app_texts_provider.dart
// Use those providers from that file instead.
