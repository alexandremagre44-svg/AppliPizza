// lib/builder/page_list/builder_page_list_screen.dart
// Page list screen for Builder B3 system
// Shows pages in Active/Inactive sections with badges and actions

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../editor/editor.dart';
import 'new_page_dialog_v2.dart';

/// Builder Page List Screen
/// 
/// Displays all pages in two sections:
/// - Active pages (isActive == true, sorted by bottomNavIndex)
/// - Inactive pages (isActive == false, sorted by updatedAt desc)
/// 
/// Each page shows:
/// - Title and icon
/// - Badges (Active, Published, Pending changes, BottomBar)
/// - Actions (Edit, Toggle Active, Set Order, Duplicate, Delete)
class BuilderPageListScreen extends StatefulWidget {
  final String appId;

  const BuilderPageListScreen({
    super.key,
    required this.appId,
  });

  @override
  State<BuilderPageListScreen> createState() => _BuilderPageListScreenState();
}

class _BuilderPageListScreenState extends State<BuilderPageListScreen> {
  final BuilderLayoutService _layoutService = BuilderLayoutService();
  final BuilderPageService _pageService = BuilderPageService();
  
  List<BuilderPage> _allPages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPages();
  }

  Future<void> _loadPages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all draft pages
      final draftPages = await _layoutService.loadAllDraftPages(widget.appId);
      final publishedPages = await _layoutService.loadAllPublishedPages(widget.appId);
      
      // Merge pages - prefer draft if exists
      final mergedPages = <String, BuilderPage>{};
      
      for (final entry in publishedPages.entries) {
        mergedPages[entry.key] = entry.value; // entry.key is already a String
      }
      
      for (final entry in draftPages.entries) {
        mergedPages[entry.key] = entry.value; // entry.key is already a String
      }
      
      setState(() {
        _allPages = mergedPages.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<BuilderPage> get _activePages {
    return _allPages
        .where((p) => p.isActive)
        .toList()
      ..sort((a, b) => a.bottomNavIndex.compareTo(b.bottomNavIndex));
  }

  List<BuilderPage> get _inactivePages {
    return _allPages
        .where((p) => !p.isActive)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pages Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPages,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _cleanDuplicates,
            tooltip: 'Nettoyer les doublons',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildPageList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePageDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle page'),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erreur: $_error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPages,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildPageList() {
    return RefreshIndicator(
      onRefresh: _loadPages,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active Pages Section
          _buildSectionHeader(
            title: 'Pages Actives',
            icon: Icons.visibility,
            color: Colors.green,
            count: _activePages.length,
          ),
          const SizedBox(height: 8),
          if (_activePages.isEmpty)
            _buildEmptySection('Aucune page active')
          else
            ..._activePages.map((page) => _buildPageCard(page)),
          
          const SizedBox(height: 24),
          
          // Inactive Pages Section
          _buildSectionHeader(
            title: 'Pages Inactives',
            icon: Icons.visibility_off,
            color: Colors.grey,
            count: _inactivePages.length,
          ),
          const SizedBox(height: 8),
          if (_inactivePages.isEmpty)
            _buildEmptySection('Aucune page inactive')
          else
            ..._inactivePages.map((page) => _buildPageCard(page)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySection(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildPageCard(BuilderPage page) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Page icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getPageTypeColor(page).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getPageIcon(page),
                    color: _getPageTypeColor(page),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and route
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDisplayName(page),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        page.route,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editPage(page),
                  tooltip: 'Modifier',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildBadges(page),
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Toggle active
                TextButton.icon(
                  onPressed: () => _toggleActive(page),
                  icon: Icon(
                    page.isActive ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                  ),
                  label: Text(page.isActive ? 'Désactiver' : 'Activer'),
                ),
                if (page.displayLocation == 'bottomBar') ...[
                  const SizedBox(width: 8),
                  // Bottom nav order
                  TextButton.icon(
                    onPressed: () => _setBottomNavOrder(page),
                    icon: const Icon(Icons.sort, size: 18),
                    label: const Text('Ordre'),
                  ),
                ],
                const SizedBox(width: 8),
                // Duplicate
                TextButton.icon(
                  onPressed: () => _duplicatePage(page),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Dupliquer'),
                ),
                if (!page.isSystemPage && page.blocks.isEmpty && page.draftLayout.isEmpty) ...[
                  const SizedBox(width: 8),
                  // Delete
                  TextButton.icon(
                    onPressed: () => _deletePage(page),
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBadges(BuilderPage page) {
    final badges = <Widget>[];
    
    // Active/Inactive badge
    badges.add(_buildBadge(
      label: page.isActive ? 'Actif' : 'Inactif',
      color: page.isActive ? Colors.green : Colors.grey,
      icon: page.isActive ? Icons.visibility : Icons.visibility_off,
    ));
    
    // Published badge
    if (page.publishedLayout.isNotEmpty) {
      badges.add(_buildBadge(
        label: 'Publié',
        color: Colors.blue,
        icon: Icons.publish,
      ));
    }
    
    // Pending changes badge
    if (page.hasUnpublishedChanges) {
      badges.add(_buildBadge(
        label: 'Modifs en attente',
        color: Colors.orange,
        icon: Icons.pending,
      ));
    }
    
    // BottomBar badge
    if (page.displayLocation == 'bottomBar') {
      badges.add(_buildBadge(
        label: 'BottomBar #${page.bottomNavIndex}',
        color: Colors.purple,
        icon: Icons.dock,
      ));
    }
    
    // System page badge
    if (page.isSystemPage) {
      badges.add(_buildBadge(
        label: 'Système',
        color: Colors.indigo,
        icon: Icons.lock,
      ));
    }
    
    // Page type badge
    badges.add(_buildBadge(
      label: page.pageType.label,
      color: Colors.teal,
      icon: _getPageTypeIcon(page.pageType),
    ));
    
    return badges;
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPageIcon(BuilderPage page) {
    // Try to get icon from page icon string
    switch (page.icon) {
      case 'home':
        return Icons.home;
      case 'menu':
      case 'restaurant_menu':
      case 'menu_book':
        return Icons.restaurant_menu;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'person':
        return Icons.person;
      case 'casino':
        return Icons.casino;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'local_offer':
        return Icons.local_offer;
      case 'info':
        return Icons.info;
      case 'contact_mail':
        return Icons.contact_mail;
      default:
        return Icons.article;
    }
  }

  Color _getPageTypeColor(BuilderPage page) {
    if (page.isSystemPage) return Colors.indigo;
    switch (page.pageType) {
      case BuilderPageType.template:
        return Colors.blue;
      case BuilderPageType.blank:
        return Colors.teal;
      case BuilderPageType.system:
        return Colors.indigo;
      case BuilderPageType.custom:
        return Colors.purple;
    }
  }

  IconData _getPageTypeIcon(BuilderPageType type) {
    switch (type) {
      case BuilderPageType.template:
        return Icons.dashboard;
      case BuilderPageType.blank:
        return Icons.description;
      case BuilderPageType.system:
        return Icons.settings;
      case BuilderPageType.custom:
        return Icons.brush;
    }
  }

  String _getDisplayName(BuilderPage page) {
    // If page has a name, use it
    if (page.name.isNotEmpty && page.name != 'Page') {
      return page.name;
    }
    
    // Try to get system page default name using systemId
    if (page.systemId != null) {
      final systemConfig = SystemPages.getConfig(page.systemId!);
      if (systemConfig != null) {
        return systemConfig.defaultName;
      }
    }
    
    // Fallback to pageId label if available, otherwise use pageKey
    return page.pageId?.label ?? page.pageKey;
  }

  // ==================== ACTIONS ====================

  void _editPage(BuilderPage page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuilderPageEditorScreen(
          appId: widget.appId,
          pageId: page.systemId ?? page.pageId, // Use systemId or pageId for system pages
          pageKey: page.pageKey, // Pass pageKey for custom pages
        ),
      ),
    ).then((_) => _loadPages());
  }

  Future<void> _toggleActive(BuilderPage page) async {
    try {
      await _pageService.toggleActiveStatus(
        page.pageKey, // Use pageKey for toggling
        widget.appId,
        !page.isActive,
      );
      _loadPages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              page.isActive 
                  ? '✅ Page désactivée' 
                  : '✅ Page activée',
            ),
          ),
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

  Future<void> _setBottomNavOrder(BuilderPage page) async {
    final controller = TextEditingController(
      text: page.bottomNavIndex.toString(),
    );
    
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Définir l\'ordre'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Position dans la barre de navigation',
            hintText: '1, 2, 3...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      try {
        // Use pageKey (String) for all pages - the service accepts both BuilderPageId and String
        await _pageService.reorderBottomNav(
          page.pageKey,
          widget.appId,
          result,
        );
        _loadPages();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Ordre mis à jour: $result')),
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
  }

  Future<void> _duplicatePage(BuilderPage page) async {
    try {
      final newPage = await _pageService.createPageFromTemplate(
        'custom',
        appId: widget.appId,
        name: '${page.name} (copie)',
        description: 'Copie de ${page.name}',
        displayLocation: page.displayLocation,
        icon: page.icon,
        order: page.order + 1,
      );
      
      // Update with blocks from original page
      final pageWithBlocks = newPage.copyWith(
        blocks: page.blocks,
        draftLayout: page.draftLayout,
      );
      await _layoutService.saveDraft(pageWithBlocks);
      
      _loadPages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Page dupliquée: ${newPage.name}')),
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

  Future<void> _deletePage(BuilderPage page) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la page'),
        content: Text('Voulez-vous vraiment supprimer "${page.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        // Use pageKey which is always non-null
        await _layoutService.deleteDraft(widget.appId, page.pageKey);
        await _layoutService.deletePublished(widget.appId, page.pageKey);
        _loadPages();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Page supprimée: ${page.name}')),
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
  }

  Future<void> _cleanDuplicates() async {
    try {
      final removed = await _pageService.cleanDuplicatePages(widget.appId);
      _loadPages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              removed > 0 
                  ? '✅ $removed doublons supprimés' 
                  : '✅ Aucun doublon trouvé',
            ),
          ),
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

  void _showCreatePageDialog() {
    showDialog(
      context: context,
      builder: (context) => NewPageDialogV2(
        appId: widget.appId,
        onPageCreated: (page) {
          Navigator.pop(context);
          _loadPages();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Page créée: ${page.name}')),
          );
        },
      ),
    );
  }
}
