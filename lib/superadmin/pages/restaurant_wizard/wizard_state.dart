/// lib/superadmin/pages/restaurant_wizard/wizard_state.dart
///
/// State management pour le Wizard de création de restaurant.
/// Utilise StateNotifier pour gérer l'état du formulaire multi-étapes.
/// Connecté à Firestore pour la persistance des données.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../white_label/core/module_id.dart';
import '../../../white_label/core/module_registry.dart';
import '../../models/restaurant_blueprint.dart';
import '../../services/superadmin_restaurant_service.dart';
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

  /// Liste des modules activés (basée sur ModuleId).
  final List<ModuleId> enabledModuleIds;

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
    List<ModuleId>? enabledModuleIds,
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

  /// Vérifie si l'étape courante est valide.
  bool get isCurrentStepValid {
    switch (currentStep) {
      case WizardStep.identity:
        return blueprint.name.isNotEmpty && blueprint.slug.isNotEmpty;
      case WizardStep.brand:
        return blueprint.brand.brandName.isNotEmpty;
      case WizardStep.template:
        return true; // Template est optionnel
      case WizardStep.modules:
        return validateModuleDependencies(enabledModuleIds);
      case WizardStep.preview:
        return blueprint.isValid && validateModuleDependencies(enabledModuleIds);
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

/// Valide les dépendances des modules.
/// Retourne true si toutes les dépendances sont satisfaites.
bool validateModuleDependencies(List<ModuleId> modules) {
  for (final moduleId in modules) {
    final definition = ModuleRegistry.definitions[moduleId];
    if (definition != null) {
      for (final dep in definition.dependencies) {
        if (!modules.contains(dep)) {
          return false;
        }
      }
    }
  }
  return true;
}

/// Récupère les dépendances manquantes pour une liste de modules.
List<ModuleId> getMissingDependencies(List<ModuleId> modules) {
  final missing = <ModuleId>[];
  for (final moduleId in modules) {
    final definition = ModuleRegistry.definitions[moduleId];
    if (definition != null) {
      for (final dep in definition.dependencies) {
        if (!modules.contains(dep) && !missing.contains(dep)) {
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

  /// Réinitialise le wizard.
  void reset() {
    state = RestaurantWizardState.initial();
  }

  /// Met à jour l'identité du restaurant.
  void updateIdentity({
    String? id,
    String? name,
    String? slug,
    RestaurantType? type,
  }) {
    state = state.copyWith(
      blueprint: state.blueprint.copyWith(
        id: id,
        name: name,
        slug: slug,
        type: type,
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

  /// Sélectionne un template et applique ses modules.
  void selectTemplate(RestaurantTemplate template) {
    // Mettre à jour le template ID et les modules activés
    state = state.copyWith(
      blueprint: state.blueprint.copyWith(
        templateId: template.id,
        modules: _moduleIdsToModulesLight(template.modules),
      ),
      enabledModuleIds: List<ModuleId>.from(template.modules),
    );
  }

  /// Active ou désactive un module par son ID.
  void toggleModule(ModuleId moduleId, bool enabled) {
    final currentModules = List<ModuleId>.from(state.enabledModuleIds);
    
    if (enabled) {
      if (!currentModules.contains(moduleId)) {
        currentModules.add(moduleId);
        // Ajouter automatiquement les dépendances requises
        final definition = ModuleRegistry.definitions[moduleId];
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
        final def = ModuleRegistry.definitions[m];
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
  void setEnabledModules(List<ModuleId> moduleIds) {
    state = state.copyWith(
      enabledModuleIds: moduleIds,
      blueprint: state.blueprint.copyWith(
        modules: _moduleIdsToModulesLight(moduleIds),
      ),
    );
  }

  /// Convertit une liste de ModuleId en RestaurantModulesLight.
  /// Note: RestaurantModulesLight only supports 8 modules currently.
  /// Additional ModuleId values are stored in enabledModuleIds for future use.
  RestaurantModulesLight _moduleIdsToModulesLight(List<ModuleId> moduleIds) {
    return RestaurantModulesLight(
      ordering: moduleIds.contains(ModuleId.ordering),
      delivery: moduleIds.contains(ModuleId.delivery),
      clickAndCollect: moduleIds.contains(ModuleId.clickAndCollect),
      payments: moduleIds.contains(ModuleId.payments),
      loyalty: moduleIds.contains(ModuleId.loyalty),
      roulette: moduleIds.contains(ModuleId.roulette),
      kitchenTablet: moduleIds.contains(ModuleId.kitchenTablet),
      staffTablet: moduleIds.contains(ModuleId.staffTablet),
    );
  }

  /// Convertit un RestaurantModulesLight en liste de ModuleId.
  /// Note: Only extracts the 8 modules supported by RestaurantModulesLight.
  List<ModuleId> _modulesLightToModuleIds(RestaurantModulesLight modules) {
    final result = <ModuleId>[];
    if (modules.ordering) result.add(ModuleId.ordering);
    if (modules.delivery) result.add(ModuleId.delivery);
    if (modules.clickAndCollect) result.add(ModuleId.clickAndCollect);
    if (modules.payments) result.add(ModuleId.payments);
    if (modules.loyalty) result.add(ModuleId.loyalty);
    if (modules.roulette) result.add(ModuleId.roulette);
    if (modules.kitchenTablet) result.add(ModuleId.kitchenTablet);
    if (modules.staffTablet) result.add(ModuleId.staffTablet);
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
  /// Crée le restaurant dans Firestore via SuperadminRestaurantService,
  /// puis met à jour l'état avec le blueprint final et l'ID généré.
  Future<void> submit({String? ownerUserId}) async {
    if (!state.blueprint.isValid) {
      state = state.copyWith(error: 'Le blueprint n\'est pas valide');
      return;
    }

    // Valider les dépendances des modules
    if (!validateModuleDependencies(state.enabledModuleIds)) {
      final missing = getMissingDependencies(state.enabledModuleIds);
      final missingNames = missing.map((m) => m.label).join(', ');
      state = state.copyWith(
        error: 'Configuration incomplète: dépendances manquantes ($missingNames)',
      );
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      // Crée le service Firestore
      final service = SuperadminRestaurantService();

      // Crée le restaurant dans Firestore
      final restaurantId = await service.createRestaurantFromBlueprintLight(
        state.blueprint,
        ownerUserId: ownerUserId,
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
    if (!state.blueprint.isValid) {
      state = state.copyWith(error: 'Le blueprint n\'est pas valide');
      return;
    }

    // Valider les dépendances des modules
    if (!validateModuleDependencies(state.enabledModuleIds)) {
      final missing = getMissingDependencies(state.enabledModuleIds);
      final missingNames = missing.map((m) => m.label).join(', ');
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
