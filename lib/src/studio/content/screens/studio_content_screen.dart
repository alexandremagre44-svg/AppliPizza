// lib/src/studio/content/screens/studio_content_screen.dart
// Main screen for home content management in Studio V2

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../widgets/content_category_manager.dart';
import '../widgets/content_featured_products.dart';
import '../widgets/content_custom_sections.dart';
import '../widgets/content_section_layout_editor.dart';

/// Home Content Manager - Professional module for managing home screen content
/// 
/// Features:
/// - Category management (show/hide, reorder)
/// - Featured products section
/// - Custom sections with drag & drop
/// - Product reordering within categories
/// - Global section layout editor
class StudioContentScreen extends ConsumerStatefulWidget {
  const StudioContentScreen({super.key});

  @override
  ConsumerState<StudioContentScreen> createState() => _StudioContentScreenState();
}

class _StudioContentScreenState extends ConsumerState<StudioContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ContentSectionLayoutEditor(),
                ContentCategoryManager(),
                ContentFeaturedProducts(),
                ContentCustomSections(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.home_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contenu d\'accueil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Gérez l\'ordre et la visibilité des sections, catégories et produits',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          _buildInfoButton(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.view_list_outlined),
            text: 'Layout général',
          ),
          Tab(
            icon: Icon(Icons.category_outlined),
            text: 'Catégories',
          ),
          Tab(
            icon: Icon(Icons.star_outline),
            text: 'Produits mis en avant',
          ),
          Tab(
            icon: Icon(Icons.add_box_outlined),
            text: 'Sections personnalisées',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoButton() {
    return IconButton(
      icon: const Icon(Icons.help_outline),
      tooltip: 'Aide',
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Module Contenu d\'accueil'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ce module vous permet de personnaliser complètement la page d\'accueil de votre application.',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Fonctionnalités :',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Layout général : Organisez l\'ordre des sections'),
                  Text('• Catégories : Affichez/masquez et réordonnez'),
                  Text('• Produits mis en avant : Choisissez les produits vedettes'),
                  Text('• Sections personnalisées : Créez des sections thématiques'),
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
      },
    );
  }
}
