// lib/src/studio/screens/studio_v2_screen.dart
// Studio Admin V2 - Professional, modular, Webflow/Shopify-inspired interface

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../controllers/studio_state_controller.dart';
import '../widgets/studio_navigation.dart';
import '../widgets/studio_preview_panel.dart';
import '../widgets/modules/studio_overview_v2.dart';
import '../widgets/modules/studio_hero_v2.dart';
import '../widgets/modules/studio_banners_v2.dart';
import '../widgets/modules/studio_popups_v2.dart';
import '../widgets/modules/studio_texts_v2.dart';
import '../widgets/modules/studio_settings_v2.dart';
import '../../services/home_config_service.dart';
import '../../services/home_layout_service.dart';
import '../../services/banner_service.dart';
import '../services/text_block_service.dart';
import '../services/popup_v2_service.dart';
import '../../models/home_config.dart';
import '../../models/home_layout_config.dart';
import '../../models/banner_config.dart';
import '../models/text_block_model.dart';
import '../models/popup_v2_model.dart';

/// Studio Admin V2 - Complete Professional Implementation
/// 
/// Features:
/// - 6 Modules: Overview, Hero, Banners, Popups, Text Blocks, Settings
/// - Draft/Publish mode with local state management
/// - Real-time preview panel
/// - Drag & drop ordering
/// - Professional UI inspired by Webflow/Shopify
/// - Fully responsive (desktop 3-column, mobile tabs)
class StudioV2Screen extends ConsumerStatefulWidget {
  const StudioV2Screen({super.key});

  @override
  ConsumerState<StudioV2Screen> createState() => _StudioV2ScreenState();
}

class _StudioV2ScreenState extends ConsumerState<StudioV2Screen> {
  // Services
  final _homeConfigService = HomeConfigService();
  final _homeLayoutService = HomeLayoutService();
  final _bannerService = BannerService();
  final _textBlockService = TextBlockService();
  final _popupV2Service = PopupV2Service();

  // Published state (from Firestore)
  HomeConfig? _publishedHomeConfig;
  HomeLayoutConfig? _publishedLayoutConfig;
  List<BannerConfig> _publishedBanners = [];
  List<TextBlockModel> _publishedTextBlocks = [];
  List<PopupV2Model> _publishedPopupsV2 = [];

  @override
  void initState() {
    super.initState();
    // FIX: Riverpod provider updates must be deferred using Future.microtask
    // to avoid "Modifying a provider inside widget lifecycle" error
    Future.microtask(() => _loadAllData());
  }

  /// Load all configurations from Firestore
  Future<void> _loadAllData() async {
    // FIX: Riverpod provider updated safely using Future.microtask in initState
    ref.read(studioLoadingProvider.notifier).state = true;

    try {
      // Initialize services if needed
      await _homeLayoutService.initIfMissing();
      await _textBlockService.initializeDefaultBlocks();

      // Load all data
      final homeConfig = await _homeConfigService.getHomeConfig();
      final layoutConfig = await _homeLayoutService.getHomeLayout();
      final banners = await _bannerService.getAllBanners();
      final textBlocks = await _textBlockService.getAllTextBlocks();
      final popupsV2 = await _popupV2Service.getAllPopups();

      // Store published state
      _publishedHomeConfig = homeConfig ?? HomeConfig.initial();
      _publishedLayoutConfig = layoutConfig ?? HomeLayoutConfig.defaultConfig();
      _publishedBanners = banners;
      _publishedTextBlocks = textBlocks;
      _publishedPopupsV2 = popupsV2;

      // Initialize draft state
      // FIX: This provider update is safe because it's called via Future.microtask
      ref.read(studioDraftStateProvider.notifier).loadInitialState(
            homeConfig: _publishedHomeConfig,
            layoutConfig: _publishedLayoutConfig,
            banners: List.from(_publishedBanners),
            popupsV2: List.from(_publishedPopupsV2),
            textBlocks: List.from(_publishedTextBlocks),
          );
    } catch (e) {
      _showError('Erreur lors du chargement: $e');
    } finally {
      // FIX: This provider update is safe because it's called via Future.microtask
      ref.read(studioLoadingProvider.notifier).state = false;
    }
  }

  /// Publish all draft changes to Firestore
  Future<void> _publishChanges() async {
    final draftState = ref.read(studioDraftStateProvider);
    
    if (!draftState.hasUnsavedChanges) {
      _showInfo('Aucune modification à publier');
      return;
    }

    ref.read(studioSavingProvider.notifier).state = true;

    try {
      // Save home config
      if (draftState.homeConfig != null) {
        await _homeConfigService.saveHomeConfig(draftState.homeConfig!);
      }

      // Save layout config
      if (draftState.layoutConfig != null) {
        await _homeLayoutService.saveHomeLayout(draftState.layoutConfig!);
      }

      // Save banners
      await _bannerService.saveAllBanners(draftState.banners);

      // Save text blocks
      await _textBlockService.saveAllTextBlocks(draftState.textBlocks);

      // Save popups V2
      await _popupV2Service.saveAllPopups(draftState.popupsV2);

      // Update published state
      _publishedHomeConfig = draftState.homeConfig;
      _publishedLayoutConfig = draftState.layoutConfig;
      _publishedBanners = List.from(draftState.banners);
      _publishedTextBlocks = List.from(draftState.textBlocks);
      _publishedPopupsV2 = List.from(draftState.popupsV2);

      // Mark as saved
      ref.read(studioDraftStateProvider.notifier).markSaved();

      _showSuccess('✓ Modifications publiées avec succès');
    } catch (e) {
      _showError('Erreur lors de la publication: $e');
    } finally {
      ref.read(studioSavingProvider.notifier).state = false;
    }
  }

