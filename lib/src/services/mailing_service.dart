// lib/src/services/mailing_service.dart
// Service pour gérer les abonnés à la newsletter

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:pizza_delizza/src/features/mailing/data/models/subscriber.dart';

class MailingService {
  static const String _subscribersKey = 'subscribers_list';
  final Uuid _uuid = const Uuid();

  // Charger tous les abonnés
  Future<List<Subscriber>> loadSubscribers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? subscribersJson = prefs.getString(_subscribersKey);

      if (subscribersJson == null || subscribersJson.isEmpty) {
        // Initialiser avec quelques abonnés de test
        final defaultSubscribers = _getDefaultSubscribers();
        await saveSubscribers(defaultSubscribers);
        return defaultSubscribers;
      }

      final List<dynamic> decoded = json.decode(subscribersJson);
      return decoded.map((json) => Subscriber.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors du chargement des abonnés: $e');
      return [];
    }
  }

  // Sauvegarder la liste des abonnés
  Future<bool> saveSubscribers(List<Subscriber> subscribers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          subscribers.map((sub) => sub.toJson()).toList();
      final String encoded = json.encode(jsonList);
      return await prefs.setString(_subscribersKey, encoded);
    } catch (e) {
      print('Erreur lors de la sauvegarde des abonnés: $e');
      return false;
    }
  }

  // Ajouter un nouvel abonné
  Future<bool> addSubscriber(Subscriber subscriber) async {
    try {
      final subscribers = await loadSubscribers();
      
      // Vérifier si l'email existe déjà
      final exists = subscribers.any((sub) => sub.email == subscriber.email);
      if (exists) {
        print('Cet email est déjà inscrit');
        return false;
      }

      subscribers.add(subscriber);
      return await saveSubscribers(subscribers);
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'abonné: $e');
      return false;
    }
  }

  // Mettre à jour un abonné
  Future<bool> updateSubscriber(Subscriber subscriber) async {
    try {
      final subscribers = await loadSubscribers();
      final index = subscribers.indexWhere((sub) => sub.id == subscriber.id);

      if (index == -1) {
        print('Abonné non trouvé');
        return false;
      }

      subscribers[index] = subscriber;
      return await saveSubscribers(subscribers);
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'abonné: $e');
      return false;
    }
  }

  // Supprimer un abonné
  Future<bool> deleteSubscriber(String id) async {
    try {
      final subscribers = await loadSubscribers();
      subscribers.removeWhere((sub) => sub.id == id);
      return await saveSubscribers(subscribers);
    } catch (e) {
      print('Erreur lors de la suppression de l\'abonné: $e');
      return false;
    }
  }

  // Désinscrire un abonné (change le statut)
  Future<bool> unsubscribe(String email) async {
    try {
      final subscribers = await loadSubscribers();
      final index = subscribers.indexWhere((sub) => sub.email == email);

      if (index == -1) {
        return false;
      }

      subscribers[index] = subscribers[index].copyWith(
        status: 'unsubscribed',
        consent: false,
      );

      return await saveSubscribers(subscribers);
    } catch (e) {
      print('Erreur lors de la désinscription: $e');
      return false;
    }
  }

  // Désinscrire par token
  Future<bool> unsubscribeByToken(String token) async {
    try {
      final subscribers = await loadSubscribers();
      final index =
          subscribers.indexWhere((sub) => sub.unsubscribeToken == token);

      if (index == -1) {
        return false;
      }

      subscribers[index] = subscribers[index].copyWith(
        status: 'unsubscribed',
        consent: false,
      );

      return await saveSubscribers(subscribers);
    } catch (e) {
      print('Erreur lors de la désinscription par token: $e');
      return false;
    }
  }

  // Filtrer les abonnés actifs
  Future<List<Subscriber>> getActiveSubscribers() async {
    final subscribers = await loadSubscribers();
    return subscribers.where((sub) => sub.status == 'active').toList();
  }

  // Filtrer les abonnés par segment
  Future<List<Subscriber>> getSubscribersBySegment(String segment) async {
    final subscribers = await loadSubscribers();

    if (segment == 'all') {
      return subscribers.where((sub) => sub.status == 'active').toList();
    } else if (segment == 'active') {
      return subscribers.where((sub) => sub.status == 'active').toList();
    } else {
      // Filtrer par tag
      return subscribers
          .where((sub) => sub.status == 'active' && sub.tags.contains(segment))
          .toList();
    }
  }

  // Générer un token unique pour la désinscription
  String generateUnsubscribeToken() {
    return _uuid.v4();
  }

  // Abonnés par défaut pour la démo
  List<Subscriber> _getDefaultSubscribers() {
    return [
      Subscriber(
        id: _uuid.v4(),
        email: 'client@delizza.com',
        status: 'active',
        tags: ['client', 'vip'],
        consent: true,
        dateInscription: DateTime.now().subtract(const Duration(days: 30)),
        unsubscribeToken: _uuid.v4(),
      ),
      Subscriber(
        id: _uuid.v4(),
        email: 'marie.dupont@example.com',
        status: 'active',
        tags: ['client'],
        consent: true,
        dateInscription: DateTime.now().subtract(const Duration(days: 15)),
        unsubscribeToken: _uuid.v4(),
      ),
      Subscriber(
        id: _uuid.v4(),
        email: 'jean.martin@example.com',
        status: 'active',
        tags: ['client', 'nouveautes'],
        consent: true,
        dateInscription: DateTime.now().subtract(const Duration(days: 7)),
        unsubscribeToken: _uuid.v4(),
      ),
      Subscriber(
        id: _uuid.v4(),
        email: 'sophie.bernard@example.com',
        status: 'unsubscribed',
        tags: ['client'],
        consent: false,
        dateInscription: DateTime.now().subtract(const Duration(days: 60)),
        unsubscribeToken: _uuid.v4(),
      ),
    ];
  }
}
