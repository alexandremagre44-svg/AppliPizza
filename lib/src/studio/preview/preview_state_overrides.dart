// lib/src/studio/preview/preview_state_overrides.dart
// Provider overrides for preview mode with draft state support

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../../models/order.dart';
import '../../models/theme_config.dart';
import '../../models/home_layout_config.dart';
import '../../models/banner_config.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/theme_providers.dart';
import '../../providers/home_layout_provider.dart';
import '../models/popup_v2_model.dart';
import '../services/popup_v2_service.dart';
import '../../services/banner_service.dart';
import 'simulation_state.dart';

/// Creates provider overrides for preview mode
class PreviewStateOverrides {
  /// Create fake user profile based on simulation state
  static UserProfile createFakeUser(SimulationState simulation) {
    final now = DateTime.now();
    
    switch (simulation.userType) {
      case SimulatedUserType.newCustomer:
        return UserProfile(
          id: simulation.userId,
          email: 'preview.new@test.com',
          displayName: 'Nouveau Client',
          createdAt: now.subtract(const Duration(days: 1)),
          favoriteProducts: [],
          loyaltyPoints: 0,
        );
      
      case SimulatedUserType.returningCustomer:
        return UserProfile(
          id: simulation.userId,
          email: 'preview.returning@test.com',
          displayName: 'Client Habituel',
          createdAt: now.subtract(const Duration(days: 90)),
          favoriteProducts: ['pizza_1', 'pizza_2'],
          loyaltyPoints: 50,
        );
      
      case SimulatedUserType.cartFilled:
        return UserProfile(
          id: simulation.userId,
          email: 'preview.cart@test.com',
          displayName: 'Client Panier Actif',
          createdAt: now.subtract(const Duration(days: 30)),
          favoriteProducts: ['pizza_1'],
          loyaltyPoints: 25,
        );
      
      case SimulatedUserType.frequentBuyer:
        return UserProfile(
          id: simulation.userId,
          email: 'preview.frequent@test.com',
          displayName: 'Client Fréquent',
          createdAt: now.subtract(const Duration(days: 180)),
          favoriteProducts: ['pizza_1', 'pizza_2', 'drink_1'],
          loyaltyPoints: 150,
        );
      
      case SimulatedUserType.vipLoyalty:
        return UserProfile(
          id: simulation.userId,
          email: 'preview.vip@test.com',
          displayName: 'Client VIP',
          createdAt: now.subtract(const Duration(days: 365)),
          favoriteProducts: ['pizza_1', 'pizza_2', 'pizza_3', 'drink_1', 'dessert_1'],
          loyaltyPoints: 500,
        );
    }
  }

  /// Create fake cart state based on simulation
  static CartState createFakeCart(SimulationState simulation) {
    final items = <CartItem>[];
    
    // Add items based on cart item count
    for (int i = 0; i < simulation.cartItemCount; i++) {
      items.add(CartItem(
        id: 'preview_item_$i',
        productId: 'preview_product_$i',
        productName: 'Pizza ${i + 1}',
        price: 12.90 + (i * 2),
        quantity: 1,
        imageUrl: '',
        isMenu: simulation.hasCombo && i == 0,
      ));
    }
    
    return CartState(items);
  }

  /// Create fake order history based on simulation
  static List<Order> createFakeOrders(SimulationState simulation) {
    final orders = <Order>[];
    final now = DateTime.now();
    
    for (int i = 0; i < simulation.previousOrdersCount; i++) {
      orders.add(Order(
        id: 'preview_order_$i',
        userId: simulation.userId,
        date: now.subtract(Duration(days: i * 7)),
        status: i == 0 ? 'completed' : 'completed',
        items: [],
        total: 25.0 + (i * 5),
        customerName: simulation.userDisplayName,
        customerPhone: '0600000000',
        pickupDate: now.subtract(Duration(days: i * 7)).toString().split(' ')[0],
      ));
    }
    
    return orders;
  }

  /// Create list of provider overrides for ProviderScope
  static List<Override> createOverrides({
    required SimulationState simulation,
    HomeLayoutConfig? draftHomeLayout,
    List<BannerConfig>? draftBanners,
    List<PopupV2Model>? draftPopups,
    ThemeConfig? draftTheme,
  }) {
    final overrides = <Override>[];

    // User provider override
    overrides.add(
      userProvider.overrideWith((ref) => FakeUserNotifier(simulation)),
    );

    // Cart provider override
    overrides.add(
      cartProvider.overrideWith((ref) => FakeCartNotifier(simulation)),
    );

    // Orders provider override
    overrides.add(
      ordersStreamProvider.overrideWith((ref) {
        return Stream.value(createFakeOrders(simulation));
      }),
    );

    // Home layout provider override (with draft support)
    if (draftHomeLayout != null) {
      overrides.add(
        homeLayoutProvider.overrideWith((ref) {
          return Stream.value(draftHomeLayout);
        }),
      );
    }

    // Theme provider override (with draft support)
    if (draftTheme != null) {
      overrides.add(
        themeConfigStreamProvider.overrideWith((ref) {
          return Stream.value(draftTheme);
        }),
      );
    }

    return overrides;
  }
}

/// Fake user notifier for preview
class FakeUserNotifier extends UserProfileNotifier {
  final SimulationState simulation;

  FakeUserNotifier(this.simulation) : super(null as Ref) {
    state = PreviewStateOverrides.createFakeUser(simulation);
  }

  @override
  Future<void> loadProfile(String userId) async {
    // Do nothing in preview mode
  }

  @override
  Future<bool> saveProfile() async {
    // Do nothing in preview mode
    return true;
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    // Do nothing in preview mode
  }

  @override
  Future<void> updateAddress(String address) async {
    // Do nothing in preview mode
  }

  @override
  Future<void> updateProfileImage(String imageUrl) async {
    // Do nothing in preview mode
  }

  @override
  Future<void> addOrder({
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? comment,
    String? pickupDate,
    String? pickupTimeSlot,
  }) async {
    // Do nothing in preview mode
  }
}

/// Fake cart notifier for preview
class FakeCartNotifier extends CartNotifier {
  final SimulationState simulation;

  FakeCartNotifier(this.simulation) {
    state = PreviewStateOverrides.createFakeCart(simulation);
  }

  // All methods do nothing in preview mode
  @override
  void addItem(product, {String? customDescription}) {
    // Do nothing in preview mode
  }

  @override
  void removeItem(String itemId) {
    // Do nothing in preview mode
  }

  @override
  void updateQuantity(String itemId, int newQuantity) {
    // Do nothing in preview mode
  }

  @override
  void incrementQuantity(String itemId) {
    // Do nothing in preview mode
  }

  @override
  void decrementQuantity(String itemId) {
    // Do nothing in preview mode
  }

  @override
  void clearCart() {
    // Do nothing in preview mode
  }
}
