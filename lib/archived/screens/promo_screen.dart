// lib/src/screens/promo/promo_screen.dart

import 'package:flutter/material.dart';
import '../../../builder/models/models.dart';
import '../../../builder/utils/utils.dart';
import '../../white_label/theme/theme_extensions.dart';

class PromoScreen extends StatelessWidget {
  static const String appId = 'pizza_delizza';

  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Try Builder B3 first, fallback to default implementation
    return BuilderPageWrapper(
      pageId: BuilderPageId.promo,
      appId: appId,
      fallbackBuilder: _buildDefaultPromo,
    );
  }

  Widget _buildDefaultPromo() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero section
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer, size: 64, color: context.surfaceColor),
                  SizedBox(height: 16),
                  Text(
                    'Nos Promotions',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: context.surfaceColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Profitez de nos offres spéciales',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.surfaceColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Promo cards
          _buildPromoCard(
            icon: Icons.restaurant,
            title: 'Menu Famille',
            description: '2 pizzas + 1 boisson offerte',
            discount: '-20%',
          ),
          const SizedBox(height: 16),
          _buildPromoCard(
            icon: Icons.local_pizza,
            title: 'Pizza du Jour',
            description: 'Une pizza achetée = 1 dessert offert',
            discount: 'Offre',
          ),
          const SizedBox(height: 16),
          _buildPromoCard(
            icon: Icons.cake,
            title: 'Happy Hour',
            description: 'Tous les desserts à -30%',
            discount: '-30%',
          ),
          const SizedBox(height: 24),
          const Text(
            'Utilisez le Builder B3 pour personnaliser cette page !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({
    required IconData icon,
    required String title,
    required String description,
    required String discount,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.orange.shade100,
              child: Icon(icon, color: Colors.orange.shade700, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                discount,
                style: const TextStyle(
                  color: context.surfaceColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
