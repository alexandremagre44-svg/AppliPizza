// lib/src/models/app_texts_config.dart
// Configuration for customizable app texts and messages

class AppTextsConfig {
  final String id;
  final GeneralTexts general;
  final OrderMessages orderMessages;
  final ErrorMessages errorMessages;
  final LoyaltyTexts loyaltyTexts;
  final DateTime updatedAt;

  AppTextsConfig({
    required this.id,
    required this.general,
    required this.orderMessages,
    required this.errorMessages,
    required this.loyaltyTexts,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'general': general.toJson(),
      'orderMessages': orderMessages.toJson(),
      'errorMessages': errorMessages.toJson(),
      'loyaltyTexts': loyaltyTexts.toJson(),
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
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  AppTextsConfig copyWith({
    String? id,
    GeneralTexts? general,
    OrderMessages? orderMessages,
    ErrorMessages? errorMessages,
    LoyaltyTexts? loyaltyTexts,
    DateTime? updatedAt,
  }) {
    return AppTextsConfig(
      id: id ?? this.id,
      general: general ?? this.general,
      orderMessages: orderMessages ?? this.orderMessages,
      errorMessages: errorMessages ?? this.errorMessages,
      loyaltyTexts: loyaltyTexts ?? this.loyaltyTexts,
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
