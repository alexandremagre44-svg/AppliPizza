// lib/src/studio/content/widgets/content_featured_products.dart
// Widget for managing featured products section

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/product.dart';
import '../../../providers/product_provider.dart';
import '../models/featured_products_model.dart';
import '../services/featured_products_service.dart';
import '../providers/content_providers.dart';

class ContentFeaturedProducts extends ConsumerStatefulWidget {
  const ContentFeaturedProducts({super.key});

  @override
  ConsumerState<ContentFeaturedProducts> createState() => _ContentFeaturedProductsState();
}

class _ContentFeaturedProductsState extends ConsumerState<ContentFeaturedProducts> {
  final _featuredService = FeaturedProductsService();
  FeaturedProductsConfig? _config;
  List<Product> _availableProducts = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _featuredService.initIfMissing();
      final config = await _featuredService.getConfig();
      
      if (mounted) {
        setState(() {
          _config = config;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveConfig() async {
    if (_config == null) return;
    
    setState(() => _isSaving = true);
    try {
      await _featuredService.updateConfig(_config!);
      ref.invalidate(featuredProductsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration sauvegardée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showProductSelector() {
    final productsAsync = ref.read(productListProvider);
    
    productsAsync.when(
      data: (products) {
        showDialog(
          context: context,
          builder: (context) => _ProductSelectorDialog(
            products: products.where((p) => p.isActive).toList(),
            selectedIds: _config?.productIds ?? [],
            onConfirm: (selectedIds) {
              setState(() {
                _config = _config?.copyWith(
                  productIds: selectedIds,
                  updatedAt: DateTime.now(),
                );
              });
            },
          ),
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chargement des produits...')),
        );
      },
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _config == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildInstructions(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfigCard(),
                const SizedBox(height: 16),
                _buildSelectedProductsList(),
              ],
            ),
          ),
        ),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Sélectionnez les produits à mettre en avant sur la page d\'accueil. '
              'Vous pouvez les réordonner par glisser-déposer.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Configuration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _config!.isActive,
                  onChanged: (value) {
                    setState(() {
                      _config = _config!.copyWith(
                        isActive: value,
                        updatedAt: DateTime.now(),
                      );
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Type d\'affichage',
              value: _config!.displayType.value,
              items: FeaturedDisplayType.values
                  .map((e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(_getDisplayTypeLabel(e)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _config = _config!.copyWith(
                    displayType: FeaturedDisplayType.fromString(value!),
                    updatedAt: DateTime.now(),
                  );
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Position',
              value: _config!.position.value,
              items: FeaturedPosition.values
                  .map((e) => DropdownMenuItem(
                        value: e.value,
                        child: Text(_getPositionLabel(e)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _config = _config!.copyWith(
                    position: FeaturedPosition.fromString(value!),
                    updatedAt: DateTime.now(),
                  );
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto-remplissage'),
              subtitle: const Text(
                'Remplir automatiquement avec les produits mis en avant si vide',
              ),
              value: _config!.autoFill,
              onChanged: (value) {
                setState(() {
                  _config = _config!.copyWith(
                    autoFill: value,
                    updatedAt: DateTime.now(),
                  );
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedProductsList() {
    final productsAsync = ref.watch(productListProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Produits sélectionnés',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _showProductSelector,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            productsAsync.when(
              data: (products) {
                if (_config!.productIds.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.star_outline, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text('Aucun produit sélectionné'),
                        ],
                      ),
                    ),
                  );
                }

                final selectedProducts = products
                    .where((p) => _config!.productIds.contains(p.id))
                    .toList();

                return ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: selectedProducts.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final productIds = List<String>.from(_config!.productIds);
                      final item = productIds.removeAt(oldIndex);
                      productIds.insert(newIndex, item);
                      _config = _config!.copyWith(
                        productIds: productIds,
                        updatedAt: DateTime.now(),
                      );
                    });
                  },
                  itemBuilder: (context, index) {
                    final product = selectedProducts[index];
                    return ListTile(
                      key: ValueKey(product.id),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: product.imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(product.imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey.shade200,
                        ),
                        child: product.imageUrl.isEmpty
                            ? const Icon(Icons.image_not_supported)
                            : null,
                      ),
                      title: Text(product.name),
                      subtitle: Text('${product.price.toStringAsFixed(2)} €'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                final productIds = List<String>.from(_config!.productIds);
                                productIds.remove(product.id);
                                _config = _config!.copyWith(
                                  productIds: productIds,
                                  updatedAt: DateTime.now(),
                                );
                              });
                            },
                          ),
                          const Icon(Icons.drag_handle),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Erreur: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _saveConfig,
          icon: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(_isSaving ? 'Sauvegarde...' : 'Sauvegarder la configuration'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  String _getDisplayTypeLabel(FeaturedDisplayType type) {
    switch (type) {
      case FeaturedDisplayType.carousel:
        return 'Carrousel';
      case FeaturedDisplayType.hero:
        return 'Hero';
      case FeaturedDisplayType.horizontalCards:
        return 'Cartes horizontales';
    }
  }

  String _getPositionLabel(FeaturedPosition position) {
    switch (position) {
      case FeaturedPosition.beforeCategories:
        return 'Avant les catégories';
      case FeaturedPosition.afterCategories:
        return 'Après les catégories';
    }
  }
}

class _ProductSelectorDialog extends StatefulWidget {
  final List<Product> products;
  final List<String> selectedIds;
  final Function(List<String>) onConfirm;

  const _ProductSelectorDialog({
    required this.products,
    required this.selectedIds,
    required this.onConfirm,
  });

  @override
  State<_ProductSelectorDialog> createState() => _ProductSelectorDialogState();
}

class _ProductSelectorDialogState extends State<_ProductSelectorDialog> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sélectionner des produits'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.products.length,
          itemBuilder: (context, index) {
            final product = widget.products[index];
            final isSelected = _selectedIds.contains(product.id);

            return CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedIds.add(product.id);
                  } else {
                    _selectedIds.remove(product.id);
                  }
                });
              },
              title: Text(product.name),
              subtitle: Text('${product.price.toStringAsFixed(2)} €'),
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: product.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey.shade200,
                ),
                child: product.imageUrl.isEmpty
                    ? const Icon(Icons.image_not_supported, size: 20)
                    : null,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            widget.onConfirm(_selectedIds);
            Navigator.pop(context);
          },
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}
