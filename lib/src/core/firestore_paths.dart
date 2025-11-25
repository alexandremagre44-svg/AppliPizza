// lib/src/core/firestore_paths.dart
// Centralized utility class for Firestore path management
//
// New Firestore structure:
// restaurants/{restaurantId}/
//     pages_system/
//     pages_draft/
//     pages_published/
//     builder_pages/
//     builder_blocks/
//     builder_settings/
//     original_data_backup/    ← never use

import 'package:cloud_firestore/cloud_firestore.dart';

/// Global restaurant ID constant
/// TODO: In future multi-resto implementations, this can be loaded dynamically
const String kRestaurantId = 'delizza';

/// Centralized utility class for Firestore collection paths
///
/// Provides consistent access to the new Firestore structure:
/// ```
/// restaurants/{restaurantId}/
///     pages_system/
///     pages_draft/
///     pages_published/
///     builder_pages/
///     builder_blocks/
///     builder_settings/
/// ```
///
/// Example usage:
/// ```dart
/// final settingsRef = FirestorePaths.builderSettings();
/// final pagesRef = FirestorePaths.pagesDraft();
/// ```
class FirestorePaths {
  // Private constructor to prevent instantiation
  FirestorePaths._();

  // Collection names
  static const String _restaurants = 'restaurants';
  static const String _pagesSystem = 'pages_system';
  static const String _pagesDraft = 'pages_draft';
  static const String _pagesPublished = 'pages_published';
  static const String _builderPages = 'builder_pages';
  static const String _builderBlocks = 'builder_blocks';
  static const String _builderSettings = 'builder_settings';

  /// Get Firestore instance (cached for convenience)
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Get the root restaurant document reference
  ///
  /// Path: restaurants/{restaurantId}
  static DocumentReference<Map<String, dynamic>> restaurantDoc([String? restaurantId]) {
    return _firestore
        .collection(_restaurants)
        .doc(restaurantId ?? kRestaurantId);
  }

  // ==================== PAGES COLLECTIONS ====================

  /// Get pages_system collection reference
  ///
  /// Path: restaurants/{restaurantId}/pages_system
  /// Used for: System page configurations
  static CollectionReference<Map<String, dynamic>> pagesSystem([String? restaurantId]) {
    return restaurantDoc(restaurantId).collection(_pagesSystem);
  }

  /// Get pages_draft collection reference
  ///
  /// Path: restaurants/{restaurantId}/pages_draft
  /// Used for: Draft page layouts (editor)
  static CollectionReference<Map<String, dynamic>> pagesDraft([String? restaurantId]) {
    return restaurantDoc(restaurantId).collection(_pagesDraft);
  }

  /// Get pages_published collection reference
  ///
  /// Path: restaurants/{restaurantId}/pages_published
  /// Used for: Published page layouts (runtime)
  static CollectionReference<Map<String, dynamic>> pagesPublished([String? restaurantId]) {
    return restaurantDoc(restaurantId).collection(_pagesPublished);
  }

  // ==================== BUILDER COLLECTIONS ====================

  /// Get builder_pages collection reference
  ///
  /// Path: restaurants/{restaurantId}/builder_pages
  /// Used for: Page metadata and configuration
  static CollectionReference<Map<String, dynamic>> builderPages([String? restaurantId]) {
    return restaurantDoc(restaurantId).collection(_builderPages);
  }

  /// Get builder_blocks collection reference
  ///
  /// Path: restaurants/{restaurantId}/builder_blocks
  /// Used for: Block templates and reusable blocks
  static CollectionReference<Map<String, dynamic>> builderBlocks([String? restaurantId]) {
    return restaurantDoc(restaurantId).collection(_builderBlocks);
  }

  /// Get builder_settings collection reference
  ///
  /// Path: restaurants/{restaurantId}/builder_settings
  /// Used for: Theme, home config, app texts, banners, popups, promotions, loyalty
  static CollectionReference<Map<String, dynamic>> builderSettings([String? restaurantId]) {
    return restaurantDoc(restaurantId).collection(_builderSettings);
  }

