// lib/src/admin/studio_b2/studio_b2_page.dart
// Studio B2 - New admin interface for managing AppConfig B2 architecture
// This is a complete rewrite that doesn't depend on Studio V2

import 'package:flutter/material.dart';
import '../../models/app_config.dart';
import '../../services/app_config_service.dart';
import '../../theme/app_theme.dart';
import 'section_list_widget.dart';
import 'texts_editor.dart';
import 'theme_editor.dart';
import 'preview_panel.dart';

/// Studio B2 - Modern admin interface for AppConfig management
/// 
/// Features:
/// - Real-time draft configuration editing
/// - Section management (add, edit, reorder, toggle)
/// - Theme and texts editing
/// - Live preview with HomeScreenB2
/// - Publish/revert workflow
class StudioB2Page extends StatefulWidget {
  const StudioB2Page({super.key});

  @override
  State<StudioB2Page> createState() => _StudioB2PageState();
}

class _StudioB2PageState extends State<StudioB2Page> {
  final AppConfigService _configService = AppConfigService();
  static const String _appId = 'pizza_delizza';
  
  bool _isPublishing = false;
  bool _showPreview = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: _buildAppBar(),
        body: StreamBuilder<AppConfig?>(
          stream: _configService.watchConfig(appId: _appId, draft: true),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return _buildNoConfigState();
            }

            final config = snapshot.data!;
            return _buildContent(config);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.dashboard_customize, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Studio B2',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'DRAFT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.successGreen,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.primaryRed,
      elevation: 2,
      actions: [
        // Preview toggle
        IconButton(
          icon: Icon(_showPreview ? Icons.visibility_off : Icons.visibility),
          tooltip: _showPreview ? 'Masquer preview' : 'Afficher preview',
          onPressed: () {
            setState(() {
              _showPreview = !_showPreview;
            });
          },
        ),
        const SizedBox(width: 8),
        // Revert to published button
        TextButton.icon(
          onPressed: _handleRevertToPublished,
          icon: const Icon(Icons.restore, color: AppColors.surfaceWhite),
          label: const Text(
            'Recharger',
            style: TextStyle(color: AppColors.surfaceWhite),
          ),
        ),
        const SizedBox(width: 8),
        // Publish button
        ElevatedButton.icon(
          onPressed: _isPublishing ? null : _handlePublish,
          icon: _isPublishing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryRed,
                  ),
                )
              : const Icon(Icons.publish),
          label: Text(_isPublishing ? 'Publication...' : 'Publier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceWhite,
            foregroundColor: AppColors.primaryRed,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildContent(AppConfig config) {
    return Row(
      children: [
        // Main content area
        Expanded(
          child: Column(
            children: [
              // Tabs
              Container(
                color: AppColors.surfaceWhite,
                child: const TabBar(
                  isScrollable: true,
                  labelColor: AppColors.primaryRed,
                  unselectedLabelColor: AppColors.textMedium,
                  indicatorColor: AppColors.primaryRed,
                  tabs: [
                    Tab(text: 'Sections'),
                    Tab(text: 'Textes'),
                    Tab(text: 'Thème'),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: TabBarView(
                  children: [
                    SectionListWidget(
                      config: config,
                      appId: _appId,
                      onConfigUpdated: _handleConfigUpdate,
                    ),
                    TextsEditor(
                      config: config,
                      appId: _appId,
                      onConfigUpdated: _handleConfigUpdate,
                    ),
                    ThemeEditor(
                      config: config,
                      appId: _appId,
                      onConfigUpdated: _handleConfigUpdate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Preview panel
        if (_showPreview)
          SizedBox(
            width: 420,
            child: PreviewPanel(appId: _appId),
          ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 24),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: const TextStyle(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoConfigState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.settings_suggest,
              size: 64,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun brouillon',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Créez un brouillon à partir de la configuration publiée',
              style: TextStyle(color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleCreateDraft,
              icon: const Icon(Icons.add),
              label: const Text('Créer un brouillon'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateDraft() async {
    try {
      await _configService.ensureDraftExists(appId: _appId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brouillon créé avec succès'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _handlePublish() async {
    setState(() {
      _isPublishing = true;
    });

    try {
      await _configService.publishDraft(appId: _appId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration publiée avec succès'),
            backgroundColor: AppColors.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de publication: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  Future<void> _handleRevertToPublished() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recharger la configuration'),
        content: const Text(
          'Voulez-vous recharger le brouillon depuis la version publiée ? '
          'Toutes les modifications non publiées seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            child: const Text('Recharger'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Delete existing draft first
        await _configService.deleteDraft(appId: _appId);
        // Then create new draft from published (will auto-create if needed)
        await _configService.ensureDraftExists(appId: _appId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Brouillon rechargé depuis la version publiée'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  void _handleConfigUpdate(AppConfig updatedConfig) {
    // Save the updated config to draft
    _configService.saveDraft(appId: _appId, config: updatedConfig).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brouillon sauvegardé'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de sauvegarde: $error'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    });
  }
}
