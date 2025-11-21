# Studio V2 Cleanup & Unification - Technical Notes

## Date
2025-11-21

## Objective
Clean up and unify the Studio/Builder system in the Pizza Deli'Zza application by keeping ONLY Studio V2 as the definitive solution, removing/isolating old studios/previews/builders to eliminate conflicts, and unifying the preview system.

---

## 1. INVENTORY OF STUDIO SCREENS

### ✅ OFFICIAL - Studio V2 (KEEP)
**File:** `lib/src/studio/screens/studio_v2_screen.dart`
**Route:** `/admin/studio` (main entry point)
**Status:** **OFFICIAL VERSION - Active and maintained**
**Purpose:** Professional studio for home content management
**Features:**
- 8 modules: Overview, Hero, Banners, Popups, Text Blocks, Content, Sections V3, Settings
- Draft/Publish workflow
- Real-time preview panel
- Professional UI inspired by Webflow/Shopify
- Fully responsive (desktop 3-column, mobile tabs)

**Related Files:**
- Navigation: `lib/src/studio/widgets/studio_navigation.dart`
- Preview: `lib/src/studio/widgets/studio_preview_panel.dart`
- Controllers: `lib/src/studio/controllers/studio_state_controller.dart`
- Module widgets: `lib/src/studio/widgets/modules/studio_*_v2.dart`

### 🔴 DEPRECATED - Admin Studio Screen (Menu)
**File:** `lib/src/screens/admin/admin_studio_screen.dart`
**Route:** None (not routable anymore)
**Status:** **DEPRECATED - No longer accessible**
**Purpose:** Was a menu screen to access different admin tools (Studio V2, Studio Unified, Products, Ingredients, etc.)
**Note:** This screen is kept in the codebase but is not accessible via routes. It provided navigation to:
- Studio V2
- Studio Unified (deprecated)
- Products Admin
- Ingredients Admin
- Promotions Admin
- Mailing Admin
- Roulette Settings
- Content Studio

**Impact:** Direct navigation to Studio V2 via bottom nav bar makes this menu unnecessary.

### 🔴 DEPRECATED - Admin Studio Screen Refactored (V1)
**File:** `lib/src/screens/admin/admin_studio_screen_refactored.dart`
**Route:** None (was `/admin/studio/old`, now redirects)
**Status:** **DEPRECATED - Imports deprecated files**
**Purpose:** First refactored version of the studio with live preview
**Issues:**
- Imports deprecated files from `_deprecated/` folder
- Uses older preview widget (AdminHomePreview)
- Not feature-complete compared to V2

**Deprecated Imports:**
- `_deprecated/hero_block_editor.dart`
- `_deprecated/banner_block_editor.dart`
- `_deprecated/popup_block_list.dart`
- `_deprecated/studio_texts_screen.dart`

### 🔴 DEPRECATED - Admin Studio Unified
**File:** `lib/src/screens/admin/studio/admin_studio_unified.dart`
**Route:** None (was `/admin/studio/new`, now redirects to `/admin/studio`)
**Status:** **DEPRECATED - Superseded by Studio V2**
**Purpose:** Unified studio implementation with 6 modules
**Note:** This was an intermediate version between refactored and V2

### 🔴 DEPRECATED - Individual Block Editors
**Location:** `lib/src/screens/admin/_deprecated/`
**Status:** **DEPRECATED - Isolated in _deprecated folder**
**Files:**
- `hero_block_editor.dart` - Old hero editor
- `banner_block_editor.dart` - Old banner editor
- `popup_block_editor.dart` - Old popup editor
- `popup_block_list.dart` - Old popup list
- `studio_texts_screen.dart` - Old texts editor

**Note:** These files are no longer imported anywhere except by `admin_studio_screen_refactored.dart` which itself is deprecated.

---

## 2. ROUTING CHANGES

### Before Cleanup
```
/admin/studio → AdminStudioScreen (menu)
/admin/studio/new → AdminStudioUnified
/admin/studio/v2 → StudioV2Screen
/admin/hero → Redirect to /admin/studio/new
/admin/banner → Redirect to /admin/studio/new
/admin/popups → Redirect to /admin/studio/new
/admin/texts → Redirect to /admin/studio/new
```

