// lib/src/screens/client/rewards/rewards_screen.dart
// Page Récompenses - Affichage des tickets de récompenses
// NOUVEAU DESIGN - Basé sur RewardTicket system

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/app_theme.dart';
import '../../../core/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/app_texts_provider.dart';
import '../../../services/reward_service.dart';
import '../../../services/roulette_rules_service.dart';
import '../../../models/reward_ticket.dart';
import '../../../models/reward_action.dart';
import 'reward_product_selector_screen.dart';
import '../../../providers/cart_provider.dart';

/// Page Récompenses
/// Affiche les tickets actifs, l'historique et un lien vers la roulette
class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  final RewardService _rewardService = RewardService();
  final RouletteRulesService _rulesService = RouletteRulesService();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId ?? 'guest';
    final appTextsAsync = ref.watch(appTextsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Récompenses'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: appTextsAsync.when(
        data: (appTexts) {
          final rewardsTexts = appTexts.rewards;
          
          return StreamBuilder<List<RewardTicket>>(
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
                    SizedBox(height: AppSpacing.md),
                    
                    // SECTION 1: TICKETS ACTIFS
                    if (activeTickets.isNotEmpty) ...[
                      Text(
                        rewardsTexts.activeSectionTitle,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      ...activeTickets.map((ticket) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildActiveTicketCard(context, ticket, rewardsTexts),
                      )),
                      SizedBox(height: AppSpacing.xxl),
                    ],
                    
                    // SECTION 2: "GAGNER PLUS DE RÉCOMPENSES"
                    _buildEarnMoreSection(context, userId),
                    
                    SizedBox(height: AppSpacing.xxl),
                    
                    // SECTION 3: HISTORIQUE
                    if (historyTickets.isNotEmpty) ...[
                      Text(
                        rewardsTexts.historySectionTitle,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      ...historyTickets.map((ticket) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _buildHistoryTicketCard(context, ticket, rewardsTexts),
                      )),
                    ],
                    
                    // Empty state when no tickets
                    if (activeTickets.isEmpty && historyTickets.isEmpty) ...[
                      SizedBox(height: AppSpacing.xl),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              size: 80,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(height: AppSpacing.lg),
                            Text(
                              rewardsTexts.noRewards,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur de chargement: $error'),
        ),
      ),
    );
  }

  /// Build "Gagner plus de récompenses" section
  Widget _buildEarnMoreSection(BuildContext context, String userId) {
    return FutureBuilder<RouletteStatus>(
      future: _rulesService.checkEligibility(userId),
      builder: (context, snapshot) {
        return Container(
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.casino,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Gagnez plus de récompenses',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Tentez votre chance quotidienne sur la roue pour gagner des récompenses !',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    context.push(AppRoutes.roulette);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.button,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.casino, size: 20),
                      SizedBox(width: AppSpacing.xs),
                      const Text('Tourner la roue'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build a card for an active ticket
  Widget _buildActiveTicketCard(
    BuildContext context,
    RewardTicket ticket,
    dynamic rewardsTexts,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final expiryText = rewardsTexts.expireAt.replaceAll(
      '{date}',
      dateFormat.format(ticket.expiresAt),
    );
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: AppSpacing.paddingMD,
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
                    color: AppColors.primaryContainer,
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
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (ticket.action.description != null)
                        Text(
                          ticket.action.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.sm),
            
            // Expiration date
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  expiryText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.md),
            
            // Use button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _useTicket(context, ticket),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.button,
                  ),
                ),
                child: Text(rewardsTexts.ctaUse),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a card for a history ticket (expired or used)
  Widget _buildHistoryTicketCard(
    BuildContext context,
    RewardTicket ticket,
    dynamic rewardsTexts,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      elevation: 0,
      color: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
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
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    ticket.isUsed 
                        ? '${rewardsTexts.used} - ${dateFormat.format(ticket.usedAt!)}'
                        : '${rewardsTexts.expired} - ${dateFormat.format(ticket.expiresAt)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: ticket.isUsed 
                    ? AppColors.successContainer
                    : AppColors.surfaceContainerHighest,
                borderRadius: AppRadius.badge,
              ),
              child: Text(
                ticket.isUsed ? rewardsTexts.used : rewardsTexts.expired,
                style: AppTextStyles.labelSmall.copyWith(
                  color: ticket.isUsed 
                      ? AppColors.success 
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.bold,
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
              _showSuccessSnackbar(context, 'Réduction appliquée au panier !');
            }
          }
          break;
          
        case RewardType.fixedDiscount:
          // Apply fixed discount to cart
          if (ticket.action.amount != null) {
            cartNotifier.applyFixedAmountDiscount(ticket.action.amount!);
            await _rewardService.markTicketUsed(ticket.userId, ticket.id);
            if (context.mounted) {
              _showSuccessSnackbar(context, 'Réduction appliquée au panier !');
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
            _showErrorSnackbar(context, 'Type de récompense non pris en charge');
          }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackbar(context, 'Erreur lors de l\'utilisation de la récompense');
      }
    }
  }

  /// Show success snackbar
  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Get icon for reward type
  IconData _getIconForRewardType(RewardType type) {
    switch (type) {
      case RewardType.percentageDiscount:
        return Icons.percent;
      case RewardType.fixedDiscount:
        return Icons.euro;
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
}
