// lib/builder/debug/builder_wl_diagnostic.dart
// Service de diagnostic pour les problèmes de propagation des modules
// entre SuperAdmin et Builder B3

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../white_label/core/module_id.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';
import '../../src/models/restaurant_config.dart';
import '../models/builder_block.dart';
import '../utils/builder_modules.dart' as builder_modules;

/// Résultat d'un test de diagnostic
class DiagnosticTestResult {
  final String testName;
  final bool passed;
  final String message;
  final Map<String, dynamic>? details;

  const DiagnosticTestResult({
    required this.testName,
    required this.passed,
    required this.message,
    this.details,
  });

  String get statusEmoji => passed ? '✅' : '❌';
}

/// Service de diagnostic pour Builder ↔ White-Label
class BuilderWLDiagnosticService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Exécuter tous les tests de diagnostic
  Future<List<DiagnosticTestResult>> runAllTests({
    required RestaurantConfig restaurantConfig,
    RestaurantPlanUnified? plan,
  }) async {
    final results = <DiagnosticTestResult>[];

    // Test 1: currentRestaurantProvider
    results.add(await _testRestaurantProvider(restaurantConfig));

    // Test 2: restaurantPlanUnifiedProvider
    results.add(_testPlanProvider(plan));

    // Test 3: Firestore direct
    if (restaurantConfig.id.isNotEmpty) {
      results.add(await _testFirestoreDirect(restaurantConfig.id));
    }

    // Test 4: moduleIdMapping
    results.add(_testModuleIdMapping());

    // Test 5: getFilteredModules
    results.add(_testGetFilteredModules(plan));

    // Test 6: Comparaison modules affichés vs actifs
    results.add(_testModuleComparison(plan));

    return results;
  }

  /// Test 1: Valider currentRestaurantProvider
  Future<DiagnosticTestResult> _testRestaurantProvider(
    RestaurantConfig config,
  ) async {
    if (config.id.isEmpty) {
      return DiagnosticTestResult(
        testName: 'Test 1: currentRestaurantProvider',
        passed: false,
        message: 'restaurantId est vide',
        details: {'restaurantId': config.id, 'name': config.name},
      );
    }

    return DiagnosticTestResult(
      testName: 'Test 1: currentRestaurantProvider',
      passed: true,
      message: 'restaurantId valide: ${config.id}',
      details: {'restaurantId': config.id, 'name': config.name},
    );
  }

  /// Test 2: Valider restaurantPlanUnifiedProvider
  DiagnosticTestResult _testPlanProvider(RestaurantPlanUnified? plan) {
    if (plan == null) {
      return const DiagnosticTestResult(
        testName: 'Test 2: restaurantPlanUnifiedProvider',
        passed: false,
        message: 'Plan est null - vérifiez que le document restaurants/{restaurantId}/plan/unified existe dans Firestore et que restaurantPlanUnifiedProvider charge correctement',
      );
    }

    final activeModulesCount = plan.activeModules.length;
    final modulesList = plan.activeModules.toList();

    return DiagnosticTestResult(
      testName: 'Test 2: restaurantPlanUnifiedProvider',
      passed: true,
      message: 'Plan chargé avec $activeModulesCount module(s) actif(s)',
      details: {
        'activeModulesCount': activeModulesCount,
        'activeModules': modulesList,
        'restaurantId': plan.restaurantId,
      },
    );
  }

  /// Test 3: Vérifier l'existence du document Firestore plan/unified
  Future<DiagnosticTestResult> _testFirestoreDirect(String restaurantId) async {
    try {
      final docRef = _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('plan')
          .doc('unified');

      final snapshot = await docRef.get();

      if (!snapshot.exists) {
        return DiagnosticTestResult(
          testName: 'Test 3: Document Firestore',
          passed: false,
          message: 'Document plan/unified n\'existe pas',
          details: {'path': docRef.path},
        );
      }

      final data = snapshot.data();
      final activeModules = (data?['activeModules'] as List?)?.cast<String>() ?? [];

      return DiagnosticTestResult(
        testName: 'Test 3: Document Firestore',
        passed: true,
        message: 'Document existe avec ${activeModules.length} module(s)',
        details: {
          'path': docRef.path,
          'activeModules': activeModules,
          'data': data,
        },
      );
    } catch (e) {
      return DiagnosticTestResult(
        testName: 'Test 3: Document Firestore',
        passed: false,
        message: 'Erreur lors de la lecture: $e',
      );
    }
  }

  /// Test 4: Valider que tous les modules ont un mapping
  DiagnosticTestResult _testModuleIdMapping() {
    final allModuleIds = ModuleId.values;
    final mappedModules = builder_modules.moduleIdMapping.values.toSet();
    final unmappedModules = <ModuleId>[];

    for (final moduleId in allModuleIds) {
      if (!mappedModules.contains(moduleId)) {
        unmappedModules.add(moduleId);
      }
    }

    // Modules legacy qui n'ont pas besoin de mapping
    final legacyModules = ['accountActivity'];

    final passed = unmappedModules.isEmpty;
    final message = passed
        ? 'Tous les modules sont mappés'
        : '${unmappedModules.length} module(s) sans mapping';

    return DiagnosticTestResult(
      testName: 'Test 4: Mapping des modules',
      passed: passed,
      message: message,
      details: {
        'totalModules': allModuleIds.length,
        'mappedCount': mappedModules.length,
        'unmappedModules': unmappedModules.map((m) => m.code).toList(),
        'legacyModules': legacyModules,
        'mapping': builder_modules.moduleIdMapping.map(
          (key, value) => MapEntry(key, value.code),
        ),
      },
    );
  }

  /// Test 5: Tester getFilteredModules
  DiagnosticTestResult _testGetFilteredModules(RestaurantPlanUnified? plan) {
    final allModules = SystemBlock.availableModules;
    final filteredModules = SystemBlock.getFilteredModules(plan);

    final planIsNull = plan == null;
    final filteringEffective = filteredModules.length < allModules.length;

    String message;
    if (planIsNull) {
      message = 'Plan null → fallback: tous les modules affichés (${allModules.length})';
    } else if (filteringEffective) {
      message = 'Filtrage effectif: ${filteredModules.length}/${allModules.length} modules';
    } else {
      message = 'Aucun filtrage: ${filteredModules.length}/${allModules.length} modules';
    }

    return DiagnosticTestResult(
      testName: 'Test 5: getFilteredModules()',
      passed: true, // Toujours passé, mais informatif
      message: message,
      details: {
        'planIsNull': planIsNull,
        'totalModules': allModules.length,
        'filteredCount': filteredModules.length,
        'filteredModules': filteredModules,
        'removedModules': allModules
            .where((m) => !filteredModules.contains(m))
            .toList(),
      },
    );
  }

  /// Test 6: Comparer modules affichés vs modules actifs
  DiagnosticTestResult _testModuleComparison(RestaurantPlanUnified? plan) {
    if (plan == null) {
      return const DiagnosticTestResult(
        testName: 'Test 6: Comparaison modules',
        passed: false,
        message: 'Plan null - impossible de comparer',
      );
    }

    final activeModuleCodes = plan.activeModules.toSet();
    final filteredModules = SystemBlock.getFilteredModules(plan);
    final displayedModules = <String>{};

    // Analyser chaque module affiché
    for (final moduleType in filteredModules) {
      final normalizedType = SystemBlock.normalizeModuleType(moduleType);
      final moduleId = builder_modules.getModuleIdForBuilder(normalizedType);

      if (moduleId != null) {
        if (plan.hasModule(moduleId)) {
          displayedModules.add(moduleType);
        }
      } else {
        // Module legacy sans mapping → toujours affiché
        displayedModules.add(moduleType);
      }
    }

    final correctlyFiltered = displayedModules.length <= filteredModules.length;
    final message = correctlyFiltered
        ? 'Filtrage cohérent: ${displayedModules.length} modules affichés'
        : 'Incohérence détectée dans le filtrage';

    return DiagnosticTestResult(
      testName: 'Test 6: Comparaison modules',
      passed: correctlyFiltered,
      message: message,
      details: {
        'activeModules': activeModuleCodes.toList(),
        'filteredModules': filteredModules,
        'displayedModules': displayedModules.toList(),
        'moduleMapping': builder_modules.moduleIdMapping.map(
          (key, value) => MapEntry(key, value.code),
        ),
      },
    );
  }

  /// Log détaillé des modules filtrés (pour debug console)
  void debugLogFilteredModules(
    String restaurantId,
    RestaurantPlanUnified? plan,
  ) {
    if (!kDebugMode) return;

    debugPrint('═══════════════════════════════════════════════');
    debugPrint('🔍 DEBUG: Modules filtrés pour $restaurantId');
    debugPrint('═══════════════════════════════════════════════');

    if (plan == null) {
      debugPrint('❌ Plan: null → fallback (tous les modules affichés)');
      debugPrint('');
      return;
    }

    debugPrint('✅ Plan chargé');
    debugPrint('   restaurantId: ${plan.restaurantId}');
    debugPrint('   activeModules: ${plan.activeModules.join(", ")}');
    debugPrint('');

    final allModules = SystemBlock.availableModules;
    debugPrint('📦 Analyse des ${allModules.length} modules disponibles:');
    debugPrint('');

    for (final moduleType in allModules) {
      final normalizedType = SystemBlock.normalizeModuleType(moduleType);
      final moduleId = builder_modules.getModuleIdForBuilder(normalizedType);

      String status;
      String reason;

      if (moduleId == null) {
        status = '✅';
        reason = 'legacy (toujours visible)';
      } else {
        if (plan.hasModule(moduleId)) {
          status = '✅';
          reason = 'enabled (${moduleId.code})';
        } else {
          status = '❌';
          reason = 'disabled (${moduleId.code})';
        }
      }

      debugPrint('  $status $moduleType → $reason');
    }

    debugPrint('═══════════════════════════════════════════════');
  }

  /// Valider le mapping des modules
  Map<String, dynamic> validateModuleMapping() {
    final allModuleIds = ModuleId.values;
    final builderModules = builder_modules.moduleIdMapping.keys.toList();
    final unmappedModules = <String>[];
    final mappingDetails = <String, String>{};

    // Vérifier chaque module builder
    for (final builderModule in builderModules) {
      final moduleId = builder_modules.getModuleIdForBuilder(builderModule);
      if (moduleId != null) {
        mappingDetails[builderModule] = moduleId.code;
      } else {
        unmappedModules.add(builderModule);
      }
    }

    // Modules WL non mappés
    final unmappedWLModules = <String>[];
    final mappedModuleIds = builder_modules.moduleIdMapping.values.toSet();
    for (final moduleId in allModuleIds) {
      if (!mappedModuleIds.contains(moduleId)) {
        unmappedWLModules.add(moduleId.code);
      }
    }

    return {
      'builderModulesCount': builderModules.length,
      'wlModulesCount': allModuleIds.length,
      'mappedCount': mappingDetails.length,
      'unmappedBuilderModules': unmappedModules,
      'unmappedWLModules': unmappedWLModules,
      'mapping': mappingDetails,
      'legacyModules': ['accountActivity'],
    };
  }
}
