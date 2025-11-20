// lib/src/providers/home_layout_provider.dart
// Riverpod providers for home layout configuration

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_layout_config.dart';
import '../services/home_layout_service.dart';

/// Service provider for home layout
final homeLayoutServiceProvider = Provider<HomeLayoutService>((ref) {
  return HomeLayoutService();
});

/// Stream provider for home layout configuration
/// Watches for real-time changes in Firestore
final homeLayoutProvider = StreamProvider<HomeLayoutConfig?>((ref) {
  final service = ref.watch(homeLayoutServiceProvider);
  return service.watchHomeLayout();
});

/// Future provider for one-time fetch
/// Used for initialization and initial loading
final homeLayoutFutureProvider = FutureProvider<HomeLayoutConfig?>((ref) async {
  final service = ref.watch(homeLayoutServiceProvider);
  final layout = await service.getHomeLayout();
  
  // Initialize default layout if none exists (backward compatibility)
  if (layout == null) {
    await service.initializeDefaultLayout();
    return await service.getHomeLayout();
  }
  
  return layout;
});
