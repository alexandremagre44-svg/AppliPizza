// lib/src/services/app_config_service_example.dart
// Example usage of AppConfigService
// This file demonstrates how to use the new unified configuration system

import '../models/app_config.dart';
import 'app_config_service.dart';

/// Example usage of AppConfigService
/// 
/// This demonstrates basic operations for managing app configuration:
/// - Initializing default configuration
/// - Creating and saving drafts
/// - Publishing drafts
/// - Watching configuration changes
class AppConfigServiceExample {
  final AppConfigService _service;
  
  AppConfigServiceExample({AppConfigService? service})
      : _service = service ?? AppConfigService();

  /// Example 1: Initialize default configuration for a new app
  Future<void> initializeNewApp() async {
    const appId = 'pizza_delizza';
    
    print('=== Example 1: Initialize Default Configuration ===');
    
    // Initialize default published config
    await _service.initializeDefaultConfig(appId: appId, draft: false);
    
    // Get and display the config
    final config = await _service.getConfig(appId: appId);
    if (config != null) {
      print('Initialized config version: ${config.version}');
      print('Home sections: ${config.home.sections.length}');
      print('Welcome title: ${config.home.texts.welcomeTitle}');
    }
  }

  /// Example 2: Create and edit a draft
  Future<void> createAndEditDraft() async {
    const appId = 'pizza_delizza';
    
    print('\n=== Example 2: Create and Edit Draft ===');
    
    // Get published config
    final published = await _service.getConfig(appId: appId);
    if (published == null) {
      print('No published config found. Initialize first.');
      return;
    }
    
    // Modify some settings
    final updatedHome = published.home.copyWith(
      texts: published.home.texts.copyWith(
        welcomeTitle: 'Nouveau Titre',
        welcomeSubtitle: 'Nouveau sous-titre',
      ),
      theme: published.home.theme.copyWith(
        primaryColor: '#FF5722',
      ),
    );
    
    final draftConfig = published.copyWith(
      home: updatedHome,
    );
    
    // Save as draft
    await _service.saveDraft(appId: appId, config: draftConfig);
    print('Draft saved successfully');
    
    // Verify draft was saved
    final savedDraft = await _service.getConfig(appId: appId, draft: true);
    if (savedDraft != null) {
      print('Draft welcome title: ${savedDraft.home.texts.welcomeTitle}');
      print('Draft primary color: ${savedDraft.home.theme.primaryColor}');
    }
  }

  /// Example 3: Publish a draft
  Future<void> publishDraftExample() async {
    const appId = 'pizza_delizza';
    
    print('\n=== Example 3: Publish Draft ===');
    
    // Check if draft exists
    final hasDraft = await _service.hasDraft(appId: appId);
    if (!hasDraft) {
      print('No draft to publish');
      return;
    }
    
    // Get versions before publishing
    final draftVersion = await _service.getConfigVersion(appId: appId, draft: true);
    final publishedVersion = await _service.getConfigVersion(appId: appId, draft: false);
    print('Draft version: $draftVersion');
    print('Published version before: $publishedVersion');
    
    // Publish the draft
    await _service.publishDraft(appId: appId);
    
    // Get version after publishing
    final newPublishedVersion = await _service.getConfigVersion(appId: appId, draft: false);
    print('Published version after: $newPublishedVersion');
  }

  /// Example 4: Watch configuration changes in real-time
  void watchConfigurationChanges() {
    const appId = 'pizza_delizza';
    
    print('\n=== Example 4: Watch Configuration Changes ===');
    
    // Watch published config
    _service.watchConfig(appId: appId).listen((config) {
      if (config != null) {
        print('Published config updated:');
        print('  - Version: ${config.version}');
        print('  - Welcome: ${config.home.texts.welcomeTitle}');
        print('  - Sections: ${config.home.sections.length}');
      } else {
        print('Published config is null');
      }
    });
    
    // Watch draft config
    _service.watchConfig(appId: appId, draft: true).listen((config) {
      if (config != null) {
        print('Draft config updated:');
        print('  - Version: ${config.version}');
        print('  - Welcome: ${config.home.texts.welcomeTitle}');
      } else {
        print('No draft config available');
      }
    });
  }

