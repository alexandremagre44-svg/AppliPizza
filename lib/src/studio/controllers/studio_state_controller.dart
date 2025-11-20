// lib/src/studio/controllers/studio_state_controller.dart
// Riverpod state management for Studio V2

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/text_block_model.dart';
import '../models/popup_v2_model.dart';
import '../services/text_block_service.dart';
import '../services/popup_v2_service.dart';
import '../../models/home_config.dart';
import '../../models/home_layout_config.dart';
import '../../models/banner_config.dart';
import '../../services/home_config_service.dart';
import '../../services/home_layout_service.dart';
import '../../services/banner_service.dart';

// ===== Services Providers =====

final textBlockServiceProvider = Provider<TextBlockService>((ref) {
  return TextBlockService();
});

final popupV2ServiceProvider = Provider<PopupV2Service>((ref) {
  return PopupV2Service();
});

final homeConfigServiceProvider = Provider<HomeConfigService>((ref) {
  return HomeConfigService();
});

final homeLayoutServiceProvider = Provider<HomeLayoutService>((ref) {
  return HomeLayoutService();
});

final bannerServiceProvider = Provider<BannerService>((ref) {
  return BannerService();
});

// ===== Data Stream Providers =====

/// Watch text blocks in real-time
final textBlocksStreamProvider = StreamProvider<List<TextBlockModel>>((ref) {
  final service = ref.watch(textBlockServiceProvider);
  return service.watchTextBlocks();
});

/// Watch popups V2 in real-time
final popupsV2StreamProvider = StreamProvider<List<PopupV2Model>>((ref) {
  final service = ref.watch(popupV2ServiceProvider);
  return service.watchPopups();
});

/// Watch home layout in real-time
final homeLayoutStreamProvider = StreamProvider<HomeLayoutConfig?>((ref) {
  final service = ref.watch(homeLayoutServiceProvider);
  return service.watchHomeLayout();
});

// ===== Draft State Providers =====

/// Studio draft state - holds all local changes before publishing
class StudioDraftState {
  final HomeConfig? homeConfig;
  final HomeLayoutConfig? layoutConfig;
  final List<BannerConfig> banners;
  final List<PopupV2Model> popupsV2;
  final List<TextBlockModel> textBlocks;
  final bool hasUnsavedChanges;

  StudioDraftState({
    this.homeConfig,
    this.layoutConfig,
    this.banners = const [],
    this.popupsV2 = const [],
    this.textBlocks = const [],
    this.hasUnsavedChanges = false,
  });

  StudioDraftState copyWith({
    HomeConfig? homeConfig,
    HomeLayoutConfig? layoutConfig,
    List<BannerConfig>? banners,
    List<PopupV2Model>? popupsV2,
    List<TextBlockModel>? textBlocks,
    bool? hasUnsavedChanges,
  }) {
    return StudioDraftState(
      homeConfig: homeConfig ?? this.homeConfig,
      layoutConfig: layoutConfig ?? this.layoutConfig,
      banners: banners ?? this.banners,
      popupsV2: popupsV2 ?? this.popupsV2,
      textBlocks: textBlocks ?? this.textBlocks,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }
}

/// Studio draft state controller
class StudioDraftStateNotifier extends StateNotifier<StudioDraftState> {
  StudioDraftStateNotifier() : super(StudioDraftState());

  void setHomeConfig(HomeConfig config) {
    state = state.copyWith(
      homeConfig: config,
      hasUnsavedChanges: true,
    );
  }

  void setLayoutConfig(HomeLayoutConfig config) {
    state = state.copyWith(
      layoutConfig: config,
      hasUnsavedChanges: true,
    );
  }

  void setBanners(List<BannerConfig> banners) {
    state = state.copyWith(
      banners: banners,
      hasUnsavedChanges: true,
    );
  }

  void setPopupsV2(List<PopupV2Model> popups) {
    state = state.copyWith(
      popupsV2: popups,
      hasUnsavedChanges: true,
    );
  }

  void setTextBlocks(List<TextBlockModel> blocks) {
    state = state.copyWith(
      textBlocks: blocks,
      hasUnsavedChanges: true,
    );
  }

  void markSaved() {
    state = state.copyWith(hasUnsavedChanges: false);
  }

  void resetToPublished(StudioDraftState publishedState) {
    state = publishedState.copyWith(hasUnsavedChanges: false);
  }

  void loadInitialState({
    HomeConfig? homeConfig,
    HomeLayoutConfig? layoutConfig,
    List<BannerConfig>? banners,
    List<PopupV2Model>? popupsV2,
    List<TextBlockModel>? textBlocks,
  }) {
    state = StudioDraftState(
      homeConfig: homeConfig,
      layoutConfig: layoutConfig,
      banners: banners ?? [],
      popupsV2: popupsV2 ?? [],
      textBlocks: textBlocks ?? [],
      hasUnsavedChanges: false,
    );
  }
}

final studioDraftStateProvider =
    StateNotifierProvider<StudioDraftStateNotifier, StudioDraftState>((ref) {
  return StudioDraftStateNotifier();
});

// ===== UI State Providers =====

/// Current selected section in Studio navigation
final studioSelectedSectionProvider = StateProvider<String>((ref) {
  return 'overview';
});

/// Loading state
final studioLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

/// Saving state
final studioSavingProvider = StateProvider<bool>((ref) {
  return false;
});
