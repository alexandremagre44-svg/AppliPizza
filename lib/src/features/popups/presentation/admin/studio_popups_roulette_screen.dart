// lib/src/screens/admin/studio/studio_popups_roulette_screen.dart
// Screen for managing popups and roulette configuration

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/popup_config.dart';
import '../../../roulette/data/models/roulette_config.dart';
import 'package:pizza_delizza/src/features/popups/data/repositories/popup_repository.dart';
import 'package:pizza_delizza/src/features/roulette/data/repositories/roulette_repository.dart';
import '../../shared/design_system/app_theme.dart';
import 'edit_popup_screen.dart';
import 'edit_roulette_screen.dart';

class StudioPopupsRouletteScreen extends StatefulWidget {
  const StudioPopupsRouletteScreen({super.key});

  @override
  State<StudioPopupsRouletteScreen> createState() =>
      _StudioPopupsRouletteScreenState();
}

class _StudioPopupsRouletteScreenState
    extends State<StudioPopupsRouletteScreen> with SingleTickerProviderStateMixin {
  final PopupRepository _popupRepository = PopupRepository();
  final RouletteRepository _rouletteRepository = RouletteRepository();
  
  late TabController _tabController;
  List<PopupConfig> _popups = [];
  RouletteConfig? _rouletteConfig;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final popups = await _popupRepository.getAllPopups();
    final roulette = await _rouletteRepository.getRouletteConfig();
    
    if (roulette == null) {
      await _rouletteRepository.initializeDefaultConfig();
      final newRoulette = await _rouletteRepository.getRouletteConfig();
      setState(() {
        _popups = popups;
        _rouletteConfig = newRoulette;
        _isLoading = false;
      });
    } else {
      setState(() {
        _popups = popups;
        _rouletteConfig = roulette;
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
                'Popups & Roulette',
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
                    Tab(text: 'Popups', icon: Icon(Icons.notifications, size: 20)),
                    Tab(text: 'Roulette', icon: Icon(Icons.casino, size: 20)),
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
                      _buildPopupsTab(),
                      _buildRouletteTab(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPopupsTab() {
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
                    '${_popups.length} popup(s) configuré(s)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: AppColors.primaryRed),
                  onPressed: _showAddPopupDialog,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        
        if (_popups.isEmpty)
          Center(
            child: Padding(
              padding: AppSpacing.paddingXXL,
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 80,
                    color: AppColors.textLight,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucun popup configuré',
                    style: AppTextStyles.titleLarge,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ajoutez des popups pour communiquer avec vos clients',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ..._popups.map((popup) => _buildPopupCard(popup)),
      ],
    );
  }

  Widget _buildRouletteTab() {
    final roulette = _rouletteConfig;
    
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.casino, color: AppColors.primaryRed),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Configuration de la roulette',
                          style: AppTextStyles.titleLarge,
                        ),
                      ],
                    ),
                    if (roulette != null)
                      IconButton(
                        icon: Icon(Icons.edit, color: AppColors.primaryRed),
                        onPressed: () => _editRoulette(roulette),
                      ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                
                // Active toggle
                SwitchListTile(
                  title: Text('Activer la roulette', style: AppTextStyles.bodyLarge),
                  subtitle: Text('Afficher la roulette aux clients'),
                  value: roulette?.isActive ?? false,
                  activeColor: AppColors.primaryRed,
                  onChanged: (value) async {
                    if (roulette == null) return;
                    final updated = roulette.copyWith(isActive: value, updatedAt: DateTime.now());
                    await _rouletteRepository.saveRouletteConfig(updated);
                    _loadData();
                    _showSnackBar('Roulette ${value ? 'activée' : 'désactivée'}');
                  },
                ),
                
                Divider(height: AppSpacing.xxl),
                
                if (roulette != null) ...[
                  _buildInfoRow('Délai d\'apparition', '${roulette.delaySeconds}s'),
                  _buildInfoRow('Max par jour', '${roulette.maxUsesPerDay}'),
                  _buildInfoRow('Segments', '${roulette.segments.length}'),
                  
                  SizedBox(height: AppSpacing.lg),
                  Text('Segments de la roue', style: AppTextStyles.titleMedium),
                  SizedBox(height: AppSpacing.md),
                  
                  ...roulette.segments.map((segment) => Card(
                        color: AppColors.backgroundLight,
                        margin: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          dense: true,
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: segment.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.textLight),
                            ),
                          ),
                          title: Text(segment.label),
                          subtitle: Text(segment.rewardId),
                          trailing: Text(
                            '${segment.probability.toStringAsFixed(1)}%',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPopupIcon(String type) {
    switch (type) {
      case 'promo':
        return Icons.local_offer;
      case 'info':
        return Icons.info;
      case 'fidelite':
        return Icons.loyalty;
      case 'systeme':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildPopupCard(PopupConfig popup) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: popup.isActive
                ? AppColors.primaryRed.withOpacity(0.1)
                : AppColors.textLight.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getPopupIcon(popup.type ?? 'info'),
            color: popup.isActive ? AppColors.primaryRed : AppColors.textLight,
          ),
        ),
        title: Text(popup.title, style: AppTextStyles.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${popup.type} • ${popup.targetAudience}',
              style: AppTextStyles.bodySmall,
            ),
            SizedBox(height: AppSpacing.xs),
            // Statistics placeholders as required
            Text(
              'Affichages: - • Clics: -',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 50,
          child: Switch(
            value: popup.isEnabled,
            activeColor: AppColors.primaryRed,
            onChanged: (value) async {
              // Toggle isEnabled state directly from the list
              final updatedPopup = popup.copyWith(isEnabled: value);
              final success = await _popupRepository.updatePopup(updatedPopup);
              if (success) {
                _loadData();
                _showSnackBar('Popup ${value ? 'activé' : 'désactivé'}');
              } else {
                _showSnackBar('Erreur lors de la modification', isError: true);
              }
            },
          ),
        ),
        children: [
          Padding(
            padding: AppSpacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(popup.message, style: AppTextStyles.bodyMedium),
                SizedBox(height: AppSpacing.md),
                _buildInfoRow('Condition', popup.displayCondition ?? 'Non définie'),
                _buildInfoRow('Priorité', popup.priority.toString()),
                if (popup.ctaText != null)
                  _buildInfoRow('Bouton', popup.ctaText!),
                SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Modifier'),
                      onPressed: () => _showEditPopupDialog(popup),
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.delete, size: 18),
                      label: Text('Supprimer'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                      ),
                      onPressed: () => _deletePopup(popup.id),
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

  Future<void> _showAddPopupDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditPopupScreen(),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _showEditPopupDialog(PopupConfig popup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPopupScreen(existingPopup: popup),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }
  
  Future<void> _editRoulette(RouletteConfig config) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRouletteScreen(config: config),
      ),
    );
    
    if (result == true) {
      _loadData();
    }
  }

  void _showPopupDialog({PopupConfig? existingPopup}) {
    final isEditing = existingPopup != null;
    final titleController = TextEditingController(text: existingPopup?.title);
    final messageController = TextEditingController(text: existingPopup?.message);
    final ctaTextController = TextEditingController(text: existingPopup?.ctaText);
    final ctaActionController = TextEditingController(text: existingPopup?.ctaAction);
    
    String selectedType = existingPopup?.type ?? 'info';
    String selectedAudience = existingPopup?.targetAudience ?? 'all';
    String selectedCondition = existingPopup?.displayCondition ?? 'always';
    bool isActive = existingPopup?.isActive ?? true;
    int priority = existingPopup?.priority ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Modifier le popup' : 'Nouveau popup'),
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
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: 'Message*',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'info', child: Text('Information')),
                    DropdownMenuItem(value: 'promo', child: Text('Promotion')),
                    DropdownMenuItem(value: 'fidelite', child: Text('Fidélité')),
                    DropdownMenuItem(value: 'systeme', child: Text('Système')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: selectedAudience,
                  decoration: InputDecoration(
                    labelText: 'Audience',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text('Tous')),
                    DropdownMenuItem(value: 'new', child: Text('Nouveaux clients')),
                    DropdownMenuItem(value: 'loyal', child: Text('Clients fidèles')),
                    DropdownMenuItem(value: 'bronze', child: Text('Bronze')),
                    DropdownMenuItem(value: 'silver', child: Text('Silver')),
                    DropdownMenuItem(value: 'gold', child: Text('Gold')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedAudience = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: selectedCondition,
                  decoration: InputDecoration(
                    labelText: 'Condition d\'affichage',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'always', child: Text('Toujours')),
                    DropdownMenuItem(value: 'onceEver', child: Text('Une seule fois')),
                    DropdownMenuItem(value: 'oncePerDay', child: Text('Une fois par jour')),
                    DropdownMenuItem(value: 'oncePerSession', child: Text('Une fois par session')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCondition = value);
                    }
                  },
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Priorité',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: priority.toString()),
                  onChanged: (value) {
                    priority = int.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: ctaTextController,
                  decoration: InputDecoration(
                    labelText: 'Texte du bouton (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                TextField(
                  controller: ctaActionController,
                  decoration: InputDecoration(
                    labelText: 'Action du bouton (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                SwitchListTile(
                  title: Text('Popup actif'),
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
                if (messageController.text.trim().isEmpty) {
                  _showSnackBar('Le message est requis', isError: true);
                  return;
                }
                
                final popup = isEditing
                    ? existingPopup.copyWith(
                        title: titleController.text.trim(),
                        message: messageController.text.trim(),
                        type: selectedType,
                        targetAudience: selectedAudience,
                        displayCondition: selectedCondition,
                        priority: priority,
                        ctaText: ctaTextController.text.trim().isEmpty ? null : ctaTextController.text.trim(),
                        ctaAction: ctaActionController.text.trim().isEmpty ? null : ctaActionController.text.trim(),
                        isEnabled: isActive,
                      )
                    : PopupConfig(
                        id: const Uuid().v4(),
                        title: titleController.text.trim(),
                        message: messageController.text.trim(),
                        type: selectedType,
                        targetAudience: selectedAudience,
                        displayCondition: selectedCondition,
                        priority: priority,
                        ctaText: ctaTextController.text.trim().isEmpty ? null : ctaTextController.text.trim(),
                        ctaAction: ctaActionController.text.trim().isEmpty ? null : ctaActionController.text.trim(),
                        isEnabled: isActive,
                        createdAt: DateTime.now(),
                      );
                
                final success = isEditing
                    ? await _popupRepository.updatePopup(popup)
                    : await _popupRepository.createPopup(popup);
                
                if (success) {
                  _loadData();
                  Navigator.pop(context);
                  _showSnackBar(isEditing ? 'Popup modifié' : 'Popup créé');
                } else {
                  _showSnackBar('Erreur lors de l\'enregistrement', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Modifier' : 'Créer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePopup(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer le popup ?'),
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
      final success = await _popupRepository.deletePopup(id);
      if (success) {
        _loadData();
        _showSnackBar('Popup supprimé');
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
}
