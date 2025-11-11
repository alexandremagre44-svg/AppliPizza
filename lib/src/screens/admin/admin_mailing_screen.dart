// lib/src/screens/admin/admin_mailing_screen.dart
// Écran principal du module Mailing avec 3 onglets: Modèles, Campagnes, Abonnés

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';
import 'mailing/email_templates_tab.dart';
import 'mailing/campaigns_tab.dart';
import 'mailing/subscribers_tab.dart';

class AdminMailingScreen extends StatefulWidget {
  const AdminMailingScreen({super.key});

  @override
  State<AdminMailingScreen> createState() => _AdminMailingScreenState();
}

class _AdminMailingScreenState extends State<AdminMailingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced SliverAppBar with gradient
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Mailing Marketing',
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryRed,
                      AppTheme.primaryRedDark,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: 10,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          Icons.email,
                          size: 180,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.description, size: 20),
                      text: 'Modèles',
                    ),
                    Tab(
                      icon: Icon(Icons.campaign, size: 20),
                      text: 'Campagnes',
                    ),
                    Tab(
                      icon: Icon(Icons.people, size: 20),
                      text: 'Abonnés',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: const [
                EmailTemplatesTab(),
                CampaignsTab(),
                SubscribersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
