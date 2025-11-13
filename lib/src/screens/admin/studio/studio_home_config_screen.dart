// lib/src/screens/admin/studio/studio_home_config_screen.dart
// Screen for configuring home page (hero, promo banner, dynamic blocks)

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/home_config.dart';
import '../../../services/home_config_service.dart';
import '../../../theme/app_theme.dart';

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
      return Center(child: CircularProgressIndicator());
    }
    
    final hero = _config!.hero;
    
    if (hero == null) {
      return Center(child: Text('Configuration Hero non disponible'));
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
                    Text('Bannière Hero', style: AppTextStyles.titleLarge),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                
                SwitchListTile(
                  title: Text('Activer le Hero'),
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
                
                _buildTextField('Titre', hero.title, (value) async {
                  final updated = hero.copyWith(title: value);
                  await _service.updateHeroConfig(updated);
                  _loadConfig();
                }),
                _buildTextField('Sous-titre', hero.subtitle, (value) async {
                  final updated = hero.copyWith(subtitle: value);
                  await _service.updateHeroConfig(updated);
                  _loadConfig();
                }),
                _buildTextField('URL de l\'image', hero.imageUrl, (value) async {
                  final updated = hero.copyWith(imageUrl: value);
                  await _service.updateHeroConfig(updated);
                  _loadConfig();
                }),
                _buildTextField('Texte du bouton', hero.ctaText, (value) async {
                  final updated = hero.copyWith(ctaText: value);
                  await _service.updateHeroConfig(updated);
                  _loadConfig();
                }),
                _buildTextField('Action du bouton', hero.ctaAction, (value) async {
                  final updated = hero.copyWith(ctaAction: value);
                  await _service.updateHeroConfig(updated);
                  _loadConfig();
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBannerTab() {
    if (_config == null) {
      return Center(child: CircularProgressIndicator());
    }
    
    final banner = _config!.promoBanner;
    
    if (banner == null) {
      return Center(child: Text('Configuration Bandeau Promo non disponible'));
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
                    Text('Bandeau Promo', style: AppTextStyles.titleLarge),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                
                SwitchListTile(
                  title: Text('Activer le bandeau'),
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
                
                _buildTextField('Texte du bandeau', banner.text, (value) async {
                  final updated = banner.copyWith(text: value);
                  await _service.updatePromoBanner(updated);
                  _loadConfig();
                }),
                _buildTextField('Couleur (hex)', banner.backgroundColor ?? '#D32F2F', (value) async {
                  final updated = banner.copyWith(backgroundColor: value);
                  await _service.updatePromoBanner(updated);
                  _loadConfig();
                }),
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
    _showBlockDialog();
  }

  void _showEditBlockDialog(ContentBlock block) {
    _showBlockDialog(existingBlock: block);
  }

  void _showBlockDialog({ContentBlock? existingBlock}) {
    final isEditing = existingBlock != null;
    final titleController = TextEditingController(text: existingBlock?.title);
    final contentController = TextEditingController(text: existingBlock?.content);
    String selectedType = existingBlock?.type ?? 'featured_products';
    bool isActive = existingBlock?.isActive ?? true;
    int order = existingBlock?.order ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Modifier le bloc' : 'Nouveau bloc'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre*',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type de bloc',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'featured_products', child: Text('Produits en vedette')),
                    DropdownMenuItem(value: 'promotions', child: Text('Promotions')),
                    DropdownMenuItem(value: 'categories', child: Text('Catégories')),
                    DropdownMenuItem(value: 'text', child: Text('Texte libre')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Contenu',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Position (ordre)',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: order.toString()),
                  onChanged: (value) {
                    order = int.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  title: Text('Bloc actif'),
                  value: isActive,
                  activeColor: AppColors.primaryRed,
                  onChanged: (value) {
                    setState(() => isActive = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  _showSnackBar('Le titre est requis', isError: true);
                  return;
                }
                
                final block = isEditing
                    ? existingBlock.copyWith(
                        title: titleController.text.trim(),
                        type: selectedType,
                        content: contentController.text.trim(),
                        order: order,
                        isActive: isActive,
                      )
                    : ContentBlock(
                        id: const Uuid().v4(),
                        title: titleController.text.trim(),
                        type: selectedType,
                        content: contentController.text.trim(),
                        order: order,
                        isActive: isActive,
                      );
                
                final success = isEditing
                    ? await _service.updateContentBlock(block)
                    : await _service.addContentBlock(block);
                
                if (success) {
                  _loadConfig();
                  Navigator.pop(context);
                  _showSnackBar(isEditing ? 'Bloc modifié' : 'Bloc ajouté');
                } else {
                  _showSnackBar('Erreur lors de l\'enregistrement', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Modifier' : 'Ajouter'),
            ),
          ],
        ),
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

  Widget _buildTextField(
    String label,
    String value,
    Future<void> Function(String) onSaved,
  ) {
    final controller = TextEditingController(text: value);
    
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelLarge),
          SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: AppRadius.input),
              contentPadding: AppSpacing.paddingMD,
            ),
            onSubmitted: (newValue) async {
              await onSaved(newValue);
              _showSnackBar('Enregistré');
            },
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Appuyez sur Entrée pour sauvegarder',
            style: AppTextStyles.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
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
}
