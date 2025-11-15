// lib/src/screens/client/rewards/rewards_screen.dart
// Page Récompenses avec affichage des tickets et navigation vers la Roulette

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../core/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/reward_service.dart';
import '../../../models/reward_ticket.dart';
import '../../../models/reward_action.dart';
import 'reward_product_selector_screen.dart';
import '../../../providers/cart_provider.dart';

/// Page Récompenses
/// Affiche la liste des tickets de récompenses (actifs, expirés, utilisés)
/// et permet d'accéder à la roue
class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  final RewardService _rewardService = RewardService();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId ?? 'guest';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Récompenses'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<RewardTicket>>(
        stream: _rewardService.watchUserTickets(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allTickets = snapshot.data ?? [];
          final activeTickets = allTickets.where((t) => t.isActive).toList();
          final historyTickets = allTickets.where((t) => !t.isActive).toList();

          return SingleChildScrollView(
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.xl),
                
                // Hero section with icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                SizedBox(height: AppSpacing.xxl),
            
                // Title
                Text(
                  'Vos récompenses',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppSpacing.md),
                
                // Description
                Text(
                  'Utilisez vos récompenses ou tournez la roue pour en gagner plus !',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppSpacing.xxxl),
                
                // Main CTA Button - Roulette
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.roulette);
                    },
                    icon: const Icon(Icons.casino, size: 28),
                    label: Text(
                      'Tourner la roue',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: AppSpacing.xxxl),
                
                // Section 1: Active tickets
                if (activeTickets.isNotEmpty) ...[
                  Text(
                    'Récompenses disponibles',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ...activeTickets.map((ticket) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.lg),
                    child: _buildActiveTicketCard(context, ticket),
                  )),
                  SizedBox(height: AppSpacing.xxxl),
                ],
                
                // Section 2: History (expired/used tickets)
                if (historyTickets.isNotEmpty) ...[
                  Text(
                    'Historique des récompenses',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  ...historyTickets.map((ticket) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _buildHistoryTicketCard(context, ticket),
                  )),
                  SizedBox(height: AppSpacing.xxxl),
                ],
                
                // Empty state when no tickets
                if (activeTickets.isEmpty && historyTickets.isEmpty) ...[
            
                  // Info cards
                  _buildInfoCard(
                    context,
                    icon: Icons.stars,
                    title: 'Récompenses variées',
                    description: 'Gagnez des pizzas, boissons, desserts ou réductions',
                    color: Colors.amber,
                  ),
                  
                  SizedBox(height: AppSpacing.lg),
                  
                  _buildInfoCard(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Une chance par jour',
                    description: 'Revenez chaque jour pour tenter votre chance',
                    color: Colors.blue,
                  ),
                  
                  SizedBox(height: AppSpacing.lg),
                  
                  _buildInfoCard(
                    context,
                    icon: Icons.local_offer,
                    title: 'Tickets avec validité',
                    description: 'Vos récompenses sont valables plusieurs jours',
                    color: Colors.green,
                  ),
                ],
                
                SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build a card for an active ticket
  Widget _buildActiveTicketCard(BuildContext context, RewardTicket ticket) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and label
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.cardSmall,
                  ),
                  child: Icon(
                    _getIconForRewardType(ticket.action.type),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.action.label ?? 'Récompense',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (ticket.action.description != null)
                        Text(
                          ticket.action.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.md),
            
            // Source badge
            if (ticket.action.source != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.2),
                  borderRadius: AppRadius.badge,
                ),
                child: Text(
                  _getSourceLabel(ticket.action.source!),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            SizedBox(height: AppSpacing.md),
            
            // Expiration date
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Valable jusqu\'au ${dateFormat.format(ticket.expiresAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.lg),
            
            // Use button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _useTicket(context, ticket),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                child: const Text('Utiliser maintenant'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a card for a history ticket (expired or used)
  Widget _buildHistoryTicketCard(BuildContext context, RewardTicket ticket) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.1),
                borderRadius: AppRadius.cardSmall,
              ),
              child: Icon(
                _getIconForRewardType(ticket.action.type),
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.action.label ?? 'Récompense',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    ticket.isUsed 
                        ? 'Utilisé le ${dateFormat.format(ticket.usedAt!)}'
                        : 'Expiré le ${dateFormat.format(ticket.expiresAt)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: ticket.isUsed 
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.textTertiary.withOpacity(0.1),
                borderRadius: AppRadius.badge,
              ),
              child: Text(
                ticket.isUsed ? 'Utilisé' : 'Expiré',
                style: AppTextStyles.labelSmall.copyWith(
                  color: ticket.isUsed 
                      ? AppColors.success 
                      : AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle ticket usage
  Future<void> _useTicket(BuildContext context, RewardTicket ticket) async {
    final cartNotifier = ref.read(cartProvider.notifier);
    
    try {
      switch (ticket.action.type) {
        case RewardType.percentageDiscount:
          // Apply percentage discount to cart
          if (ticket.action.percentage != null) {
            cartNotifier.applyPercentageDiscount(ticket.action.percentage!);
            await _rewardService.markTicketUsed(ticket.userId, ticket.id);
            if (context.mounted) {
              _showSuccessDialog(context, 'Réduction appliquée au panier !');
            }
          }
          break;
          
        case RewardType.fixedDiscount:
          // Apply fixed discount to cart
          if (ticket.action.amount != null) {
            cartNotifier.applyFixedAmountDiscount(ticket.action.amount!);
            await _rewardService.markTicketUsed(ticket.userId, ticket.id);
            if (context.mounted) {
              _showSuccessDialog(context, 'Réduction appliquée au panier !');
            }
          }
          break;
          
        case RewardType.freeProduct:
        case RewardType.freeCategory:
        case RewardType.freeAnyPizza:
        case RewardType.freeDrink:
          // Navigate to product selector
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RewardProductSelectorScreen(ticket: ticket),
              ),
            );
          }
          break;
          
        default:
          if (context.mounted) {
            _showErrorDialog(context, 'Type de récompense non pris en charge');
          }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Erreur lors de l\'utilisation de la récompense');
      }
    }
  }

  /// Show success dialog
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès !'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get icon for reward type
  IconData _getIconForRewardType(RewardType type) {
    switch (type) {
      case RewardType.percentageDiscount:
      case RewardType.fixedDiscount:
        return Icons.discount;
      case RewardType.freeProduct:
      case RewardType.freeAnyPizza:
        return Icons.local_pizza;
      case RewardType.freeDrink:
        return Icons.local_drink;
      case RewardType.freeCategory:
        return Icons.category;
      default:
        return Icons.card_giftcard;
    }
  }

  /// Get source label
  String _getSourceLabel(String source) {
    switch (source) {
      case 'roulette':
        return '🎰 Roulette';
      case 'loyalty':
        return '⭐ Fidélité';
      case 'promo':
        return '🎉 Promotion';
      default:
        return source;
    }
  }
  
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.cardSmall,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
