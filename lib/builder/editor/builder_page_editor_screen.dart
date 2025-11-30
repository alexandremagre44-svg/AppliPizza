// lib/builder/editor/builder_page_editor_screen.dart
// Page editor screen for Builder B3 system
// RESPONSIVE LAYOUT: Desktop (>=1024px) 3-column, Tablet (768-1024px) 2-column, Mobile (<768px) stacked
// PHASE 7: Enhanced with all block fields, tap actions, auto-save, and page creation
// PHASE 8E: System page protections and SystemBlock protections
// PHASE 9: Modern UI redesign with Material 3 components
//
// GLOBAL THEME SELECTION MODE:
// The editor now supports a "theme selection" mode where:
// - _isThemeSelected == true: Right panel shows only ThemePropertiesPanel
// - _isThemeSelected == false: Normal mode with Page/Bloc/Nav tabs
// This is triggered by clicking the "🎨 Thème de l'application" button in the left sidebar.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/theme_config.dart';
import '../services/services.dart';
import '../services/theme_service.dart';
import '../exceptions/builder_exceptions.dart';
import '../preview/preview.dart';
import '../utils/responsive.dart';
import '../utils/action_helper.dart';
import '../utils/icon_helper.dart';
import 'new_page_dialog.dart';
import 'widgets/icon_picker_dialog.dart';
import 'widgets/builder_properties_panel.dart';
import 'panels/theme_properties_panel.dart';

/// Builder Page Editor Screen
/// 
/// Allows editing a page's blocks with:
/// - Load draft page
/// - Display block list
/// - Add/remove blocks
/// - Reorder blocks (drag & drop)
/// - Edit block configuration
/// - Preview page (tab view or full-screen)
class BuilderPageEditorScreen extends StatefulWidget {
  final String appId;
  final BuilderPageId? pageId;
  final String? pageKey;

  const BuilderPageEditorScreen({
    super.key,
    required this.appId,
    this.pageId,
    this.pageKey,
  }) : assert(
         pageId != null || pageKey != null,
         'Either pageId (for system pages) or pageKey (for custom pages) must be provided',
       );

  @override
  State<BuilderPageEditorScreen> createState() => _BuilderPageEditorScreenState();
}

class _BuilderPageEditorScreenState extends State<BuilderPageEditorScreen> with SingleTickerProviderStateMixin {
  static const double _mobileEditorPanelHeight = 60.0;
  static const Duration _autoSaveDelay = Duration(seconds: 2);
  
  final BuilderLayoutService _service = BuilderLayoutService();
  final BuilderPageService _pageService = BuilderPageService();
  final ThemeService _themeService = ThemeService();
  BuilderPage? _page;
  bool _isLoading = true;
  BuilderBlock? _selectedBlock;
  bool _hasChanges = false;
  bool _showPreviewInMobile = false;
  late TabController _tabController;
  Timer? _autoSaveTimer;
  bool _isSaving = false;
  String? _duplicateIndexWarning; // Cached duplicate check result
  bool _isShowingDraft = true; // Toggle for draft/published preview
  
  /// Published page loaded from pages_published collection
  /// 
  /// Used for "Publié" preview to show exactly what the client app sees.
  /// This is separate from _page (which is from pages_draft) to ensure
  /// the published preview reflects the actual published content.
  BuilderPage? _publishedPage;
  bool _isLoadingPublished = false;
  
  // ==================== GLOBAL THEME SELECTION STATE ====================
  
  /// Whether the global theme is currently selected
  /// 
  /// When true, the right panel shows only ThemePropertiesPanel
  /// and the page/block selection is cleared.
  bool _isThemeSelected = false;
  
  /// Draft theme configuration
  ThemeConfig? _draftTheme;
  
  /// Whether the theme has unsaved changes
  bool _themeHasChanges = false;
  
  /// Timer for auto-saving theme changes
  Timer? _themeAutoSaveTimer;
  
