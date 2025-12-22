/// Example: How to properly import domain models
///
/// This file demonstrates the CORRECT way to import domain models
/// from any location in the codebase.
///
/// Location: lib/examples/domain_import_example.dart

// ✅ CORRECT: Always use package imports for domain models
import 'package:pizza_delizza/domain/module_exposure.dart';
import 'package:pizza_delizza/domain/fulfillment_config.dart';
import 'package:flutter/material.dart';

/// Example widget showing proper domain model imports
class DomainImportExample extends StatelessWidget {
  const DomainImportExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Example usage of ModuleExposure
    const exposure = ModuleExposure(
      enabled: true,
      surfaces: [ModuleSurface.client, ModuleSurface.pos],
    );

    // Example usage of FulfillmentConfig
    const config = FulfillmentConfig(
      appId: 'example-app',
      pickupEnabled: true,
      deliveryEnabled: true,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Domain Import Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Module enabled: ${exposure.enabled}'),
            Text('Surfaces: ${exposure.surfaces}'),
            const SizedBox(height: 20),
            Text('App ID: ${config.appId}'),
            Text('Pickup: ${config.pickupEnabled}'),
            Text('Delivery: ${config.deliveryEnabled}'),
          ],
        ),
      ),
    );
  }
}

// ❌ WRONG: Never use relative imports like these:
// import '../../../../domain/module_exposure.dart';  // INTERDIT
// import '../../../domain/fulfillment_config.dart';  // INTERDIT
// import '../../domain/module_exposure.dart';         // INTERDIT
//
// Even from nearby files, always use package imports:
// ✅ import 'package:pizza_delizza/domain/module_exposure.dart';
