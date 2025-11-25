# Phase 7 - Builder Editor Upgrade

## Overview

This document describes the Phase 7 enhancements to the Builder B3 Editor system.
The Builder Editor is now fully usable for creating, editing, and publishing dynamic pages.

---

## 1. Supported Fields by Block Type

### Hero Block
| Field | Type | Description |
|-------|------|-------------|
| title | String | Main title text |
| subtitle | String | Secondary text (optional) |
| buttonLabel | String | CTA button text |
| imageUrl | String | Background image URL |
| alignment | Enum | Text alignment (left, center, right) |
| heightPreset | Enum | Height preset (small, normal, large) |
| backgroundColor | Color | Background color (hex) |
| textColor | Color | Text color (hex) |
| tapAction | Enum | Action type (none, openPage, openLegacyPage, openUrl) |
| tapActionTarget | String | Target for the action |

### Text Block
| Field | Type | Description |
|-------|------|-------------|
| content | String | Text content |
| alignment | Enum | Text alignment (left, center, right) |
| size | Enum | Font size (small, normal, large, title, heading) |
| bold | Boolean | Bold text |
| color | Color | Text color (hex) |
| padding | Number | Inner padding (px) |
| maxLines | Number | Maximum lines (0 = unlimited) |
| tapAction | Enum | Action type |
| tapActionTarget | String | Target for the action |

### Product List Block
| Field | Type | Description |
|-------|------|-------------|
| title | String | Section title |
| titleAlignment | Enum | Title alignment (left, center, right) |
| titleSize | Enum | Title size (small, medium, large) |
| mode | Enum | Selection mode (featured, manual, top_selling, promo) |
| categoryId | String | Filter by category |
| layout | Enum | Display layout (grid, carousel, list) |
| productIds | String | Comma-separated product IDs (manual mode) |
| limit | Number | Maximum products to show |
| backgroundColor | Color | Background color |
| textColor | Color | Text color |
| borderRadius | Number | Corner radius (px) |
| elevation | Number | Shadow depth (0-24) |
| actionOnProductTap | Enum | Product tap action (openProductDetail, openPage) |

### Banner Block
| Field | Type | Description |
|-------|------|-------------|
| title | String | Main title |
| subtitle | String | Secondary text |
| text | String | Fallback text |
| imageUrl | String | Background image URL |
| ctaLabel | String | CTA button text |
| ctaAction | String | CTA route |
| style | Enum | Banner style (info, promo, warning, success) |
| backgroundColor | Color | Background color |
| textColor | Color | Text color |
| tapAction | Enum | Action type |
| tapActionTarget | String | Target for the action |

### Button Block
| Field | Type | Description |
|-------|------|-------------|
| label | String | Button text |
| style | Enum | Button style (primary, secondary, outline, text) |
| alignment | Enum | Button alignment (left, center, right, stretch) |
| backgroundColor | Color | Button color |
| textColor | Color | Button text color |
| borderRadius | Number | Corner radius (px) |
| tapAction | Enum | Action type |
| tapActionTarget | String | Target for the action |

### Image Block
| Field | Type | Description |
|-------|------|-------------|
| imageUrl | String | Image URL |
| caption | String | Caption text |
| alignment | Enum | Image alignment (left, center, right) |
| fit | Enum | Image fit (cover, contain, fill, fitWidth, fitHeight) |
| height | Number | Image height (px) |
| borderRadius | Number | Corner radius (px) |
| tapAction | Enum | Action type |
| tapActionTarget | String | Target for the action |

### Spacer Block
| Field | Type | Description |
|-------|------|-------------|
| height | Number | Spacer height (px) |

### Info Block
| Field | Type | Description |
|-------|------|-------------|
| title | String | Info title |
| content | String | Info content |
| icon | Enum | Icon (info, warning, success, error, time, phone, location, email) |
| highlight | Boolean | Highlight style |
| backgroundColor | Color | Background color |
| actionType | Enum | Action type (none, call, email, navigate) |
| actionValue | String | Action target |

### Category List Block
| Field | Type | Description |
|-------|------|-------------|
| title | String | Section title |
| mode | Enum | Selection mode (auto, custom) |
| layout | Enum | Display layout (horizontal, grid, carousel) |
| tapAction | Enum | Action type |
| tapActionTarget | String | Target for the action |

### HTML Block
| Field | Type | Description |
|-------|------|-------------|
| htmlContent | String | Custom HTML content |

---

## 2. Tap Actions System

### Action Types

