// lib/core/config/app_config_v2.dart
// Configuration typée pour l'architecture white-label
// TODO: À connecter au reste de l'application lors de la migration

/// Configuration principale de l'application white-label
class AppConfigV2 {
  final String appId;
  final RestaurantConfig restaurant;
  final ThemeConfigWhiteLabel theme;
  final ModulesConfigWhiteLabel modules;
  final MenuConfigWhiteLabel menu;
  final WebsiteConfig website;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppConfigV2({
    required this.appId,
    required this.restaurant,
    required this.theme,
    required this.modules,
    required this.menu,
    required this.website,
    required this.createdAt,
    required this.updatedAt,
  });

  AppConfigV2 copyWith({
    String? appId,
    RestaurantConfig? restaurant,
    ThemeConfigWhiteLabel? theme,
    ModulesConfigWhiteLabel? modules,
    MenuConfigWhiteLabel? menu,
    WebsiteConfig? website,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppConfigV2(
      appId: appId ?? this.appId,
      restaurant: restaurant ?? this.restaurant,
      theme: theme ?? this.theme,
      modules: modules ?? this.modules,
      menu: menu ?? this.menu,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appId': appId,
      'restaurant': restaurant.toJson(),
      'theme': theme.toJson(),
      'modules': modules.toJson(),
      'menu': menu.toJson(),
      'website': website.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppConfigV2.fromJson(Map<String, dynamic> json) {
    return AppConfigV2(
      appId: json['appId'] as String,
      restaurant: RestaurantConfig.fromJson(json['restaurant'] as Map<String, dynamic>),
      theme: ThemeConfigWhiteLabel.fromJson(json['theme'] as Map<String, dynamic>),
      modules: ModulesConfigWhiteLabel.fromJson(json['modules'] as Map<String, dynamic>),
      menu: MenuConfigWhiteLabel.fromJson(json['menu'] as Map<String, dynamic>),
      website: WebsiteConfig.fromJson(json['website'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Configuration du restaurant
class RestaurantConfig {
  final String name;
  final String description;
  final String logoUrl;
  final ContactInfo contact;
  final Address address;
  final OpeningHours openingHours;

  const RestaurantConfig({
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.contact,
    required this.address,
    required this.openingHours,
  });

  RestaurantConfig copyWith({
    String? name,
    String? description,
    String? logoUrl,
    ContactInfo? contact,
    Address? address,
    OpeningHours? openingHours,
  }) {
    return RestaurantConfig(
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      openingHours: openingHours ?? this.openingHours,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'contact': contact.toJson(),
      'address': address.toJson(),
      'openingHours': openingHours.toJson(),
    };
  }

  factory RestaurantConfig.fromJson(Map<String, dynamic> json) {
    return RestaurantConfig(
      name: json['name'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String,
      contact: ContactInfo.fromJson(json['contact'] as Map<String, dynamic>),
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      openingHours: OpeningHours.fromJson(json['openingHours'] as Map<String, dynamic>),
    );
  }
}

/// Informations de contact
class ContactInfo {
  final String phone;
  final String email;
  final String? website;

  const ContactInfo({
    required this.phone,
    required this.email,
    this.website,
  });

  ContactInfo copyWith({
    String? phone,
    String? email,
    String? website,
  }) {
    return ContactInfo(
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      if (website != null) 'website': website,
    };
  }

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'] as String,
      email: json['email'] as String,
      website: json['website'] as String?,
    );
  }
}

/// Adresse du restaurant
class Address {
  final String street;
  final String city;
  final String postalCode;
  final String country;

  const Address({
    required this.street,
    required this.city,
    required this.postalCode,
    required this.country,
  });

  Address copyWith({
    String? street,
    String? city,
    String? postalCode,
    String? country,
  }) {
    return Address(
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'postalCode': postalCode,
      'country': country,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
    );
  }
}

/// Horaires d'ouverture
class OpeningHours {
  final List<DaySchedule> schedule;
  final List<ClosedPeriod> closedPeriods;

  const OpeningHours({
    required this.schedule,
    required this.closedPeriods,
  });

  OpeningHours copyWith({
    List<DaySchedule>? schedule,
    List<ClosedPeriod>? closedPeriods,
  }) {
    return OpeningHours(
      schedule: schedule ?? this.schedule,
      closedPeriods: closedPeriods ?? this.closedPeriods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule': schedule.map((s) => s.toJson()).toList(),
      'closedPeriods': closedPeriods.map((p) => p.toJson()).toList(),
    };
  }

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      schedule: (json['schedule'] as List<dynamic>)
          .map((s) => DaySchedule.fromJson(s as Map<String, dynamic>))
          .toList(),
      closedPeriods: (json['closedPeriods'] as List<dynamic>)
          .map((p) => ClosedPeriod.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Horaire d'un jour
class DaySchedule {
  final int dayOfWeek; // 1 = Lundi, 7 = Dimanche
  final String openTime; // Format: "HH:mm"
  final String closeTime; // Format: "HH:mm"
  final bool closed;

  const DaySchedule({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.closed,
  });

  DaySchedule copyWith({
    int? dayOfWeek,
    String? openTime,
    String? closeTime,
    bool? closed,
  }) {
    return DaySchedule(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      closed: closed ?? this.closed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'openTime': openTime,
      'closeTime': closeTime,
      'closed': closed,
    };
  }

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      dayOfWeek: json['dayOfWeek'] as int,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
      closed: json['closed'] as bool,
    );
  }
}

/// Période de fermeture
class ClosedPeriod {
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  const ClosedPeriod({
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  ClosedPeriod copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
  }) {
    return ClosedPeriod(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
    };
  }

  factory ClosedPeriod.fromJson(Map<String, dynamic> json) {
    return ClosedPeriod(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      reason: json['reason'] as String,
    );
  }
}

/// Configuration du thème white-label
class ThemeConfigWhiteLabel {
  final ColorScheme colors;
  final Typography typography;
  final Spacing spacing;
  final BorderRadiusConfig borderRadius;

  const ThemeConfigWhiteLabel({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.borderRadius,
  });

  ThemeConfigWhiteLabel copyWith({
    ColorScheme? colors,
    Typography? typography,
    Spacing? spacing,
    BorderRadiusConfig? borderRadius,
  }) {
    return ThemeConfigWhiteLabel(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colors': colors.toJson(),
      'typography': typography.toJson(),
      'spacing': spacing.toJson(),
      'borderRadius': borderRadius.toJson(),
    };
  }

  factory ThemeConfigWhiteLabel.fromJson(Map<String, dynamic> json) {
    return ThemeConfigWhiteLabel(
      colors: ColorScheme.fromJson(json['colors'] as Map<String, dynamic>),
      typography: Typography.fromJson(json['typography'] as Map<String, dynamic>),
      spacing: Spacing.fromJson(json['spacing'] as Map<String, dynamic>),
      borderRadius: BorderRadiusConfig.fromJson(json['borderRadius'] as Map<String, dynamic>),
    );
  }
}

/// Schéma de couleurs
class ColorScheme {
  final String primary;
  final String secondary;
  final String accent;
  final String background;
  final String surface;
  final String error;
  final String textPrimary;
  final String textSecondary;

  const ColorScheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.error,
    required this.textPrimary,
    required this.textSecondary,
  });

  ColorScheme copyWith({
    String? primary,
    String? secondary,
    String? accent,
    String? background,
    String? surface,
    String? error,
    String? textPrimary,
    String? textSecondary,
  }) {
    return ColorScheme(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      error: error ?? this.error,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'accent': accent,
      'background': background,
      'surface': surface,
      'error': error,
      'textPrimary': textPrimary,
      'textSecondary': textSecondary,
    };
  }

  factory ColorScheme.fromJson(Map<String, dynamic> json) {
    return ColorScheme(
      primary: json['primary'] as String,
      secondary: json['secondary'] as String,
      accent: json['accent'] as String,
      background: json['background'] as String,
      surface: json['surface'] as String,
      error: json['error'] as String,
      textPrimary: json['textPrimary'] as String,
      textSecondary: json['textSecondary'] as String,
    );
  }
}

/// Configuration de la typographie
class Typography {
  final FontConfig heading1;
  final FontConfig heading2;
  final FontConfig heading3;
  final FontConfig body;
  final FontConfig caption;

  const Typography({
    required this.heading1,
    required this.heading2,
    required this.heading3,
    required this.body,
    required this.caption,
  });

  Typography copyWith({
    FontConfig? heading1,
    FontConfig? heading2,
    FontConfig? heading3,
    FontConfig? body,
    FontConfig? caption,
  }) {
    return Typography(
      heading1: heading1 ?? this.heading1,
      heading2: heading2 ?? this.heading2,
      heading3: heading3 ?? this.heading3,
      body: body ?? this.body,
      caption: caption ?? this.caption,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading1': heading1.toJson(),
      'heading2': heading2.toJson(),
      'heading3': heading3.toJson(),
      'body': body.toJson(),
      'caption': caption.toJson(),
    };
  }

  factory Typography.fromJson(Map<String, dynamic> json) {
    return Typography(
      heading1: FontConfig.fromJson(json['heading1'] as Map<String, dynamic>),
      heading2: FontConfig.fromJson(json['heading2'] as Map<String, dynamic>),
      heading3: FontConfig.fromJson(json['heading3'] as Map<String, dynamic>),
      body: FontConfig.fromJson(json['body'] as Map<String, dynamic>),
      caption: FontConfig.fromJson(json['caption'] as Map<String, dynamic>),
    );
  }
}

/// Configuration d'une police
class FontConfig {
  final String fontFamily;
  final double fontSize;
  final String fontWeight; // "normal", "bold", "100"-"900"
  final double lineHeight;
  final double letterSpacing;

  const FontConfig({
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.lineHeight,
    required this.letterSpacing,
  });

  FontConfig copyWith({
    String? fontFamily,
    double? fontSize,
    String? fontWeight,
    double? lineHeight,
    double? letterSpacing,
  }) {
    return FontConfig(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'fontWeight': fontWeight,
      'lineHeight': lineHeight,
      'letterSpacing': letterSpacing,
    };
  }

  factory FontConfig.fromJson(Map<String, dynamic> json) {
    return FontConfig(
      fontFamily: json['fontFamily'] as String,
      fontSize: (json['fontSize'] as num).toDouble(),
      fontWeight: json['fontWeight'] as String,
      lineHeight: (json['lineHeight'] as num).toDouble(),
      letterSpacing: (json['letterSpacing'] as num).toDouble(),
    );
  }
}

/// Configuration des espacements
class Spacing {
  final double small;
  final double medium;
  final double large;
  final double extraLarge;

  const Spacing({
    required this.small,
    required this.medium,
    required this.large,
    required this.extraLarge,
  });

  Spacing copyWith({
    double? small,
    double? medium,
    double? large,
    double? extraLarge,
  }) {
    return Spacing(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      extraLarge: extraLarge ?? this.extraLarge,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'small': small,
      'medium': medium,
      'large': large,
      'extraLarge': extraLarge,
    };
  }

  factory Spacing.fromJson(Map<String, dynamic> json) {
    return Spacing(
      small: (json['small'] as num).toDouble(),
      medium: (json['medium'] as num).toDouble(),
      large: (json['large'] as num).toDouble(),
      extraLarge: (json['extraLarge'] as num).toDouble(),
    );
  }
}

/// Configuration des border radius
class BorderRadiusConfig {
  final double small;
  final double medium;
  final double large;
  final double round;

  const BorderRadiusConfig({
    required this.small,
    required this.medium,
    required this.large,
    required this.round,
  });

  BorderRadiusConfig copyWith({
    double? small,
    double? medium,
    double? large,
    double? round,
  }) {
    return BorderRadiusConfig(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      round: round ?? this.round,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'small': small,
      'medium': medium,
      'large': large,
      'round': round,
    };
  }

  factory BorderRadiusConfig.fromJson(Map<String, dynamic> json) {
    return BorderRadiusConfig(
      small: (json['small'] as num).toDouble(),
      medium: (json['medium'] as num).toDouble(),
      large: (json['large'] as num).toDouble(),
      round: (json['round'] as num).toDouble(),
    );
  }
}

/// Configuration des modules white-label
class ModulesConfigWhiteLabel {
  final DeliveryModuleConfig delivery;
  final CashierModuleConfig cashier;
  final AccountingModuleConfig accounting;
  final LoyaltyModuleConfig loyalty;
  final KitchenModuleConfig kitchen;

  const ModulesConfigWhiteLabel({
    required this.delivery,
    required this.cashier,
    required this.accounting,
    required this.loyalty,
    required this.kitchen,
  });

  ModulesConfigWhiteLabel copyWith({
    DeliveryModuleConfig? delivery,
    CashierModuleConfig? cashier,
    AccountingModuleConfig? accounting,
    LoyaltyModuleConfig? loyalty,
    KitchenModuleConfig? kitchen,
  }) {
    return ModulesConfigWhiteLabel(
      delivery: delivery ?? this.delivery,
      cashier: cashier ?? this.cashier,
      accounting: accounting ?? this.accounting,
      loyalty: loyalty ?? this.loyalty,
      kitchen: kitchen ?? this.kitchen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delivery': delivery.toJson(),
      'cashier': cashier.toJson(),
      'accounting': accounting.toJson(),
      'loyalty': loyalty.toJson(),
      'kitchen': kitchen.toJson(),
    };
  }

  factory ModulesConfigWhiteLabel.fromJson(Map<String, dynamic> json) {
    return ModulesConfigWhiteLabel(
      delivery: DeliveryModuleConfig.fromJson(json['delivery'] as Map<String, dynamic>),
      cashier: CashierModuleConfig.fromJson(json['cashier'] as Map<String, dynamic>),
      accounting: AccountingModuleConfig.fromJson(json['accounting'] as Map<String, dynamic>),
      loyalty: LoyaltyModuleConfig.fromJson(json['loyalty'] as Map<String, dynamic>),
      kitchen: KitchenModuleConfig.fromJson(json['kitchen'] as Map<String, dynamic>),
    );
  }
}

/// Configuration du module de livraison
class DeliveryModuleConfig {
  final bool enabled;
  final double minimumOrderAmount;
  final double deliveryFee;
  final double freeDeliveryThreshold;
  final List<String> deliveryZones;

  const DeliveryModuleConfig({
    required this.enabled,
    required this.minimumOrderAmount,
    required this.deliveryFee,
    required this.freeDeliveryThreshold,
    required this.deliveryZones,
  });

  DeliveryModuleConfig copyWith({
    bool? enabled,
    double? minimumOrderAmount,
    double? deliveryFee,
    double? freeDeliveryThreshold,
    List<String>? deliveryZones,
  }) {
    return DeliveryModuleConfig(
      enabled: enabled ?? this.enabled,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      freeDeliveryThreshold: freeDeliveryThreshold ?? this.freeDeliveryThreshold,
      deliveryZones: deliveryZones ?? this.deliveryZones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'minimumOrderAmount': minimumOrderAmount,
      'deliveryFee': deliveryFee,
      'freeDeliveryThreshold': freeDeliveryThreshold,
      'deliveryZones': deliveryZones,
    };
  }

  factory DeliveryModuleConfig.fromJson(Map<String, dynamic> json) {
    return DeliveryModuleConfig(
      enabled: json['enabled'] as bool,
      minimumOrderAmount: (json['minimumOrderAmount'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      freeDeliveryThreshold: (json['freeDeliveryThreshold'] as num).toDouble(),
      deliveryZones: (json['deliveryZones'] as List<dynamic>).cast<String>(),
    );
  }
}

/// Configuration du module de caisse
class CashierModuleConfig {
  final bool enabled;
  final bool allowCashPayment;
  final bool allowCardPayment;
  final bool allowDigitalPayment;
  final bool printReceipts;

  const CashierModuleConfig({
    required this.enabled,
    required this.allowCashPayment,
    required this.allowCardPayment,
    required this.allowDigitalPayment,
    required this.printReceipts,
  });

  CashierModuleConfig copyWith({
    bool? enabled,
    bool? allowCashPayment,
    bool? allowCardPayment,
    bool? allowDigitalPayment,
    bool? printReceipts,
  }) {
    return CashierModuleConfig(
      enabled: enabled ?? this.enabled,
      allowCashPayment: allowCashPayment ?? this.allowCashPayment,
      allowCardPayment: allowCardPayment ?? this.allowCardPayment,
      allowDigitalPayment: allowDigitalPayment ?? this.allowDigitalPayment,
      printReceipts: printReceipts ?? this.printReceipts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'allowCashPayment': allowCashPayment,
      'allowCardPayment': allowCardPayment,
      'allowDigitalPayment': allowDigitalPayment,
      'printReceipts': printReceipts,
    };
  }

  factory CashierModuleConfig.fromJson(Map<String, dynamic> json) {
    return CashierModuleConfig(
      enabled: json['enabled'] as bool,
      allowCashPayment: json['allowCashPayment'] as bool,
      allowCardPayment: json['allowCardPayment'] as bool,
      allowDigitalPayment: json['allowDigitalPayment'] as bool,
      printReceipts: json['printReceipts'] as bool,
    );
  }
}

/// Configuration du module de comptabilité
class AccountingModuleConfig {
  final bool enabled;
  final String currency;
  final String taxRate;
  final bool trackExpenses;
  final bool generateReports;

  const AccountingModuleConfig({
    required this.enabled,
    required this.currency,
    required this.taxRate,
    required this.trackExpenses,
    required this.generateReports,
  });

  AccountingModuleConfig copyWith({
    bool? enabled,
    String? currency,
    String? taxRate,
    bool? trackExpenses,
    bool? generateReports,
  }) {
    return AccountingModuleConfig(
      enabled: enabled ?? this.enabled,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      trackExpenses: trackExpenses ?? this.trackExpenses,
      generateReports: generateReports ?? this.generateReports,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'currency': currency,
      'taxRate': taxRate,
      'trackExpenses': trackExpenses,
      'generateReports': generateReports,
    };
  }

  factory AccountingModuleConfig.fromJson(Map<String, dynamic> json) {
    return AccountingModuleConfig(
      enabled: json['enabled'] as bool,
      currency: json['currency'] as String,
      taxRate: json['taxRate'] as String,
      trackExpenses: json['trackExpenses'] as bool,
      generateReports: json['generateReports'] as bool,
    );
  }
}

/// Configuration du module de fidélité
class LoyaltyModuleConfig {
  final bool enabled;
  final int pointsPerEuro;
  final int pointsForReward;
  final List<LoyaltyReward> rewards;

  const LoyaltyModuleConfig({
    required this.enabled,
    required this.pointsPerEuro,
    required this.pointsForReward,
    required this.rewards,
  });

  LoyaltyModuleConfig copyWith({
    bool? enabled,
    int? pointsPerEuro,
    int? pointsForReward,
    List<LoyaltyReward>? rewards,
  }) {
    return LoyaltyModuleConfig(
      enabled: enabled ?? this.enabled,
      pointsPerEuro: pointsPerEuro ?? this.pointsPerEuro,
      pointsForReward: pointsForReward ?? this.pointsForReward,
      rewards: rewards ?? this.rewards,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'pointsPerEuro': pointsPerEuro,
      'pointsForReward': pointsForReward,
      'rewards': rewards.map((r) => r.toJson()).toList(),
    };
  }

  factory LoyaltyModuleConfig.fromJson(Map<String, dynamic> json) {
    return LoyaltyModuleConfig(
      enabled: json['enabled'] as bool,
      pointsPerEuro: json['pointsPerEuro'] as int,
      pointsForReward: json['pointsForReward'] as int,
      rewards: (json['rewards'] as List<dynamic>)
          .map((r) => LoyaltyReward.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Récompense de fidélité
class LoyaltyReward {
  final String id;
  final String name;
  final String description;
  final int pointsCost;
  final String type; // "discount", "free_item", "special_offer"

  const LoyaltyReward({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    required this.type,
  });

  LoyaltyReward copyWith({
    String? id,
    String? name,
    String? description,
    int? pointsCost,
    String? type,
  }) {
    return LoyaltyReward(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pointsCost: pointsCost ?? this.pointsCost,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsCost': pointsCost,
      'type': type,
    };
  }

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    return LoyaltyReward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      pointsCost: json['pointsCost'] as int,
      type: json['type'] as String,
    );
  }
}

/// Configuration du module de cuisine
class KitchenModuleConfig {
  final bool enabled;
  final bool showOrderQueue;
  final bool enableSoundAlerts;
  final int defaultPreparationTime;
  final List<String> printerNames;

  const KitchenModuleConfig({
    required this.enabled,
    required this.showOrderQueue,
    required this.enableSoundAlerts,
    required this.defaultPreparationTime,
    required this.printerNames,
  });

  KitchenModuleConfig copyWith({
    bool? enabled,
    bool? showOrderQueue,
    bool? enableSoundAlerts,
    int? defaultPreparationTime,
    List<String>? printerNames,
  }) {
    return KitchenModuleConfig(
      enabled: enabled ?? this.enabled,
      showOrderQueue: showOrderQueue ?? this.showOrderQueue,
      enableSoundAlerts: enableSoundAlerts ?? this.enableSoundAlerts,
      defaultPreparationTime: defaultPreparationTime ?? this.defaultPreparationTime,
      printerNames: printerNames ?? this.printerNames,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'showOrderQueue': showOrderQueue,
      'enableSoundAlerts': enableSoundAlerts,
      'defaultPreparationTime': defaultPreparationTime,
      'printerNames': printerNames,
    };
  }

  factory KitchenModuleConfig.fromJson(Map<String, dynamic> json) {
    return KitchenModuleConfig(
      enabled: json['enabled'] as bool,
      showOrderQueue: json['showOrderQueue'] as bool,
      enableSoundAlerts: json['enableSoundAlerts'] as bool,
      defaultPreparationTime: json['defaultPreparationTime'] as int,
      printerNames: (json['printerNames'] as List<dynamic>).cast<String>(),
    );
  }
}

/// Configuration du menu
class MenuConfigWhiteLabel {
  final List<MenuCategory> categories;
  final MenuDisplay display;
  final MenuFilters filters;

  const MenuConfigWhiteLabel({
    required this.categories,
    required this.display,
    required this.filters,
  });

  MenuConfigWhiteLabel copyWith({
    List<MenuCategory>? categories,
    MenuDisplay? display,
    MenuFilters? filters,
  }) {
    return MenuConfigWhiteLabel(
      categories: categories ?? this.categories,
      display: display ?? this.display,
      filters: filters ?? this.filters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((c) => c.toJson()).toList(),
      'display': display.toJson(),
      'filters': filters.toJson(),
    };
  }

  factory MenuConfigWhiteLabel.fromJson(Map<String, dynamic> json) {
    return MenuConfigWhiteLabel(
      categories: (json['categories'] as List<dynamic>)
          .map((c) => MenuCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      display: MenuDisplay.fromJson(json['display'] as Map<String, dynamic>),
      filters: MenuFilters.fromJson(json['filters'] as Map<String, dynamic>),
    );
  }
}

/// Catégorie du menu
class MenuCategory {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int order;
  final bool visible;

  const MenuCategory({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.order,
    required this.visible,
  });

  MenuCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? order,
    bool? visible,
  }) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      visible: visible ?? this.visible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'order': order,
      'visible': visible,
    };
  }

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      order: json['order'] as int,
      visible: json['visible'] as bool,
    );
  }
}

/// Affichage du menu
class MenuDisplay {
  final String layout; // "grid", "list", "carousel"
  final int itemsPerRow;
  final bool showImages;
  final bool showPrices;
  final bool showDescriptions;

  const MenuDisplay({
    required this.layout,
    required this.itemsPerRow,
    required this.showImages,
    required this.showPrices,
    required this.showDescriptions,
  });

  MenuDisplay copyWith({
    String? layout,
    int? itemsPerRow,
    bool? showImages,
    bool? showPrices,
    bool? showDescriptions,
  }) {
    return MenuDisplay(
      layout: layout ?? this.layout,
      itemsPerRow: itemsPerRow ?? this.itemsPerRow,
      showImages: showImages ?? this.showImages,
      showPrices: showPrices ?? this.showPrices,
      showDescriptions: showDescriptions ?? this.showDescriptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'layout': layout,
      'itemsPerRow': itemsPerRow,
      'showImages': showImages,
      'showPrices': showPrices,
      'showDescriptions': showDescriptions,
    };
  }

  factory MenuDisplay.fromJson(Map<String, dynamic> json) {
    return MenuDisplay(
      layout: json['layout'] as String,
      itemsPerRow: json['itemsPerRow'] as int,
      showImages: json['showImages'] as bool,
      showPrices: json['showPrices'] as bool,
      showDescriptions: json['showDescriptions'] as bool,
    );
  }
}

/// Filtres du menu
class MenuFilters {
  final bool enableSearch;
  final bool enableCategoryFilter;
  final bool enablePriceFilter;
  final List<String> dietaryFilters; // "vegetarian", "vegan", "gluten_free", etc.

  const MenuFilters({
    required this.enableSearch,
    required this.enableCategoryFilter,
    required this.enablePriceFilter,
    required this.dietaryFilters,
  });

  MenuFilters copyWith({
    bool? enableSearch,
    bool? enableCategoryFilter,
    bool? enablePriceFilter,
    List<String>? dietaryFilters,
  }) {
    return MenuFilters(
      enableSearch: enableSearch ?? this.enableSearch,
      enableCategoryFilter: enableCategoryFilter ?? this.enableCategoryFilter,
      enablePriceFilter: enablePriceFilter ?? this.enablePriceFilter,
      dietaryFilters: dietaryFilters ?? this.dietaryFilters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableSearch': enableSearch,
      'enableCategoryFilter': enableCategoryFilter,
      'enablePriceFilter': enablePriceFilter,
      'dietaryFilters': dietaryFilters,
    };
  }

  factory MenuFilters.fromJson(Map<String, dynamic> json) {
    return MenuFilters(
      enableSearch: json['enableSearch'] as bool,
      enableCategoryFilter: json['enableCategoryFilter'] as bool,
      enablePriceFilter: json['enablePriceFilter'] as bool,
      dietaryFilters: (json['dietaryFilters'] as List<dynamic>).cast<String>(),
    );
  }
}

/// Configuration du site vitrine
class WebsiteConfig {
  final bool enabled;
  final String domain;
  final SeoConfig seo;
  final List<WebsitePage> pages;
  final SocialMediaLinks socialMedia;

  const WebsiteConfig({
    required this.enabled,
    required this.domain,
    required this.seo,
    required this.pages,
    required this.socialMedia,
  });

  WebsiteConfig copyWith({
    bool? enabled,
    String? domain,
    SeoConfig? seo,
    List<WebsitePage>? pages,
    SocialMediaLinks? socialMedia,
  }) {
    return WebsiteConfig(
      enabled: enabled ?? this.enabled,
      domain: domain ?? this.domain,
      seo: seo ?? this.seo,
      pages: pages ?? this.pages,
      socialMedia: socialMedia ?? this.socialMedia,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'domain': domain,
      'seo': seo.toJson(),
      'pages': pages.map((p) => p.toJson()).toList(),
      'socialMedia': socialMedia.toJson(),
    };
  }

  factory WebsiteConfig.fromJson(Map<String, dynamic> json) {
    return WebsiteConfig(
      enabled: json['enabled'] as bool,
      domain: json['domain'] as String,
      seo: SeoConfig.fromJson(json['seo'] as Map<String, dynamic>),
      pages: (json['pages'] as List<dynamic>)
          .map((p) => WebsitePage.fromJson(p as Map<String, dynamic>))
          .toList(),
      socialMedia: SocialMediaLinks.fromJson(json['socialMedia'] as Map<String, dynamic>),
    );
  }
}

/// Configuration SEO
class SeoConfig {
  final String title;
  final String description;
  final List<String> keywords;
  final String ogImage;

  const SeoConfig({
    required this.title,
    required this.description,
    required this.keywords,
    required this.ogImage,
  });

  SeoConfig copyWith({
    String? title,
    String? description,
    List<String>? keywords,
    String? ogImage,
  }) {
    return SeoConfig(
      title: title ?? this.title,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      ogImage: ogImage ?? this.ogImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'keywords': keywords,
      'ogImage': ogImage,
    };
  }

  factory SeoConfig.fromJson(Map<String, dynamic> json) {
    return SeoConfig(
      title: json['title'] as String,
      description: json['description'] as String,
      keywords: (json['keywords'] as List<dynamic>).cast<String>(),
      ogImage: json['ogImage'] as String,
    );
  }
}

/// Page du site vitrine
class WebsitePage {
  final String id;
  final String path;
  final String title;
  final String content;
  final bool visible;

  const WebsitePage({
    required this.id,
    required this.path,
    required this.title,
    required this.content,
    required this.visible,
  });

  WebsitePage copyWith({
    String? id,
    String? path,
    String? title,
    String? content,
    bool? visible,
  }) {
    return WebsitePage(
      id: id ?? this.id,
      path: path ?? this.path,
      title: title ?? this.title,
      content: content ?? this.content,
      visible: visible ?? this.visible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'title': title,
      'content': content,
      'visible': visible,
    };
  }

  factory WebsitePage.fromJson(Map<String, dynamic> json) {
    return WebsitePage(
      id: json['id'] as String,
      path: json['path'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      visible: json['visible'] as bool,
    );
  }
}

/// Liens des réseaux sociaux
class SocialMediaLinks {
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final String? tiktok;

  const SocialMediaLinks({
    this.facebook,
    this.instagram,
    this.twitter,
    this.tiktok,
  });

  SocialMediaLinks copyWith({
    String? facebook,
    String? instagram,
    String? twitter,
    String? tiktok,
  }) {
    return SocialMediaLinks(
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      tiktok: tiktok ?? this.tiktok,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (facebook != null) 'facebook': facebook,
      if (instagram != null) 'instagram': instagram,
      if (twitter != null) 'twitter': twitter,
      if (tiktok != null) 'tiktok': tiktok,
    };
  }

  factory SocialMediaLinks.fromJson(Map<String, dynamic> json) {
    return SocialMediaLinks(
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      twitter: json['twitter'] as String?,
      tiktok: json['tiktok'] as String?,
    );
  }
}
