// lib/src/models/home_layout_config.dart
// Configuration model for home layout order and visibility
// This controls the order and activation of sections on the home screen

/// Configuration for the home page layout
/// Controls which sections are displayed and in what order
class HomeLayoutConfig {
  /// Document ID
  final String id;
  
  /// Global toggle to enable/disable all studio elements (hero, banner, popups)
  /// When false, the client app won't show any studio elements
  final bool studioEnabled;
  
  /// Order of sections on the home page
  /// Valid values: 'hero', 'banner', 'popups'
  /// Example: ['hero', 'banner', 'popups']
  final List<String> sectionsOrder;
  
  /// Map of section activation states
  /// Keys: 'hero', 'banner', 'popups'
  /// Values: true (visible) or false (hidden)
  final Map<String, bool> enabledSections;
  
  /// Last update timestamp
  final DateTime updatedAt;

  HomeLayoutConfig({
    required this.id,
    required this.studioEnabled,
    required this.sectionsOrder,
    required this.enabledSections,
    required this.updatedAt,
  });

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studioEnabled': studioEnabled,
      'sectionsOrder': sectionsOrder,
      'enabledSections': enabledSections,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from Firestore JSON
  factory HomeLayoutConfig.fromJson(Map<String, dynamic> json) {
    return HomeLayoutConfig(
      id: json['id'] as String? ?? 'home_layout',
      studioEnabled: json['studioEnabled'] as bool? ?? true,
      sectionsOrder: (json['sectionsOrder'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['hero', 'banner', 'popups'],
      enabledSections: (json['enabledSections'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as bool)) ??
          {'hero': true, 'banner': true, 'popups': true},
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Create a copy with modified fields
  HomeLayoutConfig copyWith({
    String? id,
    bool? studioEnabled,
    List<String>? sectionsOrder,
    Map<String, bool>? enabledSections,
    DateTime? updatedAt,
  }) {
    return HomeLayoutConfig(
      id: id ?? this.id,
      studioEnabled: studioEnabled ?? this.studioEnabled,
      sectionsOrder: sectionsOrder ?? this.sectionsOrder,
      enabledSections: enabledSections ?? this.enabledSections,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create default configuration
  /// All studio elements enabled, default order: hero, banner, popups
  factory HomeLayoutConfig.defaultConfig() {
    return HomeLayoutConfig(
      id: 'home_layout',
      studioEnabled: true,
      sectionsOrder: ['hero', 'banner', 'popups'],
      enabledSections: {
        'hero': true,
        'banner': true,
        'popups': true,
      },
      updatedAt: DateTime.now(),
    );
  }

  /// Check if a specific section is enabled
  /// Returns false if studioEnabled is false globally
  bool isSectionEnabled(String sectionKey) {
    if (!studioEnabled) return false;
    return enabledSections[sectionKey] ?? false;
  }

  /// Get ordered list of enabled sections
  /// Only returns sections that are both in sectionsOrder and enabled
  List<String> getOrderedEnabledSections() {
    if (!studioEnabled) return [];
    return sectionsOrder
        .where((section) => enabledSections[section] == true)
        .toList();
  }
}
