// lib/src/screens/admin/pos/widgets/pos_cash_payment_modal.dart
/// 
/// Cash payment modal with change calculation
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/app_theme.dart';

/// Cash payment modal
class PosCashPaymentModal extends ConsumerStatefulWidget {
  final double orderTotal;
  final Function(double amountGiven, double change) onConfirm;
  
  const PosCashPaymentModal({
    Key? key,
    required this.orderTotal,
    required this.onConfirm,
  }) : super(key: key);
  
  @override
  ConsumerState<PosCashPaymentModal> createState() => _PosCashPaymentModalState();
}

class _PosCashPaymentModalState extends ConsumerState<PosCashPaymentModal> {
  final _controller = TextEditingController();
  double? _amountGiven;
  double? _change;
  
  @override
  void initState() {
    super.initState();
    // Pre-fill with exact amount
    _controller.text = widget.orderTotal.toStringAsFixed(2);
    _amountGiven = widget.orderTotal;
    _change = 0.0;
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _calculateChange(String value) {
    if (value.isEmpty) {
      setState(() {
        _amountGiven = null;
        _change = null;
      });
      return;
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      setState(() {
        _amountGiven = null;
        _change = null;
      });
      return;
    }
    
    setState(() {
      _amountGiven = amount;
      _change = amount - widget.orderTotal;
    });
  }
  
  void _addQuickAmount(double amount) {
    final newAmount = (_amountGiven ?? 0.0) + amount;
    _controller.text = newAmount.toStringAsFixed(2);
    _calculateChange(_controller.text);
  }
  
  void _setExactAmount(double amount) {
    _controller.text = amount.toStringAsFixed(2);
    _calculateChange(_controller.text);
  }
  
  bool get _canConfirm {
    return _amountGiven != null && _amountGiven! >= widget.orderTotal;
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.euro,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Paiement en espèces',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Order total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total à payer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.orderTotal.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Amount given input
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: _calculateChange,
              decoration: InputDecoration(
                labelText: 'Montant reçu',
                suffixText: '€',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick amount buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickAmountButton(
                  label: 'Exact',
                  onTap: () => _setExactAmount(widget.orderTotal),
                ),
                _QuickAmountButton(
                  label: '+5€',
                  onTap: () => _addQuickAmount(5.0),
                ),
                _QuickAmountButton(
                  label: '+10€',
                  onTap: () => _addQuickAmount(10.0),
                ),
                _QuickAmountButton(
                  label: '+20€',
                  onTap: () => _addQuickAmount(20.0),
                ),
                _QuickAmountButton(
                  label: '+50€',
                  onTap: () => _addQuickAmount(50.0),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Change display
            if (_change != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _change! >= 0 ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _change! >= 0 ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _change! >= 0 ? Icons.check_circle : Icons.error,
                          color: _change! >= 0 ? Colors.green[700] : Colors.red[700],
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _change! >= 0 ? 'Monnaie à rendre' : 'Montant insuffisant',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _change! >= 0 ? Colors.green[900] : Colors.red[900],
                          ),
                        ),
                      ],
                    ),
                    if (_change! >= 0)
                      Text(
                        '${_change!.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canConfirm
                        ? () {
                            widget.onConfirm(_amountGiven!, _change!);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Valider',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  
  const _QuickAmountButton({
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
