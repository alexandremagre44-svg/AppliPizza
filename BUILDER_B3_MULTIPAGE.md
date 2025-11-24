# Builder B3 - Multi-Page System Documentation

## Overview

Complete multi-page support for Builder B3, allowing admins to customize all app pages (Home, Menu, Promo, About, Contact) with automatic fallback to default implementations.

## Architecture

### Pages Registry

`lib/builder/models/builder_pages_registry.dart`

Central registry with metadata for all pages:

```dart
class BuilderPageMetadata {
  final BuilderPageId pageId;
  final String name;
  final String description;
  final String route;
  final String icon;
}
```

**Available Pages:**
- 🏠 Home - Page d'accueil principale
- 📋 Menu - Catalogue de produits
- 🎁 Promo - Promotions et offres
- ℹ️ About - Informations sur le restaurant
- 📞 Contact - Coordonnées et contact

### Page Wrapper

`lib/builder/utils/builder_page_wrapper.dart`

Reusable wrapper that automatically loads Builder B3 layouts with fallback:

```dart
BuilderPageWrapper(
  pageId: BuilderPageId.menu,
  appId: 'pizza_delizza',
  fallbackBuilder: () => DefaultMenuWidget(),
)
```

**Features:**
- Loads published layout from Firestore
- Falls back to default implementation if no layout exists
- Error handling with automatic fallback
- Loading state management
- RefreshIndicator for manual refresh

## Page Implementations

### Home Screen ✅
**File:** `lib/src/screens/home/home_screen.dart`
- Full Builder B3 integration
- Automatic fallback to default behavior
- No breaking changes

### Menu Screen ✅
**File:** `lib/src/screens/menu/menu_screen.dart`
- Builder B3 wrapper with fallback
- Preserves all existing functionality
- Product grid, search, categories intact

### Promo Screen ✅ (NEW)
**File:** `lib/src/screens/promo/promo_screen.dart`
- New screen with Builder B3 support
- Default promo cards layout
- Ready for customization

### About Screen ✅ (NEW)
**File:** `lib/src/screens/about/about_screen.dart`
- New screen with Builder B3 support
- Default restaurant info layout
- Ready for customization

### Contact Screen ✅ (NEW)
**File:** `lib/src/screens/contact/contact_screen.dart`
- New screen with Builder B3 support
- Default contact info layout
- Ready for customization

## Admin Workflow

### Editing Pages

1. **Access Builder B3 Studio:**
   - Admin Menu → "🎨 Builder B3 - Constructeur de Pages"

2. **Select Page:**
   - List shows all 5 pages with metadata
   - Icons, names, descriptions visible
   - Click "Éditer" on any page

3. **Edit in Editor:**
   - Opens BuilderPageEditorScreen
   - Tab 1: Édition (blocks + config)
   - Tab 2: Prévisualisation (live preview)
   - Add/remove/reorder blocks
   - Configure block settings

4. **Save & Publish:**
   - Save Draft (💾) - saves to Firestore draft
   - Publish (📤) - publishes to production
   - Changes go live immediately

### Page-Specific Features

**Home:**
- Hero banners
- Product showcases
- Promotional sections
- Category shortcuts

**Menu:**
- Falls back to full product catalog
- Or custom Builder B3 layout

**Promo:**
- Promotional offers
- Special deals
- Limited time offers

**About:**
- Restaurant story
- Team information
- Philosophy & values

**Contact:**
- Contact information
- Hours & location
- Social media links

## User Experience

### With Published Layout
1. User opens app/page
2. BuilderPageWrapper loads published layout
3. BuilderRuntimeRenderer renders blocks
4. Full functionality (cart, navigation, etc.)

### Without Published Layout
1. User opens app/page
2. No published layout found
3. Automatic fallback to default implementation
4. Seamless experience, no errors

### Error Handling
- Firestore error → Fallback
- Invalid blocks → Skip gracefully
- Network error → Fallback
- No impact on user experience

## Technical Details

### Data Flow

```
Screen (e.g., MenuScreen)
    ↓
BuilderPageWrapper
    ↓
FutureBuilder loads BuilderLayoutService.loadPublished()
    ↓
Has layout? → Yes: BuilderRuntimeRenderer
             → No: fallbackBuilder()
```

### Firestore Structure

