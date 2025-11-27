// lib/src/services/firebase_auth_service.dart
// Service d'authentification Firebase avec gestion des rôles

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../core/constants.dart';
import '../core/firestore_paths.dart';
import 'loyalty_service.dart';
import 'user_profile_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;
  
  // UserProfileService instance initialized with appId
  late final UserProfileService _profileService;

  // Constructor with required appId for multi-tenant isolation
  FirebaseAuthService({required this.appId}) {
    _profileService = UserProfileService(appId: appId);
  }

  // Stream de l'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  /// Connexion avec email/mot de passe
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return {
          'success': false,
          'error': 'Erreur de connexion',
        };
      }

      // Récupérer le rôle de l'utilisateur depuis Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      String role = UserRole.client; // Rôle par défaut
      if (userDoc.exists) {
        role = userDoc.data()?['role'] ?? UserRole.client;
      } else {
        // Créer le profil utilisateur s'il n'existe pas
        await _createUserProfile(credential.user!, UserRole.client);
        
        // Créer aussi le profil complet
        await _profileService.createInitialProfile(
          credential.user!.uid,
          credential.user!.email ?? '',
          name: credential.user!.displayName,
        );
      }

      // Initialiser le système de fidélité
      await LoyaltyService().initializeLoyalty(credential.user!.uid);

      // Set user identifier for Crashlytics (for better crash tracking)
      // Only on non-web platforms (Crashlytics not supported on Web)
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setUserIdentifier(credential.user!.uid);
      }

      return {
        'success': true,
        'user': credential.user,
        'role': role,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erreur de connexion';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Aucun utilisateur trouvé avec cet email';
          break;
        case 'wrong-password':
          errorMessage = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          errorMessage = 'Email invalide';
          break;
        case 'user-disabled':
          errorMessage = 'Ce compte a été désactivé';
          break;
        case 'too-many-requests':
          errorMessage = 'Trop de tentatives. Réessayez plus tard';
          break;
        default:
          errorMessage = 'Erreur de connexion: ${e.message}';
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e, stackTrace) {
      // Report unexpected errors to Crashlytics
      // Only on non-web platforms (Crashlytics not supported on Web)
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'signIn failed',
          fatal: false,
        );
      }
      
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  /// Inscription avec email/mot de passe
  Future<Map<String, dynamic>> signUp(
    String email,
    String password, {
    String? displayName,
    String role = UserRole.client,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return {
          'success': false,
          'error': 'Erreur lors de la création du compte',
        };
      }

      // Mettre à jour le nom d'affichage si fourni
      if (displayName != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      // Créer le profil utilisateur dans Firestore (collection 'users')
      await _createUserProfile(credential.user!, role, displayName: displayName);
      
      // Créer le profil complet dans Firestore (collection 'user_profiles')
      await _profileService.createInitialProfile(
        credential.user!.uid,
        email,
        name: displayName,
      );

      // Initialiser le système de fidélité
      await LoyaltyService().initializeLoyalty(credential.user!.uid);

      // Set user identifier for Crashlytics (for better crash tracking)
      // Only on non-web platforms (Crashlytics not supported on Web)
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setUserIdentifier(credential.user!.uid);
      }

      return {
        'success': true,
        'user': credential.user,
        'role': role,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erreur lors de la création du compte';
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Cet email est déjà utilisé';
          break;
        case 'weak-password':
          errorMessage = 'Le mot de passe est trop faible';
          break;
        case 'invalid-email':
          errorMessage = 'Email invalide';
          break;
        default:
          errorMessage = 'Erreur: ${e.message}';
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e, stackTrace) {
      // Report unexpected errors to Crashlytics
      // Only on non-web platforms (Crashlytics not supported on Web)
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'signUp failed',
          fatal: false,
        );
      }
      
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Créer un profil utilisateur dans Firestore
  Future<void> _createUserProfile(
    User user,
    String role, {
    String? displayName,
  }) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'role': role,
      'displayName': displayName ?? user.displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Récupérer le rôle de l'utilisateur
  Future<String> getUserRole(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data()?['role'] ?? UserRole.client;
      }
      return UserRole.client;
    } catch (e) {
      return UserRole.client;
    }
  }

  /// Récupérer le profil complet de l'utilisateur
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Stream du rôle utilisateur
  Stream<String> watchUserRole(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data()?['role'] ?? UserRole.client);
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Envoyer un email de réinitialisation de mot de passe
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Email de réinitialisation envoyé',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Erreur lors de l\'envoi de l\'email';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Aucun utilisateur trouvé avec cet email';
          break;
        case 'invalid-email':
          errorMessage = 'Email invalide';
          break;
        default:
          errorMessage = 'Erreur: ${e.message}';
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur: $e',
      };
    }
  }

  /// Mettre à jour le rôle d'un utilisateur (admin uniquement)
  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Récupérer les custom claims du token Firebase Auth
  /// Returns null if user is null or claims cannot be retrieved
  Future<Map<String, dynamic>?> getCustomClaims(User user) async {
    try {
      final idTokenResult = await user.getIdTokenResult();
      return idTokenResult.claims;
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving custom claims: $e');
      }
      return null;
    }
  }
}
