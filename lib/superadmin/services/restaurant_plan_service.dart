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

  /// Sauvegarde complète lors de la création d'un restaurant via le wizard.
  /// 
  /// Cette méthode crée 3 documents Firestore:
  /// 1. restaurants/{id} - document principal du restaurant
  /// 2. restaurants/{id}/plan/config - configuration des modules (RestaurantPlan)
  /// 3. restaurants/{id}/settings/branding - paramètres de marque
  /// 
  /// Paramètres:
  /// - restaurantId: ID du restaurant à créer
  /// - name: Nom du restaurant
  /// - slug: Slug URL-friendly
  /// - enabledModuleIds: Liste des modules activés
  /// - brand: Configuration de la marque (Map avec brandName, colors, etc.)
  /// - templateId: ID du template utilisé (optionnel)
  /// 
  /// Retourne l'ID du restaurant créé.
  Future<String> saveFullRestaurantCreation({
    required String restaurantId,
    required String name,
    required String slug,
    required List<ModuleId> enabledModuleIds,
    required Map<String, dynamic> brand,
    String? templateId,
  }) async {
    try {
      // Préparer les configurations de modules
      final moduleConfigs = enabledModuleIds.map((moduleId) {
        return ModuleConfig(
          id: moduleId,
          enabled: true,
          settings: {},
        );
      }).toList();

      // Créer le RestaurantPlan
      final plan = RestaurantPlan(
        restaurantId: restaurantId,
        name: name,
        slug: slug,
        modules: moduleConfigs,
      );

      // Batch write pour créer les 3 documents atomiquement
      final batch = _db.batch();

      // 1. Document principal restaurants/{id}
      final mainDocRef = _restaurantsCollection.doc(restaurantId);
      batch.set(mainDocRef, {
        'restaurantId': restaurantId,
        'name': name,
        'slug': slug,
        if (templateId != null) 'templateId': templateId,
        'status': 'ACTIVE',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Document restaurants/{id}/plan/config
      final planDocRef = _planDoc(restaurantId);
      batch.set(planDocRef, plan.toJson());

      // 3. Document restaurants/{id}/settings/branding
      final brandingDocRef = mainDocRef.collection('settings').doc('branding');
      batch.set(brandingDocRef, {
        ...brand,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Commit le batch
      await batch.commit();

      return restaurantId;
    } catch (e) {
      throw Exception('Erreur lors de la création du restaurant: $e');
    }
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
