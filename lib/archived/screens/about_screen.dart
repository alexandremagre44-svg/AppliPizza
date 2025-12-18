// lib/src/screens/about/about_screen.dart

import 'package:flutter/material.dart';
import '../../../builder/models/models.dart';
import '../../../builder/utils/utils.dart';
import '../../white_label/theme/theme_extensions.dart';

class AboutScreen extends StatelessWidget {
  static const String appId = 'pizza_delizza';

  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Try Builder B3 first, fallback to default implementation
    return BuilderPageWrapper(
      pageId: BuilderPageId.about,
      appId: appId,
      fallbackBuilder: _buildDefaultAbout,
    );
  }

  Widget _buildDefaultAbout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Logo/Image placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.restaurant,
                size: 100,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Pizza Delizza',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'La meilleure pizzeria de la région',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // About sections
          _buildSection(
            icon: Icons.history,
            title: 'Notre Histoire',
            content:
                'Depuis 2010, nous préparons les meilleures pizzas avec passion et savoir-faire. Notre secret ? Des ingrédients frais et une pâte maison préparée chaque jour.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.star,
            title: 'Notre Philosophie',
            content:
                'Qualité, authenticité et service. Nous utilisons uniquement des produits locaux et de saison pour garantir le meilleur goût à nos clients.',
          ),
          const SizedBox(height: 16),
          _buildSection(
            icon: Icons.people,
            title: 'Notre Équipe',
            content:
                'Une équipe de passionnés dédiée à vous offrir la meilleure expérience culinaire. Nos pizzaïolos sont formés aux techniques traditionnelles italiennes.',
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary[700],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
