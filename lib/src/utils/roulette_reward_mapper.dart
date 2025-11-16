// lib/src/utils/roulette_reward_mapper.dart
// Utility to map RouletteSegment to RewardAction and create tickets

import '../models/roulette_config.dart' as roulette;
import '../models/reward_action.dart';
import '../models/reward_ticket.dart';
import '../services/reward_service.dart';
import '../services/roulette_rules_service.dart';
import '../services/loyalty_service.dart';

/// Map a RouletteSegment to a RewardAction
/// 
/// Converts the roulette segment data into the new reward system format
RewardAction mapSegmentToRewardAction(roulette.RouletteSegment segment) {
  final rewardType = segment.rewardType;
  
  // Map roulette reward type to new reward type
  RewardType mappedType;
  switch (rewardType) {
    case roulette.RewardType.bonusPoints:
      mappedType = RewardType.bonusPoints;
      break;
    case roulette.RewardType.percentageDiscount:
      mappedType = RewardType.percentageDiscount;
      break;
    case roulette.RewardType.fixedAmountDiscount:
      mappedType = RewardType.fixedDiscount;
      break;
    case roulette.RewardType.freeProduct:
      mappedType = RewardType.freeProduct;
      break;
    case roulette.RewardType.freePizza:
      mappedType = RewardType.freeProduct; // Map to freeProduct for compatibility
      break;
    case roulette.RewardType.freeDrink:
      mappedType = RewardType.freeDrink;
      break;
    case roulette.RewardType.freeDessert:
      mappedType = RewardType.freeProduct; // Map to freeProduct for compatibility
      break;
    case roulette.RewardType.none:
    default:
      // For "nothing" segments, we still create a ticket but with custom type
      // This allows tracking all spins, even unsuccessful ones
      mappedType = RewardType.custom;
      break;
  }
  
  // Determine categoryId based on reward type
  String? categoryId;
  if (rewardType == roulette.RewardType.freePizza) {
    categoryId = 'Pizza';
  } else if (rewardType == roulette.RewardType.freeDessert) {
    categoryId = 'Dessert';
  } else if (rewardType == roulette.RewardType.freeDrink) {
    categoryId = 'Drink';
  } else if (rewardType == roulette.RewardType.freeProduct) {
    categoryId = 'Pizza'; // Default to pizza category for generic free products
  }
  
  return RewardAction(
    type: mappedType,
    points: rewardType == roulette.RewardType.bonusPoints
        ? segment.rewardValue?.toInt() ?? segment.value
        : null,
    percentage: rewardType == roulette.RewardType.percentageDiscount 
        ? segment.rewardValue 
        : null,
    amount: rewardType == roulette.RewardType.fixedAmountDiscount 
        ? segment.rewardValue 
        : null,
    productId: segment.productId,
    categoryId: categoryId,
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
/// - [validity]: How long the ticket is valid (default: 7 days for roulette)
/// 
/// Returns the created ticket
Future<RewardTicket?> createTicketFromRouletteSegment({
  required String userId,
  required roulette.RouletteSegment segment,
  Duration? validity,
}) async {
  try {
    // Record in audit trail first
    final rulesService = RouletteRulesService();
    
    // Handle "nothing" segments
    if (segment.rewardType == roulette.RewardType.none) {
      print('Segment is "nothing", no ticket created');
      
      await rulesService.recordSpinAudit(
        userId: userId,
        segmentId: segment.id,
        resultType: 'none',
      );
      
      return null;
    }
    
    // Handle bonus points separately - add directly to loyalty account
    if (segment.rewardType == roulette.RewardType.bonusPoints) {
      final points = segment.rewardValue?.toInt() ?? segment.value ?? 0;
      print('Adding $points bonus points to user $userId');
      
      final loyaltyService = LoyaltyService();
      await loyaltyService.addBonusPoints(userId, points);
      
      await rulesService.recordSpinAudit(
        userId: userId,
        segmentId: segment.id,
        resultType: 'bonus_points',
        deviceInfo: 'mobile_app',
      );
      
      print('Added $points bonus points to user: $userId');
      return null; // No ticket created for points
    }
    
    // For other reward types, create a ticket
    final action = mapSegmentToRewardAction(segment).copyWith(
      source: 'roulette',
    );
    
    // Determine validity based on reward type
    final ticketValidity = validity ?? 
        Duration(days: 7); // Default 7 days for roulette rewards
    
    // Create ticket via RewardService
    final service = RewardService();
    final ticket = await service.createTicket(
      userId: userId,
      action: action,
      validity: ticketValidity,
    );
    
    await rulesService.recordSpinAudit(
      userId: userId,
      segmentId: segment.id,
      resultType: segment.rewardType.toString(),
      ticketId: ticket.id,
      expiration: ticket.expiresAt,
      deviceInfo: 'mobile_app',
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
    case RewardType.bonusPoints:
      return const Duration(days: 0); // Points are immediate, no expiration
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
