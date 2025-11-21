// lib/src/screens/admin/studio/admin_studio_unified.dart
// ⚠️ DEPRECATED - Unified Studio - Superseded by StudioV2Screen
// Route /admin/studio/new now redirects to /admin/studio (Studio V2)
// Use lib/src/studio/screens/studio_v2_screen.dart instead
// See STUDIO_V2_CLEANUP_NOTES.md for details

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/home_config.dart';
import '../../../models/app_texts_config.dart';
import '../../../models/popup_config.dart';
import '../../../models/banner_config.dart';
import '../../../models/home_layout_config.dart';
import '../../../services/home_config_service.dart';
import '../../../services/home_layout_service.dart';
import '../../../services/popup_service.dart';
import '../../../services/banner_service.dart';
import '../../../services/app_texts_service.dart';
import '../../../widgets/admin/admin_home_preview.dart';
import 'modules/studio_overview_module.dart';
import 'modules/studio_hero_module.dart';
import 'modules/studio_banner_module.dart';
import 'modules/studio_popups_module.dart';
import 'modules/studio_texts_module.dart';
import 'modules/studio_settings_module.dart';

/// Unified Admin Studio Screen
/// Complete implementation with 6 modules:
/// 1. Overview (dashboard)
/// 2. Hero editor
/// 3. Banner manager (multiple programmable banners)
/// 4. Popups manager (full CRUD with scheduling)
/// 5. Texts editor (all app texts)
/// 6. Settings (studio toggle + layout + categories)
class AdminStudioUnified extends ConsumerStatefulWidget {
  const AdminStudioUnified({super.key});

  @override
  ConsumerState<AdminStudioUnified> createState() => _AdminStudioUnifiedState();
}

class _AdminStudioUnifiedState extends ConsumerState<AdminStudioUnified> {
  // Services
  final HomeConfigService _homeConfigService = HomeConfigService();
  final HomeLayoutService _homeLayoutService = HomeLayoutService();
  final PopupService _popupService = PopupService();
  final BannerService _bannerService = BannerService();
  final AppTextsService _appTextsService = AppTextsService();

  // Current selected section
  String _selectedSection = 'overview';

  // Draft state (local only, not saved to DB until publish)
  HomeConfig? _draftHomeConfig;
  HomeLayoutConfig? _draftLayoutConfig;
  AppTextsConfig? _draftTextsConfig;
  List<PopupConfig> _draftPopups = [];
  List<BannerConfig> _draftBanners = [];

  // Published state (loaded from DB)
  HomeConfig? _publishedHomeConfig;
  HomeLayoutConfig? _publishedLayoutConfig;
  AppTextsConfig? _publishedTextsConfig;
  List<PopupConfig> _publishedPopups = [];
  List<BannerConfig> _publishedBanners = [];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  /// Initialize home layout if missing, then load all configurations
  Future<void> _initializeAndLoad() async {
    // First, ensure home_layout document exists
    await _homeLayoutService.initIfMissing();
    // Then load all configurations
    await _loadAllConfigurations();
  }

