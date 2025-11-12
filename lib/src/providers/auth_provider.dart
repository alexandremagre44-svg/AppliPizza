// lib/src/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../core/constants.dart';

/// Provider pour l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
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
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState()) {
    _initialize();
  }

  /// Initialiser l'état d'authentification
  Future<void> _initialize() async {
    await _authService.initialize();
    state = AuthState(
      isLoggedIn: _authService.isLoggedIn,
      userEmail: _authService.userEmail,
      userRole: _authService.userRole,
    );
  }

  /// Connexion
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final success = await _authService.login(email, password);
      
      if (success) {
        state = AuthState(
          isLoggedIn: true,
          userEmail: _authService.userEmail,
          userRole: _authService.userRole,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Email ou mot de passe incorrect',
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
    await _authService.logout();
    state = AuthState();
  }

  /// Vérifier le statut d'authentification
  Future<bool> checkAuthStatus() async {
    final isLoggedIn = await _authService.checkAuthStatus();
    if (isLoggedIn) {
      state = AuthState(
        isLoggedIn: true,
        userEmail: _authService.userEmail,
        userRole: _authService.userRole,
      );
    }
    return isLoggedIn;
  }
}
