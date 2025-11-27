// lib/builder/utils/app_context.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Default restaurant ID for backwards compatibility
/// This is used as fallback when no specific restaurant is configured
const String _defaultRestaurantId = 'delizza';

/// Role definitions for Builder B3 access control
class BuilderRole {
  /// Super admin with access to all restaurants
  static const String superAdmin = 'super_admin';
  
  /// Restaurant admin with access to specific restaurant
  static const String adminResto = 'admin_resto';
  
  /// Studio role with limited access (optional)
  static const String studio = 'studio';
  
  /// Regular admin (legacy compatibility)
  static const String admin = 'admin';
  
  /// Kitchen staff (no Builder access)
  static const String kitchen = 'kitchen';
  
  /// Regular client (no Builder access)
  static const String client = 'client';
}

/// Restaurant/App metadata
class AppInfo {
  final String appId;
  final String name;
  final String description;
  final bool isActive;
  
  AppInfo({
    required this.appId,
    required this.name,
    required this.description,
    this.isActive = true,
  });
  
  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      appId: json['appId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'name': name,
      'description': description,
      'isActive': isActive,
    };
  }
}

/// Current app context state
class AppContextState {
  final String currentAppId;
  final List<AppInfo> accessibleApps;
  final String userRole;
  final String? userId;
  final bool hasBuilderAccess;
  
  AppContextState({
    required this.currentAppId,
    required this.accessibleApps,
    required this.userRole,
    this.userId,
    required this.hasBuilderAccess,
  });
  
  bool get isSuperAdmin => userRole == BuilderRole.superAdmin;
  bool get isAdminResto => userRole == BuilderRole.adminResto;
  bool get isStudio => userRole == BuilderRole.studio;
  bool get canSwitchApps => isSuperAdmin && accessibleApps.length > 1;
  
  AppContextState copyWith({
    String? currentAppId,
    List<AppInfo>? accessibleApps,
    String? userRole,
    String? userId,
    bool? hasBuilderAccess,
  }) {
    return AppContextState(
      currentAppId: currentAppId ?? this.currentAppId,
      accessibleApps: accessibleApps ?? this.accessibleApps,
      userRole: userRole ?? this.userRole,
      userId: userId ?? this.userId,
      hasBuilderAccess: hasBuilderAccess ?? this.hasBuilderAccess,
    );
  }
}

