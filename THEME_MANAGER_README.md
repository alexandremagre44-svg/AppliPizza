# Theme Manager PRO - Documentation

## Overview

The Theme Manager PRO is a comprehensive visual customization interface that allows administrators to customize the entire application's appearance in real-time. It provides a professional, user-friendly interface for managing colors, typography, spacing, shadows, border radius, and dark mode.

## Route

The Theme Manager is accessible at:
```
/admin/studio/v3/theme
```

Access from:
- Studio V2 Navigation → Configuration → Theme Manager PRO
- Direct navigation to the route (admin only)

## Features

### 1. Color Management
- **Primary Color**: Main brand color used throughout the app
- **Secondary Color**: Supporting brand color
- **Background Color**: Main background color
- **Surface Color**: Card and surface backgrounds
- **Text Primary**: Main text color
- **Text Secondary**: Secondary text color
- **Success Color**: Success states and messages
- **Warning Color**: Warning states and messages
- **Error Color**: Error states and messages

Each color can be selected using:
- Material color palette picker
- Custom color picker with RGB/HSV controls
- Direct hex input

### 2. Typography

#### Base Size
- Range: 10px - 24px
- Default: 14px
- Controls the base font size for the application

#### Scale Factor
- Range: 1.0 - 1.5
- Default: 1.2
- Multiplier for heading sizes relative to base size

#### Font Family
Available Google Fonts (with fallback support):
- Roboto (default)
- Open Sans
- Lato
- Montserrat
- Oswald
- Raleway
- PT Sans
- Merriweather
- Nunito
- Playfair Display

### 3. Border Radius

Controls the roundness of UI elements:
- **Small**: 0-16px (default: 8px) - Buttons, small cards
- **Medium**: 0-24px (default: 12px) - Cards, inputs
- **Large**: 0-32px (default: 16px) - Hero sections, modals

### 4. Shadows

Controls elevation and depth:
- **Card Shadow**: 0-16px (default: 2px) - Product cards, category cards
- **Modal Shadow**: 0-24px (default: 8px) - Dialogs, popups
- **Navbar Shadow**: 0-16px (default: 4px) - App bar, bottom navigation

### 5. Spacing

Controls padding throughout the app:
- **Padding Small**: 4-16px (default: 8px) - Tight spacing
- **Padding Medium**: 8-32px (default: 16px) - Standard spacing
- **Padding Large**: 16-48px (default: 24px) - Generous spacing

### 6. Dark Mode

