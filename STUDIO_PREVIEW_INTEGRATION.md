# Studio Preview Integration Guide

## Overview
This guide explains how to integrate the `AdminHomePreviewAdvanced` widget into Studio Admin modules for real-time preview functionality.

## Quick Start

### Basic Integration (No Draft)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../preview/admin_home_preview_advanced.dart';

class MyStudioModule extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Editor panel (left)
        Expanded(
          child: MyEditorPanel(),
        ),
        
        // Preview panel (right)
        Expanded(
          child: AdminHomePreviewAdvanced(),
        ),
      ],
    );
  }
}
```

### With Draft State (Recommended)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../preview/admin_home_preview_advanced.dart';
import '../providers/banner_provider.dart';

class BannerEditorModule extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch draft state
    final draftBanners = ref.watch(draftBannersProvider);
    
    return Row(
      children: [
        // Editor panel (left)
        Expanded(
          child: BannerEditor(
            onBannersChanged: (banners) {
              // Update draft state
              ref.read(draftBannersProvider.notifier).state = banners;
              ref.read(hasUnsavedBannerChangesProvider.notifier).state = true;
            },
          ),
        ),
        
        // Preview panel (right) - shows draft changes in real-time
        Expanded(
          child: AdminHomePreviewAdvanced(
            draftBanners: draftBanners,
          ),
        ),
      ],
    );
  }
}
```

## Integration Examples by Module

### 1. Layout Manager Integration
```dart
import '../models/home_layout_config.dart';
import '../providers/home_layout_provider.dart';

class LayoutManagerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftLayout = ref.watch(draftHomeLayoutProvider);
    
    return Row(
      children: [
        Expanded(
          child: LayoutEditor(
            onLayoutChanged: (layout) {
              ref.read(draftHomeLayoutProvider.notifier).state = layout;
            },
          ),
        ),
        Expanded(
          child: AdminHomePreviewAdvanced(
            draftHomeLayout: draftLayout,
          ),
        ),
      ],
    );
  }
}
```

### 2. Banner Manager Integration
```dart
import '../models/banner_config.dart';
import '../providers/banner_provider.dart';

class BannerManagerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftBanners = ref.watch(draftBannersProvider);
    
    return Row(
      children: [
        Expanded(
          child: BannerListEditor(
            onBannersChanged: (banners) {
              ref.read(draftBannersProvider.notifier).state = banners;
              ref.read(hasUnsavedBannerChangesProvider.notifier).state = true;
            },
          ),
        ),
        Expanded(
          child: AdminHomePreviewAdvanced(
            draftBanners: draftBanners,
          ),
        ),
      ],
    );
  }
}
```

### 3. Popup Manager Integration
```dart
import '../models/popup_v2_model.dart';
import '../providers/popup_v2_provider.dart';

class PopupManagerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftPopups = ref.watch(draftPopupsV2Provider);
    
    return Row(
      children: [
        Expanded(
          child: PopupListEditor(
            onPopupsChanged: (popups) {
              ref.read(draftPopupsV2Provider.notifier).state = popups;
              ref.read(hasUnsavedPopupChangesProvider.notifier).state = true;
            },
          ),
        ),
        Expanded(
          child: AdminHomePreviewAdvanced(
            draftPopups: draftPopups,
          ),
        ),
      ],
    );
  }
}
```

### 4. Theme Manager Integration
```dart
import '../models/theme_config.dart';
import '../providers/theme_providers.dart';

class ThemeManagerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftTheme = ref.watch(draftThemeConfigProvider);
    
    return Row(
      children: [
        Expanded(
          child: ThemeEditor(
            onThemeChanged: (theme) {
              ref.read(draftThemeConfigProvider.notifier).state = theme;
              ref.read(hasUnsavedThemeChangesProvider.notifier).state = true;
            },
          ),
        ),
        Expanded(
          child: AdminHomePreviewAdvanced(
            draftTheme: draftTheme,
          ),
        ),
      ],
    );
  }
}
```

