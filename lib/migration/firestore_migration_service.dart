/// lib/migration/firestore_migration_service.dart
///
/// Service de migration Firestore pour corriger les incohérences identifiées.
///
/// Ce service effectue des migrations idempotentes et non-destructives pour:
/// 1. Créer les documents plan/unified manquants
/// 2. Normaliser les champs des restaurants
/// 3. Copier roulette_settings dans plan/unified
/// 4. Normaliser les champs utilisateurs
library;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../white_label/restaurant/restaurant_plan_unified.dart';
import 'migration_report.dart';

/// Service de migration Firestore.
///
/// Corrige les incohérences identifiées dans l'audit :
/// 1. Crée les documents plan/unified manquants
/// 2. Normalise les champs des restaurants
/// 3. Copie roulette_settings dans plan/unified
/// 4. Normalise les champs utilisateurs
///
/// Ce service est:
/// - **Idempotent** : peut être exécuté plusieurs fois sans effet secondaire
/// - **Non-destructif** : ne supprime jamais de données, ajoute seulement
/// - **Loggé** : affiche clairement ce qui est fait
class FirestoreMigrationService {
  final FirebaseFirestore _db;
  final void Function(String)? _logger;

  /// Couleur primaire par défaut pour les restaurants.
  static const String kDefaultPrimaryColor = '#D32F2F';

  /// Modules activés par défaut pour tous les restaurants.
  static const List<String> kDefaultModules = [
    'ordering',
    'promotions',
    'click_and_collect',
  ];

  /// Configuration par défaut de la roulette.
  static const int kDefaultCooldownHours = 24;
  static const String kDefaultLimitType = 'per_day';
  static const int kDefaultLimitValue = 1;

  /// Constructeur.
  ///
  /// [db] Instance Firestore (optionnel, pour tests).
  /// [logger] Fonction de logging (optionnel).
  FirestoreMigrationService({
    FirebaseFirestore? db,
    void Function(String)? logger,
  })  : _db = db ?? FirebaseFirestore.instance,
        _logger = logger;

  /// Log un message.
  void _log(String message) {
    _logger?.call(message);
    // ignore: avoid_print
    print('[Migration] $message');
  }

