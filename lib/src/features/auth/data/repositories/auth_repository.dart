// lib/src/services/auth_service.dart
// DEPRECATED: Use FirebaseAuthService instead
// Service d'authentification local - remplacé par Firebase

import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

@deprecated
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // État de connexion
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userRole;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userRole => _userRole;
  bool get isAdmin => _userRole == UserRole.admin;

  /// Initialiser l'état depuis SharedPreferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(StorageKeys.isLoggedIn) ?? false;
    _userEmail = prefs.getString(StorageKeys.userEmail);
    _userRole = prefs.getString(StorageKeys.userRole);
  }

  /// Connexion locale (simulée)
  Future<bool> login(String email, String password) async {
    // Validation simple
    String? role;
    
    if (email == TestCredentials.adminEmail && password == TestCredentials.adminPassword) {
      role = UserRole.admin;
    } else if (email == TestCredentials.clientEmail && password == TestCredentials.clientPassword) {
      role = UserRole.client;
    } else if (email == 'kitchen@delizza.com' && password == 'kitchen123') {
      role = UserRole.kitchen;
    } else {
      return false; // Échec de connexion
    }

    // Sauvegarder dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isLoggedIn, true);
    await prefs.setString(StorageKeys.userEmail, email);
    await prefs.setString(StorageKeys.userRole, role);

    // Mettre à jour l'état local
    _isLoggedIn = true;
    _userEmail = email;
    _userRole = role;

    return true;
  }

  /// Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.isLoggedIn);
    await prefs.remove(StorageKeys.userEmail);
    await prefs.remove(StorageKeys.userRole);

    _isLoggedIn = false;
    _userEmail = null;
    _userRole = null;
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> checkAuthStatus() async {
    await initialize();
    return _isLoggedIn;
  }
}
