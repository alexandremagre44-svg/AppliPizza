// lib/builder/editor/widgets/icon_picker_dialog.dart
// Icon picker dialog for selecting Material Icons for custom pages
//
// Features:
// - Grid display of 40+ Material Icons
// - Grouped by category (navigation, actions, food, layout)
// - Returns icon name as String (e.g., 'home', 'star', 'favorite')
// - No external dependencies

import 'package:flutter/material.dart';

/// A curated list of Material Icons organized by category
/// Icons are stored as (iconName, IconData, displayLabel)
class _IconCategory {
  final String name;
  final List<_IconItem> icons;
  
  const _IconCategory(this.name, this.icons);
}

class _IconItem {
  final String name;
  final IconData icon;
  final String label;
  
  const _IconItem(this.name, this.icon, this.label);
}

/// Curated icon categories for the picker
final List<_IconCategory> _iconCategories = [
  _IconCategory('Navigation', [
    _IconItem('home', Icons.home, 'Accueil'),
    _IconItem('menu', Icons.menu, 'Menu'),
    _IconItem('dashboard', Icons.dashboard, 'Tableau'),
    _IconItem('explore', Icons.explore, 'Explorer'),
    _IconItem('search', Icons.search, 'Recherche'),
    _IconItem('list', Icons.list, 'Liste'),
    _IconItem('grid_view', Icons.grid_view, 'Grille'),
    _IconItem('layers', Icons.layers, 'Calques'),
  ]),
  _IconCategory('Actions', [
    _IconItem('star', Icons.star, 'Étoile'),
    _IconItem('favorite', Icons.favorite, 'Favori'),
    _IconItem('bookmark', Icons.bookmark, 'Marque-page'),
    _IconItem('thumb_up', Icons.thumb_up, 'Pouce'),
    _IconItem('notifications', Icons.notifications, 'Notifs'),
    _IconItem('share', Icons.share, 'Partager'),
    _IconItem('send', Icons.send, 'Envoyer'),
    _IconItem('add_circle', Icons.add_circle, 'Ajouter'),
  ]),
  _IconCategory('Alimentation', [
    _IconItem('restaurant_menu', Icons.restaurant_menu, 'Menu resto'),
    _IconItem('local_pizza', Icons.local_pizza, 'Pizza'),
    _IconItem('fastfood', Icons.fastfood, 'Fast-food'),
    _IconItem('restaurant', Icons.restaurant, 'Restaurant'),
    _IconItem('local_dining', Icons.local_dining, 'Dîner'),
    _IconItem('local_cafe', Icons.local_cafe, 'Café'),
    _IconItem('local_bar', Icons.local_bar, 'Bar'),
    _IconItem('cake', Icons.cake, 'Gâteau'),
  ]),
  _IconCategory('Commerce', [
    _IconItem('shopping_cart', Icons.shopping_cart, 'Panier'),
    _IconItem('shopping_bag', Icons.shopping_bag, 'Sac'),
    _IconItem('store', Icons.store, 'Boutique'),
    _IconItem('local_offer', Icons.local_offer, 'Offre'),
    _IconItem('discount', Icons.discount, 'Remise'),
    _IconItem('card_giftcard', Icons.card_giftcard, 'Cadeau'),
    _IconItem('loyalty', Icons.loyalty, 'Fidélité'),
    _IconItem('payments', Icons.payments, 'Paiement'),
  ]),
  _IconCategory('Contenu', [
    _IconItem('article', Icons.article, 'Article'),
    _IconItem('photo', Icons.photo, 'Photo'),
    _IconItem('videocam', Icons.videocam, 'Vidéo'),
    _IconItem('event', Icons.event, 'Événement'),
    _IconItem('campaign', Icons.campaign, 'Campagne'),
    _IconItem('announcement', Icons.announcement, 'Annonce'),
    _IconItem('info', Icons.info, 'Info'),
    _IconItem('help', Icons.help, 'Aide'),
  ]),
  _IconCategory('Contact', [
    _IconItem('person', Icons.person, 'Profil'),
    _IconItem('group', Icons.group, 'Groupe'),
    _IconItem('contact_page', Icons.contact_page, 'Contact'),
    _IconItem('phone', Icons.phone, 'Téléphone'),
    _IconItem('email', Icons.email, 'Email'),
    _IconItem('location_on', Icons.location_on, 'Lieu'),
    _IconItem('schedule', Icons.schedule, 'Horaires'),
    _IconItem('chat', Icons.chat, 'Chat'),
  ]),
  _IconCategory('Divers', [
    _IconItem('casino', Icons.casino, 'Casino'),
    _IconItem('emoji_events', Icons.emoji_events, 'Trophée'),
    _IconItem('celebration', Icons.celebration, 'Fête'),
    _IconItem('flash_on', Icons.flash_on, 'Éclair'),
    _IconItem('new_releases', Icons.new_releases, 'Nouveau'),
    _IconItem('trending_up', Icons.trending_up, 'Tendance'),
    _IconItem('verified', Icons.verified, 'Vérifié'),
    _IconItem('workspace_premium', Icons.workspace_premium, 'Premium'),
  ]),
];

