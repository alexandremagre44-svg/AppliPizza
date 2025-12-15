// lib/src/screens/admin/pos/widgets/pos_actions_panel_v2.dart
/// 
/// Complete POS Actions Panel with all functionality
/// ShopCaisse Theme (#5557F6)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../design/pos_theme.dart';
import '../design/pos_components.dart';
import '../../../../models/order_type.dart';
import '../../../../models/payment_method.dart';
import '../../../../models/pos_order_status.dart';
import '../providers/pos_cart_provider.dart';
import '../providers/pos_session_provider.dart';
import '../providers/pos_state_provider.dart';
import '../providers/pos_order_provider.dart';
import 'pos_cash_payment_modal.dart';
import 'pos_session_open_modal.dart';
import 'pos_session_close_modal.dart';
import '../../../../../white_label/runtime/module_gate_provider.dart';

const _uuid = Uuid();

/// Complete POS Actions Panel
class PosActionsPanelV2 extends ConsumerWidget {
  const PosActionsPanelV2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(posCartProvider);
    final posState = ref.watch(posStateProvider);
    final sessionAsync = ref.watch(activeCashierSessionProvider);
    final hasItems = cart.items.isNotEmpty;

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return _buildNoSessionView(context, ref);
        }
        return _buildActiveSessionView(context, ref, session, hasItems, posState);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Erreur: $error', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildNoSessionView(BuildContext context, WidgetRef ref) {
    return PosEmptyState(
      icon: Icons.store_mall_directory_outlined,
      title: 'Aucune session active',
      subtitle: 'Ouvrez une session pour commencer',
      action: PosButton(
        label: 'Ouvrir la caisse',
        icon: Icons.play_arrow,
        variant: PosButtonVariant.success,
        size: PosButtonSize.large,
        onPressed: () => _openSession(context, ref),
      ),
    );
  }

  Widget _buildActiveSessionView(
    BuildContext context,
    WidgetRef ref,
    dynamic session,
    bool hasItems,
    dynamic posState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Session indicator
          _buildSessionIndicator(session),
          const SizedBox(height: 24),

          // Order type selector
          _buildOrderTypeSelector(context, ref, posState),
          const SizedBox(height: 16),

          // Customer name input (optional)
          _buildCustomerNameInput(ref, posState),
          const SizedBox(height: 24),

          // Checkout button
          _buildCheckoutButton(context, ref, hasItems, session),
          const SizedBox(height: 16),

          // Clear cart button
          _buildClearCartButton(context, ref, hasItems),
          const SizedBox(height: 24),

          const Divider(),
          const SizedBox(height: 16),

          // Close session button
          _buildCloseSessionButton(context, ref, session, hasItems),
        ],
      ),
    );
  }

  Widget _buildSessionIndicator(dynamic session) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                Text(
                  '${session.orderCount} commande(s)',
                  style: TextStyle(fontSize: 11, color: Colors.green[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSelector(BuildContext context, WidgetRef ref, dynamic posState) {
    // MODULARITÉ: Utiliser ModuleGate pour filtrer les types autorisés
    final allowedOrderTypes = ref.watch(allowedOrderTypesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type de commande',
          style: PosTextStyles.labelLarge,
        ),
        const SizedBox(height: PosSpacing.sm),
        Wrap(
          spacing: PosSpacing.sm,
          runSpacing: PosSpacing.sm,
          // MODULARITÉ: Afficher uniquement les types autorisés selon les modules actifs
          children: allowedOrderTypes.map((type) {
            final isSelected = posState.selectedOrderType == type;
            return PosChip(
              label: OrderType.getLabel(type),
              isSelected: isSelected,
              onTap: () => ref.read(posStateProvider.notifier).setOrderType(type),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomerNameInput(WidgetRef ref, dynamic posState) {
    return TextField(
      onChanged: (value) => ref.read(posStateProvider.notifier).setCustomerName(value),
      decoration: InputDecoration(
        labelText: 'Nom client (optionnel)',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, WidgetRef ref, bool hasItems, dynamic session) {
    return PosButton(
      label: 'Encaisser',
      icon: Icons.check_circle_rounded,
      variant: PosButtonVariant.success,
      size: PosButtonSize.large,
      isFullWidth: true,
      onPressed: hasItems ? () => _processCheckout(context, ref, session) : null,
    );
  }

  Widget _buildClearCartButton(BuildContext context, WidgetRef ref, bool hasItems) {
    return PosButton(
      label: 'Annuler',
      icon: Icons.delete_sweep_rounded,
      variant: PosButtonVariant.danger,
      size: PosButtonSize.large,
      isFullWidth: true,
      onPressed: hasItems
          ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(PosRadii.lg),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.delete_outline, color: PosColors.danger),
                      const SizedBox(width: PosSpacing.sm),
                      const Text('Annuler la commande'),
                    ],
                  ),
                  content: const Text('Êtes-vous sûr de vouloir vider le panier ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(posCartProvider.notifier).clearCart();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PosColors.danger,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Vider'),
                    ),
                  ],
                ),
              );
            }
          : null,
        foregroundColor: hasItems ? Colors.red[600] : Colors.grey[400],
        side: BorderSide(
          color: hasItems ? Colors.red[300]! : Colors.grey[300]!,
          width: 1.5,
        ),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCloseSessionButton(BuildContext context, WidgetRef ref, dynamic session, bool hasItems) {
    return PosButton(
      label: 'Fermer la caisse',
      icon: Icons.store_mall_directory,
      variant: PosButtonVariant.secondary,
      size: PosButtonSize.medium,
      isFullWidth: true,
      onPressed: hasItems ? null : () => _closeSession(context, ref, session),
    );
  }

  Future<void> _openSession(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => PosSessionOpenModal(
        onConfirm: (openingCash, notes) async {
          try {
            final auth = FirebaseAuth.instance;
            final user = auth.currentUser;
            if (user == null) throw Exception('Non connecté');

            final service = ref.read(cashierSessionServiceProvider);
            await service.openSession(
              staffId: user.uid,
              staffName: user.displayName ?? user.email ?? 'Utilisateur',
              openingCash: openingCash,
              notes: notes,
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session ouverte avec succès')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _closeSession(BuildContext context, WidgetRef ref, dynamic session) async {
    showDialog(
      context: context,
      builder: (context) => PosSessionCloseModal(
        session: session,
        onConfirm: (closingCash, notes) async {
          try {
            final service = ref.read(cashierSessionServiceProvider);
            await service.closeSession(
              sessionId: session.id,
              closingCash: closingCash,
              notes: notes,
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session fermée avec succès')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _processCheckout(BuildContext context, WidgetRef ref, dynamic session) async {
    // Validate cart
    final cartNotifier = ref.read(posCartProvider.notifier);
    final validationErrors = cartNotifier.validateCart();
    
    if (validationErrors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validation requise'),
          content: Text(validationErrors.join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Show cash payment modal
    showDialog(
      context: context,
      builder: (context) {
        final cart = ref.read(posCartProvider);
        final total = cartNotifier.calculateTotalWithSelections();
        
        return PosCashPaymentModal(
          orderTotal: total,
          onConfirm: (amountGiven, change) async {
            await _completeCheckout(context, ref, session, total, amountGiven, change);
          },
        );
      },
    );
  }

  Future<void> _completeCheckout(
    BuildContext context,
    WidgetRef ref,
    dynamic session,
    double total,
    double amountGiven,
    double change,
  ) async {
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user == null) throw Exception('Non connecté');

      final cart = ref.read(posCartProvider);
      final posState = ref.read(posStateProvider);
      final orderService = ref.read(posOrderServiceProvider);
      final sessionService = ref.read(cashierSessionServiceProvider);

      // Create draft order
      final orderId = await orderService.createDraftOrder(
        items: cart.items,
        total: total,
        orderType: posState.selectedOrderType,
        staffId: user.uid,
        staffName: user.displayName ?? 'Staff',
        sessionId: session.id,
        customerName: posState.customerName,
        tableNumber: posState.tableNumber,
        notes: posState.notes,
      );

      // Create payment transaction
      final paymentTransaction = PaymentTransaction(
        id: _uuid.v4(),
        orderId: orderId,
        method: PaymentMethod.cash,
        amount: total,
        amountGiven: amountGiven,
        change: change,
        timestamp: DateTime.now(),
        status: PaymentStatus.success,
      );

      // Mark as paid
      await orderService.markOrderAsPaid(
        orderId: orderId,
        payment: paymentTransaction,
      );

      // Add to session
      await sessionService.addOrderToSession(
        sessionId: session.id,
        orderId: orderId,
        paymentMethod: PaymentMethod.cash,
        amount: total,
      );

      // Clear cart and reset state
      ref.read(posCartProvider.notifier).clearCart();
      ref.read(posStateProvider.notifier).reset();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande enregistrée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
