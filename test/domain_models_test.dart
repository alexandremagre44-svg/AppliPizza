/// Test for minimal domain models
///
/// This test verifies the basic functionality of ModuleExposure and FulfillmentConfig.

import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/domain/module_exposure.dart';
import 'package:pizza_delizza/domain/fulfillment_config.dart';

void main() {
  group('ModuleSurface', () {
    test('enum values are correct', () {
      expect(ModuleSurface.client.value, 'client');
      expect(ModuleSurface.pos.value, 'pos');
      expect(ModuleSurface.kitchen.value, 'kitchen');
      expect(ModuleSurface.admin.value, 'admin');
    });

    test('fromString converts correctly', () {
      expect(ModuleSurfaceExtension.fromString('client'), ModuleSurface.client);
      expect(ModuleSurfaceExtension.fromString('pos'), ModuleSurface.pos);
      expect(ModuleSurfaceExtension.fromString('kitchen'), ModuleSurface.kitchen);
      expect(ModuleSurfaceExtension.fromString('admin'), ModuleSurface.admin);
      expect(ModuleSurfaceExtension.fromString('invalid'), ModuleSurface.client);
      expect(ModuleSurfaceExtension.fromString(null), ModuleSurface.client);
    });
  });

  group('ModuleExposure', () {
    test('creates with default values', () {
      const exposure = ModuleExposure();
      expect(exposure.enabled, false);
      expect(exposure.surfaces, isEmpty);
    });

    test('creates with custom values', () {
      const exposure = ModuleExposure(
        enabled: true,
        surfaces: [ModuleSurface.client, ModuleSurface.pos],
      );
      expect(exposure.enabled, true);
      expect(exposure.surfaces.length, 2);
      expect(exposure.surfaces[0], ModuleSurface.client);
      expect(exposure.surfaces[1], ModuleSurface.pos);
    });

    test('toJson converts correctly', () {
      const exposure = ModuleExposure(
        enabled: true,
        surfaces: [ModuleSurface.client, ModuleSurface.admin],
      );
      final json = exposure.toJson();
      expect(json['enabled'], true);
      expect(json['surfaces'], ['client', 'admin']);
    });

    test('fromJson converts correctly', () {
      final json = {
        'enabled': true,
        'surfaces': ['pos', 'kitchen'],
      };
      final exposure = ModuleExposure.fromJson(json);
      expect(exposure.enabled, true);
      expect(exposure.surfaces.length, 2);
      expect(exposure.surfaces[0], ModuleSurface.pos);
      expect(exposure.surfaces[1], ModuleSurface.kitchen);
    });

    test('fromJson handles missing values', () {
      final json = <String, dynamic>{};
      final exposure = ModuleExposure.fromJson(json);
      expect(exposure.enabled, false);
      expect(exposure.surfaces, isEmpty);
    });

    test('copyWith creates modified copy', () {
      const original = ModuleExposure(
        enabled: false,
        surfaces: [ModuleSurface.client],
      );
      final modified = original.copyWith(enabled: true);
      expect(modified.enabled, true);
      expect(modified.surfaces, [ModuleSurface.client]);
    });

    test('equality works correctly', () {
      const exposure1 = ModuleExposure(
        enabled: true,
        surfaces: [ModuleSurface.client],
      );
      const exposure2 = ModuleExposure(
        enabled: true,
        surfaces: [ModuleSurface.client],
      );
      const exposure3 = ModuleExposure(
        enabled: false,
        surfaces: [ModuleSurface.client],
      );
      expect(exposure1, exposure2);
      expect(exposure1 == exposure3, false);
    });
  });

  group('FulfillmentConfig', () {
    test('creates with required values', () {
      const config = FulfillmentConfig(appId: 'test-app');
      expect(config.appId, 'test-app');
      expect(config.pickupEnabled, false);
      expect(config.deliveryEnabled, false);
      expect(config.onSiteEnabled, false);
    });

    test('creates with custom values', () {
      const config = FulfillmentConfig(
        appId: 'test-app',
        pickupEnabled: true,
        deliveryEnabled: true,
        onSiteEnabled: false,
      );
      expect(config.appId, 'test-app');
      expect(config.pickupEnabled, true);
      expect(config.deliveryEnabled, true);
      expect(config.onSiteEnabled, false);
    });

    test('defaultConfig creates with pickup enabled', () {
      final config = FulfillmentConfig.defaultConfig('test-app');
      expect(config.appId, 'test-app');
      expect(config.pickupEnabled, true);
      expect(config.deliveryEnabled, false);
      expect(config.onSiteEnabled, false);
    });

    test('toJson converts correctly', () {
      const config = FulfillmentConfig(
        appId: 'test-app',
        pickupEnabled: true,
        deliveryEnabled: false,
        onSiteEnabled: true,
      );
      final json = config.toJson();
      expect(json['appId'], 'test-app');
      expect(json['pickupEnabled'], true);
      expect(json['deliveryEnabled'], false);
      expect(json['onSiteEnabled'], true);
    });

    test('fromJson converts correctly', () {
      final json = {
        'appId': 'test-app',
        'pickupEnabled': true,
        'deliveryEnabled': true,
        'onSiteEnabled': false,
      };
      final config = FulfillmentConfig.fromJson(json);
      expect(config.appId, 'test-app');
      expect(config.pickupEnabled, true);
      expect(config.deliveryEnabled, true);
      expect(config.onSiteEnabled, false);
    });

    test('fromJson handles missing values', () {
      final json = <String, dynamic>{};
      final config = FulfillmentConfig.fromJson(json);
      expect(config.appId, '');
      expect(config.pickupEnabled, false);
      expect(config.deliveryEnabled, false);
      expect(config.onSiteEnabled, false);
    });

    test('copyWith creates modified copy', () {
      const original = FulfillmentConfig(
        appId: 'test-app',
        pickupEnabled: false,
      );
      final modified = original.copyWith(pickupEnabled: true);
      expect(modified.appId, 'test-app');
      expect(modified.pickupEnabled, true);
    });

    test('equality works correctly', () {
      const config1 = FulfillmentConfig(
        appId: 'test-app',
        pickupEnabled: true,
      );
      const config2 = FulfillmentConfig(
        appId: 'test-app',
        pickupEnabled: true,
      );
      const config3 = FulfillmentConfig(
        appId: 'test-app',
        pickupEnabled: false,
      );
      expect(config1, config2);
      expect(config1 == config3, false);
    });
  });
}
