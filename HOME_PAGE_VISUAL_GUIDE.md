# Home Page Visual Guide

## Layout Structure

```
┌────────────────────────────────────────┐
│         AppBar (Red Header)            │
│     Pizza Deli'Zza                     │
│     À emporter uniquement              │
│  [🛍️ Cart]  [👤 Profile]              │
└────────────────────────────────────────┘
          ↓ (Scroll starts)
┌────────────────────────────────────────┐
│                                        │
│         HERO BANNER                    │
│  ┌──────────────────────────────────┐ │
│  │  [Background Image/Gradient]     │ │
│  │                                  │ │
│  │  Bienvenue chez                  │ │
│  │  Pizza Deli'Zza                  │ │
│  │                                  │ │
│  │  Découvrez nos pizzas...         │ │
│  │                                  │ │
│  │  [Voir le menu] (White button)   │ │
│  └──────────────────────────────────┘ │
│                                        │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│  🔥 Promos du moment                   │
│  ────────────────────                  │
│                                        │
│  ┌─────┐  ┌─────┐  ┌─────┐           │
│  │PROMO│  │PROMO│  │PROMO│  →        │
│  │ 🍕  │  │ 🍕  │  │ 🍕  │           │
│  │Pizza│  │Pizza│  │Menu │           │
│  │12.90│  │15.90│  │18.90│           │
│  └─────┘  └─────┘  └─────┘           │
│      (Horizontal scroll)               │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│  ⭐ Best-sellers                       │
│  ────────────                          │
│                                        │
│  ┌────────┐  ┌────────┐               │
│  │  🍕    │  │  🍕    │               │
│  │ Pizza  │  │ Pizza  │               │
│  │Margheri│  │Reine   │               │
│  │14.90 € │  │16.90 € │               │
│  │  [+]   │  │  [+]   │               │
│  └────────┘  └────────┘               │
│                                        │
│  ┌────────┐  ┌────────┐               │
│  │  🍕    │  │  🍕    │               │
│  │ Pizza  │  │ Pizza  │               │
│  │4 Froma │  │Végéta  │               │
│  │15.90 € │  │13.90 € │               │
│  │  [+]   │  │  [+]   │               │
│  └────────┘  └────────┘               │
│                                        │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│  Nos catégories                        │
│  ─────────────                         │
│                                        │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐     │
│  │  🍕 │ │  🎉 │ │  🥤 │ │  🍰 │     │
│  │Pizza│ │Menus│ │Bois.│ │Dess.│     │
│  └─────┘ └─────┘ └─────┘ └─────┘     │
│                                        │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│  ⓘ À emporter uniquement               │
│     11h–21h (Mar→Dim)                  │
└────────────────────────────────────────┘
```

## Color Scheme

### Primary Colors
- **Red**: `#B00020` - AppBar, buttons, prices, badges
- **White**: `#FFFFFF` - Text on red, card backgrounds
- **Light Gray**: `#F5F5F5` - Page background, info banner

### Text Colors
- **Dark**: `#212121` - Titles, main text
- **Medium**: `#666666` - Subtitles, descriptions
- **Light**: `#999999` - Secondary text

## Component Details

### 1. Hero Banner
- **Height**: 280px
- **Background**: Image (if provided) or red gradient
- **Overlay**: Dark gradient for text readability
- **Title**: 28px, bold, white
- **Subtitle**: 16px, regular, white (95% opacity)
- **Button**: White background, red text, rounded corners

### 2. Promo Cards (Compact)
- **Width**: 200px each
- **Height**: ~180px
- **Layout**: Horizontal scroll
- **Badge**: "PROMO" in red, top-left
- **Spacing**: 16px between cards

### 3. Best Sellers Grid
- **Columns**: 2
- **Aspect Ratio**: 0.75 (portrait cards)
- **Spacing**: 16px both directions
- **Card Style**: Same as ProductCard (reused)

### 4. Category Shortcuts
- **Count**: 4 buttons
- **Layout**: Equal width in a row
- **Icon Size**: 28px
- **Background**: White card with light red circle for icon
- **Interaction**: Navigates to Menu page

