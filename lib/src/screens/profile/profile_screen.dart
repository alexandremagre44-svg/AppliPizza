// lib/src/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart'; // Pour accéder à l'historique
import '../../models/order.dart'; // Pour le type Order
import '../../providers/cart_provider.dart'; // Pour le type CartItem

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProvider);
    final history = userProfile.orderHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Simuler une déconnexion ou navigation vers l'écran de connexion
              context.go('/'); 
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, userProfile.name, userProfile.email),
            const SizedBox(height: 30),
            _buildSectionTitle(context, 'Historique des Commandes'),
            const SizedBox(height: 10),
            _buildOrderHistory(context, history),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
  
  // ... (Fonctions d'aide pour le profil)

  Widget _buildProfileHeader(BuildContext context, String name, String email) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Color(0xFFB00020),
          child: Icon(Icons.person, size: 40, color: Colors.white),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              email,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildOrderHistory(BuildContext context, List<Order> history) {
    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey),
              const SizedBox(height: 10),
              Text(
                'Aucune commande passée pour l\'instant.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final order = history[index];
        final formattedDate = '${order.date.day}/${order.date.month}/${order.date.year}';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Pour l'expansion
            title: Text('Commande #${history.length - index}'),
            subtitle: Text('$formattedDate - ${order.status}'), // <<< UTILISE CORRECTEMENT order.status
            trailing: Text(
              '${order.total.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: const Color(0xFFB00020),
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
              ...order.items.map((item) => ListTile(
                title: Text('${item.productName}'),
                subtitle: Text('${item.quantity} x ${item.price.toStringAsFixed(2)}€'),
                trailing: Text('${item.total.toStringAsFixed(2)}€'),
              )).toList(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Statut:', style: Theme.of(context).textTheme.bodyLarge),
                    // order.status est maintenant défini
                    Text(order.status, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)), 
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}