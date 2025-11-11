# Visual Implementation Guide

## Admin Interface Examples

### Product Edit Dialog

When editing a product (Pizza, Menu, Drink, or Dessert), admins see:

#### 1. Order Field
```
┌─────────────────────────────────┐
│ Ordre d'affichage               │
│ ┌─────────────────────────────┐ │
│ │ [Sort Icon] Ex: 1, 2, 3...  │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

#### 2. Featured Toggle
```
┌─────────────────────────────────┐
│ [Star Icon] Mise en avant       │
│ Afficher ce produit en priorité │
│                        [Toggle] │
└─────────────────────────────────┘
```

#### 3. Active Status Toggle
```
┌─────────────────────────────────┐
│ [Eye Icon] Produit actif        │
│ Visible par les clients         │
│                        [Toggle] │
└─────────────────────────────────┘
```

#### 4. Display Location Selector
```
┌─────────────────────────────────┐
│ [Location Icon] Zone d'affichage│
│                                 │
│ [Partout] [Accueil]             │
│ [Promotions] [Nouveautés]       │
└─────────────────────────────────┘
```

### Product List View

Admin sees products with status badges:

```
┌────────────────────────────────────────┐
│ [Image] Pizza Margherita   [Inactif]  │
│         Description...                 │
│         12.50 €          [Edit] [Del]  │
└────────────────────────────────────────┘

┌────────────────────────────────────────┐
│ [Image] Pizza Quatre      [En avant]  │
│         Fromages                       │
│         14.90 €          [Edit] [Del]  │
└────────────────────────────────────────┘
```

## Client Interface Examples

### Product Card with Featured Badge

Regular product:
```
┌────────────────────┐
│  [Product Image]   │
│                    │
└────────────────────┘
  Pizza Margherita
  Tomate, Mozzarella
  [12.50 €] [Cart+]
```

Featured product:
```
┌────────────────────┐
│  [Product Image]   │
│            [VEDETTE│
│                 ⭐]│
└────────────────────┘
  Pizza Quatre Fromages
  4 fromages italiens
  [14.90 €] [Cart+]
```

Featured menu (circular badge):
```
┌────────────────────┐
│ [MENU]             │
│  [Product Image] [⭐]│
│                    │
└────────────────────┘
  Menu Duo
  1 pizza + 1 boisson
  [18.90 €] [Cart+]
```

### Home Screen Sections

The home screen dynamically shows sections based on displaySpot:

```
┌────────────────────────────────────┐
│ 🏠 Accueil                         │
├────────────────────────────────────┤
│                                    │
│ ⭐ Sélection du Chef               │
│ [Featured Product 1] [Featured 2]  │
│                                    │
│ 🔥 Promotions                      │
│ [Promo Product 1] [Promo 2]        │
│                                    │
│ ✨ Nouveautés                      │
│ [New Product 1] [New 2]            │
│                                    │
│ Pizzas Populaires 🍕               │
│ [Pizza 1] [Pizza 2] [Pizza 3]      │
│                                    │
│ Nos Meilleurs Menus 🎉             │
│ [Menu 1] [Menu 2]                  │
│                                    │
└────────────────────────────────────┘
```

### Menu Screen Filtering

Menu screen shows only active products:

```
┌────────────────────────────────────┐
│ Notre Menu                         │
├────────────────────────────────────┤
│ [Search: Pizza...]                 │
│                                    │
│ [Tous] [Pizza] [Menus] [Boissons]  │
│                                    │
│ ┌──────────┐ ┌──────────┐         │
│ │ Pizza 1  │ │ Pizza 2  │         │
│ │ Active   │ │ Active   │         │
│ └──────────┘ └──────────┘         │
│                                    │
│ (Inactive products not shown)      │
│                                    │
└────────────────────────────────────┘
```

## User Flow Examples

### Example 1: Creating a Promotion

Admin:
1. Create new pizza "Margherita Promo"
2. Set price to 9.99€ (reduced)
3. Select displaySpot: "Promotions"
4. Toggle "Mise en avant": ON
5. Toggle "Produit actif": ON
6. Set order: 1 (high priority)
7. Save

Client:
- Product appears in "🔥 Promotions" section on home
- Shows "VEDETTE" badge
- Appears first (order = 1)
- Visible in menu screen
- Can be added to cart

### Example 2: Launching a New Product

Admin:
1. Create new pizza "Pizza du Chef"
2. Select displaySpot: "Nouveautés"
3. Toggle "Mise en avant": ON
4. Toggle "Produit actif": ON
5. Set order: 1
6. Save

Client:
- Product appears in "✨ Nouveautés" section
- Shows "VEDETTE" badge
- Highly visible to customers
- Visible in menu screen

### Example 3: Deactivating Seasonal Product

Admin:
1. Open product "Pizza Été"
2. Toggle "Produit actif": OFF
3. Save

Client:
- Product disappears from home screen
- Product disappears from menu screen
- Not searchable
- Cannot be ordered
- Data preserved for reactivation

### Example 4: Featured Product for Home Page

Admin:
1. Open product "Pizza Signature"
2. Select displaySpot: "Accueil"
3. Toggle "Mise en avant": ON
4. Set order: 1
5. Save

Client:
- Product appears on home page
- Shows in "⭐ Sélection du Chef"
- Shows "VEDETTE" badge
- Highly promoted to customers

## Badge Styling

### Featured Badge (VEDETTE)
- Color: Amber gradient (400-600)
- Icon: Star (⭐)
- Shadow: Amber with opacity
- Text: Bold, uppercase, white
- Position: Top-right corner

### Inactive Badge (Admin Only)
- Color: Gray (200)
- Icon: Visibility off
- Text: Gray (700), bold
- Shows: "Inactif"

### Featured Badge in Admin (En avant)
- Color: Amber (100 background)
- Icon: Star
- Text: Amber (700), bold
- Shows: "En avant"

## Responsive Design

All badges and UI elements:
- Scale properly on different screen sizes
- Maintain readability
- Don't overlap with content
- Use flexible layouts
- Support portrait and landscape

## Accessibility

- Badges have sufficient color contrast
- Icons supplement text (not replace)
- Touch targets are adequately sized
- Status clearly communicated
- Screen reader friendly labels

## Performance Considerations

- Filtering happens at data layer
- Efficient widget rebuilding
- Images cached properly
- Smooth scrolling maintained
- No performance degradation with many products
