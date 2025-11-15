// lib/src/utils/roulette_reward_mapper.dart
// Utility to map RouletteSegment to RewardAction and create tickets

import '../models/roulette_config.dart' as roulette;
import '../models/reward_action.dart';
import '../models/reward_ticket.dart';
import '../services/reward_service.dart';

/// Map a RouletteSegment to a RewardAction
/// 
/// Converts the roulette segment data into the new reward system format
RewardAction mapSegmentToRewardAction(roulette.RouletteSegment segment) {
  final rewardType = segment.rewardType;
  
  // Map roulette reward type to new reward type
  RewardType mappedType;
  switch (rewardType) {
    case roulette.RewardType.percentageDiscount:
      mappedType = RewardType.percentageDiscount;
      break;
    case roulette.RewardType.fixedAmountDiscount:
      mappedType = RewardType.fixedDiscount;
      break;
    case roulette.RewardType.freeProduct:
      mappedType = RewardType.freeProduct;
      break;
    case roulette.RewardType.freeDrink:
      mappedType = RewardType.freeDrink;
      break;
    case roulette.RewardType.none:
    default:
      // For "nothing" segments, we still create a ticket but with custom type
      // This allows tracking all spins, even unsuccessful ones
      mappedType = RewardType.custom;
      break;
  }
  
  return RewardAction(
    type: mappedType,
    percentage: rewardType == roulette.RewardType.percentageDiscount 
        ? segment.rewardValue 
        : null,
    amount: rewardType == roulette.RewardType.fixedAmountDiscount 
        ? segment.rewardValue 
        : null,
    productId: segment.productId,
    categoryId: rewardType == roulette.RewardType.freeProduct 
        ? 'Pizza' // Default to pizza category for free products
        : null,
    source: 'roulette',
    label: segment.label,
    description: segment.description ?? segment.label,
  );
}

/// Create a reward ticket from a roulette segment win
/// 
/// This is the main integration point between the roulette and reward system.
/// Call this after a user wins on the roulette wheel.
/// 
/// Parameters:
/// - [userId]: The user who won
/// - [segment]: The winning segment
/// - [validity]: How long the ticket is valid (default: 30 days)
/// 
/// Returns the created ticket
Future<RewardTicket?> createTicketFromRouletteSegment({
  required String userId,
  required roulette.RouletteSegment segment,
  Duration validity = const Duration(days: 30),
}) async {
  try {
    // Don't create tickets for "nothing" segments
    if (segment.rewardType == roulette.RewardType.none) {
      print('Segment is "nothing", no ticket created');
      return null;
    }
    
    // Map segment to reward action
    final action = mapSegmentToRewardAction(segment);
    
    // Create ticket via RewardService
    final service = RewardService();
    final ticket = await service.createTicket(
      userId: userId,
      action: action,
      validity: validity,
    );
    
    print('Created reward ticket: ${ticket.id} for user: $userId');
    return ticket;
  } catch (e) {
    print('Error creating ticket from roulette segment: $e');
    return null;
  }
}

/// Get default validity duration based on reward type
/// 
/// Different reward types may have different validity periods
Duration getValidityForRewardType(RewardType type) {
  switch (type) {
    case RewardType.percentageDiscount:
    case RewardType.fixedDiscount:
      return const Duration(days: 15); // Discounts: 15 days
    case RewardType.freeProduct:
    case RewardType.freeCategory:
    case RewardType.freeAnyPizza:
    case RewardType.freeDrink:
      return const Duration(days: 30); // Free items: 30 days
    case RewardType.custom:
    default:
      return const Duration(days: 30); // Default: 30 days
  }
}
