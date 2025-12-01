/// lib/superadmin/providers/superadmin_restaurants_provider.dart
///
/// Providers Riverpod pour les données Firestore des restaurants.
/// Remplace les mocks pour afficher les vraies données depuis Firestore.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/restaurant_meta.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';
import '../services/restaurant_plan_service.dart';

// =============================================================================
// Service Provider
// =============================================================================

/// Provider pour le service de gestion des plans de restaurant.
final restaurantPlanServiceProvider = Provider<RestaurantPlanService>((ref) {
  return RestaurantPlanService();
});

// =============================================================================
// Restaurants List Provider
// =============================================================================

/// Modèle léger pour afficher un restaurant dans la liste SuperAdmin.
class SuperAdminRestaurantSummary {
  final String id;
  final String name;
  final String slug;
  final RestaurantStatus status;
  final String? templateId;
  final DateTime createdAt;
  final bool hasUnifiedPlan;

  const SuperAdminRestaurantSummary({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    this.templateId,
    required this.createdAt,
    this.hasUnifiedPlan = false,
  });

  /// Crée une instance depuis un document Firestore.
  factory SuperAdminRestaurantSummary.fromFirestore(
    String docId,
    Map<String, dynamic> data,
  ) {
    return SuperAdminRestaurantSummary(
      id: docId,
      name: data['name'] as String? ?? '',
      slug: data['slug'] as String? ?? '',
      status: RestaurantStatusExtension.fromString(data['status'] as String?),
      templateId: data['templateId'] as String?,
      createdAt: _parseTimestamp(data['createdAt']),
      hasUnifiedPlan: false, // Sera déterminé séparément si nécessaire
    );
  }

  /// Parse un Timestamp Firestore ou une date ISO en DateTime.
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

/// Provider qui stream la liste des restaurants depuis Firestore.
///
/// Source: /restaurants (collection root)
/// Tri: par date de création (desc)
final superAdminRestaurantsProvider =
    StreamProvider<List<SuperAdminRestaurantSummary>>((ref) {
  final db = FirebaseFirestore.instance;

  return db
      .collection('restaurants')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return SuperAdminRestaurantSummary.fromFirestore(
        doc.id,
        doc.data(),
      );
    }).toList();
  });
});

// =============================================================================
// Restaurant Detail Providers
// =============================================================================

/// Provider qui stream un document restaurant depuis Firestore.
///
/// Retourne null si le restaurant n'existe pas.
final superAdminRestaurantDocProvider =
    StreamProvider.family<RestaurantMeta?, String>((ref, restaurantId) {
  final db = FirebaseFirestore.instance;

  return db.collection('restaurants').doc(restaurantId).snapshots().map((doc) {
    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;
    return RestaurantMeta.fromMap({
      'id': doc.id,
      ...data,
    });
  });
});

/// Provider qui stream le plan unifié d'un restaurant depuis Firestore.
///
/// Path: /restaurants/{restaurantId}/plan/unified
/// Retourne null si le plan n'existe pas.
final superAdminRestaurantUnifiedPlanProvider =
    StreamProvider.family<RestaurantPlanUnified?, String>(
        (ref, restaurantId) {
  final service = ref.watch(restaurantPlanServiceProvider);
  return service.watchUnifiedPlan(restaurantId);
});
