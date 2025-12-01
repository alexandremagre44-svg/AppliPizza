/// lib/white_label/restaurant/restaurant_plan_unified.dart
///
/// Modèle unifié pour la configuration complète d'un restaurant.
/// Ce modèle centralise tous les paramètres et configurations nécessaires
/// pour un restaurant dans le système SaaS multi-tenant.
///
/// Utilisé par:
/// - SuperAdmin (création et édition de restaurants)
/// - WhiteLabel (configuration des modules)
/// - Application client (lecture de la configuration runtime)
/// - Builder B3 (sera connecté en Phase 3)
library;

import '../core/module_id.dart';
import '../modules/appearance/theme/theme_module_config.dart';
import '../modules/appearance/pages_builder/pages_builder_module_config.dart';
import '../modules/core/delivery/delivery_module_config.dart';
import '../modules/core/ordering/ordering_module_config.dart';
import '../modules/core/click_and_collect/click_and_collect_module_config.dart';
import '../modules/marketing/loyalty/loyalty_module_config.dart';
import '../modules/marketing/promotions/promotions_module_config.dart';
import '../modules/marketing/roulette/roulette_module_config.dart';
import '../modules/marketing/newsletter/newsletter_module_config.dart';

/// Configuration de branding pour un restaurant.
///
/// Regroupe tous les éléments visuels et de marque du restaurant.
class BrandingConfig {
  /// Nom de la marque du restaurant.
  final String? brandName;

  /// Couleur primaire (hex format, ex: "#FF5733").
  final String? primaryColor;

  /// Couleur secondaire (hex format).
  final String? secondaryColor;

  /// Couleur d'accent (hex format).
  final String? accentColor;

  /// Couleur de fond (hex format).
  final String? backgroundColor;

  /// URL du logo principal.
  final String? logoUrl;

  /// URL du logo carré (pour icônes).
  final String? squareLogoUrl;

  /// URL du favicon.
  final String? faviconUrl;

  /// Police de caractères principale.
  final String? fontFamily;

  /// Activation du mode sombre.
  final bool darkModeEnabled;

  /// Rayon des bordures (en pixels).
  final double? borderRadius;

  const BrandingConfig({
    this.brandName,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.backgroundColor,
    this.logoUrl,
    this.squareLogoUrl,
    this.faviconUrl,
    this.fontFamily,
    this.darkModeEnabled = false,
    this.borderRadius,
  });

  Map<String, dynamic> toJson() {
    return {
      'brandName': brandName,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      'backgroundColor': backgroundColor,
      'logoUrl': logoUrl,
      'squareLogoUrl': squareLogoUrl,
      'faviconUrl': faviconUrl,
      'fontFamily': fontFamily,
      'darkModeEnabled': darkModeEnabled,
      'borderRadius': borderRadius,
    };
  }

