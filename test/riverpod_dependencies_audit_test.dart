// test/riverpod_dependencies_audit_test.dart
// Tests to validate that providers with dependencies can be properly overridden
// and that no provider throws dependency override errors

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizza_delizza/src/models/restaurant_config.dart';
import 'package:pizza_delizza/src/providers/restaurant_provider.dart';
import 'package:pizza_delizza/src/providers/popup_provider.dart';
import 'package:pizza_delizza/src/providers/banner_provider.dart';
import 'package:pizza_delizza/src/providers/ingredient_provider.dart';
import 'package:pizza_delizza/src/providers/product_provider.dart';
import 'package:pizza_delizza/src/providers/home_config_provider.dart';
import 'package:pizza_delizza/src/providers/promotion_provider.dart';
import 'package:pizza_delizza/src/providers/app_texts_provider.dart';
import 'package:pizza_delizza/src/providers/theme_providers.dart';
import 'package:pizza_delizza/src/services/popup_service.dart';
import 'package:pizza_delizza/src/services/banner_service.dart';
import 'package:pizza_delizza/src/services/home_config_service.dart';
import 'package:pizza_delizza/src/services/promotion_service.dart';
import 'package:pizza_delizza/src/services/app_texts_service.dart';
import 'package:pizza_delizza/src/services/theme_service.dart';
import 'package:pizza_delizza/src/models/popup_config.dart';
import 'package:pizza_delizza/src/models/banner_config.dart';
import 'package:pizza_delizza/src/models/home_config.dart';
import 'package:pizza_delizza/src/models/promotion.dart';
import 'package:pizza_delizza/src/models/app_texts_config.dart';
import 'package:pizza_delizza/src/models/theme_config.dart';

void main() {
  group('Riverpod Dependencies Audit Tests', () {
    
    test('popup_provider - can override popupServiceProvider and watch popupsProvider', () {
      // Create a mock PopupService that returns an empty stream
      final mockPopupService = _MockPopupService();
      
      // Create a ProviderContainer with override
      final container = ProviderContainer(
        overrides: [
          popupServiceProvider.overrideWithValue(mockPopupService),
        ],
      );
      
      // Try to read the dependent provider - should not throw
      expect(() => container.read(popupsProvider), returnsNormally);
      
      container.dispose();
    });
    
    test('popup_provider - can override popupServiceProvider and watch activePopupsProvider', () {
      final mockPopupService = _MockPopupService();
      
      final container = ProviderContainer(
        overrides: [
          popupServiceProvider.overrideWithValue(mockPopupService),
        ],
      );
      
      expect(() => container.read(activePopupsProvider), returnsNormally);
      
      container.dispose();
    });
    
    test('banner_provider - can override bannerServiceProvider and watch bannersProvider', () {
      final mockBannerService = _MockBannerService();
      
      final container = ProviderContainer(
        overrides: [
          bannerServiceProvider.overrideWithValue(mockBannerService),
        ],
      );
      
      expect(() => container.read(bannersProvider), returnsNormally);
      
      container.dispose();
    });
    
    test('banner_provider - can override bannerServiceProvider and watch activeBannersProvider', () {
      final mockBannerService = _MockBannerService();
      
      final container = ProviderContainer(
        overrides: [
          bannerServiceProvider.overrideWithValue(mockBannerService),
        ],
      );
      
      expect(() => container.read(activeBannersProvider), returnsNormally);
      
      container.dispose();
    });
    
    test('home_config_provider - can override homeConfigServiceProvider and watch homeConfigProvider', () {
      final mockHomeConfigService = _MockHomeConfigService();
      
      final container = ProviderContainer(
        overrides: [
          homeConfigServiceProvider.overrideWithValue(mockHomeConfigService),
        ],
      );
      
      expect(() => container.read(homeConfigProvider), returnsNormally);
      
      container.dispose();
    });
    
    test('home_config_provider - can override homeConfigServiceProvider and watch homeConfigFutureProvider', () {
      final mockHomeConfigService = _MockHomeConfigService();
      
      final container = ProviderContainer(
        overrides: [
          homeConfigServiceProvider.overrideWithValue(mockHomeConfigService),
        ],
      );
      
      expect(() => container.read(homeConfigFutureProvider), returnsNormally);
      
      container.dispose();
    });
    
    test('promotion_provider - can override dependencies and watch promotionsProvider', () {
      final mockPromotionService = _MockPromotionService();
      
      final container = ProviderContainer(
        overrides: [
          promotionServiceProvider.overrideWithValue(mockPromotionService),
          // Note: restaurantFeatureFlagsProvider is also a dependency but can be null
        ],
      );
      
      expect(() => container.read(promotionsProvider), returnsNormally);
      
      container.dispose();
    });
    
    test('app_texts_provider - can override appTextsServiceProvider and watch appTextsConfigProvider', () {
      final mockAppTextsService = _MockAppTextsService();
      
      final container = ProviderContainer(
        overrides: [
          appTextsServiceProvider.overrideWithValue(mockAppTextsService),
        ],
      );
      
      expect(() => container.read(appTextsConfigProvider), returnsNormally);
      
      container.dispose();
    });
    
    test('theme_providers - can override themeServiceProvider and watch themeConfigProvider', () {
      final mockThemeService = _MockThemeService();
      
      final container = ProviderContainer(
        overrides: [
          themeServiceProvider.overrideWithValue(mockThemeService),
        ],
      );
      
      expect(() => container.read(themeConfigProvider), returnsNormally);
      
      container.dispose();
    });
    
    test('theme_providers - can override themeServiceProvider and watch themeConfigStreamProvider', () {
      final mockThemeService = _MockThemeService();
      
      final container = ProviderContainer(
        overrides: [
          themeServiceProvider.overrideWithValue(mockThemeService),
        ],
      );
      
      expect(() => container.read(themeConfigStreamProvider), returnsNormally);
      
      container.dispose();
    });
    
    test('white-label: currentRestaurantProvider can be overridden for multi-tenant testing', () {
      const testRestaurant = RestaurantConfig(
        id: 'test_restaurant',
        name: 'Test Restaurant',
      );
      
      final container = ProviderContainer(
        overrides: [
          currentRestaurantProvider.overrideWithValue(testRestaurant),
        ],
      );
      
      final config = container.read(currentRestaurantProvider);
      expect(config.id, equals('test_restaurant'));
      expect(config.name, equals('Test Restaurant'));
      
      container.dispose();
    });
    
    test('white-label: service providers respect currentRestaurantProvider override', () {
      const testRestaurant = RestaurantConfig(
        id: 'custom_app',
        name: 'Custom App',
      );
      
      final container = ProviderContainer(
        overrides: [
          currentRestaurantProvider.overrideWithValue(testRestaurant),
        ],
      );
      
      // Read service providers - they should use the overridden restaurant
      final popupService = container.read(popupServiceProvider);
      expect(popupService.appId, equals('custom_app'));
      
      final bannerService = container.read(bannerServiceProvider);
      expect(bannerService.appId, equals('custom_app'));
      
      final homeConfigService = container.read(homeConfigServiceProvider);
      expect(homeConfigService.appId, equals('custom_app'));
      
      final promotionService = container.read(promotionServiceProvider);
      expect(promotionService.appId, equals('custom_app'));
      
      final appTextsService = container.read(appTextsServiceProvider);
      expect(appTextsService.appId, equals('custom_app'));
      
      final themeService = container.read(themeServiceProvider);
      expect(themeService.appId, equals('custom_app'));
      
      container.dispose();
    });
  });
}

