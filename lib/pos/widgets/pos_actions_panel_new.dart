/// POS Actions Panel - checkout and payment controls
/// 
/// This widget provides action buttons for checkout, cancel, and payment
/// method selection.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pos_cart_provider.dart';
import '../providers/pos_context_provider.dart';
import '../providers/pos_payment_provider.dart';
import '../providers/pos_order_provider.dart';
import '../models/pos_payment_method.dart';
import 'payment_selector.dart';

/// Actions panel widget for POS
class PosActionsPanelNew extends ConsumerWidget {
  const PosActionsPanelNew({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(posCartProvider);
    final posContext = ref.watch(posContextProvider);
    final orderState = ref.watch(posOrderProvider);
    final hasItems = cart.isNotEmpty;
    final hasValidContext = posContext != null && posContext.isValid;
    final canCheckout = hasItems && hasValidContext && !orderState.isSubmitting;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          
          // Checkout button
          Container(
            decoration: BoxDecoration(
              gradient: canCheckout
                  ? LinearGradient(
                      colors: [Colors.green[600]!, Colors.green[800]!],
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: canCheckout
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton.icon(
              onPressed: canCheckout
                  ? () async {
                      // Submit order
                      final order = await ref.read(posOrderProvider.notifier).submitOrder();
                      
                      if (order != null && context.mounted) {
                        // Show success dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green[700], size: 32),
                                const SizedBox(width: 12),
                                const Text('Commande validée'),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('La commande a été enregistrée avec succès.'),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Total: ${order.total.toStringAsFixed(2)} €',
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Contexte: ${order.context.displayLabel}'),
                                      Text('Paiement: ${order.paymentMethod.label}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                ),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else if (orderState.error != null && context.mounted) {
                        // Show error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(orderState.error!),
                            backgroundColor: Colors.red[600],
                          ),
                        );
                      }
                    }
                  : null,
              icon: orderState.isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle_rounded, size: 28),
              label: Text(
                orderState.isSubmitting ? 'Traitement...' : 'Encaisser',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: canCheckout ? Colors.transparent : null,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
          
          // Show warning if context not set
          if (hasItems && !hasValidContext) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Sélectionnez un contexte pour continuer',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Clear cart button
          OutlinedButton.icon(
            onPressed: hasItems
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red[700]),
                            const SizedBox(width: 12),
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
                              backgroundColor: Colors.red[600],
                            ),
                            child: const Text('Vider'),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.delete_sweep_rounded, size: 22),
            label: const Text(
              'Annuler',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
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
          ),
          
          const SizedBox(height: 24),
          
          // Divider
          Divider(color: Colors.grey[300], thickness: 1),
          
          const SizedBox(height: 24),
          
          // Payment method selector
          const PosPaymentSelector(),
        ],
      ),
    );
  }
}
