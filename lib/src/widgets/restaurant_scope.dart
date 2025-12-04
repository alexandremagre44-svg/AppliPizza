// lib/src/widgets/restaurant_scope.dart
// Widget that provides restaurant context to the entire application

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant_config.dart';
import '../providers/restaurant_provider.dart';

/// RestaurantScope provides restaurant context to the entire widget tree
///
/// This widget wraps the app and overrides the currentRestaurantProvider
/// with the specified restaurant ID, making it available throughout the app.
///
/// Usage:
/// ```dart
/// RestaurantScope(
///   restaurantId: 'delizza',
///   child: MyApp(),
/// )
/// ```
class RestaurantScope extends ConsumerWidget {
  final String restaurantId;
  final String? restaurantName;
  final Widget child;

  const RestaurantScope({
    super.key,
    required this.restaurantId,
    this.restaurantName,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        currentRestaurantProvider.overrideWithValue(
          RestaurantConfig(
            id: restaurantId,
            name: restaurantName ?? 'Restaurant $restaurantId',
          ),
        ),
      ],
      child: child,
    );
  }
}
