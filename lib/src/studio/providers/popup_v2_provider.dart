// lib/src/studio/providers/popup_v2_provider.dart
// Riverpod providers for popup V2 management with draft support

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/popup_v2_model.dart';
import '../services/popup_v2_service.dart';

/// Service provider for popups V2
final popupV2ServiceProvider = Provider<PopupV2Service>((ref) {
  return PopupV2Service();
});

/// Stream provider for all popups
final popupsV2Provider = StreamProvider<List<PopupV2Model>>((ref) {
  final service = ref.watch(popupV2ServiceProvider);
  return service.watchPopups();
});

/// Stream provider for active popups only (enabled + within date range + sorted by priority)
final activePopupsV2Provider = StreamProvider<List<PopupV2Model>>((ref) {
  final popupsAsync = ref.watch(popupsV2Provider);
  return popupsAsync.when(
    data: (popups) => Stream.value(
      popups
          .where((popup) => popup.isCurrentlyActive)
          .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority)), // Higher priority first
    ),
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Future provider for one-time fetch
final popupsV2FutureProvider = FutureProvider<List<PopupV2Model>>((ref) async {
  final service = ref.watch(popupV2ServiceProvider);
  return await service.getAllPopups();
});

/// State provider for draft popups (local changes before publish)
final draftPopupsV2Provider = StateProvider<List<PopupV2Model>?>((ref) => null);

/// State provider for tracking unsaved popup changes
final hasUnsavedPopupChangesProvider = StateProvider<bool>((ref) => false);

/// Provider that returns draft popups if available, otherwise published popups
final effectivePopupsV2Provider = Provider<AsyncValue<List<PopupV2Model>>>((ref) {
  final draftPopups = ref.watch(draftPopupsV2Provider);
  
  if (draftPopups != null) {
    // Return draft popups (wrapped in AsyncValue for consistency)
    return AsyncValue.data(draftPopups);
  }
  
  // Return published popups from stream
  return ref.watch(popupsV2Provider);
});
