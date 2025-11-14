// lib/src/services/loyalty_service.dart
// Service de gestion du système de fidélité

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:pizza_delizza/src/features/loyalty/data/models/loyalty_reward.dart';

class LoyaltyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton
  static final LoyaltyService _instance = LoyaltyService._internal();
  factory LoyaltyService() => _instance;
  LoyaltyService._internal();

  /// Collection des utilisateurs
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Initialiser le profil de fidélité d'un utilisateur
  Future<void> initializeLoyalty(String uid) async {
    final userDoc = await _usersCollection.doc(uid).get();
    
    if (!userDoc.exists) {
      // Créer un nouveau document avec les champs de fidélité
      await _usersCollection.doc(uid).set({
        'loyaltyPoints': 0,
        'lifetimePoints': 0,
        'vipTier': VipTier.bronze,
        'rewards': [],
        'availableSpins': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Vérifier si les champs de fidélité existent, sinon les ajouter
      final data = userDoc.data() as Map<String, dynamic>?;
      if (data == null || !data.containsKey('loyaltyPoints')) {
        await _usersCollection.doc(uid).update({
          'loyaltyPoints': 0,
          'lifetimePoints': 0,
          'vipTier': VipTier.bronze,
          'rewards': [],
          'availableSpins': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// Ajouter des points après une commande payée
  /// 1€ dépensé = 10 points
  Future<void> addPointsFromOrder(String uid, double orderTotalInEuros) async {
    final pointsToAdd = (orderTotalInEuros * 10).round();
    
    final userDoc = await _usersCollection.doc(uid).get();
    if (!userDoc.exists) {
      await initializeLoyalty(uid);
      return addPointsFromOrder(uid, orderTotalInEuros);
    }

    final data = userDoc.data() as Map<String, dynamic>;
    final currentLoyaltyPoints = (data['loyaltyPoints'] as num? ?? 0).toInt();
    final currentLifetimePoints = (data['lifetimePoints'] as num? ?? 0).toInt();
    
    final newLoyaltyPoints = currentLoyaltyPoints + pointsToAdd;
    final newLifetimePoints = currentLifetimePoints + pointsToAdd;

    // Calculer le nombre de pizzas gratuites à donner (chaque 1000 points)
    final freePizzasToGive = newLoyaltyPoints ~/ 1000;
    final pointsAfterFreePizzas = newLoyaltyPoints % 1000;

    // Récupérer les récompenses existantes
    final existingRewards = (data['rewards'] as List?)
        ?.map((r) => LoyaltyReward.fromJson(r as Map<String, dynamic>))
        .toList() ?? [];

    // Ajouter les nouvelles pizzas gratuites
    for (int i = 0; i < freePizzasToGive; i++) {
      existingRewards.add(LoyaltyReward(
        type: RewardType.freePizza,
        createdAt: DateTime.now(),
      ));
    }

    // Calculer les spins supplémentaires (tous les 500 points de lifetime)
    final oldSpinThreshold = currentLifetimePoints ~/ 500;
    final newSpinThreshold = newLifetimePoints ~/ 500;
    final spinsToAdd = newSpinThreshold - oldSpinThreshold;
    final currentSpins = (data['availableSpins'] as num? ?? 0).toInt();

    // Recalculer le niveau VIP
    final newVipTier = VipTier.getTierFromLifetimePoints(newLifetimePoints);

    // Mettre à jour Firestore
    await _usersCollection.doc(uid).update({
      'loyaltyPoints': pointsAfterFreePizzas,
      'lifetimePoints': newLifetimePoints,
      'vipTier': newVipTier,
      'rewards': existingRewards.map((r) => r.toJson()).toList(),
      'availableSpins': currentSpins + spinsToAdd,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Obtenir les informations de fidélité d'un utilisateur
  Future<Map<String, dynamic>?> getLoyaltyInfo(String uid) async {
    final userDoc = await _usersCollection.doc(uid).get();
    if (!userDoc.exists) {
      return null;
    }

    final data = userDoc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    return {
      'loyaltyPoints': (data['loyaltyPoints'] as num? ?? 0).toInt(),
      'lifetimePoints': (data['lifetimePoints'] as num? ?? 0).toInt(),
      'vipTier': data['vipTier'] as String? ?? VipTier.bronze,
      'rewards': (data['rewards'] as List?)
          ?.map((r) => LoyaltyReward.fromJson(r as Map<String, dynamic>))
          .toList() ?? [],
      'availableSpins': (data['availableSpins'] as num? ?? 0).toInt(),
    };
  }

  /// Stream des informations de fidélité
  Stream<Map<String, dynamic>?> watchLoyaltyInfo(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      return {
        'loyaltyPoints': (data['loyaltyPoints'] as num? ?? 0).toInt(),
        'lifetimePoints': (data['lifetimePoints'] as num? ?? 0).toInt(),
        'vipTier': data['vipTier'] as String? ?? VipTier.bronze,
        'rewards': (data['rewards'] as List?)
            ?.map((r) => LoyaltyReward.fromJson(r as Map<String, dynamic>))
            .toList() ?? [],
        'availableSpins': (data['availableSpins'] as num? ?? 0).toInt(),
      };
    });
  }

  /// Tourner la roue de récompense
  Future<Map<String, dynamic>> spinRewardWheel(String uid) async {
    final userDoc = await _usersCollection.doc(uid).get();
    if (!userDoc.exists) {
      throw Exception('Utilisateur non trouvé');
    }

    final data = userDoc.data() as Map<String, dynamic>;
    final availableSpins = (data['availableSpins'] as num? ?? 0).toInt();

    if (availableSpins <= 0) {
      throw Exception('Aucun tour disponible');
    }

    // Générer une récompense aléatoire
    final random = Random();
    final roll = random.nextInt(100);

    String? rewardType;
    int? bonusPoints;

    if (roll < 5) {
      // 5% - Rien
      rewardType = null;
    } else if (roll < 25) {
      // 20% - Bonus points (50-200)
      rewardType = RewardType.bonusPoints;
      bonusPoints = 50 + random.nextInt(151); // 50 à 200
    } else if (roll < 55) {
      // 30% - Boisson gratuite
      rewardType = RewardType.freeDrink;
    } else {
      // 45% - Dessert gratuit
      rewardType = RewardType.freeDessert;
    }

    // Mettre à jour le nombre de spins
    await _usersCollection.doc(uid).update({
      'availableSpins': availableSpins - 1,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Appliquer la récompense
    if (rewardType != null) {
      if (rewardType == RewardType.bonusPoints) {
        // Ajouter directement les points
        final currentLoyaltyPoints = (data['loyaltyPoints'] as num? ?? 0).toInt();
        final currentLifetimePoints = (data['lifetimePoints'] as num? ?? 0).toInt();
        final newLoyaltyPoints = currentLoyaltyPoints + bonusPoints!;
        final newLifetimePoints = currentLifetimePoints + bonusPoints;

        // Vérifier si on a atteint 1000 points pour une pizza gratuite
        final freePizzasToGive = newLoyaltyPoints ~/ 1000;
        final pointsAfterFreePizzas = newLoyaltyPoints % 1000;

        final existingRewards = (data['rewards'] as List?)
            ?.map((r) => LoyaltyReward.fromJson(r as Map<String, dynamic>))
            .toList() ?? [];

        for (int i = 0; i < freePizzasToGive; i++) {
          existingRewards.add(LoyaltyReward(
            type: RewardType.freePizza,
            createdAt: DateTime.now(),
          ));
        }

        final newVipTier = VipTier.getTierFromLifetimePoints(newLifetimePoints);

        await _usersCollection.doc(uid).update({
          'loyaltyPoints': pointsAfterFreePizzas,
          'lifetimePoints': newLifetimePoints,
          'vipTier': newVipTier,
          'rewards': existingRewards.map((r) => r.toJson()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Ajouter une récompense
        final existingRewards = (data['rewards'] as List?)
            ?.map((r) => LoyaltyReward.fromJson(r as Map<String, dynamic>))
            .toList() ?? [];

        existingRewards.add(LoyaltyReward(
          type: rewardType,
          createdAt: DateTime.now(),
        ));

        await _usersCollection.doc(uid).update({
          'rewards': existingRewards.map((r) => r.toJson()).toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return {
      'success': true,
      'rewardType': rewardType,
      'bonusPoints': bonusPoints,
    };
  }

  /// Marquer une récompense comme utilisée
  Future<void> useReward(String uid, String rewardType) async {
    final userDoc = await _usersCollection.doc(uid).get();
    if (!userDoc.exists) {
      throw Exception('Utilisateur non trouvé');
    }

    final data = userDoc.data() as Map<String, dynamic>;
    final rewards = (data['rewards'] as List?)
        ?.map((r) => LoyaltyReward.fromJson(r as Map<String, dynamic>))
        .toList() ?? [];

    // Trouver la première récompense non utilisée du type spécifié
    bool found = false;
    for (int i = 0; i < rewards.length; i++) {
      if (rewards[i].type == rewardType && !rewards[i].used) {
        rewards[i] = rewards[i].copyWith(
          used: true,
          usedAt: DateTime.now(),
        );
        found = true;
        break;
      }
    }

    if (!found) {
      throw Exception('Aucune récompense de ce type disponible');
    }

    await _usersCollection.doc(uid).update({
      'rewards': rewards.map((r) => r.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Calculer le total avec réduction VIP appliquée
  double applyVipDiscount(String vipTier, double total) {
    final discount = VipTier.getDiscount(vipTier);
    return total * (1 - discount);
  }

  /// Obtenir les récompenses disponibles (non utilisées) d'un type
  Future<List<LoyaltyReward>> getAvailableRewards(String uid, String rewardType) async {
    final loyaltyInfo = await getLoyaltyInfo(uid);
    if (loyaltyInfo == null) return [];

    final rewards = loyaltyInfo['rewards'] as List<LoyaltyReward>;
    return rewards.where((r) => r.type == rewardType && !r.used).toList();
  }
}
