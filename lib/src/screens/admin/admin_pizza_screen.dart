// lib/src/screens/admin/admin_pizza_screen.dart
// Écran CRUD pour gérer les pizzas (Admin uniquement)
// MIGRÉ VERS FIRESTORE - Synchronisation Cloud + Local

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../services/firestore_product_service.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';

class AdminPizzaScreen extends StatefulWidget {
  const AdminPizzaScreen({super.key});

  @override
  State<AdminPizzaScreen> createState() => _AdminPizzaScreenState();
}

class _AdminPizzaScreenState extends State<AdminPizzaScreen> {
  final FirestoreProductService _firestoreService = FirestoreProductService();
  List<Product> _pizzas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPizzas();
  }

  Future<void> _loadPizzas() async {
    setState(() => _isLoading = true);
    final pizzas = await _firestoreService.loadPizzas();
    setState(() {
      _pizzas = pizzas;
      _isLoading = false;
    });
  }

  Future<void> _showPizzaDialog({Product? pizza}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: pizza?.name ?? '');
    final descController = TextEditingController(text: pizza?.description ?? '');
    final priceController = TextEditingController(text: pizza?.price.toString() ?? '');
    final imageController = TextEditingController(text: pizza?.imageUrl ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pizza == null ? 'Nouvelle Pizza' : 'Modifier Pizza'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    hintText: 'Ex: Margherita',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nom requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    hintText: 'Ex: Tomate, Mozzarella, Basilic',
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Prix (€) *',
                    hintText: 'Ex: 12.50',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Prix requis';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Prix invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: imageController,
                  decoration: const InputDecoration(
                    labelText: 'URL Image (optionnel)',
                    hintText: 'https://...',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newPizza = Product(
                  id: pizza?.id ?? const Uuid().v4(),
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                  price: double.parse(priceController.text),
                  imageUrl: imageController.text.trim().isEmpty
                      ? 'https://via.placeholder.com/200'
                      : imageController.text.trim(),
                  category: 'Pizza',
                  isMenu: false,
                );

                bool success;
                if (pizza == null) {
                  success = await _firestoreService.addPizza(newPizza);
                } else {
                  success = await _firestoreService.updatePizza(newPizza);
                }

                if (success && context.mounted) {
                  Navigator.pop(context, true);
                }
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadPizzas();
    }
  }

  Future<void> _deletePizza(Product pizza) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${pizza.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _firestoreService.deletePizza(pizza.id);
      if (success) {
        _loadPizzas();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Pizzas'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pizzas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_pizza, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune pizza',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cliquez sur + pour ajouter une pizza',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                  itemCount: _pizzas.length,
                  itemBuilder: (context, index) {
                    final pizza = _pizzas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            pizza.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Icon(Icons.local_pizza, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                        title: Text(
                          pizza.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${pizza.price.toStringAsFixed(2)} € - ${pizza.description}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showPizzaDialog(pizza: pizza),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePizza(pizza),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPizzaDialog(),
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
