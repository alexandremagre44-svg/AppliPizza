/// lib/superadmin/pages/restaurants_list/restaurants_list_page.dart
///
/// Page principale de la liste des restaurants créés via le Wizard.
/// Affiche les restaurants avec recherche, filtres et actions.
/// Utilise Scaffold simple (pas superadmin_layout).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/restaurant_blueprint.dart';
import 'restaurants_list_state.dart';
import 'restaurant_card_widget.dart';

/// Page liste des restaurants du Super-Admin (version Wizard).
class RestaurantsListWizardPage extends ConsumerStatefulWidget {
  const RestaurantsListWizardPage({super.key});

  @override
  ConsumerState<RestaurantsListWizardPage> createState() =>
      _RestaurantsListWizardPageState();
}

class _RestaurantsListWizardPageState
    extends ConsumerState<RestaurantsListWizardPage> {
  /// Contrôleur pour le champ de recherche.
  final _searchController = TextEditingController();

  /// Mode d'affichage (grille ou liste).
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantListProvider);
    final notifier = ref.read(restaurantListProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => context.go('/superadmin/restaurants'),
        ),
        title: const Text(
          'Restaurants (Wizard)',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Toggle vue
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: const Color(0xFF1A1A2E),
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'Vue liste' : 'Vue grille',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Champ de recherche
                TextField(
                  controller: _searchController,
                  onChanged: notifier.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un restaurant...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              notifier.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F5F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filtres par type
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Tous',
                        isSelected: state.filterType == null,
                        onTap: () => notifier.setFilterType(null),
                      ),
                      const SizedBox(width: 8),
                      ...RestaurantType.values.map((type) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: type.displayName,
                              isSelected: state.filterType == type,
                              onTap: () => notifier.setFilterType(type),
                              icon: _getTypeIcon(type),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Compteur et actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  '${state.filteredCount} restaurant${state.filteredCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (state.hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      notifier.clearFilters();
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Effacer filtres'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    context.go('/superadmin/restaurants/create');
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nouveau'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des restaurants
          Expanded(
            child: state.filteredRestaurants.isEmpty
                ? _buildEmptyState(state)
                : _isGridView
                    ? _buildGridView(state, notifier)
                    : _buildListView(state, notifier),
          ),
        ],
      ),
    );
  }

  /// Construit l'état vide.
  Widget _buildEmptyState(RestaurantListState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.hasActiveFilters
                ? Icons.search_off
                : Icons.restaurant_menu,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            state.hasActiveFilters
                ? 'Aucun restaurant trouvé'
                : 'Aucun restaurant créé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.hasActiveFilters
                ? 'Essayez de modifier vos critères de recherche'
                : 'Créez votre premier restaurant avec le Wizard',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          if (!state.hasActiveFilters) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/superadmin/restaurants/create');
              },
              icon: const Icon(Icons.add),
              label: const Text('Créer un restaurant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construit la vue en grille.
  Widget _buildGridView(
    RestaurantListState state,
    RestaurantListNotifier notifier,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: state.filteredRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = state.filteredRestaurants[index];
        return RestaurantCardWidget(
          restaurant: restaurant,
          onTap: (r) => _showRestaurantPreview(r),
          onView: (r) => _showRestaurantPreview(r),
          onEdit: (r) => _showEditDialog(r),
          onDuplicate: (r) => _handleDuplicate(r, notifier),
          onDelete: (r) => _showDeleteConfirmation(r, notifier),
        );
      },
    );
  }

  /// Construit la vue en liste.
  Widget _buildListView(
    RestaurantListState state,
    RestaurantListNotifier notifier,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.filteredRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = state.filteredRestaurants[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: RestaurantListTileWidget(
            restaurant: restaurant,
            onTap: (r) => _showRestaurantPreview(r),
            onDelete: (r) => _showDeleteConfirmation(r, notifier),
          ),
        );
      },
    );
  }

  /// Affiche l'aperçu d'un restaurant.
  void _showRestaurantPreview(RestaurantBlueprintLight restaurant) {
    showDialog(
      context: context,
      builder: (context) => _RestaurantPreviewDialog(restaurant: restaurant),
    );
  }

  /// Affiche la boîte de dialogue de modification.
  void _showEditDialog(RestaurantBlueprintLight restaurant) {
    // TODO: Implémenter l'édition via le Wizard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Édition de "${restaurant.name}" - À implémenter'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Duplique un restaurant.
  void _handleDuplicate(
    RestaurantBlueprintLight restaurant,
    RestaurantListNotifier notifier,
  ) {
    notifier.duplicateRestaurant(restaurant.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restaurant "${restaurant.name}" dupliqué'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  /// Affiche la confirmation de suppression.
  void _showDeleteConfirmation(
    RestaurantBlueprintLight restaurant,
    RestaurantListNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le restaurant ?'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${restaurant.name}" ?\n'
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.removeRestaurant(restaurant.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Restaurant "${restaurant.name}" supprimé'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red.shade600,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  /// Retourne l'icône correspondant au type.
  IconData _getTypeIcon(RestaurantType type) {
    switch (type) {
      case RestaurantType.restaurant:
        return Icons.restaurant;
      case RestaurantType.snack:
        return Icons.fastfood;
      case RestaurantType.snackDelivery:
        return Icons.delivery_dining;
      case RestaurantType.custom:
        return Icons.settings;
    }
  }
}

/// Chip de filtre.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialogue d'aperçu d'un restaurant.
class _RestaurantPreviewDialog extends StatelessWidget {
  final RestaurantBlueprintLight restaurant;

  const _RestaurantPreviewDialog({required this.restaurant});

  Color _hexToColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _hexToColor(restaurant.brand.primaryColor);
    final secondaryColor = _hexToColor(restaurant.brand.secondaryColor);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header avec couleurs
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // Logo/Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.brand.brandName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identité
                  _SectionTitle(title: 'Identité'),
                  _InfoRow(label: 'Slug', value: restaurant.slug),
                  _InfoRow(label: 'Type', value: restaurant.type.displayName),
                  if (restaurant.templateId != null)
                    _InfoRow(label: 'Template', value: restaurant.templateId!),
                  const SizedBox(height: 16),

                  // Couleurs
                  _SectionTitle(title: 'Couleurs'),
                  Row(
                    children: [
                      _ColorSwatch(
                        label: 'Primaire',
                        color: restaurant.brand.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      _ColorSwatch(
                        label: 'Secondaire',
                        color: restaurant.brand.secondaryColor,
                      ),
                      const SizedBox(width: 16),
                      _ColorSwatch(
                        label: 'Accent',
                        color: restaurant.brand.accentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Modules
                  _SectionTitle(title: 'Modules activés'),
                  if (restaurant.enabledModules.isEmpty)
                    Text(
                      'Aucun module activé',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade500,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: restaurant.enabledModules.map((module) {
                        return Chip(
                          label: Text(module),
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),

                  // Métadonnées
                  _SectionTitle(title: 'Métadonnées'),
                  _InfoRow(
                    label: 'Créé le',
                    value: _formatFullDate(restaurant.createdAt),
                  ),
                  if (restaurant.updatedAt != null)
                    _InfoRow(
                      label: 'Modifié le',
                      value: _formatFullDate(restaurant.updatedAt!),
                    ),
                ],
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fermer'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Naviguer vers l'édition
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Modifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Titre de section.
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
      ),
    );
  }
}

/// Ligne d'information.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Échantillon de couleur.
class _ColorSwatch extends StatelessWidget {
  final String label;
  final String color;

  const _ColorSwatch({required this.label, required this.color});

  Color _hexToColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hexToColor(color),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
