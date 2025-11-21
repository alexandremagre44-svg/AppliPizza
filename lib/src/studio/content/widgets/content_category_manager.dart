// lib/src/studio/content/widgets/content_category_manager.dart
// Widget for managing category display and order on home screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../../../models/product.dart';
import '../models/category_override_model.dart';
import '../services/category_override_service.dart';
import '../providers/content_providers.dart';

class ContentCategoryManager extends ConsumerStatefulWidget {
  const ContentCategoryManager({super.key});

  @override
  ConsumerState<ContentCategoryManager> createState() => _ContentCategoryManagerState();
}

class _ContentCategoryManagerState extends ConsumerState<ContentCategoryManager> {
  final _categoryService = CategoryOverrideService();
  List<CategoryOverride> _categories = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      await _categoryService.initIfMissing();
      final categories = await _categoryService.getAllOverrides();
      
      if (mounted) {
        setState(() {
          _categories = categories;
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

  Future<void> _saveCategories() async {
    setState(() => _isSaving = true);
    try {
      await _categoryService.saveOverrides(_categories);
      ref.invalidate(categoryOverridesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catégories sauvegardées avec succès'),
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

  String _getCategoryLabel(String categoryId) {
    try {
      return ProductCategory.fromString(categoryId).value;
    } catch (e) {
      return categoryId;
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'pizza':
        return Icons.local_pizza_outlined;
      case 'menus':
        return Icons.restaurant_menu_outlined;
      case 'boissons':
        return Icons.local_drink_outlined;
      case 'desserts':
        return Icons.cake_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildInstructions(),
        Expanded(
          child: _buildCategoriesList(),
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
              'Glissez-déposez les catégories pour modifier leur ordre d\'affichage. '
              'Désactivez une catégorie pour la masquer sur la page d\'accueil.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Aucune catégorie disponible'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadCategories,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _categories.removeAt(oldIndex);
          _categories.insert(newIndex, item);
          
          // Update order for all categories
          for (var i = 0; i < _categories.length; i++) {
            _categories[i] = _categories[i].copyWith(
              order: i,
              updatedAt: DateTime.now(),
            );
          }
        });
      },
      itemBuilder: (context, index) {
        final category = _categories[index];
        
        return Card(
          key: ValueKey(category.categoryId),
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: category.isVisibleOnHome
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getCategoryIcon(category.categoryId),
                color: category.isVisibleOnHome
                    ? AppColors.primary
                    : Colors.grey,
                size: 28,
              ),
            ),
            title: Text(
              _getCategoryLabel(category.categoryId),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: category.isVisibleOnHome ? Colors.black : Colors.grey,
              ),
            ),
            subtitle: Text(
              'Ordre: ${index + 1}',
              style: TextStyle(
                color: category.isVisibleOnHome ? Colors.grey : Colors.grey.shade400,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: category.isVisibleOnHome
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.isVisibleOnHome ? 'Visible' : 'Masqué',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: category.isVisibleOnHome
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: category.isVisibleOnHome,
                  onChanged: (value) {
                    setState(() {
                      _categories[index] = category.copyWith(
                        isVisibleOnHome: value,
                        updatedAt: DateTime.now(),
                      );
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.drag_handle, color: Colors.grey),
              ],
            ),
          ),
        );
      },
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
          onPressed: _isSaving ? null : _saveCategories,
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
          label: Text(_isSaving ? 'Sauvegarde...' : 'Sauvegarder les catégories'),
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
}
