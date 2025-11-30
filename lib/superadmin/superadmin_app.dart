/// lib/superadmin/superadmin_app.dart
///
/// Point d'entrée principal du module Super-Admin.
/// Widget autonome avec son propre router interne.
/// 
/// Usage:
/// ```dart
/// // Option 1: Lancer comme application autonome
/// runApp(const ProviderScope(child: SuperAdminApp()));
/// 
/// // Option 2: Intégrer dans une route existante
/// GoRoute(
///   path: '/superadmin',
///   builder: (context, state) => const SuperAdminApp(),
/// ),
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/providers/auth_provider.dart';
import 'superadmin_router.dart';

/// Widget principal du module Super-Admin.
/// 
/// Ce widget encapsule toute la logique du Super-Admin :
/// - Router interne dédié
/// - Layout avec sidebar et header
/// - Toutes les pages du module
/// 
/// PROTECTION: Vérifie que l'utilisateur est un Super-Admin via les custom claims.
class SuperAdminApp extends ConsumerWidget {
  const SuperAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    // Protection: Vérifier que l'utilisateur est connecté et est Super-Admin
    if (!authState.isLoggedIn) {
      return _buildAccessDeniedScreen(
        icon: Icons.login,
        title: 'Non connecté',
        message: 'Vous devez être connecté pour accéder au Super-Admin.',
      );
    }
    
    if (!authState.isSuperAdmin) {
      return _buildAccessDeniedScreen(
        icon: Icons.lock,
        title: 'Accès refusé',
        message: 'Seuls les Super-Administrateurs peuvent accéder à cette zone.',
      );
    }
    
    return MaterialApp.router(
      title: 'Super Admin - Pizza Delizza',
      debugShowCheckedModeBanner: false,
      theme: _buildSuperAdminTheme(),
      routerConfig: createSuperAdminRouter(),
    );
  }

  /// Écran d'accès refusé
  Widget _buildAccessDeniedScreen({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return MaterialApp(
      title: 'Super Admin - Accès Refusé',
      debugShowCheckedModeBanner: false,
      theme: _buildSuperAdminTheme(),
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(48),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement navigation back to main app
                      // For now, just show a snackbar
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Retour à l\'application'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Thème spécifique au module Super-Admin.
  ThemeData _buildSuperAdminTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A1A2E),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A2E),
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 2),
        ),
      ),
    );
  }
}
