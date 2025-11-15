// lib/src/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loyalty_provider.dart';
import '../../providers/reward_tickets_provider.dart';
import '../../models/order.dart';
import '../../models/loyalty_reward.dart';
import '../../models/app_texts_config.dart';
import '../../providers/cart_provider.dart';
import '../../services/loyalty_service.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';
import '../../services/roulette_settings_service.dart';
import '../../models/roulette_settings.dart';
import 'widgets/loyalty_section_widget.dart';
import 'widgets/rewards_tickets_widget.dart';
import 'widgets/roulette_card_widget.dart';
import 'widgets/account_activity_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProvider);
    final authState = ref.watch(authProvider);
    final history = userProfile.orderHistory;
    final loyaltyInfoAsync = ref.watch(loyaltyInfoProvider);
    final activeTicketsAsync = ref.watch(activeRewardTicketsProvider);
    final appTextsAsync = ref.watch(appTextsConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              child: Column(
                children: [
                  // Enhanced Avatar
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
                  // Nom et rôle
                  Text(
                    authState.userEmail ?? userProfile.name,
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Badge rôle
                  if (authState.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.admin_panel_settings, size: 16, color: Colors.black87),
                          SizedBox(width: 4),
                          Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (authState.isKitchen)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restaurant, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'CUISINE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: AppSpacing.sm),
                  // Email
                  // refactor text style → app_theme standard
                  Text(
                    authState.userEmail ?? userProfile.email,
                    style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.xxl),

            // ═══════════════════════════════════════════════════════════
            // SECTION 1 — Fidélité (carte compacte)
            // ═══════════════════════════════════════════════════════════
            loyaltyInfoAsync.when(
              data: (loyaltyInfo) {
                if (loyaltyInfo == null) return const SizedBox.shrink();
                
                return appTextsAsync.when(
                  data: (appTexts) {
                    final loyaltyPoints = loyaltyInfo['loyaltyPoints'] as int;
                    final lifetimePoints = loyaltyInfo['lifetimePoints'] as int;
                    final vipTier = loyaltyInfo['vipTier'] as String;
                    
                    return Padding(
                      padding: AppSpacing.paddingHorizontalLG,
                      child: LoyaltySectionWidget(
                        loyaltyPoints: loyaltyPoints,
                        lifetimePoints: lifetimePoints,
                        vipTier: vipTier,
                        texts: appTexts.profileTexts,
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            SizedBox(height: AppSpacing.xxl),

            // ═══════════════════════════════════════════════════════════
            // SECTION 2 — Mes récompenses (tickets)
            // ═══════════════════════════════════════════════════════════
            activeTicketsAsync.when(
              data: (activeTickets) {
                if (activeTickets.isEmpty) return const SizedBox.shrink();
                
                return appTextsAsync.when(
                  data: (appTexts) {
                    return Padding(
                      padding: AppSpacing.paddingHorizontalLG,
                      child: RewardsTicketsWidget(
                        activeTickets: activeTickets,
                        profileTexts: appTexts.profileTexts,
                        rewardsTexts: appTexts.rewardsTexts,
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            SizedBox(height: AppSpacing.xxl),

            // ═══════════════════════════════════════════════════════════
            // SECTION 3 — Roulette de la chance
            // ═══════════════════════════════════════════════════════════
            appTextsAsync.when(
              data: (appTexts) {
                final userId = authState.userId ?? 'guest';
                return Padding(
                  padding: AppSpacing.paddingHorizontalLG,
                  child: RouletteCardWidget(
                    texts: appTexts.rouletteTexts,
                    userId: userId,
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            SizedBox(height: AppSpacing.xxl),

            // ═══════════════════════════════════════════════════════════
            // SECTION 4 — Activité du compte
            // ═══════════════════════════════════════════════════════════
            appTextsAsync.when(
              data: (appTexts) {
                return Padding(
                  padding: AppSpacing.paddingHorizontalLG,
                  child: AccountActivityWidget(
                    ordersCount: history.length,
                    favoritesCount: userProfile.favoriteProducts.length,
                    texts: appTexts.profileTexts,
                    onOrdersTap: () {
                      // Scroll to orders section (already visible below)
                    },
                    onFavoritesTap: () {
                      // Navigate to favorites (could be implemented)
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            SizedBox(height: AppSpacing.xxl),

            // Staff Tablet Access (for all staff)
            Padding(
              padding: AppSpacing.paddingHorizontalLG,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.staffTabletPin),
                  icon: const Icon(Icons.tablet_mac, size: 24),
                  label: const Text(
                    'MODE CAISSE - TABLETTE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.md),

            // Kitchen Mode Access (for kitchen role users)
            if (authState.isKitchen || authState.isAdmin)
              Padding(
                padding: AppSpacing.paddingHorizontalLG,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.kitchen),
                    icon: const Icon(Icons.restaurant_menu, size: 24),
                    label: const Text(
                      'ACCÉDER AU MODE CUISINE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

            if (authState.isKitchen || authState.isAdmin)
              SizedBox(height: AppSpacing.md),

            SizedBox(height: AppSpacing.xxl),

            // Section Historique
            Padding(
              padding: AppSpacing.paddingHorizontalLG,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historique des commandes',
                    style: AppTextStyles.titleLarge,
                  ),
                  if (history.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Future: Voir toutes les commandes
                      },
                      child: const Text('Tout voir'),
                    ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.md),

            _buildOrderHistory(context, history),

            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }



  Widget _buildOrderHistory(BuildContext context, List<Order> history) {
    if (history.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune commande',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Vos commandes apparaîtront ici',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final order = history[index];
        final formattedDate = '${order.date.day.toString().padLeft(2, '0')}/'
            '${order.date.month.toString().padLeft(2, '0')}/'
            '${order.date.year}';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              'Commande #${(history.length - index).toString().padLeft(4, '0')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(formattedDate),
                const SizedBox(height: 4),
                _buildStatusChip(context, order.status),
              ],
            ),
            trailing: Text(
              '${order.total.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            children: [
              const Divider(),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${item.quantity} x ${item.price.toStringAsFixed(2)}€',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.total.toStringAsFixed(2)}€',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'livrée':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'en préparation':
        statusColor = Colors.orange;
        statusIcon = Icons.restaurant;
        break;
      case 'en livraison':
        statusColor = Colors.blue;
        statusIcon = Icons.delivery_dining;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}