  factory BrandingConfig.fromJson(Map<String, dynamic> json) {
    return BrandingConfig(
      brandName: json['brandName'] as String?,
      primaryColor: json['primaryColor'] as String?,
      secondaryColor: json['secondaryColor'] as String?,
      accentColor: json['accentColor'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      logoUrl: json['logoUrl'] as String?,
      squareLogoUrl: json['squareLogoUrl'] as String?,
      faviconUrl: json['faviconUrl'] as String?,
      fontFamily: json['fontFamily'] as String?,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      borderRadius: (json['borderRadius'] as num?)?.toDouble(),
    );
  }

  BrandingConfig copyWith({
    String? brandName,
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    String? backgroundColor,
    String? logoUrl,
    String? squareLogoUrl,
    String? faviconUrl,
    String? fontFamily,
    bool? darkModeEnabled,
    double? borderRadius,
  }) {
    return BrandingConfig(
      brandName: brandName ?? this.brandName,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      logoUrl: logoUrl ?? this.logoUrl,
      squareLogoUrl: squareLogoUrl ?? this.squareLogoUrl,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      fontFamily: fontFamily ?? this.fontFamily,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

/// Configuration des tablettes cuisine et staff.
class TabletConfig {
  /// Activation de la tablette cuisine.
  final bool kitchenTabletEnabled;

  /// Activation de la tablette staff.
  final bool staffTabletEnabled;

  /// Paramètres spécifiques pour la tablette cuisine.
  final Map<String, dynamic>? kitchenSettings;

  /// Paramètres spécifiques pour la tablette staff.
  final Map<String, dynamic>? staffSettings;

  const TabletConfig({
    this.kitchenTabletEnabled = false,
    this.staffTabletEnabled = false,
    this.kitchenSettings,
    this.staffSettings,
  });

  Map<String, dynamic> toJson() {
    return {
      'kitchenTabletEnabled': kitchenTabletEnabled,
      'staffTabletEnabled': staffTabletEnabled,
      'kitchenSettings': kitchenSettings,
      'staffSettings': staffSettings,
    };
  }

  factory TabletConfig.fromJson(Map<String, dynamic> json) {
    return TabletConfig(
      kitchenTabletEnabled: json['kitchenTabletEnabled'] as bool? ?? false,
      staffTabletEnabled: json['staffTabletEnabled'] as bool? ?? false,
      kitchenSettings: json['kitchenSettings'] as Map<String, dynamic>?,
      staffSettings: json['staffSettings'] as Map<String, dynamic>?,
    );
  }

  TabletConfig copyWith({
    bool? kitchenTabletEnabled,
    bool? staffTabletEnabled,
    Map<String, dynamic>? kitchenSettings,
    Map<String, dynamic>? staffSettings,
  }) {
    return TabletConfig(
      kitchenTabletEnabled: kitchenTabletEnabled ?? this.kitchenTabletEnabled,
      staffTabletEnabled: staffTabletEnabled ?? this.staffTabletEnabled,
      kitchenSettings: kitchenSettings ?? this.kitchenSettings,
      staffSettings: staffSettings ?? this.staffSettings,
    );
  }
}

/// Modèle unifié pour la configuration complète d'un restaurant.
///
/// Ce modèle centralise toutes les informations nécessaires pour configurer
/// un restaurant dans le système SaaS multi-tenant.
///
/// Structure Firestore:
/// ```
/// restaurants/{restaurantId}/
///   plan (document)
///     - restaurantId
///     - name
///     - slug
///     - templateId
///     - activeModules (List<String>)
///     - branding (Map)
///     - delivery (Map)
///     - ordering (Map)
///     - clickAndCollect (Map)
///     - loyalty (Map)
///     - promotions (Map)
///     - roulette (Map)
///     - newsletter (Map)
///     - theme (Map)
///     - pages (Map)
///     - tablets (Map)
///     - createdAt
///     - updatedAt
/// ```
class RestaurantPlanUnified {
  // ========== A. Informations générales ==========

  /// Identifiant unique du restaurant.
  final String restaurantId;

  /// Nom du restaurant.
  final String name;

  /// Slug URL-friendly du restaurant.
  final String slug;

  /// Identifiant du template utilisé (optionnel).
  final String? templateId;

  /// Date de création du plan.
  final DateTime? createdAt;

  /// Date de dernière mise à jour du plan.
  final DateTime? updatedAt;

  // ========== B. Modules activés ==========

  /// Liste des IDs de modules activés pour ce restaurant.
  ///
  /// Utilise les codes de ModuleId (ex: "delivery", "loyalty", "roulette").
  final List<String> activeModules;

  // ========== C. Paramètres consolidés ==========

  /// Configuration de branding (couleurs, logos, thèmes).
  final BrandingConfig? branding;

  /// Configuration du module livraison.
  final DeliveryModuleConfig? delivery;

  /// Configuration du module commandes en ligne.
  final OrderingModuleConfig? ordering;

  /// Configuration du module Click & Collect.
  final ClickAndCollectModuleConfig? clickAndCollect;

  /// Configuration du module fidélité.
  final LoyaltyModuleConfig? loyalty;

  /// Configuration du module promotions.
  final PromotionsModuleConfig? promotions;

  /// Configuration du module roulette.
  final RouletteModuleConfig? roulette;

  /// Configuration du module newsletter.
  final NewsletterModuleConfig? newsletter;

  /// Configuration du module thème.
  final ThemeModuleConfig? theme;

  /// Configuration du module constructeur de pages.
  final PagesBuilderModuleConfig? pages;

  /// Configuration des tablettes (cuisine et staff).
  final TabletConfig? tablets;

  /// Paramètres additionnels non typés (pour extensibilité future).
  final Map<String, dynamic>? additionalSettings;

  /// Constructeur.
  const RestaurantPlanUnified({
    required this.restaurantId,
    required this.name,
    required this.slug,
    this.templateId,
    this.createdAt,
    this.updatedAt,
    this.activeModules = const [],
    this.branding,
    this.delivery,
    this.ordering,
    this.clickAndCollect,
    this.loyalty,
    this.promotions,
    this.roulette,
    this.newsletter,
    this.theme,
    this.pages,
    this.tablets,
    this.additionalSettings,
  });

  /// Crée une copie de ce plan avec les champs modifiés.
  RestaurantPlanUnified copyWith({
    String? restaurantId,
    String? name,
    String? slug,
    String? templateId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? activeModules,
    BrandingConfig? branding,
    DeliveryModuleConfig? delivery,
    OrderingModuleConfig? ordering,
    ClickAndCollectModuleConfig? clickAndCollect,
    LoyaltyModuleConfig? loyalty,
    PromotionsModuleConfig? promotions,
    RouletteModuleConfig? roulette,
    NewsletterModuleConfig? newsletter,
    ThemeModuleConfig? theme,
    PagesBuilderModuleConfig? pages,
    TabletConfig? tablets,
    Map<String, dynamic>? additionalSettings,
  }) {
    return RestaurantPlanUnified(
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      activeModules: activeModules ?? this.activeModules,
      branding: branding ?? this.branding,
      delivery: delivery ?? this.delivery,
      ordering: ordering ?? this.ordering,
      clickAndCollect: clickAndCollect ?? this.clickAndCollect,
      loyalty: loyalty ?? this.loyalty,
      promotions: promotions ?? this.promotions,
      roulette: roulette ?? this.roulette,
      newsletter: newsletter ?? this.newsletter,
      theme: theme ?? this.theme,
      pages: pages ?? this.pages,
      tablets: tablets ?? this.tablets,
      additionalSettings: additionalSettings ?? this.additionalSettings,
    );
  }

  /// Sérialise le plan unifié en JSON.
  ///
  /// Cette méthode assure une sérialisation propre avec gestion
  /// des valeurs null et des champs optionnels.
  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'name': name,
      'slug': slug,
      if (templateId != null) 'templateId': templateId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'activeModules': activeModules,
      if (branding != null) 'branding': branding!.toJson(),
      if (delivery != null) 'delivery': delivery!.toJson(),
      if (ordering != null) 'ordering': ordering!.toJson(),
      if (clickAndCollect != null) 'clickAndCollect': clickAndCollect!.toJson(),
      if (loyalty != null) 'loyalty': loyalty!.toJson(),
      if (promotions != null) 'promotions': promotions!.toJson(),
      if (roulette != null) 'roulette': roulette!.toJson(),
      if (newsletter != null) 'newsletter': newsletter!.toJson(),
      if (theme != null) 'theme': theme!.toJson(),
      if (pages != null) 'pages': pages!.toJson(),
      if (tablets != null) 'tablets': tablets!.toJson(),
      if (additionalSettings != null) ...additionalSettings!,
    };
  }

  /// Désérialise un plan unifié depuis un JSON.
  ///
  /// Cette méthode assure la rétrocompatibilité en gérant les champs
  /// manquants avec des valeurs par défaut appropriées.
  factory RestaurantPlanUnified.fromJson(Map<String, dynamic> json) {
    // Parser la liste des modules activés
    final activeModulesJson = json['activeModules'] as List<dynamic>? ?? [];
    final activeModules = activeModulesJson.map((m) => m.toString()).toList();

    // Parser les dates
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt'] as String);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      try {
        updatedAt = DateTime.parse(json['updatedAt'] as String);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    // Parser les configurations de modules
    BrandingConfig? branding;
    if (json['branding'] != null) {
      try {
        branding =
            BrandingConfig.fromJson(json['branding'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    DeliveryModuleConfig? delivery;
    if (json['delivery'] != null) {
      try {
        delivery = DeliveryModuleConfig.fromJson(
            json['delivery'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    OrderingModuleConfig? ordering;
    if (json['ordering'] != null) {
      try {
        ordering = OrderingModuleConfig.fromJson(
            json['ordering'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    ClickAndCollectModuleConfig? clickAndCollect;
    if (json['clickAndCollect'] != null) {
      try {
        clickAndCollect = ClickAndCollectModuleConfig.fromJson(
            json['clickAndCollect'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    LoyaltyModuleConfig? loyalty;
    if (json['loyalty'] != null) {
      try {
        loyalty = LoyaltyModuleConfig.fromJson(
            json['loyalty'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    PromotionsModuleConfig? promotions;
    if (json['promotions'] != null) {
      try {
        promotions = PromotionsModuleConfig.fromJson(
            json['promotions'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    RouletteModuleConfig? roulette;
    if (json['roulette'] != null) {
      try {
        roulette = RouletteModuleConfig.fromJson(
            json['roulette'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    NewsletterModuleConfig? newsletter;
    if (json['newsletter'] != null) {
      try {
        newsletter = NewsletterModuleConfig.fromJson(
            json['newsletter'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    ThemeModuleConfig? theme;
    if (json['theme'] != null) {
      try {
        theme =
            ThemeModuleConfig.fromJson(json['theme'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    PagesBuilderModuleConfig? pages;
    if (json['pages'] != null) {
      try {
        pages = PagesBuilderModuleConfig.fromJson(
            json['pages'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    TabletConfig? tablets;
    if (json['tablets'] != null) {
      try {
        tablets =
            TabletConfig.fromJson(json['tablets'] as Map<String, dynamic>);
      } catch (_) {
        // Si le parsing échoue, on laisse null
      }
    }

    return RestaurantPlanUnified(
      restaurantId: json['restaurantId'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      templateId: json['templateId'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      activeModules: activeModules,
      branding: branding,
      delivery: delivery,
      ordering: ordering,
      clickAndCollect: clickAndCollect,
      loyalty: loyalty,
      promotions: promotions,
      roulette: roulette,
      newsletter: newsletter,
      theme: theme,
      pages: pages,
      tablets: tablets,
      additionalSettings: null, // Non sérialisé depuis JSON pour éviter conflits
    );
  }

  /// Vérifie si un module est activé pour ce restaurant.
  ///
  /// Utilise la liste [activeModules] pour déterminer si un module
  /// identifié par son [ModuleId] est activé.
  bool hasModule(ModuleId moduleId) {
    return activeModules.contains(moduleId.code);
  }

  /// Retourne la liste des modules activés sous forme de [ModuleId].
  List<ModuleId> get enabledModuleIds {
    return activeModules
        .map((code) {
          try {
            return ModuleId.values.firstWhere((m) => m.code == code);
          } catch (_) {
            return null;
          }
        })
        .whereType<ModuleId>()
        .toList();
  }

  /// Crée un plan unifié par défaut avec des valeurs minimales.
  factory RestaurantPlanUnified.defaults({
    required String restaurantId,
    required String name,
    required String slug,
    String? templateId,
  }) {
    return RestaurantPlanUnified(
      restaurantId: restaurantId,
      name: name,
      slug: slug,
      templateId: templateId,
      activeModules: [],
      branding: null,
      delivery: null,
      ordering: null,
      clickAndCollect: null,
      loyalty: null,
      promotions: null,
      roulette: null,
      newsletter: null,
      theme: null,
      pages: null,
      tablets: null,
    );
  }

  @override
  String toString() {
    return 'RestaurantPlanUnified('
        'restaurantId: $restaurantId, '
        'name: $name, '
        'slug: $slug, '
        'activeModules: ${activeModules.length})';
  }
}
