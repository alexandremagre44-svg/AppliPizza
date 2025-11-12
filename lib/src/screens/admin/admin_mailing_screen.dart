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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.help_outline, color: AppTheme.primaryRed),
            SizedBox(width: 8),
            Text('Guide d\'utilisation'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                'Modèles d\'emails',
                'Créez et gérez vos templates HTML pour vos campagnes. '
                'Utilisez les variables {{variable}} pour personnaliser vos emails.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Campagnes',
                'Planifiez et envoyez vos campagnes d\'emailing. '
                'Sélectionnez un modèle, choisissez votre audience et définissez la date d\'envoi.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Abonnés',
                'Gérez votre liste d\'abonnés avec segmentation par tags. '
                'Vous pouvez exporter la liste en CSV et effectuer des actions groupées.',
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Conseils:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildTip('Utilisez la recherche pour trouver rapidement'),
              _buildTip('Dupliquez vos modèles pour gagner du temps'),
              _buildTip('Testez vos campagnes avant l\'envoi massif'),
              _buildTip('Exportez vos données pour les analyser'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppTheme.primaryRed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(tip, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
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
                  color: AppColors.primaryRed,
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
            actions: [
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white),
                onPressed: () => _showHelpDialog(),
                tooltip: 'Aide',
              ),
            ],
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
