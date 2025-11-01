// lib/src/services/user_service.dart
// Service pour gérer les utilisateurs (admin)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../core/constants.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String _usersKey = 'all_users';

  /// Initialiser avec des utilisateurs par défaut
  Future<void> initialize() async {
    final users = await loadAllUsers();
    if (users.isEmpty) {
      // Créer les utilisateurs par défaut
      final defaultUsers = [
        AppUser(
          id: const Uuid().v4(),
          name: 'Administrateur',
          email: TestCredentials.adminEmail,
          role: UserRole.admin,
          createdAt: DateTime.now(),
        ),
        AppUser(
          id: const Uuid().v4(),
          name: 'Client Test',
          email: TestCredentials.clientEmail,
          role: UserRole.client,
          createdAt: DateTime.now(),
        ),
      ];
      await saveAllUsers(defaultUsers);
    }
  }

  /// Charger tous les utilisateurs
  Future<List<AppUser>> loadAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(_usersKey);
    
    if (usersJson == null || usersJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(usersJson);
      return decoded.map((json) => AppUser.fromJson(json)).toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  /// Sauvegarder tous les utilisateurs
  Future<bool> saveAllUsers(List<AppUser> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = users.map((u) => u.toJson()).toList();
      final String encoded = jsonEncode(jsonList);
      return await prefs.setString(_usersKey, encoded);
    } catch (e) {
      print('Error saving users: $e');
      return false;
    }
  }

  /// Ajouter un utilisateur
  Future<bool> addUser(AppUser user) async {
    final users = await loadAllUsers();
    
    // Vérifier si l'email existe déjà
    if (users.any((u) => u.email == user.email)) {
      return false;
    }
    
    users.add(user);
    return await saveAllUsers(users);
  }

  /// Mettre à jour un utilisateur
  Future<bool> updateUser(AppUser updatedUser) async {
    final users = await loadAllUsers();
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    
    if (index == -1) return false;
    
    users[index] = updatedUser;
    return await saveAllUsers(users);
  }

  /// Bloquer/Débloquer un utilisateur
  Future<bool> toggleUserBlock(String userId) async {
    final users = await loadAllUsers();
    final index = users.indexWhere((u) => u.id == userId);
    
    if (index == -1) return false;
    
    users[index] = users[index].copyWith(isBlocked: !users[index].isBlocked);
    return await saveAllUsers(users);
  }

  /// Supprimer un utilisateur
  Future<bool> deleteUser(String userId) async {
    final users = await loadAllUsers();
    users.removeWhere((u) => u.id == userId);
    return await saveAllUsers(users);
  }

  /// Obtenir un utilisateur par email
  Future<AppUser?> getUserByEmail(String email) async {
    final users = await loadAllUsers();
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir les statistiques des utilisateurs
  Future<Map<String, dynamic>> getUserStats() async {
    final users = await loadAllUsers();
    
    final clients = users.where((u) => u.role == UserRole.client).toList();
    final admins = users.where((u) => u.role == UserRole.admin).toList();
    final blocked = users.where((u) => u.isBlocked).toList();
    
    return {
      'totalUsers': users.length,
      'clients': clients.length,
      'admins': admins.length,
      'blocked': blocked.length,
    };
  }
}