  /// Cancel all draft changes
  Future<void> _cancelChanges() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler les modifications ?'),
        content: const Text(
          'Toutes les modifications non publiées seront perdues. Continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      final publishedState = StudioDraftState(
        homeConfig: _publishedHomeConfig,
        layoutConfig: _publishedLayoutConfig,
        banners: List.from(_publishedBanners),
        popupsV2: List.from(_publishedPopupsV2),
        textBlocks: List.from(_publishedTextBlocks),
      );
      
      ref.read(studioDraftStateProvider.notifier).resetToPublished(publishedState);
      _showInfo('Modifications annulées');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSection = ref.watch(studioSelectedSectionProvider);
    final isLoading = ref.watch(studioLoadingProvider);
    final isSaving = ref.watch(studioSavingProvider);
    final draftState = ref.watch(studioDraftStateProvider);

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Mobile layout (< 800px)
          if (constraints.maxWidth < 800) {
            return _buildMobileLayout(selectedSection, draftState, isSaving);
          }
          
          // Desktop layout (>= 800px)
          return _buildDesktopLayout(selectedSection, draftState, isSaving);
        },
      ),
    );
  }

  /// Desktop 3-column layout
  Widget _buildDesktopLayout(
    String selectedSection,
    StudioDraftState draftState,
    bool isSaving,
  ) {
    return Row(
      children: [
        // Left: Navigation
        SizedBox(
          width: 240,
          child: StudioNavigation(
            selectedSection: selectedSection,
            onSectionChanged: (section) {
              ref.read(studioSelectedSectionProvider.notifier).state = section;
            },
            hasUnsavedChanges: draftState.hasUnsavedChanges,
            onPublish: _publishChanges,
            onCancel: _cancelChanges,
            isSaving: isSaving,
          ),
        ),

        // Center: Editor panel
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            child: _buildEditorPanel(selectedSection, draftState),
          ),
        ),

        // Right: Preview panel
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F7),
              border: Border(
                left: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: StudioPreviewPanel(
              homeConfig: draftState.homeConfig,
              layoutConfig: draftState.layoutConfig,
              banners: draftState.banners,
              popupsV2: draftState.popupsV2,
              textBlocks: draftState.textBlocks,
            ),
          ),
        ),
      ],
    );
  }

  /// Mobile tab-based layout
  Widget _buildMobileLayout(
    String selectedSection,
    StudioDraftState draftState,
    bool isSaving,
  ) {
    return Column(
      children: [
        // Top navigation bar
        Container(
          color: Colors.white,
          child: StudioNavigation(
            selectedSection: selectedSection,
            onSectionChanged: (section) {
              ref.read(studioSelectedSectionProvider.notifier).state = section;
            },
            hasUnsavedChanges: draftState.hasUnsavedChanges,
            onPublish: _publishChanges,
            onCancel: _cancelChanges,
            isSaving: isSaving,
            isMobile: true,
          ),
        ),
        
        // Editor content
        Expanded(
          child: _buildEditorPanel(selectedSection, draftState),
        ),
      ],
    );
  }

  /// Build editor panel based on selected section
  Widget _buildEditorPanel(String selectedSection, StudioDraftState draftState) {
    switch (selectedSection) {
      case 'overview':
        return StudioOverviewV2(draftState: draftState);
      case 'hero':
        return StudioHeroV2(
          homeConfig: draftState.homeConfig,
          onUpdate: (config) {
            ref.read(studioDraftStateProvider.notifier).setHomeConfig(config);
          },
        );
      case 'banners':
        return StudioBannersV2(
          banners: draftState.banners,
          onUpdate: (banners) {
            ref.read(studioDraftStateProvider.notifier).setBanners(banners);
          },
        );
      case 'popups':
        return StudioPopupsV2(
          popups: draftState.popupsV2,
          onUpdate: (popups) {
            ref.read(studioDraftStateProvider.notifier).setPopupsV2(popups);
          },
        );
      case 'texts':
        return StudioTextsV2(
          textBlocks: draftState.textBlocks,
          onUpdate: (blocks) {
            ref.read(studioDraftStateProvider.notifier).setTextBlocks(blocks);
          },
        );
      case 'settings':
        return StudioSettingsV2(
          layoutConfig: draftState.layoutConfig,
          onUpdate: (config) {
            ref.read(studioDraftStateProvider.notifier).setLayoutConfig(config);
          },
        );
      default:
        return const Center(child: Text('Section non trouvée'));
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