Toggle switch to enable/disable dark mode globally:
- Automatically adjusts colors for dark theme
- Changes background to dark (#1E1E1E)
- Changes surface color to dark (#2C2C2C)
- Adjusts text colors for readability

### 7. Real-Time Preview

The right panel shows a live phone mockup displaying:
- Status bar
- App bar with branding
- Hero section with primary color
- Category cards
- Product cards
- Bottom navigation

All changes are reflected immediately in the preview.

### 8. Draft & Publish System

- All changes are local (draft mode) until published
- "Unsaved changes" indicator shows when modifications are pending
- **Publish**: Saves all changes to Firestore (config/theme)
- **Cancel**: Reverts all changes to last published state
- **Reset to Defaults**: Restores default theme configuration

## Firestore Structure

Theme configuration is stored at:
```
config/theme
```

### Schema

```javascript
{
  colors: {
    primary: 0xFFD32F2F,        // Color value as integer
    secondary: 0xFF8E4C4C,
    background: 0xFFF5F5F5,
    surface: 0xFFFFFFFF,
    textPrimary: 0xFF323232,
    textSecondary: 0xFF5A5A5A,
    success: 0xFF4CAF50,
    warning: 0xFFFF9800,
    error: 0xFFC62828
  },
  typography: {
    baseSize: 14.0,             // Double
    scaleFactor: 1.2,           // Double
    fontFamily: "Roboto"        // String
  },
  radius: {
    small: 8.0,                 // Double
    medium: 12.0,
    large: 16.0,
    full: 9999.0
  },
  shadows: {
    card: 2.0,                  // Double
    modal: 8.0,
    navbar: 4.0
  },
  spacing: {
    paddingSmall: 8.0,          // Double
    paddingMedium: 16.0,
    paddingLarge: 24.0
  },
  darkMode: false,              // Boolean
  updatedAt: "2025-01-01T00:00:00.000Z"  // ISO 8601 string
}
```

## Security

### Firestore Rules

Add the following rule to allow admin access:

```javascript
match /config/theme {
  allow read: if true;  // All users can read theme
  allow write: if request.auth != null && 
    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```

### Route Protection

The route is protected by admin-only middleware in main.dart:
```dart
if (!authState.isAdmin) {
  // Redirect to home
}
```

## Usage Guide

### For Administrators

1. **Access Theme Manager**
   - Navigate to Studio V2
   - Click "Theme Manager PRO" in the Configuration section
   - Or go directly to `/admin/studio/v3/theme`

2. **Customize Colors**
   - Click on any color block
   - Use the material palette for quick selection
   - Or use the color picker for precise control
   - Click "Select" to apply

3. **Adjust Typography**
   - Use sliders to change base size and scale factor
   - Select font family from dropdown
   - Changes appear immediately in preview

4. **Modify Spacing & Radius**
   - Use sliders to adjust values
   - Watch the preview update in real-time

5. **Enable Dark Mode**
   - Toggle the dark mode switch
   - Preview shows dark theme immediately

6. **Publish Changes**
   - Review all changes in the preview
   - Click "Publish" to save to database
   - Click "Cancel" to discard changes
   - Use "Reset to Defaults" to restore original theme

### For Developers

#### Import Theme Configuration

```dart
import 'package:pizza_delizza/src/models/theme_config.dart';
import 'package:pizza_delizza/src/services/theme_service.dart';
```

#### Load Theme

```dart
final themeService = ThemeService();
final themeConfig = await themeService.getThemeConfig();
```

#### Watch for Changes

```dart
final themeStream = themeService.watchThemeConfig();
themeStream.listen((config) {
  // Update UI with new theme
});
```

#### Apply Theme Values

```dart
Container(
  decoration: BoxDecoration(
    color: themeConfig.colors.surface,
    borderRadius: BorderRadius.circular(themeConfig.radius.medium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: themeConfig.shadows.card,
      ),
    ],
  ),
  padding: EdgeInsets.all(themeConfig.spacing.paddingMedium),
  child: Text(
    'Hello',
    style: TextStyle(
      fontSize: themeConfig.typography.baseSize,
      fontFamily: themeConfig.typography.fontFamily,
      color: themeConfig.colors.textPrimary,
    ),
  ),
)
```

## Architecture

### Models
- `ThemeConfig`: Main configuration model
- `ThemeColorsConfig`: Color configuration
- `TypographyConfig`: Typography settings
- `RadiusConfig`: Border radius settings
- `ShadowsConfig`: Shadow settings
- `SpacingConfig`: Spacing settings

### Services
- `ThemeService`: Handles Firestore operations
  - `getThemeConfig()`: Load current theme
  - `updateThemeConfig()`: Save theme changes
  - `resetToDefaults()`: Reset to default theme
  - `watchThemeConfig()`: Stream of theme updates

### Providers (Riverpod)
- `themeServiceProvider`: Theme service instance
- `themeConfigStreamProvider`: Stream of theme updates
- `themeConfigProvider`: Future of theme config
- `draftThemeConfigProvider`: Local draft state
- `hasUnsavedThemeChangesProvider`: Unsaved changes flag

### Screens
- `ThemeManagerScreen`: Main screen with app bar and layout
- `ThemeEditorPanel`: Left panel with all controls
- `ThemePreviewPanel`: Right panel with phone mockup

## Performance Considerations

1. **Draft Mode**: All changes are local until published, minimizing Firestore writes
2. **Batch Updates**: All theme changes saved in single transaction
3. **Optimistic UI**: Preview updates immediately without waiting for Firestore
4. **Efficient Rendering**: Only preview panel rebuilds on changes

## Future Enhancements

Potential improvements:
- Custom color palettes
- Theme presets (save/load custom themes)
- Export/import theme JSON
- A/B testing different themes
- Scheduled theme changes
- Per-section theme overrides
- Advanced typography (line height, letter spacing)
- Gradient support
- Animation timing controls

## Troubleshooting

### Theme Not Loading
- Check Firestore rules allow read access
- Verify config/theme document exists
- Check console for errors

### Changes Not Saving
- Verify admin authentication
- Check Firestore rules allow write for admins
- Ensure network connectivity

### Preview Not Updating
- Check browser console for errors
- Verify draft state is being updated
- Refresh the page

## Support

For issues or questions:
1. Check this documentation
2. Review Firestore rules
3. Check browser console for errors
4. Contact development team
