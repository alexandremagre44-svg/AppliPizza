// lib/src/providers/reward_tickets_provider.dart
// Provider for active reward tickets and app texts configuration

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reward_ticket.dart';
import '../models/app_texts_config.dart';
import '../services/reward_service.dart';
import '../services/app_texts_service.dart';
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

/// Provider for app texts service instance
final appTextsServiceProvider = Provider((ref) {
  return AppTextsService();
});

/// Provider for app texts configuration
final appTextsConfigProvider = StreamProvider.autoDispose<AppTextsConfig>((ref) {
  final service = ref.watch(appTextsServiceProvider);
  return service.watchAppTextsConfig();
});
