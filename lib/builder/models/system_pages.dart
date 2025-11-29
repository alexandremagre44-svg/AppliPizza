// lib/builder/models/system_pages.dart
// Unified system page mappings for Builder B3
//
// This file provides a single source of truth for system pages mapping
// between Firestore pageId values, Flutter routes, and BuilderPageId enum.

import 'package:flutter/material.dart';
import 'builder_enums.dart';

/// System page configuration
class SystemPageConfig {
  final BuilderPageId pageId;
  final String route;
  final String firestoreId;
  final String defaultName;
  final IconData defaultIcon;
  final bool isSystemPage;

  const SystemPageConfig({
    required this.pageId,
    required this.route,
    required this.firestoreId,
    required this.defaultName,
    required this.defaultIcon,
    this.isSystemPage = true,
  });
}

/// Unified system pages registry
/// 
/// This is the SINGLE SOURCE OF TRUTH for system page mappings.
/// All services, loaders, and routers should use this registry.
/// 
/// FIX M3: Added promo, about, contact to complete the registry for all BuilderPageId values.
class SystemPages {
  SystemPages._(); // Private constructor to prevent instantiation

  /// All system page configurations
  static const Map<BuilderPageId, SystemPageConfig> _registry = {
    BuilderPageId.home: SystemPageConfig(
      pageId: BuilderPageId.home,
      route: '/home',
      firestoreId: 'home',
      defaultName: 'Accueil',
      defaultIcon: Icons.home,
      isSystemPage: false, // home is not protected - can be freely edited
    ),
    BuilderPageId.menu: SystemPageConfig(
      pageId: BuilderPageId.menu,
      route: '/menu',
      firestoreId: 'menu',
      defaultName: 'Menu',
      defaultIcon: Icons.restaurant_menu,
      isSystemPage: false, // menu is not protected - can be freely edited
    ),
    // FIX M3: Added promo, about, contact pages
    BuilderPageId.promo: SystemPageConfig(
      pageId: BuilderPageId.promo,
      route: '/promo',
      firestoreId: 'promo',
      defaultName: 'Promotions',
      defaultIcon: Icons.local_offer,
      isSystemPage: false, // promo is not protected - can be freely edited
    ),
    BuilderPageId.about: SystemPageConfig(
      pageId: BuilderPageId.about,
      route: '/about',
      firestoreId: 'about',
      defaultName: 'À propos',
      defaultIcon: Icons.info,
      isSystemPage: false, // about is not protected - can be freely edited
    ),
    BuilderPageId.contact: SystemPageConfig(
      pageId: BuilderPageId.contact,
      route: '/contact',
      firestoreId: 'contact',
      defaultName: 'Contact',
      defaultIcon: Icons.contact_mail,
      isSystemPage: false, // contact is not protected - can be freely edited
    ),
    // Protected system pages (cannot be deleted, pageId cannot be changed)
    BuilderPageId.cart: SystemPageConfig(
      pageId: BuilderPageId.cart,
      route: '/cart',
      firestoreId: 'cart',
      defaultName: 'Panier',
      defaultIcon: Icons.shopping_cart,
      isSystemPage: true, // Protected: cart functionality
    ),
    BuilderPageId.profile: SystemPageConfig(
      pageId: BuilderPageId.profile,
      route: '/profile',
      firestoreId: 'profile',
      defaultName: 'Profil',
      defaultIcon: Icons.person,
      isSystemPage: true, // Protected: user profile functionality
    ),
    BuilderPageId.rewards: SystemPageConfig(
      pageId: BuilderPageId.rewards,
      route: '/rewards',
      firestoreId: 'rewards',
      defaultName: 'Récompenses',
      defaultIcon: Icons.card_giftcard,
      isSystemPage: true, // Protected: rewards functionality
    ),
    BuilderPageId.roulette: SystemPageConfig(
      pageId: BuilderPageId.roulette,
      route: '/roulette',
      firestoreId: 'roulette',
      defaultName: 'Roulette',
      defaultIcon: Icons.casino,
      isSystemPage: true, // Protected: roulette game functionality
    ),
  };

  /// Get configuration for a BuilderPageId
  static SystemPageConfig? getConfig(BuilderPageId pageId) {
    return _registry[pageId];
  }

  /// Get configuration by Firestore document ID
  static SystemPageConfig? getConfigByFirestoreId(String firestoreId) {
    for (final config in _registry.values) {
      if (config.firestoreId == firestoreId) {
        return config;
      }
    }
    return null;
  }

  /// Get configuration by route
  static SystemPageConfig? getConfigByRoute(String route) {
    final normalizedRoute = route.startsWith('/') ? route : '/$route';
    for (final config in _registry.values) {
      if (config.route == normalizedRoute) {
        return config;
      }
    }
    return null;
  }

  /// Get BuilderPageId from Firestore document ID
  static BuilderPageId? getPageIdFromFirestoreId(String firestoreId) {
    final config = getConfigByFirestoreId(firestoreId);
    return config?.pageId;
  }

  /// Get route from BuilderPageId
  static String? getRoute(BuilderPageId pageId) {
    return _registry[pageId]?.route;
  }

  /// Get Firestore ID from BuilderPageId
  static String? getFirestoreId(BuilderPageId pageId) {
    return _registry[pageId]?.firestoreId;
  }

  /// Get default name from BuilderPageId
  static String? getDefaultName(BuilderPageId pageId) {
    return _registry[pageId]?.defaultName;
  }

  /// Get default icon from BuilderPageId
  static IconData? getDefaultIcon(BuilderPageId pageId) {
    return _registry[pageId]?.defaultIcon;
  }

  /// Check if a BuilderPageId is a system page
  static bool isSystemPage(BuilderPageId pageId) {
    return _registry[pageId]?.isSystemPage ?? false;
  }

  /// Get all system page IDs
  static List<BuilderPageId> get allSystemPageIds {
    return _registry.keys.toList();
  }

  /// Get all protected system page IDs (cart, profile, rewards, roulette)
  static List<BuilderPageId> get protectedSystemPageIds {
    return _registry.entries
        .where((entry) => entry.value.isSystemPage)
        .map((entry) => entry.key)
        .toList();
  }
}
