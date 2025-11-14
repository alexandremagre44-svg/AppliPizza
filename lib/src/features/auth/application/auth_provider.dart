// lib/src/providers/auth_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pizza_delizza/src/features/auth/data/repositories/firebase_auth_repository.dart';
import '../../shared/constants/constants.dart';

/// Provider pour le service d'authentification Firebase
final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Provider pour l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(firebaseAuthRepositoryProvider));
});

/// Listenable for GoRouter's refreshListenable parameter
/// This notifies GoRouter when authentication state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// État d'authentification
class AuthState {
  final bool isLoggedIn;
  final String? userId;
  final String? userEmail;
  final String? userRole;
  final String? displayName;
  final Map<String, dynamic>? userProfile; // Full user profile from Firestore
  final bool isLoading;
  final String? error;

  AuthState({
    this.isLoggedIn = false,
    this.userId,
    this.userEmail,
    this.userRole,
    this.displayName,
    this.userProfile,
    this.isLoading = false,
    this.error,
  });

  bool get isAdmin => userRole == UserRole.admin;
  bool get isKitchen => userRole == UserRole.kitchen;

  AuthState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? userEmail,
    String? userRole,
    String? displayName,
    Map<String, dynamic>? userProfile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userRole: userRole ?? this.userRole,
      displayName: displayName ?? this.displayName,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier pour gérer l'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthRepository _authRepository;

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
        // Récupérer le profil complet de l'utilisateur depuis Firestore
        final profile = await _authService.getUserProfile(user.uid);
        final role = profile?['role'] ?? UserRole.client;
        final displayName = profile?['displayName'] ?? user.displayName;
        
        state = AuthState(
          isLoggedIn: true,
          userId: user.uid,
          userEmail: user.email,
          userRole: role,
          displayName: displayName,
          userProfile: profile,
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
      final profile = await _authService.getUserProfile(user.uid);
      final role = profile?['role'] ?? UserRole.client;
      final displayName = profile?['displayName'] ?? user.displayName;
      
      state = AuthState(
        isLoggedIn: true,
        userId: user.uid,
        userEmail: user.email,
        userRole: role,
        displayName: displayName,
        userProfile: profile,
      );
      return true;
    }
    return false;
  }
}
