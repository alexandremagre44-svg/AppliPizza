// lib/src/kitchen/widgets/kitchen_order_card.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import 'kitchen_colors.dart';
import 'kitchen_status_badge.dart';

/// Carte de commande pour le mode cuisine
/// Affiche les infos essentielles avec zones tactiles gauche/droite pour changer le statut
class KitchenOrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback? onPreviousStatus;
  final VoidCallback? onNextStatus;
  final int minutesSinceCreation;

  const KitchenOrderCard({
    Key? key,
    required this.order,
    required this.onTap,
    this.onPreviousStatus,
    this.onNextStatus,
    required this.minutesSinceCreation,
  }) : super(key: key);

  @override
  State<KitchenOrderCard> createState() => _KitchenOrderCardState();
}

class _KitchenOrderCardState extends State<KitchenOrderCard> {
  Timer? _chronoTimer;
  late ValueNotifier<int> _elapsedMinutes;

  @override
  void initState() {
    super.initState();
    _elapsedMinutes = ValueNotifier<int>(widget.minutesSinceCreation);
    
    // Update elapsed time every 10 seconds
    _chronoTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        final now = DateTime.now();
        final minutes = now.difference(widget.order.date).inMinutes;
        _elapsedMinutes.value = minutes;
      }
    });
  }

  @override
  void dispose() {
    _chronoTimer?.cancel();
    _elapsedMinutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderNumber = order.id.substring(0, 8).toUpperCase();
    final timeFormat = DateFormat('HH:mm');
    final createdTime = timeFormat.format(widget.order.date);
    final statusColor = KitchenColors.getStatusBackgroundColor(widget.order.status);
    
    // Calculate pickup time range
    String? pickupTimeRange;
    if (widget.order.pickupDate != null && widget.order.pickupTimeSlot != null) {
      // Parse the pickup time slot (format: "HH:mm")
      try {
        final parts = widget.order.pickupTimeSlot!.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final startTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        final endTime = '${(hour + 1).toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        pickupTimeRange = '$startTime-$endTime';
      } catch (e) {
        pickupTimeRange = widget.order.pickupTimeSlot;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: KitchenColors.cardShadow,
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Subtle gradient overlay for better text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000), // Transparent
                        Color(0x1A000000), // Black at 10% opacity
                      ],
                    ),
                  ),
                ),
              ),
              
              // Left tap zone for previous status (50% of card width)
              if (widget.onPreviousStatus != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: constraints.maxWidth * 0.5,
                  child: GestureDetector(
                    onTap: () async {
                      // Haptic feedback
                      HapticFeedback.lightImpact();
                      widget.onPreviousStatus!();
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              
              // Right tap zone for next status (50% of card width)
              if (widget.onNextStatus != null)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: constraints.maxWidth * 0.5,
                  child: GestureDetector(
                    onTap: () async {
                      // Haptic feedback
                      HapticFeedback.lightImpact();
                      widget.onNextStatus!();
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              
              // Double-tap detector for opening details
              Positioned.fill(
                child: GestureDetector(
                  onDoubleTap: widget.onTap,
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
          
              // Main content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Order number and status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#$orderNumber',
                          style: const TextStyle(
                            color: KitchenColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        KitchenStatusBadge(
                          status: widget.order.status,
                          animate: !widget.order.isViewed,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Line 2: Creation time + elapsed time badge
                    ValueListenableBuilder<int>(
                      valueListenable: _elapsedMinutes,
                      builder: (context, minutes, child) {
                        final badgeColor = KitchenColors.getElapsedTimeColor(minutes);
                        return Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: KitchenColors.iconPrimary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              createdTime,
                              style: const TextStyle(
                                color: KitchenColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Depuis ${minutes}min',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    // Line 3: Pickup time range
                    if (pickupTimeRange != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: KitchenColors.iconPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Retrait: $pickupTimeRange',
                            style: const TextStyle(
                              color: KitchenColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    
                    // Items block (max 4 lines visible)
                    Expanded(
                      child: _buildItemsList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemsList() {
    final maxVisibleItems = 4;
    final itemsToShow = widget.order.items.take(maxVisibleItems).toList();
    final remainingCount = widget.order.items.length - maxVisibleItems;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in itemsToShow) ...[
            _buildItemRow(item),
            const SizedBox(height: 6),
          ],
          if (remainingCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+$remainingCount élément${remainingCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: KitchenColors.textSecondary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemRow(item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.quantity}x',
              style: const TextStyle(
                color: KitchenColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.productName,
                style: const TextStyle(
                  color: KitchenColors.textPrimary,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (item.customDescription != null && item.customDescription!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              item.customDescription!,
              style: const TextStyle(
                color: KitchenColors.textSecondary,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
  
  Order get order => widget.order;
}
