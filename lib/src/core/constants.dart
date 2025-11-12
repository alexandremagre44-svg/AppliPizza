// lib/src/core/constants.dart

/// Routes de l'application
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String menu = '/menu';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String productDetail = '/details';
  static const String adminMenu = '/admin/menu';
  static const String adminPizza = '/admin/pizza';
  static const String adminDrinks = '/admin/drinks';
  static const String adminDesserts = '/admin/desserts';
  static const String adminPageBuilder = '/admin/page-builder';
  static const String adminMailing = '/admin/mailing';
  static const String adminOrders = '/admin/orders';
  static const String kitchen = '/kitchen';
}

/// Rôles utilisateurs
class UserRole {
  static const String admin = 'admin';
  static const String client = 'client';
  static const String kitchen = 'kitchen';
}

/// Clés SharedPreferences
class StorageKeys {
  static const String isLoggedIn = 'is_logged_in';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String pizzasList = 'pizzas_list';
  static const String menusList = 'menus_list';
  static const String drinksList = 'drinks_list';
  static const String dessertsList = 'desserts_list';
}

/// Constantes visuelles
class VisualConstants {
  // Grid
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 0.75;
  static const double gridSpacing = 16.0;
  
  // Text
  static const int maxLinesTitle = 2;
  static const int maxLinesDescription = 2;
  
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
}

/// Credentials de test
class TestCredentials {
  static const String adminEmail = 'admin@delizza.com';
  static const String adminPassword = 'admin123';
  static const String clientEmail = 'client@delizza.com';
  static const String clientPassword = 'client123';
}
