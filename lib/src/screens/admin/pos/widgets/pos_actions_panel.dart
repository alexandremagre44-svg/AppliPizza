// lib/src/screens/admin/pos/widgets/pos_actions_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/app_theme.dart';
import '../providers/pos_cart_provider.dart';

/// POS Actions Panel - contains POS-specific action buttons
/// Encaisser (checkout), Annuler (cancel), etc.
class PosActionsPanel extends ConsumerWidget {
  const PosActionsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(posCartProvider);
    final hasItems = cart.items.isNotEmpty;

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

          // Encaisser button (Checkout)
          Container(
            decoration: BoxDecoration(
              gradient: hasItems
                  ? LinearGradient(
                      colors: [Colors.green[600]!, Colors.green[800]!],
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: hasItems
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
              onPressed: hasItems
                  ? () {
                      // TODO: Implement checkout logic in Phase 2
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Fonctionnalité à implémenter en Phase 2'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.check_circle_rounded, size: 28),
              label: const Text(
                'Encaisser',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasItems ? Colors.transparent : null,
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
                        content: const Text(
                          'Êtes-vous sûr de vouloir vider le panier ?',
                          style: TextStyle(fontSize: 15),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Annuler',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(posCartProvider.notifier).clearCart();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Panier vidé'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Vider',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
            icon: const Icon(Icons.delete_sweep_rounded, size: 22),
            label: const Text(
              'Annuler la commande',
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

          // Payment method placeholder
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Mode de paiement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _PaymentMethodButton(
                    icon: Icons.euro,
                    label: 'Espèces',
                    isSelected: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _PaymentMethodButton(
                    icon: Icons.credit_card,
                    label: 'Carte bancaire',
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _PaymentMethodButton(
                    icon: Icons.more_horiz,
                    label: 'Autre',
                    isSelected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLighter : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : Colors.grey[600],
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : Colors.grey[700],
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
