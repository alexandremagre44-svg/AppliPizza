// lib/src/screens/admin/studio/studio_popups_roulette_screen.dart
// Screen for managing popups and roulette configuration

import 'package:flutter/material.dart';
import '../../../models/popup_config.dart';
import '../../../models/roulette_config.dart';
import '../../../services/popup_service.dart';
import '../../../services/roulette_service.dart';
import '../../../theme/app_theme.dart';

class StudioPopupsRouletteScreen extends StatefulWidget {
  const StudioPopupsRouletteScreen({super.key});

  @override
  State<StudioPopupsRouletteScreen> createState() =>
      _StudioPopupsRouletteScreenState();
}

class _StudioPopupsRouletteScreenState
    extends State<StudioPopupsRouletteScreen> with SingleTickerProviderStateMixin {
  final PopupService _popupService = PopupService();
  final RouletteService _rouletteService = RouletteService();
  
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
    
    final popups = await _popupService.getAllPopups();
    final roulette = await _rouletteService.getRouletteConfig();
    
    if (roulette == null) {
      await _rouletteService.initializeDefaultConfig();
      final newRoulette = await _rouletteService.getRouletteConfig();
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
          ..._popups.map((popup) => Card(
                elevation: 1,
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                child: ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: popup.isActive
                          ? AppColors.primaryRed.withOpacity(0.1)
                          : AppColors.textLight.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPopupIcon(popup.type),
                      color: popup.isActive
                          ? AppColors.primaryRed
                          : AppColors.textLight,
                    ),
                  ),
                  title: Text(popup.title, style: AppTextStyles.titleMedium),
                  subtitle: Text(
                    '${popup.type} • ${popup.targetAudience}',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: Icon(
                    popup.isActive ? Icons.check_circle : Icons.circle_outlined,
                    color: popup.isActive
                        ? AppColors.successGreen
                        : AppColors.textLight,
                  ),
                ),
              )),
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
                  children: [
                    Icon(Icons.casino, color: AppColors.primaryRed),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Configuration de la roulette',
                      style: AppTextStyles.titleLarge,
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
                    final updated = roulette.copyWith(isActive: value);
                    await _rouletteService.saveRouletteConfig(updated);
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
                          title: Text(segment.label),
                          subtitle: Text(segment.type),
                          trailing: Text(
                            'Poids: ${segment.weight.toStringAsFixed(1)}',
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    );
  }
}
