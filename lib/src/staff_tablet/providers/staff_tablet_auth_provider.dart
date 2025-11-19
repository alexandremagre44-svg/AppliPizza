// lib/src/staff_tablet/providers/staff_tablet_auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================
// STAFF TABLET AUTH STATE
// =============================================

class StaffTabletAuthState {
  final bool isAuthenticated;
  final DateTime? authenticatedAt;
  
  StaffTabletAuthState({
    required this.isAuthenticated,
    this.authenticatedAt,
  });
  
  StaffTabletAuthState copyWith({
    bool? isAuthenticated,
    DateTime? authenticatedAt,
  }) {
    return StaffTabletAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authenticatedAt: authenticatedAt ?? this.authenticatedAt,
    );
  }
}

// =============================================
// STAFF TABLET AUTH NOTIFIER
// =============================================

class StaffTabletAuthNotifier extends StateNotifier<StaffTabletAuthState> {
  StaffTabletAuthNotifier() : super(StaffTabletAuthState(isAuthenticated: false)) {
    _checkExistingAuth();
  }
  
  static const String _authKey = 'staff_tablet_authenticated';
  static const String _authTimeKey = 'staff_tablet_auth_time';
  static const String _pinKey = 'staff_tablet_pin';
  
  // Default PIN for first setup - should be changed by admin
  static const String defaultPin = '1234';
  
  // Session timeout in minutes
  static const int sessionTimeout = 480; // 8 hours
  
  /// Check if there's an existing valid session
  Future<void> _checkExistingAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuth = prefs.getBool(_authKey) ?? false;
    final authTimeStr = prefs.getString(_authTimeKey);
    
    if (isAuth && authTimeStr != null) {
      final authTime = DateTime.parse(authTimeStr);
      final now = DateTime.now();
      final difference = now.difference(authTime).inMinutes;
      
      if (difference < sessionTimeout) {
        state = StaffTabletAuthState(
          isAuthenticated: true,
          authenticatedAt: authTime,
        );
      } else {
        // Session expired
        await logout();
      }
    }
  }
  
  /// Authenticate with PIN
  Future<bool> authenticate(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_pinKey) ?? defaultPin;
    
    if (pin == storedPin) {
      final now = DateTime.now();
      await prefs.setBool(_authKey, true);
      await prefs.setString(_authTimeKey, now.toIso8601String());
      
      state = StaffTabletAuthState(
        isAuthenticated: true,
        authenticatedAt: now,
      );
      return true;
    }
    
    return false;
  }
  
  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_authTimeKey);
    
    state = StaffTabletAuthState(isAuthenticated: false);
  }
  
  /// Change PIN (requires current PIN)
  Future<bool> changePin(String currentPin, String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_pinKey) ?? defaultPin;
    
    if (currentPin == storedPin) {
      await prefs.setString(_pinKey, newPin);
      return true;
    }
    
    return false;
  }
  
  /// Get current PIN (for admin purposes only)
  Future<String> getCurrentPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey) ?? defaultPin;
  }
}

// =============================================
// PROVIDER
// =============================================

final staffTabletAuthProvider = StateNotifierProvider<StaffTabletAuthNotifier, StaffTabletAuthState>((ref) {
  return StaffTabletAuthNotifier();
});
