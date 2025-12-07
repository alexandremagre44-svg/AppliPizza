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
    final deliverySettingsAsync = ref.watch(wlDeliverySettingsProvider);
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
              // TODO: Implement proper order confirmation navigation
              // This should:
              // 1. Create the order via CartService.createOrder()
              // 2. Navigate to /order-confirmation with orderId
              // 3. Clear the cart
              // 
              // Example implementation:
              // final restaurantId = ref.read(currentRestaurantProvider).id;
              // final orderId = await cartService.createOrder(restaurantId);
              // if (context.mounted) {
              //   context.go('/order-confirmation/$orderId');
              // }
              //
              // For now, show a simple confirmation
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paiement confirmé ! Commande en cours de création...'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
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