  /// Example 5: Add a new home section to draft
  Future<void> addHomeSectionToDraft() async {
    const appId = 'pizza_delizza';
    
    print('\n=== Example 5: Add Home Section ===');
    
    // Get current draft or create from published
    var draft = await _service.getConfig(appId: appId, draft: true);
    if (draft == null) {
      await _service.createDraftFromPublished(appId: appId);
      draft = await _service.getConfig(appId: appId, draft: true);
    }
    
    if (draft == null) {
      print('Failed to get or create draft');
      return;
    }
    
    // Add a new popup section
    final newSection = HomeSectionConfig(
      id: 'popup_1',
      type: HomeSectionType.popup,
      order: 0,
      active: true,
      data: {
        'title': 'Info allergènes',
        'content': 'Nos pizzas peuvent contenir des traces d\'allergènes. Consultez notre carte pour plus de détails.',
        'showOnAppStart': true,
      },
    );
    
    final updatedSections = [...draft.home.sections, newSection];
    final updatedHome = draft.home.copyWith(sections: updatedSections);
    final updatedDraft = draft.copyWith(home: updatedHome);
    
    await _service.saveDraft(appId: appId, config: updatedDraft);
    print('New section added to draft. Total sections: ${updatedSections.length}');
  }

  /// Example 6: Update theme in draft
  Future<void> updateThemeInDraft() async {
    const appId = 'pizza_delizza';
    
    print('\n=== Example 6: Update Theme ===');
    
    // Get or create draft
    var draft = await _service.getConfig(appId: appId, draft: true);
    if (draft == null) {
      await _service.createDraftFromPublished(appId: appId);
      draft = await _service.getConfig(appId: appId, draft: true);
    }
    
    if (draft == null) return;
    
    // Update theme colors
    final newTheme = draft.home.theme.copyWith(
      primaryColor: '#3F51B5',
      secondaryColor: '#FF4081',
      accentColor: '#FFFFFF',
      darkMode: true,
    );
    
    final updatedHome = draft.home.copyWith(theme: newTheme);
    final updatedDraft = draft.copyWith(home: updatedHome);
    
    await _service.saveDraft(appId: appId, config: updatedDraft);
    print('Theme updated in draft');
    print('  - Primary: ${newTheme.primaryColor}');
    print('  - Dark mode: ${newTheme.darkMode}');
  }

  /// Run all examples
  Future<void> runAllExamples() async {
    try {
      await initializeNewApp();
      await Future.delayed(const Duration(seconds: 1));
      
      await createAndEditDraft();
      await Future.delayed(const Duration(seconds: 1));
      
      await addHomeSectionToDraft();
      await Future.delayed(const Duration(seconds: 1));
      
      await updateThemeInDraft();
      await Future.delayed(const Duration(seconds: 1));
      
      await publishDraftExample();
      
      print('\n=== All Examples Completed ===');
    } catch (e) {
      print('Error running examples: $e');
    }
  }
}

/* USAGE INSTRUCTIONS:

To use this service in your app:

1. Import the necessary files:
   import 'package:pizza_delizza/src/models/app_config.dart';
   import 'package:pizza_delizza/src/services/app_config_service.dart';

2. Create an instance of the service:
   final configService = AppConfigService();

3. Initialize default configuration (first time setup):
   await configService.initializeDefaultConfig(appId: 'pizza_delizza');

4. Watch configuration changes (for real-time updates):
   configService.watchConfig(appId: 'pizza_delizza').listen((config) {
     if (config != null) {
       // Use the configuration to update your UI
       print('Config updated: ${config.home.texts.welcomeTitle}');
     }
   });

5. Create and edit drafts (in admin/studio):
   // Get current published config
   final published = await configService.getConfig(appId: 'pizza_delizza');
   
   // Modify as needed
   final draft = published.copyWith(
     home: published.home.copyWith(
       texts: TextsConfig(welcomeTitle: 'New Title', welcomeSubtitle: 'New Subtitle'),
     ),
   );
   
   // Save draft
   await configService.saveDraft(appId: 'pizza_delizza', config: draft);

6. Publish draft (when ready):
   await configService.publishDraft(appId: 'pizza_delizza');

FIRESTORE STRUCTURE:

app_configs/
  pizza_delizza/
    configs/
      config          <- Published configuration (used by client app)
      config_draft    <- Draft configuration (used by admin/studio)

NOTES:
- The appId parameter allows for multi-tenant white-label support
- Draft changes don't affect the live app until published
- Version is automatically incremented on publish
- All operations include proper error handling and logging
*/
