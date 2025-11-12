// lib/src/kitchen/widgets/kitchen_order_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../kitchen_constants.dart';
import 'kitchen_status_badge.dart';

/// Carte de commande pour le mode cuisine
/// Affiche les infos essentielles avec zones tactiles gauche/droite pour changer le statut
class KitchenOrderCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final orderNumber = order.id.substring(0, 8).toUpperCase();
    final timeFormat = DateFormat('HH:mm');
    final createdTime = timeFormat.format(order.date);
    
    // Calculate ETA if pickup time is available
    String? pickupTime;
    if (order.pickupDate != null && order.pickupTimeSlot != null) {
      pickupTime = '${order.pickupDate} ${order.pickupTimeSlot}';
    }

    return Container(
      decoration: BoxDecoration(
        color: KitchenConstants.kitchenSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KitchenConstants.getStatusColor(order.status).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: KitchenConstants.getStatusColor(order.status).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Left zone for previous status
              if (onPreviousStatus != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: GestureDetector(
                    onTap: onPreviousStatus,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white24,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Right zone for next status
              if (onNextStatus != null)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: GestureDetector(
                    onTap: onNextStatus,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white24,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              
              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Order number and status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#$orderNumber',
                          style: const TextStyle(
                            color: KitchenConstants.kitchenText,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        KitchenStatusBadge(
                          status: order.status,
                          animate: !order.isViewed,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Time info
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: KitchenConstants.kitchenTextSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          createdTime,
                          style: const TextStyle(
                            color: KitchenConstants.kitchenTextSecondary,
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
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Depuis ${minutesSinceCreation}min',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    if (pickupTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: KitchenConstants.kitchenTextSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Retrait: $pickupTime',
                            style: const TextStyle(
                              color: KitchenConstants.kitchenTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    
                    // Items preview
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final item in order.items) ...[
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${item.quantity}x',
                                      style: const TextStyle(
                                        color: KitchenConstants.kitchenText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: const TextStyle(
                                        color: KitchenConstants.kitchenText,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (item.customDescription != null) ...[
                                Padding(
                                  padding: const EdgeInsets.only(left: 44, top: 2),
                                  child: Text(
                                    item.customDescription!,
                                    style: const TextStyle(
                                      color: KitchenConstants.kitchenTextSecondary,
                                      fontSize: 11,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    // New order indicator
                    if (!order.isViewed)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fiber_new,
                              color: Colors.blue,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'NOUVELLE',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