### 5. Multi-Module Integration
```dart
// When editing multiple aspects at once
class CompleteStudioScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftLayout = ref.watch(draftHomeLayoutProvider);
    final draftBanners = ref.watch(draftBannersProvider);
    final draftPopups = ref.watch(draftPopupsV2Provider);
    final draftTheme = ref.watch(draftThemeConfigProvider);
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CompleteEditor(),
        ),
        Expanded(
          flex: 1,
          child: AdminHomePreviewAdvanced(
            draftHomeLayout: draftLayout,
            draftBanners: draftBanners,
            draftPopups: draftPopups,
            draftTheme: draftTheme,
          ),
        ),
      ],
    );
  }
}
```

## Best Practices

### 1. Draft State Management
Always use draft providers to avoid modifying published data:
```dart
// ✅ CORRECT: Use draft state
ref.read(draftBannersProvider.notifier).state = newBanners;

// ❌ WRONG: Don't modify published data directly
await bannerService.saveAllBanners(newBanners);
```

### 2. Save/Publish Flow
```dart
// When user clicks "Publish" or "Save"
Future<void> publishBanners(WidgetRef ref) async {
  final draftBanners = ref.read(draftBannersProvider);
  if (draftBanners == null) return;
  
  // Save to Firestore
  final service = ref.read(bannerServiceProvider);
  await service.saveAllBanners(draftBanners);
  
  // Clear draft state
  ref.read(draftBannersProvider.notifier).state = null;
  ref.read(hasUnsavedBannerChangesProvider.notifier).state = false;
  
  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Banners published successfully!')),
  );
}
```

### 3. Discard Changes
```dart
// When user clicks "Cancel" or "Discard"
void discardChanges(WidgetRef ref) {
  ref.read(draftBannersProvider.notifier).state = null;
  ref.read(hasUnsavedBannerChangesProvider.notifier).state = false;
}
```

### 4. Unsaved Changes Warning
```dart
class MyEditorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnsavedChanges = ref.watch(hasUnsavedBannerChangesProvider);
    
    return WillPopScope(
      onWillPop: () async {
        if (hasUnsavedChanges) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Unsaved Changes'),
              content: Text('You have unsaved changes. Discard them?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Discard'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: MyEditorContent(),
    );
  }
}
```

## Layout Patterns

### Horizontal Split (Recommended)
```dart
Row(
  children: [
    Expanded(flex: 2, child: Editor()),
    Expanded(flex: 1, child: Preview()),
  ],
)
```

### Vertical Split (Mobile/Tablet)
```dart
Column(
  children: [
    Expanded(flex: 1, child: Editor()),
    Expanded(flex: 1, child: Preview()),
  ],
)
```

### Tabbed View
```dart
TabBarView(
  children: [
    EditorTab(),
    PreviewTab(), // Full-screen preview
  ],
)
```

### Collapsible Preview
```dart
Row(
  children: [
    Expanded(child: Editor()),
    if (showPreview)
      Container(
        width: 400,
        child: AdminHomePreviewAdvanced(),
      ),
  ],
)
```

## Testing Preview Integration

1. **Load Module**: Verify preview appears on the right
2. **Make Changes**: Edit configuration in left panel
3. **Watch Preview**: Verify preview updates instantly
4. **Use Simulator**: Test different user types, times, etc.
5. **Publish**: Save changes and verify they persist
6. **Reload**: Verify changes appear in live app

## Performance Tips

1. Use `const` constructors where possible
2. Avoid rebuilding preview unnecessarily
3. Use selective watching (`select`) for large states
4. Consider debouncing rapid updates
5. Profile with Flutter DevTools if needed

## Troubleshooting

### Preview Not Updating
- Check that draft provider is being updated
- Verify preview widget is watching the correct provider
- Ensure ProviderScope is properly configured

### Preview Shows Old Data
- Clear draft state when entering module
- Verify priority: draft > firestore > defaults
- Check that overrides are being applied

### Performance Issues
- Reduce number of simultaneous previews
- Use `AutomaticKeepAliveClientMixin` if needed
- Consider lazy loading for heavy content

## Security Considerations

- Preview is read-only (simulation state only)
- Draft changes are local until explicitly published
- No production data is modified during preview
- All provider overrides are isolated in preview scope

## Additional Resources

- See `STUDIO_PREVIEW_TESTING.md` for test scenarios
- Check existing Studio modules for examples
- Refer to Riverpod documentation for advanced patterns
