// lib/src/core/firestore_paths.dart
// Centralized utility class for Firestore path management
//
// Multi-tenant architecture: All methods require an appId parameter
// to support dynamic restaurant switching.
//
// Firestore structure:
// restaurants/{appId}/
//     pages_system/
//     pages_draft/
//     pages_published/
//     builder_pages/
//     builder_blocks/
//     builder_settings/
//     original_data_backup/    ← never use

import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralized utility class for Firestore collection paths
///
/// Provides consistent access to the Firestore structure for multi-tenant apps:
/// ```
/// restaurants/{appId}/
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
/// final appId = ref.read(currentRestaurantProvider).id;
/// final settingsRef = FirestorePaths.builderSettings(appId);
/// final pagesRef = FirestorePaths.pagesDraft(appId);
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
  /// Path: restaurants/{appId}
  static DocumentReference<Map<String, dynamic>> restaurantDoc(String appId) {
    return _firestore.collection(_restaurants).doc(appId);
  }

  // ==================== PAGES COLLECTIONS ====================

  /// Get pages_system collection reference
  ///
  /// Path: restaurants/{appId}/pages_system
  /// Used for: System page configurations
  static CollectionReference<Map<String, dynamic>> pagesSystem(String appId) {
    return restaurantDoc(appId).collection(_pagesSystem);
  }

  /// Get pages_draft collection reference
  ///
  /// Path: restaurants/{appId}/pages_draft
  /// Used for: Draft page layouts (editor)
  static CollectionReference<Map<String, dynamic>> pagesDraft(String appId) {
    return restaurantDoc(appId).collection(_pagesDraft);
  }

  /// Get pages_published collection reference
  ///
  /// Path: restaurants/{appId}/pages_published
  /// Used for: Published page layouts (runtime)
  static CollectionReference<Map<String, dynamic>> pagesPublished(String appId) {
    return restaurantDoc(appId).collection(_pagesPublished);
  }

  // ==================== BUILDER COLLECTIONS ====================

  /// Get builder_pages collection reference
  ///
  /// Path: restaurants/{appId}/builder_pages
  /// Used for: Page metadata and configuration
  static CollectionReference<Map<String, dynamic>> builderPages(String appId) {
    return restaurantDoc(appId).collection(_builderPages);
  }

  /// Get builder_blocks collection reference
  ///
  /// Path: restaurants/{appId}/builder_blocks
  /// Used for: Block templates and reusable blocks
  static CollectionReference<Map<String, dynamic>> builderBlocks(String appId) {
    return restaurantDoc(appId).collection(_builderBlocks);
  }

  /// Get builder_settings collection reference
  ///
  /// Path: restaurants/{appId}/builder_settings
  /// Used for: Theme, home config, app texts, banners, popups, promotions, loyalty
  static CollectionReference<Map<String, dynamic>> builderSettings(String appId) {
    return restaurantDoc(appId).collection(_builderSettings);
  }

  // ==================== SPECIFIC DOCUMENT REFERENCES ====================

  /// Get document reference within pages_system
  ///
  /// Path: restaurants/{appId}/pages_system/{docId}
  static DocumentReference<Map<String, dynamic>> systemPageDoc(
    String docId,
    String appId,
  ) {
    return pagesSystem(appId).doc(docId);
  }

  /// Get document reference within pages_draft
  ///
  /// Path: restaurants/{appId}/pages_draft/{docId}
  static DocumentReference<Map<String, dynamic>> draftDoc(
    String docId,
    String appId,
  ) {
    return pagesDraft(appId).doc(docId);
  }

  /// Get document reference within pages_published
  ///
  /// Path: restaurants/{appId}/pages_published/{docId}
  static DocumentReference<Map<String, dynamic>> publishedDoc(
    String docId,
    String appId,
  ) {
    return pagesPublished(appId).doc(docId);
  }

  /// Get document reference within builder_settings
  ///
  /// Path: restaurants/{appId}/builder_settings/{docId}
  static DocumentReference<Map<String, dynamic>> settingsDoc(
    String docId,
    String appId,
  ) {
    return builderSettings(appId).doc(docId);
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
  /// Path: restaurants/{appId}/builder_settings/home_config
  static DocumentReference<Map<String, dynamic>> homeConfigDoc(String appId) {
    return settingsDoc(homeConfigDocId, appId);
  }

  /// Get theme document reference
  ///
  /// Path: restaurants/{appId}/builder_settings/theme
  static DocumentReference<Map<String, dynamic>> themeDoc(String appId) {
    return settingsDoc(themeDocId, appId);
  }

  /// Get app texts document reference
  ///
  /// Path: restaurants/{appId}/builder_settings/app_texts
  static DocumentReference<Map<String, dynamic>> appTextsDoc(String appId) {
    return settingsDoc(appTextsDocId, appId);
  }

  /// Get loyalty settings document reference
  ///
  /// Path: restaurants/{appId}/builder_settings/loyalty_settings
  static DocumentReference<Map<String, dynamic>> loyaltySettingsDoc(String appId) {
    return settingsDoc(loyaltySettingsDocId, appId);
  }

  /// Get meta document reference (for auto-init flags, etc.)
  ///
  /// Path: restaurants/{appId}/builder_settings/meta
  static DocumentReference<Map<String, dynamic>> metaDoc(String appId) {
    return settingsDoc(metaDocId, appId);
  }

  // ==================== SUBCOLLECTIONS FOR SETTINGS ====================

  /// Get banners subcollection reference
  ///
  /// Path: restaurants/{appId}/builder_settings/banners/items
  /// Note: For compatibility, banners are stored in a subcollection
  static CollectionReference<Map<String, dynamic>> banners(String appId) {
    return builderSettings(appId).doc('banners').collection('items');
  }

  /// Get popups subcollection reference
  ///
  /// Path: restaurants/{appId}/builder_settings/popups/items
  static CollectionReference<Map<String, dynamic>> popups(String appId) {
    return builderSettings(appId).doc('popups').collection('items');
  }

  /// Get promotions subcollection reference
  ///
  /// Path: restaurants/{appId}/builder_settings/promotions/items
  static CollectionReference<Map<String, dynamic>> promotions(String appId) {
    return builderSettings(appId).doc('promotions').collection('items');
  }
}
