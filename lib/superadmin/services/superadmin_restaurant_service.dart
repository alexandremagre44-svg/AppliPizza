/// lib/superadmin/services/superadmin_restaurant_service.dart
///
/// Service Firestore dédié au SuperAdmin pour gérer les restaurants multi-resto.
/// Gère la création, lecture, mise à jour et suppression des restaurants
/// via Firestore.
///
/// Structure Firestore:
/// - restaurants/{restaurantId}/metadata - Métadonnées du restaurant
/// - restaurants/{restaurantId}/blueprint_light - Blueprint léger du restaurant
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/restaurant_blueprint.dart';

/// Document de métadonnées d'un restaurant.
///
/// Stocké dans: `restaurants/{restaurantId}/metadata`
class RestaurantMetadataDocument {
  final String restaurantId;
  final String name;
  final String slug;
  final String type;
  final String? templateId;
  final String status;
  final List<String> ownerUserIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RestaurantMetadataDocument({
    required this.restaurantId,
    required this.name,
    required this.slug,
    required this.type,
    this.templateId,
    this.status = 'ACTIVE',
    this.ownerUserIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une instance depuis un document Firestore.
  factory RestaurantMetadataDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return RestaurantMetadataDocument(
        restaurantId: doc.id,
        name: '',
        slug: '',
        type: 'CUSTOM',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return RestaurantMetadataDocument(
      restaurantId: data['restaurantId'] as String? ?? doc.id,
      name: data['name'] as String? ?? '',
      slug: data['slug'] as String? ?? '',
      type: data['type'] as String? ?? 'CUSTOM',
      templateId: data['templateId'] as String?,
      status: data['status'] as String? ?? 'ACTIVE',
      ownerUserIds: (data['ownerUserIds'] as List?)?.cast<String>() ?? [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convertit l'instance en Map pour Firestore.
  Map<String, dynamic> toFirestore({bool isCreate = false}) {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'slug': slug,
      'type': type,
      if (templateId != null) 'templateId': templateId,
      'status': status,
      'ownerUserIds': ownerUserIds,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

/// Service Firestore pour la gestion des restaurants depuis le SuperAdmin.
class SuperadminRestaurantService {
  final FirebaseFirestore _firestore;

  /// Chemin de la collection principale.
  static const String collectionPath = 'restaurants';

  SuperadminRestaurantService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Référence à la collection restaurants.
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(collectionPath);

  // =========================================================================
  // CREATE
  // =========================================================================

  /// Crée un restaurant depuis un RestaurantBlueprintLight.
  ///
  /// Génère un nouveau restaurantId et crée deux documents:
  /// - restaurants/{id}/metadata
  /// - restaurants/{id}/blueprint_light
  ///
  /// Retourne l'ID du restaurant créé.
  Future<String> createRestaurantFromBlueprintLight(
    RestaurantBlueprintLight blueprint, {
    String? ownerUserId,
  }) async {
    try {
      // Génère un nouvel ID pour le restaurant
      final docRef = _collection.doc();
      final restaurantId = docRef.id;

      // Prépare le blueprint avec le nouvel ID
      final finalBlueprint = blueprint.copyWith(
        id: restaurantId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Batch write pour créer les deux documents atomiquement
      final batch = _firestore.batch();

      // Document metadata
      final metadataRef = docRef.collection('metadata').doc('main');
      batch.set(metadataRef, {
        'restaurantId': restaurantId,
        'name': finalBlueprint.name,
        'slug': finalBlueprint.slug,
        'type': finalBlueprint.type.value,
        if (finalBlueprint.templateId != null)
          'templateId': finalBlueprint.templateId,
        'status': 'ACTIVE',
        'ownerUserIds': ownerUserId != null ? [ownerUserId] : <String>[],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Document blueprint_light
      final blueprintRef = docRef.collection('blueprint_light').doc('main');
      batch.set(blueprintRef, _blueprintToFirestore(finalBlueprint));

      // Commit le batch
      await batch.commit();

      if (kDebugMode) {
        print(
            'SuperadminRestaurantService: Created restaurant $restaurantId');
      }

      return restaurantId;
    } catch (e) {
      if (kDebugMode) {
        print('SuperadminRestaurantService: Error creating restaurant: $e');
      }
      rethrow;
    }
  }

  // =========================================================================
  // READ
  // =========================================================================

  /// Récupère un RestaurantBlueprintLight par son ID.
  Future<RestaurantBlueprintLight?> getRestaurant(String restaurantId) async {
    try {
      final doc = await _collection
          .doc(restaurantId)
          .collection('blueprint_light')
          .doc('main')
          .get();

      if (!doc.exists) {
        return null;
      }

      return _blueprintFromFirestore(doc, restaurantId);
    } catch (e) {
      if (kDebugMode) {
        print('SuperadminRestaurantService: Error getting restaurant: $e');
      }
      return null;
    }
  }

  /// Récupère tous les restaurants.
  /// Retourne une liste de RestaurantBlueprintLight.
  Future<List<RestaurantBlueprintLight>> getAllRestaurants() async {
    try {
      final snapshot = await _collection.get();
      final restaurants = <RestaurantBlueprintLight>[];

      for (final doc in snapshot.docs) {
        final blueprintDoc = await doc.reference
            .collection('blueprint_light')
            .doc('main')
            .get();

        if (blueprintDoc.exists) {
          final blueprint = _blueprintFromFirestore(blueprintDoc, doc.id);
          if (blueprint != null) {
            restaurants.add(blueprint);
          }
        }
      }

      return restaurants;
    } catch (e) {
      if (kDebugMode) {
        print('SuperadminRestaurantService: Error getting all restaurants: $e');
      }
      return [];
    }
  }

  /// Stream de tous les restaurants.
  /// Met à jour en temps réel quand un restaurant est ajouté/modifié/supprimé.
  Stream<List<RestaurantBlueprintLight>> watchAllRestaurants() {
    return _collection.snapshots().asyncMap((snapshot) async {
      final restaurants = <RestaurantBlueprintLight>[];

      for (final doc in snapshot.docs) {
        try {
          final blueprintDoc = await doc.reference
              .collection('blueprint_light')
              .doc('main')
              .get();

          if (blueprintDoc.exists) {
            final blueprint = _blueprintFromFirestore(blueprintDoc, doc.id);
            if (blueprint != null) {
              restaurants.add(blueprint);
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error fetching blueprint for ${doc.id}: $e');
          }
        }
      }

      return restaurants;
    });
  }

  /// Récupère les métadonnées d'un restaurant.
  Future<RestaurantMetadataDocument?> getRestaurantMetadata(
      String restaurantId) async {
    try {
      final doc = await _collection
          .doc(restaurantId)
          .collection('metadata')
          .doc('main')
          .get();

      if (!doc.exists) {
        return null;
      }

      return RestaurantMetadataDocument.fromFirestore(doc);
    } catch (e) {
      if (kDebugMode) {
        print('SuperadminRestaurantService: Error getting metadata: $e');
      }
      return null;
    }
  }

  // =========================================================================
  // UPDATE
  // =========================================================================

  /// Met à jour un restaurant depuis un RestaurantBlueprintLight.
  Future<void> updateRestaurant(RestaurantBlueprintLight blueprint) async {
    try {
      final restaurantId = blueprint.id;
      final docRef = _collection.doc(restaurantId);

      final batch = _firestore.batch();

      // Update metadata
      final metadataRef = docRef.collection('metadata').doc('main');
      batch.update(metadataRef, {
        'name': blueprint.name,
        'slug': blueprint.slug,
        'type': blueprint.type.value,
        if (blueprint.templateId != null) 'templateId': blueprint.templateId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update blueprint_light
      final blueprintRef = docRef.collection('blueprint_light').doc('main');
      batch.update(blueprintRef, _blueprintToFirestore(blueprint));

      await batch.commit();

      if (kDebugMode) {
        print(
            'SuperadminRestaurantService: Updated restaurant $restaurantId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SuperadminRestaurantService: Error updating restaurant: $e');
      }
      rethrow;
    }
  }

  /// Met à jour le statut d'un restaurant.
  Future<void> updateRestaurantStatus(
      String restaurantId, String status) async {
    try {
      await _collection
          .doc(restaurantId)
          .collection('metadata')
          .doc('main')
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('SuperadminRestaurantService: Error updating status: $e');
      }
      rethrow;
    }
  }

  // =========================================================================
  // DELETE
  // =========================================================================

  /// Supprime un restaurant et tous ses sous-documents.
  Future<void> deleteRestaurant(String restaurantId) async {
    try {
      final docRef = _collection.doc(restaurantId);

      // Supprime les sous-collections
      final batch = _firestore.batch();

      // Delete metadata
      final metadataDoc =
          await docRef.collection('metadata').doc('main').get();
      if (metadataDoc.exists) {
        batch.delete(metadataDoc.reference);
      }

      // Delete blueprint_light
      final blueprintDoc =
          await docRef.collection('blueprint_light').doc('main').get();
      if (blueprintDoc.exists) {
        batch.delete(blueprintDoc.reference);
      }

      // Note: On ne supprime pas le document parent car Firestore le fait
      // automatiquement quand il n'y a plus de sous-collections

      await batch.commit();

      if (kDebugMode) {
        print(
            'SuperadminRestaurantService: Deleted restaurant $restaurantId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SuperadminRestaurantService: Error deleting restaurant: $e');
      }
      rethrow;
    }
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

  /// Convertit un RestaurantBlueprintLight en Map pour Firestore.
  Map<String, dynamic> _blueprintToFirestore(RestaurantBlueprintLight blueprint) {
    return {
      'id': blueprint.id,
      'name': blueprint.name,
      'slug': blueprint.slug,
      'type': blueprint.type.value,
      if (blueprint.templateId != null) 'templateId': blueprint.templateId,
      'brand': {
        'brandName': blueprint.brand.brandName,
        'primaryColor': blueprint.brand.primaryColor,
        'secondaryColor': blueprint.brand.secondaryColor,
        'accentColor': blueprint.brand.accentColor,
        if (blueprint.brand.logoUrl != null) 'logoUrl': blueprint.brand.logoUrl,
        if (blueprint.brand.appIconUrl != null)
          'appIconUrl': blueprint.brand.appIconUrl,
      },
      'modules': {
        'ordering': blueprint.modules.ordering,
        'delivery': blueprint.modules.delivery,
        'clickAndCollect': blueprint.modules.clickAndCollect,
        'payments': blueprint.modules.payments,
        'loyalty': blueprint.modules.loyalty,
        'roulette': blueprint.modules.roulette,
        'kitchenTablet': blueprint.modules.kitchenTablet,
        'staffTablet': blueprint.modules.staffTablet,
      },
      'createdAt': Timestamp.fromDate(blueprint.createdAt),
      if (blueprint.updatedAt != null)
        'updatedAt': Timestamp.fromDate(blueprint.updatedAt!),
    };
  }

  /// Crée un RestaurantBlueprintLight depuis un document Firestore.
  RestaurantBlueprintLight? _blueprintFromFirestore(
    DocumentSnapshot doc,
    String restaurantId,
  ) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    final brandData = data['brand'] as Map<String, dynamic>? ?? {};
    final modulesData = data['modules'] as Map<String, dynamic>? ?? {};

    return RestaurantBlueprintLight(
      id: data['id'] as String? ?? restaurantId,
      name: data['name'] as String? ?? '',
      slug: data['slug'] as String? ?? '',
      type: RestaurantTypeExtension.fromString(data['type'] as String?),
      templateId: data['templateId'] as String?,
      brand: RestaurantBrandLight(
        brandName: brandData['brandName'] as String? ?? '',
        primaryColor: brandData['primaryColor'] as String? ?? '#E63946',
        secondaryColor: brandData['secondaryColor'] as String? ?? '#1D3557',
        accentColor: brandData['accentColor'] as String? ?? '#F1FAEE',
        logoUrl: brandData['logoUrl'] as String?,
        appIconUrl: brandData['appIconUrl'] as String?,
      ),
      modules: RestaurantModulesLight(
        ordering: modulesData['ordering'] as bool? ?? false,
        delivery: modulesData['delivery'] as bool? ?? false,
        clickAndCollect: modulesData['clickAndCollect'] as bool? ?? false,
        payments: modulesData['payments'] as bool? ?? false,
        loyalty: modulesData['loyalty'] as bool? ?? false,
        roulette: modulesData['roulette'] as bool? ?? false,
        kitchenTablet: modulesData['kitchenTablet'] as bool? ?? false,
        staffTablet: modulesData['staffTablet'] as bool? ?? false,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Vérifie si un slug est déjà utilisé.
  Future<bool> isSlugAvailable(String slug, {String? excludeId}) async {
    try {
      final snapshot = await _collection.get();

      for (final doc in snapshot.docs) {
        if (excludeId != null && doc.id == excludeId) continue;

        final metadataDoc =
            await doc.reference.collection('metadata').doc('main').get();
        if (metadataDoc.exists) {
          final data = metadataDoc.data();
          if (data?['slug'] == slug) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('SuperadminRestaurantService: Error checking slug: $e');
      }
      return true; // En cas d'erreur, on autorise (sera validé côté serveur)
    }
  }
}
