# Architecture Documentation

## Overview

This project follows a **feature-based architecture** (also known as "package-by-feature" or "screaming architecture"), organizing code by business domains rather than technical layers.

## Directory Structure

```
lib/src/
├── features/          # All feature modules
│   ├── auth/         # Authentication & user management
│   ├── cart/         # Shopping cart functionality
│   ├── checkout/     # Checkout process
│   ├── content/      # CMS content management
│   ├── home/         # Home screen & configuration
│   ├── loyalty/      # Loyalty program
│   ├── mailing/      # Email campaigns & mailing
│   ├── menu/         # Menu display & customization
│   ├── orders/       # Order management
│   ├── popups/       # Popup configuration
│   ├── product/      # Product management
│   ├── profile/      # User profile
│   ├── roulette/     # Roulette/wheel feature
│   ├── shared/       # Shared components & utilities
│   └── splash/       # Splash screen
├── kitchen/          # Kitchen mode (separate feature)
└── services/         # Shared services layer
```

## Feature Structure

Each feature follows a clean architecture pattern with three layers:

```
feature/
├── application/      # Application/Business Logic Layer
│   └── *_provider.dart           # Riverpod providers, state management
│
├── data/            # Data Layer
│   ├── models/                   # Data models (entities)
│   └── repositories/             # Data access (repositories)
│
└── presentation/    # Presentation Layer
    ├── screens/                  # Full-screen pages
    ├── widgets/                  # Reusable UI components
    └── admin/                    # Admin-specific screens
```

### Layer Responsibilities

#### 1. Data Layer (`data/`)
- **Models**: Plain Dart classes representing domain entities
- **Repositories**: Handle data access (Firestore, APIs, local storage)
- **Responsibilities**:
  - Define data structures
  - Fetch and persist data
  - Transform data between external and internal formats

#### 2. Application Layer (`application/`)
- **Providers**: Riverpod state notifiers and providers
- **Responsibilities**:
  - Manage application state
  - Implement business logic
  - Coordinate between data and presentation layers
  - Handle user actions and events

#### 3. Presentation Layer (`presentation/`)
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components
- **Admin**: Admin-specific interfaces
- **Responsibilities**:
  - Display data to users
  - Capture user input
  - Navigate between screens
  - Minimal business logic (only UI-related)

## Feature Examples

### Auth Feature
```
features/auth/
├── application/
│   ├── auth_provider.dart         # Authentication state
│   └── user_provider.dart         # User profile state
├── data/
│   ├── models/
│   │   └── user_profile.dart
│   └── repositories/
│       ├── firebase_auth_repository.dart
│       └── user_profile_repository.dart
└── presentation/
    └── screens/
        ├── login_screen.dart
        └── signup_screen.dart
```

### Product Feature
```
features/product/
├── application/
│   └── product_provider.dart
├── data/
│   ├── models/
│   │   └── product.dart
│   └── repositories/
│       ├── product_repository.dart
│       ├── firestore_product_repository.dart
│       └── product_crud_repository.dart
└── presentation/
    ├── admin/
    │   ├── admin_pizza_screen.dart
    │   ├── admin_menu_screen.dart
    │   ├── admin_drinks_screen.dart
    │   └── admin_desserts_screen.dart
    ├── screens/
    │   └── product_detail_screen.dart
    └── widgets/
        ├── product_card.dart
        ├── product_detail_modal.dart
        └── ingredient_selector.dart
```

## Shared Feature

The `shared/` feature contains code used across multiple features:

```
features/shared/
├── constants/           # App-wide constants
├── data/               # Shared data utilities
├── design_system/      # Design system components
├── presentation/
│   ├── admin/         # Shared admin screens
│   └── widgets/       # Shared widgets
├── theme/             # App theme
└── utils/             # Utility functions
```

## Import Guidelines

### Within a Feature (Relative Imports)
```dart
// From application to data layer
import '../data/models/user_profile.dart';

// From presentation to application layer
import '../../application/auth_provider.dart';
```

### Cross-Feature (Relative or Package Imports)
```dart
// From one feature to another
import '../../../product/data/models/product.dart';
import '../../../cart/application/cart_provider.dart';
```

### Shared Resources
```dart
// Shared constants
import '../../../shared/constants/constants.dart';

// Shared theme
import '../../../shared/theme/app_theme.dart';

// Shared widgets
import '../../../shared/widgets/scaffold_with_nav_bar.dart';
```

### Services Layer
```dart
// Services are accessed via package imports
import 'package:pizza_delizza/src/services/firebase_auth_service.dart';
```

## Benefits of This Architecture

### 1. Feature Isolation
- Each feature is self-contained
- Changes in one feature don't affect others
- Clear boundaries between features

### 2. Scalability
- Easy to add new features
- Features can grow independently
- Can extract features to separate packages

### 3. Maintainability
- Easy to locate code
- Changes are localized
- Reduced cognitive load

### 4. Team Collaboration
- Multiple developers can work on different features
- Reduced merge conflicts
- Clear ownership

### 5. Testability
- Features can be tested in isolation
- Easy to mock dependencies
- Clear testing boundaries

## Best Practices

### Do's ✅
- Keep features independent
- Use relative imports within features
- Put shared code in `shared/`
- Follow the layer structure consistently
- Keep business logic in application layer
- Keep UI logic minimal in presentation layer

### Don'ts ❌
- Don't create circular dependencies between features
- Don't bypass layers (e.g., presentation accessing data directly)
- Don't put feature-specific code in shared
- Don't mix business logic in presentation layer
- Don't create god classes/features

## Migration Notes

This architecture was created through a complete refactoring from a "by type" structure. Key changes:

- **Before**: `models/`, `services/`, `providers/`, `screens/`, `widgets/`
- **After**: `features/{feature_name}/{layer}/`

All imports have been updated to reflect the new structure, with zero changes to business logic.

## Additional Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Package by Feature](https://phauer.com/2020/package-by-feature/)
