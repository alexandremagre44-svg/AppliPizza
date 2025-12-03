// lib/src/screens/admin/ingredients_admin_screen.dart
// Écran d'administration pour gérer les ingrédients universels


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart'; // Keep for AppSpacing, AppRadius, AppTextStyles
import '../../models/product.dart';
import '../../providers/ingredient_provider.dart';
import '../../services/firestore_ingredient_service.dart';
import 'ingredient_form_screen.dart';

/// Écran principal de gestion des ingrédients universels
class IngredientsAdminScreen extends ConsumerStatefulWidget {
  const IngredientsAdminScreen({super.key});

  @override
  ConsumerState<IngredientsAdminScreen> createState() => _IngredientsAdminScreenState();
}

class _IngredientsAdminScreenState extends ConsumerState<IngredientsAdminScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Use getter to access service when needed (avoids initState ref.read issue)
  FirestoreIngredientService get _firestoreService => ref.read(firestoreIngredientServiceProvider);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: IngredientCategory.values.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation du stream provider pour les mises à jour en temps réel
    final ingredientsAsync = ref.watch(ingredientStreamProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Gestion des Ingrédients'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(icon: Icon(Icons.list), text: 'Tous'),
            ...IngredientCategory.values.map((category) => Tab(
              icon: Icon(_getCategoryIcon(category)),
              text: category.displayName,
            )),
          ],
        ),
      ),
      body: ingredientsAsync.when(
        data: (ingredients) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildIngredientList(ingredients, null),
              ...IngredientCategory.values.map((category) {
                final filtered = ingredients.where((i) => i.category == category).toList();
                return _buildIngredientList(filtered, category);
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              SizedBox(height: AppSpacing.md),
              Text('Erreur: $error', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToIngredientForm(null),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel ingrédient'),
        backgroundColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildIngredientList(List<Ingredient> ingredients, IngredientCategory? category) {
    if (ingredients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Aucun ingrédient',
              style: AppTextStyles.titleMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              category != null 
                ? 'Ajoutez votre premier ingrédient de type ${category.displayName.toLowerCase()}'
                : 'Ajoutez votre premier ingrédient',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return _buildIngredientCard(ingredient);
      },
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
      ),
      child: InkWell(
        onTap: () => _navigateToIngredientForm(ingredient),
        borderRadius: AppRadius.card,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Icône de l'ingrédient
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: ingredient.isActive 
                      ? colorScheme.primaryContainer 
                      : colorScheme.surfaceContainerLow,
                  borderRadius: AppRadius.radiusSmall,
                ),
                child: Icon(
                  _getIngredientIcon(ingredient),
                  color: ingredient.isActive 
                      ? colorScheme.primary 
                      : colorScheme.onSurfaceVariant,
                  size: 32,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Informations de l'ingrédient
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ingredient.name,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!ingredient.isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: AppRadius.radiusSmall,
                            ),
                            child: Text(
                              'Inactif',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: AppRadius.radiusSmall,
                          ),
                          child: Text(
                            ingredient.category.displayName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Ordre: ${ingredient.order}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      ingredient.extraCost > 0 
                          ? '+${ingredient.extraCost.toStringAsFixed(2)} €'
                          : 'Gratuit',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleIngredientAction(value, ingredient),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(ingredient.isActive ? Icons.visibility_off : Icons.visibility),
                        const SizedBox(width: 8),
                        Text(ingredient.isActive ? 'Désactiver' : 'Activer'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleIngredientAction(String action, Ingredient ingredient) async {
    switch (action) {
      case 'edit':
        _navigateToIngredientForm(ingredient);
        break;
      case 'toggle':
        await _toggleIngredientStatus(ingredient);
        break;
      case 'delete':
        _confirmDelete(ingredient);
        break;
    }
  }

  Future<void> _toggleIngredientStatus(Ingredient ingredient) async {
    final updatedIngredient = ingredient.copyWith(isActive: !ingredient.isActive);
    final success = await _firestoreService.saveIngredient(updatedIngredient);

    if (success && mounted) {
      // Pas besoin de ref.invalidate avec StreamProvider - mise à jour automatique en temps réel
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedIngredient.isActive ? 'Ingrédient activé' : 'Ingrédient désactivé',
          ),
        ),
      );
    }
  }

  void _confirmDelete(Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer "${ingredient.name}" ?\n\n'
          'Attention : cet ingrédient sera retiré de toutes les pizzas qui l\'utilisent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteIngredient(ingredient);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteIngredient(Ingredient ingredient) async {
    final success = await _firestoreService.deleteIngredient(ingredient.id);

    if (success && mounted) {
      // Pas besoin de ref.invalidate avec StreamProvider - mise à jour automatique en temps réel
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrédient supprimé')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  void _navigateToIngredientForm(Ingredient? ingredient) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => IngredientFormScreen(ingredient: ingredient),
      ),
    );
    // Pas besoin de ref.invalidate avec StreamProvider - mise à jour automatique en temps réel
  }

  IconData _getCategoryIcon(IngredientCategory category) {
    switch (category) {
      case IngredientCategory.fromage:
        return Icons.restaurant;
      case IngredientCategory.viande:
        return Icons.food_bank;
      case IngredientCategory.legume:
        return Icons.eco;
      case IngredientCategory.sauce:
        return Icons.water_drop;
      case IngredientCategory.herbe:
        return Icons.spa;
      case IngredientCategory.autre:
        return Icons.more_horiz;
    }
  }

  IconData _getIngredientIcon(Ingredient ingredient) {
    if (ingredient.iconName != null) {
      // Mapper le nom de l'icône en IconData (simplifié ici)
      switch (ingredient.iconName) {
        case 'local_pizza':
          return Icons.local_pizza;
        case 'restaurant':
          return Icons.restaurant;
        default:
          return _getCategoryIcon(ingredient.category);
      }
    }
    return _getCategoryIcon(ingredient.category);
  }
}
