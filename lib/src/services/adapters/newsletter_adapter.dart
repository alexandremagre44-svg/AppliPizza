/// lib/src/services/adapters/newsletter_adapter.dart
///
/// Adapter non-intrusif pour le service de newsletter.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../white_label/modules/marketing/newsletter/newsletter_module_config.dart';
import '../../providers/restaurant_plan_provider.dart';

/// Adapter pour le module de newsletter.
class NewsletterAdapter {
  final WidgetRef ref;

  NewsletterAdapter(this.ref);

  bool get isEnabled {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    return plan?.newsletter?.enabled ?? false;
  }

  NewsletterModuleConfig? get config {
    final planAsync = ref.watch(restaurantPlanUnifiedProvider);
    final plan = planAsync.asData?.value;
    return plan?.newsletter;
  }

  Map<String, dynamic>? get settings => config?.settings;

  void apply() {
    if (!isEnabled) return;
    // Hook pour adaptations futures
  }
}

final newsletterAdapterProvider = Provider<NewsletterAdapter>((ref) {
  return NewsletterAdapter(ref);
});
