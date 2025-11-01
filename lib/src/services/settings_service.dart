// lib/src/services/settings_service.dart
// Service pour gérer les paramètres de l'application

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/business_hours.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _settingsKey = 'app_settings';
  static const String _hoursKey = 'business_hours';
  static const String _closuresKey = 'exceptional_closures';

  /// Charger les paramètres
  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson == null || settingsJson.isEmpty) {
      return AppSettings();
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(settingsJson);
      return AppSettings.fromJson(decoded);
    } catch (e) {
      return AppSettings();
    }
  }

  /// Sauvegarder les paramètres
  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(settings.toJson());
      return await prefs.setString(_settingsKey, encoded);
    } catch (e) {
      return false;
    }
  }

  /// Charger les horaires
  Future<List<BusinessHours>> loadBusinessHours() async {
    final prefs = await SharedPreferences.getInstance();
    final String? hoursJson = prefs.getString(_hoursKey);
    
    if (hoursJson == null || hoursJson.isEmpty) {
      return _getDefaultHours();
    }

    try {
      final List<dynamic> decoded = jsonDecode(hoursJson);
      return decoded.map((json) => BusinessHours.fromJson(json)).toList();
    } catch (e) {
      return _getDefaultHours();
    }
  }

  /// Sauvegarder les horaires
  Future<bool> saveBusinessHours(List<BusinessHours> hours) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = hours.map((h) => h.toJson()).toList();
      final String encoded = jsonEncode(jsonList);
      return await prefs.setString(_hoursKey, encoded);
    } catch (e) {
      return false;
    }
  }

  /// Horaires par défaut
  List<BusinessHours> _getDefaultHours() {
    return [
      BusinessHours(dayOfWeek: 'Lundi', openTime: '11:00', closeTime: '22:00'),
      BusinessHours(dayOfWeek: 'Mardi', openTime: '11:00', closeTime: '22:00'),
      BusinessHours(dayOfWeek: 'Mercredi', openTime: '11:00', closeTime: '22:00'),
      BusinessHours(dayOfWeek: 'Jeudi', openTime: '11:00', closeTime: '22:00'),
      BusinessHours(dayOfWeek: 'Vendredi', openTime: '11:00', closeTime: '23:00'),
      BusinessHours(dayOfWeek: 'Samedi', openTime: '11:00', closeTime: '23:00'),
      BusinessHours(dayOfWeek: 'Dimanche', openTime: '18:00', closeTime: '22:00'),
    ];
  }

  /// Charger les fermetures exceptionnelles
  Future<List<ExceptionalClosure>> loadExceptionalClosures() async {
    final prefs = await SharedPreferences.getInstance();
    final String? closuresJson = prefs.getString(_closuresKey);
    
    if (closuresJson == null || closuresJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(closuresJson);
      return decoded.map((json) => ExceptionalClosure.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarder les fermetures exceptionnelles
  Future<bool> saveExceptionalClosures(List<ExceptionalClosure> closures) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = closures.map((c) => c.toJson()).toList();
      final String encoded = jsonEncode(jsonList);
      return await prefs.setString(_closuresKey, encoded);
    } catch (e) {
      return false;
    }
  }
}