  /// Exécute toutes les migrations.
  ///
  /// [dryRun] Si true, simule les migrations sans écrire dans Firestore.
  ///
  /// Retourne un [MigrationReport] avec les statistiques et erreurs.
  Future<MigrationReport> runAllMigrations({bool dryRun = false}) async {
    final startTime = DateTime.now();
    _log('=== Starting Firestore Migration ===');
    _log('Mode: ${dryRun ? "DRY-RUN (simulation)" : "LIVE"}');

    final errors = <String>[];
    int restaurantPlansCreated = 0;
    int restaurantsNormalized = 0;
    int rouletteSettingsMigrated = 0;
    int usersNormalized = 0;
    int loyaltySettingsMigrated = 0;
    int rouletteSegmentsMigrated = 0;

    try {
      // Migration 1: Créer plan/unified pour tous les restaurants
      _log('\n--- Migration 1: Creating missing plan/unified documents ---');
      restaurantPlansCreated =
          await migrateRestaurantPlans(dryRun: dryRun, errors: errors);
      _log('✓ Plans created: $restaurantPlansCreated');

      // Migration 2: Normaliser les champs des restaurants
      _log('\n--- Migration 2: Normalizing restaurant fields ---');
      restaurantsNormalized =
          await normalizeRestaurantFields(dryRun: dryRun, errors: errors);
      _log('✓ Restaurants normalized: $restaurantsNormalized');

      // Migration 3: Copier roulette_settings dans plan/unified
      _log('\n--- Migration 3: Migrating roulette settings ---');
      rouletteSettingsMigrated =
          await migrateRouletteSettings(dryRun: dryRun, errors: errors);
      _log('✓ Roulette settings migrated: $rouletteSettingsMigrated');

      // Migration 4: Normaliser les champs utilisateurs
      _log('\n--- Migration 4: Normalizing user fields ---');
      usersNormalized =
          await normalizeUserFields(dryRun: dryRun, errors: errors);
      _log('✓ Users normalized: $usersNormalized');

      // Migration 5: Loyalty settings
      _log('\n--- Migration 5: Loyalty Settings ---');
      try {
        loyaltySettingsMigrated = await migrateLoyaltySettings(dryRun: dryRun, errors: errors);
        _log('✓ Migrated $loyaltySettingsMigrated loyalty settings');
      } catch (e) {
        errors.add('Migration 5 failed: $e');
        _log('✗ Migration 5 failed: $e');
      }

      // Migration 6: Roulette segments
      _log('\n--- Migration 6: Roulette Segments ---');
      try {
        rouletteSegmentsMigrated = await migrateRouletteSegments(dryRun: dryRun, errors: errors);
        _log('✓ Migrated $rouletteSegmentsMigrated roulette segments');
      } catch (e) {
        errors.add('Migration 6 failed: $e');
        _log('✗ Migration 6 failed: $e');
      }
    } catch (e) {
      final errorMsg = 'Unexpected error during migration: $e';
      _log('✗ $errorMsg');
      errors.add(errorMsg);
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);

    final report = MigrationReport(
      restaurantPlansCreated: restaurantPlansCreated,
      restaurantsNormalized: restaurantsNormalized,
      rouletteSettingsMigrated: rouletteSettingsMigrated,
      usersNormalized: usersNormalized,
      loyaltySettingsMigrated: loyaltySettingsMigrated,
      rouletteSegmentsMigrated: rouletteSegmentsMigrated,
      errors: errors,
      duration: duration,
      isDryRun: dryRun,
      startedAt: startTime,
      completedAt: endTime,
    );

    _log('\n${report.summary}');
    return report;
  }

