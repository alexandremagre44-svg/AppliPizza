# PROJECT_DNA.md
> **AI Context Document** — Optimized for LLM ingestion. Not for human reading.

---

## 1. 🗺️ GLOBAL TOPOLOGY (The Map)

### 1.1 Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── src/                         # 📦 LEGACY APP (Production Client App)
│   ├── core/                    # Constants, Firestore paths
│   ├── data/                    # Data layer
│   ├── design_system/           # UI design tokens
│   ├── kitchen/                 # Kitchen display module
│   ├── models/                  # Data models
│   ├── providers/               # Riverpod state management
│   ├── repositories/            # Data access layer
│   ├── screens/                 # UI screens
│   ├── services/                # Business logic services
│   ├── staff_tablet/            # Staff ordering interface
│   ├── theme/                   # Theme configuration
│   ├── utils/                   # Utilities
│   └── widgets/                 # Reusable widgets
└── builder/                     # 🆕 NEW BUILDER SYSTEM (Admin Page Builder)
    ├── blocks/                  # Block type renderers
    ├── editor/                  # Page editor UI
    ├── exceptions/              # Custom exceptions
    ├── models/                  # Builder data models
    ├── page_list/               # Page list management
    ├── preview/                 # Live preview
    ├── providers/               # Builder state
    ├── runtime/                 # Runtime rendering
    ├── services/                # Builder services
    └── utils/                   # Builder utilities
```

### 1.2 Architecture Boundary

```
┌─────────────────────────────────────────────────────────────────┐
│                         LEGACY APP (src/)                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐ │
│  │ Kitchen  │  │ Staff    │  │ Client   │  │ Admin (Studio)   │ │
│  │ Display  │  │ Tablet   │  │ Ordering │  │ Management       │ │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘ │
│                              ↑                                   │
│                      Uses Riverpod Providers                     │
│                              ↓                                   │
│              ┌───────────────────────────────────┐              │
│              │        Services Layer             │              │
│              │  (Firestore, Auth, Products...)   │              │
│              └───────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
                              ↕
                    Firestore Database
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                      NEW BUILDER (builder/)                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Page Builder B3 - Multi-page, Multi-resto, Draft/Publish │   │
│  │  • BuilderPage (pageKey as primary ID, nullable pageId)   │   │
│  │  • BuilderBlock (modular content blocks)                  │   │
│  │  • SystemBlock (non-configurable modules)                 │   │
│  └──────────────────────────────────────────────────────────┘   │
│              Uses BuilderLayoutService → Firestore               │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 Feature Modules

```json
{
  "modules": [
    {
      "name": "Kitchen Display",
      "path": "lib/src/kitchen/",
      "description": "Real-time order status for kitchen staff",
      "status": "active"
    },
    {
      "name": "Staff Tablet",
      "path": "lib/src/staff_tablet/",
      "description": "In-store ordering interface for staff",
      "status": "active"
    },
    {
      "name": "Client Ordering",
      "path": "lib/src/screens/",
      "description": "Customer-facing order flow (home, menu, cart, checkout)",
      "status": "active"
    },
    {
      "name": "Admin Studio",
      "path": "lib/src/screens/admin/",
      "description": "Back-office management (products, orders, themes)",
      "status": "active"
    },
    {
      "name": "Builder B3",
      "path": "lib/builder/",
      "description": "No-code page builder with blocks",
      "status": "active"
    },
    {
      "name": "Roulette Game",
      "path": "lib/src/screens/roulette/",
      "description": "Promotional wheel for rewards",
      "status": "active"
    },
    {
      "name": "Loyalty System",
      "path": "lib/src/providers/loyalty_provider.dart",
      "description": "Points, tiers, and rewards",
      "status": "active"
    }
  ]
}
```

---

## 2. 💾 DATA SCHEMA DEFINITION (The Truth)

### 2.1 Core Models (src/models/)

#### Product

