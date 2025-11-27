// lib/src/models/restaurant_config.dart
// Model class for restaurant configuration in multi-tenant architecture

/// Configuration model for a restaurant tenant
class RestaurantConfig {
  /// Unique identifier for the restaurant
  final String id;

  /// Display name for the restaurant
  final String name;

  /// Creates a new RestaurantConfig instance
  const RestaurantConfig({
    required this.id,
    required this.name,
  });

  /// Empty constructor for safety - returns a placeholder config
  const RestaurantConfig.empty()
      : id = '',
        name = '';

  /// Check if this config is empty/uninitialized
  bool get isEmpty => id.isEmpty;

  /// Check if this config is valid (non-empty)
  bool get isValid => id.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantConfig && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'RestaurantConfig(id: $id, name: $name)';
}
