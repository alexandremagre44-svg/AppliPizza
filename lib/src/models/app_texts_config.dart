// lib/src/models/app_texts_config.dart
// PROMPT 3F - Complete text system refactoring with modular architecture
// Configuration for ALL customizable app texts and messages

class AppTextsConfig {
  final String id;
  final HomeTexts home;
  final ProfileTexts profile;
  final RewardsTexts rewards;
  final RouletteTexts roulette;
  final LoyaltyTexts loyalty;
  final CatalogTexts catalog;
  final CartTexts cart;
  final CheckoutTexts checkout;
  final AuthTexts auth;
  final AdminTexts admin;
  final ErrorTexts errors;
  final NotificationTexts notifications;
  final DateTime updatedAt;

  AppTextsConfig({
    required this.id,
    required this.home,
    required this.profile,
    required this.rewards,
    required this.roulette,
    required this.loyalty,
    required this.catalog,
    required this.cart,
    required this.checkout,
    required this.auth,
    required this.admin,
    required this.errors,
    required this.notifications,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'home': home.toJson(),
      'profile': profile.toJson(),
      'rewards': rewards.toJson(),
      'roulette': roulette.toJson(),
      'loyalty': loyalty.toJson(),
      'catalog': catalog.toJson(),
      'cart': cart.toJson(),
      'checkout': checkout.toJson(),
      'auth': auth.toJson(),
      'admin': admin.toJson(),
      'errors': errors.toJson(),
      'notifications': notifications.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppTextsConfig.fromJson(Map<String, dynamic> json) {
    return AppTextsConfig(
      id: json['id'] as String? ?? 'default',
      home: HomeTexts.fromJson(json['home'] as Map<String, dynamic>? ?? {}),
      profile: ProfileTexts.fromJson(json['profile'] as Map<String, dynamic>? ?? {}),
      rewards: RewardsTexts.fromJson(json['rewards'] as Map<String, dynamic>? ?? {}),
      roulette: RouletteTexts.fromJson(json['roulette'] as Map<String, dynamic>? ?? {}),
      loyalty: LoyaltyTexts.fromJson(json['loyalty'] as Map<String, dynamic>? ?? {}),
      catalog: CatalogTexts.fromJson(json['catalog'] as Map<String, dynamic>? ?? {}),
      cart: CartTexts.fromJson(json['cart'] as Map<String, dynamic>? ?? {}),
      checkout: CheckoutTexts.fromJson(json['checkout'] as Map<String, dynamic>? ?? {}),
      auth: AuthTexts.fromJson(json['auth'] as Map<String, dynamic>? ?? {}),
      admin: AdminTexts.fromJson(json['admin'] as Map<String, dynamic>? ?? {}),
      errors: ErrorTexts.fromJson(json['errors'] as Map<String, dynamic>? ?? {}),
      notifications: NotificationTexts.fromJson(json['notifications'] as Map<String, dynamic>? ?? {}),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  AppTextsConfig copyWith({
    String? id,
    HomeTexts? home,
    ProfileTexts? profile,
    RewardsTexts? rewards,
    RouletteTexts? roulette,
    LoyaltyTexts? loyalty,
    CatalogTexts? catalog,
    CartTexts? cart,
    CheckoutTexts? checkout,
    AuthTexts? auth,
    AdminTexts? admin,
    ErrorTexts? errors,
    NotificationTexts? notifications,
    DateTime? updatedAt,
  }) {
    return AppTextsConfig(
      id: id ?? this.id,
      home: home ?? this.home,
      profile: profile ?? this.profile,
      rewards: rewards ?? this.rewards,
      roulette: roulette ?? this.roulette,
      loyalty: loyalty ?? this.loyalty,
      catalog: catalog ?? this.catalog,
      cart: cart ?? this.cart,
      checkout: checkout ?? this.checkout,
      auth: auth ?? this.auth,
      admin: admin ?? this.admin,
      errors: errors ?? this.errors,
      notifications: notifications ?? this.notifications,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppTextsConfig.defaultConfig() {
    return AppTextsConfig(
      id: 'default',
      home: HomeTexts.defaultTexts(),
      profile: ProfileTexts.defaultTexts(),
      rewards: RewardsTexts.defaultTexts(),
      roulette: RouletteTexts.defaultTexts(),
      loyalty: LoyaltyTexts.defaultTexts(),
      catalog: CatalogTexts.defaultTexts(),
      cart: CartTexts.defaultTexts(),
      checkout: CheckoutTexts.defaultTexts(),
      auth: AuthTexts.defaultTexts(),
      admin: AdminTexts.defaultTexts(),
      errors: ErrorTexts.defaultTexts(),
      notifications: NotificationTexts.defaultTexts(),
      updatedAt: DateTime.now(),
    );
  }
}

// ============================================================================
// HOME MODULE
// ============================================================================
class HomeTexts {
  final String appName;
  final String slogan;
  final String title;
  final String subtitle;
  final String ctaViewMenu;
  final String welcomeMessage;
  final String categoriesTitle;
  final String promosTitle;
  final String bestSellersTitle;
  final String bestsellersTitle; // Alternative name for bestSellersTitle
  final String promoBannerTitle; // Title for promo banner section
  final String promoBannerSubtitle; // Subtitle for promo banner section
  final String featuredTitle;
  final String retryButton;
  final String productAddedToCart;

  HomeTexts({
    required this.appName,
    required this.slogan,
    required this.title,
    required this.subtitle,
    required this.ctaViewMenu,
    required this.welcomeMessage,
    required this.categoriesTitle,
    required this.promosTitle,
    required this.bestSellersTitle,
    required this.bestsellersTitle,
    required this.promoBannerTitle,
    required this.promoBannerSubtitle,
    required this.featuredTitle,
    required this.retryButton,
    required this.productAddedToCart,
  });

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'slogan': slogan,
    'title': title,
    'subtitle': subtitle,
    'ctaViewMenu': ctaViewMenu,
    'welcomeMessage': welcomeMessage,
    'categoriesTitle': categoriesTitle,
    'promosTitle': promosTitle,
    'bestSellersTitle': bestSellersTitle,
    'bestsellersTitle': bestsellersTitle,
    'promoBannerTitle': promoBannerTitle,
    'promoBannerSubtitle': promoBannerSubtitle,
    'featuredTitle': featuredTitle,
    'retryButton': retryButton,
    'productAddedToCart': productAddedToCart,
  };

  factory HomeTexts.fromJson(Map<String, dynamic> json) => HomeTexts(
    appName: json['appName'] as String? ?? 'Pizza Deli\'Zza',
    slogan: json['slogan'] as String? ?? 'À emporter uniquement',
    title: json['title'] as String? ?? 'Bienvenue chez\nPizza Deli\'Zza',
    subtitle: json['subtitle'] as String? ?? 'Découvrez nos pizzas artisanales et nos menus gourmands',
    ctaViewMenu: json['ctaViewMenu'] as String? ?? 'Voir le menu',
    welcomeMessage: json['welcomeMessage'] as String? ?? 'Bienvenue',
    categoriesTitle: json['categoriesTitle'] as String? ?? 'Nos catégories',
    promosTitle: json['promosTitle'] as String? ?? '🔥 Promos du moment',
    bestSellersTitle: json['bestSellersTitle'] as String? ?? '⭐ Nos meilleures ventes',
    bestsellersTitle: json['bestsellersTitle'] as String? ?? '⭐ Nos meilleures ventes',
    promoBannerTitle: json['promoBannerTitle'] as String? ?? '🎉 Promotions',
    promoBannerSubtitle: json['promoBannerSubtitle'] as String? ?? 'Découvrez nos offres du moment',
    featuredTitle: json['featuredTitle'] as String? ?? '⭐ Produits phares',
    retryButton: json['retryButton'] as String? ?? 'Réessayer',
    productAddedToCart: json['productAddedToCart'] as String? ?? '{name} ajouté au panier !',
  );

  factory HomeTexts.defaultTexts() => HomeTexts(
    appName: 'Pizza Deli\'Zza',
    slogan: 'À emporter uniquement',
    title: 'Bienvenue chez\nPizza Deli\'Zza',
    subtitle: 'Découvrez nos pizzas artisanales et nos menus gourmands',
    ctaViewMenu: 'Voir le menu',
    welcomeMessage: 'Bienvenue',
    categoriesTitle: 'Nos catégories',
    promosTitle: '🔥 Promos du moment',
    bestSellersTitle: '⭐ Nos meilleures ventes',
    bestsellersTitle: '⭐ Nos meilleures ventes',
    promoBannerTitle: '🎉 Promotions',
    promoBannerSubtitle: 'Découvrez nos offres du moment',
    featuredTitle: '⭐ Produits phares',
    retryButton: 'Réessayer',
    productAddedToCart: '{name} ajouté au panier !',
  );

  HomeTexts copyWith({
    String? appName,
    String? slogan,
    String? title,
    String? subtitle,
    String? ctaViewMenu,
    String? welcomeMessage,
    String? categoriesTitle,
    String? promosTitle,
    String? bestSellersTitle,
    String? bestsellersTitle,
    String? promoBannerTitle,
    String? promoBannerSubtitle,
    String? featuredTitle,
    String? retryButton,
    String? productAddedToCart,
  }) => HomeTexts(
    appName: appName ?? this.appName,
    slogan: slogan ?? this.slogan,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    ctaViewMenu: ctaViewMenu ?? this.ctaViewMenu,
    welcomeMessage: welcomeMessage ?? this.welcomeMessage,
    categoriesTitle: categoriesTitle ?? this.categoriesTitle,
    promosTitle: promosTitle ?? this.promosTitle,
    bestSellersTitle: bestSellersTitle ?? this.bestSellersTitle,
    bestsellersTitle: bestsellersTitle ?? this.bestsellersTitle,
    promoBannerTitle: promoBannerTitle ?? this.promoBannerTitle,
    promoBannerSubtitle: promoBannerSubtitle ?? this.promoBannerSubtitle,
    featuredTitle: featuredTitle ?? this.featuredTitle,
    retryButton: retryButton ?? this.retryButton,
    productAddedToCart: productAddedToCart ?? this.productAddedToCart,
  );
}

// ============================================================================
// PROFILE MODULE
// ============================================================================
class ProfileTexts {
  final String header;
  final String loyaltyTitle;
  final String loyaltyPoints;
  final String loyaltyProgress;
  final String loyaltyPointsNeeded;
  final String loyaltyCtaViewRewards;
  final String rewardsTitle;
  final String rewardsEmpty;
  final String rewardsCtaViewAll;
  final String rouletteTitle;
  final String rouletteSubtitle;
  final String rouletteCtaPlay;
  final String activityMyOrders;
  final String activityMyFavorites;

  ProfileTexts({
    required this.header,
    required this.loyaltyTitle,
    required this.loyaltyPoints,
    required this.loyaltyProgress,
    required this.loyaltyPointsNeeded,
    required this.loyaltyCtaViewRewards,
    required this.rewardsTitle,
    required this.rewardsEmpty,
    required this.rewardsCtaViewAll,
    required this.rouletteTitle,
    required this.rouletteSubtitle,
    required this.rouletteCtaPlay,
    required this.activityMyOrders,
    required this.activityMyFavorites,
  });

  Map<String, dynamic> toJson() => {
    'header': header,
    'loyaltyTitle': loyaltyTitle,
    'loyaltyPoints': loyaltyPoints,
    'loyaltyProgress': loyaltyProgress,
    'loyaltyPointsNeeded': loyaltyPointsNeeded,
    'loyaltyCtaViewRewards': loyaltyCtaViewRewards,
    'rewardsTitle': rewardsTitle,
    'rewardsEmpty': rewardsEmpty,
    'rewardsCtaViewAll': rewardsCtaViewAll,
    'rouletteTitle': rouletteTitle,
    'rouletteSubtitle': rouletteSubtitle,
    'rouletteCtaPlay': rouletteCtaPlay,
    'activityMyOrders': activityMyOrders,
    'activityMyFavorites': activityMyFavorites,
  };

  factory ProfileTexts.fromJson(Map<String, dynamic> json) => ProfileTexts(
    header: json['header'] as String? ?? 'Mon compte',
    loyaltyTitle: json['loyaltyTitle'] as String? ?? 'Programme de Fidélité',
    loyaltyPoints: json['loyaltyPoints'] as String? ?? 'Points Fidélité',
    loyaltyProgress: json['loyaltyProgress'] as String? ?? 'Progression vers une pizza gratuite',
    loyaltyPointsNeeded: json['loyaltyPointsNeeded'] as String? ?? 'Plus que {points} points',
    loyaltyCtaViewRewards: json['loyaltyCtaViewRewards'] as String? ?? 'Voir mes récompenses fidélité',
    rewardsTitle: json['rewardsTitle'] as String? ?? 'Mes récompenses',
    rewardsEmpty: json['rewardsEmpty'] as String? ?? 'Aucune récompense disponible',
    rewardsCtaViewAll: json['rewardsCtaViewAll'] as String? ?? 'Voir toutes les récompenses',
    rouletteTitle: json['rouletteTitle'] as String? ?? 'Roue de la Chance',
    rouletteSubtitle: json['rouletteSubtitle'] as String? ?? 'Tentez votre chance et gagnez des récompenses !',
    rouletteCtaPlay: json['rouletteCtaPlay'] as String? ?? 'Tourner la roue',
    activityMyOrders: json['activityMyOrders'] as String? ?? 'Mes commandes',
    activityMyFavorites: json['activityMyFavorites'] as String? ?? 'Mes favoris',
  );

  factory ProfileTexts.defaultTexts() => ProfileTexts(
    header: 'Mon compte',
    loyaltyTitle: 'Programme de Fidélité',
    loyaltyPoints: 'Points Fidélité',
    loyaltyProgress: 'Progression vers une pizza gratuite',
    loyaltyPointsNeeded: 'Plus que {points} points',
    loyaltyCtaViewRewards: 'Voir mes récompenses fidélité',
    rewardsTitle: 'Mes récompenses',
    rewardsEmpty: 'Aucune récompense disponible',
    rewardsCtaViewAll: 'Voir toutes les récompenses',
    rouletteTitle: 'Roue de la Chance',
    rouletteSubtitle: 'Tentez votre chance et gagnez des récompenses !',
    rouletteCtaPlay: 'Tourner la roue',
    activityMyOrders: 'Mes commandes',
    activityMyFavorites: 'Mes favoris',
  );

  ProfileTexts copyWith({
    String? header,
    String? loyaltyTitle,
    String? loyaltyPoints,
    String? loyaltyProgress,
    String? loyaltyPointsNeeded,
    String? loyaltyCtaViewRewards,
    String? rewardsTitle,
    String? rewardsEmpty,
    String? rewardsCtaViewAll,
    String? rouletteTitle,
    String? rouletteSubtitle,
    String? rouletteCtaPlay,
    String? activityMyOrders,
    String? activityMyFavorites,
  }) => ProfileTexts(
    header: header ?? this.header,
    loyaltyTitle: loyaltyTitle ?? this.loyaltyTitle,
    loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    loyaltyProgress: loyaltyProgress ?? this.loyaltyProgress,
    loyaltyPointsNeeded: loyaltyPointsNeeded ?? this.loyaltyPointsNeeded,
    loyaltyCtaViewRewards: loyaltyCtaViewRewards ?? this.loyaltyCtaViewRewards,
    rewardsTitle: rewardsTitle ?? this.rewardsTitle,
    rewardsEmpty: rewardsEmpty ?? this.rewardsEmpty,
    rewardsCtaViewAll: rewardsCtaViewAll ?? this.rewardsCtaViewAll,
    rouletteTitle: rouletteTitle ?? this.rouletteTitle,
    rouletteSubtitle: rouletteSubtitle ?? this.rouletteSubtitle,
    rouletteCtaPlay: rouletteCtaPlay ?? this.rouletteCtaPlay,
    activityMyOrders: activityMyOrders ?? this.activityMyOrders,
    activityMyFavorites: activityMyFavorites ?? this.activityMyFavorites,
  );
}

// ============================================================================
// REWARDS MODULE
// ============================================================================
class RewardsTexts {
  final String activeSectionTitle;
  final String historySectionTitle;
  final String expireAt;
  final String used;
  final String expired;
  final String active;
  final String ctaUse;
  final String noRewards;

  RewardsTexts({
    required this.activeSectionTitle,
    required this.historySectionTitle,
    required this.expireAt,
    required this.used,
    required this.expired,
    required this.active,
    required this.ctaUse,
    required this.noRewards,
  });

  Map<String, dynamic> toJson() => {
    'activeSectionTitle': activeSectionTitle,
    'historySectionTitle': historySectionTitle,
    'expireAt': expireAt,
    'used': used,
    'expired': expired,
    'active': active,
    'ctaUse': ctaUse,
    'noRewards': noRewards,
  };

  factory RewardsTexts.fromJson(Map<String, dynamic> json) => RewardsTexts(
    activeSectionTitle: json['activeSectionTitle'] as String? ?? 'Récompenses actives',
    historySectionTitle: json['historySectionTitle'] as String? ?? 'Historique',
    expireAt: json['expireAt'] as String? ?? 'Expire le {date}',
    used: json['used'] as String? ?? 'Utilisé',
    expired: json['expired'] as String? ?? 'Expiré',
    active: json['active'] as String? ?? 'Actif',
    ctaUse: json['ctaUse'] as String? ?? 'Utiliser',
    noRewards: json['noRewards'] as String? ?? 'Aucune récompense pour le moment',
  );

  factory RewardsTexts.defaultTexts() => RewardsTexts(
    activeSectionTitle: 'Récompenses actives',
    historySectionTitle: 'Historique',
    expireAt: 'Expire le {date}',
    used: 'Utilisé',
    expired: 'Expiré',
    active: 'Actif',
    ctaUse: 'Utiliser',
    noRewards: 'Aucune récompense pour le moment',
  );

  RewardsTexts copyWith({
    String? activeSectionTitle,
    String? historySectionTitle,
    String? expireAt,
    String? used,
    String? expired,
    String? active,
    String? ctaUse,
    String? noRewards,
  }) => RewardsTexts(
    activeSectionTitle: activeSectionTitle ?? this.activeSectionTitle,
    historySectionTitle: historySectionTitle ?? this.historySectionTitle,
    expireAt: expireAt ?? this.expireAt,
    used: used ?? this.used,
    expired: expired ?? this.expired,
    active: active ?? this.active,
    ctaUse: ctaUse ?? this.ctaUse,
    noRewards: noRewards ?? this.noRewards,
  );
}

// ============================================================================
// ROULETTE MODULE
// ============================================================================
class RouletteTexts {
  final String playTitle;
  final String playDescription;
  final String playButton;
  final String resultWin;
  final String resultLose;
  final String cooldown;
  final String noSpinsAvailable;
  final String congratulations;
  final String youWon;
  final String tryAgainTomorrow;

  RouletteTexts({
    required this.playTitle,
    required this.playDescription,
    required this.playButton,
    required this.resultWin,
    required this.resultLose,
    required this.cooldown,
    required this.noSpinsAvailable,
    required this.congratulations,
    required this.youWon,
    required this.tryAgainTomorrow,
  });

  Map<String, dynamic> toJson() => {
    'playTitle': playTitle,
    'playDescription': playDescription,
    'playButton': playButton,
    'resultWin': resultWin,
    'resultLose': resultLose,
    'cooldown': cooldown,
    'noSpinsAvailable': noSpinsAvailable,
    'congratulations': congratulations,
    'youWon': youWon,
    'tryAgainTomorrow': tryAgainTomorrow,
  };

  factory RouletteTexts.fromJson(Map<String, dynamic> json) => RouletteTexts(
    playTitle: json['playTitle'] as String? ?? 'Roulette de la chance',
    playDescription: json['playDescription'] as String? ?? 'Tentez votre chance chaque jour !',
    playButton: json['playButton'] as String? ?? 'Tourner la roue',
    resultWin: json['resultWin'] as String? ?? 'Bravo ! Vous avez gagné :',
    resultLose: json['resultLose'] as String? ?? 'Dommage, réessayez demain.',
    cooldown: json['cooldown'] as String? ?? 'Vous avez déjà joué aujourd\'hui.',
    noSpinsAvailable: json['noSpinsAvailable'] as String? ?? 'Aucun tour disponible',
    congratulations: json['congratulations'] as String? ?? 'Félicitations !',
    youWon: json['youWon'] as String? ?? 'Vous avez gagné :',
    tryAgainTomorrow: json['tryAgainTomorrow'] as String? ?? 'Réessayez demain pour tenter votre chance !',
  );

  factory RouletteTexts.defaultTexts() => RouletteTexts(
    playTitle: 'Roulette de la chance',
    playDescription: 'Tentez votre chance chaque jour !',
    playButton: 'Tourner la roue',
    resultWin: 'Bravo ! Vous avez gagné :',
    resultLose: 'Dommage, réessayez demain.',
    cooldown: 'Vous avez déjà joué aujourd\'hui.',
    noSpinsAvailable: 'Aucun tour disponible',
    congratulations: 'Félicitations !',
    youWon: 'Vous avez gagné :',
    tryAgainTomorrow: 'Réessayez demain pour tenter votre chance !',
  );

  RouletteTexts copyWith({
    String? playTitle,
    String? playDescription,
    String? playButton,
    String? resultWin,
    String? resultLose,
    String? cooldown,
    String? noSpinsAvailable,
    String? congratulations,
    String? youWon,
    String? tryAgainTomorrow,
  }) => RouletteTexts(
    playTitle: playTitle ?? this.playTitle,
    playDescription: playDescription ?? this.playDescription,
    playButton: playButton ?? this.playButton,
    resultWin: resultWin ?? this.resultWin,
    resultLose: resultLose ?? this.resultLose,
    cooldown: cooldown ?? this.cooldown,
    noSpinsAvailable: noSpinsAvailable ?? this.noSpinsAvailable,
    congratulations: congratulations ?? this.congratulations,
    youWon: youWon ?? this.youWon,
    tryAgainTomorrow: tryAgainTomorrow ?? this.tryAgainTomorrow,
  );
}

// ============================================================================
// LOYALTY MODULE
// ============================================================================
class LoyaltyTexts {
  final String programTitle;
  final String rewardMessage;
  final String programExplanation;
  final String bronzeLevelText;
  final String silverLevelText;
  final String goldLevelText;
  final String pointsLabel;
  final String progressLabel;

  LoyaltyTexts({
    required this.programTitle,
    required this.rewardMessage,
    required this.programExplanation,
    required this.bronzeLevelText,
    required this.silverLevelText,
    required this.goldLevelText,
    required this.pointsLabel,
    required this.progressLabel,
  });

  Map<String, dynamic> toJson() => {
    'programTitle': programTitle,
    'rewardMessage': rewardMessage,
    'programExplanation': programExplanation,
    'bronzeLevelText': bronzeLevelText,
    'silverLevelText': silverLevelText,
    'goldLevelText': goldLevelText,
    'pointsLabel': pointsLabel,
    'progressLabel': progressLabel,
  };

  factory LoyaltyTexts.fromJson(Map<String, dynamic> json) => LoyaltyTexts(
    programTitle: json['programTitle'] as String? ?? 'Programme de Fidélité',
    rewardMessage: json['rewardMessage'] as String? ?? 'Bravo ! Vous avez gagné {points} points !',
    programExplanation: json['programExplanation'] as String? ?? 'Gagnez 1 point par euro dépensé',
    bronzeLevelText: json['bronzeLevelText'] as String? ?? 'Niveau Bronze',
    silverLevelText: json['silverLevelText'] as String? ?? 'Niveau Silver',
    goldLevelText: json['goldLevelText'] as String? ?? 'Niveau Gold',
    pointsLabel: json['pointsLabel'] as String? ?? 'Points',
    progressLabel: json['progressLabel'] as String? ?? 'Progression',
  );

  factory LoyaltyTexts.defaultTexts() => LoyaltyTexts(
    programTitle: 'Programme de Fidélité',
    rewardMessage: 'Bravo ! Vous avez gagné {points} points !',
    programExplanation: 'Gagnez 1 point par euro dépensé',
    bronzeLevelText: 'Niveau Bronze',
    silverLevelText: 'Niveau Silver',
    goldLevelText: 'Niveau Gold',
    pointsLabel: 'Points',
    progressLabel: 'Progression',
  );

  LoyaltyTexts copyWith({
    String? programTitle,
    String? rewardMessage,
    String? programExplanation,
    String? bronzeLevelText,
    String? silverLevelText,
    String? goldLevelText,
    String? pointsLabel,
    String? progressLabel,
  }) => LoyaltyTexts(
    programTitle: programTitle ?? this.programTitle,
    rewardMessage: rewardMessage ?? this.rewardMessage,
    programExplanation: programExplanation ?? this.programExplanation,
    bronzeLevelText: bronzeLevelText ?? this.bronzeLevelText,
    silverLevelText: silverLevelText ?? this.silverLevelText,
    goldLevelText: goldLevelText ?? this.goldLevelText,
    pointsLabel: pointsLabel ?? this.pointsLabel,
    progressLabel: progressLabel ?? this.progressLabel,
  );
}

// ============================================================================
// CATALOG MODULE
// ============================================================================
class CatalogTexts {
  final String menuTitle;
  final String pizzaCategory;
  final String menusCategory;
  final String drinksCategory;
  final String dessertsCategory;
  final String allCategory;
  final String searchPlaceholder;
  final String noResults;
  final String addToCart;
  final String customize;

  CatalogTexts({
    required this.menuTitle,
    required this.pizzaCategory,
    required this.menusCategory,
    required this.drinksCategory,
    required this.dessertsCategory,
    required this.allCategory,
    required this.searchPlaceholder,
    required this.noResults,
    required this.addToCart,
    required this.customize,
  });

  Map<String, dynamic> toJson() => {
    'menuTitle': menuTitle,
    'pizzaCategory': pizzaCategory,
    'menusCategory': menusCategory,
    'drinksCategory': drinksCategory,
    'dessertsCategory': dessertsCategory,
    'allCategory': allCategory,
    'searchPlaceholder': searchPlaceholder,
    'noResults': noResults,
    'addToCart': addToCart,
    'customize': customize,
  };

  factory CatalogTexts.fromJson(Map<String, dynamic> json) => CatalogTexts(
    menuTitle: json['menuTitle'] as String? ?? 'Notre Menu',
    pizzaCategory: json['pizzaCategory'] as String? ?? 'Pizza',
    menusCategory: json['menusCategory'] as String? ?? 'Menus',
    drinksCategory: json['drinksCategory'] as String? ?? 'Boissons',
    dessertsCategory: json['dessertsCategory'] as String? ?? 'Desserts',
    allCategory: json['allCategory'] as String? ?? 'Tous',
    searchPlaceholder: json['searchPlaceholder'] as String? ?? 'Rechercher...',
    noResults: json['noResults'] as String? ?? 'Aucun produit trouvé',
    addToCart: json['addToCart'] as String? ?? 'Ajouter au panier',
    customize: json['customize'] as String? ?? 'Personnaliser',
  );

  factory CatalogTexts.defaultTexts() => CatalogTexts(
    menuTitle: 'Notre Menu',
    pizzaCategory: 'Pizza',
    menusCategory: 'Menus',
    drinksCategory: 'Boissons',
    dessertsCategory: 'Desserts',
    allCategory: 'Tous',
    searchPlaceholder: 'Rechercher...',
    noResults: 'Aucun produit trouvé',
    addToCart: 'Ajouter au panier',
    customize: 'Personnaliser',
  );

  CatalogTexts copyWith({
    String? menuTitle,
    String? pizzaCategory,
    String? menusCategory,
    String? drinksCategory,
    String? dessertsCategory,
    String? allCategory,
    String? searchPlaceholder,
    String? noResults,
    String? addToCart,
    String? customize,
  }) => CatalogTexts(
    menuTitle: menuTitle ?? this.menuTitle,
    pizzaCategory: pizzaCategory ?? this.pizzaCategory,
    menusCategory: menusCategory ?? this.menusCategory,
    drinksCategory: drinksCategory ?? this.drinksCategory,
    dessertsCategory: dessertsCategory ?? this.dessertsCategory,
    allCategory: allCategory ?? this.allCategory,
    searchPlaceholder: searchPlaceholder ?? this.searchPlaceholder,
    noResults: noResults ?? this.noResults,
    addToCart: addToCart ?? this.addToCart,
    customize: customize ?? this.customize,
  );
}

// ============================================================================
// CART MODULE
// ============================================================================
class CartTexts {
  final String title;
  final String emptyTitle;
  final String emptyMessage;
  final String ctaCheckout;
  final String ctaViewMenu;
  final String totalLabel;
  final String subtotalLabel;
  final String discountLabel;

  CartTexts({
    required this.title,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.ctaCheckout,
    required this.ctaViewMenu,
    required this.totalLabel,
    required this.subtotalLabel,
    required this.discountLabel,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'emptyTitle': emptyTitle,
    'emptyMessage': emptyMessage,
    'ctaCheckout': ctaCheckout,
    'ctaViewMenu': ctaViewMenu,
    'totalLabel': totalLabel,
    'subtotalLabel': subtotalLabel,
    'discountLabel': discountLabel,
  };

  factory CartTexts.fromJson(Map<String, dynamic> json) => CartTexts(
    title: json['title'] as String? ?? 'Mon Panier',
    emptyTitle: json['emptyTitle'] as String? ?? 'Votre panier est vide',
    emptyMessage: json['emptyMessage'] as String? ?? 'Ajoutez de délicieuses pizzas pour commencer votre commande',
    ctaCheckout: json['ctaCheckout'] as String? ?? 'Commander',
    ctaViewMenu: json['ctaViewMenu'] as String? ?? 'Découvrir le menu',
    totalLabel: json['totalLabel'] as String? ?? 'Total',
    subtotalLabel: json['subtotalLabel'] as String? ?? 'Sous-total',
    discountLabel: json['discountLabel'] as String? ?? 'Réduction',
  );

  factory CartTexts.defaultTexts() => CartTexts(
    title: 'Mon Panier',
    emptyTitle: 'Votre panier est vide',
    emptyMessage: 'Ajoutez de délicieuses pizzas pour commencer votre commande',
    ctaCheckout: 'Commander',
    ctaViewMenu: 'Découvrir le menu',
    totalLabel: 'Total',
    subtotalLabel: 'Sous-total',
    discountLabel: 'Réduction',
  );

  CartTexts copyWith({
    String? title,
    String? emptyTitle,
    String? emptyMessage,
    String? ctaCheckout,
    String? ctaViewMenu,
    String? totalLabel,
    String? subtotalLabel,
    String? discountLabel,
  }) => CartTexts(
    title: title ?? this.title,
    emptyTitle: emptyTitle ?? this.emptyTitle,
    emptyMessage: emptyMessage ?? this.emptyMessage,
    ctaCheckout: ctaCheckout ?? this.ctaCheckout,
    ctaViewMenu: ctaViewMenu ?? this.ctaViewMenu,
    totalLabel: totalLabel ?? this.totalLabel,
    subtotalLabel: subtotalLabel ?? this.subtotalLabel,
    discountLabel: discountLabel ?? this.discountLabel,
  );
}

// ============================================================================
// CHECKOUT MODULE
// ============================================================================
class CheckoutTexts {
  final String title;
  final String orderConfirmed;
  final String orderSuccess;
  final String orderFailure;
  final String noSlotsAvailable;
  final String selectTimeSlot;
  final String confirmOrder;

  CheckoutTexts({
    required this.title,
    required this.orderConfirmed,
    required this.orderSuccess,
    required this.orderFailure,
    required this.noSlotsAvailable,
    required this.selectTimeSlot,
    required this.confirmOrder,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'orderConfirmed': orderConfirmed,
    'orderSuccess': orderSuccess,
    'orderFailure': orderFailure,
    'noSlotsAvailable': noSlotsAvailable,
    'selectTimeSlot': selectTimeSlot,
    'confirmOrder': confirmOrder,
  };

  factory CheckoutTexts.fromJson(Map<String, dynamic> json) => CheckoutTexts(
    title: json['title'] as String? ?? 'Finaliser la commande',
    orderConfirmed: json['orderConfirmed'] as String? ?? 'Commande confirmée !',
    orderSuccess: json['orderSuccess'] as String? ?? 'Votre commande a été validée avec succès !',
    orderFailure: json['orderFailure'] as String? ?? 'Une erreur est survenue lors de la commande.',
    noSlotsAvailable: json['noSlotsAvailable'] as String? ?? 'Aucun créneau disponible pour le moment.',
    selectTimeSlot: json['selectTimeSlot'] as String? ?? 'Sélectionner un créneau',
    confirmOrder: json['confirmOrder'] as String? ?? 'Confirmer la commande',
  );

  factory CheckoutTexts.defaultTexts() => CheckoutTexts(
    title: 'Finaliser la commande',
    orderConfirmed: 'Commande confirmée !',
    orderSuccess: 'Votre commande a été validée avec succès !',
    orderFailure: 'Une erreur est survenue lors de la commande.',
    noSlotsAvailable: 'Aucun créneau disponible pour le moment.',
    selectTimeSlot: 'Sélectionner un créneau',
    confirmOrder: 'Confirmer la commande',
  );

  CheckoutTexts copyWith({
    String? title,
    String? orderConfirmed,
    String? orderSuccess,
    String? orderFailure,
    String? noSlotsAvailable,
    String? selectTimeSlot,
    String? confirmOrder,
  }) => CheckoutTexts(
    title: title ?? this.title,
    orderConfirmed: orderConfirmed ?? this.orderConfirmed,
    orderSuccess: orderSuccess ?? this.orderSuccess,
    orderFailure: orderFailure ?? this.orderFailure,
    noSlotsAvailable: noSlotsAvailable ?? this.noSlotsAvailable,
    selectTimeSlot: selectTimeSlot ?? this.selectTimeSlot,
    confirmOrder: confirmOrder ?? this.confirmOrder,
  );
}

// ============================================================================
// AUTH MODULE
// ============================================================================
class AuthTexts {
  final String loginTitle;
  final String loginButton;
  final String signupTitle;
  final String signupButton;
  final String emailLabel;
  final String passwordLabel;
  final String nameLabel;
  final String errorInvalidCredentials;
  final String errorWeakPassword;
  final String errorEmailInUse;
  final String forgotPassword;
  final String noAccount;
  final String hasAccount;

  AuthTexts({
    required this.loginTitle,
    required this.loginButton,
    required this.signupTitle,
    required this.signupButton,
    required this.emailLabel,
    required this.passwordLabel,
    required this.nameLabel,
    required this.errorInvalidCredentials,
    required this.errorWeakPassword,
    required this.errorEmailInUse,
    required this.forgotPassword,
    required this.noAccount,
    required this.hasAccount,
  });

  Map<String, dynamic> toJson() => {
    'loginTitle': loginTitle,
    'loginButton': loginButton,
    'signupTitle': signupTitle,
    'signupButton': signupButton,
    'emailLabel': emailLabel,
    'passwordLabel': passwordLabel,
    'nameLabel': nameLabel,
    'errorInvalidCredentials': errorInvalidCredentials,
    'errorWeakPassword': errorWeakPassword,
    'errorEmailInUse': errorEmailInUse,
    'forgotPassword': forgotPassword,
    'noAccount': noAccount,
    'hasAccount': hasAccount,
  };

  factory AuthTexts.fromJson(Map<String, dynamic> json) => AuthTexts(
    loginTitle: json['loginTitle'] as String? ?? 'Connexion',
    loginButton: json['loginButton'] as String? ?? 'Se connecter',
    signupTitle: json['signupTitle'] as String? ?? 'Créer un compte',
    signupButton: json['signupButton'] as String? ?? 'S\'inscrire',
    emailLabel: json['emailLabel'] as String? ?? 'Email',
    passwordLabel: json['passwordLabel'] as String? ?? 'Mot de passe',
    nameLabel: json['nameLabel'] as String? ?? 'Nom',
    errorInvalidCredentials: json['errorInvalidCredentials'] as String? ?? 'Identifiants incorrects',
    errorWeakPassword: json['errorWeakPassword'] as String? ?? 'Mot de passe trop faible',
    errorEmailInUse: json['errorEmailInUse'] as String? ?? 'Cet email est déjà utilisé',
    forgotPassword: json['forgotPassword'] as String? ?? 'Mot de passe oublié ?',
    noAccount: json['noAccount'] as String? ?? 'Pas encore de compte ?',
    hasAccount: json['hasAccount'] as String? ?? 'Déjà un compte ?',
  );

  factory AuthTexts.defaultTexts() => AuthTexts(
    loginTitle: 'Connexion',
    loginButton: 'Se connecter',
    signupTitle: 'Créer un compte',
    signupButton: 'S\'inscrire',
    emailLabel: 'Email',
    passwordLabel: 'Mot de passe',
    nameLabel: 'Nom',
    errorInvalidCredentials: 'Identifiants incorrects',
    errorWeakPassword: 'Mot de passe trop faible',
    errorEmailInUse: 'Cet email est déjà utilisé',
    forgotPassword: 'Mot de passe oublié ?',
    noAccount: 'Pas encore de compte ?',
    hasAccount: 'Déjà un compte ?',
  );

  AuthTexts copyWith({
    String? loginTitle,
    String? loginButton,
    String? signupTitle,
    String? signupButton,
    String? emailLabel,
    String? passwordLabel,
    String? nameLabel,
    String? errorInvalidCredentials,
    String? errorWeakPassword,
    String? errorEmailInUse,
    String? forgotPassword,
    String? noAccount,
    String? hasAccount,
  }) => AuthTexts(
    loginTitle: loginTitle ?? this.loginTitle,
    loginButton: loginButton ?? this.loginButton,
    signupTitle: signupTitle ?? this.signupTitle,
    signupButton: signupButton ?? this.signupButton,
    emailLabel: emailLabel ?? this.emailLabel,
    passwordLabel: passwordLabel ?? this.passwordLabel,
    nameLabel: nameLabel ?? this.nameLabel,
    errorInvalidCredentials: errorInvalidCredentials ?? this.errorInvalidCredentials,
    errorWeakPassword: errorWeakPassword ?? this.errorWeakPassword,
    errorEmailInUse: errorEmailInUse ?? this.errorEmailInUse,
    forgotPassword: forgotPassword ?? this.forgotPassword,
    noAccount: noAccount ?? this.noAccount,
    hasAccount: hasAccount ?? this.hasAccount,
  );
}

// ============================================================================
// ADMIN MODULE
// ============================================================================
class AdminTexts {
  final String studioTitle;
  final String heroEditorTitle;
  final String heroEditorSubtitle;
  final String bannerEditorTitle;
  final String popupEditorTitle;
  final String textEditorTitle;
  final String textEditorSubtitle;
  final String saveButton;
  final String cancelButton;
  final String deleteButton;
  final String successSaved;
  final String errorSaving;

  AdminTexts({
    required this.studioTitle,
    required this.heroEditorTitle,
    required this.heroEditorSubtitle,
    required this.bannerEditorTitle,
    required this.popupEditorTitle,
    required this.textEditorTitle,
    required this.textEditorSubtitle,
    required this.saveButton,
    required this.cancelButton,
    required this.deleteButton,
    required this.successSaved,
    required this.errorSaving,
  });

  Map<String, dynamic> toJson() => {
    'studioTitle': studioTitle,
    'heroEditorTitle': heroEditorTitle,
    'heroEditorSubtitle': heroEditorSubtitle,
    'bannerEditorTitle': bannerEditorTitle,
    'popupEditorTitle': popupEditorTitle,
    'textEditorTitle': textEditorTitle,
    'textEditorSubtitle': textEditorSubtitle,
    'saveButton': saveButton,
    'cancelButton': cancelButton,
    'deleteButton': deleteButton,
    'successSaved': successSaved,
    'errorSaving': errorSaving,
  };

  factory AdminTexts.fromJson(Map<String, dynamic> json) => AdminTexts(
    studioTitle: json['studioTitle'] as String? ?? 'Studio Builder',
    heroEditorTitle: json['heroEditorTitle'] as String? ?? 'Éditeur Hero',
    heroEditorSubtitle: json['heroEditorSubtitle'] as String? ?? 'Personnalisez la bannière d\'accueil',
    bannerEditorTitle: json['bannerEditorTitle'] as String? ?? 'Bandeau promotionnel',
    popupEditorTitle: json['popupEditorTitle'] as String? ?? 'Éditeur de Popup',
    textEditorTitle: json['textEditorTitle'] as String? ?? 'Textes & Messages',
    textEditorSubtitle: json['textEditorSubtitle'] as String? ?? 'Gérez tous les textes de l\'application',
    saveButton: json['saveButton'] as String? ?? 'Sauvegarder',
    cancelButton: json['cancelButton'] as String? ?? 'Annuler',
    deleteButton: json['deleteButton'] as String? ?? 'Supprimer',
    successSaved: json['successSaved'] as String? ?? 'Enregistré avec succès',
    errorSaving: json['errorSaving'] as String? ?? 'Erreur lors de l\'enregistrement',
  );

  factory AdminTexts.defaultTexts() => AdminTexts(
    studioTitle: 'Studio Builder',
    heroEditorTitle: 'Éditeur Hero',
    heroEditorSubtitle: 'Personnalisez la bannière d\'accueil',
    bannerEditorTitle: 'Bandeau promotionnel',
    popupEditorTitle: 'Éditeur de Popup',
    textEditorTitle: 'Textes & Messages',
    textEditorSubtitle: 'Gérez tous les textes de l\'application',
    saveButton: 'Sauvegarder',
    cancelButton: 'Annuler',
    deleteButton: 'Supprimer',
    successSaved: 'Enregistré avec succès',
    errorSaving: 'Erreur lors de l\'enregistrement',
  );

  AdminTexts copyWith({
    String? studioTitle,
    String? heroEditorTitle,
    String? heroEditorSubtitle,
    String? bannerEditorTitle,
    String? popupEditorTitle,
    String? textEditorTitle,
    String? textEditorSubtitle,
    String? saveButton,
    String? cancelButton,
    String? deleteButton,
    String? successSaved,
    String? errorSaving,
  }) => AdminTexts(
    studioTitle: studioTitle ?? this.studioTitle,
    heroEditorTitle: heroEditorTitle ?? this.heroEditorTitle,
    heroEditorSubtitle: heroEditorSubtitle ?? this.heroEditorSubtitle,
    bannerEditorTitle: bannerEditorTitle ?? this.bannerEditorTitle,
    popupEditorTitle: popupEditorTitle ?? this.popupEditorTitle,
    textEditorTitle: textEditorTitle ?? this.textEditorTitle,
    textEditorSubtitle: textEditorSubtitle ?? this.textEditorSubtitle,
    saveButton: saveButton ?? this.saveButton,
    cancelButton: cancelButton ?? this.cancelButton,
    deleteButton: deleteButton ?? this.deleteButton,
    successSaved: successSaved ?? this.successSaved,
    errorSaving: errorSaving ?? this.errorSaving,
  );
}

// ============================================================================
// ERRORS MODULE
// ============================================================================
class ErrorTexts {
  final String networkError;
  final String serverError;
  final String sessionExpired;
  final String genericError;
  final String loadingError;
  final String savingError;

  ErrorTexts({
    required this.networkError,
    required this.serverError,
    required this.sessionExpired,
    required this.genericError,
    required this.loadingError,
    required this.savingError,
  });

  Map<String, dynamic> toJson() => {
    'networkError': networkError,
    'serverError': serverError,
    'sessionExpired': sessionExpired,
    'genericError': genericError,
    'loadingError': loadingError,
    'savingError': savingError,
  };

  factory ErrorTexts.fromJson(Map<String, dynamic> json) => ErrorTexts(
    networkError: json['networkError'] as String? ?? 'Erreur de connexion. Vérifiez votre réseau.',
    serverError: json['serverError'] as String? ?? 'Erreur serveur. Réessayez plus tard.',
    sessionExpired: json['sessionExpired'] as String? ?? 'Votre session a expiré. Reconnectez-vous.',
    genericError: json['genericError'] as String? ?? 'Une erreur est survenue.',
    loadingError: json['loadingError'] as String? ?? 'Erreur lors du chargement',
    savingError: json['savingError'] as String? ?? 'Erreur lors de l\'enregistrement',
  );

  factory ErrorTexts.defaultTexts() => ErrorTexts(
    networkError: 'Erreur de connexion. Vérifiez votre réseau.',
    serverError: 'Erreur serveur. Réessayez plus tard.',
    sessionExpired: 'Votre session a expiré. Reconnectez-vous.',
    genericError: 'Une erreur est survenue.',
    loadingError: 'Erreur lors du chargement',
    savingError: 'Erreur lors de l\'enregistrement',
  );

  ErrorTexts copyWith({
    String? networkError,
    String? serverError,
    String? sessionExpired,
    String? genericError,
    String? loadingError,
    String? savingError,
  }) => ErrorTexts(
    networkError: networkError ?? this.networkError,
    serverError: serverError ?? this.serverError,
    sessionExpired: sessionExpired ?? this.sessionExpired,
    genericError: genericError ?? this.genericError,
    loadingError: loadingError ?? this.loadingError,
    savingError: savingError ?? this.savingError,
  );
}

// ============================================================================
// NOTIFICATIONS MODULE
// ============================================================================
class NotificationTexts {
  final String newOrderTitle;
  final String orderReadyTitle;
  final String promoAvailableTitle;
  final String rewardEarnedTitle;
  final String loyaltyPointsEarnedTitle;

  NotificationTexts({
    required this.newOrderTitle,
    required this.orderReadyTitle,
    required this.promoAvailableTitle,
    required this.rewardEarnedTitle,
    required this.loyaltyPointsEarnedTitle,
  });

  Map<String, dynamic> toJson() => {
    'newOrderTitle': newOrderTitle,
    'orderReadyTitle': orderReadyTitle,
    'promoAvailableTitle': promoAvailableTitle,
    'rewardEarnedTitle': rewardEarnedTitle,
    'loyaltyPointsEarnedTitle': loyaltyPointsEarnedTitle,
  };

  factory NotificationTexts.fromJson(Map<String, dynamic> json) => NotificationTexts(
    newOrderTitle: json['newOrderTitle'] as String? ?? 'Nouvelle commande',
    orderReadyTitle: json['orderReadyTitle'] as String? ?? 'Commande prête',
    promoAvailableTitle: json['promoAvailableTitle'] as String? ?? 'Nouvelle promotion',
    rewardEarnedTitle: json['rewardEarnedTitle'] as String? ?? 'Récompense gagnée',
    loyaltyPointsEarnedTitle: json['loyaltyPointsEarnedTitle'] as String? ?? 'Points de fidélité gagnés',
  );

  factory NotificationTexts.defaultTexts() => NotificationTexts(
    newOrderTitle: 'Nouvelle commande',
    orderReadyTitle: 'Commande prête',
    promoAvailableTitle: 'Nouvelle promotion',
    rewardEarnedTitle: 'Récompense gagnée',
    loyaltyPointsEarnedTitle: 'Points de fidélité gagnés',
  );

  NotificationTexts copyWith({
    String? newOrderTitle,
    String? orderReadyTitle,
    String? promoAvailableTitle,
    String? rewardEarnedTitle,
    String? loyaltyPointsEarnedTitle,
  }) => NotificationTexts(
    newOrderTitle: newOrderTitle ?? this.newOrderTitle,
    orderReadyTitle: orderReadyTitle ?? this.orderReadyTitle,
    promoAvailableTitle: promoAvailableTitle ?? this.promoAvailableTitle,
    rewardEarnedTitle: rewardEarnedTitle ?? this.rewardEarnedTitle,
    loyaltyPointsEarnedTitle: loyaltyPointsEarnedTitle ?? this.loyaltyPointsEarnedTitle,
  );
}
