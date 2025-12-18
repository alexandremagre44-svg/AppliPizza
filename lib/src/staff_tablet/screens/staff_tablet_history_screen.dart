// MIGRATED to WL V2 Theme - Uses theme colors
// lib/src/staff_tablet/screens/staff_tablet_history_screen.dart

import 'package:flutter/material.dart';
import '../../src/design_system/colors.dart';
import '../../white_label/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../../white_label/theme/theme_extensions.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../providers/staff_tablet_orders_provider.dart';

class StaffTabletHistoryScreen extends ConsumerWidget {
  const StaffTabletHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PROTECTION: Vérifier que l'utilisateur est admin
    final authState = ref.watch(authProvider);
    if (!authState.isAdmin) {
      return _buildUnauthorizedScreen(context);
    }
    
    final todayOrders = ref.watch(staffTabletTodayOrdersProvider);
    final todayRevenue = ref.watch(staffTabletTodayRevenueProvider);
    final orderCount = ref.watch(staffTabletTodayOrdersCountProvider);

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceVariant ,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primarySwatch[600]!, AppColors.primaryDark!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: context.onPrimary, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.onPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: context.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Historique du jour',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.onPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Statistics card with improved design
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.onPrimary, context.textSecondary,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.colorScheme.shadow.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.shopping_bag_rounded,
                    label: 'Commandes',
                    value: orderCount.toString(),
                    color: context.primaryColor[700]!,
                    gradient: LinearGradient(
                      colors: [context.primaryColor[50]!, context.primaryColor[100]!],
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        context.textSecondary,
                        context.textSecondary,
                        context.textSecondary,
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.euro_rounded,
                    label: 'Chiffre d\'affaires',
                    value: '${todayRevenue.toStringAsFixed(2)} €',
                    color: AppColors.success[700]!,
                    gradient: LinearGradient(
                      colors: [AppColors.success[50]!, AppColors.success[100]!],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Orders list
          Expanded(
            child: todayOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: context.colorScheme.surfaceVariant ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune commande aujourd\'hui',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.surfaceVariant ,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: todayOrders.length,
                    itemBuilder: (context, index) {
                      final order = todayOrders[index];
                      return _OrderCard(order: order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 36, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.colorScheme.surfaceVariant ,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget d'écran non autorisé pour les non-admins
  Widget _buildUnauthorizedScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.error[900]!,
              AppColors.error[700]!,
            ],
          ),
        ),
        child: Center(
          child: Card(
            margin: EdgeInsets.all(AppSpacing.xl),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 80,
                    color: AppColors.error,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Accès non autorisé',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Le module CAISSE est réservé aux administrateurs uniquement.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: () => context.go('/menu'),
                    icon: const Icon(Icons.home),
                    label: const Text('Retour à l\'accueil'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color _getStatusColor(String status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.primary!;
      case OrderStatus.preparing:
        return context.primaryColor[700]!;
      case OrderStatus.baking:
        return Colors.purple[700]!;
      case OrderStatus.ready:
        return AppColors.success[700]!;
      case OrderStatus.delivered:
        return context.textSecondary;
      case OrderStatus.cancelled:
        return AppColors.error[700]!;
      default:
        return context.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showOrderDetails(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.onPrimary, context.textSecondary,
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time with enhanced styling
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [context.primaryColor[50]!, context.primaryColor[100]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.primaryColor[200]!, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: 20, color: context.primaryColor[800]),
                        const SizedBox(width: 8),
                        Text(
                          timeFormat.format(order.date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: context.primaryColor[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge with improved design
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(order.status),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor(order.status).withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _getStatusLabel(order.status),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Customer name if available
              if (order.customerName != null && order.customerName!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.purple[200]!, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_rounded, size: 20, color: Colors.purple[700]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          order.customerName!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.purple[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Items and payment summary in a row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primarySwatch[200]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shopping_bag_rounded,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDarker,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (order.paymentMethod != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.success[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.success[200]!, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.payment_rounded,
                                size: 18, color: AppColors.success[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getPaymentMethodLabel(order.paymentMethod!),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              // Divider
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primarySwatch[200]!, Colors.transparent],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Total with enhanced design
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLighter!, AppColors.primarySwatch[200]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primarySwatch[400]!, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate_rounded,
                            color: AppColors.primaryDarker, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: context.colorScheme.surfaceVariant ,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${order.total.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDarker,
                        letterSpacing: -0.5,
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

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cash':
        return 'Espèces';
      case 'card':
        return 'Carte bancaire';
      case 'other':
        return 'Autre';
      default:
        return method;
    }
  }

  void _showOrderDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la commande'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order info
              _buildDetailRow('Heure', DateFormat('HH:mm').format(order.date)),
              if (order.customerName != null && order.customerName!.isNotEmpty)
                _buildDetailRow('Client', order.customerName!),
              _buildDetailRow('Statut', _getStatusLabel(order.status)),
              if (order.paymentMethod != null)
                _buildDetailRow('Paiement', _getPaymentMethodLabel(order.paymentMethod!)),
              const Divider(height: 24),
              
              // Items
              const Text(
                'Articles:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item.quantity}x ${item.productName}'),
                    ),
                    Text(
                      '${item.total.toStringAsFixed(2)} €',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),
              const Divider(height: 24),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${order.total.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
