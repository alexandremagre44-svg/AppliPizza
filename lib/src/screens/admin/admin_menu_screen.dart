// lib/src/screens/admin/admin_menu_screen.dart
// Écran CRUD pour gérer les menus (Admin uniquement)

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../services/product_crud_service.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final ProductCrudService _crudService = ProductCrudService();
  List<Product> _menus = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenus();
  }

  Future<void> _loadMenus() async {
    setState(() => _isLoading = true);
    final menus = await _crudService.loadMenus();
    setState(() {
      _menus = menus;
      _isLoading = false;
    });
  }

  Future<void> _showMenuDialog({Product? menu}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: menu?.name ?? '');
    final descController = TextEditingController(text: menu?.description ?? '');
    final priceController = TextEditingController(text: menu?.price.toString() ?? '');
    final imageController = TextEditingController(text: menu?.imageUrl ?? '');
    
    // P10: Composition menu
    int pizzaCount = menu?.pizzaCount ?? 1;
    int drinkCount = menu?.drinkCount ?? 1;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(menu == null ? 'Nouveau Menu' : 'Modifier Menu'),
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
                      hintText: 'Ex: Menu Duo',
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
                      hintText: 'Ex: 2 pizzas + 2 boissons',
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
                  
                  // P10: Composition du menu
                  const Text(
                    'Composition du menu:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  
                  // Nombre de pizzas
                  Row(
                    children: [
                      const Icon(Icons.local_pizza, size: 20),
                      const SizedBox(width: 8),
                      const Text('Pizzas:'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: pizzaCount > 0
                            ? () => setState(() => pizzaCount--)
                            : null,
                      ),
                      Text(
                        pizzaCount.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: pizzaCount < 5
                            ? () => setState(() => pizzaCount++)
                            : null,
                      ),
                    ],
                  ),
                  
                  // Nombre de boissons
                  Row(
                    children: [
                      const Icon(Icons.local_drink, size: 20),
                      const SizedBox(width: 8),
                      const Text('Boissons:'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: drinkCount > 0
                            ? () => setState(() => drinkCount--)
                            : null,
                      ),
                      Text(
                        drinkCount.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: drinkCount < 5
                            ? () => setState(() => drinkCount++)
                            : null,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Prix (€) *',
                      hintText: 'Ex: 34.90',
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
                  // Mise à jour de la description selon la composition
                  final compositionDesc = '${pizzaCount} pizza${pizzaCount > 1 ? 's' : ''} + ${drinkCount} boisson${drinkCount > 1 ? 's' : ''}';
                  
                  final newMenu = Product(
                    id: menu?.id ?? const Uuid().v4(),
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: double.parse(priceController.text),
                    imageUrl: imageController.text.trim().isEmpty
                        ? 'https://via.placeholder.com/200'
                        : imageController.text.trim(),
                    category: 'Menus',
                    isMenu: true,
                    pizzaCount: pizzaCount,
                    drinkCount: drinkCount,
                  );

                  bool success;
                  if (menu == null) {
                    success = await _crudService.addMenu(newMenu);
                  } else {
                    success = await _crudService.updateMenu(newMenu);
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
      ),
    );

    if (result == true) {
      _loadMenus();
    }
  }

  Future<void> _deleteMenu(Product menu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer "${menu.name}" ?'),
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
      final success = await _crudService.deleteMenu(menu.id);
      if (success) {
        _loadMenus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Menus'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _menus.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun menu',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cliquez sur + pour ajouter un menu',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                  itemCount: _menus.length,
                  itemBuilder: (context, index) {
                    final menu = _menus[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            menu.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Icon(Icons.restaurant_menu, color: Colors.grey[600]),
                            ),
                          ),
                        ),
                        title: Text(
                          menu.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${menu.price.toStringAsFixed(2)} € - ${menu.description}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.local_pizza, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${menu.pizzaCount}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.local_drink, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${menu.drinkCount}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showMenuDialog(menu: menu),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMenu(menu),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenuDialog(),
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
