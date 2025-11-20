// lib/src/screens/admin/_deprecated/studio_texts_screen.dart
// ⚠️ DEPRECATED - Migrated to unified Studio (admin_studio_screen_refactored.dart)
// Preserved ONLY for rollback and reference.
// Do not import or use in new code.
//
// PROMPT 3F - Complete modular text editor with sections, search, and preview
// Material 3 + Design System Pizza Deli'Zza

import 'package:flutter/material.dart';
import '../../../models/app_texts_config.dart';
import '../../../services/app_texts_service.dart';
import '../../../design_system/app_theme.dart';

/// StudioTextsScreen - Professional text management interface
/// 
/// Features:
/// - Modular organization by feature (Home, Profile, Cart, etc.)
/// - Search functionality
/// - Section filtering
/// - Real-time validation
/// - Bulk save with success feedback
class StudioTextsScreen extends StatefulWidget {
  const StudioTextsScreen({super.key});

  @override
  State<StudioTextsScreen> createState() => _StudioTextsScreenState();
}

class _StudioTextsScreenState extends State<StudioTextsScreen> with SingleTickerProviderStateMixin {
  final AppTextsService _service = AppTextsService();
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  
  late TabController _tabController;
  AppTextsConfig? _config;
  bool _isLoading = true;
  bool _isSaving = false;
  String _searchQuery = '';
  
