// Test pour le modèle UserProfile
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('Créer un profil utilisateur devrait fonctionner', () {
      final profile = UserProfile(
        id: 'u1',
        name: 'John Doe',
        email: 'john@example.com',
        imageUrl: 'https://test.com/image.jpg',
        address: '123 Main St',
        favoriteProducts: ['p1', 'p2'],
        orderHistory: [],
      );

      expect(profile.id, 'u1');
      expect(profile.name, 'John Doe');
      expect(profile.email, 'john@example.com');
      expect(profile.loyaltyPoints, 0); // Default value
      expect(profile.loyaltyLevel, 'Bronze'); // Default value
    });

    test('Créer un profil avec points de fidélité devrait fonctionner', () {
      final profile = UserProfile(
        id: 'u1',
        name: 'Jane Doe',
        email: 'jane@example.com',
        imageUrl: 'https://test.com/image.jpg',
        address: '456 Oak Ave',
        favoriteProducts: [],
        orderHistory: [],
        loyaltyPoints: 750,
        loyaltyLevel: 'Silver',
      );

      expect(profile.id, 'u1');
      expect(profile.loyaltyPoints, 750);
      expect(profile.loyaltyLevel, 'Silver');
    });

    test('copyWith devrait créer une copie avec modifications', () {
      final profile = UserProfile(
        id: 'u1',
        name: 'John Doe',
        email: 'john@example.com',
        imageUrl: 'https://test.com/image.jpg',
        address: '123 Main St',
        favoriteProducts: ['p1'],
        orderHistory: [],
      );

      final updatedProfile = profile.copyWith(
        loyaltyPoints: 500,
        loyaltyLevel: 'Silver',
      );

      expect(updatedProfile.id, 'u1');
      expect(updatedProfile.name, 'John Doe');
      expect(updatedProfile.loyaltyPoints, 500);
      expect(updatedProfile.loyaltyLevel, 'Silver');
    });

    test('toJson devrait sérialiser correctement', () {
      final profile = UserProfile(
        id: 'u1',
        name: 'John Doe',
        email: 'john@example.com',
        imageUrl: 'https://test.com/image.jpg',
        address: '123 Main St',
        favoriteProducts: ['p1', 'p2'],
        orderHistory: [],
        loyaltyPoints: 1200,
        loyaltyLevel: 'Gold',
      );

      final json = profile.toJson();

      expect(json['id'], 'u1');
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['loyaltyPoints'], 1200);
      expect(json['loyaltyLevel'], 'Gold');
      expect(json['favoriteProducts'], ['p1', 'p2']);
    });

    test('fromJson devrait désérialiser correctement', () {
      final json = {
        'id': 'u1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'imageUrl': 'https://test.com/image.jpg',
        'address': '123 Main St',
        'favoriteProducts': ['p1', 'p2'],
        'loyaltyPoints': 800,
        'loyaltyLevel': 'Silver',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'u1');
      expect(profile.name, 'John Doe');
      expect(profile.email, 'john@example.com');
      expect(profile.loyaltyPoints, 800);
      expect(profile.loyaltyLevel, 'Silver');
      expect(profile.favoriteProducts.length, 2);
    });

    test('fromJson avec données partielles devrait utiliser les valeurs par défaut', () {
      final json = {
        'id': 'u1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'imageUrl': 'https://test.com/image.jpg',
        'address': '123 Main St',
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'u1');
      expect(profile.loyaltyPoints, 0); // Default value
      expect(profile.loyaltyLevel, 'Bronze'); // Default value
      expect(profile.favoriteProducts.length, 0);
    });

    test('initial factory devrait créer un profil par défaut', () {
      final profile = UserProfile.initial();

      expect(profile.id, 'user_1');
      expect(profile.name, 'Alexandre Dupont');
      expect(profile.loyaltyPoints, 0);
      expect(profile.loyaltyLevel, 'Bronze');
      expect(profile.favoriteProducts.length, 0);
      expect(profile.orderHistory.length, 0);
    });

    test('fromJson devrait utiliser les valeurs par défaut pour les champs loyalty manquants', () {
      final json = {
        'id': 'u1',
        'name': 'John Doe',
        'email': 'john@example.com',
        'imageUrl': 'https://test.com/image.jpg',
        'address': '123 Main St',
        'favoriteProducts': ['p1'],
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.loyaltyPoints, 0); // Valeur par défaut
      expect(profile.loyaltyLevel, 'Bronze'); // Valeur par défaut
    });

    test('copyWith devrait modifier uniquement les champs loyalty', () {
      final profile = UserProfile(
        id: 'u1',
        name: 'John Doe',
        email: 'john@example.com',
        imageUrl: 'https://test.com/image.jpg',
        address: '123 Main St',
        favoriteProducts: ['p1'],
        orderHistory: [],
      );

      final updatedProfile = profile.copyWith(
        loyaltyPoints: 1500,
        loyaltyLevel: 'Gold',
      );

      expect(updatedProfile.id, 'u1');
      expect(updatedProfile.name, 'John Doe');
      expect(updatedProfile.email, 'john@example.com');
      expect(updatedProfile.loyaltyPoints, 1500);
      expect(updatedProfile.loyaltyLevel, 'Gold');
    });
  });
}
