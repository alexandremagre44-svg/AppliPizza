// lib/src/screens/admin/pos/providers/pos_session_provider.dart
/// 
/// Provider for managing cashier session state in POS
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../models/cashier_session.dart';
import '../../../../services/cashier_session_service.dart';
import '../../../../providers/restaurant_provider.dart';

/// Provider for cashier session service
final cashierSessionServiceProvider = Provider<CashierSessionService>(
  (ref) {
    final restaurant = ref.watch(currentRestaurantProvider);
    if (restaurant == null) {
      throw Exception('No active restaurant');
    }
    return CashierSessionService(appId: restaurant.id);
  },
  dependencies: [currentRestaurantProvider],
);

/// Provider for active cashier session
final activeCashierSessionProvider = StreamProvider<CashierSession?>(
  (ref) {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    
    if (user == null) {
      return Stream.value(null);
    }
    
    final service = ref.watch(cashierSessionServiceProvider);
    return service.watchActiveSession(user.uid);
  },
  dependencies: [cashierSessionServiceProvider],
);

/// Provider to check if there's an active session
final hasActiveSessionProvider = Provider<bool>(
  (ref) {
    final sessionAsync = ref.watch(activeCashierSessionProvider);
    return sessionAsync.when(
      data: (session) => session != null,
      loading: () => false,
      error: (_, __) => false,
    );
  },
  dependencies: [activeCashierSessionProvider],
);

/// Provider for session report
final sessionReportProvider = Provider.family<SessionReport?, String>(
  (ref, sessionId) {
    final service = ref.watch(cashierSessionServiceProvider);
    // This would need to be async, but for now we'll return null
    // In real implementation, use FutureProvider
    return null;
  },
  dependencies: [cashierSessionServiceProvider],
);
