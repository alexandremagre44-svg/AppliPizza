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
                primaryColor: '#D32F2F',
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
    final modules = <String>['ordering']; // Toujours actif par défaut

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

      // Ajouter les modules de base
      modules.addAll(['promotions', 'click_and_collect']);
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
                'cooldownHours': settings['cooldownHours'] ?? 24,
                'limitType': settings['limitType'] ?? 'per_day',
                'limitValue': settings['limitValue'] ?? 1,
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
}
