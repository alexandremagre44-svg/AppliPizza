// lib/src/models/app_texts_config.dart
// Configuration for customizable app texts and messages

class AppTextsConfig {
  final String id;
  final GeneralTexts general;
  final OrderMessages orderMessages;
  final ErrorMessages errorMessages;
  final LoyaltyTexts loyaltyTexts;
  final ProfileTexts profileTexts;
  final RewardsTexts rewardsTexts;
  final RouletteTexts rouletteTexts;
  final DateTime updatedAt;

  AppTextsConfig({
    required this.id,
    required this.general,
    required this.orderMessages,
    required this.errorMessages,
    required this.loyaltyTexts,
    required this.profileTexts,
    required this.rewardsTexts,
    required this.rouletteTexts,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'general': general.toJson(),
      'orderMessages': orderMessages.toJson(),
      'errorMessages': errorMessages.toJson(),
      'loyaltyTexts': loyaltyTexts.toJson(),
      'profileTexts': profileTexts.toJson(),
      'rewardsTexts': rewardsTexts.toJson(),
      'rouletteTexts': rouletteTexts.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppTextsConfig.fromJson(Map<String, dynamic> json) {
    return AppTextsConfig(
      id: json['id'] as String,
      general: GeneralTexts.fromJson(json['general'] as Map<String, dynamic>),
      orderMessages: OrderMessages.fromJson(json['orderMessages'] as Map<String, dynamic>),
      errorMessages: ErrorMessages.fromJson(json['errorMessages'] as Map<String, dynamic>),
      loyaltyTexts: LoyaltyTexts.fromJson(json['loyaltyTexts'] as Map<String, dynamic>),
      profileTexts: ProfileTexts.fromJson(json['profileTexts'] as Map<String, dynamic>? ?? {}),
      rewardsTexts: RewardsTexts.fromJson(json['rewardsTexts'] as Map<String, dynamic>? ?? {}),
      rouletteTexts: RouletteTexts.fromJson(json['rouletteTexts'] as Map<String, dynamic>? ?? {}),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  AppTextsConfig copyWith({
    String? id,
    GeneralTexts? general,
    OrderMessages? orderMessages,
    ErrorMessages? errorMessages,
    LoyaltyTexts? loyaltyTexts,
    ProfileTexts? profileTexts,
    RewardsTexts? rewardsTexts,
    RouletteTexts? rouletteTexts,
    DateTime? updatedAt,
  }) {
    return AppTextsConfig(
      id: id ?? this.id,
      general: general ?? this.general,
      orderMessages: orderMessages ?? this.orderMessages,
      errorMessages: errorMessages ?? this.errorMessages,
      loyaltyTexts: loyaltyTexts ?? this.loyaltyTexts,
      profileTexts: profileTexts ?? this.profileTexts,
      rewardsTexts: rewardsTexts ?? this.rewardsTexts,
      rouletteTexts: rouletteTexts ?? this.rouletteTexts,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppTextsConfig.defaultConfig() {
    return AppTextsConfig(
      id: 'default',
      general: GeneralTexts.defaultTexts(),
      orderMessages: OrderMessages.defaultMessages(),
      errorMessages: ErrorMessages.defaultMessages(),
      loyaltyTexts: LoyaltyTexts.defaultTexts(),
      profileTexts: ProfileTexts.defaultTexts(),
      rewardsTexts: RewardsTexts.defaultTexts(),
      rouletteTexts: RouletteTexts.defaultTexts(),
      updatedAt: DateTime.now(),
    );
  }
}

// General section texts
class GeneralTexts {
  final String appName;
  final String slogan;
  final String homeIntro;

  GeneralTexts({
    required this.appName,
    required this.slogan,
    required this.homeIntro,
  });

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'slogan': slogan,
      'homeIntro': homeIntro,
    };
  }

  factory GeneralTexts.fromJson(Map<String, dynamic> json) {
    return GeneralTexts(
      appName: json['appName'] as String? ?? 'Pizza Deli\'Zza',
      slogan: json['slogan'] as String? ?? 'La meilleure pizza à emporter',
      homeIntro: json['homeIntro'] as String? ?? 'Découvrez nos pizzas artisanales',
    );
  }

  factory GeneralTexts.defaultTexts() {
    return GeneralTexts(
      appName: 'Pizza Deli\'Zza',
      slogan: 'La meilleure pizza à emporter',
      homeIntro: 'Découvrez nos pizzas artisanales',
    );
  }

  GeneralTexts copyWith({
    String? appName,
    String? slogan,
    String? homeIntro,
  }) {
    return GeneralTexts(
      appName: appName ?? this.appName,
      slogan: slogan ?? this.slogan,
      homeIntro: homeIntro ?? this.homeIntro,
    );
  }
}

// Order-related messages
class OrderMessages {
  final String successMessage;
  final String failureMessage;
  final String noSlotsMessage;

  OrderMessages({
    required this.successMessage,
    required this.failureMessage,
    required this.noSlotsMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'successMessage': successMessage,
      'failureMessage': failureMessage,
      'noSlotsMessage': noSlotsMessage,
    };
  }

  factory OrderMessages.fromJson(Map<String, dynamic> json) {
    return OrderMessages(
      successMessage: json['successMessage'] as String? ??
          'Votre commande a été validée avec succès !',
      failureMessage: json['failureMessage'] as String? ??
          'Une erreur est survenue lors de la commande.',
      noSlotsMessage: json['noSlotsMessage'] as String? ??
          'Aucun créneau disponible pour le moment.',
    );
  }

  factory OrderMessages.defaultMessages() {
    return OrderMessages(
      successMessage: 'Votre commande a été validée avec succès !',
      failureMessage: 'Une erreur est survenue lors de la commande.',
      noSlotsMessage: 'Aucun créneau disponible pour le moment.',
    );
  }

  OrderMessages copyWith({
    String? successMessage,
    String? failureMessage,
    String? noSlotsMessage,
  }) {
    return OrderMessages(
      successMessage: successMessage ?? this.successMessage,
      failureMessage: failureMessage ?? this.failureMessage,
      noSlotsMessage: noSlotsMessage ?? this.noSlotsMessage,
    );
  }
}

// Error messages
class ErrorMessages {
  final String networkError;
  final String serverError;
  final String sessionExpired;

  ErrorMessages({
    required this.networkError,
    required this.serverError,
    required this.sessionExpired,
  });

  Map<String, dynamic> toJson() {
    return {
      'networkError': networkError,
      'serverError': serverError,
      'sessionExpired': sessionExpired,
    };
  }

  factory ErrorMessages.fromJson(Map<String, dynamic> json) {
    return ErrorMessages(
      networkError: json['networkError'] as String? ??
          'Erreur de connexion. Vérifiez votre réseau.',
      serverError: json['serverError'] as String? ??
          'Erreur serveur. Réessayez plus tard.',
      sessionExpired: json['sessionExpired'] as String? ??
          'Votre session a expiré. Reconnectez-vous.',
    );
  }

  factory ErrorMessages.defaultMessages() {
    return ErrorMessages(
      networkError: 'Erreur de connexion. Vérifiez votre réseau.',
      serverError: 'Erreur serveur. Réessayez plus tard.',
      sessionExpired: 'Votre session a expiré. Reconnectez-vous.',
    );
  }

  ErrorMessages copyWith({
    String? networkError,
    String? serverError,
    String? sessionExpired,
  }) {
    return ErrorMessages(
      networkError: networkError ?? this.networkError,
      serverError: serverError ?? this.serverError,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}

// Loyalty program texts
class LoyaltyTexts {
  final String rewardMessage;
  final String programExplanation;
  final String bronzeLevelText;
  final String silverLevelText;
  final String goldLevelText;

  LoyaltyTexts({
    required this.rewardMessage,
    required this.programExplanation,
    required this.bronzeLevelText,
    required this.silverLevelText,
    required this.goldLevelText,
  });

  Map<String, dynamic> toJson() {
    return {
      'rewardMessage': rewardMessage,
      'programExplanation': programExplanation,
      'bronzeLevelText': bronzeLevelText,
      'silverLevelText': silverLevelText,
      'goldLevelText': goldLevelText,
    };
  }

  factory LoyaltyTexts.fromJson(Map<String, dynamic> json) {
    return LoyaltyTexts(
      rewardMessage: json['rewardMessage'] as String? ??
          'Bravo ! Vous avez gagné {points} points !',
      programExplanation: json['programExplanation'] as String? ??
          'Gagnez 1 point par euro dépensé',
      bronzeLevelText: json['bronzeLevelText'] as String? ?? 'Niveau Bronze',
      silverLevelText: json['silverLevelText'] as String? ?? 'Niveau Silver',
      goldLevelText: json['goldLevelText'] as String? ?? 'Niveau Gold',
    );
  }

  factory LoyaltyTexts.defaultTexts() {
    return LoyaltyTexts(
      rewardMessage: 'Bravo ! Vous avez gagné {points} points !',
      programExplanation: 'Gagnez 1 point par euro dépensé',
      bronzeLevelText: 'Niveau Bronze',
      silverLevelText: 'Niveau Silver',
      goldLevelText: 'Niveau Gold',
    );
  }

  LoyaltyTexts copyWith({
    String? rewardMessage,
    String? programExplanation,
    String? bronzeLevelText,
    String? silverLevelText,
    String? goldLevelText,
  }) {
    return LoyaltyTexts(
      rewardMessage: rewardMessage ?? this.rewardMessage,
      programExplanation: programExplanation ?? this.programExplanation,
      bronzeLevelText: bronzeLevelText ?? this.bronzeLevelText,
      silverLevelText: silverLevelText ?? this.silverLevelText,
      goldLevelText: goldLevelText ?? this.goldLevelText,
    );
  }
}

// Profile section texts
class ProfileTexts {
  final String loyaltySectionTitle;
  final String loyaltySectionPoints;
  final String loyaltySectionProgress;
  final String loyaltySectionPointsNeeded;
  final String loyaltySectionViewRewards;
  final String rewardsSectionTitle;
  final String rewardsSectionViewAll;
  final String rewardsSectionEmpty;
  final String rouletteSectionTitle;
  final String rouletteSectionDescription;
  final String rouletteSectionButton;
  final String activitySectionMyOrders;
  final String activitySectionMyFavorites;

  ProfileTexts({
    required this.loyaltySectionTitle,
    required this.loyaltySectionPoints,
    required this.loyaltySectionProgress,
    required this.loyaltySectionPointsNeeded,
    required this.loyaltySectionViewRewards,
    required this.rewardsSectionTitle,
    required this.rewardsSectionViewAll,
    required this.rewardsSectionEmpty,
    required this.rouletteSectionTitle,
    required this.rouletteSectionDescription,
    required this.rouletteSectionButton,
    required this.activitySectionMyOrders,
    required this.activitySectionMyFavorites,
  });

  Map<String, dynamic> toJson() {
    return {
      'loyaltySectionTitle': loyaltySectionTitle,
      'loyaltySectionPoints': loyaltySectionPoints,
      'loyaltySectionProgress': loyaltySectionProgress,
      'loyaltySectionPointsNeeded': loyaltySectionPointsNeeded,
      'loyaltySectionViewRewards': loyaltySectionViewRewards,
      'rewardsSectionTitle': rewardsSectionTitle,
      'rewardsSectionViewAll': rewardsSectionViewAll,
      'rewardsSectionEmpty': rewardsSectionEmpty,
      'rouletteSectionTitle': rouletteSectionTitle,
      'rouletteSectionDescription': rouletteSectionDescription,
      'rouletteSectionButton': rouletteSectionButton,
      'activitySectionMyOrders': activitySectionMyOrders,
      'activitySectionMyFavorites': activitySectionMyFavorites,
    };
  }

  factory ProfileTexts.fromJson(Map<String, dynamic> json) {
    return ProfileTexts(
      loyaltySectionTitle: json['loyaltySectionTitle'] as String? ?? 'Programme de Fidélité',
      loyaltySectionPoints: json['loyaltySectionPoints'] as String? ?? 'Points Fidélité',
      loyaltySectionProgress: json['loyaltySectionProgress'] as String? ?? 'Progression vers une pizza gratuite',
      loyaltySectionPointsNeeded: json['loyaltySectionPointsNeeded'] as String? ?? 'Plus que {points} points',
      loyaltySectionViewRewards: json['loyaltySectionViewRewards'] as String? ?? 'Voir mes récompenses fidélité',
      rewardsSectionTitle: json['rewardsSectionTitle'] as String? ?? 'Mes récompenses',
      rewardsSectionViewAll: json['rewardsSectionViewAll'] as String? ?? 'Voir toutes les récompenses',
      rewardsSectionEmpty: json['rewardsSectionEmpty'] as String? ?? 'Aucune récompense disponible',
      rouletteSectionTitle: json['rouletteSectionTitle'] as String? ?? 'Roue de la Chance',
      rouletteSectionDescription: json['rouletteSectionDescription'] as String? ?? 'Tentez votre chance et gagnez des récompenses !',
      rouletteSectionButton: json['rouletteSectionButton'] as String? ?? 'Tourner la roue',
      activitySectionMyOrders: json['activitySectionMyOrders'] as String? ?? 'Mes commandes',
      activitySectionMyFavorites: json['activitySectionMyFavorites'] as String? ?? 'Mes favoris',
    );
  }

  factory ProfileTexts.defaultTexts() {
    return ProfileTexts(
      loyaltySectionTitle: 'Programme de Fidélité',
      loyaltySectionPoints: 'Points Fidélité',
      loyaltySectionProgress: 'Progression vers une pizza gratuite',
      loyaltySectionPointsNeeded: 'Plus que {points} points',
      loyaltySectionViewRewards: 'Voir mes récompenses fidélité',
      rewardsSectionTitle: 'Mes récompenses',
      rewardsSectionViewAll: 'Voir toutes les récompenses',
      rewardsSectionEmpty: 'Aucune récompense disponible',
      rouletteSectionTitle: 'Roue de la Chance',
      rouletteSectionDescription: 'Tentez votre chance et gagnez des récompenses !',
      rouletteSectionButton: 'Tourner la roue',
      activitySectionMyOrders: 'Mes commandes',
      activitySectionMyFavorites: 'Mes favoris',
    );
  }

  ProfileTexts copyWith({
    String? loyaltySectionTitle,
    String? loyaltySectionPoints,
    String? loyaltySectionProgress,
    String? loyaltySectionPointsNeeded,
    String? loyaltySectionViewRewards,
    String? rewardsSectionTitle,
    String? rewardsSectionViewAll,
    String? rewardsSectionEmpty,
    String? rouletteSectionTitle,
    String? rouletteSectionDescription,
    String? rouletteSectionButton,
    String? activitySectionMyOrders,
    String? activitySectionMyFavorites,
  }) {
    return ProfileTexts(
      loyaltySectionTitle: loyaltySectionTitle ?? this.loyaltySectionTitle,
      loyaltySectionPoints: loyaltySectionPoints ?? this.loyaltySectionPoints,
      loyaltySectionProgress: loyaltySectionProgress ?? this.loyaltySectionProgress,
      loyaltySectionPointsNeeded: loyaltySectionPointsNeeded ?? this.loyaltySectionPointsNeeded,
      loyaltySectionViewRewards: loyaltySectionViewRewards ?? this.loyaltySectionViewRewards,
      rewardsSectionTitle: rewardsSectionTitle ?? this.rewardsSectionTitle,
      rewardsSectionViewAll: rewardsSectionViewAll ?? this.rewardsSectionViewAll,
      rewardsSectionEmpty: rewardsSectionEmpty ?? this.rewardsSectionEmpty,
      rouletteSectionTitle: rouletteSectionTitle ?? this.rouletteSectionTitle,
      rouletteSectionDescription: rouletteSectionDescription ?? this.rouletteSectionDescription,
      rouletteSectionButton: rouletteSectionButton ?? this.rouletteSectionButton,
      activitySectionMyOrders: activitySectionMyOrders ?? this.activitySectionMyOrders,
      activitySectionMyFavorites: activitySectionMyFavorites ?? this.activitySectionMyFavorites,
    );
  }
}

// Rewards section texts
class RewardsTexts {
  final String ticketExpiresOn;
  final String ticketExpired;
  final String ticketUsed;
  final String ticketActive;

  RewardsTexts({
    required this.ticketExpiresOn,
    required this.ticketExpired,
    required this.ticketUsed,
    required this.ticketActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'ticketExpiresOn': ticketExpiresOn,
      'ticketExpired': ticketExpired,
      'ticketUsed': ticketUsed,
      'ticketActive': ticketActive,
    };
  }

  factory RewardsTexts.fromJson(Map<String, dynamic> json) {
    return RewardsTexts(
      ticketExpiresOn: json['ticketExpiresOn'] as String? ?? 'Expire le {date}',
      ticketExpired: json['ticketExpired'] as String? ?? 'Expiré',
      ticketUsed: json['ticketUsed'] as String? ?? 'Utilisé',
      ticketActive: json['ticketActive'] as String? ?? 'Actif',
    );
  }

  factory RewardsTexts.defaultTexts() {
    return RewardsTexts(
      ticketExpiresOn: 'Expire le {date}',
      ticketExpired: 'Expiré',
      ticketUsed: 'Utilisé',
      ticketActive: 'Actif',
    );
  }

  RewardsTexts copyWith({
    String? ticketExpiresOn,
    String? ticketExpired,
    String? ticketUsed,
    String? ticketActive,
  }) {
    return RewardsTexts(
      ticketExpiresOn: ticketExpiresOn ?? this.ticketExpiresOn,
      ticketExpired: ticketExpired ?? this.ticketExpired,
      ticketUsed: ticketUsed ?? this.ticketUsed,
      ticketActive: ticketActive ?? this.ticketActive,
    );
  }
}

// Roulette section texts
class RouletteTexts {
  final String playTitle;
  final String playDescription;
  final String playButton;
  final String noSpinsAvailable;
  final String spinsRemaining;

  RouletteTexts({
    required this.playTitle,
    required this.playDescription,
    required this.playButton,
    required this.noSpinsAvailable,
    required this.spinsRemaining,
  });

  Map<String, dynamic> toJson() {
    return {
      'playTitle': playTitle,
      'playDescription': playDescription,
      'playButton': playButton,
      'noSpinsAvailable': noSpinsAvailable,
      'spinsRemaining': spinsRemaining,
    };
  }

  factory RouletteTexts.fromJson(Map<String, dynamic> json) {
    return RouletteTexts(
      playTitle: json['playTitle'] as String? ?? 'Roue de la Chance',
      playDescription: json['playDescription'] as String? ?? 'Tentez votre chance chaque jour !',
      playButton: json['playButton'] as String? ?? 'Tourner la roue',
      noSpinsAvailable: json['noSpinsAvailable'] as String? ?? 'Aucun tour disponible',
      spinsRemaining: json['spinsRemaining'] as String? ?? '{count} tour(s) disponible(s)',
    );
  }

  factory RouletteTexts.defaultTexts() {
    return RouletteTexts(
      playTitle: 'Roue de la Chance',
      playDescription: 'Tentez votre chance chaque jour !',
      playButton: 'Tourner la roue',
      noSpinsAvailable: 'Aucun tour disponible',
      spinsRemaining: '{count} tour(s) disponible(s)',
    );
  }

  RouletteTexts copyWith({
    String? playTitle,
    String? playDescription,
    String? playButton,
    String? noSpinsAvailable,
    String? spinsRemaining,
  }) {
    return RouletteTexts(
      playTitle: playTitle ?? this.playTitle,
      playDescription: playDescription ?? this.playDescription,
      playButton: playButton ?? this.playButton,
      noSpinsAvailable: noSpinsAvailable ?? this.noSpinsAvailable,
      spinsRemaining: spinsRemaining ?? this.spinsRemaining,
    );
  }
}
