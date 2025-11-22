// lib/src/services/app_config_service.dart
// Service for managing unified application configuration in Firestore
// Supports draft and published configurations for white-label apps

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_config.dart';

/// Service for managing application configuration in Firestore
/// 
/// Firestore structure:
/// - Published config: app_configs/{appId}/config
/// - Draft config: app_configs/{appId}/config_draft
class AppConfigService {
  final FirebaseFirestore _firestore;

  // Collection and document constants
  static const String _collectionName = 'app_configs';
  static const String _configDocName = 'config';
  static const String _configDraftDocName = 'config_draft';

  AppConfigService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Watch configuration changes in real-time
  /// 
  /// Returns a stream of AppConfig updates
  /// [appId] - The application identifier (default: 'pizza_delizza')
  /// [draft] - Whether to watch draft or published config (default: false)
  Stream<AppConfig?> watchConfig({
    required String appId,
    bool draft = false,
  }) {
    try {
      final docName = draft ? _configDraftDocName : _configDocName;
      
      return _firestore
          .collection(_collectionName)
          .doc(appId)
          .collection('configs')
          .doc(docName)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return null;
        }
        
        try {
          return AppConfig.fromJson(snapshot.data()!);
        } catch (e) {
          print('AppConfigService: Error parsing config: $e');
          return null;
        }
      });
    } catch (e) {
      print('AppConfigService: Error watching config: $e');
      // Return a stream that emits null on error
      return Stream.value(null);
    }
  }

  /// Get configuration
  /// 
  /// Returns the current configuration or null if not found
  /// [appId] - The application identifier (default: 'pizza_delizza')
  /// [draft] - Whether to get draft or published config (default: false)
  Future<AppConfig?> getConfig({
    required String appId,
    bool draft = false,
  }) async {
    try {
      final docName = draft ? _configDraftDocName : _configDocName;
      
      final snapshot = await _firestore
          .collection(_collectionName)
          .doc(appId)
          .collection('configs')
          .doc(docName)
          .get();

      if (!snapshot.exists || snapshot.data() == null) {
        print('AppConfigService: Config not found for appId: $appId, draft: $draft');
        return null;
      }

      return AppConfig.fromJson(snapshot.data()!);
    } catch (e) {
      print('AppConfigService: Error getting config: $e');
      return null;
    }
  }

  /// Save configuration as draft
  /// 
  /// Saves the configuration to the draft location
  /// [appId] - The application identifier
  /// [config] - The configuration to save
  Future<void> saveDraft({
    required String appId,
    required AppConfig config,
  }) async {
    try {
      // Update the updatedAt timestamp
      final updatedConfig = config.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionName)
          .doc(appId)
          .collection('configs')
          .doc(_configDraftDocName)
          .set(updatedConfig.toJson());

      print('AppConfigService: Draft saved successfully for appId: $appId');
    } catch (e) {
      print('AppConfigService: Error saving draft: $e');
      rethrow;
    }
  }

  /// Publish draft configuration
  /// 
  /// Copies the draft configuration to the published location
  /// [appId] - The application identifier
  Future<void> publishDraft({
    required String appId,
  }) async {
    try {
      // Get the draft configuration
      final draft = await getConfig(appId: appId, draft: true);
      
      if (draft == null) {
        throw Exception('No draft configuration found for appId: $appId');
      }

      // Update the version and timestamp
      final publishedConfig = draft.copyWith(
        version: draft.version + 1,
        updatedAt: DateTime.now(),
      );

      // Save to published location
      await _firestore
          .collection(_collectionName)
          .doc(appId)
          .collection('configs')
          .doc(_configDocName)
          .set(publishedConfig.toJson());

      print('AppConfigService: Draft published successfully for appId: $appId (version: ${publishedConfig.version})');
    } catch (e) {
      print('AppConfigService: Error publishing draft: $e');
      rethrow;
    }
  }

  /// Initialize default configuration
  /// 
  /// Creates a default configuration if none exists
  /// [appId] - The application identifier
  /// [draft] - Whether to initialize draft or published config (default: false)
  Future<void> initializeDefaultConfig({
    required String appId,
    bool draft = false,
  }) async {
    try {
      // Check if config already exists
      final existing = await getConfig(appId: appId, draft: draft);
      if (existing != null) {
        print('AppConfigService: Config already exists for appId: $appId, draft: $draft');
        return;
      }

      // Create default config
      final defaultConfig = AppConfig.initial(appId: appId);

      // Save based on draft flag
      if (draft) {
        await saveDraft(appId: appId, config: defaultConfig);
      } else {
        await _firestore
            .collection(_collectionName)
            .doc(appId)
            .collection('configs')
            .doc(_configDocName)
            .set(defaultConfig.toJson());
      }

      print('AppConfigService: Default config initialized for appId: $appId, draft: $draft');
    } catch (e) {
      print('AppConfigService: Error initializing default config: $e');
      rethrow;
    }
  }

  /// Delete draft configuration
  /// 
  /// Removes the draft configuration
  /// [appId] - The application identifier
  Future<void> deleteDraft({
    required String appId,
  }) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(appId)
          .collection('configs')
          .doc(_configDraftDocName)
          .delete();

      print('AppConfigService: Draft deleted for appId: $appId');
    } catch (e) {
      print('AppConfigService: Error deleting draft: $e');
      rethrow;
    }
  }

  /// Copy published config to draft
  /// 
  /// Creates a new draft from the current published configuration
  /// [appId] - The application identifier
  Future<void> createDraftFromPublished({
    required String appId,
  }) async {
    try {
      // Get the published configuration
      final published = await getConfig(appId: appId, draft: false);
      
      if (published == null) {
        throw Exception('No published configuration found for appId: $appId');
      }

      // Save as draft
      await saveDraft(appId: appId, config: published);

      print('AppConfigService: Draft created from published config for appId: $appId');
    } catch (e) {
      print('AppConfigService: Error creating draft from published: $e');
      rethrow;
    }
  }

  /// Check if draft exists
  /// 
  /// Returns true if a draft configuration exists
  /// [appId] - The application identifier
  Future<bool> hasDraft({
    required String appId,
  }) async {
    try {
      final draft = await getConfig(appId: appId, draft: true);
      return draft != null;
    } catch (e) {
      print('AppConfigService: Error checking draft existence: $e');
      return false;
    }
  }

  /// Get configuration version
  /// 
  /// Returns the version number of the configuration
  /// [appId] - The application identifier
  /// [draft] - Whether to get version from draft or published config
  Future<int?> getConfigVersion({
    required String appId,
    bool draft = false,
  }) async {
    try {
      final config = await getConfig(appId: appId, draft: draft);
      return config?.version;
    } catch (e) {
      print('AppConfigService: Error getting config version: $e');
      return null;
    }
  }
}
