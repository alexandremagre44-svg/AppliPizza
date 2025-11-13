// lib/src/widgets/order_detail_panel.dart
// Panneau de détail d'une commande avec slide animation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';
import '../services/firebase_order_service.dart';
import '../providers/order_provider.dart';
import 'order_status_badge.dart';

class OrderDetailPanel extends ConsumerStatefulWidget {
  final Order order;
  final VoidCallback onClose;
  
  const OrderDetailPanel({
    super.key,
    required this.order,
    required this.onClose,
  });
  
  @override
  ConsumerState<OrderDetailPanel> createState() => _OrderDetailPanelState();
}

class _OrderDetailPanelState extends ConsumerState<OrderDetailPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
    
    // Marquer comme vue
    ref.read(firebaseOrderServiceProvider).markOrderAsViewed(widget.order.id);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _close() async {
    await _controller.reverse();
    widget.onClose();
  }
  
  Future<void> _changeStatus(String newStatus) async {
    await ref.read(firebaseOrderServiceProvider).updateOrderStatus(
      widget.order.id,
      newStatus,
      note: 'Statut changé par admin',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut changé: $newStatus'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }
  
  Future<void> _showCancelDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette commande ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _changeStatus(OrderStatus.cancelled);
    }
  }
  
  void _printOrder() {
    // Stub pour impression future
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonction d\'impression à venir...'),
        backgroundColor: AppColors.infoBlue,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          boxShadow: AppShadows.deep,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                boxShadow: AppShadows.soft,
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _close,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Commande #${widget.order.id.substring(0, 8)}',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            dateFormat.format(widget.order.date),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.print, color: Colors.white),
                      onPressed: _printOrder,
                      tooltip: 'Imprimer',
                    ),
                  ],
                ),
              ),
            ),
            
            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingLG,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Statut actuel
                    _buildSection(
                      title: 'Statut',
                      child: OrderStatusBadge(status: widget.order.status),
                    ),
                    
                    // Informations client
                    if (widget.order.customerName != null) ...[
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Client',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildInfoRow(
                              Icons.person,
                              widget.order.customerName!,
                            ),
                            if (widget.order.customerPhone != null)
                              _buildInfoRow(
                                Icons.phone,
                                widget.order.customerPhone!,
                              ),
                            if (widget.order.customerEmail != null)
                              _buildInfoRow(
                                Icons.email,
                                widget.order.customerEmail!,
                              ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Détails retrait
                    if (widget.order.pickupDate != null) ...[
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Retrait prévu',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today,
                              widget.order.pickupDate!,
                            ),
                            if (widget.order.pickupTimeSlot != null)
                              _buildInfoRow(
                                Icons.access_time,
                                widget.order.pickupTimeSlot!,
                              ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Produits
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Produits',
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: widget.order.items.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: AppSpacing.paddingMD,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: AppRadius.card,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceWhite,
                                    borderRadius: AppRadius.radiusSM,
                                    image: item.imageUrl.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(item.imageUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: item.imageUrl.isEmpty
                                      ? const Icon(Icons.local_pizza)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${item.quantity}x ${item.productName}',
                                        style: AppTextStyles.titleSmall,
                                      ),
                                      if (item.customDescription != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          item.customDescription!,
                                          style: AppTextStyles.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Text(
                                  '${item.total.toStringAsFixed(2)} €',
                                  style: AppTextStyles.price,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Commentaire
                    if (widget.order.comment != null &&
                        widget.order.comment!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Commentaire',
                        child: Container(
                          padding: AppSpacing.paddingMD,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: AppRadius.card,
                          ),
                          child: Text(
                            widget.order.comment!,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                    
                    // Total
                    const SizedBox(height: 24),
                    Container(
                      padding: AppSpacing.paddingLG,
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.1),
                        borderRadius: AppRadius.card,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTextStyles.titleLarge,
                          ),
                          Text(
                            '${widget.order.total.toStringAsFixed(2)} €',
                            style: AppTextStyles.priceLarge,
                          ),
                        ],
                      ),
                    ),
                    
                    // Historique des statuts
                    if (widget.order.statusHistory != null &&
                        widget.order.statusHistory!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildSection(
                        title: 'Historique',
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.order.statusHistory!.map((history) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: AppSpacing.paddingSM,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: AppRadius.radiusSM,
                              ),
                              child: Row(
                                children: [
                                  OrderStatusBadge(
                                    status: history.status,
                                    compact: true,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      DateFormat('dd/MM HH:mm').format(history.timestamp),
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.order.status != OrderStatus.cancelled) ...[
                      Row(
                        children: [
                          if (widget.order.status == OrderStatus.pending)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _changeStatus(OrderStatus.preparing),
                                icon: const Text('🧑‍🍳'),
                                label: const Text('Préparer'),
                              ),
                            ),
                          if (widget.order.status == OrderStatus.preparing) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _changeStatus(OrderStatus.ready),
                                icon: const Text('✅'),
                                label: const Text('Prête'),
                              ),
                            ),
                          ],
                          if (widget.order.status == OrderStatus.ready) ...[
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _changeStatus(OrderStatus.delivered),
                                icon: const Text('📦'),
                                label: const Text('Livrée'),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (widget.order.status != OrderStatus.cancelled &&
                        widget.order.status != OrderStatus.delivered)
                      OutlinedButton.icon(
                        onPressed: _showCancelDialog,
                        icon: const Icon(Icons.cancel, color: AppColors.errorRed),
                        label: const Text(
                          'Annuler la commande',
                          style: TextStyle(color: AppColors.errorRed),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.errorRed),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primaryRed,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
  
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMedium),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
