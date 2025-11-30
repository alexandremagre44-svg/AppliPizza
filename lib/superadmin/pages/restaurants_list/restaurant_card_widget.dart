/// lib/superadmin/pages/restaurants_list/restaurant_card_widget.dart
///
/// Widget carte pour afficher un restaurant dans la liste.
/// Design responsive avec informations principales et actions.
library;

import 'package:flutter/material.dart';

import '../../models/restaurant_blueprint.dart';

/// Callback pour les actions sur un restaurant.
typedef RestaurantAction = void Function(RestaurantBlueprintLight restaurant);

/// Widget carte pour afficher un restaurant.
class RestaurantCardWidget extends StatelessWidget {
  /// Restaurant à afficher.
  final RestaurantBlueprintLight restaurant;

  /// Callback appelé quand on tape sur la carte.
  final RestaurantAction? onTap;

  /// Callback appelé pour voir les détails.
  final RestaurantAction? onView;

  /// Callback appelé pour modifier le restaurant.
  final RestaurantAction? onEdit;

  /// Callback appelé pour dupliquer le restaurant.
  final RestaurantAction? onDuplicate;

  /// Callback appelé pour supprimer le restaurant.
  final RestaurantAction? onDelete;

  const RestaurantCardWidget({
    super.key,
    required this.restaurant,
    this.onTap,
    this.onView,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  /// Convertit une couleur hex en Color.
  Color _hexToColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  /// Retourne l'icône correspondant au type de restaurant.
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

  /// Formate la date en format lisible.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _hexToColor(restaurant.brand.primaryColor);
    final enabledModules = restaurant.enabledModules;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap != null ? () => onTap!(restaurant) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header avec couleur primaire
            Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne titre + type
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar/Logo
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: restaurant.brand.logoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  restaurant.brand.logoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    _getTypeIcon(restaurant.type),
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                ),
                              )
                            : Icon(
                                _getTypeIcon(restaurant.type),
                                color: primaryColor,
                                size: 24,
                              ),
                      ),
                      const SizedBox(width: 12),

                      // Nom et slug
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              restaurant.slug,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menu actions
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey.shade600,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              onView?.call(restaurant);
                              break;
                            case 'edit':
                              onEdit?.call(restaurant);
                              break;
                            case 'duplicate':
                              onDuplicate?.call(restaurant);
                              break;
                            case 'delete':
                              onDelete?.call(restaurant);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 18),
                                SizedBox(width: 8),
                                Text('Voir détails'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Modifier'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 18),
                                SizedBox(width: 8),
                                Text('Dupliquer'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.red.shade600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Ligne type + brand
                  Row(
                    children: [
                      // Badge type
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(restaurant.type),
                              size: 14,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              restaurant.type.displayName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Brand name
                      if (restaurant.brand.brandName.isNotEmpty)
                        Expanded(
                          child: Text(
                            restaurant.brand.brandName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Modules activés
                  if (enabledModules.isNotEmpty) ...[
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: enabledModules.take(4).map((module) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getModuleLabel(module),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (enabledModules.length > 4)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${enabledModules.length - 4} autres modules',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                  ] else
                    Text(
                      'Aucun module activé',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade500,
                      ),
                    ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Footer avec dates
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Créé ${_formatDate(restaurant.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (restaurant.updatedAt != null) ...[
                        const Spacer(),
                        Icon(
                          Icons.update,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Modifié ${_formatDate(restaurant.updatedAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Template badge
                  if (restaurant.templateId != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.dashboard,
                          size: 12,
                          color: Colors.purple.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restaurant.templateId!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.purple.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retourne le label lisible d'un module.
  String _getModuleLabel(String module) {
    switch (module) {
      case 'ordering':
        return 'Commandes';
      case 'delivery':
        return 'Livraison';
      case 'clickAndCollect':
        return 'Click & Collect';
      case 'payments':
        return 'Paiements';
      case 'loyalty':
        return 'Fidélité';
      case 'roulette':
        return 'Roulette';
      case 'kitchenTablet':
        return 'Cuisine';
      case 'staffTablet':
        return 'Staff';
      default:
        return module;
    }
  }
}

/// Widget carte compacte pour la liste (vue liste).
class RestaurantListTileWidget extends StatelessWidget {
  /// Restaurant à afficher.
  final RestaurantBlueprintLight restaurant;

  /// Callback appelé quand on tape sur la carte.
  final RestaurantAction? onTap;

  /// Callback appelé pour supprimer le restaurant.
  final RestaurantAction? onDelete;

  const RestaurantListTileWidget({
    super.key,
    required this.restaurant,
    this.onTap,
    this.onDelete,
  });

  /// Convertit une couleur hex en Color.
  Color _hexToColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  /// Retourne l'icône correspondant au type de restaurant.
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = _hexToColor(restaurant.brand.primaryColor);

    return ListTile(
      onTap: onTap != null ? () => onTap!(restaurant) : null,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getTypeIcon(restaurant.type),
          color: primaryColor,
          size: 22,
        ),
      ),
      title: Text(
        restaurant.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${restaurant.type.displayName} • ${restaurant.enabledModulesCount} modules',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Couleur primaire indicator
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.chevron_right,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
