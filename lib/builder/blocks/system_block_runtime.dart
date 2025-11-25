// lib/builder/blocks/system_block_runtime.dart
// Runtime version of SystemBlock - renders existing application modules

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/builder_block.dart';
import '../utils/block_config_helper.dart';
import '../../src/screens/roulette/roulette_screen.dart';
import '../../src/screens/profile/widgets/loyalty_section_widget.dart';
import '../../src/screens/profile/widgets/rewards_tickets_widget.dart';
import '../../src/screens/profile/widgets/account_activity_widget.dart';
import '../../src/models/app_texts_config.dart';
import '../../src/models/reward_ticket.dart';

/// System Block Runtime Widget
/// 
/// Renders existing application modules within the Builder B3 system.
/// 
/// Supported modules:
/// - roulette: Roulette wheel game (RouletteScreen)
/// - loyalty: Loyalty points section (LoyaltySectionWidget)
/// - rewards: Rewards tickets widget (RewardsTicketsWidget)
/// - accountActivity: Account activity widget (AccountActivityWidget)
/// 
/// Configuration:
/// - moduleType: Required - the type of system module to render
/// - padding: Optional padding around the module
/// - margin: Optional margin around the module
/// - backgroundColor: Optional background color
class SystemBlockRuntime extends ConsumerWidget {
  final BuilderBlock block;

  const SystemBlockRuntime({
    super.key,
    required this.block,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helper = BlockConfigHelper(block.config, blockId: block.id);
    
    // Get the module type from config
    final moduleType = helper.getString('moduleType', defaultValue: '');
    
    // Get styling configuration
    final padding = helper.getEdgeInsets('padding', defaultValue: const EdgeInsets.all(16));
    final margin = helper.getEdgeInsets('margin');
    final backgroundColor = helper.getColor('backgroundColor');
    
    // Build the module widget based on type
    Widget moduleWidget = _buildModuleWidget(context, ref, moduleType);
    
    // Apply padding
    moduleWidget = Padding(
      padding: padding,
      child: moduleWidget,
    );
    
    // Apply background and margin if specified
    if (margin != EdgeInsets.zero || backgroundColor != null) {
      moduleWidget = Container(
        margin: margin,
        decoration: backgroundColor != null
            ? BoxDecoration(color: backgroundColor)
            : null,
        child: moduleWidget,
      );
    }
    
    // Ensure full width
    return SizedBox(
      width: double.infinity,
      child: moduleWidget,
    );
  }

  Widget _buildModuleWidget(BuildContext context, WidgetRef ref, String moduleType) {
    switch (moduleType) {
      case 'roulette':
        return _buildRouletteModule(context, ref);
      case 'loyalty':
        return _buildLoyaltyModule(context, ref);
      case 'rewards':
        return _buildRewardsModule(context, ref);
      case 'accountActivity':
        return _buildAccountActivityModule(context, ref);
      default:
        return _buildUnknownModule(moduleType);
    }
  }

  /// Build Roulette module - uses RouletteScreen widget
  Widget _buildRouletteModule(BuildContext context, WidgetRef ref) {
    // Note: RouletteScreen requires a userId, which should come from auth state
    // For now, we display a placeholder that indicates the roulette will show here
    // In production, this should integrate with the auth provider
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade400,
            Colors.purple.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.casino,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'Roue de la Chance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tentez votre chance et gagnez des récompenses !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to roulette screen
              Navigator.of(context).pushNamed('/roulette');
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Jouer maintenant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Loyalty module - uses LoyaltySectionWidget
  Widget _buildLoyaltyModule(BuildContext context, WidgetRef ref) {
    // Default values for demo/preview - in production these come from providers
    const defaultLoyaltyPoints = 350;
    const defaultLifetimePoints = 1250;
    const defaultVipTier = 'bronze';
    final defaultTexts = ProfileTexts(
      loyaltyTitle: 'Programme Fidélité',
      loyaltyPoints: 'Points disponibles',
      loyaltyProgress: 'Progression vers pizza gratuite',
      loyaltyPointsNeeded: 'Encore {points} pts pour une pizza gratuite',
      loyaltyCtaViewRewards: 'Voir mes récompenses',
      rewardsTitle: 'Récompenses',
      rewardsCtaViewAll: 'Voir tout',
      activityMyOrders: 'Mes commandes',
      activityMyFavorites: 'Mes favoris',
    );
    
    return LoyaltySectionWidget(
      loyaltyPoints: defaultLoyaltyPoints,
      lifetimePoints: defaultLifetimePoints,
      vipTier: defaultVipTier,
      texts: defaultTexts,
    );
  }

  /// Build Rewards module - uses RewardsTicketsWidget
  Widget _buildRewardsModule(BuildContext context, WidgetRef ref) {
    // Default values for demo/preview - in production these come from providers
    final defaultProfileTexts = ProfileTexts(
      loyaltyTitle: 'Programme Fidélité',
      loyaltyPoints: 'Points disponibles',
      loyaltyProgress: 'Progression vers pizza gratuite',
      loyaltyPointsNeeded: 'Encore {points} pts pour une pizza gratuite',
      loyaltyCtaViewRewards: 'Voir mes récompenses',
      rewardsTitle: 'Mes récompenses',
      rewardsCtaViewAll: 'Voir tout',
      activityMyOrders: 'Mes commandes',
      activityMyFavorites: 'Mes favoris',
    );
    final defaultRewardsTexts = RewardsTexts(
      title: 'Récompenses',
      active: 'Actif',
      expireAt: 'Expire le {date}',
      noRewards: 'Aucune récompense disponible',
    );
    
    // Empty list for demo - in production this comes from rewards provider
    final List<RewardTicket> emptyTickets = [];
    
    // If no tickets, show placeholder
    if (emptyTickets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 48,
              color: Colors.orange.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              defaultProfileTexts.rewardsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              defaultRewardsTexts.noRewards,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return RewardsTicketsWidget(
      activeTickets: emptyTickets,
      profileTexts: defaultProfileTexts,
      rewardsTexts: defaultRewardsTexts,
    );
  }

  /// Build Account Activity module - uses AccountActivityWidget
  Widget _buildAccountActivityModule(BuildContext context, WidgetRef ref) {
    // Default values for demo/preview - in production these come from providers
    const defaultOrdersCount = 12;
    const defaultFavoritesCount = 5;
    final defaultTexts = ProfileTexts(
      loyaltyTitle: 'Programme Fidélité',
      loyaltyPoints: 'Points disponibles',
      loyaltyProgress: 'Progression vers pizza gratuite',
      loyaltyPointsNeeded: 'Encore {points} pts pour une pizza gratuite',
      loyaltyCtaViewRewards: 'Voir mes récompenses',
      rewardsTitle: 'Récompenses',
      rewardsCtaViewAll: 'Voir tout',
      activityMyOrders: 'Mes commandes',
      activityMyFavorites: 'Mes favoris',
    );
    
    return AccountActivityWidget(
      ordersCount: defaultOrdersCount,
      favoritesCount: defaultFavoritesCount,
      texts: defaultTexts,
      onOrdersTap: () {
        Navigator.of(context).pushNamed('/orders');
      },
      onFavoritesTap: () {
        Navigator.of(context).pushNamed('/favorites');
      },
    );
  }

  /// Build unknown module placeholder
  Widget _buildUnknownModule(String moduleType) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 12),
          Text(
            'Module introuvable',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Type: $moduleType',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
