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
  /// LEGACY: Collection 'plan' avec document 'config'
  /// Path: restaurants/{restaurantId}/plan/config
  DocumentReference<Map<String, dynamic>> _planDoc(String restaurantId) =>
      _restaurantsCollection.doc(restaurantId).collection('plan').doc('config');

  /// Référence au document plan unifié d'un restaurant.
  /// 
  /// NOUVEAU: Document 'unified' dans la collection 'plan'
  /// Path: restaurants/{restaurantId}/plan/unified
  /// Contient le RestaurantPlanUnified avec toutes les configurations consolidées
  DocumentReference<Map<String, dynamic>> _planUnifiedDoc(String restaurantId) =>
      _restaurantsCollection.doc(restaurantId).collection('plan').doc('unified');

  /// Charge le RestaurantPlanUnified depuis Firestore.
  ///
  /// Cherche d'abord dans restaurants/{id}/plan/unified (nouveau format)
  /// Si non trouvé, retourne un plan par défaut.
  Future<RestaurantPlanUnified?> loadUnifiedPlan(String restaurantId) async {
    try {
      // Essayer de charger le plan unifié
      final unifiedDocRef = _planUnifiedDoc(restaurantId);
      final doc = await unifiedDocRef.get();

      if (doc.exists && doc.data() != null) {
        return RestaurantPlanUnified.fromJson(doc.data()!);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde le RestaurantPlanUnified dans Firestore.
  Future<void> saveUnifiedPlan(RestaurantPlanUnified plan) async {
    final unifiedDocRef = _planUnifiedDoc(plan.restaurantId);
    await unifiedDocRef.set(plan.toJson());
  }

  /// Stream pour écouter les changements du plan unifié en temps réel.
  Stream<RestaurantPlanUnified?> watchUnifiedPlan(String restaurantId) {
    final unifiedDocRef = _planUnifiedDoc(restaurantId);
    return unifiedDocRef.snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return RestaurantPlanUnified.fromJson(doc.data()!);
    });
  }

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
  /// Cette méthode crée les documents Firestore suivants:
  /// 1. restaurants/{id} - document principal du restaurant
  /// 2. restaurants/{id}/plan/unified - plan unifié (RestaurantPlanUnified)
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
      // Convertir les modules en codes
      final activeModules = enabledModuleIds.map((id) => id.code).toList();

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

      // Sauvegarder dans Firestore: restaurants/{id}/plan/unified
      final planDocRef = _planUnifiedDoc(restaurantId);
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
