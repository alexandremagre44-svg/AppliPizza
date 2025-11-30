// lib/src/providers/auth_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../core/constants.dart';
import '../models/auth_roles.dart';
import 'restaurant_provider.dart';

/// Provider pour le service d'authentification Firebase
/// Watches currentRestaurantProvider to inject the appId for multi-tenant isolation
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  final config = ref.watch(currentRestaurantProvider);
  return FirebaseAuthService(appId: config.id);
});

/// Provider pour l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(firebaseAuthServiceProvider));
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
  final Map<String, dynamic>? customClaims; // Custom claims from Firebase Auth token
  final AuthRoles roles; // Parsed roles from custom claims
  final bool isLoading;
  final String? error;

  AuthState({
    this.isLoggedIn = false,
    this.userId,
    this.userEmail,
    this.userRole,
    this.displayName,
    this.userProfile,
    this.customClaims,
    AuthRoles? roles,
    this.isLoading = false,
    this.error,
  }) : roles = roles ?? AuthRoles.fromClaims(customClaims);

  bool get isAdmin => userRole == UserRole.admin || (customClaims?['admin'] == true);
  bool get isKitchen => userRole == UserRole.kitchen;
  
  /// True if user is a Super-Admin (from custom claims)
  bool get isSuperAdmin => roles.isSuperAdmin;

  AuthState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? userEmail,
    String? userRole,
    String? displayName,
    Map<String, dynamic>? userProfile,
    Map<String, dynamic>? customClaims,
    AuthRoles? roles,
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
      customClaims: customClaims ?? this.customClaims,
      roles: roles ?? this.roles,
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
        // Récupérer le profil complet de l'utilisateur depuis Firestore
        final profile = await _authService.getUserProfile(user.uid);
        final role = profile?['role'] ?? UserRole.client;
        final displayName = profile?['displayName'] ?? user.displayName;
        
        // Récupérer les custom claims depuis le token Firebase Auth
        final customClaims = await _authService.getCustomClaims(user);
        
        state = AuthState(
          isLoggedIn: true,
          userId: user.uid,
          userEmail: user.email,
          userRole: role,
          displayName: displayName,
          userProfile: profile,
          customClaims: customClaims,
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
      
      // Récupérer les custom claims depuis le token Firebase Auth
      final customClaims = await _authService.getCustomClaims(user);
      
      state = AuthState(
        isLoggedIn: true,
        userId: user.uid,
        userEmail: user.email,
        userRole: role,
        displayName: displayName,
        userProfile: profile,
        customClaims: customClaims,
      );
      return true;
    }
    return false;
  }
}
