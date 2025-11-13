// lib/src/screens/admin/studio/studio_home_config_screen.dart
// Screen for configuring home page (hero, promo banner, dynamic blocks)

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/home_config.dart';
import '../../../models/dynamic_block_model.dart';
import '../../../services/home_config_service.dart';
import '../../../theme/app_theme.dart';
import 'dialogs/edit_hero_dialog.dart';
import 'dialogs/edit_promo_banner_dialog.dart';
import 'dialogs/edit_block_dialog.dart';

class StudioHomeConfigScreen extends StatefulWidget {
  const StudioHomeConfigScreen({super.key});

  @override
  State<StudioHomeConfigScreen> createState() => _StudioHomeConfigScreenState();
}

class _StudioHomeConfigScreenState extends State<StudioHomeConfigScreen>
    with SingleTickerProviderStateMixin {
  final HomeConfigService _service = HomeConfigService();
  late TabController _tabController;
  
  HomeConfig? _config;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConfig();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    final config = await _service.getHomeConfig();
    if (config == null) {
      await _service.initializeDefaultConfig();
      final newConfig = await _service.getHomeConfig();
      setState(() {
        _config = newConfig;
        _isLoading = false;
      });
    } else {
      setState(() {
        _config = config;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Page d\'accueil',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryRed,
                  unselectedLabelColor: AppTheme.textMedium,
                  indicatorColor: AppTheme.primaryRed,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Hero'),
                    Tab(text: 'Bandeau'),
                    Tab(text: 'Blocs'),
                  ],
                ),
              ),
            ),
          ),

          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHeroTab(),
                      _buildPromoBannerTab(),
                      _buildBlocksTab(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeroTab() {
    if (_config == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final hero = _config!.hero;
    
    if (hero == null) {
      return const Center(child: Text('Configuration Hero non disponible'));
    }
    
    return ListView(
      padding: AppSpacing.paddingLG,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
          child: Padding(
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, color: AppColors.primaryRed),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text('Bannière Hero', style: AppTextStyles.titleLarge),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showEditHeroDialog(hero),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                
                SwitchListTile(
                  title: const Text('Activer le Hero'),
                  value: hero.isActive,
                  activeColor: AppColors.primaryRed,
                  onChanged: (value) async {
                    final updated = hero.copyWith(isActive: value);
                    await _service.updateHeroConfig(updated);
                    _loadConfig();
                    _showSnackBar('Hero ${value ? 'activé' : 'désactivé'}');
                  },
                ),
                
                Divider(height: AppSpacing.xxl),
                
                // Preview
                _buildInfoRow('Titre', hero.title),
                _buildInfoRow('Sous-titre', hero.subtitle),
                _buildInfoRow('Texte du bouton', hero.ctaText),
                _buildInfoRow('Action', hero.ctaAction),
                if (hero.imageUrl.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      hero.imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 48),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBannerTab() {
    if (_config == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final banner = _config!.promoBanner;
    
    if (banner == null) {
      return const Center(child: Text('Configuration Bandeau Promo non disponible'));
    }
    
    return ListView(
      padding: AppSpacing.paddingLG,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
          child: Padding(
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications, color: AppColors.primaryRed),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text('Bandeau Promo', style: AppTextStyles.titleLarge),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showEditPromoBannerDialog(banner),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                
                SwitchListTile(
                  title: const Text('Activer le bandeau'),
                  value: banner.isActive,
                  activeColor: AppColors.primaryRed,
                  onChanged: (value) async {
                    final updated = banner.copyWith(isActive: value);
                    await _service.updatePromoBanner(updated);
                    _loadConfig();
                    _showSnackBar('Bandeau ${value ? 'activé' : 'désactivé'}');
                  },
                ),
                
                Divider(height: AppSpacing.xxl),
                
                // Preview
                _buildInfoRow('Texte', banner.text),
                _buildInfoRow('Couleur de fond', banner.backgroundColor ?? '#D32F2F'),
                _buildInfoRow('Couleur du texte', banner.textColor ?? '#FFFFFF'),
                SizedBox(height: AppSpacing.md),
                
                // Preview banner
                if (banner.text.isNotEmpty) Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Color(ColorConverter.hexToColor(banner.backgroundColor) ?? 0xFFD32F2F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        color: Color(ColorConverter.hexToColor(banner.textColor) ?? 0xFFFFFFFF),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          banner.text,
                          style: TextStyle(
                            color: Color(ColorConverter.hexToColor(banner.textColor) ?? 0xFFFFFFFF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlocksTab() {
    if (_config == null) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ListView(
      padding: AppSpacing.paddingLG,
      children: [
        Card(
          elevation: 2,
          color: AppColors.primaryRed.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.cardLarge),
          child: Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primaryRed),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '${_config!.blocks.length} bloc(s) configuré(s)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: AppColors.primaryRed),
                  onPressed: _showAddBlockDialog,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        
        if (_config!.blocks.isEmpty)
          Center(
            child: Padding(
              padding: AppSpacing.paddingXXL,
              child: Column(
                children: [
                  Icon(
                    Icons.view_agenda_outlined,
                    size: 80,
                    color: AppColors.textLight,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucun bloc',
                    style: AppTextStyles.titleLarge,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ajoutez des blocs pour personnaliser votre page',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ..._config!.blocks.map((block) => _buildBlockCard(block)),
      ],
    );
  }

  Widget _buildBlockCard(ContentBlock block) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: block.isActive
                ? AppColors.primaryRed.withOpacity(0.1)
                : AppColors.textLight.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getBlockIcon(block.type),
            color: block.isActive ? AppColors.primaryRed : AppColors.textLight,
          ),
        ),
        title: Text(block.title, style: AppTextStyles.titleMedium),
        subtitle: Text(
          'Type: ${block.type} • Position: ${block.order}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Icon(
          block.isActive ? Icons.check_circle : Icons.circle_outlined,
          color: block.isActive ? AppColors.successGreen : AppColors.textLight,
        ),
        children: [
          Padding(
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(block.content, style: AppTextStyles.bodyMedium),
                SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Modifier'),
                      onPressed: () => _showEditBlockDialog(block),
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.delete, size: 18),
                      label: Text('Supprimer'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                      ),
                      onPressed: () => _deleteBlock(block.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBlockIcon(String type) {
    switch (type) {
      case 'featured_products':
        return Icons.star;
      case 'promotions':
        return Icons.local_offer;
      case 'categories':
        return Icons.category;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.view_agenda;
    }
  }

  void _showAddBlockDialog() {
    // Convert ContentBlock to DynamicBlock for the dialog
    showDialog(
      context: context,
      builder: (context) => EditBlockDialog(
        onSave: (dynamicBlock) async {
          // Convert DynamicBlock to ContentBlock for saving
          final contentBlock = ContentBlock(
            id: dynamicBlock.id,
            type: dynamicBlock.type,
            title: dynamicBlock.title,
            maxItems: dynamicBlock.maxItems,
            order: dynamicBlock.order,
            isActive: dynamicBlock.isVisible,
          );
          
          final success = await _service.addContentBlock(contentBlock);
          if (success) {
            _loadConfig();
            _showSnackBar('Bloc ajouté');
          } else {
            _showSnackBar('Erreur lors de l\'ajout', isError: true);
          }
        },
      ),
    );
  }

  void _showEditBlockDialog(ContentBlock block) {
    // Convert ContentBlock to DynamicBlock for the dialog
    final dynamicBlock = DynamicBlock(
      id: block.id,
      type: block.type,
      title: block.title,
      maxItems: block.maxItems,
      order: block.order,
      isVisible: block.isActive,
    );
    
    showDialog(
      context: context,
      builder: (context) => EditBlockDialog(
        block: dynamicBlock,
        onSave: (updatedDynamicBlock) async {
          // Convert back to ContentBlock for saving
          final updatedBlock = block.copyWith(
            type: updatedDynamicBlock.type,
            title: updatedDynamicBlock.title,
            maxItems: updatedDynamicBlock.maxItems,
            order: updatedDynamicBlock.order,
            isActive: updatedDynamicBlock.isVisible,
          );
          
          final success = await _service.updateContentBlock(updatedBlock);
          if (success) {
            _loadConfig();
            _showSnackBar('Bloc modifié');
          } else {
            _showSnackBar('Erreur lors de la modification', isError: true);
          }
        },
      ),
    );
  }

  Future<void> _deleteBlock(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le bloc ?'),
        content: Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await _service.deleteContentBlock(id);
      if (success) {
        _loadConfig();
        _showSnackBar('Bloc supprimé');
      } else {
        _showSnackBar('Erreur lors de la suppression', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    );
  }

  // Show edit hero dialog
  void _showEditHeroDialog(HeroConfig hero) {
    showDialog(
      context: context,
      builder: (context) => EditHeroDialog(
        hero: hero,
        onSave: (updatedHero) async {
          await _service.updateHeroConfig(updatedHero);
          _loadConfig();
          _showSnackBar('Hero mis à jour');
        },
      ),
    );
  }

  // Show edit promo banner dialog
  void _showEditPromoBannerDialog(PromoBannerConfig banner) {
    showDialog(
      context: context,
      builder: (context) => EditPromoBannerDialog(
        banner: banner,
        onSave: (updatedBanner) async {
          await _service.updatePromoBanner(updatedBanner);
          _loadConfig();
          _showSnackBar('Bandeau mis à jour');
        },
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '(vide)' : value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
