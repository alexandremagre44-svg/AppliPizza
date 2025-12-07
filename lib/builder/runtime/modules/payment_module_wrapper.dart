// lib/builder/runtime/modules/payment_module_wrapper.dart
// Wrapper for payment module that integrates with Riverpod providers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../white_label/modules/payment/payments_core/payment_service_provider.dart';
import '../../../white_label/modules/core/delivery/delivery_runtime_provider.dart';
import '../../../white_label/core/module_id.dart';
import '../../../white_label/runtime/module_runtime_adapter.dart';
import '../../../src/providers/restaurant_plan_provider.dart';
import 'payment_module_client_widget.dart';

/// Wrapper widget that connects PaymentModuleClientWidget with Riverpod providers
class PaymentModuleWrapper extends ConsumerWidget {
  const PaymentModuleWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartService = ref.watch(cartServiceProvider);
    final deliverySettingsAsync = ref.watch(deliverySettingsProvider);
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);

    return planAsync.when(
      data: (plan) {
        final deliveryEnabled = ModuleRuntimeAdapter.isModuleActiveById(
          plan,
          ModuleId.delivery,
        );
        final clickCollectEnabled = ModuleRuntimeAdapter.isModuleActiveById(
          plan,
          ModuleId.clickAndCollect,
        );

        return deliverySettingsAsync.when(
          data: (deliverySettings) => PaymentModuleClientWidget(
            cartService: cartService,
            deliveryEnabled: deliveryEnabled,
            clickCollectEnabled: clickCollectEnabled,
            deliverySettings: deliveryEnabled ? deliverySettings : null,
            onPaymentSuccess: () {
              // TODO: Navigate to order confirmation
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paiement confirmé !'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => PaymentModuleClientWidget(
            cartService: cartService,
            deliveryEnabled: deliveryEnabled,
            clickCollectEnabled: clickCollectEnabled,
            deliverySettings: null,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => PaymentModuleClientWidget(
        cartService: cartService,
        deliveryEnabled: false,
        clickCollectEnabled: false,
        deliverySettings: null,
      ),
    );
  }
}