/// App context service
class AppContextService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  AppContextService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;
  
  /// Get user role and accessible apps
  Future<AppContextState> loadUserContext() async {
    final user = _auth.currentUser;
    
    if (user == null) {
      return AppContextState(
        currentAppId: _defaultRestaurantId, // Default
        accessibleApps: [],
        userRole: BuilderRole.client,
        hasBuilderAccess: false,
      );
    }
    
    // Check custom claims first (more secure)
    Map<String, dynamic>? customClaims;
    try {
      final idTokenResult = await user.getIdTokenResult();
      customClaims = idTokenResult.claims;
    } catch (e) {
      print('Error retrieving custom claims: $e');
    }
    
    // Check if user has admin claim
    final hasAdminClaim = customClaims?['admin'] == true;
    
    // Load user profile from Firestore as fallback
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    
    if (!userDoc.exists && !hasAdminClaim) {
      return AppContextState(
        currentAppId: _defaultRestaurantId,
        accessibleApps: [],
        userRole: BuilderRole.client,
        userId: user.uid,
        hasBuilderAccess: false,
      );
    }
    
    final userData = userDoc.exists ? userDoc.data()! : <String, dynamic>{};
    final role = userData['role'] as String? ?? BuilderRole.client;
    
    // Determine accessible apps based on role
    List<AppInfo> accessibleApps;
    String defaultAppId;
    
    if (role == BuilderRole.superAdmin || hasAdminClaim) {
      // Super admin or admin claim: load all apps
      accessibleApps = await _loadAllApps();
      defaultAppId = accessibleApps.isNotEmpty 
          ? accessibleApps.first.appId 
          : _defaultRestaurantId;
    } else if (role == BuilderRole.adminResto || role == BuilderRole.studio) {
      // Admin resto/studio: load their specific app
      final assignedAppId = userData['appId'] as String? ?? _defaultRestaurantId;
      final appInfo = await _loadAppInfo(assignedAppId);
      accessibleApps = appInfo != null ? [appInfo] : [];
      defaultAppId = assignedAppId;
    } else if (role == BuilderRole.admin) {
      // Legacy admin: treat as admin_resto for default restaurant
      final appInfo = await _loadAppInfo(_defaultRestaurantId);
      accessibleApps = appInfo != null ? [appInfo] : [];
      defaultAppId = _defaultRestaurantId;
    } else {
      // No Builder access
      accessibleApps = [];
      defaultAppId = _defaultRestaurantId;
    }
    
    // Check if user has Builder access (custom claim OR role-based)
    final hasBuilderAccess = hasAdminClaim ||
        role == BuilderRole.superAdmin ||
        role == BuilderRole.adminResto ||
        role == BuilderRole.studio ||
        role == BuilderRole.admin;
    
    return AppContextState(
      currentAppId: defaultAppId,
      accessibleApps: accessibleApps,
      userRole: role,
      userId: user.uid,
      hasBuilderAccess: hasBuilderAccess,
    );
  }
  
  /// Load all apps (for super admin)
  Future<List<AppInfo>> _loadAllApps() async {
    try {
      final snapshot = await _firestore.collection('apps').get();
      return snapshot.docs
          .map((doc) => AppInfo.fromJson({...doc.data(), 'appId': doc.id}))
          .where((app) => app.isActive)
          .toList();
    } catch (e) {
      print('Error loading apps: $e');
      // Fallback to default
      return [
        AppInfo(
          appId: _defaultRestaurantId,
          name: 'Delizza',
          description: 'Restaurant principal',
        ),
      ];
    }
  }
  
  /// Load specific app info
  Future<AppInfo?> _loadAppInfo(String appId) async {
    try {
      final doc = await _firestore.collection('apps').doc(appId).get();
      if (doc.exists) {
        return AppInfo.fromJson({...doc.data()!, 'appId': doc.id});
      }
    } catch (e) {
      print('Error loading app $appId: $e');
    }
    
    // Fallback for default restaurant
    if (appId == _defaultRestaurantId) {
      return AppInfo(
        appId: _defaultRestaurantId,
        name: 'Delizza',
        description: 'Restaurant principal',
      );
    }
    
    return null;
  }
  
  /// Verify user can access specific appId
  bool canAccessApp(AppContextState state, String appId) {
    if (state.isSuperAdmin) {
      return true; // Super admin can access any app
    }
    
    // Check if appId is in accessible apps
    return state.accessibleApps.any((app) => app.appId == appId);
  }
}

/// State notifier for app context
class AppContextNotifier extends StateNotifier<AppContextState> {
  final AppContextService _service;
  
  AppContextNotifier(this._service)
      : super(AppContextState(
          currentAppId: _defaultRestaurantId,
          accessibleApps: [],
          userRole: BuilderRole.client,
          hasBuilderAccess: false,
        ));
  
  /// Load user context
  Future<void> loadContext() async {
    final context = await _service.loadUserContext();
    state = context;
  }
  
  /// Switch to different app (only for super admin)
  void switchApp(String appId) {
    if (!state.isSuperAdmin) {
      print('Error: Only super admin can switch apps');
      return;
    }
    
    if (!_service.canAccessApp(state, appId)) {
      print('Error: Cannot access app $appId');
      return;
    }
    
    state = state.copyWith(currentAppId: appId);
  }
  
  /// Reload context (e.g., after role change)
  Future<void> refresh() async {
    await loadContext();
  }
}

/// Provider for app context service
final appContextServiceProvider = Provider<AppContextService>((ref) {
  return AppContextService();
});

/// Provider for app context state
final appContextProvider =
    StateNotifierProvider<AppContextNotifier, AppContextState>((ref) {
  final service = ref.watch(appContextServiceProvider);
  final notifier = AppContextNotifier(service);
  
  // Auto-load context on creation
  notifier.loadContext();
  
  return notifier;
});

/// Helper provider to get current appId
final currentAppIdProvider = Provider<String>((ref) {
  return ref.watch(appContextProvider).currentAppId;
});

/// Helper provider to check Builder access
final hasBuilderAccessProvider = Provider<bool>((ref) {
  return ref.watch(appContextProvider).hasBuilderAccess;
});
