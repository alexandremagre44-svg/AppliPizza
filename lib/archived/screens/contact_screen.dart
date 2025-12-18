// lib/src/screens/contact/contact_screen.dart

import 'package:flutter/material.dart';
import '../../../builder/models/models.dart';
import '../../../builder/utils/utils.dart';
import '../../white_label/theme/theme_extensions.dart';

class ContactScreen extends StatelessWidget {
  static const String appId = 'pizza_delizza';

  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Try Builder B3 first, fallback to default implementation
    return BuilderPageWrapper(
      pageId: BuilderPageId.contact,
      appId: appId,
      fallbackBuilder: _buildDefaultContact,
    );
  }

  Widget _buildDefaultContact() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.phone, size: 64, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Contactez-nous',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Nous sommes là pour vous aider',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact info cards
          _buildContactCard(
            icon: Icons.phone,
            title: 'Téléphone',
            info: '+33 1 23 45 67 89',
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.email,
            title: 'Email',
            info: 'contact@pizzadelizza.fr',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.location_on,
            title: 'Adresse',
            info: '123 Rue de la Pizza, 75000 Paris',
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildContactCard(
            icon: Icons.schedule,
            title: 'Horaires',
            info: 'Lun-Dim: 11h00 - 23h00',
            color: Colors.orange,
          ),
          const SizedBox(height: 24),

          // Social media section
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suivez-nous',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton(Icons.facebook, Colors.blue[900]!),
                      _buildSocialButton(Icons.camera_alt, Colors.pink),
                      _buildSocialButton(Icons.tag, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String info,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(info),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