  /// Migration 1: Créer plan/unified pour tous les restaurants.
  ///
  /// Pour chaque restaurant dans la collection 'restaurants',
  /// vérifie si plan/unified existe déjà. Si non, le crée avec
  /// des valeurs par défaut intelligentes basées sur les données existantes.
  Future<int> migrateRestaurantPlans({
    bool dryRun = false,
    List<String>? errors,
  }) async {
    int count = 0;

    try {
      // Récupérer tous les restaurants
      final restaurantsSnapshot = await _db.collection('restaurants').get();
      _log('Found ${restaurantsSnapshot.docs.length} restaurants');

      for (final restaurantDoc in restaurantsSnapshot.docs) {
        final restaurantId = restaurantDoc.id;
        final restaurantData = restaurantDoc.data();

        try {
          // Vérifier si plan/unified existe déjà
          final unifiedDocRef = _db
              .collection('restaurants')
              .doc(restaurantId)
              .collection('plan')
              .doc('unified');

          final unifiedDoc = await unifiedDocRef.get();

          if (!unifiedDoc.exists) {
            _log('  Creating plan/unified for restaurant: $restaurantId');

            // Détecter les modules actifs
            final activeModules =
                await _detectActiveModules(restaurantId, restaurantData);

            // Créer le plan unifié avec valeurs par défaut
            final unifiedPlan = RestaurantPlanUnified(
              restaurantId: restaurantId,
              name: restaurantData['name'] as String? ?? restaurantId,
              slug: restaurantData['slug'] as String? ?? restaurantId,
              templateId: restaurantData['templateId'] as String?,
              activeModules: activeModules,
              branding: BrandingConfig(
                brandName: restaurantData['name'] as String?,
                primaryColor: kDefaultPrimaryColor,
              ),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            if (!dryRun) {
              await unifiedDocRef.set(unifiedPlan.toJson());
            }
            count++;
            _log('  ✓ Created plan/unified for $restaurantId');
          } else {
            _log('  • plan/unified already exists for $restaurantId');
          }
        } catch (e) {
          final errorMsg =
              'Error creating plan/unified for $restaurantId: $e';
          _log('  ✗ $errorMsg');
          errors?.add(errorMsg);
        }
      }
    } catch (e) {
      final errorMsg = 'Error in migrateRestaurantPlans: $e';
      _log('✗ $errorMsg');
      errors?.add(errorMsg);
    }

    return count;
  }

  /// Détecte intelligemment les modules actifs pour un restaurant.
  ///
  /// Analyse les collections et documents existants pour déterminer
  /// quels modules devraient être activés par défaut.
  Future<List<String>> _detectActiveModules(
    String restaurantId,
    Map<String, dynamic> restaurantData,
  ) async {
    final modules = <String>[...kDefaultModules];

    try {
      // Vérifier si roulette_settings existe
      final rouletteDoc =
          await _db.collection('marketing').doc('roulette_settings').get();
      if (rouletteDoc.exists) {
        modules.add('roulette');
        _log('    • Detected roulette module');
      }

      // Vérifier si loyalty_settings existe (dans le restaurant ou globalement)
      final loyaltyDoc = await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('loyalty')
          .limit(1)
          .get();
      if (loyaltyDoc.docs.isNotEmpty) {
        modules.add('loyalty');
        _log('    • Detected loyalty module');
      }
    } catch (e) {
      _log('    ⚠ Warning: Error detecting modules for $restaurantId: $e');
    }

    return modules;
  }

  /// Migration 2: Normaliser les champs des restaurants.
  ///
  /// Pour chaque restaurant:
  /// - Normalise le statut en majuscules (ACTIVE, INACTIVE, PENDING)
  /// - S'assure que le champ 'id' existe (= doc.id)
  Future<int> normalizeRestaurantFields({
    bool dryRun = false,
    List<String>? errors,
  }) async {
    int count = 0;

    try {
      final restaurantsSnapshot = await _db.collection('restaurants').get();
      _log('Checking ${restaurantsSnapshot.docs.length} restaurants');

      for (final restaurantDoc in restaurantsSnapshot.docs) {
        final restaurantId = restaurantDoc.id;
        final data = restaurantDoc.data();

        try {
          final updates = <String, dynamic>{};

          // Normaliser le statut en majuscules
          final currentStatus = data['status'] as String?;
          if (currentStatus != null &&
              currentStatus != currentStatus.toUpperCase()) {
            updates['status'] = currentStatus.toUpperCase();
            _log('  • Normalizing status for $restaurantId: $currentStatus -> ${currentStatus.toUpperCase()}');
          }

          // S'assurer que 'id' existe
          if (data['id'] == null) {
            updates['id'] = restaurantId;
            _log('  • Adding id field for $restaurantId');
          }

          // Appliquer les mises à jour si nécessaire
          if (updates.isNotEmpty) {
            if (!dryRun) {
              await restaurantDoc.reference.update(updates);
            }
            count++;
            _log('  ✓ Normalized restaurant $restaurantId');
          }
        } catch (e) {
          final errorMsg = 'Error normalizing restaurant $restaurantId: $e';
          _log('  ✗ $errorMsg');
          errors?.add(errorMsg);
        }
      }
    } catch (e) {
      final errorMsg = 'Error in normalizeRestaurantFields: $e';
      _log('✗ $errorMsg');
      errors?.add(errorMsg);
    }

    return count;
  }

  /// Migration 3: Copier roulette_settings dans plan/unified.
  ///
  /// Lit les settings depuis marketing/roulette_settings et les copie
  /// dans le champ roulette de chaque plan/unified.
  /// Ne supprime pas l'ancien emplacement (rétrocompatibilité).
  Future<int> migrateRouletteSettings({
    bool dryRun = false,
    List<String>? errors,
  }) async {
    int count = 0;

    try {
      // Lire depuis marketing/roulette_settings
      final marketingSettingsDoc =
          await _db.collection('marketing').doc('roulette_settings').get();

      if (!marketingSettingsDoc.exists) {
        _log('No roulette_settings found in marketing collection');
        return 0;
      }

      final settings = marketingSettingsDoc.data()!;
      _log('Found roulette_settings in marketing collection');

      // Pour chaque restaurant avec plan/unified, mettre à jour le champ roulette
      final restaurantsSnapshot = await _db.collection('restaurants').get();

      for (final restaurantDoc in restaurantsSnapshot.docs) {
        final restaurantId = restaurantDoc.id;

        try {
          final unifiedDocRef = _db
              .collection('restaurants')
              .doc(restaurantId)
              .collection('plan')
              .doc('unified');

          final unifiedDoc = await unifiedDocRef.get();

          if (unifiedDoc.exists) {
            // Vérifier si roulette n'existe pas déjà ou est vide
            final currentData = unifiedDoc.data();
            final hasRouletteConfig = currentData?['roulette'] != null;

            if (!hasRouletteConfig) {
              final rouletteConfig = {
                'enabled': settings['isEnabled'] ?? true,
                'cooldownHours': settings['cooldownHours'] ?? kDefaultCooldownHours,
                'limitType': settings['limitType'] ?? kDefaultLimitType,
                'limitValue': settings['limitValue'] ?? kDefaultLimitValue,
                'settings': settings,
              };

              if (!dryRun) {
                await unifiedDocRef.update({'roulette': rouletteConfig});
              }
              count++;
              _log('  ✓ Migrated roulette settings for $restaurantId');
            } else {
              _log('  • Roulette config already exists for $restaurantId');
            }
          }
        } catch (e) {
          final errorMsg =
              'Error migrating roulette settings for $restaurantId: $e';
          _log('  ✗ $errorMsg');
          errors?.add(errorMsg);
        }
      }
    } catch (e) {
      final errorMsg = 'Error in migrateRouletteSettings: $e';
      _log('✗ $errorMsg');
      errors?.add(errorMsg);
    }

    return count;
  }

  /// Migration 4: Normaliser les champs utilisateurs.
  ///
  /// Pour chaque utilisateur:
  /// - Copie name vers displayName si displayName manque
  /// - Copie displayName vers name si name manque
  /// - Ajoute isAdmin=true si role='admin' et isAdmin manque
  Future<int> normalizeUserFields({
    bool dryRun = false,
    List<String>? errors,
  }) async {
    int count = 0;

    try {
      final usersSnapshot = await _db.collection('users').get();
      _log('Checking ${usersSnapshot.docs.length} users');

      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final data = userDoc.data();

        try {
          final updates = <String, dynamic>{};

          // Normaliser name/displayName
          if (data['name'] != null && data['displayName'] == null) {
            updates['displayName'] = data['name'];
            _log('  • Copying name -> displayName for user $userId');
          } else if (data['displayName'] != null && data['name'] == null) {
            updates['name'] = data['displayName'];
            _log('  • Copying displayName -> name for user $userId');
          }

          // S'assurer que isAdmin existe pour les admins
          if (data['role'] == 'admin' && data['isAdmin'] == null) {
            updates['isAdmin'] = true;
            _log('  • Adding isAdmin=true for admin user $userId');
          }

          // Appliquer les mises à jour si nécessaire
          if (updates.isNotEmpty) {
            if (!dryRun) {
              await userDoc.reference.update(updates);
            }
            count++;
            _log('  ✓ Normalized user $userId');
          }
        } catch (e) {
          final errorMsg = 'Error normalizing user $userId: $e';
          _log('  ✗ $errorMsg');
          errors?.add(errorMsg);
        }
      }
    } catch (e) {
      final errorMsg = 'Error in normalizeUserFields: $e';
      _log('✗ $errorMsg');
      errors?.add(errorMsg);
    }

    return count;
  }

