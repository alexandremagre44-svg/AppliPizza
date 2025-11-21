# Theme Manager PRO - Architecture Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐        ┌──────────────────────────┐  │
│  │  ThemeManagerScreen  │        │                          │  │
│  │  ─────────────────── │        │  Navigation (Studio V2)  │  │
│  │                      │        │  ────────────────────    │  │
│  │  • App Bar           │◄───────┤  • Theme Menu Item       │  │
│  │  • Layout Manager    │        │  • Go Router Navigation  │  │
│  │  • State Handler     │        │  • Admin Protection      │  │
│  └──────────────────────┘        └──────────────────────────┘  │
│           │                                                     │
│           ├──────────────┬─────────────────┐                   │
│           ▼              ▼                 ▼                   │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐          │
│  │ Editor Panel │ │   Divider    │ │Preview Panel │          │
│  │              │ │              │ │              │          │
│  │ • Colors     │ │              │ │ • Phone Mock │          │
│  │ • Typography │ │              │ │ • Real-time  │          │
│  │ • Radius     │ │              │ │ • Auto Update│          │
│  │ • Shadows    │ │              │ │              │          │
│  │ • Spacing    │ │              │ │              │          │
│  │ • Dark Mode  │ │              │ │              │          │
│  └──────────────┘ └──────────────┘ └──────────────┘          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      STATE MANAGEMENT                           │
├─────────────────────────────────────────────────────────────────┤
│                         Riverpod                                │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Theme Providers                                         │  │
│  │  ───────────────                                         │  │
│  │                                                          │  │
│  │  • themeServiceProvider         → Service Instance      │  │
│  │  • themeConfigStreamProvider    → Real-time Stream      │  │
│  │  • themeConfigProvider          → Initial Load          │  │
│  │  • draftThemeConfigProvider     → Local Draft State     │  │
│  │  • hasUnsavedThemeChangesProvider → Change Tracking    │  │
│  │  • themeLoadingProvider         → Loading State         │  │
│  │  • themeSavingProvider          → Saving State          │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
│                            ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Draft State Flow                                        │  │
│  │  ────────────────                                        │  │
│  │                                                          │  │
│  │  Published ─────► Draft ─────► Preview                  │  │
│  │     State         State         Update                   │  │
│  │       │             │                                    │  │
│  │       │             ├──► Publish ──► Firestore          │  │
│  │       │             │                    │               │  │
│  │       └─────────────┴──► Cancel         │               │  │
│  │                                          │               │  │
│  │                              ┌───────────┘               │  │
│  │                              ▼                           │  │
│  │                        Update Published                  │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      BUSINESS LOGIC                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  ThemeService                                            │  │
│  │  ────────────                                            │  │
│  │                                                          │  │
│  │  Methods:                                                │  │
│  │  • getThemeConfig()      → Load from Firestore          │  │
│  │  • updateThemeConfig()   → Save to Firestore            │  │
│  │  • resetToDefaults()     → Restore defaults             │  │
│  │  • initIfMissing()       → Initialize if needed         │  │
│  │  • watchThemeConfig()    → Real-time stream             │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
│                            ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Data Models                                             │  │
│  │  ───────────                                             │  │
│  │                                                          │  │
│  │  ThemeConfig                                             │  │
│  │    ├── ThemeColorsConfig (9 colors)                     │  │
│  │    ├── TypographyConfig (size, scale, font)             │  │
│  │    ├── RadiusConfig (small, medium, large, full)        │  │
│  │    ├── ShadowsConfig (card, modal, navbar)              │  │
│  │    ├── SpacingConfig (small, medium, large)             │  │
│  │    ├── darkMode (bool)                                   │  │
│  │    └── updatedAt (timestamp)                            │  │
│  │                                                          │  │
│  │  Each model has:                                         │  │
│  │    • Factory constructors (default, fromMap)            │  │
│  │    • toMap() serialization                              │  │
│  │    • copyWith() for immutable updates                   │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                         BACKEND                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Cloud Firestore                                         │  │
│  │  ───────────────                                         │  │
│  │                                                          │  │
│  │  Collection: config                                      │  │
│  │  Document: theme                                         │  │
│  │                                                          │  │
│  │  {                                                       │  │
│  │    colors: {                                             │  │
│  │      primary: 0xFFD32F2F,                                │  │
│  │      secondary: 0xFF8E4C4C,                              │  │
│  │      background: 0xFFF5F5F5,                             │  │
│  │      surface: 0xFFFFFFFF,                                │  │
│  │      textPrimary: 0xFF323232,                            │  │
│  │      textSecondary: 0xFF5A5A5A,                          │  │
│  │      success: 0xFF4CAF50,                                │  │
│  │      warning: 0xFFFF9800,                                │  │
│  │      error: 0xFFC62828                                   │  │
│  │    },                                                    │  │
│  │    typography: {                                         │  │
│  │      baseSize: 14.0,                                     │  │
│  │      scaleFactor: 1.2,                                   │  │
│  │      fontFamily: "Roboto"                                │  │
│  │    },                                                    │  │
│  │    radius: { small: 8, medium: 12, large: 16, ... },    │  │
│  │    shadows: { card: 2, modal: 8, navbar: 4 },           │  │
│  │    spacing: { paddingSmall: 8, ... },                   │  │
│  │    darkMode: false,                                      │  │
│  │    updatedAt: "2025-11-21T..."                           │  │
│  │  }                                                       │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
│                            ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Firestore Security Rules                               │  │
│  │  ─────────────────────────                               │  │
│  │                                                          │  │
│  │  match /config/theme {                                   │  │
│  │    // Public read - all users can see theme             │  │
│  │    allow read: if true;                                  │  │
│  │                                                          │  │
│  │    // Admin write only                                   │  │
│  │    allow write: if isAdmin();                            │  │
│  │                                                          │  │
│  │    // Validate data structure                            │  │
│  │    allow update, create: if isAdmin() &&                 │  │
│  │      request.resource.data.keys().hasAll([...]) &&      │  │
│  │      request.resource.data.colors is map && ...;         │  │
│  │  }                                                       │  │
│  │                                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      NAVIGATION                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  GoRouter Configuration (main.dart)                             │
│  ──────────────────────────────────                             │
│                                                                 │
│  GoRoute(                                                       │
│    path: '/admin/studio/v3/theme',                              │
│    builder: (context, state) {                                  │
│      // Admin protection                                        │
│      if (!authState.isAdmin) {                                  │
│        redirect to home                                         │
│      }                                                          │
│      return ThemeManagerScreen();                               │
│    }                                                            │
│  )                                                              │
│                                                                 │
│  Access Points:                                                 │
│  • Direct URL: /admin/studio/v3/theme                           │
│  • Studio V2 → Configuration → Theme Manager PRO                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
┌──────────┐
│  Admin   │
│  User    │
└────┬─────┘
     │
     │ Navigate to /admin/studio/v3/theme
     ▼