### 5. Info Banner
- **Background**: Light gray (#F5F5F5)
- **Border**: Subtle gray border
- **Text**: Center-aligned, medium gray
- **Icon**: Optional, 20px

## Spacing System

All spacing uses the `AppSpacing` constants:

```dart
xs:   4px   - Minimal spacing
sm:   8px   - Small gaps
md:   12px  - Medium gaps
lg:   16px  - Standard spacing (most common)
xl:   20px  - Large spacing
xxl:  24px  - Extra large
xxxl: 32px  - Section dividers
```

## Navigation Flow

```
Home Page
│
├─→ Hero "Voir le menu" button → Menu Page
│
├─→ Promo Card tap → Pizza/Menu Customization Modal
│
├─→ Best Seller Card tap → Pizza/Menu Customization Modal
│
├─→ Category button tap → Menu Page
│
└─→ Cart icon → Cart Page
```

## Responsive Behavior

### Small Screens (< 600px)
- Single column layout maintained
- Hero banner scales proportionally
- Promo cards remain horizontal scroll
- Best sellers: 2 columns (no change)
- Category buttons: 4 in a row (may be tight on very small screens)

### Medium Screens (600-900px)
- Same layout, more breathing room
- Better visibility of all elements

### Large Screens (> 900px)
- Content width constrained by padding
- Better aesthetics with more white space

## Data Flow

```
ProductProvider (Riverpod)
    │
    ├─→ Fetch all products
    │
    ├─→ Filter active products
    │
    ├─→ Filter promotions (displaySpot == 'promotions')
    │       └─→ Take first 3 → Promo Section
    │
    └─→ Filter featured (isFeatured == true)
            └─→ If empty: Take first 4 Pizzas
            └─→ Best Sellers Section
```

## Error States

### No Products
- Shows empty state with icon and message
- "Aucun produit disponible"

### No Promos
- Promo section simply hidden
- No visual indication needed

### No Best Sellers
- Shows message: "Aucun best-seller disponible"
- Fallback to pizzas prevents this in most cases

### Network Error
- Full-screen error state
- Red icon, error message, "Réessayer" button

## Loading States

### Initial Load
- Centered CircularProgressIndicator
- Red color matching brand

### Pull to Refresh
- Standard RefreshIndicator
- Red accent color

## Interactions

### Tap Behaviors
1. **Hero Button**: Push to Menu page
2. **Promo Card**: Open customization modal
3. **Best Seller Card**: Open customization modal
4. **Category Button**: Push to Menu page
5. **Cart Icon**: Push to Cart page
6. **Profile Icon**: Push to Profile page

### Modals
- **Pizza**: `ElegantPizzaCustomizationModal`
- **Menu**: `MenuCustomizationModal`
- **Other**: Direct add to cart with SnackBar

### SnackBar
- Shows "🍕 [Product Name] ajouté au panier !"
- Red background
- Floating behavior
- 2 second duration
- Rounded corners

## Accessibility

### Text Contrast
- White text on red/dark backgrounds
- Dark text on white/light backgrounds
- All meet WCAG AA standards

### Touch Targets
- All buttons minimum 44x44px
- Cards have full tap area
- Proper spacing between interactive elements

### Semantic Labels
- Proper widget hierarchy
- Descriptive text for screen readers
- Icons accompanied by labels

## Performance Considerations

### Optimizations
- `ConsumerWidget` (not Stateful) - fewer rebuilds
- `ListView.builder` for promos - efficient scrolling
- `GridView.builder` for best sellers - efficient rendering
- `shrinkWrap` on grid - prevents unnecessary height
- `.take(n)` limits data processing
- Efficient filtering with `.where()`

### Memory
- No image caching issues (using Image.network)
- Proper error handling on images
- Fallback icons when images fail

## Testing Scenarios

### Happy Path
1. ✅ Load home page
2. ✅ See hero banner
3. ✅ See promos (if available)
4. ✅ See best sellers
5. ✅ Tap "Voir le menu" → Goes to Menu
6. ✅ Tap category → Goes to Menu
7. ✅ Tap product → Opens modal
8. ✅ Add to cart → Shows SnackBar

### Edge Cases
1. ✅ No products at all → Shows empty state
2. ✅ No promos → Section hidden
3. ✅ No featured products → Shows pizzas
4. ✅ Network error → Shows error state
5. ✅ Pull to refresh → Reloads data
6. ✅ Small screen → No overflow
7. ✅ Image load error → Shows fallback icon

## Comparison with Menu Page

| Feature | Home Page | Menu Page |
|---------|-----------|-----------|
| Purpose | Showcase | Product catalog |
| Layout | Sections | Tabs + Grid |
| Navigation | CTA to Menu | Internal filtering |
| Search | No | Yes |
| Filters | No | Yes |
| Categories | Shortcuts | Tabs with filtering |
| Promos | Featured carousel | In "Promos" tab |
| Best Sellers | Featured grid | Mixed with all |
| Cart Bar | No | Yes (fixed) |

## Future Enhancements (Not Implemented)

1. **Hero Image Carousel**: Multiple hero images rotating
2. **Customer Reviews**: Show recent positive reviews
3. **Special Offers Timer**: Countdown for time-limited promos
4. **Seasonal Content**: Change hero based on season/holidays
5. **Personalized Recommendations**: Based on user history
6. **Social Proof**: "N customers ordered today"
7. **Quick Add**: Add to cart without modal for simple items
8. **Favorites Section**: Quick access to user favorites
9. **Story-style Banners**: Instagram-like stories for promos
10. **Location Info**: Map or directions widget
