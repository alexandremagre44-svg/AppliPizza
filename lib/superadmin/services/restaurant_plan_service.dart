/// lib/superadmin/services/restaurant_plan_service.dart
///
/// Service pour gérer les RestaurantPlan via Firestore.
/// Permet de charger et enregistrer les configurations de modules par restaurant.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../white_label/core/module_id.dart';
import '../../white_label/core/module_config.dart';
import '../../white_label/core/module_registry.dart';
import '../../white_label/restaurant/restaurant_plan.dart';

/// Service pour gérer les plans de restaurant (modules activés/désactivés).
///
/// La configuration est stockée dans Firestore dans :
///   restaurants/{restaurantId}/plan
/// sous la forme d'un seul document par restaurant.
class RestaurantPlanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Référence à la collection des restaurants.
  CollectionReference<Map<String, dynamic>> get _restaurantsCollection =>
      _db.collection('restaurants');

  /// Référence au document plan d'un restaurant.
  DocumentReference<Map<String, dynamic>> _planDoc(String restaurantId) =>
      _restaurantsCollection.doc(restaurantId).collection('plan').doc('config');

  /// Charge le RestaurantPlan depuis Firestore.
  ///
  /// Si le document n'existe pas, retourne un plan par défaut avec tous les
  /// modules désactivés.
  Future<RestaurantPlan> loadPlan(String restaurantId) async {
    try {
      final doc = await _planDoc(restaurantId).get();

      if (!doc.exists || doc.data() == null) {
        // Retourner un plan par défaut avec tous les modules désactivés
        return _createDefaultPlan(restaurantId);
      }

      return RestaurantPlan.fromJson(doc.data()!);
    } catch (e) {
      // En cas d'erreur, retourner un plan par défaut
      return _createDefaultPlan(restaurantId);
    }
  }

  /// Crée un plan par défaut avec tous les modules désactivés.
  RestaurantPlan _createDefaultPlan(String restaurantId) {
    final defaultModules = ModuleId.values.map((id) {
      return ModuleConfig(
        id: id,
        enabled: false,
        settings: {},
      );
    }).toList();

    return RestaurantPlan(
      restaurantId: restaurantId,
      name: '', // Sera rempli par le restaurant
      slug: '', // Sera rempli par le restaurant
      modules: defaultModules,
    );
  }

  /// Enregistre le RestaurantPlan dans Firestore.
  Future<void> savePlan(RestaurantPlan plan) async {
    await _planDoc(plan.restaurantId).set(plan.toJson());
  }

  /// Met à jour un seul module dans le plan.
  Future<void> updateModuleConfig(
    String restaurantId,
    ModuleConfig config,
  ) async {
    final plan = await loadPlan(restaurantId);
    
    // Trouver et remplacer le module existant ou l'ajouter
    final modules = List<ModuleConfig>.from(plan.modules);
    final existingIndex = modules.indexWhere((m) => m.id == config.id);
    
    if (existingIndex >= 0) {
      modules[existingIndex] = config;
    } else {
      modules.add(config);
    }
    
    final updatedPlan = plan.copyWith(modules: modules);
    await savePlan(updatedPlan);
  }

  /// Active ou désactive un module.
  Future<void> toggleModule(
    String restaurantId,
    ModuleId moduleId,
    bool enabled,
  ) async {
    final plan = await loadPlan(restaurantId);
    
    final modules = List<ModuleConfig>.from(plan.modules);
    final existingIndex = modules.indexWhere((m) => m.id == moduleId);
    
    if (existingIndex >= 0) {
      modules[existingIndex] = modules[existingIndex].copyWith(enabled: enabled);
    } else {
      modules.add(ModuleConfig(
        id: moduleId,
        enabled: enabled,
        settings: {},
      ));
    }
    
    final updatedPlan = plan.copyWith(modules: modules);
    await savePlan(updatedPlan);
  }

  /// Stream pour écouter les changements du plan en temps réel.
  Stream<RestaurantPlan> watchPlan(String restaurantId) {
    return _planDoc(restaurantId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return _createDefaultPlan(restaurantId);
      }
      return RestaurantPlan.fromJson(doc.data()!);
    });
  }

  /// Vérifie si un module a des dépendances non satisfaites.
  List<ModuleId> checkDependencies(RestaurantPlan plan, ModuleId moduleId) {
    final definition = ModuleRegistry.of(moduleId);
    final missingDeps = <ModuleId>[];

    for (final depId in definition.dependencies) {
      if (!plan.hasModule(depId)) {
        missingDeps.add(depId);
      }
    }

    return missingDeps;
  }

  /// Retourne les modules qui dépendent d'un module donné.
  List<ModuleId> getDependentModules(RestaurantPlan plan, ModuleId moduleId) {
    final dependents = <ModuleId>[];

    for (final module in plan.enabledModules) {
      final definition = ModuleRegistry.of(module.id);
      if (definition.dependencies.contains(moduleId)) {
        dependents.add(module.id);
      }
    }

    return dependents;
  }
}