  /// Whether to show the mobile editor panel at the bottom
  /// Panel is shown when a block is selected AND we're showing the blocks list (not preview)
  bool get _shouldShowMobileEditorPanel => _selectedBlock != null && !_showPreviewInMobile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPage();
    _loadDraftTheme();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _themeAutoSaveTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// Schedule auto-save after changes
  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(_autoSaveDelay, () {
      if (_hasChanges && _page != null) {
        _autoSaveDraft();
      }
    });
  }

  /// Auto-save draft without user confirmation
  Future<void> _autoSaveDraft() async {
    if (_page == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      await _service.saveDraft(_page!);
      setState(() {
        _hasChanges = false;
        _isSaving = false;
      });
      debugPrint('✅ Auto-saved draft');
    } catch (e) {
      setState(() => _isSaving = false);
      debugPrint('❌ Auto-save failed: $e');
    }
  }

  // ==================== THEME MANAGEMENT METHODS ====================

  /// Load the draft theme from Firestore
  Future<void> _loadDraftTheme() async {
    try {
      final theme = await _themeService.loadDraftTheme(widget.appId);
      if (mounted) {
        setState(() {
          _draftTheme = theme;
        });
      }
      debugPrint('🎨 [EditorScreen] Draft theme loaded');
    } catch (e) {
      debugPrint('❌ [EditorScreen] Error loading draft theme: $e');
      if (mounted) {
        setState(() {
          _draftTheme = ThemeConfig.defaultConfig;
        });
      }
    }
  }

  /// Handler called when user clicks on the "🎨 Thème de l'application" button
  /// 
  /// This switches the editor to "theme selection" mode where:
  /// - The right panel shows only ThemePropertiesPanel
  /// - Page and block selection is cleared
  /// - Preview stays on the current page
  void _onThemeEntrySelected() {
    setState(() {
      _isThemeSelected = true;
      _selectedBlock = null;
      // Note: We don't clear _page to keep the preview showing
    });
    debugPrint('🎨 [EditorScreen] Theme entry selected');
  }

  /// Update theme configuration with partial updates
  void _onThemeChanged(Map<String, dynamic> updates) {
    if (_draftTheme == null) return;

    setState(() {
      _draftTheme = _draftTheme!.mergeForPreview(updates);
      _themeHasChanges = true;
    });

    // Auto-save theme changes
    _scheduleThemeAutoSave();
  }

  /// Schedule auto-save for theme changes
  void _scheduleThemeAutoSave() {
    _themeAutoSaveTimer?.cancel();
    _themeAutoSaveTimer = Timer(_autoSaveDelay, () {
      if (_themeHasChanges && _draftTheme != null) {
        _saveThemeDraft();
      }
    });
  }

  /// Save the current draft theme to Firestore
  Future<void> _saveThemeDraft() async {
    if (_draftTheme == null) return;

    try {
      await _themeService.saveDraftTheme(widget.appId, _draftTheme!);
      if (mounted) {
        setState(() {
          _themeHasChanges = false;
        });
      }
      debugPrint('✅ [EditorScreen] Draft theme saved');
    } catch (e) {
      debugPrint('❌ [EditorScreen] Error saving draft theme: $e');
    }
  }

  /// Publish the theme to make it visible to clients
  Future<void> _onThemePublish() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publier le thème'),
        content: const Text('Voulez-vous publier le thème ? Les modifications seront visibles par tous les utilisateurs de l\'application.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publier'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Save any pending changes first
      if (_themeHasChanges && _draftTheme != null) {
        await _themeService.saveDraftTheme(widget.appId, _draftTheme!);
      }

      // Publish the theme
      await _themeService.publishTheme(widget.appId, userId: 'admin'); // TODO: Get from auth

      if (mounted) {
        setState(() {
          _themeHasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Thème publié avec succès')),
        );
      }
      debugPrint('✅ [EditorScreen] Theme published');
    } catch (e) {
      debugPrint('❌ [EditorScreen] Error publishing theme: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e')),
        );
      }
    }
  }

  /// Reset theme to default values
  Future<void> _onThemeResetToDefaults() async {
    try {
      await _themeService.resetToDefaults(widget.appId, userId: 'admin'); // TODO: Get from auth
      await _loadDraftTheme();
      
      if (mounted) {
        setState(() {
          _themeHasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Thème réinitialisé aux valeurs par défaut')),
        );
      }
      debugPrint('✅ [EditorScreen] Theme reset to defaults');
    } catch (e) {
      debugPrint('❌ [EditorScreen] Error resetting theme: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e')),
        );
      }
    }
  }

  Future<void> _loadPage() async {
    setState(() => _isLoading = true);

    try {
      // Determine the page identifier to use
      final pageIdentifier = widget.pageId ?? widget.pageKey!;
      final pageIdStr = widget.pageId?.value ?? widget.pageKey!;
      
      debugPrint('📖 [EditorScreen] Loading page: $pageIdStr (appId: ${widget.appId})');
      
      // Load draft, or create default if none exists
      var page = await _service.loadDraft(widget.appId, pageIdentifier);
      
      if (page != null) {
        debugPrint('📖 [EditorScreen] Page loaded: ${page.name}');
        debugPrint('   - pageKey: ${page.pageKey}');
        debugPrint('   - systemId: ${page.systemId?.value ?? 'null (custom page)'}');
        debugPrint('   - route: ${page.route}');
        debugPrint('   - draftLayout: ${page.draftLayout.length} blocks');
        debugPrint('   - publishedLayout: ${page.publishedLayout.length} blocks');
        debugPrint('   - blocks (legacy): ${page.blocks.length} blocks');
        debugPrint('   - isSystemPage: ${page.isSystemPage}');
      }
      
      // SURGICAL FIX: For system pages with empty draft, try to initialize with default content
      // This only triggers if BOTH draft AND published are empty (checked in initializeSpecificPageDraft)
      if (page != null && page.draftLayout.isEmpty && widget.pageId != null) {
        debugPrint('📋 [EditorScreen] System page ${widget.pageId!.value} has empty draft, attempting initialization...');
        final initializedPage = await _pageService.initializeSpecificPageDraft(
          widget.appId,
          widget.pageId!,
        );
        if (initializedPage != null) {
          page = initializedPage;
          debugPrint('✅ [EditorScreen] Page initialized with ${page.draftLayout.length} default blocks');
        }
      }
      
      if (page == null && widget.pageId != null) {
        // Only auto-create for system pages (those with BuilderPageId)
        debugPrint('📋 [EditorScreen] Creating default page for system page: ${widget.pageId!.value}');
        page = await _service.createDefaultPage(
          widget.appId,
          widget.pageId!,
          isDraft: true,
        );
      }
      
      if (page == null) {
        // Custom page not found
        debugPrint('❌ [EditorScreen] Page not found: $pageIdStr');
        throw BuilderPageException(
          'Page not found: ${widget.pageKey ?? widget.pageId?.value}',
          pageId: widget.pageKey ?? widget.pageId?.value,
        );
      }
      
      // Verify and correct system page flag if needed
      page = _verifySystemPageIntegrity(page);
      
      debugPrint('✅ [EditorScreen] Page ready for editing: ${page.name} with ${page.draftLayout.length} blocks');

      setState(() {
        _page = page;
        _isLoading = false;
      });
      
      // Check for duplicate index after loading
      _checkDuplicateIndex();
    } catch (e, stackTrace) {
      debugPrint('❌ [EditorScreen] Error loading page: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }
  
  /// Verify and correct system page integrity at load time
  /// 
  /// Checks:
  /// - System pages have isSystemPage = true
  /// - System pages have valid displayLocation
  /// - System pages have a default icon if missing
  BuilderPage _verifySystemPageIntegrity(BuilderPage page) {
    var correctedPage = page;
    bool needsCorrection = false;
    
    // Check if this should be a system page but isn't marked as such
    final isSystemPageById = page.systemId?.isSystemPage ?? page.pageId?.isSystemPage ?? false;
    if (isSystemPageById && !page.isSystemPage) {
      debugPrint('⚠️ Correcting isSystemPage for ${page.pageKey}');
      correctedPage = correctedPage.copyWith(isSystemPage: true);
      needsCorrection = true;
    }
    
    // Validate displayLocation for system pages
    if (correctedPage.isSystemPage) {
      final validLocations = ['bottomBar', 'hidden'];
      if (!validLocations.contains(correctedPage.displayLocation)) {
        debugPrint('⚠️ Correcting displayLocation for ${page.pageKey}');
        correctedPage = correctedPage.copyWith(displayLocation: 'hidden');
        needsCorrection = true;
      }
    }
    
    // Set default icon for system pages if missing
    if (correctedPage.isSystemPage && (correctedPage.icon.isEmpty || correctedPage.icon == 'help_outline')) {
      String defaultIcon;
      final sysId = page.systemId;
      if (sysId != null) {
        switch (sysId) {
          case BuilderPageId.profile:
            defaultIcon = 'person';
            break;
          case BuilderPageId.cart:
            defaultIcon = 'shopping_cart';
            break;
          case BuilderPageId.rewards:
            defaultIcon = 'card_giftcard';
            break;
          case BuilderPageId.roulette:
            defaultIcon = 'casino';
            break;
          default:
            defaultIcon = 'help_outline';
        }
      } else {
        defaultIcon = 'help_outline';
      }
      if (correctedPage.icon != defaultIcon) {
        correctedPage = correctedPage.copyWith(icon: defaultIcon);
        needsCorrection = true;
      }
    }
    
    // Auto-save corrected page if changes were made
    if (needsCorrection) {
      debugPrint('✅ Auto-correcting system page ${page.pageKey}');
      _service.saveDraft(correctedPage);
    }
    
    return correctedPage;
  }

  /// Load published page from pages_published collection for "Publié" preview
  /// 
  /// PREVIEW FIX: The "Publié" preview must load from pages_published collection
  /// (NOT from pages_draft) to show exactly what the client app renders.
  /// 
  /// - Brouillon preview: uses pages_draft + draftLayout
  /// - Publié preview: uses pages_published + publishedLayout (same as client runtime)
  /// 
  /// Set [forceRefresh] to true to reload even if already cached.
  Future<void> _loadPublishedPage({bool forceRefresh = false}) async {
    if (_isLoadingPublished) return;
    if (_publishedPage != null && !forceRefresh) return;
    
    setState(() => _isLoadingPublished = true);
    
    try {
      final pageIdentifier = widget.pageId ?? widget.pageKey!;
      debugPrint('📗 [EditorScreen] Loading published page for preview: $pageIdentifier');
      
      final publishedPage = await _service.loadPublished(widget.appId, pageIdentifier);
      
      if (publishedPage != null) {
        debugPrint('📗 [EditorScreen] Published page loaded: ${publishedPage.name}');
        debugPrint('   - publishedLayout: ${publishedPage.publishedLayout.length} blocks');
      } else {
        debugPrint('ℹ️ [EditorScreen] No published version found');
      }
      
      if (mounted) {
        setState(() {
          _publishedPage = publishedPage;
          _isLoadingPublished = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [EditorScreen] Error loading published page: $e');
      if (mounted) {
        setState(() => _isLoadingPublished = false);
      }
    }
  }
  
  /// Get the layout and modules for the preview based on the current tab selection.
  /// 
  /// Returns null if the preview should show a loading or empty state.
  /// This helper centralizes the logic for determining preview data source:
  /// - Brouillon: pages_draft + draftLayout
  /// - Publié: pages_published + publishedLayout
  ({List<BuilderBlock> layout, List<String> modules})? _getPreviewData() {
    if (_page == null) return null;
    
    if (_isShowingDraft) {
      // Brouillon preview: uses pages_draft + draftLayout
      final layout = _page!.draftLayout.isNotEmpty 
          ? _page!.draftLayout 
          : _page!.publishedLayout;
      return (layout: layout, modules: _page!.modules);
    } else {
      // Publié preview: uses pages_published + publishedLayout
      if (_isLoadingPublished || _publishedPage == null) {
        return null;
      }
      return (layout: _publishedPage!.publishedLayout, modules: _publishedPage!.modules);
    }
  }
  
  /// Build the "no published version" empty state widget
  Widget _buildNoPublishedVersionState({bool compact = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.unpublished,
            size: compact ? 40 : 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune version publiée',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            Text(
              'Publiez cette page pour voir la prévisualisation',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveDraft() async {
    if (_page == null) return;

    try {
      await _service.saveDraft(_page!);
      setState(() => _hasChanges = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Brouillon sauvegardé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e')),
        );
      }
    }
  }

  Future<void> _publishPage() async {
    if (_page == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publier la page'),
        content: const Text('Voulez-vous publier cette page ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Publier'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.publishPage(
        _page!,
        userId: 'admin', // TODO: Get from auth
        shouldDeleteDraft: false,
      );
      
      setState(() {
        _hasChanges = false;
        // Reset cached published page so it will be reloaded from pages_published
        _publishedPage = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Page publiée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e')),
        );
      }
    }
  }

  void _addBlock(BlockType type) {
    if (_page == null) return;

    final newBlock = BuilderBlock(
      id: 'block_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      order: _page!.draftLayout.length,
      config: _getDefaultConfig(type),
    );

    setState(() {
      _page = _page!.addBlock(newBlock);
      _hasChanges = true;
      _selectedBlock = newBlock;
    });
    _scheduleAutoSave();
  }

  Map<String, dynamic> _getDefaultConfig(BlockType type) {
    switch (type) {
      case BlockType.hero:
        return {
          'title': 'Titre du Hero',
          'subtitle': 'Sous-titre',
          'imageUrl': '',
          'backgroundColor': '#D32F2F',
          'buttonLabel': 'En savoir plus',
          'alignment': 'center',
          'heightPreset': 'normal',
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.text:
        return {
          'content': 'Nouveau texte',
          'alignment': 'left',
          'size': 'normal',
          'bold': false,
          'color': '',
          'padding': 16,
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.productList:
        return {
          'title': '',
          'titleAlignment': 'left',
          'titleSize': 'medium',
          'mode': 'featured',
          'categoryId': '',
          'productIds': '',
          'layout': 'grid',
          'limit': 6,
          'backgroundColor': '',
          'textColor': '',
          'borderRadius': 8,
          'elevation': 2,
          'actionOnProductTap': 'openProductDetail',
        };
      case BlockType.banner:
        return {
          'title': 'Nouvelle bannière',
          'subtitle': '',
          'text': '',
          'imageUrl': '',
          'backgroundColor': '#2196F3',
          'textColor': '#FFFFFF',
          'style': 'info',
          'ctaLabel': '',
          'ctaAction': '',
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.button:
        return {
          'label': 'Bouton',
          'style': 'primary',
          'alignment': 'center',
          'backgroundColor': '',
          'textColor': '',
          'borderRadius': 8,
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.image:
        return {
          'imageUrl': '',
          'caption': '',
          'alignment': 'center',
          'height': 300,
          'fit': 'cover',
          'borderRadius': 0,
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.spacer:
        return {
          'height': 24,
        };
      case BlockType.info:
        return {
          'title': 'Information',
          'content': '',
          'icon': 'info',
          'highlight': false,
          'actionType': 'none',
          'actionValue': '',
          'backgroundColor': '',
        };
      case BlockType.categoryList:
        return {
          'title': '',
          'mode': 'auto',
          'layout': 'horizontal',
          'tapAction': 'none',
          'tapActionTarget': '',
        };
      case BlockType.html:
        return {
          'htmlContent': '<p>Contenu HTML</p>',
        };
      case BlockType.system:
        // System blocks use moduleType, not through _addBlock
        return {
          'moduleType': 'unknown',
        };
    }
  }

  void _removeBlock(String blockId) {
    if (_page == null) return;

    setState(() {
      _page = _page!.removeBlock(blockId);
      _hasChanges = true;
      if (_selectedBlock?.id == blockId) {
        _selectedBlock = null;
      }
    });
    _scheduleAutoSave();
  }

  void _reorderBlocks(int oldIndex, int newIndex) {
    if (_page == null) return;

    // Adjust index for removal
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final blocks = _page!.sortedDraftBlocks;
    final block = blocks.removeAt(oldIndex);
    blocks.insert(newIndex, block);

    final blockIds = blocks.map((b) => b.id).toList();

    setState(() {
      _page = _page!.reorderBlocks(blockIds);
      _hasChanges = true;
    });
    _scheduleAutoSave();
  }

  void _selectBlock(BuilderBlock block) {
    setState(() {
      _selectedBlock = block;
      // Exit theme selection mode when a block is selected
      _isThemeSelected = false;
    });
  }

  void _updateBlockConfig(String key, dynamic value) {
    if (_page == null || _selectedBlock == null) return;

    final updatedBlock = _selectedBlock!.updateConfig(key, value);

    setState(() {
      _page = _page!.updateBlock(updatedBlock);
      _selectedBlock = updatedBlock;
      _hasChanges = true;
    });
    _scheduleAutoSave();
  }

  /// Update multiple config values at once
  void _updateBlockConfigMultiple(Map<String, dynamic> updates) {
    if (_page == null || _selectedBlock == null) return;

    var updatedBlock = _selectedBlock!;
    for (final entry in updates.entries) {
      updatedBlock = updatedBlock.updateConfig(entry.key, entry.value);
    }

    setState(() {
      _page = _page!.updateBlock(updatedBlock);
      _selectedBlock = updatedBlock;
      _hasChanges = true;
    });
    _scheduleAutoSave();
  }

  /// Get the display label for the current page
  String get _pageLabel {
    if (widget.pageId != null) {
      return widget.pageId!.label;
    }
    // For custom pages, use the pageKey or get the name from loaded page
    return _page?.name ?? widget.pageKey ?? 'Page';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsive = ResponsiveBuilder(constraints.maxWidth);
        
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          appBar: _buildAppBar(responsive),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _page == null
                  ? _buildErrorState()
                  : _buildResponsiveLayout(responsive),
          floatingActionButton: _buildFloatingActionButton(responsive),
        );
      },
    );
  }

  /// Build the app bar with responsive actions
  PreferredSizeWidget _buildAppBar(ResponsiveBuilder responsive) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.edit_document,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            responsive.isMobile ? _pageLabel : 'Studio Builder',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (!responsive.isMobile) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _pageLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
          if (_page != null && _page!.hasUnpublishedChanges) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Modifs',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ],
          if (_isSaving) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
      actions: [
        // Save button
        if (_hasChanges)
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Sauvegarder',
            onPressed: _saveDraft,
          ),
        // Mobile view toggle
        if (responsive.isMobile)
          IconButton(
            icon: Icon(_showPreviewInMobile ? Icons.view_list : Icons.visibility),
            tooltip: _showPreviewInMobile ? 'Liste des blocs' : 'Prévisualisation',
            onPressed: () => setState(() => _showPreviewInMobile = !_showPreviewInMobile),
          ),
        // Full screen preview (not on mobile)
        if (!responsive.isMobile)
          IconButton(
            icon: const Icon(Icons.fullscreen),
            tooltip: 'Plein écran',
            onPressed: _showFullScreenPreview,
          ),
        // Publish button
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.publish),
              tooltip: 'Publier',
              onPressed: _publishPage,
            ),
            if (_page != null && _page!.hasUnpublishedChanges)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Build responsive layout based on screen size
  Widget _buildResponsiveLayout(ResponsiveBuilder responsive) {
    if (responsive.isDesktop) {
      return _buildDesktopLayout();
    } else if (responsive.isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  /// Desktop layout: 3 columns (pages | preview | properties)
  /// Width >= 1024px
  /// - Sidebar: 260-320px with internal padding
  /// - Preview: Flexible centered with margin/padding
  /// - Properties: 320-380px with internal padding
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left column: Pages list (260-320px) with 8px internal padding
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: ResponsiveBreakpoints.sidebarMinWidth,
            maxWidth: ResponsiveBreakpoints.sidebarMaxWidth,
          ),
          child: Container(
            width: ResponsiveBreakpoints.sidebarMinWidth,
            padding: const EdgeInsets.all(8.0),
            child: _buildPagesColumn(),
          ),
        ),
        
        // Center column: Preview (flex) with 12px horizontal, 8px vertical padding
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: _buildPreviewColumn(),
          ),
        ),
        
        // Right column: Properties panel (320-380px) with 8px internal padding
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: ResponsiveBreakpoints.propertiesPanelMinWidth,
            maxWidth: ResponsiveBreakpoints.propertiesPanelMaxWidth,
          ),
          child: Container(
            width: ResponsiveBreakpoints.propertiesPanelMinWidth,
            padding: const EdgeInsets.all(8.0),
            child: _buildPropertiesColumn(),
          ),
        ),
      ],
    );
  }

  /// Tablet layout: 2 columns (preview | properties) with page dropdown
  /// Width >= 768px and < 1024px
  Widget _buildTabletLayout() {
    return Column(
      children: [
        // Page selector (dropdown)
        _buildPageDropdown(),
        
        // Two-column layout with proper constraints
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left: Preview (flex) with margin
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildPreviewColumn(),
                  ),
                ),
                
                // Right: Properties panel (min 280px, max 320px)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 280,
                    maxWidth: 320,
                  ),
                  child: _buildPropertiesColumn(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build error state widget
  Widget _buildErrorState() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Impossible de charger la page',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Vérifiez la connexion et réessayez',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadPage,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build floating action button
  Widget? _buildFloatingActionButton(ResponsiveBuilder responsive) {
    if (_page == null) return null;
    
    // Only show on mobile when viewing blocks list
    if (responsive.isMobile && _showPreviewInMobile) return null;
    
    return FloatingActionButton.extended(
      onPressed: _showAddBlockDialog,
      icon: const Icon(Icons.add),
      label: Text(responsive.isMobile ? 'Bloc' : 'Ajouter un bloc'),
    );
  }

  /// Build the pages column (left sidebar)
  /// Uses Material 3 surface container colors and independent scrolling
  Widget _buildPagesColumn() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.layers,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pages',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Blocks list with independent scroll
          Expanded(
            child: _buildBlocksListContent(),
          ),
          
          // Separator
          Divider(height: 1, color: Theme.of(context).dividerColor),
          
          // 🎨 Theme button - GLOBAL THEME SELECTION
          _buildThemeEntryButton(),
          
          // Add block button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: FilledButton.icon(
              onPressed: _showAddBlockDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter bloc'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the theme entry button for global theme selection
  /// 
  /// This button appears in the left sidebar and allows the user to
  /// switch to "theme selection" mode where the right panel shows
  /// only the ThemePropertiesPanel.
  Widget _buildThemeEntryButton() {
    final isSelected = _isThemeSelected;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Material(
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer 
            : Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: _onThemeEntrySelected,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5)
                  : Border.all(color: Theme.of(context).dividerColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary 
                      : Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🎨 Thème de l\'application',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (_themeHasChanges)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the preview column (center)
  /// Uses Material 3 surface colors and centered preview with proper margins
  Widget _buildPreviewColumn() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prévisualisation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Draft/Published toggle
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Brouillon', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.edit_note, size: 16),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Publié', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.public, size: 16),
                    ),
                  ],
                  selected: {_isShowingDraft},
                  onSelectionChanged: (selection) {
                    final showDraft = selection.first;
                    setState(() => _isShowingDraft = showDraft);
                    
                    // Load published page from pages_published collection when switching to "Publié"
                    if (!showDraft && _publishedPage == null) {
                      _loadPublishedPage();
                    }
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          
          // Preview content with padding for breathing room
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildPreviewContent(),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the properties column (right sidebar)
  /// Uses Material 3 surface colors and independent tab-based scroll
  /// 
  /// GLOBAL THEME SELECTION MODE:
  /// When _isThemeSelected is true, displays BuilderPropertiesPanel with
  /// showThemeOnly=true, which shows only the ThemePropertiesPanel.
  Widget _buildPropertiesColumn() {
    // GLOBAL THEME SELECTION MODE:
    // When theme is selected, use BuilderPropertiesPanel in theme-only mode
    if (_isThemeSelected) {
      return BuilderPropertiesPanel(
        showThemeOnly: true,
        theme: _draftTheme,
        onThemeChanged: _onThemeChanged,
        onThemePublish: _onThemePublish,
        onThemeResetToDefaults: _onThemeResetToDefaults,
        themeHasChanges: _themeHasChanges,
      );
    }
    
    // Standard mode: display tabbed interface
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Header with tabs
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Propriétés',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    unselectedLabelStyle: const TextStyle(fontSize: 11),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.article_outlined, size: 16),
                        text: 'Page',
                        height: 44,
                      ),
                      Tab(
                        icon: Badge(
                          isLabelVisible: _selectedBlock != null,
                          smallSize: 6,
                          child: Icon(Icons.widgets_outlined, size: 16),
                        ),
                        text: 'Bloc',
                        height: 44,
                      ),
                      Tab(
                        icon: Icon(Icons.navigation_outlined, size: 16),
                        text: 'Nav',
                        height: 44,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tab content with independent scroll per tab
            Expanded(
              child: TabBarView(
                children: [
                  _buildPagePropertiesTab(),
                  _buildBlockPropertiesTab(),
                  _buildNavigationTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build blocks list column for mobile
  /// Uses Material 3 surface container colors
  Widget _buildBlocksListColumn() {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildBlocksListContent(),
    );
  }

  /// Build page dropdown for tablet/mobile
  /// Uses Material 3 surface container colors
  Widget _buildPageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Page:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPageIcon(_page),
                    size: 18,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _page?.name ?? _pageLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_page != null && _page!.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Actif',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the mobile bottom panel for editing selected block
  Widget _buildMobileBottomPanel() {
    if (_selectedBlock == null) return const SizedBox.shrink();
    
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: SafeArea(
        top: false,
        child: ListTile(
          leading: Text(
            _selectedBlock!.type.icon,
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(
            _selectedBlock!.type.label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Appuyez pour configurer',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary),
                onPressed: _showMobileEditorSheet,
              ),
              IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary),
                onPressed: () => setState(() => _selectedBlock = null),
              ),
            ],
          ),
          onTap: _showMobileEditorSheet,
        ),
      ),
    );
  }

  /// Build preview content
  /// 
  /// PREVIEW DATA SOURCES:
  /// - Brouillon preview: uses pages_draft + draftLayout
  /// - Publié preview: uses pages_published + publishedLayout (same as client runtime)
  /// 
  /// This ensures the "Publié" preview shows exactly what the client app renders.
  Widget _buildPreviewContent() {
    if (_page == null) {
      return Center(
        child: Text(
          'Aucune page à prévisualiser',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    // Handle loading state for published preview
    if (!_isShowingDraft && _isLoadingPublished) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Get preview data using the centralized helper
    final previewData = _getPreviewData();
    
    // Handle no published version state
    if (previewData == null && !_isShowingDraft) {
      return _buildNoPublishedVersionState();
    }
    
    // Fallback for unexpected null (shouldn't happen but be safe)
    if (previewData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: BuilderPagePreview(
        blocks: previewData.layout,
        modules: previewData.modules,
        // THEME INTEGRATION: Pass draftTheme for live preview when showing draft
        // Use theme background color, not Material theme surface
        themeConfig: _draftTheme,
      ),
    );
  }

  /// Build blocks list content (shared between desktop and mobile)
  /// Uses independent scrolling within its container
  Widget _buildBlocksListContent() {
    final blocks = _page!.sortedDraftBlocks;

    return Column(
      children: [
        // System page protection banner with proper padding
        if (_page!.isSystemPage)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildSystemPageBanner(),
          ),
        
        // Navigation parameters panel with proper spacing
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: _buildNavigationParamsPanel(),
        ),
        
        const SizedBox(height: 4),
        
        // Blocks list with independent scroll
        Expanded(
          child: blocks.isEmpty
              ? _buildEmptyBlocksState()
              : ReorderableListView.builder(
                  onReorder: _reorderBlocks,
                  itemCount: blocks.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemBuilder: (context, index) {
                    final block = blocks[index];
                    final isSelected = _selectedBlock?.id == block.id;

                    return Card(
                      key: ValueKey(block.id),
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primaryContainer 
                          : Theme.of(context).colorScheme.surfaceContainerLowest,
                      elevation: isSelected ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: isSelected 
                            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        leading: Text(
                          block.type.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          block.type.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          _getBlockSummary(block),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.error,
                                size: 20,
                              ),
                              onPressed: () => _removeBlock(block.id),
                            ),
                            const Icon(Icons.drag_handle, size: 20),
                          ],
                        ),
                        onTap: () => _selectBlock(block),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Build system page banner
  Widget _buildSystemPageBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.shield, color: Colors.blue.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Page système protégée',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          Tooltip(
            message: 'Cette page ne peut pas être supprimée',
            child: Icon(Icons.info_outline, color: Colors.blue.shade400, size: 16),
          ),
        ],
      ),
    );
  }

  /// Build navigation parameters panel (compact version for blocks list)
  Widget _buildNavigationParamsPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.navigation, color: Colors.green.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Navigation',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ),
          // Active switch
          Switch(
            value: _page!.isActive,
            onChanged: (value) => _updateNavigationParams(isActive: value),
            activeColor: Colors.green.shade600,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  /// Build empty blocks state
  Widget _buildEmptyBlocksState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun bloc',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur + pour ajouter du contenu',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build page properties tab content
  Widget _buildPagePropertiesTab() {
    if (_page == null) {
      return _buildEmptyPropertiesState('Aucune page sélectionnée');
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Page info card
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getPageIcon(_page),
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _page!.name.isNotEmpty ? _page!.name : _page!.pageKey,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _page!.route,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatChip(Icons.layers, '${_page!.draftLayout.length}', 'blocs'),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.public, 
                      _page!.publishedLayout.isNotEmpty ? 'Oui' : 'Non', 
                      'publié',
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.visibility, 
                      _page!.isActive ? 'Actif' : 'Inactif', 
                      'statut',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        if (_page!.isSystemPage) ...[
          const SizedBox(height: 12),
          _buildSystemPageBanner(),
        ],
      ],
    );
  }

  /// Build block properties tab content
  Widget _buildBlockPropertiesTab() {
    if (_selectedBlock == null) {
      return _buildEmptyPropertiesState('Sélectionnez un bloc');
    }
    
    final block = _selectedBlock!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Block header
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    block.type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          block.type.label,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Ordre: ${block.order}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() => _selectedBlock = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Configuration',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Configuration fields
          ..._buildConfigFields(block),
        ],
      ),
    );
  }

  /// Build navigation tab content
  Widget _buildNavigationTab() {
    if (_page == null) {
      return _buildEmptyPropertiesState('Aucune page sélectionnée');
    }
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active switch
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  _page!.isActive ? Icons.visibility : Icons.visibility_off,
                  color: _page!.isActive ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Afficher dans la barre',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _page!.isActive ? 'Visible' : 'Masqué',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _page!.isActive,
                  onChanged: (value) => _updateNavigationParams(isActive: value),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ),
        
        if (_page!.isActive) ...[
          const SizedBox(height: 12),
          
          // Position selector
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sort,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Position (0-4)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: DropdownButton<int>(
                          value: (_page!.bottomNavIndex >= 0 && _page!.bottomNavIndex <= 4) 
                              ? _page!.bottomNavIndex 
                              : null,
                          hint: const Text('?', style: TextStyle(fontSize: 14)),
                          underline: const SizedBox(),
                          isDense: true,
                          items: List.generate(5, (i) => i).map((index) {
                            return DropdownMenuItem<int>(
                              value: index,
                              child: Text('$index', style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _updateNavigationParams(bottomNavIndex: value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  // Duplicate warning
                  if (_duplicateIndexWarning != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, size: 14, color: Colors.orange.shade700),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _duplicateIndexWarning!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Icon picker (for custom pages only)
          if (!_page!.isSystemPage) ...[
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Icon(
                        _getPageIcon(_page),
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Icône',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _page!.icon.isEmpty ? 'Par défaut' : _page!.icon,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: _showIconPicker,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(60, 32),
                      ),
                      child: const Text('Choisir', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  /// Build empty properties state
  Widget _buildEmptyPropertiesState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build stat chip for page info
  Widget _buildStatChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to get page icon
  IconData _getPageIcon(BuilderPage? page) {
    if (page == null) return Icons.article;
    
    if (page.icon.isNotEmpty) {
      return IconHelper.iconFromName(page.icon);
    }
    
    if (page.isSystemPage) {
      final sysId = page.systemId;
      if (sysId != null) {
        switch (sysId) {
          case BuilderPageId.profile:
            return Icons.person;
          case BuilderPageId.cart:
            return Icons.shopping_cart;
          case BuilderPageId.rewards:
            return Icons.card_giftcard;
          case BuilderPageId.roulette:
            return Icons.casino;
          default:
            return Icons.article;
        }
      }
    }
    
    return Icons.article;
  }

  /// Toggle active status of the page
  Future<void> _toggleActive() async {
    if (_page == null) return;
    
    // Use the new service-based method
    await _updateNavigationParams(isActive: !_page!.isActive);
  }

  /// Show bottom nav order dialog (deprecated - now handled in navigation panel)
  /// Kept for backward compatibility with AppBar button
  Future<void> _showBottomNavOrderDialog() async {
    if (_page == null) return;
    
    final controller = TextEditingController(
      text: _page!.bottomNavIndex.toString(),
    );
    
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Position dans la navigation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Position (0-4)',
                hintText: '0, 1, 2, 3, 4',
                border: OutlineInputBorder(),
                helperText: 'Position dans la barre de navigation',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Vous pouvez aussi modifier cette valeur dans le panneau "Paramètres de navigation" ci-dessous.',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 0 && value <= 4) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      await _updateNavigationParams(bottomNavIndex: result);
    }
  }

  /// Update navigation parameters using BuilderPageService
  /// 
  /// FIX M1: Handles both system pages (with pageId) and custom pages (with pageKey)
  /// Custom pages no longer require a BuilderPageId enum to be modified.
  Future<void> _updateNavigationParams({bool? isActive, int? bottomNavIndex}) async {
    if (_page == null) return;
    
    // FIX M1: Use pageKey for all pages (custom and system)
    // pageKey is ALWAYS non-null, unlike pageId/systemId which are null for custom pages
    final pageKey = _page!.pageKey;
    
    // Determine if this is a system page (has a valid systemId)
    final systemPageId = _page!.systemId ?? _page!.pageId;
    
    // Store old values for potential revert
    final oldIsActive = _page!.isActive;
    final oldBottomNavIndex = _page!.bottomNavIndex;
    
    // Determine final values
    final finalIsActive = isActive ?? _page!.isActive;
    final finalBottomNavIndex = bottomNavIndex ?? _page!.bottomNavIndex;
    
    // Validate: if active, bottomNavIndex must be 0-4
    if (finalIsActive && (finalBottomNavIndex < 0 || finalBottomNavIndex > 4)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ La position doit être entre 0 et 4 pour une page active'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    try {
      BuilderPage updatedPage;
      
      // FIX M1: For system pages, use the enum-based method
      // For custom pages, use pageKey-based approach
      if (systemPageId != null) {
        // System page: use existing service method
        updatedPage = await _pageService.updatePageNavigation(
          pageId: systemPageId,
          appId: widget.appId,
          isActive: finalIsActive,
          bottomNavIndex: finalIsActive ? finalBottomNavIndex : null,
        );
      } else {
        // FIX M1: Custom page: update via layout service directly using pageKey
        // This is the key fix - custom pages work without requiring a BuilderPageId enum
        final displayLocation = finalIsActive ? 'bottomBar' : 'hidden';
        final finalOrder = finalIsActive ? finalBottomNavIndex : 999;
        final finalNavIndex = finalIsActive ? finalBottomNavIndex : null;
        
        updatedPage = _page!.copyWith(
          isActive: finalIsActive,
          bottomNavIndex: finalNavIndex,
          displayLocation: displayLocation,
          order: finalOrder,
          updatedAt: DateTime.now(),
        );
        
        // Save to both draft and published
        await _service.saveDraft(updatedPage.copyWith(isDraft: true));
        
        if (await _service.hasPublished(widget.appId, pageKey)) {
          await _service.publishPage(
            updatedPage,
            userId: 'editor',
            shouldDeleteDraft: false,
          );
        }
        
        debugPrint('[BuilderPageEditorScreen] ✅ Updated custom page navigation: $pageKey');
      }
      
      setState(() {
        _page = updatedPage;
        _hasChanges = false; // Already saved
      });
      
      // Check for duplicates after update
      _checkDuplicateIndex();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              finalIsActive 
                ? '✅ Page activée (position $finalBottomNavIndex)' 
                : '✅ Page désactivée'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on MinimumBottomNavItemsException catch (e) {
      // Revert UI to old values
      setState(() {
        if (_page != null) {
          _page = _page!.copyWith(
            isActive: oldIsActive,
            bottomNavIndex: oldBottomNavIndex,
          );
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${e.message}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on BottomNavIndexConflictException catch (e) {
      // Don't apply the change - keep current values
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${e.message}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // General error handling
      debugPrint('[BuilderPageEditorScreen] Error updating navigation: $e');
      
      // Revert UI to old values
      setState(() {
        if (_page != null) {
          _page = _page!.copyWith(
            isActive: oldIsActive,
            bottomNavIndex: oldBottomNavIndex,
          );
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Check if another page is using the same bottomNavIndex
  /// Updates the cached _duplicateIndexWarning state
  Future<void> _checkDuplicateIndex() async {
    if (_page == null || !_page!.isActive) {
      if (_duplicateIndexWarning != null) {
        setState(() => _duplicateIndexWarning = null);
      }
      return;
    }
    
    try {
      final allPages = await _service.loadAllDraftPages(widget.appId);
      String? warning;
      
      for (final entry in allPages.entries) {
        final otherPage = entry.value;
        // Use pageKey for comparison since it's always non-null
        if (otherPage.pageKey != _page!.pageKey && 
            otherPage.isActive && 
            otherPage.bottomNavIndex == _page!.bottomNavIndex) {
          warning = 'La page "${otherPage.name}" utilise déjà cette position';
          break;
        }
      }
      
      if (warning != _duplicateIndexWarning) {
        setState(() => _duplicateIndexWarning = warning);
      }
    } catch (e) {
      debugPrint('Error checking duplicate index: $e');
    }
  }
  
  /// Show icon picker dialog for custom pages
  Future<void> _showIconPicker() async {
    if (_page == null || _page!.isSystemPage) return;
    
    final selectedIcon = await IconPickerDialog.show(
      context,
      currentIcon: _page!.icon.isNotEmpty ? _page!.icon : null,
    );
    
    if (selectedIcon != null) {
      await _updatePageIcon(selectedIcon);
    }
  }
  
  /// Update the page icon and save
  Future<void> _updatePageIcon(String iconName) async {
    if (_page == null) return;
    
    // Update local state
    setState(() {
      _page = _page!.copyWith(icon: iconName);
      _hasChanges = true;
    });
    
    // Save to Firestore
    try {
      await _service.saveDraft(_page!);
      
      // Also update published version if it exists
      if (await _service.hasPublished(widget.appId, _page!.pageKey)) {
        await _service.publishPage(
          _page!,
          userId: 'editor',
          shouldDeleteDraft: false,
        );
      }
      
      setState(() => _hasChanges = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Icône "$iconName" enregistrée'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      debugPrint('[BuilderPageEditorScreen] ✅ Updated icon for ${_page!.pageKey}: $iconName');
    } catch (e) {
      debugPrint('[BuilderPageEditorScreen] ❌ Error updating icon: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Helper to convert icon name to IconData
  IconData _getIconFromName(String iconName) {
    return IconHelper.iconFromName(iconName);
  }

  /// Mobile layout with blocks list showing delete/drag actions permanently
  /// Clear visual separation between panels with Material 3 styling
  Widget _buildMobileLayout() {
    return Stack(
      children: [
        Column(
          children: [
            // Page info bar with Material 3 styling
            _buildPageDropdown(),
            
            // Content area with proper padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: _showPreviewInMobile 
                    ? _buildMobilePreviewContent() 
                    : _buildMobileBlocksListContent(),
              ),
            ),
          ],
        ),
        
        // Bottom editor panel button (when block is selected and in list view)
        if (_shouldShowMobileEditorPanel)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMobileBottomPanel(),
          ),
      ],
    );
  }
  
  /// Mobile-optimized preview content with proper padding
  /// 
  /// PREVIEW DATA SOURCES:
  /// - Brouillon preview: uses pages_draft + draftLayout
  /// - Publié preview: uses pages_published + publishedLayout (same as client runtime)
  Widget _buildMobilePreviewContent() {
    if (_page == null) {
      return Center(
        child: Text(
          'Aucune page à prévisualiser',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    // Handle loading state for published preview
    if (!_isShowingDraft && _isLoadingPublished) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Get preview data using the centralized helper
    final previewData = _getPreviewData();
    
    // Handle no published version state (compact for mobile)
    if (previewData == null && !_isShowingDraft) {
      return _buildNoPublishedVersionState(compact: true);
    }
    
    // Fallback for unexpected null (shouldn't happen but be safe)
    if (previewData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: BuilderPagePreview(
        blocks: previewData.layout,
        modules: previewData.modules,
        // THEME INTEGRATION: Pass draftTheme for live preview
        themeConfig: _draftTheme,
      ),
    );
  }
  
  /// Mobile-optimized blocks list content with proper styling
  Widget _buildMobileBlocksListContent() {
    return Card(
      margin: const EdgeInsets.all(4.0),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildBlocksListContent(),
    );
  }

  /// Show mobile editor sheet with block configuration
  void _showMobileEditorSheet() {
    if (_selectedBlock == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        _selectedBlock!.type.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedBlock!.type.label,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Configuration fields (scrollable)
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Configuration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildConfigFields(_selectedBlock!),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenPreview() {
    if (_page == null) return;

    // Use the centralized helper for getting preview data
    // PREVIEW DATA SOURCES:
    // - Brouillon preview: uses pages_draft + draftLayout
    // - Publié preview: uses pages_published + publishedLayout (same as client runtime)
    final previewData = _getPreviewData();
    
    if (previewData == null) {
      // No data available - show consistent error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isShowingDraft 
                ? 'Aucune page à prévisualiser' 
                : 'Aucune version publiée disponible'
          ),
        ),
      );
      return;
    }

    BuilderFullScreenPreview.show(
      context,
      blocks: previewData.layout,
      modules: previewData.modules,
      pageTitle: _pageLabel,
      // THEME INTEGRATION: Pass draftTheme for live full-screen preview
      themeConfig: _draftTheme,
    );
  }

  String _getBlockSummary(BuilderBlock block) {
    switch (block.type) {
      case BlockType.hero:
        return block.getConfig<String>('title', 'Sans titre') ?? 'Sans titre';
      case BlockType.text:
        final content = block.getConfig<String>('content', '') ?? '';
        return content.length > 40 ? '${content.substring(0, 40)}...' : content;
      case BlockType.productList:
        final ids = block.getConfig<List>('productIds', []) ?? [];
        return '${ids.length} produit(s)';
      case BlockType.banner:
        return block.getConfig<String>('text', 'Bannière') ?? 'Bannière';
      case BlockType.system:
        final moduleType = block.getConfig<String>('moduleType', 'unknown') ?? 'unknown';
        return 'Module ${SystemBlock.getModuleLabel(moduleType)}';
      default:
        return 'Bloc ${block.type.value}';
    }
  }

  List<Widget> _buildConfigFields(BuilderBlock block) {
    switch (block.type) {
      case BlockType.hero:
        return _buildHeroConfig(block);
      case BlockType.text:
        return _buildTextConfig(block);
      case BlockType.productList:
        return _buildProductListConfig(block);
      case BlockType.banner:
        return _buildBannerConfig(block);
      case BlockType.info:
        return _buildInfoConfig(block);
      case BlockType.button:
        return _buildButtonConfig(block);
      case BlockType.image:
        return _buildImageConfig(block);
      case BlockType.spacer:
        return _buildSpacerConfig(block);
      case BlockType.categoryList:
        return _buildCategoryListConfig(block);
      case BlockType.html:
        return _buildHtmlConfig(block);
      case BlockType.system:
        return _buildSystemConfig(block);
    }
  }

  /// Build configuration fields for system blocks
  /// System blocks are non-configurable, so we just show info about the module
  /// Protection: No configuration fields are exposed
  List<Widget> _buildSystemConfig(BuilderBlock block) {
    final moduleType = block.getConfig<String>('moduleType', 'unknown') ?? 'unknown';
    final moduleLabel = SystemBlock.getModuleLabel(moduleType);
    final isValidModule = SystemBlock.availableModules.contains(moduleType);
    
    // Get the appropriate icon for the module type
    IconData moduleIcon;
    Color iconColor;
    switch (moduleType) {
      case 'roulette':
        moduleIcon = Icons.casino;
        iconColor = Colors.purple.shade600;
        break;
      case 'loyalty':
        moduleIcon = Icons.card_giftcard;
        iconColor = Colors.amber.shade600;
        break;
      case 'rewards':
        moduleIcon = Icons.stars;
        iconColor = Colors.orange.shade600;
        break;
      case 'accountActivity':
        moduleIcon = Icons.history;
        iconColor = Colors.blue.shade600;
        break;
      default:
        moduleIcon = Icons.help_outline;
        iconColor = Colors.grey.shade600;
    }
    
    return [
      // Module info card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(moduleIcon, size: 32, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[Module: $moduleLabel]',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: $moduleType',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Protection banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, size: 20, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Module système protégé',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // No config message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ce module système ne possède aucune configuration.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Warning if module type is invalid
            if (!isValidModule) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 20, color: Colors.red.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Module "$moduleType" inconnu. Ce bloc peut ne pas s\'afficher correctement.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      
      const SizedBox(height: 16),
      
      // Restrictions list
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restrictions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            _buildRestrictionRow(Icons.block, 'Pas de configuration personnalisée'),
            const SizedBox(height: 4),
            _buildRestrictionRow(Icons.block, 'Type de bloc non modifiable'),
            const SizedBox(height: 4),
            _buildRestrictionRow(Icons.check_circle, 'Suppression autorisée'),
            const SizedBox(height: 4),
            _buildRestrictionRow(Icons.check_circle, 'Réorganisation autorisée'),
          ],
        ),
      ),
    ];
  }
  
  /// Build a restriction row for system block config
  Widget _buildRestrictionRow(IconData icon, String text) {
    final isAllowed = icon == Icons.check_circle;
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isAllowed ? Colors.green.shade600 : Colors.red.shade400,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildHeroConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Titre',
        value: block.getConfig<String>('title', '') ?? '',
        onChanged: (v) => _updateBlockConfig('title', v),
        helperText: 'Titre principal du hero banner',
      ),
      _buildTextField(
        label: 'Sous-titre',
        value: block.getConfig<String>('subtitle', '') ?? '',
        onChanged: (v) => _updateBlockConfig('subtitle', v),
        helperText: 'Texte secondaire (optionnel)',
      ),
      _buildTextField(
        label: 'Label du bouton',
        value: block.getConfig<String>('buttonLabel', '') ?? '',
        onChanged: (v) => _updateBlockConfig('buttonLabel', v),
        helperText: 'Texte du bouton CTA',
      ),
      _buildTextField(
        label: 'URL Image',
        value: block.getConfig<String>('imageUrl', '') ?? '',
        onChanged: (v) => _updateBlockConfig('imageUrl', v),
        helperText: 'URL de l\'image de fond',
      ),
      _buildDropdown<String>(
        label: 'Alignement du texte',
        value: block.getConfig<String>('alignment', 'center') ?? 'center',
        items: const ['left', 'center', 'right'],
        onChanged: (v) => _updateBlockConfig('alignment', v),
      ),
      _buildDropdown<String>(
        label: 'Hauteur',
        value: block.getConfig<String>('heightPreset', 'normal') ?? 'normal',
        items: const ['small', 'normal', 'large'],
        onChanged: (v) => _updateBlockConfig('heightPreset', v),
      ),
      _buildColorPicker(
        label: 'Couleur de fond',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
      _buildColorPicker(
        label: 'Couleur du texte',
        value: block.getConfig<String>('textColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('textColor', v),
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildTextConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Contenu',
        value: block.getConfig<String>('content', '') ?? '',
        onChanged: (v) => _updateBlockConfig('content', v),
        maxLines: 5,
        helperText: 'Texte du bloc',
      ),
      _buildDropdown<String>(
        label: 'Alignement',
        value: block.getConfig<String>('alignment', 'left') ?? 'left',
        items: const ['left', 'center', 'right'],
        onChanged: (v) => _updateBlockConfig('alignment', v),
      ),
      _buildDropdown<String>(
        label: 'Taille',
        value: block.getConfig<String>('size', 'normal') ?? 'normal',
        items: const ['small', 'normal', 'large', 'title', 'heading'],
        onChanged: (v) => _updateBlockConfig('size', v),
      ),
      _buildCheckbox(
        label: 'Gras',
        value: block.getConfig<bool>('bold', false) ?? false,
        onChanged: (v) => _updateBlockConfig('bold', v),
      ),
      _buildColorPicker(
        label: 'Couleur du texte',
        value: block.getConfig<String>('color', '') ?? '',
        onChanged: (v) => _updateBlockConfig('color', v),
      ),
      _buildNumberField(
        label: 'Padding',
        value: block.getConfig<int>('padding', 16) ?? 16,
        onChanged: (v) => _updateBlockConfig('padding', v),
        helperText: 'Espacement intérieur',
      ),
      _buildNumberField(
        label: 'Nombre de lignes max',
        value: block.getConfig<int>('maxLines', 0) ?? 0,
        onChanged: (v) => _updateBlockConfig('maxLines', v),
        helperText: '0 = illimité',
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildProductListConfig(BuilderBlock block) {
    final productIds = block.getConfig<String>('productIds', '') ?? '';

    return [
      _buildTextField(
        label: 'Titre (optionnel)',
        value: block.getConfig<String>('title', '') ?? '',
        onChanged: (v) => _updateBlockConfig('title', v),
        helperText: 'Titre de la section de produits',
      ),
      _buildDropdown<String>(
        label: 'Alignement du titre',
        value: block.getConfig<String>('titleAlignment', 'left') ?? 'left',
        items: const ['left', 'center', 'right'],
        onChanged: (v) => _updateBlockConfig('titleAlignment', v),
      ),
      _buildDropdown<String>(
        label: 'Taille du titre',
        value: block.getConfig<String>('titleSize', 'medium') ?? 'medium',
        items: const ['small', 'medium', 'large'],
        onChanged: (v) => _updateBlockConfig('titleSize', v),
      ),
      _buildDropdown<String>(
        label: 'Mode',
        value: block.getConfig<String>('mode', 'featured') ?? 'featured',
        items: const ['featured', 'manual', 'top_selling', 'promo'],
        onChanged: (v) => _updateBlockConfig('mode', v),
      ),
      _buildTextField(
        label: 'Catégorie',
        value: block.getConfig<String>('categoryId', '') ?? '',
        onChanged: (v) => _updateBlockConfig('categoryId', v),
        helperText: 'ID de la catégorie (Pizza, Boissons, etc.)',
      ),
      _buildDropdown<String>(
        label: 'Layout',
        value: block.getConfig<String>('layout', 'grid') ?? 'grid',
        items: const ['grid', 'carousel', 'list'],
        onChanged: (v) => _updateBlockConfig('layout', v),
      ),
      _buildTextField(
        label: 'IDs des produits (pour mode manuel)',
        value: productIds,
        onChanged: (v) => _updateBlockConfig('productIds', v),
        helperText: 'Séparés par virgule. Ex: prod1,prod2,prod3',
        maxLines: 2,
      ),
      _buildNumberField(
        label: 'Limite',
        value: block.getConfig<int>('limit', 6) ?? 6,
        onChanged: (v) => _updateBlockConfig('limit', v),
        helperText: 'Nombre maximum de produits à afficher',
      ),
      _buildColorPicker(
        label: 'Couleur de fond',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
      _buildColorPicker(
        label: 'Couleur du texte',
        value: block.getConfig<String>('textColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('textColor', v),
      ),
      _buildNumberField(
        label: 'Border Radius',
        value: block.getConfig<int>('borderRadius', 8) ?? 8,
        onChanged: (v) => _updateBlockConfig('borderRadius', v),
        helperText: 'Arrondi des coins',
      ),
      _buildNumberField(
        label: 'Élévation',
        value: block.getConfig<int>('elevation', 2) ?? 2,
        onChanged: (v) => _updateBlockConfig('elevation', v),
        helperText: 'Ombre portée',
        max: 24,
      ),
      _buildDropdown<String>(
        label: 'Action au clic sur produit',
        value: block.getConfig<String>('actionOnProductTap', 'openProductDetail') ?? 'openProductDetail',
        items: const ['openProductDetail', 'openPage'],
        onChanged: (v) => _updateBlockConfig('actionOnProductTap', v),
      ),
    ];
  }

  List<Widget> _buildBannerConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Titre',
        value: block.getConfig<String>('title', '') ?? '',
        onChanged: (v) => _updateBlockConfig('title', v),
        helperText: 'Titre principal de la bannière',
      ),
      _buildTextField(
        label: 'Sous-titre',
        value: block.getConfig<String>('subtitle', '') ?? '',
        onChanged: (v) => _updateBlockConfig('subtitle', v),
        helperText: 'Texte secondaire (optionnel)',
      ),
      _buildTextField(
        label: 'Texte (fallback)',
        value: block.getConfig<String>('text', '') ?? '',
        onChanged: (v) => _updateBlockConfig('text', v),
        helperText: 'Utilisé si titre absent',
      ),
      _buildTextField(
        label: 'URL Image',
        value: block.getConfig<String>('imageUrl', '') ?? '',
        onChanged: (v) => _updateBlockConfig('imageUrl', v),
        helperText: 'Image de fond (optionnelle)',
      ),
      _buildTextField(
        label: 'Label CTA',
        value: block.getConfig<String>('ctaLabel', '') ?? '',
        onChanged: (v) => _updateBlockConfig('ctaLabel', v),
        helperText: 'Texte du bouton d\'action',
      ),
      _buildTextField(
        label: 'Action CTA',
        value: block.getConfig<String>('ctaAction', '') ?? '',
        onChanged: (v) => _updateBlockConfig('ctaAction', v),
        helperText: 'Route ex: /menu',
      ),
      _buildDropdown<String>(
        label: 'Style',
        value: block.getConfig<String>('style', 'info') ?? 'info',
        items: const ['info', 'promo', 'warning', 'success'],
        onChanged: (v) => _updateBlockConfig('style', v),
      ),
      _buildColorPicker(
        label: 'Couleur de fond',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
      _buildColorPicker(
        label: 'Couleur du texte',
        value: block.getConfig<String>('textColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('textColor', v),
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildInfoConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Titre',
        value: block.getConfig<String>('title', '') ?? '',
        onChanged: (v) => _updateBlockConfig('title', v),
        helperText: 'Titre de l\'information',
      ),
      _buildTextField(
        label: 'Contenu',
        value: block.getConfig<String>('content', '') ?? '',
        onChanged: (v) => _updateBlockConfig('content', v),
        maxLines: 3,
        helperText: 'Texte descriptif',
      ),
      _buildDropdown<String>(
        label: 'Icône',
        value: block.getConfig<String>('icon', 'info') ?? 'info',
        items: const ['info', 'warning', 'success', 'error', 'time', 'phone', 'location', 'email'],
        onChanged: (v) => _updateBlockConfig('icon', v),
      ),
      _buildCheckbox(
        label: 'Mise en évidence',
        value: block.getConfig<bool>('highlight', false) ?? false,
        onChanged: (v) => _updateBlockConfig('highlight', v),
      ),
      _buildColorPicker(
        label: 'Couleur de fond',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
      _buildDropdown<String>(
        label: 'Type d\'action',
        value: block.getConfig<String>('actionType', 'none') ?? 'none',
        items: const ['none', 'call', 'email', 'navigate'],
        onChanged: (v) => _updateBlockConfig('actionType', v),
      ),
      _buildTextField(
        label: 'Valeur de l\'action',
        value: block.getConfig<String>('actionValue', '') ?? '',
        onChanged: (v) => _updateBlockConfig('actionValue', v),
        helperText: 'Numéro, email ou URL',
      ),
    ];
  }

  List<Widget> _buildButtonConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Label',
        value: block.getConfig<String>('label', '') ?? '',
        onChanged: (v) => _updateBlockConfig('label', v),
        helperText: 'Texte du bouton',
      ),
      _buildDropdown<String>(
        label: 'Style',
        value: block.getConfig<String>('style', 'primary') ?? 'primary',
        items: const ['primary', 'secondary', 'outline', 'text'],
        onChanged: (v) => _updateBlockConfig('style', v),
      ),
      _buildDropdown<String>(
        label: 'Alignement',
        value: block.getConfig<String>('alignment', 'center') ?? 'center',
        items: const ['left', 'center', 'right', 'stretch'],
        onChanged: (v) => _updateBlockConfig('alignment', v),
      ),
      _buildColorPicker(
        label: 'Couleur du bouton',
        value: block.getConfig<String>('backgroundColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('backgroundColor', v),
      ),
      _buildColorPicker(
        label: 'Couleur du texte',
        value: block.getConfig<String>('textColor', '') ?? '',
        onChanged: (v) => _updateBlockConfig('textColor', v),
      ),
      _buildNumberField(
        label: 'Border Radius',
        value: block.getConfig<int>('borderRadius', 8) ?? 8,
        onChanged: (v) => _updateBlockConfig('borderRadius', v),
        helperText: 'Arrondi des coins',
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildImageConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'URL Image',
        value: block.getConfig<String>('imageUrl', '') ?? '',
        onChanged: (v) => _updateBlockConfig('imageUrl', v),
        helperText: 'URL de l\'image',
      ),
      _buildTextField(
        label: 'Légende',
        value: block.getConfig<String>('caption', '') ?? '',
        onChanged: (v) => _updateBlockConfig('caption', v),
        helperText: 'Texte sous l\'image (optionnel)',
      ),
      _buildDropdown<String>(
        label: 'Alignement',
        value: block.getConfig<String>('alignment', 'center') ?? 'center',
        items: const ['left', 'center', 'right'],
        onChanged: (v) => _updateBlockConfig('alignment', v),
      ),
      _buildDropdown<String>(
        label: 'Ajustement de l\'image',
        value: block.getConfig<String>('fit', 'cover') ?? 'cover',
        items: const ['cover', 'contain', 'fill', 'fitWidth', 'fitHeight'],
        onChanged: (v) => _updateBlockConfig('fit', v),
      ),
      _buildNumberField(
        label: 'Hauteur',
        value: block.getConfig<int>('height', 300) ?? 300,
        onChanged: (v) => _updateBlockConfig('height', v),
        helperText: 'Hauteur en pixels',
      ),
      _buildNumberField(
        label: 'Border Radius',
        value: block.getConfig<int>('borderRadius', 0) ?? 0,
        onChanged: (v) => _updateBlockConfig('borderRadius', v),
        helperText: 'Arrondi des coins',
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildSpacerConfig(BuilderBlock block) {
    return [
      _buildNumberField(
        label: 'Hauteur',
        value: block.getConfig<int>('height', 24) ?? 24,
        onChanged: (v) => _updateBlockConfig('height', v),
        helperText: 'Hauteur de l\'espace en pixels',
      ),
    ];
  }

  List<Widget> _buildCategoryListConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Titre (optionnel)',
        value: block.getConfig<String>('title', '') ?? '',
        onChanged: (v) => _updateBlockConfig('title', v),
        helperText: 'Titre de la section',
      ),
      _buildDropdown<String>(
        label: 'Mode',
        value: block.getConfig<String>('mode', 'auto') ?? 'auto',
        items: const ['auto', 'custom'],
        onChanged: (v) => _updateBlockConfig('mode', v),
      ),
      _buildDropdown<String>(
        label: 'Layout',
        value: block.getConfig<String>('layout', 'horizontal') ?? 'horizontal',
        items: const ['horizontal', 'grid', 'carousel'],
        onChanged: (v) => _updateBlockConfig('layout', v),
      ),
      // Tap action fields
      ..._buildTapActionFields(block),
    ];
  }

  List<Widget> _buildHtmlConfig(BuilderBlock block) {
    return [
      _buildTextField(
        label: 'Contenu HTML',
        value: block.getConfig<String>('htmlContent', '') ?? '',
        onChanged: (v) => _updateBlockConfig('htmlContent', v),
        maxLines: 10,
        helperText: 'Code HTML personnalisé',
      ),
    ];
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    int maxLines = 1,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey('${label}_$value'), // Unique key for rebuild
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        maxLines: maxLines,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ),
        tileColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildColorPicker({
    required String label,
    required String value,
    required Function(String) onChanged,
  }) {
    // Predefined color palette
    final colors = {
      '': 'Par défaut',
      '#DC2626': 'Rouge',
      '#EA580C': 'Orange',
      '#CA8A04': 'Jaune',
      '#16A34A': 'Vert',
      '#0284C7': 'Bleu',
      '#9333EA': 'Violet',
      '#DB2777': 'Rose',
      '#000000': 'Noir',
      '#FFFFFF': 'Blanc',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.entries.map((entry) {
              final isSelected = value == entry.key;
              Color colorValue;
              
              if (entry.key.isEmpty) {
                colorValue = Colors.grey.shade300;
              } else {
                try {
                  colorValue = Color(int.parse(entry.key.replaceAll('#', '0xFF')));
                } catch (e) {
                  // Fallback to grey if color parsing fails
                  colorValue = Colors.grey.shade300;
                  debugPrint('Invalid color format: ${entry.key}');
                }
              }
              
              return InkWell(
                onTap: () => onChanged(entry.key),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorValue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: entry.key.isEmpty
                      ? const Icon(Icons.block, color: Colors.grey)
                      : null,
                ),
              );
            }).toList(),
          ),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Sélectionné: ${colors[value] ?? value}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddBlockDialog() {
    // Filter out system type from regular blocks
    final regularBlocks = BlockType.values.where((t) => t != BlockType.system).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un bloc'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Regular blocks section
                const Text(
                  'Blocs de contenu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Divider(),
                ...regularBlocks.map((type) => ListTile(
                  leading: Text(
                    type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(type.label),
                  onTap: () {
                    Navigator.pop(context);
                    _addBlock(type);
                  },
                )),
                
                const SizedBox(height: 16),
                
                // System modules section
                const Text(
                  'Modules système',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Divider(color: Colors.blue),
                ListTile(
                  leading: Icon(Icons.shopping_cart, size: 28, color: Colors.green.shade600),
                  title: const Text('Ajouter module Panier'),
                  subtitle: const Text('Panier et validation'),
                  onTap: () {
                    Navigator.pop(context);
                    _addSystemBlock('cart_module');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.casino, size: 28, color: Colors.purple.shade600),
                  title: const Text('Ajouter module Roulette'),
                  subtitle: const Text('Roue de la chance'),
                  onTap: () {
                    Navigator.pop(context);
                    _addSystemBlock('roulette');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.card_giftcard, size: 28, color: Colors.amber.shade600),
                  title: const Text('Ajouter module Fidélité'),
                  subtitle: const Text('Points et progression'),
                  onTap: () {
                    Navigator.pop(context);
                    _addSystemBlock('loyalty');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.stars, size: 28, color: Colors.orange.shade600),
                  title: const Text('Ajouter module Récompenses'),
                  subtitle: const Text('Tickets et bons'),
                  onTap: () {
                    Navigator.pop(context);
                    _addSystemBlock('rewards');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history, size: 28, color: Colors.blue.shade600),
                  title: const Text('Ajouter module Activité du compte'),
                  subtitle: const Text('Commandes et favoris'),
                  onTap: () {
                    Navigator.pop(context);
                    _addSystemBlock('accountActivity');
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  /// Add a system block with the specified module type
  void _addSystemBlock(String moduleType) {
    if (_page == null) return;

    final newBlock = SystemBlock(
      id: 'block_${DateTime.now().millisecondsSinceEpoch}',
      moduleType: moduleType,
      order: _page!.draftLayout.length,
    );

    setState(() {
      _page = _page!.addBlock(newBlock);
      _hasChanges = true;
      _selectedBlock = newBlock;
    });
    _scheduleAutoSave();
  }

  /// Build tap action configuration fields
  /// 
  /// Shows:
  /// - Action type dropdown (none, openPage, openLegacyPage, openUrl)
  /// - Conditional target field based on action type
  List<Widget> _buildTapActionFields(BuilderBlock block) {
    final tapAction = block.getConfig<String>('tapAction', 'none') ?? 'none';
    final tapActionTarget = block.getConfig<String>('tapActionTarget', '') ?? '';

    return [
      const Divider(height: 32),
      const Text(
        '🔗 Action au clic',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
      const SizedBox(height: 12),
      _buildDropdown<String>(
        label: 'Type d\'action',
        value: tapAction,
        items: const ['none', 'openPage', 'openLegacyPage', 'openSystemPage', 'openUrl'],
        onChanged: (v) {
          _updateBlockConfigMultiple({
            'tapAction': v,
            'tapActionTarget': '', // Reset target when action type changes
          });
        },
      ),
      // Show target field based on action type
      if (tapAction == 'openPage')
        _buildTextField(
          label: 'ID de la page Builder',
          value: tapActionTarget,
          onChanged: (v) => _updateBlockConfig('tapActionTarget', v),
          helperText: 'Ex: promo, menu, about',
        ),
      if (tapAction == 'openLegacyPage' && LegacyRoutes.values.isNotEmpty)
        _buildDropdown<String>(
          label: 'Route de l\'application',
          value: LegacyRoutes.values.contains(tapActionTarget) 
              ? tapActionTarget 
              : LegacyRoutes.values.first,
          items: LegacyRoutes.values,
          onChanged: (v) => _updateBlockConfig('tapActionTarget', v),
        ),
      if (tapAction == 'openSystemPage')
        _buildDropdown<String>(
          label: 'Page système',
          value: SystemPageRoutes.values.contains(tapActionTarget)
              ? tapActionTarget
              : SystemPageRoutes.values.first,
          items: SystemPageRoutes.values,
          onChanged: (v) => _updateBlockConfig('tapActionTarget', v),
        ),
      if (tapAction == 'openSystemPage')
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ouvre la page système avec la version Builder si disponible.',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),
      if (tapAction == 'openUrl')
        _buildTextField(
          label: 'URL externe',
          value: tapActionTarget,
          onChanged: (v) => _updateBlockConfig('tapActionTarget', v),
          helperText: 'Ex: https://example.com',
        ),
    ];
  }

  /// Build padding/margin/spacing fields
  Widget _buildNumberField({
    required String label,
    required int value,
    required Function(int) onChanged,
    String? helperText,
    int min = 0,
    int max = 999,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey('${label}_$value'), // Unique key for rebuild
        initialValue: value.toString(),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        onChanged: (v) {
          final parsed = int.tryParse(v) ?? value;
          onChanged(parsed.clamp(min, max));
        },
      ),
    );
  }
}