/// Dialog for selecting an icon for custom pages
/// 
/// Returns the icon name as a String (e.g., 'home', 'star')
/// Returns null if dialog is cancelled
class IconPickerDialog extends StatefulWidget {
  /// Currently selected icon name (optional)
  final String? currentIcon;
  
  const IconPickerDialog({
    super.key,
    this.currentIcon,
  });
  
  /// Show the dialog and return selected icon name
  static Future<String?> show(BuildContext context, {String? currentIcon}) {
    return showDialog<String>(
      context: context,
      builder: (context) => IconPickerDialog(currentIcon: currentIcon),
    );
  }

  @override
  State<IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<IconPickerDialog> {
  String? _selectedIcon;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.currentIcon;
  }
  
  /// Get all icons matching the search query
  List<_IconItem> get _filteredIcons {
    if (_searchQuery.isEmpty) {
      // Return all icons from all categories
      return _iconCategories.expand((cat) => cat.icons).toList();
    }
    
    final query = _searchQuery.toLowerCase();
    return _iconCategories
        .expand((cat) => cat.icons)
        .where((icon) => 
            icon.name.contains(query) || 
            icon.label.toLowerCase().contains(query))
        .toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.palette, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Choisir une icône',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Search field
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une icône...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            
            // Icon grid
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildCategorizedGrid()
                  : _buildFilteredGrid(),
            ),
            
            // Footer with actions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  // Preview of selected icon
                  if (_selectedIcon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getIconData(_selectedIcon!),
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedIcon!,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _selectedIcon != null
                        ? () => Navigator.pop(context, _selectedIcon)
                        : null,
                    child: const Text('Valider'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build grid organized by categories
  Widget _buildCategorizedGrid() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _iconCategories.length,
      itemBuilder: (context, index) {
        final category = _iconCategories[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: category.icons.length,
              itemBuilder: (context, iconIndex) {
                final iconItem = category.icons[iconIndex];
                return _buildIconTile(iconItem);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
  
  /// Build flat grid for filtered results
  Widget _buildFilteredGrid() {
    final icons = _filteredIcons;
    
    if (icons.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Aucune icône trouvée',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        return _buildIconTile(icons[index]);
      },
    );
  }
  
  /// Build a single icon tile
  Widget _buildIconTile(_IconItem iconItem) {
    final isSelected = _selectedIcon == iconItem.name;
    
    return InkWell(
      onTap: () => setState(() => _selectedIcon = iconItem.name),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue.shade400 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconItem.icon,
              size: 28,
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
            ),
            const SizedBox(height: 4),
            Text(
              iconItem.label,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Get IconData from icon name
  IconData _getIconData(String iconName) {
    for (final category in _iconCategories) {
      for (final iconItem in category.icons) {
        if (iconItem.name == iconName) {
          return iconItem.icon;
        }
      }
    }
    return Icons.layers;
  }
}