// ============================================================================
// Mock Services for Testing
// ============================================================================

class _MockPopupService implements PopupService {
  @override
  String get appId => 'mock';
  
  @override
  Stream<List<PopupConfig>> watchPopups() {
    return Stream.value([]);
  }
  
  @override
  Future<List<PopupConfig>> getActivePopups() async {
    return [];
  }
  
  @override
  Future<void> createPopup(PopupConfig popup) async {}
  
  @override
  Future<void> updatePopup(PopupConfig popup) async {}
  
  @override
  Future<void> deletePopup(String popupId) async {}
  
  @override
  Future<PopupConfig?> getPopup(String popupId) async {
    return null;
  }
}

class _MockBannerService implements BannerService {
  @override
  String get appId => 'mock';
  
  @override
  Stream<List<BannerConfig>> watchBanners() {
    return Stream.value([]);
  }
  
  @override
  Future<List<BannerConfig>> getActiveBanners() async {
    return [];
  }
  
  @override
  Future<void> createBanner(BannerConfig banner) async {}
  
  @override
  Future<void> updateBanner(BannerConfig banner) async {}
  
  @override
  Future<void> deleteBanner(String bannerId) async {}
  
  @override
  Future<BannerConfig?> getBanner(String bannerId) async {
    return null;
  }
}

class _MockHomeConfigService implements HomeConfigService {
  @override
  String get appId => 'mock';
  
  @override
  Stream<HomeConfig?> watchHomeConfig() {
    return Stream.value(null);
  }
  
  @override
  Future<HomeConfig?> getHomeConfig() async {
    return null;
  }
  
  @override
  Future<void> saveHomeConfig(HomeConfig config) async {}
  
  @override
  Future<void> initializeDefaultConfig() async {}
}

class _MockPromotionService implements PromotionService {
  @override
  String get appId => 'mock';
  
  @override
  Stream<List<Promotion>> watchPromotions() {
    return Stream.value([]);
  }
  
  @override
  Future<List<Promotion>> getActivePromotions() async {
    return [];
  }
  
  @override
  Future<List<Promotion>> getHomeBannerPromotions() async {
    return [];
  }
  
  @override
  Future<List<Promotion>> getPromoBlockPromotions() async {
    return [];
  }
  
  @override
  Future<void> createPromotion(Promotion promotion) async {}
  
  @override
  Future<void> updatePromotion(Promotion promotion) async {}
  
  @override
  Future<void> deletePromotion(String promotionId) async {}
  
  @override
  Future<Promotion?> getPromotion(String promotionId) async {
    return null;
  }
}

class _MockAppTextsService implements AppTextsService {
  @override
  String get appId => 'mock';
  
  @override
  Stream<AppTextsConfig> watchAppTextsConfig() {
    return Stream.value(AppTextsConfig.defaultConfig());
  }
  
  @override
  Future<AppTextsConfig> getAppTextsConfig() async {
    return AppTextsConfig.defaultConfig();
  }
  
  @override
  Future<void> saveAppTextsConfig(AppTextsConfig config) async {}
  
  @override
  Future<void> initializeDefaultConfig() async {}
}

class _MockThemeService implements ThemeService {
  @override
  String get appId => 'mock';
  
  @override
  Stream<ThemeConfig> watchTheme() {
    return Stream.value(ThemeConfig.defaultConfig());
  }
  
  @override
  Future<ThemeConfig> loadTheme() async {
    return ThemeConfig.defaultConfig();
  }
  
  @override
  Future<void> saveTheme(ThemeConfig config) async {}
  
  @override
  Future<void> publishTheme(ThemeConfig config) async {}
  
  @override
  Future<ThemeConfig> getDraftTheme() async {
    return ThemeConfig.defaultConfig();
  }
  
  @override
  Future<void> saveDraftTheme(ThemeConfig config) async {}
  
  @override
  Future<void> initializeDefaultTheme() async {}
}