┌─────────────────────────────────┐
│   Authentication Check          │
│   ─────────────────             │
│   isAdmin? ─────► YES ──────►   │
│                                 │
│                   NO            │
│                   │             │
│                   ▼             │
│              Redirect Home      │
└─────────────────────────────────┘
     │
     │ Authenticated Admin
     ▼
┌─────────────────────────────────┐
│   ThemeManagerScreen Init       │
│   ────────────────────          │
│   1. Initialize service         │
│   2. Load from Firestore        │
│   3. Set published state        │
│   4. Copy to draft state        │
└─────────────────────────────────┘
     │
     ├──► Display UI ──────────────┐
     │                             │
     │                             ▼
     │                    ┌────────────────┐
     │                    │ Editor Panel   │
     │                    │ ────────────   │
     │                    │ User changes   │
     │                    │ colors, fonts  │
     │                    │ etc.           │
     │                    └────────────────┘
     │                             │
     │                             │ Update draft
     │                             ▼
     │                    ┌────────────────┐
     │                    │ Draft State    │
     │                    │ ────────────   │
     │                    │ Local changes  │
     │                    │ not saved yet  │
     │                    └────────────────┘
     │                             │
     │                             │ Notify
     │                             ▼
     │                    ┌────────────────┐
     │                    │ Preview Panel  │
     │                    │ ────────────   │
     │                    │ Real-time      │
     │                    │ updates        │
     │                    └────────────────┘
     │                             │
     │                             │
     │            ┌────────────────┼────────────────┐
     │            │                │                │
     │            ▼                ▼                ▼
     │       ┌────────┐      ┌────────┐      ┌────────┐
     │       │Publish │      │Cancel  │      │Reset   │
     │       └───┬────┘      └───┬────┘      └───┬────┘
     │           │               │               │
     │           │               │               │
     │           ▼               ▼               ▼
     │    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
     │    │Save to       │ │Revert to     │ │Load          │
     │    │Firestore     │ │published     │ │defaults      │
     │    └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
     │           │                │                │
     │           ▼                │                │
     │    ┌──────────────┐        │                │
     │    │Update        │        │                │
     │    │published     │◄───────┴────────────────┘
     │    │state         │
     │    └──────────────┘
     │
     ▼
