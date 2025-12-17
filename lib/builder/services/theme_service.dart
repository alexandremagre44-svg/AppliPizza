// lib/builder/services/theme_service.dart
// Service for managing ThemeConfig in Firestore
//
// Firestore structure:
// restaurants/{appId}/theme_draft (single document)
// restaurants/{appId}/theme_published (single document)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_config.dart';
import '../../white_label/core/module_id.dart';
import '../../white_label/restaurant/restaurant_plan_unified.dart';

/// Service for managing Builder theme configuration in Firestore
///
/// ⚠️ DEPRECATED - THEME MANAGEMENT IS NOW DONE VIA SUPERADMIN ⚠️
///
/// This service is NO LONGER USED for global application theming.
/// Global theme is now managed through:
/// - SuperAdmin > Restaurant Theme page
/// - RestaurantPlanUnified.theme.settings (top-level field)
/// - white_label/theme/unified_theme_provider.dart
///
/// This service is kept for backward compatibility with existing blocks
/// that may read ThemeConfig for block-level styling, but it should NOT
/// be used to modify the global application theme.
///
/// Firestore structure (LEGACY - DO NOT USE FOR NEW CODE):
/// ```
/// restaurants/{appId}/theme_draft     (single document) - DEPRECATED
/// restaurants/{appId}/theme_published (single document) - DEPRECATED
/// ```
///
/// White-label integration:
/// - Checks if ModuleId.theme is enabled before performing operations
/// - Fails silently in release mode when module is disabled
/// - Throws assertion errors in debug mode when module is disabled
@Deprecated('Use SuperAdmin theme editor and white_label/theme/unified_theme_provider.dart instead')
class ThemeService {
  final FirebaseFirestore _firestore;
  final RestaurantPlanUnified? _restaurantPlan;