  // ==================== SPECIFIC DOCUMENT REFERENCES ====================

  /// Get document reference within pages_draft
  ///
  /// Path: restaurants/{restaurantId}/pages_draft/{docId}
  static DocumentReference<Map<String, dynamic>> draftDoc(
    String docId, [
    String? restaurantId,
  ]) {
    return pagesDraft(restaurantId).doc(docId);
  }

  /// Get document reference within pages_published
  ///
  /// Path: restaurants/{restaurantId}/pages_published/{docId}
  static DocumentReference<Map<String, dynamic>> publishedDoc(
    String docId, [
    String? restaurantId,
  ]) {
    return pagesPublished(restaurantId).doc(docId);
  }

  /// Get document reference within builder_settings
  ///
  /// Path: restaurants/{restaurantId}/builder_settings/{docId}
  static DocumentReference<Map<String, dynamic>> settingsDoc(
    String docId, [
    String? restaurantId,
  ]) {
    return builderSettings(restaurantId).doc(docId);
  }

  // ==================== COMMON DOCUMENT IDS ====================

  /// Document IDs for builder_settings collection
  static const String homeConfigDocId = 'home_config';
  static const String themeDocId = 'theme';
  static const String appTextsDocId = 'app_texts';
  static const String loyaltySettingsDocId = 'loyalty_settings';
  static const String metaDocId = 'meta';

  // ==================== CONVENIENCE METHODS ====================

  /// Get home config document reference
  ///
  /// Path: restaurants/{restaurantId}/builder_settings/home_config
  static DocumentReference<Map<String, dynamic>> homeConfigDoc([String? restaurantId]) {
    return settingsDoc(homeConfigDocId, restaurantId);
  }

  /// Get theme document reference
  ///
  /// Path: restaurants/{restaurantId}/builder_settings/theme
  static DocumentReference<Map<String, dynamic>> themeDoc([String? restaurantId]) {
    return settingsDoc(themeDocId, restaurantId);
  }

  /// Get app texts document reference
  ///
  /// Path: restaurants/{restaurantId}/builder_settings/app_texts
  static DocumentReference<Map<String, dynamic>> appTextsDoc([String? restaurantId]) {
    return settingsDoc(appTextsDocId, restaurantId);
  }

  /// Get loyalty settings document reference
  ///
  /// Path: restaurants/{restaurantId}/builder_settings/loyalty_settings
  static DocumentReference<Map<String, dynamic>> loyaltySettingsDoc([String? restaurantId]) {
    return settingsDoc(loyaltySettingsDocId, restaurantId);
  }

  /// Get meta document reference (for auto-init flags, etc.)
  ///
  /// Path: restaurants/{restaurantId}/builder_settings/meta
  static DocumentReference<Map<String, dynamic>> metaDoc([String? restaurantId]) {
    return settingsDoc(metaDocId, restaurantId);
  }

  // ==================== SUBCOLLECTIONS FOR SETTINGS ====================

  /// Get banners subcollection reference
  ///
  /// Path: restaurants/{restaurantId}/builder_settings/banners/items
  /// Note: For compatibility, banners are stored in a subcollection
  static CollectionReference<Map<String, dynamic>> banners([String? restaurantId]) {
    return builderSettings(restaurantId).doc('banners').collection('items');
  }

  /// Get popups subcollection reference
  ///
  /// Path: restaurants/{restaurantId}/builder_settings/popups/items
  static CollectionReference<Map<String, dynamic>> popups([String? restaurantId]) {
    return builderSettings(restaurantId).doc('popups').collection('items');
  }

  /// Get promotions subcollection reference
  ///
  /// Path: restaurants/{restaurantId}/builder_settings/promotions/items
  static CollectionReference<Map<String, dynamic>> promotions([String? restaurantId]) {
    return builderSettings(restaurantId).doc('promotions').collection('items');
  }
}
