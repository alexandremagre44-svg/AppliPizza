// lib/src/features/content/data/initial_content_seeder.dart
// Helper to seed initial content strings for the CMS

import 'content_service.dart';

/// Seeds the database with initial content strings
/// This is useful for first-time setup and testing
class InitialContentSeeder {
  final ContentService _service;

  InitialContentSeeder(this._service);

  /// Seed the database with initial French content
  Future<void> seedInitialContent() async {
    final initialContent = {
      // Home screen
      'home_welcome_title': 'Bienvenue chez PizzaDeli\'Zza',
      'home_welcome_subtitle': 'Les meilleures pizzas artisanales livrées chez vous',
      'home_order_now': 'Commander maintenant',
      'home_view_menu': 'Voir le menu',
      'home_featured_title': 'Produits à la une',
      
      // Navigation
      'nav_home': 'Accueil',
      'nav_menu': 'Menu',
      'nav_cart': 'Panier',
      'nav_profile': 'Profil',
      'nav_admin': 'Admin',
      
      // Menu screen
      'menu_title': 'Notre Menu',
      'menu_pizzas': 'Pizzas',
      'menu_drinks': 'Boissons',
      'menu_desserts': 'Desserts',
      'menu_all': 'Tout',
      
      // Cart screen
      'cart_title': 'Mon Panier',
      'cart_empty': 'Votre panier est vide',
      'cart_total': 'Total',
      'cart_checkout': 'Commander',
      'cart_continue_shopping': 'Continuer mes achats',
      
      // Profile screen
      'profile_title': 'Mon Profil',
      'profile_orders': 'Mes commandes',
      'profile_favorites': 'Mes favoris',
      'profile_settings': 'Paramètres',
      'profile_logout': 'Se déconnecter',
      
      // Auth
      'auth_login': 'Se connecter',
      'auth_signup': 'S\'inscrire',
      'auth_email': 'Email',
      'auth_password': 'Mot de passe',
      'auth_forgot_password': 'Mot de passe oublié?',
      
      // Common
      'common_loading': 'Chargement...',
      'common_error': 'Une erreur est survenue',
      'common_retry': 'Réessayer',
      'common_cancel': 'Annuler',
      'common_save': 'Enregistrer',
      'common_delete': 'Supprimer',
      'common_edit': 'Modifier',
      'common_add': 'Ajouter',
      'common_search': 'Rechercher',
      
      // Product
      'product_price': 'Prix',
      'product_add_to_cart': 'Ajouter au panier',
      'product_customize': 'Personnaliser',
      'product_ingredients': 'Ingrédients',
      
      // Order
      'order_success': 'Commande validée avec succès!',
      'order_error': 'Erreur lors de la commande',
      'order_tracking': 'Suivi de commande',
      'order_status_pending': 'En attente',
      'order_status_preparing': 'En préparation',
      'order_status_ready': 'Prête',
      'order_status_delivered': 'Livrée',
      
      // Admin
      'admin_dashboard': 'Tableau de bord',
      'admin_products': 'Produits',
      'admin_orders': 'Commandes',
      'admin_studio': 'Studio',
      'admin_content': 'Contenu',
    };

    // Seed each content string
    for (final entry in initialContent.entries) {
      try {
        // Check if it already exists
        final exists = await _service.exists(entry.key);
        if (!exists) {
          await _service.createString(entry.key, 'fr', entry.value);
          print('✓ Seeded: ${entry.key}');
        } else {
          print('- Already exists: ${entry.key}');
        }
      } catch (e) {
        print('✗ Failed to seed ${entry.key}: $e');
      }
    }
    
    print('Initial content seeding completed!');
  }
}
