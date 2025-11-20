// lib/src/screens/admin/admin_studio_screen_refactored.dart
// NOUVEAU Studio Builder - Écran principal unifié REFONTE COMPLÈTE
// Avec prévisualisation LIVE, mode brouillon, drag & drop, et toggle global

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../models/home_config.dart';
import '../../models/app_texts_config.dart';
import '../../models/popup_config.dart';
import '../../models/home_layout_config.dart';
import '../../providers/home_config_provider.dart';
import '../../providers/app_texts_provider.dart';
import '../../providers/home_layout_provider.dart';
import '../../services/home_config_service.dart';
import '../../services/home_layout_service.dart';
import '../../services/popup_service.dart';
import '../../services/app_texts_service.dart';
import '../../widgets/admin/admin_home_preview.dart';
import 'studio/hero_block_editor.dart';
import 'studio/banner_block_editor.dart';
import 'studio/popup_block_list.dart';
import 'studio/studio_texts_screen.dart';

/// NOUVEAU Studio Builder - Interface unifiée REFACTORED
/// 
/// ARCHITECTURE MODERNE:
/// - Vue d'ensemble avec prévisualisation LIVE
/// - Mode brouillon (état local uniquement, pas de DB)
/// - Drag & drop pour réorganiser sections
/// - Toggle global pour activer/désactiver tout le studio
/// - Navigation interne entre sections
class AdminStudioScreenRefactored extends ConsumerStatefulWidget {
  const AdminStudioScreenRefactored({super.key});

  @override
  ConsumerState<AdminStudioScreenRefactored> createState() => _AdminStudioScreenRefactoredState();
}

class _AdminStudioScreenRefactoredState extends ConsumerState<AdminStudioScreenRefactored> {
  // Services
  final HomeConfigService _homeConfigService = HomeConfigService();
  final HomeLayoutService _homeLayoutService = HomeLayoutService();
  final PopupService _popupService = PopupService();
  final AppTextsService _appTextsService = AppTextsService();

  // Current selected section
  String _selectedSection = 'overview';

  // Draft state (local only, not saved to DB until publish)
  HomeConfig? _draftHomeConfig;
  HomeLayoutConfig? _draftLayoutConfig;
  AppTextsConfig? _draftTextsConfig;
  List<PopupConfig> _draftPopups = [];

  // Published state (loaded from DB)
  HomeConfig? _publishedHomeConfig;
  HomeLayoutConfig? _publishedLayoutConfig;
  AppTextsConfig? _publishedTextsConfig;
  List<PopupConfig> _publishedPopups = [];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadAllConfigurations();
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
      final textsConfig = await _appTextsService.getTextsConfig();
      _publishedTextsConfig = textsConfig ?? AppTextsConfig.defaultConfig();
      _draftTextsConfig = _publishedTextsConfig?.copyWith();

