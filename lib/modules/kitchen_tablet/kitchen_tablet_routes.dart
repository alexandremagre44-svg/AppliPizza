// lib/modules/kitchen_tablet/kitchen_tablet_routes.dart

import 'package:go_router/go_router.dart';
import '../../screens/kitchen_tablet/kitchen_tablet_screen.dart';
import 'kitchen_tablet_module.dart';

/// Route dédiée pour le module Tablette Cuisine
final kitchenTabletRoute = GoRoute(
  path: KitchenTabletModule.route,
  name: 'kitchen_tablet',
  builder: (context, state) => const KitchenTabletScreen(),
);
