/// lib/src/services/adapters/staff_tablet_adapter.dart
///
/// Adapter non-intrusif pour le module tablette staff.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/restaurant_plan_provider.dart';

/// Adapter pour le module tablette staff.
class StaffTabletAdapter {
  final WidgetRef ref;

  StaffTabletAdapter(this.ref);

  bool get isEnabled {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    return plan?.tablets?.staffTabletEnabled ?? false;
  }

  Map<String, dynamic>? get settings {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    return plan?.tablets?.staffSettings;
  }

  void apply() {
    if (!isEnabled) return;
    // Hook pour adaptations futures
  }
}

final staffTabletAdapterProvider = Provider<StaffTabletAdapter>((ref) {
  return StaffTabletAdapter(ref);
});
