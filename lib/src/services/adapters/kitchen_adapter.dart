/// lib/src/services/adapters/kitchen_adapter.dart
///
/// Adapter non-intrusif pour le module tablette cuisine.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/restaurant_plan_provider.dart';

/// Adapter pour le module tablette cuisine.
class KitchenAdapter {
  final WidgetRef ref;

  KitchenAdapter(this.ref);

  bool get isEnabled {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    return plan?.tablets?.kitchenTabletEnabled ?? false;
  }

  Map<String, dynamic>? get settings {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    return plan?.tablets?.kitchenSettings;
  }

  void apply() {
    if (!isEnabled) return;
    // Hook pour adaptations futures
  }
}

final kitchenAdapterProvider = Provider<KitchenAdapter>((ref) {
  return KitchenAdapter(ref);
});