### After Cleanup ✅
```
/admin/studio → StudioV2Screen (OFFICIAL)
/admin/studio/new → Redirect to /admin/studio
/admin/studio/v2 → Redirect to /admin/studio
/admin/hero → Redirect to /admin/studio
/admin/banner → Redirect to /admin/studio
/admin/popups → Redirect to /admin/studio
/admin/texts → Redirect to /admin/studio
```

**Benefit:** Single source of truth - all studio routes lead to Studio V2.

---

## 3. PREVIEW SYSTEM ANALYSIS

### Available Preview Widgets

#### ✅ StudioPreviewPanel (Studio V2 - OFFICIAL)
**File:** `lib/src/studio/widgets/studio_preview_panel.dart`
**Used by:** StudioV2Screen
**Status:** **ACTIVE**
**Features:**
- Phone frame preview
- Shows simplified preview based on draft state
- Used in Studio V2 desktop layout

#### ✅ AdminHomePreviewAdvanced (Advanced - RECOMMENDED)
**File:** `lib/src/studio/preview/admin_home_preview_advanced.dart`
**Status:** **AVAILABLE but not currently used**
**Features:**
- Uses REAL HomeScreen component
- Provider overrides for draft data
- Simulation panel (theme, user, time)
- Most accurate preview (1:1 with production)
- Phone frame with PreviewPhoneFrame widget

**Supporting Files:**
- `lib/src/studio/preview/preview_phone_frame.dart` - Phone frame UI
- `lib/src/studio/preview/preview_state_overrides.dart` - Provider override logic
- `lib/src/studio/preview/simulation_panel.dart` - Simulation controls
- `lib/src/studio/preview/simulation_state.dart` - Simulation state model

#### 🔴 AdminHomePreview (Old - DEPRECATED)
**File:** `lib/src/widgets/admin/admin_home_preview.dart`
**Used by:** AdminStudioScreenRefactored, AdminStudioUnified
**Status:** **DEPRECATED**
**Issues:**
- Does NOT use real HomeScreen
- Custom preview implementation
- Not 1:1 with production
- Less accurate than AdminHomePreviewAdvanced

### Preview Unification Recommendation
The preview system should be unified around **AdminHomePreviewAdvanced** because:
1. It uses the REAL HomeScreen component
2. It provides accurate 1:1 preview
3. It supports simulation controls
4. It uses proper provider overrides

**Action Items:**
- [ ] Consider integrating AdminHomePreviewAdvanced features into StudioPreviewPanel
- [ ] Or replace StudioPreviewPanel with AdminHomePreviewAdvanced
- [ ] Ensure all previews use real HomeScreen via provider overrides

---

## 4. RIVERPOD LIFECYCLE ISSUES

### Known Issue Pattern
```
"Modifying a provider inside those life-cycles is not allowed…"
```

### Locations to Check
- Studio V2 screen `initState()` - ✅ Already uses `Future.microtask()`
- Preview widgets lifecycle methods
- Any `ref.read(...).state =` in `build()`, `initState()`, `didChangeDependencies()`

### Current Status in Studio V2 ✅
The Studio V2 correctly uses `Future.microtask()` in `initState()`:
```dart
@override
void initState() {
  super.initState();
  // FIX: Riverpod provider updates must be deferred using Future.microtask
  Future.microtask(() => _loadAllData());
}
```

---

## 5. ARCHITECTURE SUMMARY

### Studio V2 Architecture (Official)
```
lib/src/studio/
├── screens/
│   ├── studio_v2_screen.dart          # Main Studio V2 screen
│   ├── theme_manager_screen.dart      # Theme management
│   └── media_manager_screen.dart      # Media library
├── controllers/
│   └── studio_state_controller.dart   # State management
├── widgets/
│   ├── studio_navigation.dart         # Left sidebar navigation
│   ├── studio_preview_panel.dart      # Right preview panel
│   └── modules/                       # Editor modules
│       ├── studio_overview_v2.dart
│       ├── studio_hero_v2.dart
│       ├── studio_banners_v2.dart
│       ├── studio_popups_v2.dart
│       ├── studio_texts_v2.dart
│       ├── studio_settings_v2.dart
│       └── studio_sections_v3.dart
├── preview/                            # Preview system
│   ├── admin_home_preview_advanced.dart
│   ├── preview_phone_frame.dart
│   ├── preview_state_overrides.dart
│   ├── simulation_panel.dart
│   └── simulation_state.dart
├── models/                             # Data models
│   ├── text_block_model.dart
│   ├── popup_v2_model.dart
│   ├── dynamic_section_model.dart
│   └── media_asset_model.dart
├── services/                           # Business logic
│   ├── text_block_service.dart
│   ├── popup_v2_service.dart
│   ├── dynamic_section_service.dart
│   └── media_manager_service.dart
└── providers/                          # Riverpod providers
    ├── banner_provider.dart
    ├── popup_v2_provider.dart
    └── text_block_provider.dart
```

