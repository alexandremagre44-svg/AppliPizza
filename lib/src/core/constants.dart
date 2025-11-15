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
  static const String checkout = '/checkout';
  static const String kitchen = '/kitchen';
  static const String roulette = '/roulette';
  
  // Studio Builder - Admin entry point
  static const String adminStudio = '/admin/studio';
  
  // Staff Tablet routes
  static const String staffTabletPin = '/staff-tablet';
  static const String staffTabletCatalog = '/staff-tablet/catalog';
  static const String staffTabletCheckout = '/staff-tablet/checkout';
  static const String staffTabletHistory = '/staff-tablet/history';
}

/// Rôles utilisateurs
class UserRole {
  static const String admin = 'admin';
  static const String client = 'client';
  static const String kitchen = 'kitchen';
}

/// Clés SharedPreferences (encore utilisé pour les produits)
class StorageKeys {
  // Auth keys deprecated - Firebase Auth is now used
  @deprecated
  static const String isLoggedIn = 'is_logged_in';
  @deprecated
  static const String userEmail = 'user_email';
  @deprecated
  static const String userRole = 'user_role';
  
  // Product storage keys - still in use
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

/// DEPRECATED: Test credentials removed - use Firebase Auth for real users
/// Create users in Firebase Console with appropriate roles in Firestore
@deprecated
class TestCredentials {
  @deprecated
  static const String adminEmail = 'admin@delizza.com';
  @deprecated
  static const String adminPassword = 'admin123';
  @deprecated
  static const String clientEmail = 'client@delizza.com';
  @deprecated
  static const String clientPassword = 'client123';
}
