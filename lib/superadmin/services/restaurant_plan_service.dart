/// lib/superadmin/services/restaurant_plan_service.dart
///
/// Service pour gérer les RestaurantPlan via Firestore.
/// Permet de charger et enregistrer les configurations de modules par restaurant.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../white_label/core/module_config.dart';
import '../../white_label/core/module_registry.dart';
import '../../white_label/restaurant/restaurant_plan.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';

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
  /// 
  /// Path: restaurants/{restaurantId}/plan/config
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
    final defaultModules = ModuleRegistry.definitions.keys.map((id) {
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
  /// 
  /// @deprecated This method is deprecated and will be removed in a future version.
  /// Use updateModule(restaurantId, moduleId, enabled) instead.
  /// Example: updateModule(restaurantId, "delivery", true)
  Future<void> toggleModule(
    String restaurantId,
    String moduleId,
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
  /// Cette méthode crée les documents Firestore suivants:
  /// 1. restaurants/{id} - document principal du restaurant
  /// 2. restaurants/{id}/plan/config - plan unifié (RestaurantPlanUnified)
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
    required List<String> enabledModuleIds,
    required Map<String, dynamic> brand,
    String? templateId,
  }) async {
    try {
      // Use module IDs directly as they are already strings
      final activeModules = enabledModuleIds;

      // Créer la configuration de branding depuis le map
      final branding = BrandingConfig(
        brandName: brand['brandName'] as String?,
        primaryColor: brand['primaryColor'] as String?,
        secondaryColor: brand['secondaryColor'] as String?,
        accentColor: brand['accentColor'] as String?,
        backgroundColor: brand['backgroundColor'] as String?,
        logoUrl: brand['logoUrl'] as String?,
        squareLogoUrl: brand['squareLogoUrl'] as String?,
        faviconUrl: brand['faviconUrl'] as String?,
        fontFamily: brand['fontFamily'] as String?,
        darkModeEnabled: brand['darkModeEnabled'] as bool? ?? false,
        borderRadius: (brand['borderRadius'] as num?)?.toDouble(),
      );

      // Créer le RestaurantPlanUnified
      final unifiedPlan = RestaurantPlanUnified(
        restaurantId: restaurantId,
        name: name,
        slug: slug,
        templateId: templateId,
        activeModules: activeModules,
        branding: branding,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Sauvegarder dans Firestore: restaurants/{id}/plan/config
      final planDocRef = _planDoc(restaurantId);
      await planDocRef.set(unifiedPlan.toJson());

      // Créer aussi le document principal du restaurant pour compatibilité
      final mainDocRef = _restaurantsCollection.doc(restaurantId);
      await mainDocRef.set({
        'restaurantId': restaurantId,
        'name': name,
        'slug': slug,
        if (templateId != null) 'templateId': templateId,
        'status': 'ACTIVE',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return restaurantId;
    } catch (e) {
      throw Exception('Erreur lors de la création du restaurant: $e');
    }
  }

  /// Vérifie si un module a des dépendances non satisfaites.
  List<String> checkDependencies(RestaurantPlan plan, String moduleId) {
    final definition = ModuleRegistry.ofString(moduleId);
    if (definition == null) return [];
    
    final missingDeps = <String>[];

    for (final depId in definition.dependencies) {
      if (!plan.hasModule(depId)) {
        missingDeps.add(depId);
      }
    }

    return missingDeps;
  }

  /// Retourne les modules qui dépendent d'un module donné.
  List<String> getDependentModules(RestaurantPlan plan, String moduleId) {
    final dependents = <String>[];

    for (final module in plan.enabledModules) {
      final definition = ModuleRegistry.ofString(module.id);
      if (definition != null && definition.dependencies.contains(moduleId)) {
        dependents.add(module.id);
      }
    }

    return dependents;
  }

  /// Stream pour écouter les changements du plan unifié en temps réel.
  /// 
  /// Path: restaurants/{restaurantId}/plan/config
  /// Retourne null si le document n'existe pas.
  Stream<RestaurantPlanUnified?> watchConfigPlan(String restaurantId) {
    return _planDoc(restaurantId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      try {
        return RestaurantPlanUnified.fromJson(doc.data()!);
      } catch (e) {
        // Si le parsing échoue, retourner null
        return null;
      }
    });
  }

  /// Met à jour l'état enabled/disabled d'un module.
  /// 
  /// moduleId doit être un String (ex: "delivery", "loyalty")
  Future<void> updateModule(
    String restaurantId,
    String moduleId,
    bool enabled,
  ) async {
    final docRef = _planDoc(restaurantId);
    final doc = await docRef.get();
    
    if (!doc.exists || doc.data() == null) {
      // Créer un nouveau document avec le module
      final newPlan = RestaurantPlanUnified(
        restaurantId: restaurantId,
        name: '',
        slug: '',
        modules: [
          ModuleConfig(
            id: moduleId,
            enabled: enabled,
            settings: {},
          ),
        ],
        activeModules: enabled ? [moduleId] : [],
      );
      await docRef.set(newPlan.toJson());
      return;
    }

    // Charger le plan existant
    final plan = RestaurantPlanUnified.fromJson(doc.data()!);
    
    // Mettre à jour ou ajouter le module
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
    
    // Recalculer activeModules
    final activeModules = modules
        .where((m) => m.enabled)
        .map((m) => m.id)
        .toList();
    
    // Sauvegarder
    final updatedPlan = plan.copyWith(
      modules: modules,
      activeModules: activeModules,
      updatedAt: DateTime.now(),
    );
    
    await docRef.set(updatedPlan.toJson());
  }

  /// Met à jour les settings d'un module spécifique.
  /// 
  /// moduleId doit être un String (ex: "delivery", "loyalty")
  Future<void> updateModuleSettings(
    String restaurantId,
    String moduleId,
    Map<String, dynamic> settings,
  ) async {
    final docRef = _planDoc(restaurantId);
    final doc = await docRef.get();
    
    if (!doc.exists || doc.data() == null) {
      throw Exception('Restaurant plan not found for $restaurantId');
    }

    final plan = RestaurantPlanUnified.fromJson(doc.data()!);
    
    // Mettre à jour les settings du module
    final modules = List<ModuleConfig>.from(plan.modules);
    final existingIndex = modules.indexWhere((m) => m.id == moduleId);
    
    if (existingIndex >= 0) {
      modules[existingIndex] = modules[existingIndex].copyWith(settings: settings);
    } else {
      // Créer le module s'il n'existe pas
      modules.add(ModuleConfig(
        id: moduleId,
        enabled: false,
        settings: settings,
      ));
    }
    
    // Sauvegarder
    final updatedPlan = plan.copyWith(
      modules: modules,
      updatedAt: DateTime.now(),
    );
    
    await docRef.set(updatedPlan.toJson());
  }
}