  ThemeService({
    FirebaseFirestore? firestore,
    RestaurantPlanUnified? restaurantPlan,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _restaurantPlan = restaurantPlan;

  /// Collection path for theme_draft
  static const String _themeDraftCollection = 'theme_draft';

  /// Collection path for theme_published
  static const String _themePublishedCollection = 'theme_published';

  /// Document ID for the theme config
  static const String _themeDocId = 'config';

  // ==================== MODULE GUARD ====================

  /// Checks if the theme module is enabled for the current restaurant.
  ///
  /// Returns true if:
  /// - No restaurant plan is set (backward compatibility)
  /// - The theme module is enabled in the restaurant plan
  ///
  /// In debug mode, throws an assertion error when module is disabled.
  /// In release mode, returns false silently when module is disabled.
  bool _isThemeModuleEnabled() {
    // If no plan is set, allow access for backward compatibility
    if (_restaurantPlan == null) {
      return true;
    }

    final isEnabled = _restaurantPlan!.hasModule(ModuleId.theme);

    // In debug mode, assert that the module is enabled
    assert(
      isEnabled,
      'Theme module is not enabled for restaurant ${_restaurantPlan!.restaurantId}. '
      'Enable ModuleId.theme in the restaurant plan to use theme features.',
    );

    return isEnabled;
  }

  // ==================== DOCUMENT REFERENCES ====================

  /// Get document reference for draft theme
  /// Path: restaurants/{appId}/theme_draft/config
  DocumentReference<Map<String, dynamic>> _getDraftRef(String appId) {
    return _firestore
        .collection('restaurants')
        .doc(appId)
        .collection(_themeDraftCollection)
        .doc(_themeDocId);
  }

  /// Get document reference for published theme
  /// Path: restaurants/{appId}/theme_published/config
  DocumentReference<Map<String, dynamic>> _getPublishedRef(String appId) {
    return _firestore
        .collection('restaurants')
        .doc(appId)
        .collection(_themePublishedCollection)
        .doc(_themeDocId);
  }

  // ==================== DRAFT OPERATIONS ====================

  /// Load the draft theme configuration
  ///
  /// Returns ThemeConfig.defaultConfig if no draft exists.
  /// Used by the Builder editor for theme editing.
  ///
  /// White-label guard: Returns default config if theme module is disabled.
  Future<ThemeConfig> loadDraftTheme(String appId) async {
    // Check if theme module is enabled
    if (!_isThemeModuleEnabled()) {
      debugPrint('[ThemeService] ⚠️  Theme module disabled for $appId, using defaults');
      return ThemeConfig.defaultConfig;
    }

    try {
      final ref = _getDraftRef(appId);
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.data() == null) {
        debugPrint('[ThemeService] No draft theme found for $appId, using defaults');
        return ThemeConfig.defaultConfig;
      }

      final config = ThemeConfig.fromMap(snapshot.data()!);
      debugPrint('[ThemeService] ✅ Draft theme loaded for $appId');
      return config;
    } catch (e, stackTrace) {
      debugPrint('[ThemeService] ❌ Error loading draft theme: $e');
      debugPrint('Stack trace: $stackTrace');
      return ThemeConfig.defaultConfig;
    }
  }

  /// Save the draft theme configuration
  ///
  /// ⚠️ DISABLED - DO NOT USE FOR GLOBAL THEME ⚠️
  ///
  /// This method is now a NO-OP. Global theme should be edited via:
  /// SuperAdmin > Restaurant Theme page which writes to
  /// RestaurantPlanUnified.theme.settings (top-level field)
  ///
  /// White-label guard: Always returns without saving.
  @Deprecated('Use SuperAdmin theme editor instead')
  Future<void> saveDraftTheme(String appId, ThemeConfig config) async {
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('⚠️  [ThemeService] SAVE BLOCKED');
      debugPrint('   saveDraftTheme() is deprecated and disabled');
      debugPrint('   Use SuperAdmin > Restaurant Theme instead');
      debugPrint('   Path: SuperAdmin > Restaurant > Theme');
      debugPrint('   This writes to RestaurantPlanUnified.theme.settings');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
    
    // NO-OP: Do not write to Firestore
    // Theme should only be managed via SuperAdmin
    return;
  }

  /// Watch draft theme changes in real-time
  ///
  /// Returns a stream that emits ThemeConfig whenever the draft changes.
  /// Falls back to defaultConfig if no draft exists.
  ///
  /// White-label guard: Returns default config stream if theme module is disabled.
  Stream<ThemeConfig> watchDraftTheme(String appId) {
    // Check if theme module is enabled
    if (!_isThemeModuleEnabled()) {
      debugPrint('[ThemeService] ⚠️  Theme module disabled for $appId, using default stream');
      return Stream.value(ThemeConfig.defaultConfig);
    }

    return _getDraftRef(appId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return ThemeConfig.defaultConfig;
      }
      try {
        return ThemeConfig.fromMap(snapshot.data()!);
      } catch (e) {
        debugPrint('[ThemeService] Error parsing draft theme: $e');
        return ThemeConfig.defaultConfig;
      }
    });
  }

  // ==================== PUBLISHED OPERATIONS ====================

  /// Load the published theme configuration
  ///
  /// Returns ThemeConfig.defaultConfig if no published theme exists.
  /// Used by the client runtime for rendering blocks.
  ///
  /// White-label guard: Returns default config if theme module is disabled.
  Future<ThemeConfig> loadPublishedTheme(String appId) async {
    // Check if theme module is enabled
    if (!_isThemeModuleEnabled()) {
      debugPrint('[ThemeService] ⚠️  Theme module disabled for $appId, using defaults');
      return ThemeConfig.defaultConfig;
    }

    try {
      final ref = _getPublishedRef(appId);
      final snapshot = await ref.get();

      if (!snapshot.exists || snapshot.data() == null) {
        debugPrint('[ThemeService] No published theme found for $appId, using defaults');
        return ThemeConfig.defaultConfig;
      }

      final config = ThemeConfig.fromMap(snapshot.data()!);
      debugPrint('[ThemeService] ✅ Published theme loaded for $appId');
      return config;
    } catch (e, stackTrace) {
      debugPrint('[ThemeService] ❌ Error loading published theme: $e');
      debugPrint('Stack trace: $stackTrace');
      return ThemeConfig.defaultConfig;
    }
  }

  /// Watch published theme changes in real-time
  ///
  /// Returns a stream that emits ThemeConfig whenever the published theme changes.
  /// Falls back to defaultConfig if no published theme exists.
  ///
  /// White-label guard: Returns default config stream if theme module is disabled.
  Stream<ThemeConfig> watchPublishedTheme(String appId) {
    // Check if theme module is enabled
    if (!_isThemeModuleEnabled()) {
      debugPrint('[ThemeService] ⚠️  Theme module disabled for $appId, using default stream');
      return Stream.value(ThemeConfig.defaultConfig);
    }

    return _getPublishedRef(appId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return ThemeConfig.defaultConfig;
      }
      try {
        return ThemeConfig.fromMap(snapshot.data()!);
      } catch (e) {
        debugPrint('[ThemeService] Error parsing published theme: $e');
        return ThemeConfig.defaultConfig;
      }
    });
  }

  // ==================== PUBLISH OPERATIONS ====================

  /// Publish the theme configuration
  ///
  /// ⚠️ DISABLED - DO NOT USE FOR GLOBAL THEME ⚠️
  ///
  /// This method is now a NO-OP. Global theme changes are automatically
  /// published when saved via SuperAdmin > Restaurant Theme page.
  ///
  /// White-label guard: Always returns without publishing.
  @Deprecated('Use SuperAdmin theme editor instead')
  Future<void> publishTheme(String appId, {String? userId}) async {
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('⚠️  [ThemeService] PUBLISH BLOCKED');
      debugPrint('   publishTheme() is deprecated and disabled');
      debugPrint('   Theme changes via SuperAdmin are automatically live');
      debugPrint('   No publish step needed for WL V2 theme system');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
    
    // NO-OP: Do not write to Firestore
    // Theme is managed via SuperAdmin and auto-synced
    return;
  }

  /// Check if a published theme exists
  Future<bool> hasPublishedTheme(String appId) async {
    try {
      final ref = _getPublishedRef(appId);
      final snapshot = await ref.get();
      return snapshot.exists && snapshot.data() != null;
    } catch (e) {
      debugPrint('[ThemeService] Error checking published theme: $e');
      return false;
    }
  }

  /// Check if a draft theme exists
  Future<bool> hasDraftTheme(String appId) async {
    try {
      final ref = _getDraftRef(appId);
      final snapshot = await ref.get();
      return snapshot.exists && snapshot.data() != null;
    } catch (e) {
      debugPrint('[ThemeService] Error checking draft theme: $e');
      return false;
    }
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Reset draft to published theme
  ///
  /// Discards all draft changes by copying the published theme back to draft.
  Future<void> resetDraftToPublished(String appId) async {
    try {
      final published = await loadPublishedTheme(appId);
      await saveDraftTheme(appId, published);
      debugPrint('[ThemeService] ✅ Draft reset to published for $appId');
    } catch (e, stackTrace) {
      debugPrint('[ThemeService] ❌ Error resetting draft: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Reset theme to defaults
  ///
  /// Saves the default theme configuration to both draft and published.
  Future<void> resetToDefaults(String appId, {String? userId}) async {
    try {
      final defaultConfig = ThemeConfig.defaultConfig.copyWith(
        updatedAt: DateTime.now(),
        lastModifiedBy: userId,
      );

      // Save to both draft and published
      await saveDraftTheme(appId, defaultConfig);
      await _getPublishedRef(appId).set(defaultConfig.toMap());

      debugPrint('[ThemeService] ✅ Theme reset to defaults for $appId');
    } catch (e, stackTrace) {
      debugPrint('[ThemeService] ❌ Error resetting to defaults: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
