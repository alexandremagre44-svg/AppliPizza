// lib/src/services/promo_service.dart
// Service pour gérer les codes promo

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/promo_code.dart';

class PromoService {
  static final PromoService _instance = PromoService._internal();
  factory PromoService() => _instance;
  PromoService._internal();

  static const String _promosKey = 'promo_codes';

  Future<List<PromoCode>> loadPromoCodes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? promosJson = prefs.getString(_promosKey);
    
    if (promosJson == null || promosJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(promosJson);
      return decoded.map((json) => PromoCode.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> savePromoCodes(List<PromoCode> codes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = codes.map((c) => c.toJson()).toList();
      final String encoded = jsonEncode(jsonList);
      return await prefs.setString(_promosKey, encoded);
    } catch (e) {
      return false;
    }
  }

  Future<bool> addPromoCode(PromoCode code) async {
    final codes = await loadPromoCodes();
    codes.add(code);
    return await savePromoCodes(codes);
  }

  Future<bool> updatePromoCode(PromoCode updatedCode) async {
    final codes = await loadPromoCodes();
    final index = codes.indexWhere((c) => c.id == updatedCode.id);
    if (index == -1) return false;
    codes[index] = updatedCode;
    return await savePromoCodes(codes);
  }

  Future<bool> deletePromoCode(String codeId) async {
    final codes = await loadPromoCodes();
    codes.removeWhere((c) => c.id == codeId);
    return await savePromoCodes(codes);
  }

  Future<PromoCode?> validatePromoCode(String code) async {
    final codes = await loadPromoCodes();
    try {
      final promo = codes.firstWhere((c) => c.code.toUpperCase() == code.toUpperCase());
      return promo.isValid ? promo : null;
    } catch (e) {
      return null;
    }
  }
}
