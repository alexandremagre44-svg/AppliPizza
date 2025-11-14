// lib/src/providers/loyalty_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizza_delizza/src/services/loyalty_service.dart';
import 'auth_provider.dart';

/// Provider pour les informations de fidélité de l'utilisateur connecté
final loyaltyInfoProvider = StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authProvider);
  final uid = authState.userId;
  
  if (uid == null) {
    return Stream.value(null);
  }
  
  return LoyaltyService().watchLoyaltyInfo(uid);
});
