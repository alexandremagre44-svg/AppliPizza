// lib/src/screens/admin/communication/communication_loyalty_screen.dart
// Screen for managing loyalty program and customer segments

import 'package:flutter/material.dart';
import '../../../auth/data/models/user_profile.dart';
import '../../data/models/loyalty_settings.dart';
import 'package:pizza_delizza/src/features/auth/data/repositories/user_profile_repository.dart';
import 'package:pizza_delizza/src/features/loyalty/data/repositories/loyalty_settings_repository.dart';
import '../../../shared/theme/app_theme.dart';

class CommunicationLoyaltyScreen extends StatefulWidget {
  const CommunicationLoyaltyScreen({super.key});

  @override
  State<CommunicationLoyaltyScreen> createState() =>
      _CommunicationLoyaltyScreenState();
}

class _CommunicationLoyaltyScreenState
    extends State<CommunicationLoyaltyScreen>
    with SingleTickerProviderStateMixin {
  final UserProfileRepository _service = UserProfileRepository();
  final LoyaltySettingsRepository _settingsRepository = LoyaltySettingsRepository();
  
  late TabController _tabController;
  List<UserProfile> _users = [];
  LoyaltySettings? _loyaltySettings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    final users = await _service.getAllUserProfiles();
    final settings = await _settingsRepository.getLoyaltySettings();
    
    setState(() {
      _users = users;
      _loyaltySettings = settings;
      _isLoading = false;
    });
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
                'Fidélité & Segments',
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
                    Tab(text: 'Clients', icon: Icon(Icons.people, size: 20)),
                    Tab(text: 'Paramètres', icon: Icon(Icons.settings, size: 20)),
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
                      _buildClientsTab(),
                      _buildSettingsTab(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildClientsTab() {
    // Sort users by loyalty points
    final sortedUsers = List<UserProfile>.from(_users)
      ..sort((a, b) => b.loyaltyPoints.compareTo(a.loyaltyPoints));
    
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
                Icon(Icons.people, color: AppColors.primaryRed),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    '${_users.length} client(s) enregistré(s)',
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
        
        if (_users.isEmpty)
          Center(
            child: Padding(
              padding: AppSpacing.paddingXXL,
              child: Column(
                children: [
                  Icon(
                    Icons.people_outlined,
                    size: 80,
                    color: AppColors.textLight,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Aucun client',
                    style: AppTextStyles.titleLarge,
                  ),
                ],
              ),
            ),
          )
        else
          ...sortedUsers.map((user) => _buildUserCard(user)),
      ],
    );
  }

  Widget _buildUserCard(UserProfile user) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: _getLoyaltyLevelColor(user.loyaltyLevel),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(user.name, style: AppTextStyles.titleMedium),
        subtitle: Text(
          '${user.email}\n${user.loyaltyPoints} points • ${user.loyaltyLevel}',
          style: AppTextStyles.bodySmall,
        ),
        isThreeLine: true,
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _getLoyaltyLevelColor(user.loyaltyLevel).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            user.loyaltyLevel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getLoyaltyLevelColor(user.loyaltyLevel),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
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
                    Icon(Icons.loyalty, color: AppColors.primaryRed),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Programme de fidélité',
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: AppColors.primaryRed),
                      onPressed: _showLoyaltySettingsDialog,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                
                if (_loyaltySettings != null) ...[
                  _buildSettingRow('Points par € dépensé', '${_loyaltySettings!.pointsPerEuro}'),
                  _buildSettingRow('Seuil Bronze', '${_loyaltySettings!.bronzeThreshold} points'),
                  _buildSettingRow('Seuil Silver', '${_loyaltySettings!.silverThreshold} points'),
                  _buildSettingRow('Seuil Gold', '${_loyaltySettings!.goldThreshold} points'),
                ],
                
                SizedBox(height: AppSpacing.lg),
                
                Text('Niveaux de fidélité', style: AppTextStyles.titleMedium),
                SizedBox(height: AppSpacing.md),
                
                _buildLevelCard('Bronze', Icons.looks_one, Colors.brown),
                _buildLevelCard('Silver', Icons.looks_two, Colors.grey),
                _buildLevelCard('Gold', Icons.looks_3, Colors.amber),
              ],
            ),
          ),
        ),
        
        SizedBox(height: AppSpacing.lg),
        
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
                    Icon(Icons.groups, color: AppColors.primaryRed),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Segments clients',
                      style: AppTextStyles.titleLarge,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                
                _buildSegmentCard('Tous les clients', _users.length),
                _buildSegmentCard(
                  'Clients Gold',
                  _users.where((u) => u.loyaltyLevel == 'Gold').length,
                ),
                _buildSegmentCard(
                  'Clients Silver',
                  _users.where((u) => u.loyaltyLevel == 'Silver').length,
                ),
                _buildSegmentCard(
                  'Clients Bronze',
                  _users.where((u) => u.loyaltyLevel == 'Bronze').length,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(String label, String value) {
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

  Widget _buildLevelCard(String name, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color),
        title: Text(name),
        trailing: Icon(Icons.chevron_right, color: color),
      ),
    );
  }

  Widget _buildSegmentCard(String name, int count) {
    return Card(
      color: AppColors.backgroundLight,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        dense: true,
        title: Text(name),
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Color _getLoyaltyLevelColor(String level) {
    switch (level) {
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.grey;
      case 'Bronze':
        return Colors.brown;
      default:
        return AppColors.textLight;
    }
  }

  void _showLoyaltySettingsDialog() {
    final settings = _loyaltySettings ?? LoyaltySettings.defaultSettings();
    final pointsPerEuroController = TextEditingController(text: settings.pointsPerEuro.toString());
    final bronzeThresholdController = TextEditingController(text: settings.bronzeThreshold.toString());
    final silverThresholdController = TextEditingController(text: settings.silverThreshold.toString());
    final goldThresholdController = TextEditingController(text: settings.goldThreshold.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Paramètres de fidélité'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pointsPerEuroController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Points par € dépensé',
                  border: OutlineInputBorder(),
                  helperText: 'Ex: 1 point = 1€',
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: bronzeThresholdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Seuil Bronze (points)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: silverThresholdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Seuil Silver (points)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: goldThresholdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Seuil Gold (points)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: AppRadius.card,
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primaryRed, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Ces paramètres seront appliqués à tous les clients',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
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
              final pointsPerEuro = int.tryParse(pointsPerEuroController.text) ?? 1;
              final bronzeThreshold = int.tryParse(bronzeThresholdController.text) ?? 0;
              final silverThreshold = int.tryParse(silverThresholdController.text) ?? 500;
              final goldThreshold = int.tryParse(goldThresholdController.text) ?? 1000;
              
              final newSettings = LoyaltySettings(
                id: 'main',
                pointsPerEuro: pointsPerEuro,
                bronzeThreshold: bronzeThreshold,
                silverThreshold: silverThreshold,
                goldThreshold: goldThreshold,
                updatedAt: DateTime.now(),
              );
              
              final success = await _settingsRepository.saveLoyaltySettings(newSettings);
              
              Navigator.pop(context);
              
              if (success) {
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Paramètres sauvegardés'),
                    backgroundColor: AppColors.primaryRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de la sauvegarde'),
                    backgroundColor: AppColors.errorRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }
}