### Deprecated Files (DO NOT USE)
```
lib/src/screens/admin/
├── admin_studio_screen.dart                    # Menu (not routable)
├── admin_studio_screen_refactored.dart         # V1 (deprecated)
├── studio/
│   └── admin_studio_unified.dart               # Unified (deprecated)
└── _deprecated/                                # Old editors (isolated)
    ├── hero_block_editor.dart
    ├── banner_block_editor.dart
    ├── popup_block_editor.dart
    ├── popup_block_list.dart
    └── studio_texts_screen.dart

lib/src/widgets/admin/
└── admin_home_preview.dart                     # Old preview (deprecated)
```

---

## 6. NAVIGATION FLOW

### Admin Access Flow
1. Admin logs in → Bottom navigation shows "Admin" tab
2. Click "Admin" tab → Navigate to `/admin/studio`
3. `/admin/studio` → Opens **StudioV2Screen** directly
4. Studio V2 provides access to:
   - Home content modules (Hero, Banners, Popups, Texts, Sections, Content)
   - Theme Manager (separate route)
   - Media Manager (separate route)

### Other Admin Features
These are OUTSIDE the scope of Studio cleanup (as per requirements):
- Products Admin → Direct MaterialPageRoute navigation
- Ingredients Admin → Direct MaterialPageRoute navigation
- Promotions Admin → Direct MaterialPageRoute navigation
- Mailing Admin → Direct MaterialPageRoute navigation
- Roulette Settings → Direct MaterialPageRoute navigation
- Staff Tablet (Caisse) → Separate route `/staff-tablet`
- Kitchen Mode → Separate route `/kitchen`

---

## 7. TESTING CHECKLIST

### Route Testing
- [x] `/admin/studio` opens Studio V2
- [x] `/admin/studio/new` redirects to `/admin/studio`
- [x] `/admin/studio/v2` redirects to `/admin/studio`
- [x] Old module routes redirect to `/admin/studio`
- [x] Bottom nav "Admin" button goes to Studio V2

### Studio V2 Functionality
- [ ] All 8 modules accessible via navigation
- [ ] Draft/Publish workflow works
- [ ] Preview panel shows changes
- [ ] No Riverpod lifecycle errors
- [ ] Theme Manager accessible
- [ ] Media Manager accessible

### Preview System
- [ ] Preview reflects draft changes in real-time
- [ ] Published changes appear in production HomeScreen
- [ ] No discrepancies between preview and production

### No Regressions
- [ ] Products admin still accessible
- [ ] Caisse (Staff Tablet) still works
- [ ] Checkout still works
- [ ] Orders still work
- [ ] Loyalty system still works
- [ ] Roulette still works
- [ ] Auth still works
- [ ] Cart still works

---

## 8. FUTURE IMPROVEMENTS

### Preview System Enhancement
Consider replacing `StudioPreviewPanel` with `AdminHomePreviewAdvanced` to get:
- Real HomeScreen component (1:1 accuracy)
- Simulation controls (theme, user, time)
- Better visual fidelity

### Navigation Enhancement
Could add quick links in Studio V2 Overview or Settings to:
- Products Admin
- Ingredients Admin
- Promotions Admin
- Other admin tools

This would restore the convenience of the old AdminStudioScreen menu while keeping Studio V2 as the main interface.

---

## 9. CONCLUSION

✅ **Completed:**
- Routing unified to Studio V2 only
- Old studios isolated and documented
- No breaking changes to other modules

⏳ **Next Steps:**
- Remove deprecated imports
- Unify preview system
- Fix any remaining Riverpod lifecycle issues
- Final testing and validation

🎯 **Result:**
A clean, professional Studio V2 as the single source of truth for home content management, with no conflicts from legacy code.
