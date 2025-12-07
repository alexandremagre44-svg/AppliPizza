// lib/builder/runtime/modules/payment_module_client_widget.dart
// Client widget for payment_module - checkout and payment functionality

import 'package:flutter/material.dart';
import '../../../src/design_system/app_theme.dart';
import '../../../white_label/modules/payment/payments_core/payment_service.dart';
import '../../../white_label/modules/core/delivery/delivery_runtime_service.dart';
import '../../../white_label/modules/core/delivery/delivery_settings.dart';

/// Payment Module Client Widget
/// 
/// Comprehensive checkout widget for the payment module.
/// Features:
/// - Cart display with items
/// - Price summary
/// - Delivery section (when delivery module enabled)
/// - Click & collect section (when click_collect module enabled)
/// - Form validation
/// - Pay button
class PaymentModuleClientWidget extends StatefulWidget {
  final CartService cartService;
  final bool deliveryEnabled;
  final bool clickCollectEnabled;
  final DeliverySettings? deliverySettings;
  final VoidCallback? onPaymentSuccess;

  const PaymentModuleClientWidget({
    super.key,
    required this.cartService,
    this.deliveryEnabled = false,
    this.clickCollectEnabled = false,
    this.deliverySettings,
    this.onPaymentSuccess,
  });

  @override
  State<PaymentModuleClientWidget> createState() => _PaymentModuleClientWidgetState();
}

class _PaymentModuleClientWidgetState extends State<PaymentModuleClientWidget> {
  final addressController = TextEditingController();
  String? selectedDeliverySlot;
  String? selectedClickCollectSlot;
  double deliveryFee = 0.0;
  String? addressError;
  bool isValidatingAddress = false;
  DeliveryRuntimeService? deliveryService;

