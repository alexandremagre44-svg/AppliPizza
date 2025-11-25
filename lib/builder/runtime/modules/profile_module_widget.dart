// lib/builder/runtime/modules/profile_module_widget.dart
// Runtime widget for profile_module
// 
// Wraps the existing ProfileScreen for use in Builder system

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../src/providers/user_provider.dart';
import '../../../src/providers/auth_provider.dart';
import '../../../src/providers/loyalty_provider.dart';
import '../../../src/providers/reward_tickets_provider.dart';
import '../../../src/models/app_texts_config.dart';
import '../../../src/theme/app_theme.dart';
import '../../../src/core/constants.dart';
import '../../../src/screens/profile/widgets/loyalty_section_widget.dart';
import '../../../src/screens/profile/widgets/rewards_tickets_widget.dart';
import '../../../src/screens/profile/widgets/roulette_card_widget.dart';
import '../../../src/screens/profile/widgets/account_activity_widget.dart';

/// Profile Module Widget
/// 
/// Profile content for use as a Builder module (without Scaffold)
class ProfileModuleWidget extends ConsumerWidget {
  const ProfileModuleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProvider);
    final authState = ref.watch(authProvider);
    final history = userProfile.orderHistory;
    final loyaltyInfoAsync = ref.watch(loyaltyInfoProvider);
    final activeTicketsAsync = ref.watch(activeRewardTicketsProvider);
    final appTextsAsync = ref.watch(appTextsConfigProvider);
    final userId = authState.userId ?? 'guest';

    // Return just the body content - BuilderPageLoader provides the Scaffold
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Profile Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                // Name
                Text(
                  authState.userEmail ?? userProfile.name,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 8),
                // Admin badge if applicable
                if (authState.isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Administrateur',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Profile sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Roulette Card
                appTextsAsync.when(
                  data: (appTexts) => RouletteCardWidget(
                    texts: appTexts.roulette,
                    userId: userId,
                  ),
                  loading: () => const SizedBox(height: 150),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 16),
                
                // Loyalty Section
                loyaltyInfoAsync.when(
                  data: (loyaltyInfo) {
                    if (loyaltyInfo == null) return const SizedBox.shrink();
                    
                    return appTextsAsync.when(
                      data: (appTexts) {
                        final loyaltyPoints = loyaltyInfo['loyaltyPoints'] as int? ?? 0;
                        final lifetimePoints = loyaltyInfo['lifetimePoints'] as int? ?? 0;
                        final vipTier = loyaltyInfo['vipTier'] as String? ?? 'bronze';
                        
                        return LoyaltySectionWidget(
                          loyaltyPoints: loyaltyPoints,
                          lifetimePoints: lifetimePoints,
                          vipTier: vipTier,
                          texts: appTexts.profile,
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                  loading: () => const SizedBox(height: 150),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 16),
                
                // Rewards Tickets
                activeTicketsAsync.when(
                  data: (activeTickets) {
                    if (activeTickets.isEmpty) return const SizedBox.shrink();
                    
                    return appTextsAsync.when(
                      data: (appTexts) {
                        return RewardsTicketsWidget(
                          activeTickets: activeTickets,
                          profileTexts: appTexts.profile,
                          rewardsTexts: appTexts.rewards,
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    );
                  },
                  loading: () => const SizedBox(height: 150),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 16),
                
                // Account Activity
                appTextsAsync.when(
                  data: (appTexts) => AccountActivityWidget(
                    ordersCount: history.length,
                    favoritesCount: userProfile.favoriteProducts.length,
                    texts: appTexts.profile,
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 32),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Se déconnecter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
