/// lib/superadmin/pages/restaurant_wizard/wizard_state.dart
///
/// State management pour le Wizard de création de restaurant.
/// Utilise StateNotifier pour gérer l'état du formulaire multi-étapes.
/// Connecté à Firestore pour la persistance des données.
///
/// FIX: selectTemplate method
/// - Changed parameter type from 'dynamic' to 'RestaurantTemplate' for type safety
/// - Removed redundant type casts (as String)
/// - Added debug logs to track state updates
/// - Ensures proper state notification to trigger UI rebuilds
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../white_label/core/module_registry.dart';
import '../../../white_label/restaurant/restaurant_template.dart';
import '../../models/restaurant_blueprint.dart';
import '../../services/superadmin_restaurant_service.dart';
import '../../services/restaurant_plan_service.dart';
import 'wizard_step_template.dart';

/// Étapes du wizard.
enum WizardStep {
  /// Étape 1: Identité du restaurant (nom, slug).
  identity,

  /// Étape 2: Configuration de la marque (couleurs, logo).
  brand,

  /// Étape 3: Sélection du template.
  template,

  /// Étape 4: Activation des modules.
  modules,

  /// Étape 5: Aperçu et validation.
  preview,
}

/// Extension pour WizardStep.
extension WizardStepExtension on WizardStep {
  /// Index de l'étape (0-based).
  int get index {
    switch (this) {
      case WizardStep.identity:
        return 0;
      case WizardStep.brand:
        return 1;
      case WizardStep.template:
        return 2;
      case WizardStep.modules:
        return 3;
      case WizardStep.preview:
        return 4;
    }
  }

  /// Titre de l'étape.
  String get title {
    switch (this) {
      case WizardStep.identity:
        return 'Identité';
      case WizardStep.brand:
        return 'Marque';
      case WizardStep.template:
        return 'Template';
      case WizardStep.modules:
        return 'Modules';
      case WizardStep.preview:
        return 'Aperçu';
    }
  }

  /// Description de l'étape.
  String get description {
    switch (this) {
      case WizardStep.identity:
        return 'Définissez le nom de votre restaurant';
      case WizardStep.brand:
        return 'Personnalisez les couleurs et le logo';
      case WizardStep.template:
        return 'Choisissez un template de départ';
      case WizardStep.modules:
        return 'Activez les fonctionnalités souhaitées';
      case WizardStep.preview:
        return 'Vérifiez et validez votre configuration';
    }
  }

  /// Icône de l'étape.
  String get iconName {
    switch (this) {
      case WizardStep.identity:
        return 'store';
      case WizardStep.brand:
        return 'palette';
      case WizardStep.template:
        return 'dashboard';
      case WizardStep.modules:
        return 'extension';
      case WizardStep.preview:
        return 'preview';
    }
  }

  /// Nombre total d'étapes.
  static int get totalSteps => WizardStep.values.length;

  /// Étape suivante (null si dernière).
  WizardStep? get next {
    final nextIndex = index + 1;
    if (nextIndex >= WizardStep.values.length) return null;
    return WizardStep.values[nextIndex];
  }

  /// Étape précédente (null si première).
  WizardStep? get previous {
    final prevIndex = index - 1;
    if (prevIndex < 0) return null;
    return WizardStep.values[prevIndex];
  }
}

/// État du wizard de création de restaurant.
class RestaurantWizardState {
  /// Blueprint en cours de construction.
  final RestaurantBlueprintLight blueprint;

  /// Liste des modules activés (basée sur String module IDs).
  final List<String> enabledModuleIds;

  /// Étape courante du wizard.
  final WizardStep currentStep;

  /// Indique si le wizard est en cours de soumission.
  final bool isSubmitting;

  /// Message d'erreur éventuel.
  final String? error;

  /// Indique si le wizard a été complété avec succès.
  final bool isCompleted;

