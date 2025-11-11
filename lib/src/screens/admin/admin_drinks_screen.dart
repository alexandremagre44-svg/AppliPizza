// lib/src/screens/admin/admin_drinks_screen.dart
// Écran CRUD pour gérer les boissons (Admin uniquement)

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/product.dart';
import '../../services/product_crud_service.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';

class AdminDrinksScreen extends StatefulWidget {
  const AdminDrinksScreen({super.key});

  @override
  State<AdminDrinksScreen> createState() => _AdminDrinksScreenState();
}

class _AdminDrinksScreenState extends State<AdminDrinksScreen> {
  final ProductCrudService _crudService = ProductCrudService();
  List<Product> _drinks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrinks();
  }

  Future<void> _loadDrinks() async {
    setState(() => _isLoading = true);
    final drinks = await _crudService.loadDrinks();
    setState(() {
      _drinks = drinks;
      _isLoading = false;
    });
  }

  Future<void> _showDrinkDialog({Product? drink}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: drink?.name ?? '');
    final descController = TextEditingController(text: drink?.description ?? '');
    final priceController = TextEditingController(text: drink?.price.toString() ?? '');
    final imageController = TextEditingController(text: drink?.imageUrl ?? '');
    final orderController = TextEditingController(text: drink?.order.toString() ?? '0');
    bool isFeatured = drink?.isFeatured ?? false;
    bool isActive = drink?.isActive ?? true;
    String displaySpot = drink?.displaySpot ?? 'all';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.cyan.shade50.withOpacity(0.3),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyan.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_drink,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          drink == null ? 'Nouvelle Boisson' : 'Modifier Boisson',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Nom *',
                              hintText: 'Ex: Coca-Cola',
                              prefixIcon: Icon(Icons.local_drink, color: Colors.cyan.shade600),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade600, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nom requis';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: descController,
                            decoration: InputDecoration(
                              labelText: 'Description *',
                              hintText: 'Ex: Boisson gazeuse rafraîchissante',
                              prefixIcon: Icon(Icons.description, color: Colors.cyan.shade600),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade600, width: 2),
                              ),
                            ),
                            maxLines: 2,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description requise';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: priceController,
                            decoration: InputDecoration(
                              labelText: 'Prix (€) *',
                              hintText: 'Ex: 2.50',
                              prefixIcon: Icon(Icons.euro, color: Colors.cyan.shade600),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade600, width: 2),
                              ),
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
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: imageController,
                            decoration: InputDecoration(
                              labelText: 'URL Image (optionnel)',
                              hintText: 'https://...',
                              prefixIcon: Icon(Icons.image, color: Colors.cyan.shade600),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade600, width: 2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Ordre d'affichage
                          TextFormField(
                            controller: orderController,
                            decoration: InputDecoration(
                              labelText: 'Ordre d\'affichage',
                              hintText: 'Ex: 1, 2, 3...',
                              prefixIcon: Icon(Icons.sort, color: Colors.cyan.shade600),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade200),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.cyan.shade600, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final order = int.tryParse(value);
                                if (order == null) {
                                  return 'Ordre invalide';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Mise en avant toggle
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.cyan.shade50.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.cyan.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber.shade600, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mise en avant',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: Colors.cyan.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Afficher ce produit en priorité',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isFeatured,
                                  onChanged: (value) {
                                    setState(() => isFeatured = value);
                                  },
                                  activeColor: Colors.amber.shade600,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Statut actif toggle
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.visibility, color: Colors.green.shade600, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Produit actif',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Visible par les clients',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isActive,
                                  onChanged: (value) {
                                    setState(() => isActive = value);
                                  },
                                  activeColor: Colors.green.shade600,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Zone d'affichage
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.blue.shade600, size: 24),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Zone d\'affichage',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ChoiceChip(
                                      label: const Text('Partout'),
                                      selected: displaySpot == 'all',
                                      onSelected: (selected) {
                                        if (selected) setState(() => displaySpot = 'all');
                                      },
                                      selectedColor: Colors.blue.shade200,
                                      labelStyle: TextStyle(
                                        color: displaySpot == 'all' ? Colors.blue.shade900 : Colors.grey.shade700,
                                        fontWeight: displaySpot == 'all' ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                    ChoiceChip(
                                      label: const Text('Accueil'),
                                      selected: displaySpot == 'home',
                                      onSelected: (selected) {
                                        if (selected) setState(() => displaySpot = 'home');
                                      },
                                      selectedColor: Colors.blue.shade200,
                                      labelStyle: TextStyle(
                                        color: displaySpot == 'home' ? Colors.blue.shade900 : Colors.grey.shade700,
                                        fontWeight: displaySpot == 'home' ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                    ChoiceChip(
                                      label: const Text('Promotions'),
                                      selected: displaySpot == 'promotions',
                                      onSelected: (selected) {
                                        if (selected) setState(() => displaySpot = 'promotions');
                                      },
                                      selectedColor: Colors.blue.shade200,
                                      labelStyle: TextStyle(
                                        color: displaySpot == 'promotions' ? Colors.blue.shade900 : Colors.grey.shade700,
                                        fontWeight: displaySpot == 'promotions' ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                    ChoiceChip(
                                      label: const Text('Nouveautés'),
                                      selected: displaySpot == 'new',
                                      onSelected: (selected) {
                                        if (selected) setState(() => displaySpot = 'new');
                                      },
                                      selectedColor: Colors.blue.shade200,
                                      labelStyle: TextStyle(
                                        color: displaySpot == 'new' ? Colors.blue.shade900 : Colors.grey.shade700,
                                        fontWeight: displaySpot == 'new' ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final newDrink = Product(
                              id: drink?.id ?? const Uuid().v4(),
                              name: nameController.text.trim(),
                              description: descController.text.trim(),
                              price: double.parse(priceController.text),
                              imageUrl: imageController.text.trim().isEmpty
                                  ? 'https://via.placeholder.com/200'
                                  : imageController.text.trim(),
                              category: 'Boissons',
                              isMenu: false,
                              isFeatured: isFeatured,
                              isActive: isActive,
                              displaySpot: displaySpot,
                              order: int.tryParse(orderController.text) ?? 0,
                            );

                            bool success;
                            if (drink == null) {
                              success = await _crudService.addDrink(newDrink);
                            } else {
                              success = await _crudService.updateDrink(newDrink);
                            }

                            if (success && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Sauvegarder',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      _loadDrinks();
    }
  }

  Future<void> _deleteDrink(Product drink) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.red.shade50.withOpacity(0.5),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade700],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Confirmer la suppression',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Voulez-vous vraiment supprimer "${drink.name}" ?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cette action est irréversible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true) {
      final success = await _crudService.deleteDrink(drink.id);
      if (success) {
        _loadDrinks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Text('✅', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('${drink.name} supprimée avec succès'),
                  ),
                ],
              ),
              backgroundColor: AppTheme.primaryRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
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
                'Gestion des Boissons',
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.cyan.shade400,
                      Colors.blue.shade600,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: 10,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          Icons.local_drink,
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
          ),
          
          // Content
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _drinks.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.cyan.shade300.withOpacity(0.2),
                                    Colors.blue.shade400.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyan.withOpacity(0.1),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.local_drink,
                                size: 70,
                                color: Colors.cyan.shade600,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Aucune boisson',
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'Cliquez sur + pour ajouter votre première boisson',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final drink = _drinks[index];
                            return _buildEnhancedDrinkCard(context, drink);
                          },
                          childCount: _drinks.length,
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDrinkDialog(),
        backgroundColor: Colors.blue.shade600,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvelle Boisson',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 6,
      ),
    );
  }

  Widget _buildEnhancedDrinkCard(BuildContext context, Product drink) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.cyan.shade50.withOpacity(0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDrinkDialog(drink: drink),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image with gradient border
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.cyan.shade400, Colors.blue.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        drink.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.local_drink,
                            color: Colors.cyan.shade600,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              drink.name,
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                            ),
                          ),
                          if (!drink.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility_off, size: 14, color: Colors.grey.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Inactif',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (drink.isFeatured && drink.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'En avant',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.amber.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        drink.description,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.cyan.shade400, Colors.blue.shade600],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${drink.price.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Action buttons
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade700),
                        onPressed: () => _showDrinkDialog(drink: drink),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red.shade700),
                        onPressed: () => _deleteDrink(drink),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
