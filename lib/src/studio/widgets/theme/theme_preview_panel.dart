// lib/src/studio/widgets/theme/theme_preview_panel.dart
// Real-time preview panel showing theme changes in phone mockup

import 'package:flutter/material.dart';
import '../../../models/theme_config.dart';

class ThemePreviewPanel extends StatelessWidget {
  final ThemeConfig config;

  const ThemePreviewPanel({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.phone_iphone, size: 20),
                SizedBox(width: 8),
                Text(
                  'Live Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Phone mockup
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: _buildPhoneMockup(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneMockup() {
    final isDarkMode = config.darkMode;
    final bgColor = isDarkMode 
        ? const Color(0xFF1E1E1E)
        : config.colors.background;
    
    return AspectRatio(
      aspectRatio: 9 / 19.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              children: [
                // Status bar
                _buildStatusBar(),
                
                // App bar
                _buildAppBar(),
                
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeroSection(),
                        _buildCategoryCards(),
                        _buildProductCards(),
                      ],
                    ),
                  ),
                ),
                
                // Bottom navigation
                _buildBottomNav(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final isDarkMode = config.darkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, size: 14, color: textColor),
              const SizedBox(width: 4),
              Icon(Icons.wifi, size: 14, color: textColor),
              const SizedBox(width: 4),
              Icon(Icons.battery_full, size: 14, color: textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final isDarkMode = config.darkMode;
    final surfaceColor = isDarkMode 
        ? const Color(0xFF2C2C2C)
        : config.colors.surface;
    final textColor = isDarkMode 
        ? Colors.white
        : config.colors.textPrimary;
    
    return Container(
      padding: EdgeInsets.all(config.spacing.paddingMedium),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: config.shadows.navbar,
            offset: Offset(0, config.shadows.navbar / 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Pizza Deli\'Zza',
              style: TextStyle(
                fontSize: config.typography.baseSize * config.typography.scaleFactor,
                fontWeight: FontWeight.bold,
                color: textColor,
                fontFamily: config.typography.fontFamily,
              ),
            ),
          ),
          Icon(Icons.search, color: textColor, size: 20),
          SizedBox(width: config.spacing.paddingSmall),
          Icon(Icons.shopping_cart, color: textColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    final isDarkMode = config.darkMode;
    final textColor = isDarkMode 
        ? Colors.white
        : config.colors.textPrimary;
    
    return Container(
      margin: EdgeInsets.all(config.spacing.paddingMedium),
      padding: EdgeInsets.all(config.spacing.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.colors.primary,
            config.colors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(config.radius.large),
        boxShadow: [
          BoxShadow(
            color: config.colors.primary.withOpacity(0.3),
            blurRadius: config.shadows.card,
            offset: Offset(0, config.shadows.card / 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Special Offer!',
            style: TextStyle(
              fontSize: config.typography.baseSize * config.typography.scaleFactor * 1.2,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: config.typography.fontFamily,
            ),
          ),
          SizedBox(height: config.spacing.paddingSmall),
          Text(
            'Get 20% off on your first order',
            style: TextStyle(
              fontSize: config.typography.baseSize,
              color: Colors.white.withOpacity(0.9),
              fontFamily: config.typography.fontFamily,
            ),
          ),
          SizedBox(height: config.spacing.paddingMedium),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: config.spacing.paddingMedium,
              vertical: config.spacing.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(config.radius.full),
            ),
            child: Text(
              'Order Now',
              style: TextStyle(
                fontSize: config.typography.baseSize,
                fontWeight: FontWeight.w600,
                color: config.colors.primary,
                fontFamily: config.typography.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCards() {
    final isDarkMode = config.darkMode;
    final surfaceColor = isDarkMode 
        ? const Color(0xFF2C2C2C)
        : config.colors.surface;
    final textColor = isDarkMode 
        ? Colors.white
        : config.colors.textPrimary;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: config.spacing.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              fontSize: config.typography.baseSize * config.typography.scaleFactor,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: config.typography.fontFamily,
            ),
          ),
          SizedBox(height: config.spacing.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _buildCategoryCard(
                  'Pizzas',
                  Icons.local_pizza,
                  surfaceColor,
                  textColor,
                ),
              ),
              SizedBox(width: config.spacing.paddingSmall),
              Expanded(
                child: _buildCategoryCard(
                  'Drinks',
                  Icons.local_drink,
                  surfaceColor,
                  textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    Color surfaceColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.all(config.spacing.paddingMedium),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(config.radius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: config.shadows.card,
            offset: Offset(0, config.shadows.card / 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(config.spacing.paddingSmall),
            decoration: BoxDecoration(
              color: config.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(config.radius.small),
            ),
            child: Icon(
              icon,
              color: config.colors.primary,
              size: 20,
            ),
          ),
          SizedBox(height: config.spacing.paddingSmall),
          Text(
            title,
            style: TextStyle(
              fontSize: config.typography.baseSize * 0.9,
              fontWeight: FontWeight.w600,
              color: textColor,
              fontFamily: config.typography.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCards() {
    final isDarkMode = config.darkMode;
    final surfaceColor = isDarkMode 
        ? const Color(0xFF2C2C2C)
        : config.colors.surface;
    final textColor = isDarkMode 
        ? Colors.white
        : config.colors.textPrimary;
    final textSecondaryColor = isDarkMode 
        ? Colors.white70
        : config.colors.textSecondary;
    
    return Padding(
      padding: EdgeInsets.all(config.spacing.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Items',
            style: TextStyle(
              fontSize: config.typography.baseSize * config.typography.scaleFactor,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: config.typography.fontFamily,
            ),
          ),
          SizedBox(height: config.spacing.paddingMedium),
          _buildProductCard(
            'Margherita',
            '€12.99',
            surfaceColor,
            textColor,
            textSecondaryColor,
          ),
          SizedBox(height: config.spacing.paddingSmall),
          _buildProductCard(
            'Pepperoni',
            '€14.99',
            surfaceColor,
            textColor,
            textSecondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    String name,
    String price,
    Color surfaceColor,
    Color textColor,
    Color textSecondaryColor,
  ) {
    return Container(
      padding: EdgeInsets.all(config.spacing.paddingMedium),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(config.radius.medium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: config.shadows.card,
            offset: Offset(0, config.shadows.card / 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: config.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(config.radius.small),
            ),
            child: Icon(
              Icons.local_pizza,
              color: config.colors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: config.spacing.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: config.typography.baseSize,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontFamily: config.typography.fontFamily,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: config.typography.baseSize * 0.9,
                    color: textSecondaryColor,
                    fontFamily: config.typography.fontFamily,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(config.spacing.paddingSmall),
            decoration: BoxDecoration(
              color: config.colors.primary,
              borderRadius: BorderRadius.circular(config.radius.small),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isDarkMode = config.darkMode;
    final surfaceColor = isDarkMode 
        ? const Color(0xFF2C2C2C)
        : config.colors.surface;
    final textColor = isDarkMode 
        ? Colors.white70
        : config.colors.textSecondary;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: config.spacing.paddingMedium,
        vertical: config.spacing.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: config.shadows.navbar,
            offset: Offset(0, -config.shadows.navbar / 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home, color: config.colors.primary, size: 24),
          Icon(Icons.search, color: textColor, size: 24),
          Icon(Icons.shopping_cart, color: textColor, size: 24),
          Icon(Icons.person, color: textColor, size: 24),
        ],
      ),
    );
  }
}
