// lib/src/screens/admin/communication/communication_loyalty_screen.dart
// Screen for managing loyalty program and customer segments

import 'package:flutter/material.dart';
import '../../../models/user_profile.dart';
import '../../../services/user_profile_service.dart';
import '../../../theme/app_theme.dart';

class CommunicationLoyaltyScreen extends StatefulWidget {
  const CommunicationLoyaltyScreen({super.key});

  @override
  State<CommunicationLoyaltyScreen> createState() =>
      _CommunicationLoyaltyScreenState();
}

class _CommunicationLoyaltyScreenState
    extends State<CommunicationLoyaltyScreen>
    with SingleTickerProviderStateMixin {
  final UserProfileService _service = UserProfileService();
  
  late TabController _tabController;
  List<UserProfile> _users = [];
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
    
    setState(() {
      _users = users;
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
                    Text(
                      'Programme de fidélité',
                      style: AppTextStyles.titleLarge,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                
                _buildSettingRow('Points par € dépensé', '1'),
                _buildSettingRow('Seuil Bronze', '0 points'),
                _buildSettingRow('Seuil Silver', '500 points'),
                _buildSettingRow('Seuil Gold', '1000 points'),
                
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
}