┌─────────────────────────────────┐
│   Application Uses Theme         │
│   ───────────────────            │
│   • Read from config/theme       │
│   • Apply colors, fonts, etc.    │
│   • Update UI                    │
└─────────────────────────────────┘
```

## Component Interaction

```
ThemeManagerScreen
    │
    ├── manages ──► Published State (from Firestore)
    │
    ├── manages ──► Draft State (local)
    │
    ├── renders ──► ThemeEditorPanel
    │                   │
    │                   ├── Color Section
    │                   │     └── ColorPicker Dialog
    │                   │
    │                   ├── Typography Section
    │                   │     ├── Sliders
    │                   │     └── Font Dropdown
    │                   │
    │                   ├── Radius Section
    │                   │     └── Sliders
    │                   │
    │                   ├── Shadows Section
    │                   │     └── Sliders
    │                   │
    │                   ├── Spacing Section
    │                   │     └── Sliders
    │                   │
    │                   └── Dark Mode Section
    │                         └── Switch
    │
    └── renders ──► ThemePreviewPanel
                        │
                        └── Phone Mockup
                              ├── Status Bar
                              ├── App Bar
                              ├── Hero Section
                              ├── Category Cards
                              ├── Product Cards
                              └── Bottom Nav
```

## State Management Flow

```
┌──────────────────────────────────────────────────────┐
│            Riverpod Provider Tree                    │
├──────────────────────────────────────────────────────┤
│                                                      │
│  themeServiceProvider (Provider)                     │
│    │                                                 │
│    ├──► themeConfigStreamProvider (StreamProvider)  │
│    │      └──► Real-time Firestore updates          │
│    │                                                 │
│    ├──► themeConfigProvider (FutureProvider)        │
│    │      └──► Initial load from Firestore          │
│    │                                                 │
│    └──► Service methods                             │
│           ├── getThemeConfig()                      │
│           ├── updateThemeConfig()                   │
│           ├── resetToDefaults()                     │
│           └── watchThemeConfig()                    │
│                                                      │
│  draftThemeConfigProvider (StateProvider)           │
│    └──► Local draft state (not persisted)           │
│                                                      │
│  hasUnsavedThemeChangesProvider (StateProvider)     │
│    └──► Boolean flag for unsaved changes            │
│                                                      │
│  themeLoadingProvider (StateProvider)               │
│    └──► Boolean flag for loading state              │
│                                                      │
│  themeSavingProvider (StateProvider)                │
│    └──► Boolean flag for saving state               │
│                                                      │
└──────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────┐
│              Security Layers                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Layer 1: Route Protection (main.dart)              │
│  ─────────────────────────────────                  │
│  • Check authState.isAdmin                          │
│  • Redirect non-admins to home                      │
│  • Executed before screen renders                   │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Layer 2: Firestore Rules (firestore.rules)         │
│  ────────────────────────────────────               │
│  • Public read access (all users)                   │
│  • Admin-only write access                          │
│  • Data structure validation                        │
│  • Field type validation                            │
│                                                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Layer 3: Service Layer (theme_service.dart)        │
│  ─────────────────────────────────────────          │
│  • Error handling                                   │
│  • Data validation                                  │
│  • Transaction safety                               │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Performance Optimizations

```
┌─────────────────────────────────────────────────────┐
│          Performance Strategies                     │
├─────────────────────────────────────────────────────┤
│                                                     │
│  1. Draft Mode                                      │
│     └─ All changes local until publish              │
│        └─ Minimizes Firestore writes                │
│                                                     │
│  2. Optimistic UI                                   │
│     └─ Preview updates immediately                  │
│        └─ No wait for Firestore                     │
│                                                     │
│  3. Efficient Rebuilds                              │
│     └─ Only preview panel rebuilds                  │
│        └─ Editor panel stays stable                 │
│                                                     │
│  4. Batch Updates                                   │
│     └─ Single Firestore transaction                 │
│        └─ Atomic updates                            │
│                                                     │
│  5. Stream vs Future                                │
│     └─ StreamProvider for real-time                 │
│     └─ FutureProvider for initial load              │
│                                                     │
└─────────────────────────────────────────────────────┘
```

## Error Handling

```
┌────────────────────────────────────────────────────┐
│           Error Handling Flow                      │
├────────────────────────────────────────────────────┤
│                                                    │
│  User Action                                       │
│      │                                             │
│      ├─► Service Call                              │
│      │       │                                     │
│      │       ├─► try/catch                         │
│      │       │                                     │
│      │       ├─► Success                           │
│      │       │     └─► Update state                │
│      │       │         └─► Show success snackbar   │
│      │       │                                     │
│      │       └─► Error                             │
│      │             ├─► Log error                   │
│      │             ├─► Reset loading state         │
│      │             └─► Show error snackbar         │
│      │                                             │
│      └─► Firestore Error                           │
│            ├─► Permission denied                   │
│            ├─► Network error                       │
│            ├─► Invalid data                        │
│            └─► Unknown error                       │
│                                                    │
└────────────────────────────────────────────────────┘
```
