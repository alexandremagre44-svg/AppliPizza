// lib/src/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/application/user_provider.dart';
import '../../../auth/application/auth_provider.dart';
import '../../../loyalty/application/loyalty_provider.dart';
import '../../../orders/data/models/order.dart';
import '../../../loyalty/data/models/loyalty_reward.dart';
import '../../../cart/application/cart_provider.dart';
import 'package:pizza_delizza/src/features/loyalty/data/repositories/loyalty_repository.dart';
import '../../../shared/constants/constants.dart';
import '../../../shared/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProvider);
    final authState = ref.watch(authProvider);
    final history = userProfile.orderHistory;
    final loyaltyInfoAsync = ref.watch(loyaltyInfoProvider);

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

            // Loyalty Information Section
            loyaltyInfoAsync.when(
              data: (loyaltyInfo) {
                if (loyaltyInfo == null) return const SizedBox.shrink();
                return _buildLoyaltySection(context, ref, loyaltyInfo);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            SizedBox(height: AppSpacing.xxl),

            // Statistiques rapides
            // refactor padding → app_theme standard
            Padding(
              padding: AppSpacing.paddingHorizontalLG,
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.shopping_bag,
                      title: 'Commandes',
                      value: history.length.toString(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.favorite,
                      title: 'Favoris',
                      value: userProfile.favoriteProducts.length.toString(),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.xxl),

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

  // refactor stat card → app_theme standard (padding, radius, shadow)
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.cardLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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

  Widget _buildLoyaltySection(BuildContext context, WidgetRef ref, Map<String, dynamic> loyaltyInfo) {
    final loyaltyPoints = loyaltyInfo['loyaltyPoints'] as int;
    final lifetimePoints = loyaltyInfo['lifetimePoints'] as int;
    final vipTier = loyaltyInfo['vipTier'] as String;
    final rewards = loyaltyInfo['rewards'] as List<LoyaltyReward>;
    final availableSpins = loyaltyInfo['availableSpins'] as int;

    // Calculer la progression vers la prochaine pizza
    final progressToFreePizza = (loyaltyPoints % 1000) / 1000.0;
    final pointsNeeded = 1000 - (loyaltyPoints % 1000);

    return Padding(
      padding: AppSpacing.paddingHorizontalLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(Icons.stars, color: Colors.amber, size: 28),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Programme de Fidélité',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // VIP Tier Badge
          _buildVipTierCard(context, vipTier, lifetimePoints),
          SizedBox(height: AppSpacing.lg),

          // Points Card
          Container(
            padding: AppSpacing.paddingXL,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryRed, AppColors.primaryRed.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.cardLarge,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Points Fidélité',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '$loyaltyPoints pts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.stars, color: Colors.white, size: 32),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Progression vers une pizza gratuite',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressToFreePizza,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Plus que $pointsNeeded points',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          // Available Rewards
          if (rewards.where((r) => !r.used).isNotEmpty) ...[
            Text(
              'Récompenses disponibles',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.md),
            _buildRewardsList(context, rewards),
            SizedBox(height: AppSpacing.lg),
          ],

          // Spin the Wheel Button
          if (availableSpins > 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _spinWheel(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.casino, size: 24),
                label: Text(
                  'Tourner la Roue ($availableSpins disponible${availableSpins > 1 ? 's' : ''})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVipTierCard(BuildContext context, String vipTier, int lifetimePoints) {
    Color tierColor;
    String tierLabel;
    IconData tierIcon;

    switch (vipTier) {
      case VipTier.gold:
        tierColor = Colors.amber.shade700;
        tierLabel = 'GOLD';
        tierIcon = Icons.workspace_premium;
        break;
      case VipTier.silver:
        tierColor = Colors.grey.shade400;
        tierLabel = 'SILVER';
        tierIcon = Icons.military_tech;
        break;
      default:
        tierColor = Colors.brown.shade400;
        tierLabel = 'BRONZE';
        tierIcon = Icons.emoji_events;
    }

    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: tierColor.withOpacity(0.1),
        borderRadius: AppRadius.cardLarge,
        border: Border.all(color: tierColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tierColor,
              shape: BoxShape.circle,
            ),
            child: Icon(tierIcon, color: Colors.white, size: 28),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Niveau $tierLabel',
                  style: TextStyle(
                    color: tierColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$lifetimePoints points à vie',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (vipTier == VipTier.silver || vipTier == VipTier.gold)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: tierColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '-${(VipTier.getDiscount(vipTier) * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRewardsList(BuildContext context, List<LoyaltyReward> rewards) {
    final availableRewards = rewards.where((r) => !r.used).toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableRewards.map((reward) {
        IconData icon;
        String label;
        Color color;

        switch (reward.type) {
          case RewardType.freePizza:
            icon = Icons.local_pizza;
            label = 'Pizza Gratuite';
            color = AppColors.primaryRed;
            break;
          case RewardType.freeDrink:
            icon = Icons.local_drink;
            label = 'Boisson Gratuite';
            color = Colors.blue;
            break;
          case RewardType.freeDessert:
            icon = Icons.cake;
            label = 'Dessert Gratuit';
            color = Colors.pink;
            break;
          default:
            icon = Icons.card_giftcard;
            label = 'Récompense';
            color = Colors.grey;
        }

        return Chip(
          avatar: Icon(icon, color: Colors.white, size: 18),
          label: Text(label),
          backgroundColor: color,
          labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
      }).toList(),
    );
  }

  Future<void> _spinWheel(BuildContext context, WidgetRef ref) async {
    final authState = ref.read(authProvider);
    final uid = authState.userId;
    
    if (uid == null) return;

    try {
      // Afficher un dialogue de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'La roue tourne...',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );

      // Attendre un peu pour l'effet
      await Future.delayed(Duration(seconds: 2));

      final result = await LoyaltyRepository().spinRewardWheel(uid);
      
      if (context.mounted) {
        Navigator.pop(context); // Fermer le dialogue de chargement

        // Afficher le résultat
        String message;
        IconData icon;
        Color color;

        if (result['rewardType'] == null) {
          message = 'Dommage ! Essayez encore !';
          icon = Icons.sentiment_dissatisfied;
          color = Colors.grey;
        } else if (result['rewardType'] == RewardType.bonusPoints) {
          message = 'Félicitations ! Vous avez gagné ${result['bonusPoints']} points !';
          icon = Icons.stars;
          color = Colors.amber;
        } else if (result['rewardType'] == RewardType.freeDrink) {
          message = 'Félicitations ! Vous avez gagné une boisson gratuite !';
          icon = Icons.local_drink;
          color = Colors.blue;
        } else if (result['rewardType'] == RewardType.freeDessert) {
          message = 'Félicitations ! Vous avez gagné un dessert gratuit !';
          icon = Icons.cake;
          color = Colors.pink;
        } else {
          message = 'Vous avez gagné une récompense !';
          icon = Icons.card_giftcard;
          color = Colors.green;
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(icon, color: color, size: 32),
                SizedBox(width: 12),
                Expanded(child: Text('Roue de la Chance')),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fermer le dialogue de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}