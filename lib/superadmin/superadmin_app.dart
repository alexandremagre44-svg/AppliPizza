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

import 'superadmin_router.dart';

/// Widget principal du module Super-Admin.
/// 
/// Ce widget encapsule toute la logique du Super-Admin :
/// - Router interne dédié
/// - Layout avec sidebar et header
/// - Toutes les pages du module
/// 
/// TEMPORAIRE : Pas de vérification d'authentification.
/// TODO: Ajouter la vérification d'auth Super-Admin.
class SuperAdminApp extends ConsumerWidget {
  const SuperAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Add Super-Admin authentication verification
    // For Phase 0, we skip authentication and display the app directly
    
    return MaterialApp.router(
      title: 'Super Admin - Pizza Delizza',
      debugShowCheckedModeBanner: false,
      theme: _buildSuperAdminTheme(),
      routerConfig: createSuperAdminRouter(),
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
