/// lib/src/services/adapters/promotions_adapter.dart
///
/// Adapter non-intrusif pour le service de promotions.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../white_label/modules/marketing/promotions/promotions_module_config.dart';
import '../../providers/restaurant_plan_provider.dart';

/// Adapter pour le module de promotions.
class PromotionsAdapter {
  final WidgetRef ref;

  PromotionsAdapter(this.ref);

  bool get isEnabled {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    return plan?.promotions?.enabled ?? false;
  }

  PromotionsModuleConfig? get config {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    return plan?.promotions;
  }

  Map<String, dynamic>? get settings => config?.settings;

  void apply() {
    if (!isEnabled) return;
    // Hook pour adaptations futures
  }
}

final promotionsAdapterProvider = Provider<PromotionsAdapter>((ref) {
  return PromotionsAdapter(ref);
});
