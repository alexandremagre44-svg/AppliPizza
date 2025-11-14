// lib/src/kitchen/widgets/kitchen_order_detail.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../features/orders/data/models/order.dart';
import '../kitchen_constants.dart';
import '../services/kitchen_print_stub.dart';
import 'kitchen_status_badge.dart';

/// Modal plein écran pour afficher les détails complets d'une commande
class KitchenOrderDetail extends StatelessWidget {
  final Order order;
  final VoidCallback? onPreviousStatus;
  final VoidCallback? onNextStatus;
  final int minutesSinceCreation;

  const KitchenOrderDetail({
    Key? key,
    required this.order,
    this.onPreviousStatus,
    this.onNextStatus,
    required this.minutesSinceCreation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderNumber = order.id.substring(0, 8).toUpperCase();
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final createdTime = timeFormat.format(order.date);
    final createdDate = dateFormat.format(order.date);
    
    String? pickupInfo;
    if (order.pickupDate != null && order.pickupTimeSlot != null) {
      pickupInfo = '${order.pickupDate} à ${order.pickupTimeSlot}';
    }

    return Scaffold(
      backgroundColor: KitchenConstants.kitchenBackground,
      appBar: AppBar(
        backgroundColor: KitchenConstants.kitchenBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: KitchenConstants.kitchenText,
            size: 32,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Commande #$orderNumber',
          style: const TextStyle(
            color: KitchenConstants.kitchenText,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content (scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Center(
                      child: KitchenStatusBadge(
                        status: order.status,
                        animate: !order.isViewed,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Time info card
                    _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Informations Temporelles',
                      children: [
                        _buildInfoRow('Créée le', '$createdDate à $createdTime'),
                        _buildInfoRow('Depuis', '$minutesSinceCreation minutes'),
                        if (pickupInfo != null)
                          _buildInfoRow('Retrait prévu', pickupInfo, highlight: true),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Customer info card
                    if (order.customerName != null || order.customerPhone != null)
                      _buildInfoCard(
                        icon: Icons.person,
                        title: 'Informations Client',
                        children: [
                          if (order.customerName != null)
                            _buildInfoRow('Nom', order.customerName!),
                          if (order.customerPhone != null)
                            _buildInfoRow('Téléphone', order.customerPhone!),
                        ],
                      ),
                    
                    if (order.customerName != null || order.customerPhone != null)
                      const SizedBox(height: 16),
                    
                    // Items card
                    _buildInfoCard(
                      icon: Icons.restaurant,
                      title: 'Détails de la Commande',
                      children: [
                        for (final item in order.items) ...[
                          _buildItemDetail(item),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Comment card
                    if (order.comment != null && order.comment!.isNotEmpty)
                      _buildInfoCard(
                        icon: Icons.comment,
                        title: 'Commentaire Client',
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.yellow.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              order.comment!,
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    
                    if (order.comment != null && order.comment!.isNotEmpty)
                      const SizedBox(height: 16),
                    
                    // Total card
                    _buildInfoCard(
                      icon: Icons.euro,
                      title: 'Total',
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL',
                              style: TextStyle(
                                color: KitchenConstants.kitchenText,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${order.total.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: KitchenConstants.kitchenSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Status change buttons
                  Row(
                    children: [
                      if (onPreviousStatus != null)
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.arrow_back,
                            label: 'État Précédent',
                            color: Colors.orange,
                            onPressed: onPreviousStatus!,
                          ),
                        ),
                      if (onPreviousStatus != null && onNextStatus != null)
                        const SizedBox(width: 12),
                      if (onNextStatus != null)
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.arrow_forward,
                            label: 'État Suivant',
                            color: Colors.green,
                            onPressed: onNextStatus!,
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Print button
                  SizedBox(
                    width: double.infinity,
                    child: _buildActionButton(
                      icon: Icons.print,
                      label: 'Imprimer Ticket Cuisine',
                      color: Colors.blue,
                      onPressed: () async {
                        await KitchenPrintService().printKitchenTicket(order);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ticket envoyé à l\'imprimante'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KitchenConstants.kitchenSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: KitchenConstants.kitchenText,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: KitchenConstants.kitchenText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: KitchenConstants.kitchenTextSecondary,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight ? Colors.orange : KitchenConstants.kitchenText,
              fontSize: 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetail(item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity}x',
                        style: const TextStyle(
                          color: KitchenConstants.kitchenText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          color: KitchenConstants.kitchenText,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item.total.toStringAsFixed(2)} €',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (item.customDescription != null && item.customDescription!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildCustomizationDetails(item.customDescription!),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomizationDetails(String customDescription) {
    // Parse the custom description to extract and color-code parts
    final parts = customDescription.split(' • ');
    final List<Widget> widgets = [];
    
    for (final part in parts) {
      if (part.startsWith('Sans:')) {
        // Removed ingredients - show in red
        final ingredients = part.substring(5).trim();
        widgets.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.remove_circle, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    ingredients,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (part.startsWith('Avec:')) {
        // Added ingredients - show in green
        final ingredients = part.substring(5).trim();
        widgets.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    ingredients,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (part.startsWith('Taille:')) {
        // Size - show normally
        widgets.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              part,
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 14,
              ),
            ),
          ),
        );
      } else if (part.startsWith('Note:')) {
        // Note - show in yellow
        widgets.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.yellow.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.note, color: Colors.yellow, size: 16),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    part.substring(5).trim(),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else if (part.isNotEmpty) {
        // Other parts - show normally
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              part,
              style: const TextStyle(
                color: KitchenConstants.kitchenTextSecondary,
                fontSize: 14,
              ),
            ),
          ),
        );
      }
    }
    
    if (widgets.isEmpty) {
      // Fallback if no recognized format
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          customDescription,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 14,
          ),
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: widgets,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