  @override
  void initState() {
    super.initState();
    if (widget.deliveryEnabled && widget.deliverySettings != null) {
      deliveryService = DeliveryRuntimeService(widget.deliverySettings!);
    }
    
    // Load existing checkout state
    final checkout = widget.cartService.checkoutState;
    if (checkout.deliveryAddress != null) {
      addressController.text = checkout.deliveryAddress!;
    }
    selectedDeliverySlot = checkout.deliverySlot;
    selectedClickCollectSlot = checkout.clickCollectSlot;
    deliveryFee = checkout.deliveryFee ?? 0.0;
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  Future<void> _validateAndCalculateFee() async {
    if (deliveryService == null) return;

    setState(() {
      isValidatingAddress = true;
      addressError = null;
    });

    final address = addressController.text;
    final error = await deliveryService!.validateAddress(address);

    if (error != null) {
      setState(() {
        addressError = error;
        deliveryFee = 0.0;
        isValidatingAddress = false;
      });
      return;
    }

    final fee = await deliveryService!.calculateDeliveryFee(
      address,
      widget.cartService.subtotal,
    );

    setState(() {
      deliveryFee = fee;
      isValidatingAddress = false;
    });

    // Update checkout state
    widget.cartService.updateCheckoutState(
      widget.cartService.checkoutState.copyWith(
        deliveryAddress: address,
        deliveryFee: fee,
        isDelivery: true,
      ),
    );
  }

  bool _isFormValid() {
    if (widget.cartService.items.isEmpty) return false;

    if (widget.deliveryEnabled) {
      return addressController.text.isNotEmpty &&
          selectedDeliverySlot != null &&
          addressError == null;
    }

    if (widget.clickCollectEnabled) {
      return selectedClickCollectSlot != null;
    }

    return true;
  }

  void _handlePayment() {
    if (!_isFormValid()) return;

    // Update final checkout state
    if (widget.deliveryEnabled) {
      widget.cartService.updateCheckoutState(
        widget.cartService.checkoutState.copyWith(
          deliveryAddress: addressController.text,
          deliverySlot: selectedDeliverySlot,
          deliveryFee: deliveryFee,
          isDelivery: true,
        ),
      );
    } else if (widget.clickCollectEnabled) {
      widget.cartService.updateCheckoutState(
        widget.cartService.checkoutState.copyWith(
          clickCollectSlot: selectedClickCollectSlot,
          isDelivery: false,
        ),
      );
    }

    widget.onPaymentSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.shopping_cart, color: colorScheme.primary, size: 32),
                SizedBox(width: AppSpacing.md),
                Text(
                  "Checkout",
                  style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // Cart items
            _buildCartItems(),
            SizedBox(height: AppSpacing.lg),

            // Price summary
            _buildPriceSummary(),
            SizedBox(height: AppSpacing.lg),

            // Delivery section (if enabled)
            if (widget.deliveryEnabled) ...[
              _buildDeliverySection(),
              SizedBox(height: AppSpacing.lg),
            ],

            // Click & collect section (if enabled)
            if (widget.clickCollectEnabled && !widget.deliveryEnabled) ...[
              _buildClickCollectSection(),
              SizedBox(height: AppSpacing.lg),
            ],

            // Pay button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isFormValid() ? _handlePayment : null,
                child: Text(
                  'Payer ${(widget.cartService.subtotal + deliveryFee).toStringAsFixed(2)} €',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    if (widget.cartService.items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'Votre panier est vide',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articles (${widget.cartService.items.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: AppSpacing.sm),
        ...widget.cartService.items.map((item) => Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.productName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '${item.total.toStringAsFixed(2)} €',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildPriceSummary() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sous-total', style: textTheme.bodyLarge),
              Text(
                '${widget.cartService.subtotal.toStringAsFixed(2)} €',
                style: textTheme.bodyLarge,
              ),
            ],
          ),
          if (deliveryFee > 0) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Frais de livraison', style: textTheme.bodyLarge),
                Text(
                  '${deliveryFee.toStringAsFixed(2)} €',
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
          ],
          Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(widget.cartService.subtotal + deliveryFee).toStringAsFixed(2)} €',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final slots = deliveryService?.listTimeSlots() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Livraison',
          style: textTheme.titleMedium?.copyWith(color: colorScheme.primary),
        ),
        SizedBox(height: AppSpacing.md),
        
        // Address field
        Text(
          'Votre adresse',
          style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: AppSpacing.xs),
        TextField(
          controller: addressController,
          decoration: InputDecoration(
            hintText: 'Saisissez votre adresse complète',
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: AppRadius.input,
              borderSide: BorderSide.none,
            ),
            errorText: addressError,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            suffixIcon: isValidatingAddress
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: (_) {
            setState(() {
              addressError = null;
            });
          },
          onSubmitted: (_) => _validateAndCalculateFee(),
        ),
        SizedBox(height: AppSpacing.sm),
        TextButton.icon(
          onPressed: isValidatingAddress ? null : _validateAndCalculateFee,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Valider l\'adresse'),
        ),
        
        SizedBox(height: AppSpacing.md),
        
        // Time slot selection
        Text(
          'Créneau de livraison',
          style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: AppSpacing.xs),
        if (slots.isEmpty)
          Text(
            'Aucun créneau disponible',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: slots.map((slot) => ChoiceChip(
              label: Text(slot),
              selected: selectedDeliverySlot == slot,
              onSelected: (selected) {
                setState(() {
                  selectedDeliverySlot = selected ? slot : null;
                });
              },
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildClickCollectSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Default pickup slots
    final slots = [
      '12:00 - 12:30',
      '12:30 - 13:00',
      '19:00 - 19:30',
      '19:30 - 20:00',
      '20:00 - 20:30',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Click & Collect',
          style: textTheme.titleMedium?.copyWith(color: colorScheme.primary),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Créneau de retrait',
          style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: slots.map((slot) => ChoiceChip(
            label: Text(slot),
            selected: selectedClickCollectSlot == slot,
            onSelected: (selected) {
              setState(() {
                selectedClickCollectSlot = selected ? slot : null;
              });
            },
          )).toList(),
        ),
      ],
    );
  }
}