      // Load popups
      final popups = await _popupService.getAllPopups();
      _publishedPopups = popups;
      _draftPopups = List.from(popups);
    } catch (e) {
      _showSnackBar('Erreur lors du chargement: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Publish all draft changes to Firestore
  Future<void> _publishChanges() async {
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
        await _appTextsService.saveTextsConfig(_draftTextsConfig!);
      }

      // Update published state
      _publishedHomeConfig = _draftHomeConfig?.copyWith();
      _publishedLayoutConfig = _draftLayoutConfig?.copyWith();
      _publishedTextsConfig = _draftTextsConfig?.copyWith();
      _publishedPopups = List.from(_draftPopups);

      setState(() => _hasUnsavedChanges = false);
      _showSnackBar('Modifications publiées avec succès ✓', isError: false);

      // Invalidate providers to refresh
      ref.invalidate(homeConfigProvider);
      ref.invalidate(homeLayoutProvider);
      ref.invalidate(appTextsConfigProvider);
    } catch (e) {
      _showSnackBar('Erreur lors de la publication: $e', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Cancel all draft changes and reload from DB
  Future<void> _cancelChanges() async {
    setState(() {
      _draftHomeConfig = _publishedHomeConfig?.copyWith();
      _draftLayoutConfig = _publishedLayoutConfig?.copyWith();
      _draftTextsConfig = _publishedTextsConfig?.copyWith();
      _draftPopups = List.from(_publishedPopups);
      _hasUnsavedChanges = false;
    });
    _showSnackBar('Modifications annulées', isError: false);
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
        title: const Text('Studio - Contenu & Apparence'),
        centerTitle: false,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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

  /// Desktop layout with 3 columns
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
      {'id': 'banner', 'icon': Icons.flag, 'title': 'Bandeau'},
      {'id': 'popups', 'icon': Icons.campaign, 'title': 'Popups'},
      {'id': 'texts', 'icon': Icons.notes, 'title': 'Textes'},
      {'id': 'settings', 'icon': Icons.settings, 'title': 'Paramètres'},
    ];

    return Container(
      color: AppColors.surface,
      child: ListView(
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
      ),
    );
  }

  /// Main content area based on selected section
  Widget _buildSectionContent() {
    switch (_selectedSection) {
      case 'overview':
        return _buildOverviewSection();
      case 'hero':
        return _buildHeroSection();
      case 'banner':
        return _buildBannerSection();
      case 'popups':
        return _buildPopupsSection();
      case 'texts':
        return _buildTextsSection();
      case 'settings':
        return _buildSettingsSection();
      default:
        return _buildOverviewSection();
    }
  }

  /// Preview panel
  Widget _buildPreviewPanel() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: AdminHomePreview(
        homeConfig: _draftHomeConfig,
        homeTexts: _draftTextsConfig?.home,
        popups: _draftPopups,
        sectionsOrder: _draftLayoutConfig?.sectionsOrder,
        enabledSections: _draftLayoutConfig?.enabledSections,
        studioEnabled: _draftLayoutConfig?.studioEnabled,
      ),
    );
  }

  /// Overview section with quick stats and preview
  Widget _buildOverviewSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vue d\'ensemble', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Hero', _draftHomeConfig?.hero?.isActive == true, Icons.image),
        _buildStatCard('Bandeau', _draftLayoutConfig?.isSectionEnabled('banner') ?? false, Icons.flag),
        _buildStatCard('Popups', _draftPopups.where((p) => p.isCurrentlyActive).length.toString(), Icons.campaign),
        _buildStatCard('Studio', _draftLayoutConfig?.studioEnabled == true, Icons.visibility),
      ],
    );
  }

  Widget _buildStatCard(String title, dynamic value, IconData icon) {
    final isActive = value is bool ? value : (value is String && value != '0');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isActive ? AppColors.primary : AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelSmall),
                Text(
                  value is bool ? (value ? 'Actif' : 'Inactif') : value.toString(),
                  style: AppTextStyles.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actions rapides', style: AppTextStyles.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Recharger depuis la base de données'),
              onTap: _loadAllConfigurations,
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off),
              title: const Text('Désactiver tout le studio'),
              onTap: () {
                setState(() {
                  _draftLayoutConfig = _draftLayoutConfig?.copyWith(studioEnabled: false);
                  _hasUnsavedChanges = true;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Activer le studio'),
              onTap: () {
                setState(() {
                  _draftLayoutConfig = _draftLayoutConfig?.copyWith(studioEnabled: true);
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Hero section
  Widget _buildHeroSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configuration Hero', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Activer le Hero'),
                    value: _draftHomeConfig?.hero?.isActive ?? false,
                    onChanged: (value) {
                      setState(() {
                        _draftHomeConfig = _draftHomeConfig?.copyWith(
                          hero: _draftHomeConfig?.hero?.copyWith(isActive: value) ?? 
                                 HeroConfig(isActive: value, imageUrl: '', title: '', subtitle: '', ctaText: '', ctaAction: ''),
                        );
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Éditer le Hero en détail'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HeroBlockEditor(
                            initialHero: _draftHomeConfig?.hero,
                            onSaved: () {
                              _loadAllConfigurations();
                              setState(() => _hasUnsavedChanges = true);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Banner section
  Widget _buildBannerSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configuration Bandeau', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Activer le bandeau'),
                    value: _draftHomeConfig?.promoBanner?.isActive ?? false,
                    onChanged: (value) {
                      setState(() {
                        _draftHomeConfig = _draftHomeConfig?.copyWith(
                          promoBanner: _draftHomeConfig?.promoBanner?.copyWith(isActive: value) ?? 
                                       PromoBannerConfig(isActive: value, text: ''),
                        );
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                  const Divider(),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Texte du bandeau'),
                    controller: TextEditingController(text: _draftHomeConfig?.promoBanner?.text ?? ''),
                    onChanged: (value) {
                      setState(() {
                        _draftHomeConfig = _draftHomeConfig?.copyWith(
                          promoBanner: _draftHomeConfig?.promoBanner?.copyWith(text: value) ?? 
                                       PromoBannerConfig(isActive: true, text: value),
                        );
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Popups section
  Widget _buildPopupsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configuration Popups', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('${_draftPopups.where((p) => p.isCurrentlyActive).length} popup(s) actif(s)'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PopupBlockList()),
                      );
                      _loadAllConfigurations();
                    },
                    child: const Text('Gérer les popups'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Texts section
  Widget _buildTextsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Configuration Textes', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Gérer tous les textes de l\'application'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const StudioTextsScreen()),
                      );
                      _loadAllConfigurations();
                    },
                    child: const Text('Éditer les textes'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Settings section with drag & drop and global toggle
  Widget _buildSettingsSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Paramètres du Studio', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 24),
          
          // Global toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SwitchListTile(
                title: const Text('Studio activé'),
                subtitle: const Text('Désactiver masque tous les éléments (Hero, Bandeau, Popups) côté client'),
                value: _draftLayoutConfig?.studioEnabled ?? true,
                onChanged: (value) {
                  setState(() {
                    _draftLayoutConfig = _draftLayoutConfig?.copyWith(studioEnabled: value);
                    _hasUnsavedChanges = true;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sections order and activation
          Text('Ordre et activation des sections', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          _buildSectionsOrderEditor(),
        ],
      ),
    );
  }

  Widget _buildSectionsOrderEditor() {
    final sections = _draftLayoutConfig?.sectionsOrder ?? ['hero', 'banner', 'popups'];
    final enabled = _draftLayoutConfig?.enabledSections ?? {};

    return Card(
      child: ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = sections.removeAt(oldIndex);
            sections.insert(newIndex, item);
            _draftLayoutConfig = _draftLayoutConfig?.copyWith(sectionsOrder: sections);
            _hasUnsavedChanges = true;
          });
        },
        children: sections.map((section) {
          final sectionTitle = section == 'hero' ? 'Hero' : section == 'banner' ? 'Bandeau' : 'Popups';
          final isEnabled = enabled[section] ?? false;
          
          return ListTile(
            key: ValueKey(section),
            leading: const Icon(Icons.drag_handle),
            title: Text(sectionTitle),
            trailing: Switch(
              value: isEnabled,
              onChanged: (value) {
                setState(() {
                  final newEnabled = Map<String, bool>.from(enabled);
                  newEnabled[section] = value;
                  _draftLayoutConfig = _draftLayoutConfig?.copyWith(enabledSections: newEnabled);
                  _hasUnsavedChanges = true;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
