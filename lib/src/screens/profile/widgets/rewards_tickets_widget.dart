// lib/src/screens/profile/widgets/rewards_tickets_widget.dart
// Display active reward tickets in profile screen (Material 3)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design_system/app_theme.dart';
import '../../../core/constants.dart';
import '../../../models/reward_ticket.dart';
import '../../../models/app_texts_config.dart';

/// Display 2-3 active reward tickets with CTA to view all
class RewardsTicketsWidget extends StatelessWidget {
  final List<RewardTicket> activeTickets;
  final ProfileTexts profileTexts;
  final RewardsTexts rewardsTexts;

  const RewardsTicketsWidget({
    super.key,
    required this.activeTickets,
    required this.profileTexts,
    required this.rewardsTexts,
  });

  @override
  Widget build(BuildContext context) {
    // Show max 3 tickets
    final displayTickets = activeTickets.take(3).toList();
    
    if (displayTickets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  profileTexts.rewardsTitle,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (activeTickets.length > 3)
              TextButton.icon(
                onPressed: () {
                  context.push(AppRoutes.rewards);
                },
                icon: Icon(Icons.arrow_forward, size: 16),
                label: Text(profileTexts.rewardsCtaViewAll),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
              ),
          ],
        ),
        
        SizedBox(height: AppSpacing.md),
        
        // Tickets list
        ...displayTickets.map((ticket) => _buildTicketCard(context, ticket)),
        
        // View all button if more than 3
        if (activeTickets.length > 3) ...[
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.push(AppRoutes.rewards);
              },
              child: Text(profileTexts.rewardsCtaViewAll),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTicketCard(BuildContext context, RewardTicket ticket) {
    final iconData = _getIconForTicket(ticket);
    final formattedDate = DateFormat('dd/MM/yyyy').format(ticket.expiresAt);
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.cardSmall,
              ),
              child: Icon(
                iconData,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            
            SizedBox(width: AppSpacing.md),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.action.label ?? ticket.action.description ?? 'Récompense',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  if (ticket.action.description != null && 
                      ticket.action.label != ticket.action.description)
                    Text(
                      ticket.action.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: AppSpacing.xxs),
                      Text(
                        rewardsTexts.expireAt.replaceAll('{date}', formattedDate),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: AppRadius.badge,
              ),
              child: Text(
                rewardsTexts.active,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTicket(RewardTicket ticket) {
    final type = ticket.action.type.value;
    
    switch (type) {
      case 'free_product':
      case 'free_any_pizza':
      case 'free_category':
        return Icons.local_pizza;
      case 'free_drink':
        return Icons.local_drink;
      case 'percentage_discount':
        return Icons.percent;
      case 'fixed_discount':
        return Icons.euro;
      default:
        return Icons.card_giftcard;
    }
  }
}