  /// Migration 5: Copier loyalty_settings de la racine vers chaque restaurant.
  ///
  /// Source: loyalty_settings/main
  /// Destination: restaurants/{appId}/builder_settings/loyalty_settings
  ///
  /// Comportement:
  /// - Lit le document global loyalty_settings/main
  /// - Pour chaque restaurant, copie vers builder_settings/loyalty_settings
  /// - Ne crée pas si le document destination existe déjà (idempotent)
  /// - Ne supprime PAS le document source (rétrocompatibilité)
  Future<int> migrateLoyaltySettings({
    bool dryRun = false,
    List<String>? errors,
  }) async {
    int count = 0;

    try {
      // Lire le document source
      final sourceDoc = await _db.collection('loyalty_settings').doc('main').get();

      if (!sourceDoc.exists || sourceDoc.data() == null) {
        _log('ℹ️ No loyalty_settings/main found, skipping');
        return 0;
      }

      final sourceData = sourceDoc.data()!;
      _log('📋 Found loyalty_settings/main with ${sourceData.length} fields');

      // Récupérer tous les restaurants
      final restaurants = await _db.collection('restaurants').get();

      for (final restaurant in restaurants.docs) {
        final destRef = _db
            .collection('restaurants')
            .doc(restaurant.id)
            .collection('builder_settings')
            .doc('loyalty_settings');

        try {
          // Vérifier si existe déjà
          final existing = await destRef.get();
          if (existing.exists) {
            _log('  ⏭️ ${restaurant.id}: loyalty_settings already exists, skipping');
            continue;
          }

          if (!dryRun) {
            await destRef.set(sourceData);
          }

          _log('  ✅ ${restaurant.id}: loyalty_settings migrated');
          count++;
        } catch (e) {
          final errorMsg =
              'Error migrating loyalty_settings for ${restaurant.id}: $e';
          _log('  ✗ $errorMsg');
          errors?.add(errorMsg);
        }
      }
    } catch (e) {
      final errorMsg = 'Error in migrateLoyaltySettings: $e';
      _log('✗ $errorMsg');
      errors?.add(errorMsg);
    }

    return count;
  }

