/// lib/src/helpers/module_visibility.dart
///
/// Helpers pour vérifier la visibilité des modules dans l'application cliente.
///
/// Ces fonctions utilisent le RestaurantPlanUnified via les providers Riverpod
/// pour déterminer quels modules sont activés.
///
/// IMPORTANT: Ces helpers ne modifient JAMAIS les services existants.
/// Ils servent uniquement à vérifier l'état des modules.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../white_label/core/module_id.dart';
import '../../white_label/runtime/module_runtime_adapter.dart';
import '../providers/restaurant_plan_provider.dart';

/// Vérifie si le module de livraison est activé.
///
/// Utilise le provider unifié pour vérifier l'état du module.
bool isDeliveryEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.delivery);
}

/// Vérifie si le module Click & Collect est activé.
bool isClickAndCollectEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.clickAndCollect);
}

/// Vérifie si le module de commandes est activé.
bool isOrderingEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.ordering);
}

/// Vérifie si le module de fidélité est activé.
bool isLoyaltyEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.loyalty);
}

/// Vérifie si le module de promotions est activé.
bool isPromotionEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.promotions);
}

/// Vérifie si le module roulette est activé.
bool isRouletteEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.roulette);
}

/// Vérifie si le module newsletter est activé.
bool isNewsletterEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.newsletter);
}

/// Vérifie si le module tablette cuisine est activé.
bool isKitchenEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.kitchen_tablet);
}

/// Vérifie si le module tablette staff est activé.
bool isStaffTabletEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.staff_tablet);
}

/// Vérifie si le module de paiement est activé.
bool isPaymentEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.payments);
}

/// Vérifie si le module de terminal de paiement est activé.
bool isPaymentTerminalEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.paymentTerminal);
}

/// Vérifie si le module portefeuille est activé.
bool isWalletEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.wallet);
}

/// Vérifie si le module thème est activé.
bool isThemeEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.theme);
}

/// Vérifie si le module constructeur de pages est activé.
bool isPagesBuilderEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.pagesBuilder);
}

/// Vérifie si le module reporting est activé.
bool isReportingEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.reporting);
}

/// Vérifie si le module exports est activé.
bool isExportsEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.exports);
}

/// Vérifie si le module campagnes est activé.
bool isCampaignsEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.campaigns);
}

/// Vérifie si le module pointeuse est activé.
bool isTimeRecorderEnabled(WidgetRef ref) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isModuleActiveById(plan, ModuleId.timeRecorder);
}

/// Vérifie si plusieurs modules sont tous activés.
///
/// Utile pour vérifier les dépendances entre modules.
bool areAllModulesEnabled(WidgetRef ref, List<ModuleId> moduleIds) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.areAllModulesActive(plan, moduleIds);
}

/// Vérifie si au moins un des modules spécifiés est activé.
///
/// Utile pour afficher des fonctionnalités alternatives.
bool isAnyModuleEnabled(WidgetRef ref, List<ModuleId> moduleIds) {
  final planAsync = ref.watch(restaurantPlanUnifiedProvider);
  final plan = planAsync.asData?.value;
  return ModuleRuntimeAdapter.isAnyModuleActive(plan, moduleIds);
}
