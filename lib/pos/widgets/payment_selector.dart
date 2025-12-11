/// POS Payment Selector - widget for selecting payment method
/// 
/// This widget displays payment method options and allows the user to select one.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pos_payment_method.dart';
import '../providers/pos_payment_provider.dart';

/// Payment selector widget
class PosPaymentSelector extends ConsumerWidget {
  const PosPaymentSelector({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(posPaymentProvider);
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: theme.colorScheme.primary, size: 24),
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
            
            // Payment method buttons
            _PaymentMethodButton(
              icon: Icons.euro,
              label: PosPaymentMethod.cash.label,
              isSelected: selectedMethod == PosPaymentMethod.cash,
              onTap: () {
                ref.read(posPaymentProvider.notifier)
                    .setPaymentMethod(PosPaymentMethod.cash);
              },
            ),
            const SizedBox(height: 8),
            _PaymentMethodButton(
              icon: Icons.credit_card,
              label: PosPaymentMethod.card.label,
              isSelected: selectedMethod == PosPaymentMethod.card,
              onTap: () {
                ref.read(posPaymentProvider.notifier)
                    .setPaymentMethod(PosPaymentMethod.card);
              },
            ),
            const SizedBox(height: 8),
            _PaymentMethodButton(
              icon: Icons.more_horiz,
              label: PosPaymentMethod.other.label,
              isSelected: selectedMethod == PosPaymentMethod.other,
              onTap: () {
                ref.read(posPaymentProvider.notifier)
                    .setPaymentMethod(PosPaymentMethod.other);
              },
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey[600],
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey[700],
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
