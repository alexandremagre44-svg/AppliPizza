# Navigation Parameters Implementation (Option B)

## Overview
This document describes the implementation of navigation parameters in the page editor screen, allowing administrators to configure bottom navigation bar visibility and ordering.

## Quick Reference

### Files Modified
1. `lib/builder/services/builder_page_service.dart` - Added `updatePageNavigation()` method
2. `lib/builder/editor/builder_page_editor_screen.dart` - Added navigation parameters panel

### Files Unchanged (No Refactor)
- ✅ `lib/builder/models/builder_page.dart` - Fields already exist
- ✅ `lib/src/widgets/scaffold_with_nav_bar.dart` - Already uses correct filtering
- ✅ `lib/builder/services/builder_layout_service.dart` - Logic already implemented
- ✅ All module files (roulette, menu, cart, etc.)
- ✅ All published/draft layout management
- ✅ All system pages

## Usage Guide

### For Administrators

1. **Navigate to Page Editor**
   - Open Admin Panel → Builder Studio
   - Select a page from the list

2. **Configure Navigation**
   - Locate "Paramètres de navigation" panel (green background)
   - Toggle "Afficher dans la barre du bas" to show/hide in bottom bar
   - Select position (0-4) when page is active
   - Watch for duplicate warnings

3. **Save Changes**
   - Changes save automatically to Firestore
   - Bottom navigation bar updates immediately
   - Success message confirms the update

### For Developers

#### Update Navigation Programmatically

```dart
final pageService = BuilderPageService();

// Activate page at position 2
await pageService.updatePageNavigation(
  pageId: BuilderPageId.promo,
  appId: 'delizza',
  isActive: true,
  bottomNavIndex: 2,
);

// Deactivate page
await pageService.updatePageNavigation(
  pageId: BuilderPageId.promo,
  appId: 'delizza',
  isActive: false,
  bottomNavIndex: null,
);
```

#### Check for Duplicate Index

```dart
final allPages = await layoutService.loadAllDraftPages(appId);

for (final page in allPages.values) {
  if (page.isActive && page.bottomNavIndex == targetIndex) {
    print('Duplicate found: ${page.name}');
  }
}
```

## Technical Details

### Data Model

The `BuilderPage` model includes these fields:
- `isActive` (bool) - Whether page appears in bottom navigation
- `bottomNavIndex` (int) - Position in bottom bar (0-4)
- `order` (int) - Kept in sync with bottomNavIndex for compatibility

### Validation Rules

1. **Active Pages**:
   - Must have `bottomNavIndex` between 0 and 4
   - Cannot have duplicate `bottomNavIndex` with other active pages
   - Both draft and published versions are updated

2. **Inactive Pages**:
   - `bottomNavIndex` set to 999 (out of range)
   - `order` also set to 999
   - Page will not appear in bottom bar

### Firestore Structure

No schema changes required. Fields already exist:
```
restaurants/{restaurantId}/pages_draft/{pageId}
├── isActive: boolean
├── bottomNavIndex: number
└── order: number (synced with bottomNavIndex)

restaurants/{restaurantId}/pages_published/{pageId}
├── isActive: boolean
├── bottomNavIndex: number
└── order: number (synced with bottomNavIndex)
```

### Bottom Bar Logic

```dart
// BuilderLayoutService.getBottomBarPages()
bool _isBottomBarPage(BuilderPage page) {
  return page.isActive && 
         page.bottomNavIndex != null && 
         page.bottomNavIndex < 999;
}

void _sortByBottomNavIndex(List<BuilderPage> pages) {
  pages.sort((a, b) => 
    (a.bottomNavIndex ?? 999).compareTo(b.bottomNavIndex ?? 999));
}
```

## API Reference

### BuilderPageService.updatePageNavigation()

Updates navigation parameters for a page.

**Parameters:**
- `pageId` (BuilderPageId) - Page identifier
- `appId` (String) - Restaurant/app identifier
- `isActive` (bool) - Show in bottom navigation
- `bottomNavIndex` (int?) - Position (0-4), required if isActive

**Returns:**
- `BuilderPage?` - Updated page or null on validation failure

**Validation:**
- Checks bottomNavIndex range (0-4) for active pages
- Detects duplicate bottomNavIndex across pages
- Logs debug messages on validation failure

**Side Effects:**
- Updates draft version in Firestore
- Updates published version if it exists
- Sets order field to match bottomNavIndex

## Troubleshooting

### Page Not Appearing in Bottom Bar

1. Check `isActive` is true
2. Verify `bottomNavIndex` is between 0-4
3. Check for duplicate index warning
4. Verify published version exists

### Duplicate Index Warning

1. Review all active pages
2. Change one page to different index
3. Warning disappears automatically

### Invalid Data Warning

1. Check Firestore for corrupt data
2. Use dropdown to select valid index (0-4)
3. Save to fix invalid data

## Performance Notes

- Duplicate check caches result in component state
- Only triggers on page load and after updates
- Minimal Firestore reads (reuses existing queries)
- Two Firestore writes per update (draft + published)

## Backward Compatibility

- Existing pages work without modification
- Legacy `order` field maintained for old code
- System pages remain protected
- No breaking changes to navigation logic

## Security

- Uses existing service layer authentication
- Validates all inputs before Firestore update
- No direct Firestore access from UI
- CodeQL security check passed

## Support

For issues or questions:
1. Check debug logs for validation messages
2. Verify Firestore data structure
3. Review implementation summary document
4. Contact development team

---

**Implementation Date:** 2025-11-26  
**Version:** 1.0  
**Status:** ✅ Complete and tested