| Type | Description | Config |
|------|-------------|--------|
| `none` | No action | - |
| `openPage` | Navigate to Builder page | `tapActionTarget` = page ID |
| `openLegacyPage` | Navigate to app route | `tapActionTarget` = route path |
| `openUrl` | Open external URL | `tapActionTarget` = full URL |

### Legacy Routes Available

- `/home` - Home
- `/menu` - Menu
- `/cart` - Cart
- `/profile` - Profile
- `/orders` - Orders
- `/roulette` - Roulette game
- `/rewards` - Rewards
- `/checkout` - Checkout
- `/login` - Login
- `/register` - Register
- `/settings` - Settings
- `/about` - About
- `/contact` - Contact

### Config Structure

```json
{
  "tapAction": "openPage",
  "tapActionTarget": "promo_page"
}
```

---

## 3. Draft / Publish Workflow

### Auto-Save

- Changes are automatically saved to draft after 2 seconds of inactivity
- Manual save button available for immediate save
- Progress indicator shows when auto-save is in progress

### Loading Draft

1. Editor opens → loads draft from Firestore
2. If no draft exists → creates default empty page
3. Full block list and config is restored

### Publishing

1. Click "Publier" button
2. Confirmation dialog appears
3. On confirm:
   - Draft is written to published document
   - Preview panel refreshes
   - Success toast displayed: "✅ Page publiée avec succès"
4. Published pages are visible in the app runtime

### Firestore Structure

```
builder/
  apps/
    {appId}/
      pages/
        {pageId}/
          draft     ← Working version (editor)
          published ← Live version (app runtime)
```

---

## 4. Creating New Pages

### Steps

1. Click "Créer une page" button (or use floating action)
2. Fill in the dialog:
   - **Titre de la page** (required): Display name
   - **ID de la page**: Auto-generated from title
   - **Emplacement d'affichage**:
     - `bottomBar`: Appears in bottom navigation
     - `hidden`: Accessible only via actions
     - `internal`: System pages
   - **Ordre**: Position in bottom bar (lower = first)
   - **Icône**: Select from available icons

3. Click "Créer la page"
4. New draft is created in Firestore
5. Editor opens automatically for the new page

### Available Icons

- home, menu_book, local_offer, info
- contact_mail, star, favorite, settings
- person, shopping_cart, card_giftcard
- new_releases, help_outline, article, photo_library

---

## 5. Bottom Bar Integration

### Fields That Affect Bottom Bar

| Field | Effect |
|-------|--------|
| `displayLocation` | `bottomBar` = visible in nav, `hidden` = not visible |
| `icon` | Icon shown in bottom bar |
| `order` | Position (lower number = appears first) |

### How It Works

1. When a page is **published** with `displayLocation: 'bottomBar'`
2. The bottom bar provider reloads page list
3. New page appears/updates immediately
4. No app redeployment needed

---

## 6. Preview / Runtime Alignment

### Responsive Breakpoints

| Breakpoint | Width | Behavior |
|------------|-------|----------|
| Mobile | < 600px | Full width, compact cards |
| Tablet | 600px - 1024px | Medium padding, 3 columns |
| Desktop | > 1024px | Max 1200px width, centered |

### Max Content Width

```dart
static const double maxContentWidth = 1200;
```

Content is centered on screens wider than 1200px.

### Consistent Padding

| Device | Horizontal Padding |
|--------|-------------------|
| Mobile | 12px |
| Tablet | 16px |
| Desktop | 24px |

---

## 7. Technical Implementation

### Files Modified

- `lib/builder/editor/builder_page_editor_screen.dart`
- `lib/builder/editor/new_page_dialog.dart` (NEW)
- `lib/builder/editor/editor.dart`
- `lib/builder/utils/action_helper.dart`
- `lib/builder/utils/responsive.dart`

### Key Features

1. **Auto-save**: Timer-based draft saving (2s delay)
2. **Tap action fields**: Reusable `_buildTapActionFields()` widget
3. **Number fields**: `_buildNumberField()` for int values
4. **Update multiple**: `_updateBlockConfigMultiple()` for batch updates
5. **Legacy routes**: `LegacyRoutes` class for route picker

---

## 8. Migration Notes

### Breaking Changes

None. All changes are additive.

### New Default Configs

Blocks now include more default values. Existing blocks will use fallback defaults.

### Recommended Actions

1. Re-save drafts to include new field defaults
2. Test tap actions on existing blocks
3. Verify bottom bar updates after publishing
