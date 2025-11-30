/// lib/src/services/restaurant_plan_runtime_service.dart
///
/// Service runtime pour charger le RestaurantPlan depuis Firestore.
/// Ce service est utilisé côté client pour lire la configuration du restaurant.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../white_label/restaurant/restaurant_plan.dart';

/// Service pour charger le RestaurantPlan côté runtime (client).
///
/// Ce service utilise EXACTEMENT le même chemin Firestore que
/// [RestaurantPlanService] côté SuperAdmin:
///   restaurants/{restaurantId}/plan/config
///
/// Le SuperAdmin est responsable de créer/éditer le plan.
/// Ce service ne fait que lire.
class RestaurantPlanRuntimeService {
  final FirebaseFirestore _db;

  /// Constructeur.
  ///
  /// Permet d'injecter une instance de Firestore pour les tests.
  RestaurantPlanRuntimeService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Référence à la collection des restaurants.
  CollectionReference<Map<String, dynamic>> get _restaurantsCollection =>
      _db.collection('restaurants');

  /// Référence au document plan d'un restaurant.
  ///
  /// ATTENTION: Ce chemin doit être IDENTIQUE à celui utilisé
  /// par RestaurantPlanService côté SuperAdmin.
  /// Path: restaurants/{restaurantId}/plan/config
  DocumentReference<Map<String, dynamic>> _planDoc(String restaurantId) =>
      _restaurantsCollection.doc(restaurantId).collection('plan').doc('config');

  /// Charge le RestaurantPlan depuis Firestore.
  ///
  /// Retourne null si le document n'existe pas.
  /// Pas de logique de fallback ici : le superadmin est responsable
  /// de créer le plan initial.
  Future<RestaurantPlan?> loadPlan(String restaurantId) async {
    final doc = await _planDoc(restaurantId).get();
    if (!doc.exists) {
      return null;
    }
    final data = doc.data();
    if (data == null) return null;
    return RestaurantPlan.fromJson(data);
  }

  /// Stream pour écouter les changements du plan en temps réel.
  ///
  /// Retourne null si le document n'existe pas (via le map).
  Stream<RestaurantPlan?> watchPlan(String restaurantId) {
    return _planDoc(restaurantId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return RestaurantPlan.fromJson(doc.data()!);
    });
  }
}
