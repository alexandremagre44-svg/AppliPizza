// lib/src/screens/home/home_screen_b2.dart
// HomeScreenB2 - New home screen based on AppConfig B2 architecture
// Uses AppConfigService to display home sections dynamically

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/app_config.dart';
import '../../services/app_config_service.dart';
import '../../widgets/home/hero_banner.dart';
import '../../widgets/home/home_shimmer_loading.dart';
import '../../theme/app_theme.dart';

/// HomeScreenB2 - New implementation using AppConfig B2 architecture
/// 
/// This screen:
/// - Uses AppConfigService.watchConfig() to listen for real-time config changes
/// - Displays home sections dynamically based on HomeSectionConfig
/// - Respects home.texts and home.theme from AppConfig
/// - Reuses existing widgets (HeroBanner, etc.) where possible
class HomeScreenB2 extends StatefulWidget {
  const HomeScreenB2({super.key});

  @override
  State<HomeScreenB2> createState() => _HomeScreenB2State();
}

class _HomeScreenB2State extends State<HomeScreenB2> {
  final AppConfigService _configService = AppConfigService();
  static const String _appId = 'pizza_delizza';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pizza Deli\'Zza B2',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.surfaceWhite,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
      ),
      body: StreamBuilder<AppConfig?>(
        stream: _configService.watchConfig(appId: _appId, draft: false),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const HomeShimmerLoading();
          }

          // Error state
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          // No data state
          if (!snapshot.hasData || snapshot.data == null) {
            return _buildNoConfigState();
          }

          final config = snapshot.data!;
          return _buildContent(config);
        },
      ),
    );
  }

  Widget _buildContent(AppConfig config) {
    final home = config.home;
    
    // Sort sections by order
    final sortedSections = List<HomeSectionConfig>.from(home.sections)
      ..sort((a, b) => a.order.compareTo(b.order));

    // Filter only active sections
    final activeSections = sortedSections.where((s) => s.active).toList();

    return RefreshIndicator(
      onRefresh: () async {
        // Trigger a refresh by reading the stream again
        setState(() {});
      },
      child: CustomScrollView(
        slivers: [
          // Welcome header
          SliverToBoxAdapter(
            child: _buildWelcomeHeader(home.texts),
          ),
          
          // Dynamic sections
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final section = activeSections[index];
                return _buildSection(section, config);
              },
              childCount: activeSections.length,
            ),
          ),
          
          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(TextsConfig texts) {
    return Container(
      padding: AppSpacing.paddingXXL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts.welcomeTitle,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            texts.welcomeSubtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(HomeSectionConfig section, AppConfig config) {
    switch (section.type) {
      case HomeSectionType.hero:
        return _buildHeroSection(section);
      
      case HomeSectionType.promoBanner:
        return _buildPromoBannerSection(section);
      
      case HomeSectionType.popup:
        // Popups are shown as dialogs, not inline sections
        return const SizedBox.shrink();
      
      case HomeSectionType.productGrid:
        return _buildProductGridSection(section);
      
      case HomeSectionType.categoryList:
        return _buildCategoryListSection(section);
      
      case HomeSectionType.custom:
      default:
        return _buildCustomSection(section);
    }
  }

  Widget _buildHeroSection(HomeSectionConfig section) {
    final data = section.data;
    final title = data['title'] as String? ?? '';
    final subtitle = data['subtitle'] as String? ?? '';
    final imageUrl = data['imageUrl'] as String? ?? '';
    final ctaLabel = data['ctaLabel'] as String? ?? 'En savoir plus';
    final ctaTarget = data['ctaTarget'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: HeroBanner(
        title: title,
        subtitle: subtitle,
        buttonText: ctaLabel,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        onPressed: () {
          // Navigate based on ctaTarget
          if (ctaTarget == 'menu') {
            context.go('/menu');
          } else if (ctaTarget.isNotEmpty) {
            context.go(ctaTarget);
          }
        },
      ),
    );
  }

  Widget _buildPromoBannerSection(HomeSectionConfig section) {
    final data = section.data;
    final text = data['text'] as String? ?? '';
    final backgroundColor = data['backgroundColor'] as String? ?? '#D62828';
    final textColor = data['textColor'] as String? ?? '#FFFFFF';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _parseColor(backgroundColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer,
            color: _parseColor(textColor),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.titleMedium.copyWith(
                color: _parseColor(textColor),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGridSection(HomeSectionConfig section) {
    final data = section.data;
    final title = data['title'] as String? ?? 'Produits';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: AppTextStyles.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Grille de produits\n(À implémenter avec productIds)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryListSection(HomeSectionConfig section) {
    final data = section.data;
    final title = data['title'] as String? ?? 'Catégories';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: AppTextStyles.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Liste de catégories\n(À implémenter)',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSection(HomeSectionConfig section) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Section personnalisée: ${section.id}',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${section.type.value}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorRed,
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Erreur de chargement',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoConfigState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.settings_suggest,
              size: 64,
              color: AppColors.textLight,
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Configuration non trouvée',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Aucune configuration n\'a été trouvée pour cette application.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _configService.initializeDefaultConfig(appId: _appId);
                  setState(() {});
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Initialiser la configuration'),
            ),
          ],
        ),
      ),
    );
  }

  /// Parse color from hex string
  Color _parseColor(String hexString) {
    try {
      final hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      // Return default color on error
    }
    return AppColors.primaryRed;
  }
}