```typescript
interface Product {
  readonly id: string;
  name: string;
  description: string;
  price: number;
  imageUrl: string;
  category: ProductCategory; // "Pizza" | "Menus" | "Boissons" | "Desserts"
  isMenu: boolean;
  baseIngredients: string[];
  allowedSupplements: string[];
  pizzaCount: number;
  drinkCount: number;
  isFeatured: boolean;
  isActive: boolean;
  displaySpot: DisplaySpot; // "home" | "promotions" | "new" | "all"
  order: number;
  isBestSeller: boolean;
  isNew: boolean;
  isChefSpecial: boolean;
  isKidFriendly: boolean;
}

enum ProductCategory {
  pizza = "Pizza",
  menus = "Menus",
  boissons = "Boissons",
  desserts = "Desserts"
}

enum DisplaySpot {
  home = "home",
  promotions = "promotions",
  new_ = "new",
  all = "all"
}
```

#### Ingredient

```typescript
interface Ingredient {
  readonly id: string;
  name: string;
  extraCost: number;
  category: IngredientCategory;
  isActive: boolean;
  iconName?: string;
  order: number;
}

enum IngredientCategory {
  fromage = "Fromages",
  viande = "Viandes",
  legume = "Légumes",
  sauce = "Sauces",
  herbe = "Herbes & Épices",
  autre = "Autres"
}
```

#### Order

```typescript
interface Order {
  readonly id: string;
  total: number;
  date: DateTime;
  items: CartItem[];
  status: OrderStatus;
  customerName?: string;
  customerPhone?: string;
  customerEmail?: string;
  comment?: string;
  statusHistory?: OrderStatusHistory[];
  isViewed: boolean;
  viewedAt?: DateTime;
  pickupDate?: string;
  pickupTimeSlot?: string;
  source: OrderSource; // "client" | "staff_tablet" | "admin"
  paymentMethod?: string;
}

type OrderStatus = 
  | "En attente" 
  | "En préparation" 
  | "En cuisson" 
  | "Prête" 
  | "Livrée" 
  | "Annulée";

interface OrderStatusHistory {
  status: string;
  timestamp: DateTime;
  note?: string;
}
```

#### CartItem

```typescript
interface CartItem {
  readonly id: string;
  productId: string;
  productName: string;
  price: number;
  quantity: number; // mutable
  imageUrl: string;
  customDescription?: string;
  isMenu: boolean;
}
```

#### UserProfile

```typescript
interface UserProfile {
  readonly id: string;
  name: string;
  email: string;
  imageUrl: string;
  address: string;
  favoriteProducts: string[];
  orderHistory: Order[]; // loaded separately
  loyaltyPoints: number;
  loyaltyLevel: string; // "Bronze" | "Silver" | "Gold"
}
```

#### LoyaltyReward

```typescript
interface LoyaltyReward {
  type: string; // "free_pizza" | "bonus_points" | "free_drink" | "free_dessert"
  value?: number;
  used: boolean;
  createdAt: DateTime;
  usedAt?: DateTime;
}
```

### 2.2 Configuration Models (src/models/)

#### ThemeConfig

```typescript
interface ThemeConfig {
  colors: ThemeColorsConfig;
  typography: TypographyConfig;
  radius: RadiusConfig;
  shadows: ShadowsConfig;
  spacing: SpacingConfig;
  darkMode: boolean;
  updatedAt: DateTime;
}

interface ThemeColorsConfig {
  primary: Color;
  secondary: Color;
  background: Color;
  surface: Color;
  textPrimary: Color;
  textSecondary: Color;
  success: Color;
  warning: Color;
  error: Color;
}
```

#### HomeConfig

```typescript
interface HomeConfig {
  readonly id: string;
  hero?: HeroConfig;
  promoBanner?: PromoBannerConfig;
  blocks: ContentBlock[];
  updatedAt: DateTime;
}

interface HeroConfig {
  isActive: boolean;
  imageUrl: string;
  title: string;
  subtitle: string;
  ctaText: string;
  ctaAction: string; // route path
}

interface PromoBannerConfig {
  isActive: boolean;
  text: string;
  backgroundColor?: string;
  textColor?: string;
  startDate?: DateTime;
  endDate?: DateTime;
}
```

#### RouletteConfig

```typescript
interface RouletteConfig {
  readonly id: string;
  isActive: boolean;
  displayLocation: string;
  delaySeconds: number;
  maxUsesPerDay: number;
  startDate?: DateTime;
  endDate?: DateTime;
  segments: RouletteSegment[];
  updatedAt: DateTime;
}

interface RouletteSegment {
  readonly id: string;
  label: string;
  rewardId: string;
  probability: number; // 0-100
  color: Color;
  description?: string;
  rewardType: RewardType;
  rewardValue?: number;
  productId?: string;
  iconName?: string;
  isActive: boolean;
  position: number;
}

enum RewardType {
  none = "none",
  bonusPoints = "bonus_points",
  percentageDiscount = "percentage_discount",
  fixedAmountDiscount = "fixed_amount_discount",
  freeProduct = "free_product",
  freePizza = "free_pizza",
  freeDrink = "free_drink",
  freeDessert = "free_dessert"
}
```

