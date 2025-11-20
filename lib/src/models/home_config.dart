// lib/src/models/home_config.dart
// Configuration model for home page customization

class HomeConfig {
  final String id;
  final HeroConfig? hero;
  final PromoBannerConfig? promoBanner;
  final List<ContentBlock> blocks;
  final DateTime updatedAt;

  HomeConfig({
    required this.id,
    this.hero,
    this.promoBanner,
    this.blocks = const [],
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hero': hero?.toJson(),
      'promoBanner': promoBanner?.toJson(),
      'blocks': blocks.map((b) => b.toJson()).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HomeConfig.fromJson(Map<String, dynamic> json) {
    return HomeConfig(
      id: json['id'] as String,
      hero: json['hero'] != null
          ? HeroConfig.fromJson(json['hero'] as Map<String, dynamic>)
          : null,
      promoBanner: json['promoBanner'] != null
          ? PromoBannerConfig.fromJson(json['promoBanner'] as Map<String, dynamic>)
          : null,
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((b) => ContentBlock.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // Convenience getters for hero properties
  bool get heroEnabled => hero?.isActive ?? false;
  String? get heroImageUrl => hero?.imageUrl;
  String get heroTitle => hero?.title ?? '';
  String get heroSubtitle => hero?.subtitle ?? '';
  String get heroCtaText => hero?.ctaText ?? '';
  String get heroCtaAction => hero?.ctaAction ?? '';

  HomeConfig copyWith({
    String? id,
    HeroConfig? hero,
    PromoBannerConfig? promoBanner,
    List<ContentBlock>? blocks,
    DateTime? updatedAt,
    // Convenience parameters for hero properties
    bool? heroEnabled,
    String? heroImageUrl,
    String? heroTitle,
    String? heroSubtitle,
    String? heroCtaText,
    String? heroCtaAction,
  }) {
    // If any hero convenience parameters are provided, update the hero config
    HeroConfig? updatedHero = hero;
    if (heroEnabled != null || heroImageUrl != null || heroTitle != null || 
        heroSubtitle != null || heroCtaText != null || heroCtaAction != null) {
      final currentHero = this.hero ?? HeroConfig(
        isActive: true,
        imageUrl: '',
        title: '',
        subtitle: '',
        ctaText: '',
        ctaAction: '',
      );
      updatedHero = currentHero.copyWith(
        isActive: heroEnabled,
        imageUrl: heroImageUrl,
        title: heroTitle,
        subtitle: heroSubtitle,
        ctaText: heroCtaText,
        ctaAction: heroCtaAction,
      );
    }
    
    return HomeConfig(
      id: id ?? this.id,
      hero: updatedHero ?? this.hero,
      promoBanner: promoBanner ?? this.promoBanner,
      blocks: blocks ?? this.blocks,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create initial default configuration
  factory HomeConfig.initial() {
    return HomeConfig(
      id: 'main',
      hero: HeroConfig(
        isActive: true,
        imageUrl: '',
        title: 'Bienvenue chez Pizza Deli\'Zza',
        subtitle: 'Découvrez nos pizzas artisanales',
        ctaText: 'Voir le menu',
        ctaAction: '/menu',
      ),
      promoBanner: PromoBannerConfig(
        isActive: false,
        text: 'Offre spéciale : -20% sur toutes les pizzas',
        backgroundColor: '#D32F2F',
        textColor: '#FFFFFF',
      ),
      blocks: [],
      updatedAt: DateTime.now(),
    );
  }
}

// Hero Banner Configuration
class HeroConfig {
  final bool isActive;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String ctaText;
  final String ctaAction; // Navigation action (e.g., '/menu', '/admin/pizza')

  HeroConfig({
    required this.isActive,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.ctaAction,
  });

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'ctaText': ctaText,
      'ctaAction': ctaAction,
    };
  }

  factory HeroConfig.fromJson(Map<String, dynamic> json) {
    return HeroConfig(
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      ctaText: json['ctaText'] as String? ?? '',
      ctaAction: json['ctaAction'] as String? ?? '',
    );
  }

  HeroConfig copyWith({
    bool? isActive,
    String? imageUrl,
    String? title,
    String? subtitle,
    String? ctaText,
    String? ctaAction,
  }) {
    return HeroConfig(
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      ctaText: ctaText ?? this.ctaText,
      ctaAction: ctaAction ?? this.ctaAction,
    );
  }
}

// Promotional Banner Configuration
class PromoBannerConfig {
  final bool isActive;
  final String text;
  final String? backgroundColor;
  final String? textColor;
  final DateTime? startDate;
  final DateTime? endDate;

  PromoBannerConfig({
    required this.isActive,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'text': text,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory PromoBannerConfig.fromJson(Map<String, dynamic> json) {
    return PromoBannerConfig(
      isActive: json['isActive'] as bool? ?? false,
      text: json['text'] as String? ?? '',
      backgroundColor: json['backgroundColor'] as String?,
      textColor: json['textColor'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
    );
  }

  PromoBannerConfig copyWith({
    bool? isActive,
    String? text,
    String? backgroundColor,
    String? textColor,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return PromoBannerConfig(
      isActive: isActive ?? this.isActive,
      text: text ?? this.text,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }
}

// Dynamic Content Block
class ContentBlock {
  final String id;
  final String type; // 'specialiteChef', 'produitsPhares', 'menus', 'desserts', 'boissons', 'custom'
  final String title;
  final String content;
  final List<String> productIds;
  final int maxItems;
  final bool isActive;
  final int order; // Display order (1, 2, 3...)

  ContentBlock({
    required this.id,
    required this.type,
    required this.title,
    this.content = '',
    this.productIds = const [],
    this.maxItems = 6,
    this.isActive = true,
    this.order = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'content': content,
      'productIds': productIds,
      'maxItems': maxItems,
      'isActive': isActive,
      'order': order,
    };
  }

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      productIds: (json['productIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      maxItems: json['maxItems'] as int? ?? 6,
      isActive: json['isActive'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
  }

  ContentBlock copyWith({
    String? id,
    String? type,
    String? title,
    String? content,
    List<String>? productIds,
    int? maxItems,
    bool? isActive,
    int? order,
  }) {
    return ContentBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      productIds: productIds ?? this.productIds,
      maxItems: maxItems ?? this.maxItems,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }
}

/// Utility class for color conversion between Flutter Color and Hex String
class ColorConverter {
  /// Convert hex string to Color
  /// Supports formats: '#RRGGBB', '#AARRGGBB', 'RRGGBB', 'AARRGGBB'
  static int? hexToColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    
    String hex = hexString.replaceAll('#', '');
    
    // Add alpha if not present
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    
    try {
      return int.parse(hex, radix: 16);
    } catch (e) {
      print('Error converting hex to color: $e');
      return null;
    }
  }

  /// Convert Color to hex string with alpha
  /// Returns format: '#AARRGGBB'
  static String colorToHex(int colorValue) {
    return '#${colorValue.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Convert Color to hex string without alpha
  /// Returns format: '#RRGGBB'
  static String colorToHexWithoutAlpha(int colorValue) {
    final hex = colorValue.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${hex.substring(2)}'; // Skip the alpha channel
  }
}
