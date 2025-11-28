// lib/src/providers/loyalty_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/loyalty_service.dart';
import 'auth_provider.dart';

/// Provider pour les informations de fidélité de l'utilisateur connecté
final loyaltyInfoProvider = StreamProvider.autoDispose<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authProvider);
  final uid = authState.userId;
  final loyaltyService = ref.watch(loyaltyServiceProvider);
  
  if (uid == null) {
    return Stream.value(null);
  }
  
  return loyaltyService.watchLoyaltyInfo(uid);
});