### 2.3 Builder Models (builder/models/)

#### BuilderPage

```typescript
interface BuilderPage {
  readonly pageKey: string;        // PRIMARY IDENTIFIER (Firestore doc ID)
  readonly systemId?: BuilderPageId; // Nullable, only for system pages
  readonly pageId?: BuilderPageId;   // DEPRECATED, nullable for custom pages
  appId: string;                   // Restaurant ID ("delizza")
  name: string;
  description: string;
  route: string;                   // e.g., "/home", "/page/promo_noel"
  blocks: BuilderBlock[];          // DEPRECATED, use draftLayout
  isEnabled: boolean;
  isDraft: boolean;
  metadata?: PageMetadata;
  version: number;
  createdAt: DateTime;
  updatedAt: DateTime;
  publishedAt?: DateTime;
  lastModifiedBy?: string;
  displayLocation: string;         // "bottomBar" | "hidden" | "internal"
  icon: string;                    // Material icon name
  order: number;
  isSystemPage: boolean;
  pageType: BuilderPageType;       // "template" | "blank" | "system" | "custom"
  isActive: boolean;
  bottomNavIndex: number;
  modules: string[];               // e.g., ["menu_catalog", "cart_module"]
  hasUnpublishedChanges: boolean;
  draftLayout: BuilderBlock[];     // Editor working copy
  publishedLayout: BuilderBlock[]; // Live version
}

enum BuilderPageId {
  home = "home",
  menu = "menu",
  promo = "promo",
  about = "about",
  contact = "contact",
  profile = "profile",   // system
  cart = "cart",         // system
  rewards = "rewards",   // system
  roulette = "roulette"  // system
}

enum BuilderPageType {
  template = "template",
  blank = "blank",
  system = "system",
  custom = "custom"
}
```

#### BuilderBlock

```typescript
interface BuilderBlock {
  readonly id: string;
  type: BlockType;
  order: number;
  config: Record<string, any>;
  isActive: boolean;
  visibility: BlockVisibility;
  customStyles?: string;
  createdAt: DateTime;
  updatedAt: DateTime;
}

enum BlockType {
  hero = "hero",
  banner = "banner",
  text = "text",
  productList = "product_list",
  info = "info",
  spacer = "spacer",
  image = "image",
  button = "button",
  categoryList = "category_list",
  html = "html",
  system = "system"
}

enum BlockVisibility {
  visible = "visible",
  hidden = "hidden",
  mobileOnly = "mobile_only",
  desktopOnly = "desktop_only"
}
```

#### SystemBlock (extends BuilderBlock)

```typescript
interface SystemBlock extends BuilderBlock {
  moduleType: string; // "roulette" | "loyalty" | "rewards" | "accountActivity"
}
```

---

## 3. ⚡ STATE MANAGEMENT GRAPH (The Nervous System)

### 3.1 Riverpod Providers (src/providers/)