  /// Migration 6: Copier roulette_segments de la racine vers chaque restaurant.
  ///
  /// Source: roulette_segments/{segmentId}
  /// Destination: restaurants/{appId}/roulette_segments/{segmentId}
  ///
  /// Comportement:
  /// - Lit tous les documents de la collection roulette_segments (racine)
  /// - Pour chaque restaurant, copie tous les segments
  /// - Ne remplace pas si le segment existe déjà (merge)
  /// - Ne supprime PAS les documents source (rétrocompatibilité)
  Future<int> migrateRouletteSegments({
    bool dryRun = false,
    List<String>? errors,
  }) async {
    int count = 0;

    try {
      // Lire les segments source
      final sourceSegments = await _db.collection('roulette_segments').get();

      if (sourceSegments.docs.isEmpty) {
        _log('ℹ️ No roulette_segments found at root, skipping');
        return 0;
      }

      _log('📋 Found ${sourceSegments.docs.length} segments at root');

      // Récupérer tous les restaurants
      final restaurants = await _db.collection('restaurants').get();

      for (final restaurant in restaurants.docs) {
        _log('  📍 Processing ${restaurant.id}...');

        for (final segment in sourceSegments.docs) {
          final destRef = _db
              .collection('restaurants')
              .doc(restaurant.id)
              .collection('roulette_segments')
              .doc(segment.id);

          try {
            // Vérifier si existe déjà
            final existing = await destRef.get();
            if (existing.exists) {
              _log('    ⏭️ Segment ${segment.id} already exists, skipping');
              continue;
            }

            if (!dryRun) {
              await destRef.set(segment.data());
            }

            _log('    ✅ Segment ${segment.id} migrated');
            count++;
          } catch (e) {
            final errorMsg =
                'Error migrating segment ${segment.id} for ${restaurant.id}: $e';
            _log('    ✗ $errorMsg');
            errors?.add(errorMsg);
          }
        }
      }
    } catch (e) {
      final errorMsg = 'Error in migrateRouletteSegments: $e';
      _log('✗ $errorMsg');
      errors?.add(errorMsg);
    }

    return count;
  }
}
