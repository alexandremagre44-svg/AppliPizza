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
                      _buildInfoTab('Bannière Hero', Icons.image),
                      _buildInfoTab('Bandeau Promo', Icons.notifications),
                      _buildInfoTab('Blocs de Contenu', Icons.view_agenda),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildInfoTab(String title, IconData icon) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.primaryRed.withOpacity(0.3)),
            SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Configuration disponible prochainement',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