```yaml
Providers:
  # Cart State
  - name: cartProvider
    type: StateNotifierProvider<CartNotifier, CartState>
    stores: |
      - items: List<CartItem>
      - discountPercent: double?
      - discountAmount: double?
      - pendingFreeItemId: string?
      - pendingFreeItemType: string?
      - appliedTicket: RewardTicket?
    computed:
      - subtotal: double
      - discountValue: double
      - total: double
      - totalItems: int
      - hasDiscount: bool
      - hasPendingFreeItem: bool
    dependencies: []

  # Auth State
  - name: authStateProvider
    type: StreamProvider<User?>
    stores: Firebase Auth user stream
    dependencies: [FirebaseAuthService]

  # Products
  - name: productProvider
    type: StreamProvider<List<Product>>
    stores: Real-time product list from Firestore
    dependencies: [FirestoreProductService]

  # Ingredients
  - name: ingredientProvider
    type: StreamProvider<List<Ingredient>>
    stores: Real-time ingredient list
    dependencies: [FirestoreIngredientService]

  # User Profile
  - name: userProvider
    type: StateNotifierProvider<UserNotifier, UserProfile?>
    stores: Current user profile
    dependencies: [authStateProvider, UserProfileService]

  # Orders
  - name: ordersProvider
    type: StreamProvider<List<Order>>
    stores: Real-time order list
    dependencies: [FirebaseOrderService]

  # Favorites
  - name: favoritesProvider
    type: StateNotifierProvider<FavoritesNotifier, List<String>>
    stores: Product IDs in favorites
    dependencies: []

  # Loyalty
  - name: loyaltyProvider
    type: StateNotifierProvider<LoyaltyNotifier, LoyaltyState>
    stores: Points, tier, rewards
    dependencies: [userProvider, LoyaltyService]

  # Reward Tickets
  - name: rewardTicketsProvider
    type: StreamProvider<List<RewardTicket>>
    stores: User's reward tickets
    dependencies: [userProvider, RewardService]

  # Theme
  - name: themeConfigProvider
    type: StreamProvider<ThemeConfig>
    stores: App theme configuration
    dependencies: [ThemeService]

  - name: currentThemeProvider
    type: Provider<ThemeData>
    stores: Flutter ThemeData derived from ThemeConfig
    dependencies: [themeConfigProvider]

  # Home Config
  - name: homeConfigProvider
    type: StreamProvider<HomeConfig>
    stores: Home page configuration
    dependencies: [HomeConfigService]

  # App Texts
  - name: appTextsProvider
    type: StreamProvider<AppTextsConfig>
    stores: Customizable UI texts
    dependencies: [AppTextsService]
```

### 3.2 Provider Dependency Graph

```
                    authStateProvider
                          │
                          ▼
                    userProvider ◄────────┐
                          │               │
          ┌───────────────┼───────────────┤
          ▼               ▼               ▼
   loyaltyProvider   ordersProvider  rewardTicketsProvider
          │
          ▼
     cartProvider (can apply tickets)

   productProvider ◄──── ingredientProvider (for supplements)
          │
          ▼
    favoritesProvider

   themeConfigProvider ──► currentThemeProvider ──► App MaterialApp

   homeConfigProvider ──► HomeScreen widgets
```

---

## 4. 🔌 FIRESTORE PATH MAP (The Data Source)

### 4.1 Collection Structure

```
restaurants/
└── {restaurantId}/              # e.g., "delizza"
    ├── pages_system/            # System page configs
    │   ├── home
    │   ├── menu
    │   ├── cart
    │   ├── profile
    │   └── ...
    ├── pages_draft/             # Draft page layouts (editor)
    │   ├── home
    │   ├── promo_noel          # Custom page
    │   └── ...
    ├── pages_published/         # Published page layouts (runtime)
    │   ├── home
    │   └── ...
    ├── builder_pages/           # Page metadata
    ├── builder_blocks/          # Block templates
    └── builder_settings/        # Builder configuration
        ├── home_config          # HomeConfig document
        ├── theme                # ThemeConfig document
        ├── app_texts            # App texts document
        ├── loyalty_settings     # Loyalty configuration
        ├── meta                 # Auto-init flags
        ├── banners/items/       # Banner subcollection
        ├── popups/items/        # Popup subcollection
        └── promotions/items/    # Promotions subcollection

products/                        # Global products collection
└── {productId}

ingredients/                     # Global ingredients collection
└── {ingredientId}

orders/                          # Global orders collection
└── {orderId}

users/                           # User profiles
└── {userId}
    └── reward_tickets/          # User's reward tickets
        └── {ticketId}

roulette_config/                 # Roulette wheel config
└── main

roulette_spins/                  # Spin history
└── {spinId}
```

### 4.2 Firestore Paths Helper

```typescript
// lib/src/core/firestore_paths.dart
class FirestorePaths {
  static const kRestaurantId = "delizza";
  
  // Collections
  static pagesSystem(restaurantId?) → CollectionReference
  static pagesDraft(restaurantId?) → CollectionReference
  static pagesPublished(restaurantId?) → CollectionReference
  static builderPages(restaurantId?) → CollectionReference
  static builderBlocks(restaurantId?) → CollectionReference
  static builderSettings(restaurantId?) → CollectionReference
  
  // Documents
  static systemPageDoc(docId, restaurantId?) → DocumentReference
  static draftDoc(docId, restaurantId?) → DocumentReference
  static publishedDoc(docId, restaurantId?) → DocumentReference
  static settingsDoc(docId, restaurantId?) → DocumentReference
  
  // Common IDs
  static homeConfigDocId = "home_config"
  static themeDocId = "theme"
  static appTextsDocId = "app_texts"
  static loyaltySettingsDocId = "loyalty_settings"
  static metaDocId = "meta"
}
```

