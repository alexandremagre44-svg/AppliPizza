# Example Refactoring: Using the CMS System

This document shows a concrete before/after example of refactoring a screen to use the headless CMS.

## Before: Static Strings

```dart
// lib/src/screens/home/home_screen.dart (BEFORE)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pizza Deli\'Zza',  // ❌ Static string
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.surfaceWhite,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'À emporter uniquement',  // ❌ Static string
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.surfaceWhite.withOpacity(0.8),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryRed,
      ),
      body: ListView(
        children: [
          // Hero Banner
          Container(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Bienvenue chez Pizza Deli\'Zza',  // ❌ Static string
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Les meilleures pizzas artisanales',  // ❌ Static string
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/menu'),
                  child: Text('Commander maintenant'),  // ❌ Static string
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## After: Dynamic CMS Strings

```dart
// lib/src/screens/home/home_screen.dart (AFTER)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/content/application/content_provider.dart'; // ✅ Add import

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ref.tr('app_name'),  // ✅ Dynamic from CMS
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.surfaceWhite,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              ref.tr('app_subtitle'),  // ✅ Dynamic from CMS
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.surfaceWhite.withOpacity(0.8),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryRed,
      ),
      body: ListView(
        children: [
          // Hero Banner
          Container(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  ref.tr('home_welcome_title'),  // ✅ Dynamic from CMS
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  ref.tr('home_welcome_subtitle'),  // ✅ Dynamic from CMS
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/menu'),
                  child: Text(ref.tr('home_order_now')),  // ✅ Dynamic from CMS
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Step-by-Step Migration Process

### Step 1: Add Content to CMS

Go to `/admin/studio/content` and add these keys:

| Key | Value (fr) |
|-----|------------|
| `app_name` | Pizza Deli'Zza |
| `app_subtitle` | À emporter uniquement |
| `home_welcome_title` | Bienvenue chez Pizza Deli'Zza |
| `home_welcome_subtitle` | Les meilleures pizzas artisanales |
| `home_order_now` | Commander maintenant |

### Step 2: Add Import

Add this import at the top of your file:

```dart
import '../../features/content/application/content_provider.dart';
```

### Step 3: Replace Static Strings

Replace each static string:
- Find: `'Static text'`
- Replace: `ref.tr('key_name')`

### Step 4: Test

1. Run the app
2. Verify all text displays correctly
3. Go to `/admin/studio/content`
4. Edit a value
5. Verify the change appears in the app in real-time

## Benefits Demonstrated

### ✅ Real-Time Updates
Change "Bienvenue chez Pizza Deli'Zza" to "Welcome to Pizza Deli'Zza" in the admin, and it updates instantly without redeployment.

### ✅ I18N Ready
The structure already supports multiple languages:
```dart
// In Firestore:
{
  "key": "home_welcome_title",
  "value": {
    "fr": "Bienvenue chez Pizza Deli'Zza",
    "en": "Welcome to Pizza Deli'Zza",  // Add this later
    "es": "Bienvenido a Pizza Deli'Zza"  // Add this later
  }
}
```

### ✅ No A/B Testing Setup Needed
Want to test different titles? Just change it in the admin panel - no code deployment required.

### ✅ Performance Optimized
Only widgets using changed keys rebuild, thanks to `select()` optimization.

## Advanced: Parameter Interpolation

### Before
```dart
Text('Bienvenue, Alexandre!')
```

### After
```dart
// In CMS: "welcome_user" = "Bienvenue, {name}!"
final userName = ref.watch(userProvider).name;
Text(ref.tr('welcome_user', params: {'name': userName}))
```

## Handling Loading & Error States

The `tr()` method automatically handles edge cases:

```dart
// ⏳ While loading Firestore data
ref.tr('any_key')  // Returns "..."

// ❌ If Firestore connection fails
ref.tr('any_key')  // Returns "❌ Error"

// ⚠️ If key doesn't exist in CMS
ref.tr('missing_key')  // Returns "⚠️ missing_key"
```

This gives immediate visual feedback during development.

## Complete Migration Checklist

For each screen file:

1. [ ] Add import: `import '../../features/content/application/content_provider.dart';`
2. [ ] List all static strings in the file
3. [ ] Create descriptive keys for each string (follow naming convention)
4. [ ] Add all keys/values to CMS via `/admin/studio/content`
5. [ ] Replace `'static string'` with `ref.tr('key')`
6. [ ] Replace `const Text('...')` with `Text(ref.tr('...'))`
7. [ ] Test the screen
8. [ ] Verify real-time updates work

## Naming Convention

Use this pattern for keys:
- `{screen}_{element}` - Ex: `home_title`, `cart_total`
- `{section}_{action}` - Ex: `auth_login`, `profile_logout`
- `common_{element}` - Ex: `common_loading`, `common_error`
- `nav_{destination}` - Ex: `nav_home`, `nav_cart`

## Pro Tips

### Tip 1: Use VS Code Search & Replace
1. Press `Ctrl+Shift+F` (or `Cmd+Shift+F` on Mac)
2. Search: `Text\('([^']+)'\)`
3. Manually review each match and decide on key names

### Tip 2: Group Related Strings
Add all strings for one screen at once in the CMS to maintain context.

### Tip 3: Test Edge Cases
- Empty cart screen
- Error states
- Loading states
- Long text strings

### Tip 4: Use Constants for Commonly Used Keys
```dart
// lib/src/features/content/constants.dart
class ContentKeys {
  static const appName = 'app_name';
  static const appSubtitle = 'app_subtitle';
  // ... more keys
}

// Usage:
Text(ref.tr(ContentKeys.appName))
```

## Result

After migration, your app:
- ✅ Has all strings in one central location (Firestore)
- ✅ Can be updated without redeployment
- ✅ Is ready for internationalization
- ✅ Has real-time synchronization
- ✅ Maintains type safety with the tr() method
- ✅ Has optimized performance with selective rebuilds

**This is the power of a headless CMS!**