```
apps/
  └── pizza_delizza/
      └── builder/
          └── pages/
              ├── home/
              │   ├── draft
              │   └── published
              ├── menu/
              │   ├── draft
              │   └── published
              ├── promo/
              │   ├── draft
              │   └── published
              ├── about/
              │   ├── draft
              │   └── published
              └── contact/
                  ├── draft
                  └── published
```

### Performance

**Optimizations:**
- Single Firestore read per page load
- FutureBuilder caching
- No continuous polling
- Lazy block rendering
- Automatic error recovery

### Safety Features

**Non-Breaking:**
- ✅ All existing code preserved
- ✅ Automatic fallback always works
- ✅ Can unpublish to revert
- ✅ No breaking changes
- ✅ Gradual rollout possible

**Provider Integration:**
- ✅ All runtime widgets are ConsumerWidget
- ✅ Full provider access (cart, products, etc.)
- ✅ Navigation with GoRouter
- ✅ Modal dialogs supported
- ✅ Theme access

## Registry API

### Get Metadata

```dart
final metadata = BuilderPagesRegistry.getMetadata(BuilderPageId.menu);
print(metadata.name);        // "Menu"
print(metadata.icon);        // "📋"
print(metadata.route);       // "/menu"
print(metadata.description); // "Catalogue de produits et menu"
```

### Get All Pages

```dart
final allPages = BuilderPagesRegistry.pages;
final pageIds = BuilderPagesRegistry.getAllPageIds();
final routes = BuilderPagesRegistry.getAllRoutes();
```

### Get by Route

```dart
final metadata = BuilderPagesRegistry.getByRoute('/menu');
if (metadata != null) {
  print('Found page: ${metadata.name}');
}
```

## Common Patterns

### Create New Page with Builder B3

```dart
class MyScreen extends StatelessWidget {
  static const String appId = 'pizza_delizza';

  @override
  Widget build(BuildContext context) {
    return BuilderPageWrapper(
      pageId: BuilderPageId.myPage,
      appId: appId,
      fallbackBuilder: _buildDefault,
    );
  }

  Widget _buildDefault() {
    return Scaffold(
      appBar: AppBar(title: Text('My Page')),
      body: Center(child: Text('Default Content')),
    );
  }
}
```

### Custom Loading/Error States

```dart
BuilderPageWrapper(
  pageId: BuilderPageId.menu,
  appId: 'pizza_delizza',
  fallbackBuilder: _buildDefault,
  loadingBuilder: (context) => MyCustomLoader(),
  errorBuilder: (context, error) => MyErrorWidget(error),
)
```

## Benefits

### For Admins
- ✅ Edit any page without code
- ✅ Consistent editor interface
- ✅ Live preview before publishing
- ✅ Draft/publish workflow
- ✅ No technical knowledge required

### For Developers
- ✅ Zero code duplication
- ✅ Automatic fallback system
- ✅ Type-safe page identifiers
- ✅ Centralized registry
- ✅ Easy to extend

### For Users
- ✅ Seamless experience
- ✅ No breaking changes
- ✅ Graceful error handling
- ✅ Fast page loads
- ✅ Always functional

## Migration

**No migration needed!**

- Existing pages work as-is
- Builder B3 is optional overlay
- Admins build pages at their pace
- Users see seamless transition
- Can always revert by unpublishing

## Future Enhancements

Potential additions:
- Page scheduling (publish at specific time)
- A/B testing (multiple versions)
- Device-specific layouts (mobile/tablet/desktop)
- Page templates
- Import/export pages
- Page cloning
- Version history
- Analytics integration

## Troubleshooting

### Page Not Loading
- Check Firestore permissions
- Verify appId matches
- Check pageId is correct
- Look for console errors

### Fallback Not Working
- Verify fallbackBuilder returns valid widget
- Check for errors in default implementation
- Test with BuilderPageWrapper directly

### Changes Not Appearing
- Ensure page is published (not just draft)
- Check appId in code matches Firestore
- Try refreshing (pull down)
- Clear app cache

## Summary

Complete multi-page system with:
- ✅ 5 pages supported (Home, Menu, Promo, About, Contact)
- ✅ Central pages registry
- ✅ Reusable BuilderPageWrapper
- ✅ Automatic fallback system
- ✅ Zero code duplication
- ✅ Type-safe architecture
- ✅ Production-ready
- ✅ Fully documented

All pages can now be customized through Builder B3 while maintaining full backward compatibility and automatic fallback to default implementations.