---

## 5. 🚀 ENTRY POINTS & ROUTES (The Navigation)

### 5.1 Main Entry Point

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: MyApp()));
}
```

### 5.2 Route Structure

```yaml
Routes:
  Client:
    /: SplashScreen
    /home: HomeScreen
    /menu: MenuScreen
    /cart: CartScreen
    /checkout: CheckoutScreen
    /profile: ProfileScreen
    /roulette: RouletteScreen
    /about: AboutScreen
    /contact: ContactScreen
    /product/:id: ProductDetailScreen

  Admin:
    /admin: AdminDashboard
    /admin/pizza: PizzaManagementScreen
    /admin/orders: OrderManagementScreen
    /admin/theme: ThemeEditorScreen
    /admin/studio: StudioScreen (HomeConfig editor)
    /admin/studio/roulette: RouletteStudioScreen

  Kitchen:
    /kitchen: KitchenPage

  Staff Tablet:
    /staff: StaffTabletScreen

  Builder:
    /builder: BuilderEntryScreen
    /builder/editor/:pageId: BuilderPageEditorScreen
```

### 5.3 Bottom Navigation Structure

```yaml
BottomNavBar:
  items:
    - index: 0, icon: home, route: /home, pageId: home
    - index: 1, icon: restaurant_menu, route: /menu, pageId: menu
    - index: 2, icon: shopping_cart, route: /cart, pageId: cart (system)
    - index: 3, icon: person, route: /profile, pageId: profile (system)
  
  controlled_by: BuilderNavigationService.getBottomBarPages()
  source: pages_system collection with isActive=true, bottomNavIndex < 999
```

---

## 6. 🔧 SERVICES LAYER (The Business Logic)

### 6.1 Service Catalog

```yaml
Authentication:
  - AuthService: Email/password auth, password reset
  - FirebaseAuthService: Firebase Auth wrapper

Data:
  - FirestoreProductService: Product CRUD with Firestore
  - FirestoreIngredientService: Ingredient management
  - FirebaseOrderService: Order lifecycle management
  - UserProfileService: User profile CRUD

Business Logic:
  - LoyaltyService: Points calculation, tier management
  - LoyaltySettingsService: Loyalty rules configuration
  - RewardService: Reward ticket management
  - OrderService: Order creation, status updates

Configuration:
  - ThemeService: Theme CRUD from Firestore
  - HomeConfigService: Home page configuration
  - AppTextsService: UI text customization
  - BannerService: Promotional banners
  - PopupService: Popup configuration
  - PromotionService: Promotion rules

Roulette:
  - RouletteService: Spin logic, reward distribution
  - RouletteSettingsService: Wheel configuration
  - RouletteSegmentService: Segment management
  - RouletteRulesService: Spin rules and limits

Builder:
  - BuilderLayoutService: Page layout CRUD (draft/published)
  - BuilderPageService: Page management
  - BuilderNavigationService: Navigation bar management
  - BuilderAutoInitService: Auto-initialization
  - SystemPagesInitializer: System page creation
  - DynamicPageResolver: Route resolution for custom pages

Utilities:
  - ImageUploadService: Firebase Storage uploads
  - MailingService: Email notifications
  - ApiService: External API calls
```

### 6.2 BuilderLayoutService API

```dart
class BuilderLayoutService {
  // Dynamic pageId accepts String or BuilderPageId
  String _toPageIdString(dynamic pageId);
  
  // Draft Operations
  Future<void> saveDraft(BuilderPage page);
  Future<BuilderPage?> loadDraft(String appId, dynamic pageId);
  Stream<BuilderPage?> watchDraft(String appId, dynamic pageId);
  Future<void> deleteDraft(String appId, dynamic pageId);
  Future<bool> hasDraft(String appId, dynamic pageId);
  
