// lib/src/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../core/constants.dart';

/// Provider pour le service d'authentification Firebase
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Provider pour l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(firebaseAuthServiceProvider));
});

/// État d'authentification
class AuthState {
  final bool isLoggedIn;
  final String? userEmail;
  final String? userRole;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isLoggedIn = false,
    this.userEmail,
    this.userRole,
    this.isLoading = false,
    this.error,
  });

  bool get isAdmin => userRole == UserRole.admin;
  bool get isKitchen => userRole == UserRole.kitchen;

  AuthState copyWith({
    bool? isLoggedIn,
    String? userEmail,
    String? userRole,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userEmail: userEmail ?? this.userEmail,
      userRole: userRole ?? this.userRole,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier pour gérer l'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _initialize();
  }

  /// Initialiser l'état d'authentification
  Future<void> _initialize() async {
    // Écouter les changements d'état Firebase Auth
    _authService.authStateChanges.listen((user) async {
      if (user == null) {
        state = AuthState();
      } else {
        // Récupérer le rôle de l'utilisateur
        final role = await _authService.getUserRole(user.uid);
        state = AuthState(
          isLoggedIn: true,
          userEmail: user.email,
          userRole: role,
          isLoading: false,
        );
      }
    });
  }

  /// Connexion
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.signIn(email, password);
      
      if (result['success']) {
        // L'état sera mis à jour automatiquement par le stream authStateChanges
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] as String,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de connexion: $e',
      );
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _authService.signOut();
    // L'état sera mis à jour automatiquement par le stream authStateChanges
  }

  /// Vérifier le statut d'authentification
  Future<bool> checkAuthStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final role = await _authService.getUserRole(user.uid);
      state = AuthState(
        isLoggedIn: true,
        userEmail: user.email,
        userRole: role,
      );
      return true;
    }
    return false;
  }
}
