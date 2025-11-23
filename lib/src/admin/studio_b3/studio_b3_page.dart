// lib/src/admin/studio_b3/studio_b3_page.dart
// Studio B3 - Page editor for dynamic pages based on PageSchema

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_config.dart';
import '../../models/page_schema.dart';
import '../../services/app_config_service.dart';
import '../../providers/app_config_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';
import 'page_list.dart';
import 'page_editor.dart';

/// Studio B3 - Editor for dynamic pages (PageSchema)
/// 
/// Features:
/// - List of all B3 pages from draft config (Firestore-backed)
/// - Add, edit, delete pages
/// - Block editing with drag & drop
/// - Live preview
/// - Publish/revert workflow
class StudioB3Page extends ConsumerStatefulWidget {
  /// Optional initial page route to open directly (e.g., '/home-b3')
  final String? initialPageRoute;

  const StudioB3Page({super.key, this.initialPageRoute});

  @override
  ConsumerState<StudioB3Page> createState() => _StudioB3PageState();
}

class _StudioB3PageState extends ConsumerState<StudioB3Page> {
  static const String _appId = AppConstants.appId;
  
  PageSchema? _selectedPage;
  bool _isPublishing = false;
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final configService = ref.watch(appConfigServiceProvider);
    final configAsync = ref.watch(appConfigDraftProvider);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: configAsync.when(
        data: (config) {
          if (config == null) {
            return _buildNoConfigState();
          }
          
          return _buildContent(config, configService);
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Chargement des pages B3...',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        error: (error, stack) {
          debugPrint('Studio B3: Error loading draft config: $error');
          debugPrint('Stack trace: $stack');
          return _buildErrorState(error.toString());
        },
      ),
    );
  }

  Widget _buildContent(AppConfig config, AppConfigService configService) {
    // Get pages from config (already includes fallback from appConfigDraftProvider)
    final pages = config.pages.pages;
    debugPrint('StudioB3: displaying ${pages.length} pages from provider');
    
    // Initialize selected page from route parameter if provided and not yet initialized
    if (!_isInitialized && widget.initialPageRoute != null && _selectedPage == null) {
      _isInitialized = true;
      // Find page by route
      final page = config.pages.getPage(widget.initialPageRoute!);
      if (page != null) {
        // Use WidgetsBinding to set state after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedPage = page;
            });
          }
        });
      } else {
        // Page not found - show message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Page "${widget.initialPageRoute}" non trouvée'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        });
      }
    }
    
    // If a page is selected, show the editor
    if (_selectedPage != null) {
      return PageEditor(
        pageSchema: _selectedPage!,
        config: config,
        onBack: () {
          setState(() {
            _selectedPage = null;
          });
        },
        onSave: (updatedPage) async {
          await _updatePage(config, updatedPage, configService);
          setState(() {
            _selectedPage = updatedPage;
          });
        },
      );
    }

    // Otherwise, show the page list
    return PageList(
      pages: pages,
      onPageSelected: (page) {
        setState(() {
          _selectedPage = page;
        });
      },
      onPageToggle: (page, enabled) async {
        await _togglePage(config, page, enabled, configService);
      },
      onAddPage: () async {
        await _addNewPage(config, configService);
      },
      onDeletePage: (page) async {
        await _deletePage(config, page, configService);
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.pages, size: 28),
          const SizedBox(width: 12),
          Text(
            _selectedPage != null ? 'Studio B3 - ${_selectedPage!.name}' : 'Studio B3',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'DRAFT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (_isPublishing)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else ...[
          TextButton.icon(
            onPressed: _revertChanges,
            icon: const Icon(Icons.refresh),
            label: const Text('Annuler'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _publishChanges,
            icon: const Icon(Icons.publish),
            label: const Text('Publier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoConfigState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aucune configuration',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createDefaultConfig,
            child: const Text('Créer la configuration par défaut'),
          ),
        ],
      ),
    );
  }

  Future<void> _createDefaultConfig() async {
    setState(() => _isPublishing = true);
    try {
      final configService = ref.read(appConfigServiceProvider);
      final defaultConfig = configService.getDefaultConfig(_appId);
      await configService.saveDraft(appId: _appId, config: defaultConfig);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration créée avec succès')),
        );
      }
    } catch (e) {
      debugPrint('Studio B3: Error creating default config: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _publishChanges() async {
    setState(() => _isPublishing = true);
    try {
      final configService = ref.read(appConfigServiceProvider);
      await configService.publishDraft(appId: _appId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Modifications publiées avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Studio B3: Error publishing draft: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _revertChanges() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler les modifications'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler toutes les modifications non publiées ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isPublishing = true);
    try {
      final configService = ref.read(appConfigServiceProvider);
      await configService.createDraftFromPublished(appId: _appId);
      
      if (mounted) {
        setState(() => _selectedPage = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modifications annulées')),
        );
      }
    } catch (e) {
      debugPrint('Studio B3: Error reverting changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  Future<void> _updatePage(AppConfig config, PageSchema updatedPage, AppConfigService configService) async {
    try {
      final updatedPages = config.pages.pages.map((p) {
        return p.id == updatedPage.id ? updatedPage : p;
      }).toList();

      final updatedConfig = config.copyWith(
        pages: config.pages.copyWith(pages: updatedPages),
      );

      await configService.saveDraft(appId: _appId, config: updatedConfig);
      debugPrint('Studio B3: Page "${updatedPage.name}" updated successfully');
    } catch (e) {
      debugPrint('Studio B3: Error updating page: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _togglePage(AppConfig config, PageSchema page, bool enabled, AppConfigService configService) async {
    try {
      final updatedPage = page.copyWith(enabled: enabled);
      await _updatePage(config, updatedPage, configService);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled ? 'Page activée' : 'Page désactivée'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Studio B3: Error toggling page: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _addNewPage(AppConfig config, AppConfigService configService) async {
    final newPage = PageSchema(
      id: 'page_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Nouvelle Page',
      route: '/new-page',
      enabled: false,
      blocks: [],
      metadata: {'created': DateTime.now().toIso8601String()},
    );

    try {
      final updatedPages = [...config.pages.pages, newPage];
      final updatedConfig = config.copyWith(
        pages: config.pages.copyWith(pages: updatedPages),
      );

      await configService.saveDraft(appId: _appId, config: updatedConfig);
      
      if (mounted) {
        setState(() => _selectedPage = newPage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nouvelle page créée')),
        );
      }
    } catch (e) {
      debugPrint('Studio B3: Error adding new page: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deletePage(AppConfig config, PageSchema page, AppConfigService configService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la page'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${page.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final updatedPages = config.pages.pages.where((p) => p.id != page.id).toList();
      final updatedConfig = config.copyWith(
        pages: config.pages.copyWith(pages: updatedPages),
      );

      await configService.saveDraft(appId: _appId, config: updatedConfig);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Page supprimée')),
        );
      }
    } catch (e) {
      debugPrint('Studio B3: Error deleting page: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