  // Controllers organized by module
  final Map<String, Map<String, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 12, vsync: this);
    _loadConfig();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final module in _controllers.values) {
      for (final controller in module.values) {
        controller.dispose();
      }
    }
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    
    try {
      final config = await _service.getAppTextsConfig();
      
      setState(() {
        _config = config;
        _initializeControllers(config);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erreur lors du chargement: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  void _initializeControllers(AppTextsConfig config) {
    // Home module
    _controllers['home'] = {
      'appName': TextEditingController(text: config.home.appName),
      'slogan': TextEditingController(text: config.home.slogan),
      'title': TextEditingController(text: config.home.title),
      'subtitle': TextEditingController(text: config.home.subtitle),
      'ctaViewMenu': TextEditingController(text: config.home.ctaViewMenu),
      'welcomeMessage': TextEditingController(text: config.home.welcomeMessage),
      'categoriesTitle': TextEditingController(text: config.home.categoriesTitle),
      'promosTitle': TextEditingController(text: config.home.promosTitle),
      'bestSellersTitle': TextEditingController(text: config.home.bestSellersTitle),
      'featuredTitle': TextEditingController(text: config.home.featuredTitle),
      'retryButton': TextEditingController(text: config.home.retryButton),
      'productAddedToCart': TextEditingController(text: config.home.productAddedToCart),
    };

    // Profile module
    _controllers['profile'] = {
      'header': TextEditingController(text: config.profile.header),
      'loyaltyTitle': TextEditingController(text: config.profile.loyaltyTitle),
      'loyaltyPoints': TextEditingController(text: config.profile.loyaltyPoints),
      'loyaltyProgress': TextEditingController(text: config.profile.loyaltyProgress),
      'loyaltyPointsNeeded': TextEditingController(text: config.profile.loyaltyPointsNeeded),
      'loyaltyCtaViewRewards': TextEditingController(text: config.profile.loyaltyCtaViewRewards),
      'rewardsTitle': TextEditingController(text: config.profile.rewardsTitle),
      'rewardsEmpty': TextEditingController(text: config.profile.rewardsEmpty),
      'rewardsCtaViewAll': TextEditingController(text: config.profile.rewardsCtaViewAll),
      'rouletteTitle': TextEditingController(text: config.profile.rouletteTitle),
      'rouletteSubtitle': TextEditingController(text: config.profile.rouletteSubtitle),
      'rouletteCtaPlay': TextEditingController(text: config.profile.rouletteCtaPlay),
      'activityMyOrders': TextEditingController(text: config.profile.activityMyOrders),
      'activityMyFavorites': TextEditingController(text: config.profile.activityMyFavorites),
    };

    // Cart module
    _controllers['cart'] = {
      'title': TextEditingController(text: config.cart.title),
      'emptyTitle': TextEditingController(text: config.cart.emptyTitle),
      'emptyMessage': TextEditingController(text: config.cart.emptyMessage),
      'ctaCheckout': TextEditingController(text: config.cart.ctaCheckout),
      'ctaViewMenu': TextEditingController(text: config.cart.ctaViewMenu),
      'totalLabel': TextEditingController(text: config.cart.totalLabel),
      'subtotalLabel': TextEditingController(text: config.cart.subtotalLabel),
      'discountLabel': TextEditingController(text: config.cart.discountLabel),
    };

    // Checkout module
    _controllers['checkout'] = {
      'title': TextEditingController(text: config.checkout.title),
      'orderConfirmed': TextEditingController(text: config.checkout.orderConfirmed),
      'orderSuccess': TextEditingController(text: config.checkout.orderSuccess),
      'orderFailure': TextEditingController(text: config.checkout.orderFailure),
      'noSlotsAvailable': TextEditingController(text: config.checkout.noSlotsAvailable),
      'selectTimeSlot': TextEditingController(text: config.checkout.selectTimeSlot),
      'confirmOrder': TextEditingController(text: config.checkout.confirmOrder),
    };

    // Rewards module
    _controllers['rewards'] = {
      'activeSectionTitle': TextEditingController(text: config.rewards.activeSectionTitle),
      'historySectionTitle': TextEditingController(text: config.rewards.historySectionTitle),
      'expireAt': TextEditingController(text: config.rewards.expireAt),
      'used': TextEditingController(text: config.rewards.used),
      'expired': TextEditingController(text: config.rewards.expired),
      'active': TextEditingController(text: config.rewards.active),
      'ctaUse': TextEditingController(text: config.rewards.ctaUse),
      'noRewards': TextEditingController(text: config.rewards.noRewards),
    };

    // Roulette module
    _controllers['roulette'] = {
      'playTitle': TextEditingController(text: config.roulette.playTitle),
      'playDescription': TextEditingController(text: config.roulette.playDescription),
      'playButton': TextEditingController(text: config.roulette.playButton),
      'resultWin': TextEditingController(text: config.roulette.resultWin),
      'resultLose': TextEditingController(text: config.roulette.resultLose),
      'cooldown': TextEditingController(text: config.roulette.cooldown),
      'noSpinsAvailable': TextEditingController(text: config.roulette.noSpinsAvailable),
      'congratulations': TextEditingController(text: config.roulette.congratulations),
      'youWon': TextEditingController(text: config.roulette.youWon),
      'tryAgainTomorrow': TextEditingController(text: config.roulette.tryAgainTomorrow),
    };

    // Loyalty module
    _controllers['loyalty'] = {
      'programTitle': TextEditingController(text: config.loyalty.programTitle),
      'rewardMessage': TextEditingController(text: config.loyalty.rewardMessage),
      'programExplanation': TextEditingController(text: config.loyalty.programExplanation),
      'bronzeLevelText': TextEditingController(text: config.loyalty.bronzeLevelText),
      'silverLevelText': TextEditingController(text: config.loyalty.silverLevelText),
      'goldLevelText': TextEditingController(text: config.loyalty.goldLevelText),
      'pointsLabel': TextEditingController(text: config.loyalty.pointsLabel),
      'progressLabel': TextEditingController(text: config.loyalty.progressLabel),
    };

    // Catalog module
    _controllers['catalog'] = {
      'menuTitle': TextEditingController(text: config.catalog.menuTitle),
      'pizzaCategory': TextEditingController(text: config.catalog.pizzaCategory),
      'menusCategory': TextEditingController(text: config.catalog.menusCategory),
      'drinksCategory': TextEditingController(text: config.catalog.drinksCategory),
      'dessertsCategory': TextEditingController(text: config.catalog.dessertsCategory),
      'allCategory': TextEditingController(text: config.catalog.allCategory),
      'searchPlaceholder': TextEditingController(text: config.catalog.searchPlaceholder),
      'noResults': TextEditingController(text: config.catalog.noResults),
      'addToCart': TextEditingController(text: config.catalog.addToCart),
      'customize': TextEditingController(text: config.catalog.customize),
    };

    // Auth module
    _controllers['auth'] = {
      'loginTitle': TextEditingController(text: config.auth.loginTitle),
      'loginButton': TextEditingController(text: config.auth.loginButton),
      'signupTitle': TextEditingController(text: config.auth.signupTitle),
      'signupButton': TextEditingController(text: config.auth.signupButton),
      'emailLabel': TextEditingController(text: config.auth.emailLabel),
      'passwordLabel': TextEditingController(text: config.auth.passwordLabel),
      'nameLabel': TextEditingController(text: config.auth.nameLabel),
      'errorInvalidCredentials': TextEditingController(text: config.auth.errorInvalidCredentials),
      'errorWeakPassword': TextEditingController(text: config.auth.errorWeakPassword),
      'errorEmailInUse': TextEditingController(text: config.auth.errorEmailInUse),
      'forgotPassword': TextEditingController(text: config.auth.forgotPassword),
      'noAccount': TextEditingController(text: config.auth.noAccount),
      'hasAccount': TextEditingController(text: config.auth.hasAccount),
    };

    // Admin module
    _controllers['admin'] = {
      'studioTitle': TextEditingController(text: config.admin.studioTitle),
      'heroEditorTitle': TextEditingController(text: config.admin.heroEditorTitle),
      'heroEditorSubtitle': TextEditingController(text: config.admin.heroEditorSubtitle),
      'bannerEditorTitle': TextEditingController(text: config.admin.bannerEditorTitle),
      'popupEditorTitle': TextEditingController(text: config.admin.popupEditorTitle),
      'textEditorTitle': TextEditingController(text: config.admin.textEditorTitle),
      'textEditorSubtitle': TextEditingController(text: config.admin.textEditorSubtitle),
      'saveButton': TextEditingController(text: config.admin.saveButton),
      'cancelButton': TextEditingController(text: config.admin.cancelButton),
      'deleteButton': TextEditingController(text: config.admin.deleteButton),
      'successSaved': TextEditingController(text: config.admin.successSaved),
      'errorSaving': TextEditingController(text: config.admin.errorSaving),
    };

    // Errors module
    _controllers['errors'] = {
      'networkError': TextEditingController(text: config.errors.networkError),
      'serverError': TextEditingController(text: config.errors.serverError),
      'sessionExpired': TextEditingController(text: config.errors.sessionExpired),
      'genericError': TextEditingController(text: config.errors.genericError),
      'loadingError': TextEditingController(text: config.errors.loadingError),
      'savingError': TextEditingController(text: config.errors.savingError),
    };

    // Notifications module
    _controllers['notifications'] = {
      'newOrderTitle': TextEditingController(text: config.notifications.newOrderTitle),
      'orderReadyTitle': TextEditingController(text: config.notifications.orderReadyTitle),
      'promoAvailableTitle': TextEditingController(text: config.notifications.promoAvailableTitle),
      'rewardEarnedTitle': TextEditingController(text: config.notifications.rewardEarnedTitle),
      'loyaltyPointsEarnedTitle': TextEditingController(text: config.notifications.loyaltyPointsEarnedTitle),
    };
  }

  Future<void> _saveAllChanges() async {
    if (_formKey.currentState?.validate() != true) {
      _showSnackBar('Veuillez corriger les erreurs', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedConfig = _config!.copyWith(
        home: _buildHomeTexts(),
        profile: _buildProfileTexts(),
        cart: _buildCartTexts(),
        checkout: _buildCheckoutTexts(),
        rewards: _buildRewardsTexts(),
        roulette: _buildRouletteTexts(),
        loyalty: _buildLoyaltyTexts(),
        catalog: _buildCatalogTexts(),
        auth: _buildAuthTexts(),
        admin: _buildAdminTexts(),
        errors: _buildErrorTexts(),
        notifications: _buildNotificationTexts(),
        updatedAt: DateTime.now(),
      );

      final success = await _service.saveAppTextsConfig(updatedConfig);

      if (success) {
        _showSnackBar('✓ Tous les textes ont été enregistrés');
        await _loadConfig();
      } else {
        _showSnackBar('Erreur lors de l\'enregistrement', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erreur: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  HomeTexts _buildHomeTexts() {
    final c = _controllers['home']!;
    return HomeTexts(
      appName: c['appName']!.text.trim(),
      slogan: c['slogan']!.text.trim(),
      title: c['title']!.text.trim(),
      subtitle: c['subtitle']!.text.trim(),
      ctaViewMenu: c['ctaViewMenu']!.text.trim(),
      welcomeMessage: c['welcomeMessage']!.text.trim(),
      categoriesTitle: c['categoriesTitle']!.text.trim(),
      promosTitle: c['promosTitle']!.text.trim(),
      bestSellersTitle: c['bestSellersTitle']!.text.trim(),
      featuredTitle: c['featuredTitle']!.text.trim(),
      retryButton: c['retryButton']!.text.trim(),
      productAddedToCart: c['productAddedToCart']!.text.trim(),
    );
  }

  ProfileTexts _buildProfileTexts() {
    final c = _controllers['profile']!;
    return ProfileTexts(
      header: c['header']!.text.trim(),
      loyaltyTitle: c['loyaltyTitle']!.text.trim(),
      loyaltyPoints: c['loyaltyPoints']!.text.trim(),
      loyaltyProgress: c['loyaltyProgress']!.text.trim(),
      loyaltyPointsNeeded: c['loyaltyPointsNeeded']!.text.trim(),
      loyaltyCtaViewRewards: c['loyaltyCtaViewRewards']!.text.trim(),
      rewardsTitle: c['rewardsTitle']!.text.trim(),
      rewardsEmpty: c['rewardsEmpty']!.text.trim(),
      rewardsCtaViewAll: c['rewardsCtaViewAll']!.text.trim(),
      rouletteTitle: c['rouletteTitle']!.text.trim(),
      rouletteSubtitle: c['rouletteSubtitle']!.text.trim(),
      rouletteCtaPlay: c['rouletteCtaPlay']!.text.trim(),
      activityMyOrders: c['activityMyOrders']!.text.trim(),
      activityMyFavorites: c['activityMyFavorites']!.text.trim(),
    );
  }

  CartTexts _buildCartTexts() {
    final c = _controllers['cart']!;
    return CartTexts(
      title: c['title']!.text.trim(),
      emptyTitle: c['emptyTitle']!.text.trim(),
      emptyMessage: c['emptyMessage']!.text.trim(),
      ctaCheckout: c['ctaCheckout']!.text.trim(),
      ctaViewMenu: c['ctaViewMenu']!.text.trim(),
      totalLabel: c['totalLabel']!.text.trim(),
      subtotalLabel: c['subtotalLabel']!.text.trim(),
      discountLabel: c['discountLabel']!.text.trim(),
    );
  }

  CheckoutTexts _buildCheckoutTexts() {
    final c = _controllers['checkout']!;
    return CheckoutTexts(
      title: c['title']!.text.trim(),
      orderConfirmed: c['orderConfirmed']!.text.trim(),
      orderSuccess: c['orderSuccess']!.text.trim(),
      orderFailure: c['orderFailure']!.text.trim(),
      noSlotsAvailable: c['noSlotsAvailable']!.text.trim(),
      selectTimeSlot: c['selectTimeSlot']!.text.trim(),
      confirmOrder: c['confirmOrder']!.text.trim(),
    );
  }

  RewardsTexts _buildRewardsTexts() {
    final c = _controllers['rewards']!;
    return RewardsTexts(
      activeSectionTitle: c['activeSectionTitle']!.text.trim(),
      historySectionTitle: c['historySectionTitle']!.text.trim(),
      expireAt: c['expireAt']!.text.trim(),
      used: c['used']!.text.trim(),
      expired: c['expired']!.text.trim(),
      active: c['active']!.text.trim(),
      ctaUse: c['ctaUse']!.text.trim(),
      noRewards: c['noRewards']!.text.trim(),
    );
  }

  RouletteTexts _buildRouletteTexts() {
    final c = _controllers['roulette']!;
    return RouletteTexts(
      playTitle: c['playTitle']!.text.trim(),
      playDescription: c['playDescription']!.text.trim(),
      playButton: c['playButton']!.text.trim(),
      resultWin: c['resultWin']!.text.trim(),
      resultLose: c['resultLose']!.text.trim(),
      cooldown: c['cooldown']!.text.trim(),
      noSpinsAvailable: c['noSpinsAvailable']!.text.trim(),
      congratulations: c['congratulations']!.text.trim(),
      youWon: c['youWon']!.text.trim(),
      tryAgainTomorrow: c['tryAgainTomorrow']!.text.trim(),
    );
  }

  LoyaltyTexts _buildLoyaltyTexts() {
    final c = _controllers['loyalty']!;
    return LoyaltyTexts(
      programTitle: c['programTitle']!.text.trim(),
      rewardMessage: c['rewardMessage']!.text.trim(),
      programExplanation: c['programExplanation']!.text.trim(),
      bronzeLevelText: c['bronzeLevelText']!.text.trim(),
      silverLevelText: c['silverLevelText']!.text.trim(),
      goldLevelText: c['goldLevelText']!.text.trim(),
      pointsLabel: c['pointsLabel']!.text.trim(),
      progressLabel: c['progressLabel']!.text.trim(),
    );
  }

  CatalogTexts _buildCatalogTexts() {
    final c = _controllers['catalog']!;
    return CatalogTexts(
      menuTitle: c['menuTitle']!.text.trim(),
      pizzaCategory: c['pizzaCategory']!.text.trim(),
      menusCategory: c['menusCategory']!.text.trim(),
      drinksCategory: c['drinksCategory']!.text.trim(),
      dessertsCategory: c['dessertsCategory']!.text.trim(),
      allCategory: c['allCategory']!.text.trim(),
      searchPlaceholder: c['searchPlaceholder']!.text.trim(),
      noResults: c['noResults']!.text.trim(),
      addToCart: c['addToCart']!.text.trim(),
      customize: c['customize']!.text.trim(),
    );
  }

  AuthTexts _buildAuthTexts() {
    final c = _controllers['auth']!;
    return AuthTexts(
      loginTitle: c['loginTitle']!.text.trim(),
      loginButton: c['loginButton']!.text.trim(),
      signupTitle: c['signupTitle']!.text.trim(),
      signupButton: c['signupButton']!.text.trim(),
      emailLabel: c['emailLabel']!.text.trim(),
      passwordLabel: c['passwordLabel']!.text.trim(),
      nameLabel: c['nameLabel']!.text.trim(),
      errorInvalidCredentials: c['errorInvalidCredentials']!.text.trim(),
      errorWeakPassword: c['errorWeakPassword']!.text.trim(),
      errorEmailInUse: c['errorEmailInUse']!.text.trim(),
      forgotPassword: c['forgotPassword']!.text.trim(),
      noAccount: c['noAccount']!.text.trim(),
      hasAccount: c['hasAccount']!.text.trim(),
    );
  }

  AdminTexts _buildAdminTexts() {
    final c = _controllers['admin']!;
    return AdminTexts(
      studioTitle: c['studioTitle']!.text.trim(),
      heroEditorTitle: c['heroEditorTitle']!.text.trim(),
      heroEditorSubtitle: c['heroEditorSubtitle']!.text.trim(),
      bannerEditorTitle: c['bannerEditorTitle']!.text.trim(),
      popupEditorTitle: c['popupEditorTitle']!.text.trim(),
      textEditorTitle: c['textEditorTitle']!.text.trim(),
      textEditorSubtitle: c['textEditorSubtitle']!.text.trim(),
      saveButton: c['saveButton']!.text.trim(),
      cancelButton: c['cancelButton']!.text.trim(),
      deleteButton: c['deleteButton']!.text.trim(),
      successSaved: c['successSaved']!.text.trim(),
      errorSaving: c['errorSaving']!.text.trim(),
    );
  }

  ErrorTexts _buildErrorTexts() {
    final c = _controllers['errors']!;
    return ErrorTexts(
      networkError: c['networkError']!.text.trim(),
      serverError: c['serverError']!.text.trim(),
      sessionExpired: c['sessionExpired']!.text.trim(),
      genericError: c['genericError']!.text.trim(),
      loadingError: c['loadingError']!.text.trim(),
      savingError: c['savingError']!.text.trim(),
    );
  }

  NotificationTexts _buildNotificationTexts() {
    final c = _controllers['notifications']!;
    return NotificationTexts(
      newOrderTitle: c['newOrderTitle']!.text.trim(),
      orderReadyTitle: c['orderReadyTitle']!.text.trim(),
      promoAvailableTitle: c['promoAvailableTitle']!.text.trim(),
      rewardEarnedTitle: c['rewardEarnedTitle']!.text.trim(),
      loyaltyPointsEarnedTitle: c['loyaltyPointsEarnedTitle']!.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Textes & Messages',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un texte...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: const BorderSide(color: AppColors.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: const BorderSide(color: AppColors.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.input,
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: AppTextStyles.labelLarge,
                tabs: const [
                  Tab(text: 'Accueil'),
                  Tab(text: 'Profil'),
                  Tab(text: 'Panier'),
                  Tab(text: 'Commande'),
                  Tab(text: 'Récompenses'),
                  Tab(text: 'Roulette'),
                  Tab(text: 'Fidélité'),
                  Tab(text: 'Catalogue'),
                  Tab(text: 'Auth'),
                  Tab(text: 'Admin'),
                  Tab(text: 'Erreurs'),
                  Tab(text: 'Notifications'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildModuleFields('home', 'Accueil'),
                        _buildModuleFields('profile', 'Profil'),
                        _buildModuleFields('cart', 'Panier'),
                        _buildModuleFields('checkout', 'Commande'),
                        _buildModuleFields('rewards', 'Récompenses'),
                        _buildModuleFields('roulette', 'Roulette'),
                        _buildModuleFields('loyalty', 'Fidélité'),
                        _buildModuleFields('catalog', 'Catalogue'),
                        _buildModuleFields('auth', 'Authentification'),
                        _buildModuleFields('admin', 'Administration'),
                        _buildModuleFields('errors', 'Erreurs'),
                        _buildModuleFields('notifications', 'Notifications'),
                      ],
                    ),
                  ),
                  // Save button at bottom
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _saveAllChanges,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.button,
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Sauvegarder tous les textes',
                                  style: AppTextStyles.labelLarge,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModuleFields(String moduleName, String moduleTitle) {
    final fields = _controllers[moduleName];
    if (fields == null) return const SizedBox.shrink();

    // Filter fields based on search query
    final filteredFields = _searchQuery.isEmpty
        ? fields.entries.toList()
        : fields.entries.where((entry) {
            final key = entry.key.toLowerCase();
            final value = entry.value.text.toLowerCase();
            return key.contains(_searchQuery) || value.contains(_searchQuery);
          }).toList();

    if (filteredFields.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aucun résultat pour "$_searchQuery"',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            moduleTitle,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...filteredFields.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildTextField(
                controller: entry.value,
                label: _formatLabel(entry.key),
                hint: 'Saisissez le texte...',
                maxLines: entry.key.contains('Message') || entry.key.contains('Description') ? 2 : 1,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatLabel(String key) {
    // Convert camelCase to readable format
    final result = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelMedium,
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ce champ ne peut pas être vide';
        }
        return null;
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.button,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
