/// lib/src/services/adapters/roulette_adapter.dart
///
/// Adapter non-intrusif pour le service de roulette.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../white_label/modules/marketing/roulette/roulette_module_config.dart';
import '../../providers/restaurant_plan_provider.dart';

/// Adapter pour le module de roulette.
class RouletteAdapter {
  final WidgetRef ref;

  RouletteAdapter(this.ref);

  bool get isEnabled {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    return plan?.roulette?.enabled ?? false;
  }

  RouletteModuleConfig? get config {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    return plan?.roulette;
  }

  Map<String, dynamic>? get settings => config?.settings;

  void apply() {
    if (!isEnabled) return;
    // Hook pour adaptations futures
  }
}

final rouletteAdapterProvider = Provider<RouletteAdapter>((ref) {
  return RouletteAdapter(ref);
});
