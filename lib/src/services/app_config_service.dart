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

  /// Get default configuration for an app
  /// 
  /// Returns a complete minimal configuration with:
  /// - Default hero section
  /// - Default texts
  /// - Default theme
  /// - Disabled roulette module
  /// - Default B3 dynamic pages (menu_b3, categories_b3, cart_b3)
  AppConfig getDefaultConfig(String appId) {
    return AppConfig.initial(appId: appId);
  }

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
  /// Returns the current configuration, auto-creating if not found
  /// [appId] - The application identifier (default: 'pizza_delizza')
  /// [draft] - Whether to get draft or published config (default: false)
  /// [autoCreate] - Whether to automatically create config if not found (default: true)
  Future<AppConfig?> getConfig({
    required String appId,
    bool draft = false,
    bool autoCreate = true,
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
        
        if (!autoCreate) {
          return null;
        }
        
        print('AppConfigService: Auto-creating config for appId: $appId, draft: $draft');
        
        if (draft) {
          // For draft: try to copy from published first, otherwise create default
          final published = await getConfig(appId: appId, draft: false, autoCreate: true);
          if (published != null) {
            try {
              await saveDraft(appId: appId, config: published);
              print('AppConfigService: Draft created from published config');
              return published;
            } catch (e) {
              print('AppConfigService: Error saving draft, creating default instead: $e');
              // Fall through to create default
            }
          }
          
          // If published doesn't exist or save failed, create default in both locations
          final defaultConfig = getDefaultConfig(appId);
          try {
            // Save to published first
            await _firestore
                .collection(_collectionName)
                .doc(appId)
                .collection('configs')
                .doc(_configDocName)
                .set(defaultConfig.toJson());
            
            // Then save to draft
            await saveDraft(appId: appId, config: defaultConfig);
            print('AppConfigService: Default config created in both published and draft');
            return defaultConfig;
          } catch (e) {
            print('AppConfigService: Error creating default config: $e');
            return null;
          }
        } else {
          // For published: create default config
          final defaultConfig = getDefaultConfig(appId);
          try {
            await _firestore
                .collection(_collectionName)
                .doc(appId)
                .collection('configs')
                .doc(docName)
                .set(defaultConfig.toJson());
            print('AppConfigService: Default published config created for appId: $appId');
            return defaultConfig;
          } catch (e) {
            print('AppConfigService: Error creating default published config: $e');
            return null;
          }
        }
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
  /// If published config doesn't exist, creates default config in both locations
  /// Never throws exceptions - always ensures both configs exist
  /// [appId] - The application identifier
  Future<void> createDraftFromPublished({
    required String appId,
  }) async {
    try {
      // Get the published configuration (with auto-create)
      final published = await getConfig(appId: appId, draft: false, autoCreate: true);
      
      if (published == null) {
        // This should not happen with autoCreate=true, but handle gracefully
        print('AppConfigService: WARNING - Auto-create failed, manually creating default config');
        final defaultConfig = getDefaultConfig(appId);
        
        try {
          // Save to both published and draft
          await _firestore
              .collection(_collectionName)
              .doc(appId)
              .collection('configs')
              .doc(_configDocName)
              .set(defaultConfig.toJson());
          
          await saveDraft(appId: appId, config: defaultConfig);
          print('AppConfigService: Default config created for both published and draft');
        } catch (e) {
          print('AppConfigService: ERROR - Failed to create default config: $e');
          // Don't rethrow - log only
        }
        return;
      }

      // Save as draft
      try {
        await saveDraft(appId: appId, config: published);
        print('AppConfigService: Draft created from published config for appId: $appId');
      } catch (e) {
        print('AppConfigService: ERROR - Failed to save draft: $e');
        // Don't rethrow - log only
      }
    } catch (e) {
      print('AppConfigService: ERROR - Unexpected error in createDraftFromPublished: $e');
      // Don't rethrow - log only
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

  /// Ensure published configuration exists
  /// 
  /// Creates default published config if it doesn't exist
  /// Safe to call multiple times - will not overwrite existing config
  /// Never throws exceptions - logs errors only
  /// [appId] - The application identifier
  Future<void> ensurePublishedExists({
    required String appId,
  }) async {
    try {
      final existing = await getConfig(appId: appId, draft: false, autoCreate: false);
      
      if (existing == null) {
        print('AppConfigService: Creating default published config for appId: $appId');
        final defaultConfig = getDefaultConfig(appId);
        
        try {
          await _firestore
              .collection(_collectionName)
              .doc(appId)
              .collection('configs')
              .doc(_configDocName)
              .set(defaultConfig.toJson());
          
          print('AppConfigService: Default published config created successfully');
        } catch (e) {
          print('AppConfigService: ERROR - Failed to create published config: $e');
          // Don't rethrow - log only
        }
      } else {
        print('AppConfigService: Published config already exists for appId: $appId');
      }
    } catch (e) {
      print('AppConfigService: ERROR - Unexpected error in ensurePublishedExists: $e');
      // Don't rethrow - log only
    }
  }

  /// Ensure draft configuration exists
  /// 
  /// Creates draft config if it doesn't exist
  /// - If published config exists, copies it to draft
  /// - If published config doesn't exist, creates default in both locations
  /// Safe to call multiple times - will not overwrite existing draft
  /// Never throws exceptions - logs errors only
  /// [appId] - The application identifier
  Future<void> ensureDraftExists({
    required String appId,
  }) async {
    try {
      // Check if draft already exists
      final existingDraft = await getConfig(appId: appId, draft: true, autoCreate: false);
      
      if (existingDraft != null) {
        print('AppConfigService: Draft already exists for appId: $appId');
        return;
      }

      print('AppConfigService: Creating draft for appId: $appId');

      // Check if published exists
      final published = await getConfig(appId: appId, draft: false, autoCreate: false);
      
      if (published != null) {
        // Copy from published
        try {
          await saveDraft(appId: appId, config: published);
          print('AppConfigService: Draft created from published config successfully');
        } catch (e) {
          print('AppConfigService: ERROR - Failed to save draft from published: $e');
          // Don't rethrow - log only
        }
      } else {
        // Create default in both locations
        print('AppConfigService: Creating default config for both published and draft');
        final defaultConfig = getDefaultConfig(appId);
        
        try {
          // Save to published
          await _firestore
              .collection(_collectionName)
              .doc(appId)
              .collection('configs')
              .doc(_configDocName)
              .set(defaultConfig.toJson());
          
          // Save to draft
          await saveDraft(appId: appId, config: defaultConfig);
          
          print('AppConfigService: Default config created for both locations successfully');
        } catch (e) {
          print('AppConfigService: ERROR - Failed to create default config: $e');
          // Don't rethrow - log only
        }
      }
    } catch (e) {
      print('AppConfigService: ERROR - Unexpected error in ensureDraftExists: $e');
      // Don't rethrow - log only
    }
  }

  /// Ensure all mandatory B3 pages exist in both draft and published configs
  /// 
  /// Verifies that the following pages exist and creates them if missing:
  /// - home-b3 (/home-b3)
  /// - menu-b3 (/menu-b3) 
  /// - categories-b3 (/categories-b3)
  /// - cart-b3 (/cart-b3)
  /// 
  /// Safe to call multiple times - will not overwrite existing pages
  /// Never throws exceptions - logs errors only
  /// [appId] - The application identifier
  Future<void> ensureMandatoryB3Pages({
    required String appId,
  }) async {
    try {
      print('AppConfigService: Checking mandatory B3 pages for appId: $appId');
      
      // List of mandatory B3 page routes
      final mandatoryRoutes = ['/home-b3', '/menu-b3', '/categories-b3', '/cart-b3'];
      
      // Check published config
      final published = await getConfig(appId: appId, draft: false, autoCreate: true);
      if (published == null) {
        print('AppConfigService: ERROR - Failed to get published config for B3 page check');
        return;
      }
      
      // Check which pages are missing
      final missingRoutes = <String>[];
      for (final route in mandatoryRoutes) {
        if (!published.pages.hasPage(route)) {
          missingRoutes.add(route);
        }
      }
      
      if (missingRoutes.isEmpty) {
        print('AppConfigService: All mandatory B3 pages exist');
        return;
      }
      
      print('AppConfigService: Missing B3 pages: $missingRoutes');
      
      // Get default config to extract missing pages
      final defaultConfig = getDefaultConfig(appId);
      final updatedPages = List<PageSchema>.from(published.pages.pages);
      
      // Add missing pages from default config
      for (final route in missingRoutes) {
        final defaultPage = defaultConfig.pages.getPage(route);
        if (defaultPage != null) {
          print('AppConfigService: Adding missing page: ${defaultPage.name} ($route)');
          updatedPages.add(defaultPage);
        }
      }
      
      // Update published config
      final updatedPublished = published.copyWith(
        pages: published.pages.copyWith(pages: updatedPages),
      );
      
      try {
        // Save to published
        await _firestore
            .collection(_collectionName)
            .doc(appId)
            .collection('configs')
            .doc(_configDocName)
            .set(updatedPublished.toJson());
        
        print('AppConfigService: Published config updated with missing B3 pages');
        
        // Also update draft
        await saveDraft(appId: appId, config: updatedPublished);
        print('AppConfigService: Draft config updated with missing B3 pages');
      } catch (e) {
        print('AppConfigService: ERROR - Failed to save configs with B3 pages: $e');
        // Don't rethrow - log only
      }
    } catch (e) {
      print('AppConfigService: ERROR - Unexpected error in ensureMandatoryB3Pages: $e');
      // Don't rethrow - log only
    }
  }
}
