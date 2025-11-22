// lib/src/models/app_config.dart
// Unified configuration model for the entire application
// This centralizes all configuration aspects for white-label support

/// Enum for different types of home sections
enum HomeSectionType {
  hero('hero'),
  promoBanner('promo_banner'),
  popup('popup'),
  productGrid('product_grid'),
  categoryList('category_list'),
  custom('custom');

  const HomeSectionType(this.value);
  final String value;

  static HomeSectionType fromString(String value) {
    return HomeSectionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HomeSectionType.custom,
    );
  }
}

/// Main application configuration
class AppConfig {
  final String appId;
  final int version;
  final HomeConfigV2 home;
  final MenuConfig menu;
  final BrandingConfig branding;
  final LegalConfig legal;
  final ModulesConfig modules;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppConfig({
    required this.appId,
    required this.version,
    required this.home,
    required this.menu,
    required this.branding,
    required this.legal,
    required this.modules,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'version': version,
      'home': home.toJson(),
      'menu': menu.toJson(),
      'branding': branding.toJson(),
      'legal': legal.toJson(),
      'modules': modules.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appId: json['appId'] as String? ?? 'pizza_delizza',
      version: json['version'] as int? ?? 1,
      home: json['home'] != null
          ? HomeConfigV2.fromJson(json['home'] as Map<String, dynamic>)
          : HomeConfigV2.empty(),
      menu: json['menu'] != null
          ? MenuConfig.fromJson(json['menu'] as Map<String, dynamic>)
          : MenuConfig.empty(),
      branding: json['branding'] != null
          ? BrandingConfig.fromJson(json['branding'] as Map<String, dynamic>)
          : BrandingConfig.empty(),
      legal: json['legal'] != null
          ? LegalConfig.fromJson(json['legal'] as Map<String, dynamic>)
          : LegalConfig.empty(),
      modules: json['modules'] != null
          ? ModulesConfig.fromJson(json['modules'] as Map<String, dynamic>)
          : ModulesConfig.empty(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  AppConfig copyWith({
    String? appId,
    int? version,
    HomeConfigV2? home,
    MenuConfig? menu,
    BrandingConfig? branding,
    LegalConfig? legal,
    ModulesConfig? modules,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppConfig(
      appId: appId ?? this.appId,
      version: version ?? this.version,
      home: home ?? this.home,
      menu: menu ?? this.menu,
      branding: branding ?? this.branding,
      legal: legal ?? this.legal,
      modules: modules ?? this.modules,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppConfig.initial({String appId = 'pizza_delizza'}) {
    final now = DateTime.now();
    return AppConfig(
      appId: appId,
      version: 1,
      home: HomeConfigV2.initial(),
      menu: MenuConfig.empty(),
      branding: BrandingConfig.empty(),
      legal: LegalConfig.empty(),
      modules: ModulesConfig.empty(),
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Configuration for the home screen
class HomeConfigV2 {
  final List<HomeSectionConfig> sections;
  final TextsConfig texts;
  final ThemeConfigV2 theme;

  HomeConfigV2({
    required this.sections,
    required this.texts,
    required this.theme,
  });

  Map<String, dynamic> toJson() {
    return {
      'sections': sections.map((s) => s.toJson()).toList(),
      'texts': texts.toJson(),
      'theme': theme.toJson(),
    };
  }

  factory HomeConfigV2.fromJson(Map<String, dynamic> json) {
    return HomeConfigV2(
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => HomeSectionConfig.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      texts: json['texts'] != null
          ? TextsConfig.fromJson(json['texts'] as Map<String, dynamic>)
          : TextsConfig.empty(),
      theme: json['theme'] != null
          ? ThemeConfigV2.fromJson(json['theme'] as Map<String, dynamic>)
          : ThemeConfigV2.empty(),
    );
  }

  HomeConfigV2 copyWith({
    List<HomeSectionConfig>? sections,
    TextsConfig? texts,
    ThemeConfigV2? theme,
  }) {
    return HomeConfigV2(
      sections: sections ?? this.sections,
      texts: texts ?? this.texts,
      theme: theme ?? this.theme,
    );
  }

  factory HomeConfigV2.empty() {
    return HomeConfigV2(
      sections: [],
      texts: TextsConfig.empty(),
      theme: ThemeConfigV2.empty(),
    );
  }

  factory HomeConfigV2.initial() {
    return HomeConfigV2(
      sections: [
        HomeSectionConfig(
          id: 'hero_1',
          type: HomeSectionType.hero,
          order: 1,
          active: true,
          data: {
            'title': 'Bienvenue chez Pizza Deli\'Zza',
            'subtitle': 'La pizza 100% appli',
            'imageUrl': '',
            'ctaLabel': 'Voir le menu',
            'ctaTarget': 'menu',
          },
        ),
        HomeSectionConfig(
          id: 'banner_1',
          type: HomeSectionType.promoBanner,
          order: 2,
          active: false,
          data: {
            'text': '−20% le mardi',
            'backgroundColor': '#D62828',
          },
        ),
      ],
      texts: TextsConfig.initial(),
      theme: ThemeConfigV2.initial(),
    );
  }
}

/// Configuration for a single home section
class HomeSectionConfig {
  final String id;
  final HomeSectionType type;
  final int order;
  final bool active;
  final Map<String, dynamic> data;

  HomeSectionConfig({
    required this.id,
    required this.type,
    required this.order,
    required this.active,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'order': order,
      'active': active,
      'data': data,
    };
  }

  factory HomeSectionConfig.fromJson(Map<String, dynamic> json) {
    return HomeSectionConfig(
      id: json['id'] as String,
      type: HomeSectionType.fromString(json['type'] as String? ?? 'custom'),
      order: json['order'] as int? ?? 0,
      active: json['active'] as bool? ?? true,
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  HomeSectionConfig copyWith({
    String? id,
    HomeSectionType? type,
    int? order,
    bool? active,
    Map<String, dynamic>? data,
  }) {
    return HomeSectionConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      order: order ?? this.order,
      active: active ?? this.active,
      data: data ?? this.data,
    );
  }
}

/// Configuration for text content
class TextsConfig {
  final String welcomeTitle;
  final String welcomeSubtitle;
  final Map<String, String>? additionalTexts;

  TextsConfig({
    required this.welcomeTitle,
    required this.welcomeSubtitle,
    this.additionalTexts,
  });

  Map<String, dynamic> toJson() {
    return {
      'welcomeTitle': welcomeTitle,
      'welcomeSubtitle': welcomeSubtitle,
      'additionalTexts': additionalTexts,
    };
  }

  factory TextsConfig.fromJson(Map<String, dynamic> json) {
    return TextsConfig(
      welcomeTitle: json['welcomeTitle'] as String? ?? '',
      welcomeSubtitle: json['welcomeSubtitle'] as String? ?? '',
      additionalTexts: json['additionalTexts'] != null
          ? Map<String, String>.from(json['additionalTexts'] as Map)
          : null,
    );
  }

  TextsConfig copyWith({
    String? welcomeTitle,
    String? welcomeSubtitle,
    Map<String, String>? additionalTexts,
  }) {
    return TextsConfig(
      welcomeTitle: welcomeTitle ?? this.welcomeTitle,
      welcomeSubtitle: welcomeSubtitle ?? this.welcomeSubtitle,
      additionalTexts: additionalTexts ?? this.additionalTexts,
    );
  }

  factory TextsConfig.empty() {
    return TextsConfig(
      welcomeTitle: '',
      welcomeSubtitle: '',
    );
  }

  factory TextsConfig.initial() {
    return TextsConfig(
      welcomeTitle: 'Bienvenue chez Pizza Deli\'Zza',
      welcomeSubtitle: 'La pizza 100% appli',
    );
  }
}

/// Configuration for theme colors and styling
class ThemeConfigV2 {
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final bool darkMode;

  ThemeConfigV2({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.darkMode,
  });

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      'darkMode': darkMode,
    };
  }

  factory ThemeConfigV2.fromJson(Map<String, dynamic> json) {
    return ThemeConfigV2(
      primaryColor: json['primaryColor'] as String? ?? '#D62828',
      secondaryColor: json['secondaryColor'] as String? ?? '#000000',
      accentColor: json['accentColor'] as String? ?? '#FFFFFF',
      darkMode: json['darkMode'] as bool? ?? false,
    );
  }

  ThemeConfigV2 copyWith({
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    bool? darkMode,
  }) {
    return ThemeConfigV2(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  factory ThemeConfigV2.empty() {
    return ThemeConfigV2(
      primaryColor: '#D62828',
      secondaryColor: '#000000',
      accentColor: '#FFFFFF',
      darkMode: false,
    );
  }

  factory ThemeConfigV2.initial() {
    return ThemeConfigV2(
      primaryColor: '#D62828',
      secondaryColor: '#000000',
      accentColor: '#FFFFFF',
      darkMode: false,
    );
  }
}

/// Configuration for menu
class MenuConfig {
  final List<String> categories;
  final List<String> featuredItems;

  MenuConfig({
    required this.categories,
    required this.featuredItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'categories': categories,
      'featuredItems': featuredItems,
    };
  }

  factory MenuConfig.fromJson(Map<String, dynamic> json) {
    return MenuConfig(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      featuredItems: (json['featuredItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  MenuConfig copyWith({
    List<String>? categories,
    List<String>? featuredItems,
  }) {
    return MenuConfig(
      categories: categories ?? this.categories,
      featuredItems: featuredItems ?? this.featuredItems,
    );
  }

  factory MenuConfig.empty() {
    return MenuConfig(
      categories: [],
      featuredItems: [],
    );
  }
}

/// Configuration for branding
class BrandingConfig {
  final String logoUrl;
  final String faviconUrl;

  BrandingConfig({
    required this.logoUrl,
    required this.faviconUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'logoUrl': logoUrl,
      'faviconUrl': faviconUrl,
    };
  }

  factory BrandingConfig.fromJson(Map<String, dynamic> json) {
    return BrandingConfig(
      logoUrl: json['logoUrl'] as String? ?? '',
      faviconUrl: json['faviconUrl'] as String? ?? '',
    );
  }

  BrandingConfig copyWith({
    String? logoUrl,
    String? faviconUrl,
  }) {
    return BrandingConfig(
      logoUrl: logoUrl ?? this.logoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
    );
  }

  factory BrandingConfig.empty() {
    return BrandingConfig(
      logoUrl: '',
      faviconUrl: '',
    );
  }
}

/// Configuration for legal information
class LegalConfig {
  final String cgv;
  final String mentionsLegales;

  LegalConfig({
    required this.cgv,
    required this.mentionsLegales,
  });

  Map<String, dynamic> toJson() {
    return {
      'cgv': cgv,
      'mentionsLegales': mentionsLegales,
    };
  }

  factory LegalConfig.fromJson(Map<String, dynamic> json) {
    return LegalConfig(
      cgv: json['cgv'] as String? ?? '',
      mentionsLegales: json['mentionsLegales'] as String? ?? '',
    );
  }

  LegalConfig copyWith({
    String? cgv,
    String? mentionsLegales,
  }) {
    return LegalConfig(
      cgv: cgv ?? this.cgv,
      mentionsLegales: mentionsLegales ?? this.mentionsLegales,
    );
  }

  factory LegalConfig.empty() {
    return LegalConfig(
      cgv: '',
      mentionsLegales: '',
    );
  }
}

/// Configuration for all modules
class ModulesConfig {
  final RouletteModuleConfig roulette;

  ModulesConfig({
    required this.roulette,
  });

  Map<String, dynamic> toJson() {
    return {
      'roulette': roulette.toJson(),
    };
  }

  factory ModulesConfig.fromJson(Map<String, dynamic> json) {
    return ModulesConfig(
      roulette: json['roulette'] != null
          ? RouletteModuleConfig.fromJson(json['roulette'] as Map<String, dynamic>)
          : RouletteModuleConfig.empty(),
    );
  }

  ModulesConfig copyWith({
    RouletteModuleConfig? roulette,
  }) {
    return ModulesConfig(
      roulette: roulette ?? this.roulette,
    );
  }

  factory ModulesConfig.empty() {
    return ModulesConfig(
      roulette: RouletteModuleConfig.empty(),
    );
  }
}

/// Configuration for the roulette module
class RouletteModuleConfig {
  final bool enabled;
  final Map<String, dynamic> config;

  RouletteModuleConfig({
    required this.enabled,
    required this.config,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'config': config,
    };
  }

  factory RouletteModuleConfig.fromJson(Map<String, dynamic> json) {
    return RouletteModuleConfig(
      enabled: json['enabled'] as bool? ?? false,
      config: json['config'] as Map<String, dynamic>? ?? {},
    );
  }

  RouletteModuleConfig copyWith({
    bool? enabled,
    Map<String, dynamic>? config,
  }) {
    return RouletteModuleConfig(
      enabled: enabled ?? this.enabled,
      config: config ?? this.config,
    );
  }

  factory RouletteModuleConfig.empty() {
    return RouletteModuleConfig(
      enabled: false,
      config: {},
    );
  }
}
