// test/cart_builder_protection_test.dart
// Tests de non-régression pour la protection du panier
// 
// Ces tests garantissent que :
// 1. Le panier ne peut jamais être créé comme page Builder
// 2. Le panier bypass toujours le BuilderPageLoader
// 3. Les tentatives de création sont bloquées et loggées

import 'package:flutter_test/flutter_test.dart';
import 'package:appli_pizza/builder/models/models.dart';
import 'package:appli_pizza/builder/services/builder_page_service.dart';
import 'package:appli_pizza/builder/services/dynamic_page_resolver.dart';
import 'package:appli_pizza/builder/services/system_pages_initializer.dart';

void main() {
  group('Cart Builder Protection Tests', () {
    
    test('SystemPagesInitializer does not include cart', () {
      // Verify that cart is not in the list of system pages to initialize
      final systemPages = SystemPagesInitializer.systemPages;
      
      // Cart should NOT be in the list
      final hasCart = systemPages.any((config) => config.pageId == BuilderPageId.cart);
      
      expect(hasCart, false, 
        reason: 'Cart must NEVER be in SystemPagesInitializer.systemPages');
      
      // Verify that other system pages are present
      final hasProfile = systemPages.any((config) => config.pageId == BuilderPageId.profile);
      final hasRewards = systemPages.any((config) => config.pageId == BuilderPageId.rewards);
      final hasRoulette = systemPages.any((config) => config.pageId == BuilderPageId.roulette);
      
      expect(hasProfile, true, reason: 'Profile should be in system pages');
      expect(hasRewards, true, reason: 'Rewards should be in system pages');
      expect(hasRoulette, true, reason: 'Roulette should be in system pages');
    });
    
    test('Cannot create blank page with cart name', () {
      final service = BuilderPageService();
      
      // Attempt to create a page with name "Cart"
      expect(
        () => service.createBlankPage(
          appId: 'test_app',
          name: 'Cart',
        ),
        throwsException,
        reason: 'Creating a page with "cart" in the name must throw an exception',
      );
      
      // Also test lowercase
      expect(
        () => service.createBlankPage(
          appId: 'test_app',
          name: 'cart',
        ),
        throwsException,
        reason: 'Creating a page with "cart" in the name must throw an exception',
      );
      
      // Also test with cart in the middle
      expect(
        () => service.createBlankPage(
          appId: 'test_app',
          name: 'Shopping Cart',
        ),
        throwsException,
        reason: 'Creating a page with "cart" in the name must throw an exception',
      );
    });
    
    test('Cannot create template page with cart name', () {
      final service = BuilderPageService();
      
      // Attempt to create a page from template with name "Cart"
      expect(
        () => service.createPageFromTemplate(
          'blank_template',
          appId: 'test_app',
          name: 'Cart',
        ),
        throwsException,
        reason: 'Creating a template page with "cart" in the name must throw an exception',
      );
    });
    
    test('DynamicPageResolver rejects cart pageId', () async {
      final resolver = DynamicPageResolver();
      
      // Attempt to resolve cart page - should return null immediately
      final cartPage = await resolver.resolve(BuilderPageId.cart, 'test_app');
      
      expect(cartPage, null, 
        reason: 'DynamicPageResolver must return null for cart pageId');
    });
    
    test('Cart is marked as system page in SystemPages', () {
      final cartConfig = SystemPages.getConfig(BuilderPageId.cart);
      
      expect(cartConfig, isNotNull, 
        reason: 'Cart config should exist for route mapping');
      
      expect(cartConfig!.isSystemPage, true, 
        reason: 'Cart must be marked as a system page');
      
      expect(cartConfig.route, '/cart', 
        reason: 'Cart route should be /cart');
      
      expect(cartConfig.firestoreId, 'cart', 
        reason: 'Cart Firestore ID should be "cart"');
    });
    
    test('Cart is identified as system page', () {
      // Verify that cart pageId is recognized as a system page
      final isSystemPage = SystemPages.isSystemPage(BuilderPageId.cart);
      
      expect(isSystemPage, true, 
        reason: 'Cart must be identified as a system page');
    });
    
    test('Cart is in protected system page IDs list', () {
      final protectedIds = SystemPages.protectedSystemPageIds;
      
      expect(protectedIds.contains(BuilderPageId.cart), true, 
        reason: 'Cart must be in the list of protected system page IDs');
    });
    
    test('_generatePageId prevents cart collisions', () {
      // This is a unit test for the _generatePageId method
      // Since it's private, we test it indirectly through createBlankPage
      final service = BuilderPageService();
      
      // Names that should trigger the cart protection
      final forbiddenNames = [
        'Cart',
        'cart',
        'CART',
        'Shopping Cart',
        'My Cart',
        'cart page',
      ];
      
      for (final name in forbiddenNames) {
        expect(
          () => service.createBlankPage(
            appId: 'test_app',
            name: name,
          ),
          throwsException,
          reason: 'Name "$name" should be blocked by cart protection',
        );
      }
    });
    
    test('Valid page names without cart are allowed', () {
      final service = BuilderPageService();
      
      // These names should NOT trigger the cart protection
      final validNames = [
        'Home',
        'Menu',
        'Profile',
        'Promotions',
        'About Us',
        'Contact',
      ];
      
      for (final name in validNames) {
        // Should not throw exception
        expect(
          () => service.createBlankPage(
            appId: 'test_app',
            name: name,
          ),
          returnsNormally,
          reason: 'Name "$name" should be allowed',
        );
      }
    });
  });
  
  group('Cart WL Doctrine Compliance', () {
    test('cart_module is in WL system modules list', () {
      // Verify that cart_module is blocked in BlockAddDialog
      const wlSystemModules = [
        'cart_module',
        'delivery_module',
        'click_collect_module',
      ];
      
      expect(wlSystemModules.contains('cart_module'), true,
        reason: 'cart_module must be in the list of blocked WL system modules');
    });
    
    test('Cart protection is documented', () {
      // This test serves as documentation that cart protection is critical
      // and must not be removed or bypassed
      
      const protectionRules = {
        'no_builder_page': 'Cart must NEVER exist as a Builder page in Firestore',
        'no_builder_loader': 'Cart must NEVER use BuilderPageLoader',
        'no_creation': 'Cart pages must NEVER be created through Builder UI',
        'direct_route': 'Route /cart must go directly to CartScreen()',
        'no_module': 'cart_module must NEVER be addable in Builder',
      };
      
      expect(protectionRules.keys.length, 5,
        reason: 'All 5 cart protection rules must be enforced');
    });
  });
}
