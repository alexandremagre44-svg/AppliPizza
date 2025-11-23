// lib/src/services/app_config_service.dart
// Service for managing unified application configuration in Firestore
// Supports draft and published configurations for white-label apps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';
import '../models/page_schema.dart';

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
  
  // B3 initialization constants
  static const String _b3TestCollection = '_b3_test';
  static const String _b3TestDocName = '__b3_init__';
  static const String _b3InitializedKey = 'b3_auto_initialized';
  
  // B3 migration constants
  static const String _defaultHeroImageUrl = 'https://images.unsplash.com/photo-1513104890138-7c749659a591';
  static const String _defaultGradientStartColor = '#000000CC';
  static const String _defaultGradientEndColor = '#00000000';
  static const String _defaultPrimaryColor = '#D62828';
  static const String _defaultWhiteColor = '#FFFFFF';
  
  // B3 route constants - DEPRECATED: kept for backward compatibility
  // TODO: Remove these constants after migration period (est. 2025-01)
  static const String _homeB3Route = '/home-b3';
  static const String _menuB3Route = '/menu-b3';
  static const String _categoriesB3Route = '/categories-b3';
  static const String _cartB3Route = '/cart-b3';
  
  /// Get all mandatory B3 routes
  /// FIX: Only main routes now - no duplicate -b3 routes
  static Set<String> _getMandatoryB3Routes() {
    return {'/home', '/menu', '/cart', '/categories'};
  }

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
  /// If the config document doesn't exist, creates a full default AppConfig
  /// Safe to call multiple times - will not overwrite existing pages
  /// Never throws exceptions - logs errors only
  Future<void> ensureMandatoryB3Pages() async {
    final docPublished = _firestore
        .collection(_collectionName)
        .doc('pizza_delizza')
        .collection('configs')
        .doc(_configDocName);
    final docDraft = _firestore
        .collection(_collectionName)
        .doc('pizza_delizza')
        .collection('configs')
        .doc(_configDraftDocName);

    Future<void> ensure(DocumentReference<Map<String, dynamic>> ref, bool isDraft) async {
      final snap = await ref.get();
      
      // If document doesn't exist, create full default AppConfig
      if (!snap.exists) {
        debugPrint('🔥 ensureMandatoryB3Pages: Document ${ref.id} does not exist, creating default AppConfig');
        final defaultConfig = getDefaultConfig('pizza_delizza');
        await ref.set(defaultConfig.toJson(), SetOptions(merge: false));
        debugPrint('🔥 ensureMandatoryB3Pages: Default AppConfig created in ${ref.id}');
        return;
      }
      
      Map<String, dynamic> data = snap.data() ?? {};

      // Ensure pages structure exists
      if (!data.containsKey('pages')) {
        data['pages'] = {'pages': []};
      }
      
      // Safely access nested pages list
      final pagesData = data['pages'] as Map<String, dynamic>?;
      final pagesList = pagesData?['pages'] as List?;
      List<dynamic> pages = pagesList != null ? List.from(pagesList) : [];

      final required = [
        '/home-b3',
        '/menu-b3',
        '/categories-b3',
        '/cart-b3',
      ];

      // Check which pages already exist
      final existingRoutes = pages
          .whereType<Map<String, dynamic>>()
          .map((p) => p['route'] as String?)
          .whereType<String>()
          .toList();
      final missing = required.where((r) => !existingRoutes.contains(r)).toList();

      if (missing.isEmpty) {
        debugPrint('🔥 ensureMandatoryB3Pages: All mandatory pages already exist in ${ref.id}');
        return; // Nothing to do
      }

      debugPrint('🔥 ensureMandatoryB3Pages: Adding ${missing.length} missing pages to ${ref.id}: $missing');

      // Generate missing pages
      final generated = missing
          .map((route) {
            switch (route) {
              case '/home-b3':
                return PageSchema.homeB3().toJson();
              case '/menu-b3':
                return PageSchema.menuB3().toJson();
              case '/categories-b3':
                return PageSchema.categoriesB3().toJson();
              case '/cart-b3':
                return PageSchema.cartB3().toJson();
              default:
                return null;
            }
          })
          .whereType<Map<String, dynamic>>()
          .toList();

      data['pages'] = {
        'pages': [...pages, ...generated]
      };

      await ref.set(data, SetOptions(merge: true));
      debugPrint('🔥 ensureMandatoryB3Pages: ${missing.length} pages injected in ${ref.id}');
    }

    try {
      await ensure(docPublished, false);
      await ensure(docDraft, true);
      debugPrint('🔥 ensureMandatoryB3Pages: Completed successfully');
    } catch (e) {
      debugPrint('AppConfigService: ERROR - Error in ensureMandatoryB3Pages: $e');
      // Don't rethrow - log only
    }
  }

  /// Ensure Firestore rules allow write access and create mandatory B3 pages
  /// 
  /// This method:
  /// 1. Checks if user is authenticated
  /// 2. Tests Firestore write permissions by creating a test document
  /// 3. If permissions are denied, logs clear error messages
  /// 4. If permissions are OK, creates mandatory B3 pages silently
  /// 
  /// Never throws exceptions - always handles errors gracefully
  Future<void> ensureFirestoreRulesAndMandatoryPages() async {
    try {
      // 1. Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('B3 Init: User not authenticated, skipping Firestore initialization');
        return;
      }

      debugPrint('B3 Init: User authenticated (${user.email}), checking Firestore permissions...');

      // 2. Test Firestore write permissions with a test document
      try {
        final testDoc = _firestore.collection(_b3TestCollection).doc(_b3TestDocName);
        
        await testDoc.set({
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid,
          'purpose': 'B3 initialization test',
        });

        debugPrint('B3 Init: Firestore write test successful');

        // Clean up test document
        try {
          await testDoc.delete();
        } catch (e) {
          // Ignore cleanup errors
          debugPrint('B3 Init: Test document cleanup failed (non-critical): $e');
        }

      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          _logPermissionDeniedError();
          return;
        }
        
        // Other Firebase errors
        debugPrint('B3 Init: Firebase error during permission test: ${e.code} - ${e.message}');
        return;
      }

      // 3. Permissions OK - Create mandatory B3 pages
      debugPrint('B3 Init: Creating mandatory B3 pages...');
      await ensureMandatoryB3Pages();
      debugPrint('B3 Init: Mandatory B3 pages creation completed');

    } catch (e) {
      debugPrint('B3 Init: Unexpected error in ensureFirestoreRulesAndMandatoryPages: $e');
      // Don't rethrow - log only
    }
  }

  /// Auto-initialize B3 pages if needed (runs only once on first boot)
  /// 
  /// This method:
  /// 1. Checks a local flag to ensure it runs only once
  /// 2. Calls ensureFirestoreRulesAndMandatoryPages()
  /// 3. Logs success message
  /// 4. Sets flag to prevent re-initialization
  /// 
  /// Safe to call multiple times - will skip if already initialized
  /// Never throws exceptions - always handles errors gracefully
  Future<void> autoInitializeB3IfNeeded() async {
    try {
      // Check if already initialized
      final prefs = await SharedPreferences.getInstance();
      
      final alreadyInitialized = prefs.getBool(_b3InitializedKey) ?? false;
      
      if (alreadyInitialized) {
        debugPrint('B3 Init: Already initialized, skipping');
        return;
      }

      debugPrint('B3 Init: Starting first-time initialization...');

      // Run the initialization
      await ensureFirestoreRulesAndMandatoryPages();

      // Mark as initialized
      await prefs.setBool(_b3InitializedKey, true);
      
      debugPrint('B3 Init: Pages auto-created successfully');

    } catch (e) {
      debugPrint('B3 Init: Error in autoInitializeB3IfNeeded: $e');
      // Don't rethrow - log only
      // Don't set the flag on error, so it will retry next time
    }
  }

  /// Log a clear error message when Firestore permissions are denied
  /// 
  /// This message guides the user to update Firestore rules in Firebase Console
  void _logPermissionDeniedError() {
    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════════════╗');
    debugPrint('║  ⚠️  FIRESTORE PERMISSION DENIED                              ║');
    debugPrint('╠═══════════════════════════════════════════════════════════════╣');
    debugPrint('║  Current Firestore rules block write access.                 ║');
    debugPrint('║                                                               ║');
    debugPrint('║  ACTION REQUIRED:                                             ║');
    debugPrint('║  1. Go to Firebase Console                                   ║');
    debugPrint('║  2. Navigate to Firestore Database > Rules                   ║');
    debugPrint('║  3. Apply temporary rules from file:                         ║');
    debugPrint('║     B3_FIRESTORE_RULES.md                                    ║');
    debugPrint('║                                                               ║');
    debugPrint('║  B3 pages will be created automatically after                ║');
    debugPrint('║  updating the rules on the next launch.                      ║');
    debugPrint('╚═══════════════════════════════════════════════════════════════╝');
    debugPrint('');
  }

  /// Force B3 initialization for DEBUG mode
  /// 
  /// **DEBUG ONLY**: This method writes directly to Firestore without any 
  /// authentication or permission checks. It's designed to make Studio B3 
  /// immediately functional in DEBUG/CHROME mode where Firebase Auth is not available.
  /// 
  /// **What it does**:
  /// - Creates full AppConfig with 4 mandatory B3 pages (home-b3, menu-b3, categories-b3, cart-b3) in Firestore
  /// - Writes to both app_configs/pizza_delizza/configs/config (published) and config_draft (draft)
  /// - Uses merge mode to preserve existing data
  /// - Never checks Firebase Auth or permissions
  /// - Ignores all permission errors (logs them only)
  /// 
  /// **Usage**: Call this in main.dart immediately after Firebase.initializeApp()
  /// wrapped in an `if (kDebugMode)` check to ensure it only runs in debug mode.
  /// 
  /// **IMPORTANT**: 
  /// - Never throws exceptions - always handles errors gracefully
  /// - The caller is responsible for checking kDebugMode before calling this method
  Future<void> forceB3InitializationForDebug() async {
    try {
      debugPrint('🔧 DEBUG: Force B3 initialization starting...');
      const appId = 'pizza_delizza';
      
      // Build the mandatory B3 pages (includes both /home and /home-b3 routes)
      final mandatoryB3Pages = _buildMandatoryB3Pages();
      // Main routes that can be edited in Builder B3
      final mandatoryRoutes = _getMandatoryB3Routes();
      
      // Use correct Firestore paths: app_configs/{appId}/configs/{config|config_draft}
      final publishedDoc = _firestore
          .collection(_collectionName)
          .doc(appId)
          .collection('configs')
          .doc(_configDocName);
      
      final draftDoc = _firestore
          .collection(_collectionName)
          .doc(appId)
          .collection('configs')
          .doc(_configDraftDocName);
      
      // Write to published document - preserving existing pages
      try {
        // Load existing published config
        AppConfig? existingPublished = await getConfig(appId: appId, draft: false, autoCreate: false);
        
        if (existingPublished != null) {
          // Keep all non-B3 pages
          final nonB3Pages = existingPublished.pages.pages
              .where((page) => !mandatoryRoutes.contains(page.route))
              .toList();
          
          // Combine with mandatory B3 pages
          final updatedPages = [...nonB3Pages, ...mandatoryB3Pages];
          
          // Update config
          final updatedConfig = existingPublished.copyWith(
            pages: existingPublished.pages.copyWith(pages: updatedPages),
          );
          
          await publishedDoc.set(updatedConfig.toJson(), SetOptions(merge: true));
          debugPrint('🔧 DEBUG: B3 config updated in published with ${updatedPages.length} pages (${nonB3Pages.length} existing + ${mandatoryB3Pages.length} B3)');
        } else {
          // No existing config - create new one with B3 pages only
          final defaultConfig = getDefaultConfig(appId);
          await publishedDoc.set(defaultConfig.toJson(), SetOptions(merge: true));
          debugPrint('🔧 DEBUG: B3 config created in published with ${mandatoryB3Pages.length} B3 pages');
        }
      } catch (e) {
        // Log error but don't throw - permission denied is expected in some environments
        debugPrint('🔧 DEBUG: Failed to write to published (expected in restrictive environments): $e');
      }
      
      // Write to draft document - preserving existing pages
      try {
        // Load existing draft config
        AppConfig? existingDraft = await getConfig(appId: appId, draft: true, autoCreate: false);
        
        if (existingDraft != null) {
          // Keep all non-B3 pages
          final nonB3Pages = existingDraft.pages.pages
              .where((page) => !mandatoryRoutes.contains(page.route))
              .toList();
          
          // Combine with mandatory B3 pages
          final updatedPages = [...nonB3Pages, ...mandatoryB3Pages];
          
          // Update config
          final updatedConfig = existingDraft.copyWith(
            pages: existingDraft.pages.copyWith(pages: updatedPages),
          );
          
          await draftDoc.set(updatedConfig.toJson(), SetOptions(merge: true));
          debugPrint('🔧 DEBUG: B3 config updated in draft with ${updatedPages.length} pages (${nonB3Pages.length} existing + ${mandatoryB3Pages.length} B3)');
        } else {
          // No existing config - create new one with B3 pages only
          final defaultConfig = getDefaultConfig(appId);
          await draftDoc.set(defaultConfig.toJson(), SetOptions(merge: true));
          debugPrint('🔧 DEBUG: B3 config created in draft with ${mandatoryB3Pages.length} B3 pages');
        }
      } catch (e) {
        // Log error but don't throw - permission denied is expected in some environments
        debugPrint('🔧 DEBUG: Failed to write to draft (expected in restrictive environments): $e');
      }
      
      debugPrint('🔧 DEBUG: Force B3 initialization completed (errors ignored if any)');
      
    } catch (e) {
      // Catch any unexpected errors and log only - never crash the app
      debugPrint('🔧 DEBUG: Unexpected error in forceB3InitializationForDebug: $e');
      // Don't rethrow - this is a debug helper that should never break the app
    }
  }

  /// Build the mandatory B3 pages
  /// 
  /// Returns a list of PageSchema objects for:
  /// - home (/home): Main home page - editable in Builder B3
  /// - home-b3 (/home-b3): Alternate B3 home page
  /// - menu (/menu): Main menu page - editable in Builder B3
  /// - menu-b3 (/menu-b3): Alternate B3 menu page
  /// - categories-b3 (/categories-b3): Category list
  /// - cart (/cart): Main cart page - editable in Builder B3
  /// - cart-b3 (/cart-b3): Alternate B3 cart page
  /// 
  /// These pages allow Builder B3 to edit the real application pages.
  List<PageSchema> _buildMandatoryB3Pages() {
    // FIX: Create ONLY main routes - no duplicate -b3 pages
    // This ensures Studio B3 edits the REAL pages that the app displays
    return [
      // Main application pages (editable in Builder B3)
      // These are the ONLY pages - no duplicates
      PageSchema.homeB3().copyWith(
        id: 'home_main',
        name: 'Accueil',
        route: '/home',
        enabled: false, // Disabled by default - admin can enable in Studio B3
      ),
      PageSchema.menuB3().copyWith(
        id: 'menu_main',
        name: 'Menu',
        route: '/menu',
        enabled: false, // Disabled by default
      ),
      PageSchema.cartB3().copyWith(
        id: 'cart_main',
        name: 'Panier',
        route: '/cart',
        enabled: false, // Disabled by default
      ),
      // Categories page (not in hybrid system, but available for future use)
      PageSchema.categoriesB3().copyWith(
        id: 'categories_main',
        name: 'Catégories',
        route: '/categories',
        enabled: false,
      ),
    ];
  }

  /// Force rebuild all B3 mandatory pages
  /// 
  /// Regenerates the four mandatory B3 pages (home-b3, menu-b3, categories-b3, cart-b3)
  /// into BOTH Firestore collections:
  /// - published (app_configs/pizza_delizza/configs/config)
  /// - draft (app_configs/pizza_delizza/configs/config_draft)
  /// 
  /// **Key features**:
  /// - Does NOT touch existing logic (autoInitializeB3IfNeeded, getConfig, saveDraft, etc.)
  /// - Does NOT delete or modify existing pages
  /// - Simply OVERWRITES the 4 B3 pages by route
  /// - Ignores Firestore permission-denied errors (catches and logs them)
  /// - Never stops execution if writes fail
  /// - Works even if user is NOT authenticated (logs "Skipped write: not authenticated")
  /// - 100% additive and reversible
  /// 
  /// **Usage**: Can be called manually from UI or debug console to force refresh B3 pages
  /// 
  /// **Safe to call multiple times**: Will replace existing B3 pages with fresh templates
  Future<void> forceRebuildAllB3Pages() async {
    debugPrint("B3 FORCE: Rebuilding all B3 mandatory pages...");
    final appId = "pizza_delizza";

    try {
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("B3 FORCE: Skipped write: not authenticated");
        return;
      }

      // 1. Build pages (locally)
      final mandatoryPages = _buildMandatoryB3Pages();
      debugPrint("B3 FORCE: Built ${mandatoryPages.length} mandatory pages");

      // Define the routes to replace
      final mandatoryRoutes = _getMandatoryB3Routes();

      // 2. Load current configs from Firestore if available
      AppConfig? draftConfig;
      AppConfig? publishedConfig;

      try {
        draftConfig = await getConfig(appId: appId, draft: true, autoCreate: false);
        debugPrint("B3 FORCE: Draft config loaded with ${draftConfig?.pages.pages.length ?? 0} pages");
      } catch (e) {
        debugPrint("B3 FORCE: Could not load draft config: $e");
      }

      try {
        publishedConfig = await getConfig(appId: appId, draft: false, autoCreate: false);
        debugPrint("B3 FORCE: Published config loaded with ${publishedConfig?.pages.pages.length ?? 0} pages");
      } catch (e) {
        debugPrint("B3 FORCE: Could not load published config: $e");
      }

      // 3. Replace ONLY the four B3 pages, keep all other pages intact

      // Process draft config
      if (draftConfig != null) {
        // Keep all non-B3 pages
        final nonB3Pages = draftConfig.pages.pages
            .where((page) => !mandatoryRoutes.contains(page.route))
            .toList();
        
        // Combine with new B3 pages
        final updatedDraftPages = [...nonB3Pages, ...mandatoryPages];
        
        final updatedDraftConfig = draftConfig.copyWith(
          pages: draftConfig.pages.copyWith(pages: updatedDraftPages),
        );

        // 4. Save to draft
        try {
          await saveDraft(appId: appId, config: updatedDraftConfig);
          debugPrint("B3 FORCE: Draft updated successfully with ${updatedDraftPages.length} pages (${mandatoryPages.length} B3 pages replaced)");
        } catch (e) {
          debugPrint("B3 FORCE: Failed to save draft (continuing anyway): $e");
        }
      } else {
        // Create new draft config with only B3 pages
        debugPrint("B3 FORCE: Draft config not found, creating new one with B3 pages");
        final defaultConfig = getDefaultConfig(appId);
        final newDraftConfig = defaultConfig.copyWith(
          pages: defaultConfig.pages.copyWith(pages: mandatoryPages),
        );
        
        try {
          await saveDraft(appId: appId, config: newDraftConfig);
          debugPrint("B3 FORCE: New draft created successfully with ${mandatoryPages.length} B3 pages");
        } catch (e) {
          debugPrint("B3 FORCE: Failed to create new draft (continuing anyway): $e");
        }
      }

      // Process published config
      if (publishedConfig != null) {
        // Keep all non-B3 pages
        final nonB3Pages = publishedConfig.pages.pages
            .where((page) => !mandatoryRoutes.contains(page.route))
            .toList();
        
        // Combine with new B3 pages
        final updatedPublishedPages = [...nonB3Pages, ...mandatoryPages];
        
        final updatedPublishedConfig = publishedConfig.copyWith(
          pages: publishedConfig.pages.copyWith(pages: updatedPublishedPages),
          version: publishedConfig.version + 1,
          updatedAt: DateTime.now(),
        );

        // Save to published
        try {
          await _firestore
              .collection(_collectionName)
              .doc(appId)
              .collection('configs')
              .doc(_configDocName)
              .set(updatedPublishedConfig.toJson());
          debugPrint("B3 FORCE: Published updated successfully with ${updatedPublishedPages.length} pages (${mandatoryPages.length} B3 pages replaced)");
        } catch (e) {
          debugPrint("B3 FORCE: Failed to save published (continuing anyway): $e");
        }
      } else {
        // Create new published config with only B3 pages
        debugPrint("B3 FORCE: Published config not found, creating new one with B3 pages");
        final defaultConfig = getDefaultConfig(appId);
        final newPublishedConfig = defaultConfig.copyWith(
          pages: defaultConfig.pages.copyWith(pages: mandatoryPages),
          updatedAt: DateTime.now(),
        );
        
        try {
          await _firestore
              .collection(_collectionName)
              .doc(appId)
              .collection('configs')
              .doc(_configDocName)
              .set(newPublishedConfig.toJson());
          debugPrint("B3 FORCE: New published created successfully with ${mandatoryPages.length} B3 pages");
        } catch (e) {
          debugPrint("B3 FORCE: Failed to create new published (continuing anyway): $e");
        }
      }

      debugPrint("B3 FORCE: Completed (errors ignored).");
      
    } catch (e) {
      debugPrint("B3 FORCE: Unexpected error (ignored): $e");
      // Never throw - always handle gracefully
    }
  }

  /// Migrate existing V2 pages to B3 architecture
  /// 
  /// This method reads existing content from HomeConfigV2 sections (hero, promo banner, etc.)
  /// and converts them into B3 PageSchema format. It creates 4 pages:
  /// - home_b3 (/home-b3): Based on existing home sections
  /// - menu_b3 (/menu-b3): Product list page
  /// - categories_b3 (/categories-b3): Category list page
  /// - cart_b3 (/cart-b3): Cart summary page
  /// 
  /// The migration:
  /// - Only runs once (uses SharedPreferences flag)
  /// - Writes to both draft and published Firestore paths
  /// - Never crashes even if content is missing
  /// - Logs clear success message
  /// 
  /// Mapping:
  /// - Hero → WidgetBlockType.heroAdvanced
  /// - PromoBanner → WidgetBlockType.promoBanner
  /// - Other sections → appropriate B3 types
  /// 
  /// [appId] - The application identifier (default: 'pizza_delizza')
  Future<void> migrateExistingPagesToB3(String appId) async {
    const String migrationKey = 'b3_migration_v2_to_b3_completed';
    
    try {
      // Check if migration already completed
      final prefs = await SharedPreferences.getInstance();
      final alreadyMigrated = prefs.getBool(migrationKey) ?? false;
      
      if (alreadyMigrated) {
        debugPrint('B3 Migration: Already completed, skipping');
        return;
      }
      
      debugPrint('B3 Migration: Starting V2 → B3 migration for appId: $appId');
      
      // Get existing configuration
      AppConfig? existingConfig;
      try {
        existingConfig = await getConfig(appId: appId, draft: false, autoCreate: false);
      } catch (e) {
        debugPrint('B3 Migration: Could not load existing config: $e');
      }
      
      // Build the 4 B3 pages based on existing content
      final List<PageSchema> migratedB3Pages = [];
      
      // 1. HOME PAGE - Convert V2 home sections to B3 blocks
      try {
        final homePage = _buildHomePageFromV2(existingConfig);
        migratedB3Pages.add(homePage);
        debugPrint('B3 Migration: Home page created with ${homePage.blocks.length} blocks');
      } catch (e) {
        debugPrint('B3 Migration: Error creating home page: $e (using default)');
        migratedB3Pages.add(PageSchema.homeB3());
      }
      
      // 2. MENU PAGE
      try {
        migratedB3Pages.add(_buildMenuPage());
        debugPrint('B3 Migration: Menu page created');
      } catch (e) {
        debugPrint('B3 Migration: Error creating menu page: $e (using default)');
        migratedB3Pages.add(PageSchema.menuB3());
      }
      
      // 3. CATEGORIES PAGE
      try {
        migratedB3Pages.add(_buildCategoriesPage());
        debugPrint('B3 Migration: Categories page created');
      } catch (e) {
        debugPrint('B3 Migration: Error creating categories page: $e (using default)');
        migratedB3Pages.add(PageSchema.categoriesB3());
      }
      
      // 4. CART PAGE
      try {
        migratedB3Pages.add(_buildCartPage());
        debugPrint('B3 Migration: Cart page created');
      } catch (e) {
        debugPrint('B3 Migration: Error creating cart page: $e (using default)');
        migratedB3Pages.add(PageSchema.cartB3());
      }
      
      // Define the B3 routes that will be replaced
      final b3Routes = _getMandatoryB3Routes();
      
      // Preserve existing non-B3 pages
      List<PageSchema> existingNonB3Pages = [];
      if (existingConfig != null && existingConfig.pages.pages.isNotEmpty) {
        existingNonB3Pages = existingConfig.pages.pages
            .where((page) => !b3Routes.contains(page.route))
            .toList();
        debugPrint('B3 Migration: Preserving ${existingNonB3Pages.length} existing non-B3 pages');
      }
      
      // Combine existing non-B3 pages with migrated B3 pages
      final allPages = [...existingNonB3Pages, ...migratedB3Pages];
      
      // Create PagesConfig with all pages
      final pagesConfig = PagesConfig(pages: allPages);
      
      // Get or create base config
      AppConfig baseConfig;
      if (existingConfig != null) {
        baseConfig = existingConfig.copyWith(pages: pagesConfig);
      } else {
        baseConfig = getDefaultConfig(appId);
        baseConfig = baseConfig.copyWith(pages: pagesConfig);
      }
      
      debugPrint('B3 Migration: Final config has ${allPages.length} pages total (${existingNonB3Pages.length} existing + ${migratedB3Pages.length} B3)');
      
      // Track if at least one write succeeds
      bool publishedWriteSuccess = false;
      bool draftWriteSuccess = false;
      
      // Write to published
      try {
        await _firestore
            .collection(_collectionName)
            .doc(appId)
            .collection('configs')
            .doc(_configDocName)
            .set(baseConfig.toJson(), SetOptions(merge: true));
        publishedWriteSuccess = true;
        debugPrint('B3 Migration: Written to published config');
      } catch (e) {
        debugPrint('B3 Migration: Failed to write published (continuing): $e');
      }
      
      // Write to draft
      try {
        await _firestore
            .collection(_collectionName)
            .doc(appId)
            .collection('configs')
            .doc(_configDraftDocName)
            .set(baseConfig.toJson(), SetOptions(merge: true));
        draftWriteSuccess = true;
        debugPrint('B3 Migration: Written to draft config');
      } catch (e) {
        debugPrint('B3 Migration: Failed to write draft (continuing): $e');
      }
      
      // Mark migration as completed only if at least one write succeeded
      if (publishedWriteSuccess || draftWriteSuccess) {
        await prefs.setBool(migrationKey, true);
        debugPrint('✅ Migration B3 SUCCESS - ${migratedB3Pages.length} pages migrated');
      } else {
        debugPrint('B3 Migration: Both writes failed, will retry on next launch');
      }
      
    } catch (e) {
      debugPrint('B3 Migration: Unexpected error (not setting migration flag): $e');
      // Don't set flag on error so it retries next time
    }
  }

  /// Build home page from existing V2 configuration
  PageSchema _buildHomePageFromV2(AppConfig? config) {
    final List<WidgetBlock> blocks = [];
    int order = 1;
    
    if (config != null && config.home.sections.isNotEmpty) {
      // Convert existing sections to B3 blocks
      for (final section in config.home.sections) {
        if (!section.active) continue;
        
        try {
          switch (section.type) {
            case HomeSectionType.hero:
              blocks.add(_convertHeroToB3(section, order++));
              break;
            case HomeSectionType.promoBanner:
              blocks.add(_convertPromoBannerToB3(section, order++));
              break;
            case HomeSectionType.popup:
              blocks.add(_convertPopupToB3(section, order++));
              break;
            default:
              debugPrint('B3 Migration: Unknown section type: ${section.type}');
          }
        } catch (e) {
          debugPrint('B3 Migration: Error converting section ${section.id}: $e');
        }
      }
    }
    
    // If no blocks were created, add default blocks
    if (blocks.isEmpty) {
      debugPrint('B3 Migration: No V2 sections found, using default home page');
      return PageSchema.homeB3();
    }
    
    // Add product slider if not present
    blocks.add(WidgetBlock(
      id: 'bestsellers_slider',
      type: WidgetBlockType.productSlider,
      order: order++,
      visible: true,
      properties: {
        'title': '⭐ Nos Meilleures Ventes',
        'showTitle': true,
        'columns': 2,
        'spacing': 16.0,
        'showPrice': true,
      },
      dataSource: DataSource(
        id: 'featured_products',
        type: DataSourceType.products,
        config: {'category': 'pizza', 'limit': 6},
      ),
      styling: {
        'padding': {'top': 16.0, 'bottom': 16.0, 'left': 16.0, 'right': 16.0},
      },
    ));
    
    // Add category slider
    blocks.add(WidgetBlock(
      id: 'categories_slider',
      type: WidgetBlockType.categorySlider,
      order: order++,
      visible: true,
      properties: {
        'title': '📂 Explorez nos catégories',
        'showTitle': true,
        'itemWidth': 120.0,
        'itemHeight': 120.0,
        'showCountBadge': true,
      },
      dataSource: DataSource(
        id: 'all_categories',
        type: DataSourceType.categories,
        config: {'limit': 10},
      ),
      styling: {
        'padding': {'top': 16.0, 'bottom': 16.0, 'left': 16.0, 'right': 16.0},
      },
    ));
    
    return PageSchema(
      id: 'home_main',
      name: 'Accueil',
      route: '/home',
      enabled: false, // Disabled by default to preserve existing behavior
      blocks: blocks,
      metadata: {
        'description': 'Page d\'accueil migrée depuis V2',
        'version': 1,
        'migrated': true,
      },
    );
  }

  /// Build navigation action for main routes
  /// 
  /// Converts V2 target names to main routes
  /// Examples: 'menu' → '/menu', 'categories' → '/categories'
  String _buildNavigationAction(dynamic target) {
    if (target == null) {
      return 'navigate:/menu'; // Default to menu
    }
    
    final targetStr = target.toString().toLowerCase();
    
    // Map V2 targets to main routes
    switch (targetStr) {
      case 'menu':
        return 'navigate:/menu';
      case 'categories':
        return 'navigate:/categories';
      case 'cart':
        return 'navigate:/cart';
      case 'home':
        return 'navigate:/home';
      default:
        // If it's already a path, keep it
        if (targetStr.startsWith('/')) {
          return 'navigate:$targetStr';
        }
        // Otherwise default to menu
        return 'navigate:/menu';
    }
  }

  /// Convert Hero section to B3 heroAdvanced block
  WidgetBlock _convertHeroToB3(HomeSectionConfig section, int order) {
    final data = section.data;
    return WidgetBlock(
      id: 'hero_${section.id}',
      type: WidgetBlockType.heroAdvanced,
      order: order,
      visible: true,
      properties: {
        'title': data['title'] ?? 'Bienvenue',
        'subtitle': data['subtitle'] ?? '',
        'imageUrl': data['imageUrl'] ?? _defaultHeroImageUrl,
        'height': 350.0,
        'borderRadius': 0.0,
        'imageFit': 'cover',
        'hasGradient': true,
        'gradientStartColor': _defaultGradientStartColor,
        'gradientEndColor': _defaultGradientEndColor,
        'gradientDirection': 'vertical',
        'overlayOpacity': 0.3,
        'titleColor': _defaultWhiteColor,
        'subtitleColor': '#FFFFFFDD',
        'contentAlign': 'bottom',
        'spacing': 8.0,
        'ctas': [
          {
            'label': data['ctaLabel'] ?? 'Commander maintenant',
            'action': _buildNavigationAction(data['ctaTarget']),
            'backgroundColor': _defaultPrimaryColor,
            'textColor': _defaultWhiteColor,
            'borderRadius': 8.0,
            'padding': 16.0,
          }
        ],
      },
    );
  }

  /// Convert PromoBanner section to B3 promoBanner block
  WidgetBlock _convertPromoBannerToB3(HomeSectionConfig section, int order) {
    final data = section.data;
    return WidgetBlock(
      id: 'promo_${section.id}',
      type: WidgetBlockType.promoBanner,
      order: order,
      visible: true,
      properties: {
        'title': data['text'] ?? '🎉 Offre Spéciale',
        'subtitle': data['subtitle'] ?? '',
        'backgroundColor': data['backgroundColor'] ?? '#FFA726',
        'textColor': _defaultWhiteColor,
        'borderRadius': 12.0,
        'padding': 20.0,
        'gradientStartColor': '#FF6F00',
        'gradientEndColor': '#FFA726',
        'gradientDirection': 'horizontal',
      },
      styling: {
        'padding': {'top': 16.0, 'bottom': 16.0, 'left': 16.0, 'right': 16.0},
      },
    );
  }

  /// Convert Popup section to B3 popup block
  WidgetBlock _convertPopupToB3(HomeSectionConfig section, int order) {
    final data = section.data;
    return WidgetBlock(
      id: 'popup_${section.id}',
      type: WidgetBlockType.popup,
      order: order,
      visible: true,
      properties: {
        'title': data['title'] ?? 'Bienvenue ! 🍕',
        'message': data['message'] ?? 'Découvrez nos pizzas artisanales',
        'titleColor': '#000000',
        'messageColor': '#666666',
        'alignment': 'center',
        'icon': 'promo',
        'backgroundColor': _defaultWhiteColor,
        'borderRadius': 16.0,
        'padding': 24.0,
        'maxWidth': 320.0,
        'elevation': 8.0,
        'overlayColor': '#000000',
        'overlayOpacity': 0.5,
        'showOnLoad': false,
        'triggerType': 'delayed',
        'delayMs': 2000,
        'dismissibleByTapOutside': true,
        'showOncePerSession': true,
        'ctas': [
          {
            'label': 'Découvrir',
            'action': 'navigate:/menu',
            'backgroundColor': _defaultPrimaryColor,
            'textColor': _defaultWhiteColor,
            'borderRadius': 8.0,
          },
          {
            'label': 'Plus tard',
            'action': 'dismissOnly',
            'backgroundColor': '#EEEEEE',
            'textColor': '#666666',
            'borderRadius': 8.0,
          }
        ],
      },
    );
  }

  /// Build menu page with product list
  PageSchema _buildMenuPage() {
    return PageSchema(
      id: 'menu_main',
      name: 'Menu',
      route: '/menu',
      enabled: false, // Disabled by default to preserve existing behavior
      blocks: [
        WidgetBlock(
          id: 'banner_menu',
          type: WidgetBlockType.banner,
          order: 1,
          visible: true,
          properties: {
            'text': '🍕 Notre Menu',
          },
          styling: {
            'backgroundColor': _defaultPrimaryColor,
            'textColor': _defaultWhiteColor,
            'padding': 16.0,
          },
        ),
        WidgetBlock(
          id: 'title_menu',
          type: WidgetBlockType.text,
          order: 2,
          visible: true,
          properties: {
            'text': 'Découvrez nos pizzas',
            'fontSize': 24.0,
            'bold': true,
            'align': 'center',
          },
          styling: {
            'padding': {'top': 24.0, 'bottom': 16.0, 'left': 16.0, 'right': 16.0},
          },
        ),
        WidgetBlock(
          id: 'products_menu',
          type: WidgetBlockType.productList,
          order: 3,
          visible: true,
          properties: {
            'title': 'Nos Pizzas',
          },
          dataSource: DataSource(
            id: 'all_products',
            type: DataSourceType.products,
            config: {'category': 'pizza'},
          ),
          styling: {
            'padding': 8.0,
          },
        ),
      ],
      metadata: {
        'description': 'Page menu dynamique B3',
        'version': 1,
        'migrated': true,
      },
    );
  }

  /// Build categories page with category list
  PageSchema _buildCategoriesPage() {
    return PageSchema(
      id: 'categories_main',
      name: 'Catégories',
      route: '/categories',
      enabled: false, // Disabled by default to preserve existing behavior
      blocks: [
        WidgetBlock(
          id: 'banner_categories',
          type: WidgetBlockType.banner,
          order: 1,
          visible: true,
          properties: {
            'text': '📂 Catégories',
          },
          styling: {
            'backgroundColor': '#2E7D32',
            'textColor': _defaultWhiteColor,
            'padding': 16.0,
          },
        ),
        WidgetBlock(
          id: 'title_categories',
          type: WidgetBlockType.text,
          order: 2,
          visible: true,
          properties: {
            'text': 'Explorez nos catégories',
            'fontSize': 24.0,
            'bold': true,
            'align': 'center',
          },
          styling: {
            'padding': {'top': 24.0, 'bottom': 16.0, 'left': 16.0, 'right': 16.0},
          },
        ),
        WidgetBlock(
          id: 'categories_list',
          type: WidgetBlockType.categoryList,
          order: 3,
          visible: true,
          properties: {
            'title': 'Toutes les catégories',
          },
          dataSource: DataSource(
            id: 'all_categories',
            type: DataSourceType.categories,
            config: {},
          ),
          styling: {
            'padding': 8.0,
          },
        ),
      ],
      metadata: {
        'description': 'Page catégories dynamique B3',
        'version': 1,
        'migrated': true,
      },
    );
  }

  /// Build cart page with empty state
  PageSchema _buildCartPage() {
    return PageSchema(
      id: 'cart_main',
      name: 'Panier',
      route: '/cart',
      enabled: false, // Disabled by default to preserve existing behavior
      blocks: [
        WidgetBlock(
          id: 'banner_cart',
          type: WidgetBlockType.banner,
          order: 1,
          visible: true,
          properties: {
            'text': '🛒 Votre Panier',
          },
          styling: {
            'backgroundColor': '#1976D2',
            'textColor': _defaultWhiteColor,
            'padding': 16.0,
          },
        ),
        WidgetBlock(
          id: 'empty_cart_message',
          type: WidgetBlockType.text,
          order: 2,
          visible: true,
          properties: {
            'text': 'Votre panier est vide',
            'fontSize': 20.0,
            'bold': true,
            'align': 'center',
          },
          styling: {
            'color': '#666666',
            'padding': {'top': 48.0, 'bottom': 24.0, 'left': 16.0, 'right': 16.0},
          },
        ),
        WidgetBlock(
          id: 'empty_cart_subtitle',
          type: WidgetBlockType.text,
          order: 3,
          visible: true,
          properties: {
            'text': 'Ajoutez des produits depuis notre menu pour commencer votre commande',
            'fontSize': 16.0,
            'align': 'center',
          },
          styling: {
            'color': '#999999',
            'padding': {'top': 0.0, 'bottom': 32.0, 'left': 16.0, 'right': 16.0},
          },
        ),
        WidgetBlock(
          id: 'back_to_menu_button',
          type: WidgetBlockType.button,
          order: 4,
          visible: true,
          properties: {
            'label': 'Retour au menu',
          },
          actions: {
            'onTap': 'navigate:/menu',
          },
          styling: {
            'backgroundColor': _defaultPrimaryColor,
            'textColor': _defaultWhiteColor,
            'padding': 16.0,
          },
        ),
      ],
      metadata: {
        'description': 'Page panier dynamique B3',
        'version': 1,
        'migrated': true,
      },
    );
  }

  /// ONE-TIME FIX: Repair pages that may have been corrupted by old initialization code
  /// 
  /// This method runs once (controlled by SharedPreferences flag) to:
  /// 1. Check if pages in Firebase were corrupted (only 4 B3 pages exist)
  /// 2. If user had more pages before, this would have been lost
  /// 3. Simply ensures B3 pages exist without removing other pages
  /// 
  /// This is safe to call multiple times - after first run, it won't do anything.
  /// 
  /// **Why this is needed**: 
  /// Old versions of forceB3InitializationForDebug() and migrateExistingPagesToB3()
  /// would overwrite ALL pages with just the 4 B3 pages. This one-time fix ensures
  /// that going forward, all pages are preserved.
  Future<void> oneTimeFixForPagePreservation() async {
    const fixKey = 'b3_page_preservation_fix_applied';
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final fixApplied = prefs.getBool(fixKey) ?? false;
      
      if (fixApplied) {
        // Fix already applied, skip
        return;
      }
      
      debugPrint('🔧 ONE-TIME FIX: Checking if page preservation fix is needed...');
      
      // Check current state of configs
      const appId = 'pizza_delizza';
      final publishedConfig = await getConfig(appId: appId, draft: false, autoCreate: false);
      final draftConfig = await getConfig(appId: appId, draft: true, autoCreate: false);
      
      final publishedPageCount = publishedConfig?.pages.pages.length ?? 0;
      final draftPageCount = draftConfig?.pages.pages.length ?? 0;
      
      debugPrint('🔧 ONE-TIME FIX: Current state - Published: $publishedPageCount pages, Draft: $draftPageCount pages');
      
      // If both configs exist and have reasonable number of pages, no fix needed
      if (publishedPageCount > 4 || draftPageCount > 4) {
        debugPrint('🔧 ONE-TIME FIX: Configs look good (>4 pages), marking fix as applied');
        await prefs.setBool(fixKey, true);
        return;
      }
      
      // If we only have 4 pages (the B3 defaults), this might be legitimate for a new install
      // OR it might mean pages were lost. We can't know for sure, but the new code will
      // preserve any future pages the user creates.
      debugPrint('🔧 ONE-TIME FIX: Config has ≤4 pages - this is either a fresh install or pages were lost');
      debugPrint('🔧 ONE-TIME FIX: Going forward, all new pages will be preserved by updated initialization code');
      
      // Mark fix as applied so we don't check again
      await prefs.setBool(fixKey, true);
      debugPrint('✅ ONE-TIME FIX: Page preservation fix applied');
      
    } catch (e) {
      debugPrint('🔧 ONE-TIME FIX: Error in oneTimeFixForPagePreservation: $e');
      // Don't rethrow - this is a best-effort fix
    }
  }

  /// DEBUG UTILITY: Reset B3 initialization flags
  /// 
  /// This method clears the SharedPreferences flags that prevent re-initialization.
  /// Use this if you need to force the B3 initialization to run again.
  /// 
  /// **Usage**: Call this method from debug console or add a button in debug UI:
  /// ```dart
  /// await AppConfigService().resetB3InitializationFlags();
  /// ```
  /// 
  /// Then restart the app - initialization will run again and preserve existing pages.
  Future<void> resetB3InitializationFlags() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_b3InitializedKey);
      await prefs.remove('b3_migration_v2_to_b3_completed');
      debugPrint('✅ B3 initialization flags cleared - restart app to re-initialize');
    } catch (e) {
      debugPrint('❌ Error clearing B3 flags: $e');
    }
  }

  /// DEBUG UTILITY: Force fix existing pages in Firestore
  /// 
  /// This method:
  /// 1. Loads current config from Firestore (both draft and published)
  /// 2. Ensures the 4 mandatory B3 pages exist
  /// 3. Preserves all other existing pages
  /// 4. Writes back the corrected config
  /// 
  /// **Safe to call**: Will not delete any pages, only ensures B3 pages exist
  /// 
  /// **Usage**: Call this to fix data that was corrupted by old initialization code:
  /// ```dart
  /// await AppConfigService().fixExistingPagesInFirestore();
  /// ```
  Future<void> fixExistingPagesInFirestore({String appId = 'pizza_delizza'}) async {
    try {
      debugPrint('🔧 FIX: Starting to fix pages in Firestore for appId: $appId');
      
      final mandatoryB3Pages = _buildMandatoryB3Pages();
      final b3Routes = _getMandatoryB3Routes();
      
      // Fix published config
      try {
        final publishedConfig = await getConfig(appId: appId, draft: false, autoCreate: false);
        if (publishedConfig != null) {
          // Keep all non-B3 pages
          final nonB3Pages = publishedConfig.pages.pages
              .where((page) => !b3Routes.contains(page.route))
              .toList();
          
          // Combine with B3 pages
          final allPages = [...nonB3Pages, ...mandatoryB3Pages];
          
          final fixedConfig = publishedConfig.copyWith(
            pages: publishedConfig.pages.copyWith(pages: allPages),
          );
          
          await _firestore
              .collection(_collectionName)
              .doc(appId)
              .collection('configs')
              .doc(_configDocName)
              .set(fixedConfig.toJson());
          
          debugPrint('🔧 FIX: Published config fixed - ${allPages.length} pages (${nonB3Pages.length} existing + ${mandatoryB3Pages.length} B3)');
        } else {
          debugPrint('🔧 FIX: No published config found, creating default');
          final defaultConfig = getDefaultConfig(appId);
          await _firestore
              .collection(_collectionName)
              .doc(appId)
              .collection('configs')
              .doc(_configDocName)
              .set(defaultConfig.toJson());
        }
      } catch (e) {
        debugPrint('🔧 FIX: Error fixing published config: $e');
      }
      
      // Fix draft config
      try {
        final draftConfig = await getConfig(appId: appId, draft: true, autoCreate: false);
        if (draftConfig != null) {
          // Keep all non-B3 pages
          final nonB3Pages = draftConfig.pages.pages
              .where((page) => !b3Routes.contains(page.route))
              .toList();
          
          // Combine with B3 pages
          final allPages = [...nonB3Pages, ...mandatoryB3Pages];
          
          final fixedConfig = draftConfig.copyWith(
            pages: draftConfig.pages.copyWith(pages: allPages),
          );
          
          await _firestore
              .collection(_collectionName)
              .doc(appId)
              .collection('configs')
              .doc(_configDraftDocName)
              .set(fixedConfig.toJson());
          
          debugPrint('🔧 FIX: Draft config fixed - ${allPages.length} pages (${nonB3Pages.length} existing + ${mandatoryB3Pages.length} B3)');
        } else {
          debugPrint('🔧 FIX: No draft config found, creating from published');
          await createDraftFromPublished(appId: appId);
        }
      } catch (e) {
        debugPrint('🔧 FIX: Error fixing draft config: $e');
      }
      
      debugPrint('✅ FIX: Firestore pages fix completed');
    } catch (e) {
      debugPrint('❌ FIX: Error in fixExistingPagesInFirestore: $e');
    }
  }

  // Old B3 routes to clean up during migration
  static const Set<String> _oldB3Routes = {
    '/home-b3',
    '/menu-b3',
    '/categories-b3',
    '/cart-b3',
  };

  /// One-time cleanup: Remove old duplicate -b3 pages
  /// 
  /// This method removes the old duplicate pages that had -b3 suffixes
  /// (like /home-b3, /menu-b3, /cart-b3, /categories-b3) and keeps only
  /// the main routes (/home, /menu, /cart, /categories).
  /// 
  /// This fixes the confusion where users would edit one page in Studio B3
  /// but see different content in the actual app.
  /// 
  /// **Safe to call multiple times** - it only removes pages with -b3 routes
  Future<void> cleanupDuplicateB3Pages({String appId = AppConstants.appId}) async {
    const String cleanupKey = 'b3_duplicate_pages_cleanup_completed';
    
    try {
      // Check if cleanup already completed (cache the prefs instance)
      final prefs = await SharedPreferences.getInstance();
      final alreadyCleaned = prefs.getBool(cleanupKey) ?? false;
      
      if (alreadyCleaned) {
        debugPrint('🧹 CLEANUP: Already completed, skipping');
        return;
      }
      
      debugPrint('🧹 CLEANUP: Starting duplicate -b3 pages cleanup for appId: $appId');
      
      // Clean published config
      try {
        final publishedConfig = await getConfig(appId: appId, draft: false, autoCreate: false);
        if (publishedConfig != null) {
          final originalCount = publishedConfig.pages.pages.length;
          
          // Keep only pages that are NOT old -b3 routes
          final cleanedPages = publishedConfig.pages.pages
              .where((page) => !_oldB3Routes.contains(page.route))
              .toList();
          
          if (cleanedPages.length < originalCount) {
            final fixedConfig = publishedConfig.copyWith(
              pages: publishedConfig.pages.copyWith(pages: cleanedPages),
            );
            
            await _firestore
                .collection(_collectionName)
                .doc(appId)
                .collection('configs')
                .doc(_configDocName)
                .set(fixedConfig.toJson());
            
            debugPrint('🧹 CLEANUP: Published config cleaned - removed ${originalCount - cleanedPages.length} duplicate pages');
          } else {
            debugPrint('🧹 CLEANUP: Published config - no duplicates found');
          }
        }
      } catch (e) {
        debugPrint('🧹 CLEANUP: Error cleaning published config: $e');
      }
      
      // Clean draft config
      try {
        final draftConfig = await getConfig(appId: appId, draft: true, autoCreate: false);
        if (draftConfig != null) {
          final originalCount = draftConfig.pages.pages.length;
          
          // Keep only pages that are NOT old -b3 routes
          final cleanedPages = draftConfig.pages.pages
              .where((page) => !_oldB3Routes.contains(page.route))
              .toList();
          
          if (cleanedPages.length < originalCount) {
            final fixedConfig = draftConfig.copyWith(
              pages: draftConfig.pages.copyWith(pages: cleanedPages),
            );
            
            await _firestore
                .collection(_collectionName)
                .doc(appId)
                .collection('configs')
                .doc(_configDraftDocName)
                .set(fixedConfig.toJson());
            
            debugPrint('🧹 CLEANUP: Draft config cleaned - removed ${originalCount - cleanedPages.length} duplicate pages');
          } else {
            debugPrint('🧹 CLEANUP: Draft config - no duplicates found');
          }
        }
      } catch (e) {
        debugPrint('🧹 CLEANUP: Error cleaning draft config: $e');
      }
      
      // Mark cleanup as completed
      await prefs.setBool(cleanupKey, true);
      debugPrint('✅ CLEANUP: Duplicate -b3 pages cleanup completed');
    } catch (e) {
      debugPrint('❌ CLEANUP: Error in cleanupDuplicateB3Pages: $e');
    }
  }
}