  // Published Operations
  Future<void> publishPage(BuilderPage page, {required String userId});
  Future<BuilderPage?> loadPublished(String appId, dynamic pageId);
  Stream<BuilderPage?> watchPublished(String appId, dynamic pageId);
  Future<void> deletePublished(String appId, dynamic pageId);
  Future<bool> hasPublished(String appId, dynamic pageId);
  
  // Multi-page Operations
  Future<Map<String, BuilderPage>> loadAllPublishedPages(String appId);
  Future<Map<String, BuilderPage>> loadAllDraftPages(String appId);
  
  // System Pages
  Future<List<BuilderPage>> loadSystemPages();
  Future<BuilderPage?> loadSystemPage(BuilderPageId pageId);
  Stream<List<BuilderPage>> watchSystemPages();
  Future<List<BuilderPage>> getBottomBarPages();
}
```

---

## 7. 📋 CRITICAL IMPLEMENTATION NOTES

### 7.1 pageKey vs pageId (Builder)

```
IMPORTANT: BuilderPage ID System

- pageKey (String): PRIMARY IDENTIFIER
  - Used as Firestore document ID
  - Can be any string: "home", "menu", "promo_noel", "special_offer"
  - Always set, never null

- pageId (BuilderPageId?): DEPRECATED, NULLABLE
  - Enum value for known system pages
  - null for custom pages
  - Derived from pageKey via BuilderPageId.tryFromString()
  - Do NOT default to BuilderPageId.home

- systemId (BuilderPageId?): Alias for pageId when non-null
  - Same as pageId for system pages
  - null for custom pages
  - Use for system page lookups: SystemPages.getConfig(systemId)

Migration Pattern:
  OLD: page.pageId.value  → crashes for custom pages
  NEW: page.pageKey       → always works
```

### 7.2 Draft/Publish Workflow

```
Page Lifecycle:
  1. Admin creates/edits page → draftLayout modified
  2. saveDraft() → stores to pages_draft/{pageKey}
  3. publishPage() → copies draftLayout to publishedLayout, stores to pages_published/{pageKey}
  4. Client app → reads publishedLayout only
  
Fields:
  - draftLayout: Editor working copy
  - publishedLayout: Live version
  - hasUnpublishedChanges: Computed from diff
  - isDraft: Boolean flag
```

### 7.3 Provider Refresh Pattern

```dart
// Force provider refresh after Firestore update
ref.invalidate(productProvider);
ref.invalidate(homeConfigProvider);

// Listen to stream changes
ref.watch(themeConfigProvider).when(
  data: (config) => applyTheme(config),
  loading: () => showLoading(),
  error: (e, s) => showError(e),
);
```

---

## 8. 🔐 SECURITY NOTES

```yaml
Firebase Security Rules:
  - /restaurants/{restaurantId}: Admin only write
  - /products: Admin only write, all read
  - /orders: User can create own, admin all access
  - /users/{userId}: User can read/write own profile
  
App Check:
  - Enabled for production
  - Debug token for development

Auth Flow:
  - Email/password (Firebase Auth)
  - Session persistence (SharedPreferences for admin)
```

---

## 9. 📐 DESIGN SYSTEM TOKENS

```yaml
Colors:
  primary: 0xFFD32F2F (Red)
  secondary: 0xFF8E4C4C
  background: 0xFFF5F5F5
  surface: 0xFFFFFFFF
  textPrimary: 0xFF323232
  textSecondary: 0xFF5A5A5A
  success: 0xFF4CAF50
  warning: 0xFFFF9800
  error: 0xFFC62828

Typography:
  baseSize: 14.0
  scaleFactor: 1.2
  fontFamily: "Roboto"

Radius:
  small: 8.0
  medium: 12.0
  large: 16.0
  full: 9999.0

Spacing:
  paddingSmall: 8.0
  paddingMedium: 16.0
  paddingLarge: 24.0
```

---

## 10. 🧪 TESTING NOTES

```yaml
Test Files:
  - test/builder_page_parsing_test.dart: BuilderPage.fromJson safety
  - test/app_config_service_test.dart: Service tests
  - test/widget_test.dart: Widget tests

Key Test Cases:
  - BuilderPage custom page with unknown pageId → pageId should be null
  - BuilderPage system page → pageId should match systemId
  - Layout parsing with null/legacy data → graceful fallback
  - Cart calculations with discounts
```

---

*END OF PROJECT_DNA.md*