  /// Load all configurations from Firestore
  Future<void> _loadAllConfigurations() async {
    setState(() => _isLoading = true);

    try {
      // Load home config
      final homeConfig = await _homeConfigService.getHomeConfig();
      _publishedHomeConfig = homeConfig ?? HomeConfig.initial();
      _draftHomeConfig = _publishedHomeConfig?.copyWith();

      // Load layout config
      final layoutConfig = await _homeLayoutService.getHomeLayout();
      _publishedLayoutConfig = layoutConfig ?? HomeLayoutConfig.defaultConfig();
      _draftLayoutConfig = _publishedLayoutConfig?.copyWith();

      // Load texts config
      final textsConfig = await _appTextsService.getAppTextsConfig();
      _publishedTextsConfig = textsConfig ?? AppTextsConfig.defaultConfig();
      _draftTextsConfig = _publishedTextsConfig?.copyWith();

      // Load popups
      final popups = await _popupService.getAllPopups();
      _publishedPopups = popups;
      _draftPopups = List.from(popups);

      // Load banners
      final banners = await _bannerService.getAllBanners();
      _publishedBanners = banners;
      _draftBanners = List.from(banners);

      setState(() => _hasUnsavedChanges = false);
    } catch (e) {
      _showSnackBar('Erreur lors du chargement: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Publish all draft changes to Firestore
  Future<void> _publishChanges() async {
    if (!_hasUnsavedChanges) return;

    setState(() => _isSaving = true);

    try {
      // Save home config
      if (_draftHomeConfig != null) {
        await _homeConfigService.saveHomeConfig(_draftHomeConfig!);
      }

      // Save layout config
      if (_draftLayoutConfig != null) {
        await _homeLayoutService.saveHomeLayout(_draftLayoutConfig!);
      }

      // Save texts config
      if (_draftTextsConfig != null) {
        await _appTextsService.saveAppTextsConfig(_draftTextsConfig!);
      }

      // Save banners (only if changed)
      for (final banner in _draftBanners) {
        final existingBanner = _publishedBanners.firstWhere(
          (b) => b.id == banner.id,
          orElse: () => BannerConfig.defaultBanner(),
        );
        if (banner != existingBanner) {
          if (_publishedBanners.any((b) => b.id == banner.id)) {
            await _bannerService.updateBanner(banner);
          } else {
            await _bannerService.createBanner(banner);
          }
        }
      }

      // Delete removed banners
      for (final publishedBanner in _publishedBanners) {
        if (!_draftBanners.any((b) => b.id == publishedBanner.id)) {
          await _bannerService.deleteBanner(publishedBanner.id);
        }
      }

      // Save popups (only if changed)
      for (final popup in _draftPopups) {
        final existingPopup = _publishedPopups.firstWhere(
          (p) => p.id == popup.id,
          orElse: () => PopupConfig(
            id: '',
            title: '',
            message: '',
            createdAt: DateTime.now(),
          ),
        );
        if (popup.id.isNotEmpty && popup != existingPopup) {
          if (_publishedPopups.any((p) => p.id == popup.id)) {
            await _popupService.updatePopup(popup);
          } else {
            await _popupService.createPopup(popup);
          }
        }
      }

      // Delete removed popups
      for (final publishedPopup in _publishedPopups) {
        if (!_draftPopups.any((p) => p.id == publishedPopup.id)) {
          await _popupService.deletePopup(publishedPopup.id);
        }
      }

      // Update published state
      _publishedHomeConfig = _draftHomeConfig?.copyWith();
      _publishedLayoutConfig = _draftLayoutConfig?.copyWith();
      _publishedTextsConfig = _draftTextsConfig?.copyWith();
      _publishedPopups = List.from(_draftPopups);
      _publishedBanners = List.from(_draftBanners);

      setState(() => _hasUnsavedChanges = false);
      _showSnackBar('✓ Modifications publiées avec succès', isError: false);
    } catch (e) {
      _showSnackBar('Erreur lors de la publication: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Cancel all draft changes and reload from DB
  Future<void> _cancelChanges() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (shouldCancel == true) {
      setState(() {
        _draftHomeConfig = _publishedHomeConfig?.copyWith();
        _draftLayoutConfig = _publishedLayoutConfig?.copyWith();
        _draftTextsConfig = _publishedTextsConfig?.copyWith();
        _draftPopups = List.from(_publishedPopups);
        _draftBanners = List.from(_publishedBanners);
        _hasUnsavedChanges = false;
      });
      _showSnackBar('Modifications annulées', isError: false);
    }
  }

  /// Mark draft as changed
  void _markChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Studio Admin Unifié'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_hasUnsavedChanges) {
              _showUnsavedWarning(() => context.pop());
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          if (_hasUnsavedChanges) ...[
            TextButton.icon(
              onPressed: _isSaving ? null : _cancelChanges,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Annuler'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _isSaving ? null : _publishChanges,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.publish),
              label: Text(_isSaving ? 'Publication...' : 'Publier'),
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isDesktop
              ? _buildDesktopLayout()
              : _buildMobileLayout(),
    );
  }

  /// Show warning when trying to leave with unsaved changes
  void _showUnsavedWarning(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifications non enregistrées'),
        content: const Text(
          'Vous avez des modifications non publiées. Voulez-vous vraiment quitter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Rester'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  /// Desktop layout with 3 columns (nav, content, preview)
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Navigation
        SizedBox(
          width: 250,
          child: _buildNavigation(),
        ),
        const VerticalDivider(width: 1),
        // Center: Content
        Expanded(
          flex: 2,
          child: _buildSectionContent(),
        ),
        const VerticalDivider(width: 1),
        // Right: Preview
        Expanded(
          flex: 1,
          child: _buildPreviewPanel(),
        ),
      ],
    );
  }

  /// Mobile layout with tabs
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildNavigation(),
        const Divider(height: 1),
        Expanded(child: _buildSectionContent()),
      ],
    );
  }

  /// Navigation sidebar/tabs
  Widget _buildNavigation() {
    final sections = [
      {'id': 'overview', 'icon': Icons.dashboard, 'title': 'Vue d\'ensemble'},
      {'id': 'hero', 'icon': Icons.image, 'title': 'Hero'},
      {'id': 'banner', 'icon': Icons.flag, 'title': 'Bandeaux'},
      {'id': 'popups', 'icon': Icons.campaign, 'title': 'Popups'},
      {'id': 'texts', 'icon': Icons.notes, 'title': 'Textes'},
      {'id': 'settings', 'icon': Icons.settings, 'title': 'Paramètres'},
    ];

    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Container(
      color: AppColors.surface,
      height: isDesktop ? null : 60,
      child: isDesktop
          ? ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: sections.map((section) {
                final isSelected = _selectedSection == section['id'];
                return ListTile(
                  leading: Icon(
                    section['icon'] as IconData,
                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                  ),
                  title: Text(
                    section['title'] as String,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedTileColor: AppColors.primaryContainer,
                  onTap: () {
                    setState(() => _selectedSection = section['id'] as String);
                  },
                );
              }).toList(),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: sections.map((section) {
                  final isSelected = _selectedSection == section['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      avatar: Icon(
                        section['icon'] as IconData,
                        size: 18,
                        color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                      ),
                      label: Text(section['title'] as String),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedSection = section['id'] as String);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  /// Main content area based on selected section
  Widget _buildSectionContent() {
    switch (_selectedSection) {
      case 'overview':
        return StudioOverviewModule(
          draftHomeConfig: _draftHomeConfig,
          draftLayoutConfig: _draftLayoutConfig,
          draftPopups: _draftPopups,
          draftBanners: _draftBanners,
          onReload: _loadAllConfigurations,
          onToggleStudio: (enabled) {
            setState(() {
              _draftLayoutConfig = _draftLayoutConfig?.copyWith(studioEnabled: enabled);
              _markChanged();
            });
          },
        );
      case 'hero':
        return StudioHeroModule(
          draftHomeConfig: _draftHomeConfig,
          onUpdate: (config) {
            setState(() {
              _draftHomeConfig = config;
              _markChanged();
            });
          },
        );
      case 'banner':
        return StudioBannerModule(
          draftBanners: _draftBanners,
          onUpdate: (banners) {
            setState(() {
              _draftBanners = banners;
              _markChanged();
            });
          },
        );
      case 'popups':
        return StudioPopupsModule(
          draftPopups: _draftPopups,
          onUpdate: (popups) {
            setState(() {
              _draftPopups = popups;
              _markChanged();
            });
          },
        );
      case 'texts':
        return StudioTextsModule(
          draftTextsConfig: _draftTextsConfig,
          onUpdate: (config) {
            setState(() {
              _draftTextsConfig = config;
              _markChanged();
            });
          },
        );
      case 'settings':
        return StudioSettingsModule(
          draftLayoutConfig: _draftLayoutConfig,
          onUpdate: (config) {
            setState(() {
              _draftLayoutConfig = config;
              _markChanged();
            });
          },
        );
      default:
        return const Center(child: Text('Section inconnue'));
    }
  }

  /// Preview panel
  Widget _buildPreviewPanel() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: AdminHomePreview(
              homeConfig: _draftHomeConfig,
              homeTexts: _draftTextsConfig?.home,
              popups: _draftPopups,
              banners: _draftBanners,
              sectionsOrder: _draftLayoutConfig?.sectionsOrder,
              enabledSections: _draftLayoutConfig?.enabledSections,
              studioEnabled: _draftLayoutConfig?.studioEnabled,
            ),
          );
        },
      ),
    );
  }
}