  /// Constructeur principal.
  const RestaurantWizardState({
    required this.blueprint,
    this.enabledModuleIds = const [],
    this.currentStep = WizardStep.identity,
    this.isSubmitting = false,
    this.error,
    this.isCompleted = false,
  });

  /// Factory pour créer un état initial vide.
  factory RestaurantWizardState.initial() {
    return RestaurantWizardState(
      blueprint: RestaurantBlueprintLight.empty(),
      enabledModuleIds: const [],
    );
  }

  /// Crée une copie avec des valeurs modifiées.
  RestaurantWizardState copyWith({
    RestaurantBlueprintLight? blueprint,
    List<String>? enabledModuleIds,
    WizardStep? currentStep,
    bool? isSubmitting,
    String? error,
    bool? isCompleted,
  }) {
    return RestaurantWizardState(
      blueprint: blueprint ?? this.blueprint,
      enabledModuleIds: enabledModuleIds ?? this.enabledModuleIds,
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Vérifie si l'identité est valide (Step 1).
  bool get isIdentityValid =>
      blueprint.name.isNotEmpty && blueprint.slug.isNotEmpty;

  /// Vérifie si la marque est valide (Step 2).
  bool get isBrandValid => blueprint.brand.brandName.isNotEmpty;

  /// Vérifie si le template est valide (Step 3).
  /// Le template est optionnel, donc toujours valide.
  bool get isTemplateValid => true;

  /// Vérifie si les modules sont valides (Step 4).
  /// Valide les dépendances des modules activés.
  bool get isModulesValid => validateModuleDependencies(enabledModuleIds);

  /// Vérifie si la configuration est prête pour la création (Step 5).
  /// Combine toutes les validations.
  bool get isReadyForCreation =>
      isIdentityValid && isBrandValid && isTemplateValid && isModulesValid;

  /// Vérifie si l'étape courante est valide.
  bool get isCurrentStepValid {
    switch (currentStep) {
      case WizardStep.identity:
        return isIdentityValid;
      case WizardStep.brand:
        return isBrandValid;
      case WizardStep.template:
        return isTemplateValid;
      case WizardStep.modules:
        return isModulesValid;
      case WizardStep.preview:
        return isReadyForCreation;
    }
  }

  /// Vérifie si on peut aller à l'étape suivante.
  bool get canGoNext => isCurrentStepValid && currentStep.next != null;

  /// Vérifie si on peut revenir à l'étape précédente.
  bool get canGoBack => currentStep.previous != null;

  /// Vérifie si c'est la dernière étape.
  bool get isLastStep => currentStep == WizardStep.preview;

  /// Pourcentage de progression (0.0 à 1.0).
  double get progress =>
      (currentStep.index + 1) / WizardStepExtension.totalSteps;
}

/// Convertit un module ID depuis le format `.name` vers le format registry (snake_case).
/// Nécessaire car ModuleRegistry utilise des clés en snake_case
/// mais ModuleId.name produit des valeurs mixtes (camelCase pour certains, snake_case pour d'autres).
String _toRegistryFormat(String moduleIdName) {
  // Convert camelCase to snake_case for modules that need it
  switch (moduleIdName) {
    case 'clickAndCollect':
      return 'click_and_collect';
    case 'paymentTerminal':
      return 'payment_terminal';
    case 'timeRecorder':
      return 'time_recorder';
    case 'pagesBuilder':
      return 'pages_builder';
    // For modules already in snake_case or simple names, return as-is
    default:
      return moduleIdName;
  }
}

/// Valide les dépendances des modules.
/// Retourne true si toutes les dépendances sont satisfaites.
bool validateModuleDependencies(List<String> modules) {
  for (final moduleId in modules) {
    final registryId = _toRegistryFormat(moduleId);
    final definition = ModuleRegistry.of(registryId);
    if (definition != null) {
      for (final dep in definition.dependencies) {
        // Dependencies from registry are in snake_case format
        // Need to check if the equivalent .name format exists in modules list
        final depInNameFormat = modules.firstWhere(
          (m) => _toRegistryFormat(m) == dep,
          orElse: () => '',
        );
        if (depInNameFormat.isEmpty) {
          return false;
        }
      }
    }
  }
  return true;
}

/// Récupère les dépendances manquantes pour une liste de modules.
List<String> getMissingDependencies(List<String> modules) {
  final missing = <String>[];
  for (final moduleId in modules) {
    final registryId = _toRegistryFormat(moduleId);
    final definition = ModuleRegistry.of(registryId);
    if (definition != null) {
      for (final dep in definition.dependencies) {
        // Check if dependency exists in modules (considering name format conversion)
        final depExists = modules.any((m) => _toRegistryFormat(m) == dep);
        if (!depExists && !missing.contains(dep)) {
          missing.add(dep);
        }
      }
    }
  }
  return missing;
}

/// Notifier pour gérer l'état du wizard.
class RestaurantWizardNotifier extends StateNotifier<RestaurantWizardState> {
  RestaurantWizardNotifier() : super(RestaurantWizardState.initial());

  /// Helper pour obtenir le nom d'un module depuis son ID.
  /// Convertit le format .name vers le format registry si nécessaire.
  String _getModuleName(String id) =>
      ModuleRegistry.of(_toRegistryFormat(id))?.name ?? id;

  /// Réinitialise le wizard.
  void reset() {
    state = RestaurantWizardState.initial();
  }

  /// Met à jour l'identité du restaurant.
  void updateIdentity({
    String? id,
    String? name,
    String? slug,
  }) {
    state = state.copyWith(
      blueprint: state.blueprint.copyWith(
        id: id,
        name: name,
        slug: slug,
      ),
    );
  }

  /// Met à jour la configuration de marque.
  void updateBrand({
    String? brandName,
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    String? logoUrl,
    String? appIconUrl,
  }) {
    state = state.copyWith(
      blueprint: state.blueprint.copyWith(
        brand: state.blueprint.brand.copyWith(
          brandName: brandName,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          accentColor: accentColor,
          logoUrl: logoUrl,
          appIconUrl: appIconUrl,
        ),
      ),
    );
  }

  /// Met à jour le template sélectionné.
  void updateTemplate(String? templateId) {
    state = state.copyWith(
      blueprint: state.blueprint.copyWith(
        templateId: templateId,
      ),
    );
  }

  /// Sélectionne un template et suggère ses modules recommandés.
  ///
  /// [template] Le template métier à appliquer (RestaurantTemplate)
  /// 
  /// ⚠️ IMPORTANT: Le template NE contrôle PAS les modules.
  /// Les modules recommandés sont pré-cochés mais peuvent être modifiés
  /// par le SuperAdmin à l'étape suivante.
  void selectTemplate(RestaurantTemplate template) {
    if (kDebugMode) {
      debugPrint('[Wizard] selectTemplate called: ${template.id}');
      debugPrint('[Wizard] Current templateId: ${state.blueprint.templateId}');
    }
    
    final templateId = template.id;
    
    // Get recommended modules from the new template system
    final recommendedModuleIds = template.recommendedModules
        .map((m) => m.name)
        .toList();
    
    if (kDebugMode) {
      debugPrint('[Wizard] Recommended modules: $recommendedModuleIds');
    }
    
    // Mettre à jour le template ID et les modules recommandés (pas forcés)
    state = state.copyWith(
      blueprint: state.blueprint.copyWith(
        templateId: templateId,
        modules: _moduleIdsToModulesLight(recommendedModuleIds),
      ),
      // Create defensive copy to prevent unintended mutations
      enabledModuleIds: List.of(recommendedModuleIds),
    );
    
    if (kDebugMode) {
      debugPrint('[Wizard] New templateId: ${state.blueprint.templateId}');
      debugPrint('[Wizard] State updated successfully');
    }
  }

  /// Active ou désactive un module par son ID.
  void toggleModule(String moduleId, bool enabled) {
    final currentModules = List<String>.from(state.enabledModuleIds);
    
    if (enabled) {
      if (!currentModules.contains(moduleId)) {
        currentModules.add(moduleId);
        // Ajouter automatiquement les dépendances requises
        final definition = ModuleRegistry.of(moduleId);
        if (definition != null) {
          for (final dep in definition.dependencies) {
            if (!currentModules.contains(dep)) {
              currentModules.add(dep);
            }
          }
        }
      }
    } else {
      currentModules.remove(moduleId);
      // Désactiver les modules qui dépendent de celui-ci
      final dependentModules = currentModules.where((m) {
        final def = ModuleRegistry.of(m);
        return def != null && def.dependencies.contains(moduleId);
      }).toList();
      for (final dep in dependentModules) {
        currentModules.remove(dep);
      }
    }
    
    state = state.copyWith(
      enabledModuleIds: currentModules,
      blueprint: state.blueprint.copyWith(
        modules: _moduleIdsToModulesLight(currentModules),
      ),
    );
  }

  /// Remplace entièrement la liste des modules activés.
  void setEnabledModules(List<String> moduleIds) {
    state = state.copyWith(
      enabledModuleIds: moduleIds,
      blueprint: state.blueprint.copyWith(
        modules: _moduleIdsToModulesLight(moduleIds),
      ),
    );
  }

  /// Convertit une liste de String module IDs en RestaurantModulesLight.
  /// Note: RestaurantModulesLight only supports 8 modules currently.
  /// Additional module IDs are stored in enabledModuleIds for future use.
  RestaurantModulesLight _moduleIdsToModulesLight(List<String> moduleIds) {
    return RestaurantModulesLight(
      ordering: moduleIds.contains('ordering'),
      delivery: moduleIds.contains('delivery'),
      clickAndCollect: moduleIds.contains('clickAndCollect'),
      payments: moduleIds.contains('payments'),
      loyalty: moduleIds.contains('loyalty'),
      roulette: moduleIds.contains('roulette'),
      kitchenTablet: moduleIds.contains('kitchen_tablet'),
      staffTablet: moduleIds.contains('staff_tablet'),
    );
  }

  /// Convertit un RestaurantModulesLight en liste de String module IDs.
  /// Note: Only extracts the 8 modules supported by RestaurantModulesLight.
  List<String> _modulesLightToModuleIds(RestaurantModulesLight modules) {
    final result = <String>[];
    if (modules.ordering) result.add('ordering');
    if (modules.delivery) result.add('delivery');
    if (modules.clickAndCollect) result.add('clickAndCollect');
    if (modules.payments) result.add('payments');
    if (modules.loyalty) result.add('loyalty');
    if (modules.roulette) result.add('roulette');
    if (modules.kitchenTablet) result.add('kitchen_tablet');
    if (modules.staffTablet) result.add('staff_tablet');
    return result;
  }

  /// Met à jour les modules activés (ancienne méthode pour compatibilité).
  void updateModules({
    bool? ordering,
    bool? delivery,
    bool? clickAndCollect,
    bool? payments,
    bool? loyalty,
    bool? roulette,
    bool? kitchenTablet,
    bool? staffTablet,
  }) {
    // Mettre à jour le blueprint
    final newModulesLight = state.blueprint.modules.copyWith(
      ordering: ordering,
      delivery: delivery,
      clickAndCollect: clickAndCollect,
      payments: payments,
      loyalty: loyalty,
      roulette: roulette,
      kitchenTablet: kitchenTablet,
      staffTablet: staffTablet,
    );
    
    state = state.copyWith(
      blueprint: state.blueprint.copyWith(modules: newModulesLight),
      enabledModuleIds: _modulesLightToModuleIds(newModulesLight),
    );
  }

  /// Remplace entièrement les modules.
  void setModules(RestaurantModulesLight modules) {
    state = state.copyWith(
      blueprint: state.blueprint.copyWith(modules: modules),
      enabledModuleIds: _modulesLightToModuleIds(modules),
    );
  }

  /// Passe à l'étape suivante.
  void nextStep() {
    if (!state.canGoNext) return;
    state = state.copyWith(currentStep: state.currentStep.next);
  }

  /// Revient à l'étape précédente.
  void previousStep() {
    if (!state.canGoBack) return;
    state = state.copyWith(currentStep: state.currentStep.previous);
  }

  /// Va directement à une étape spécifique.
  void goToStep(WizardStep step) {
    state = state.copyWith(currentStep: step);
  }

  /// Soumet le wizard et enregistre dans Firestore.
  /// 
  /// Crée le restaurant dans Firestore avec 3 documents:
  /// 1. restaurants/{id} - document principal
  /// 2. restaurants/{id}/plan/config - configuration des modules
  /// 3. restaurants/{id}/settings/branding - paramètres de marque
  Future<void> submit({String? ownerUserId}) async {
    if (!state.isReadyForCreation) {
      state = state.copyWith(error: 'La configuration n\'est pas complète');
      return;
    }

    // Valider les dépendances des modules
    if (!validateModuleDependencies(state.enabledModuleIds)) {
      final missing = getMissingDependencies(state.enabledModuleIds);
      final missingNames = missing.map(_getModuleName).join(', ');
      state = state.copyWith(
        error: 'Configuration incomplète: dépendances manquantes ($missingNames)',
      );
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // Génère un nouvel ID pour le restaurant
      final restaurantId = 'resto-${DateTime.now().millisecondsSinceEpoch}';

      // Prépare les données de marque
      final brandData = state.blueprint.brand.toJson();

      // Créer les 3 documents via RestaurantPlanService
      final planService = RestaurantPlanService();
      await planService.saveFullRestaurantCreation(
        restaurantId: restaurantId,
        name: state.blueprint.name,
        slug: state.blueprint.slug,
        enabledModuleIds: state.enabledModuleIds,
        brand: brandData,
        templateId: state.blueprint.templateId,
      );

      // Met à jour le blueprint avec l'ID généré
      final finalBlueprint = state.blueprint.copyWith(
        id: restaurantId,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(
        blueprint: finalBlueprint,
        isSubmitting: false,
        isCompleted: true,
      );

      if (kDebugMode) {
        print('Restaurant created successfully with ID: $restaurantId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting wizard: $e');
      }
      state = state.copyWith(
        isSubmitting: false,
        error: 'Erreur lors de la création: ${e.toString()}',
      );
    }
  }

  /// Soumet le wizard en mode mock (sans Firestore).
  /// Utile pour le développement et les tests.
  Future<void> submitMock() async {
    if (!state.isReadyForCreation) {
      state = state.copyWith(error: 'La configuration n\'est pas complète');
      return;
    }

    // Valider les dépendances des modules
    if (!validateModuleDependencies(state.enabledModuleIds)) {
      final missing = getMissingDependencies(state.enabledModuleIds);
      final missingNames = missing.map(_getModuleName).join(', ');
      state = state.copyWith(
        error: 'Configuration incomplète: dépendances manquantes ($missingNames)',
      );
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    // Simule un délai de sauvegarde
    await Future.delayed(const Duration(seconds: 1));

    // Génère un ID si nécessaire
    final finalBlueprint = state.blueprint.copyWith(
      id: state.blueprint.id.isEmpty
          ? 'resto-${DateTime.now().millisecondsSinceEpoch}'
          : null,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      blueprint: finalBlueprint,
      isSubmitting: false,
      isCompleted: true,
    );
  }

  /// Efface l'erreur.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider pour le wizard de création de restaurant.
/// Auto-dispose pour nettoyer l'état quand on quitte le wizard.
final restaurantWizardProvider =
    StateNotifierProvider.autoDispose<RestaurantWizardNotifier, RestaurantWizardState>(
  (ref) => RestaurantWizardNotifier(),
);
