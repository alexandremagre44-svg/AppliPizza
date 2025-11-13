// lib/src/services/user_profile_service.dart
// Service Firestore pour gérer les profils utilisateurs complets

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../models/user_profile.dart';
import '../models/order.dart';

/// Service pour gérer les profils utilisateurs dans Firestore
class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Singleton
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  /// Collection des profils utilisateurs
  CollectionReference get _profilesCollection => _firestore.collection('user_profiles');

  /// Créer ou mettre à jour un profil utilisateur complet
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final data = {
        'id': profile.id,
        'name': profile.name,
        'email': profile.email,
        'imageUrl': profile.imageUrl,
        'address': profile.address,
        'favoriteProducts': profile.favoriteProducts,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _profilesCollection.doc(profile.id).set(data, SetOptions(merge: true));
      
      developer.log('✅ Profil utilisateur "${profile.name}" sauvegardé dans Firestore');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la sauvegarde du profil utilisateur: $e');
      return false;
    }
  }

  /// Récupérer un profil utilisateur
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _profilesCollection.doc(userId).get();
      
      if (!doc.exists) {
        developer.log('⚠️ Profil utilisateur "$userId" non trouvé');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      
      return UserProfile(
        id: data['id'] as String? ?? userId,
        name: data['name'] as String? ?? 'Utilisateur',
        email: data['email'] as String? ?? '',
        imageUrl: data['imageUrl'] as String? ?? 'https://picsum.photos/200/200?user',
        address: data['address'] as String? ?? '',
        favoriteProducts: (data['favoriteProducts'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        orderHistory: [], // Les commandes sont chargées séparément
      );
    } catch (e) {
      developer.log('❌ Erreur lors de la récupération du profil utilisateur: $e');
      return null;
    }
  }

  /// Stream pour écouter les changements du profil en temps réel
  Stream<UserProfile?> watchUserProfile(String userId) {
    return _profilesCollection
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      
      return UserProfile(
        id: data['id'] as String? ?? userId,
        name: data['name'] as String? ?? 'Utilisateur',
        email: data['email'] as String? ?? '',
        imageUrl: data['imageUrl'] as String? ?? 'https://picsum.photos/200/200?user',
        address: data['address'] as String? ?? '',
        favoriteProducts: (data['favoriteProducts'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        orderHistory: [],
      );
    }).handleError((error) {
      developer.log('❌ Erreur stream profil utilisateur: $error');
      return null;
    });
  }

  /// Ajouter un produit aux favoris
  Future<bool> addToFavorites(String userId, String productId) async {
    try {
      await _profilesCollection.doc(userId).update({
        'favoriteProducts': FieldValue.arrayUnion([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      developer.log('✅ Produit "$productId" ajouté aux favoris');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de l\'ajout aux favoris: $e');
      return false;
    }
  }

  /// Retirer un produit des favoris
  Future<bool> removeFromFavorites(String userId, String productId) async {
    try {
      await _profilesCollection.doc(userId).update({
        'favoriteProducts': FieldValue.arrayRemove([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      developer.log('✅ Produit "$productId" retiré des favoris');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors du retrait des favoris: $e');
      return false;
    }
  }

  /// Mettre à jour l'adresse de l'utilisateur
  Future<bool> updateAddress(String userId, String address) async {
    try {
      await _profilesCollection.doc(userId).update({
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      developer.log('✅ Adresse utilisateur mise à jour');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la mise à jour de l\'adresse: $e');
      return false;
    }
  }

  /// Mettre à jour l'image de profil
  Future<bool> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _profilesCollection.doc(userId).update({
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      developer.log('✅ Image de profil mise à jour');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la mise à jour de l\'image: $e');
      return false;
    }
  }

  /// Créer un profil initial pour un nouvel utilisateur
  Future<bool> createInitialProfile(
    String userId,
    String email, {
    String? name,
    String? imageUrl,
  }) async {
    try {
      final profile = UserProfile(
        id: userId,
        name: name ?? 'Utilisateur',
        email: email,
        imageUrl: imageUrl ?? 'https://picsum.photos/200/200?user',
        address: '',
        favoriteProducts: [],
        orderHistory: [],
      );

      return await saveUserProfile(profile);
    } catch (e) {
      developer.log('❌ Erreur lors de la création du profil initial: $e');
      return false;
    }
  }

  /// Supprimer un profil utilisateur
  Future<bool> deleteUserProfile(String userId) async {
    try {
      await _profilesCollection.doc(userId).delete();
      developer.log('✅ Profil utilisateur "$userId" supprimé');
      return true;
    } catch (e) {
      developer.log('❌ Erreur lors de la suppression du profil: $e');
      return false;
    }
  }
}
