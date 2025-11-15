// lib/src/services/roulette_settings_service.dart
// Service for managing RouletteSettings from Firestore

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/roulette_settings.dart';

class RouletteSettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Récupère les paramètres de la roulette depuis Firestore
  Future<RouletteSettings?> getRouletteSettings() async {
    try {
      final doc = await _firestore
          .collection('marketing')
          .doc('roulette_settings')
          .get();

      if (doc.exists && doc.data() != null) {
        return RouletteSettings.fromMap(doc.data()!);
      }
      
      // Return default settings if not configured
      return RouletteSettings.defaultSettings();
    } catch (e) {
      print('Error loading roulette settings: $e');
      return null;
    }
  }
  
  /// Vérifie si la roulette est actuellement active
  /// en tenant compte de tous les paramètres (isEnabled, dates, jours, heures)
  Future<bool> isRouletteCurrentlyActive() async {
    try {
      final settings = await getRouletteSettings();
      if (settings == null || !settings.isEnabled) {
        return false;
      }
      
      final now = DateTime.now();
      
      // Check validity period
      if (!settings.isWithinValidityPeriod(now)) {
        return false;
      }
      
      // Check active days (1=Monday, 7=Sunday)
      final currentDayOfWeek = now.weekday;
      if (!settings.isActiveOnDay(currentDayOfWeek)) {
        return false;
      }
      
      // Check active hours
      if (!settings.isActiveAtHour(now.hour)) {
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error checking if roulette is active: $e');
      return false;
    }
  }
  
  /// Stream pour les changements en temps réel
  Stream<RouletteSettings?> watchRouletteSettings() {
    return _firestore
        .collection('marketing')
        .doc('roulette_settings')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return RouletteSettings.fromMap(snapshot.data()!);
      }
      return RouletteSettings.defaultSettings();
    });
  }
}
