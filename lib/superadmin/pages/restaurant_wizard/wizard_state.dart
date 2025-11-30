/// lib/superadmin/pages/restaurant_wizard/wizard_state.dart
///
/// State management pour le Wizard de création de restaurant.
/// Utilise StateNotifier pour gérer l'état du formulaire multi-étapes.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/restaurant_blueprint.dart';

/// Étapes du wizard.
enum WizardStep {
  /// Étape 1: Identité du restaurant (nom, slug, type).
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
        return 'Définissez le nom et le type de votre restaurant';
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
    this.currentStep = WizardStep.identity,
    this.isSubmitting = false,
    this.error,
    this.isCompleted = false,
  });

  /// Factory pour créer un état initial vide.
  factory RestaurantWizardState.initial() {
    return RestaurantWizardState(
      blueprint: RestaurantBlueprintLight.empty(),
    );
  }

  /// Crée une copie avec des valeurs modifiées.
  RestaurantWizardState copyWith({
    RestaurantBlueprintLight? blueprint,
    WizardStep? currentStep,
    bool? isSubmitting,
    String? error,
    bool? isCompleted,
  }) {
    return RestaurantWizardState(
      blueprint: blueprint ?? this.blueprint,
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
        return true; // Modules peuvent être tous désactivés
      case WizardStep.preview:
        return blueprint.isValid;
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

  /// Met à jour les modules activés.
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
    state = state.copyWith(
      blueprint: state.blueprint.copyWith(
        modules: state.blueprint.modules.copyWith(
          ordering: ordering,
          delivery: delivery,
          clickAndCollect: clickAndCollect,
          payments: payments,
          loyalty: loyalty,
          roulette: roulette,
          kitchenTablet: kitchenTablet,
          staffTablet: staffTablet,
        ),
      ),
    );
  }

  /// Remplace entièrement les modules.
  void setModules(RestaurantModulesLight modules) {
    state = state.copyWith(
      blueprint: state.blueprint.copyWith(modules: modules),
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

  /// Soumet le wizard (mock - simule une sauvegarde).
  Future<void> submit() async {
    if (!state.blueprint.isValid) {
      state = state.copyWith(error: 'Le blueprint n\'est pas valide');
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
