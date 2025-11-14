# Module 2: Popups & Roulette - Testing Guide

## 🧪 Prerequisites

Before testing, ensure:
1. ✅ Flutter dependencies are installed: `flutter pub get`
2. ✅ Firebase is configured and running
3. ✅ You have an admin account for testing admin features
4. ✅ You have a regular user account for testing client features

---

## Part A: Testing Configurable Popups

### 1. Admin Interface Testing

#### Access the Popup Studio
1. **Login as admin**
2. **Navigate to**: `/admin/studio/popups-roulette`
3. **Expected**: See tabbed interface with "Popups" and "Roulette" tabs

#### Test: Create a Popup (Desktop)
1. **Click** the `+` button or "Popups" tab
2. **Expected**: Opens EditPopupScreen with split-screen layout
3. **Left side**: Configuration form
4. **Right side**: Live preview

#### Test: Template System
1. **In EditPopupScreen**, click template chip (e.g., "Offre Spéciale")
2. **Expected**: Form fields auto-populate with template data
3. **Preview updates** in real-time on the right
4. **Verify**: 
   - Title: "🎉 Offre Spéciale !"
   - Message: Pre-filled offer text
   - Button text and link pre-filled

#### Test: Image Upload
1. **Click** "Ajouter une image" button
2. **Select** an image from gallery (< 10MB)
3. **Expected**: 
   - Image preview appears in form
   - Image preview appears in live preview
   - X button to remove image
4. **Try**: Upload oversized image (> 10MB)
5. **Expected**: Error message "Image invalide. Taille max: 10MB"

#### Test: Form Fields
1. **Type** in Title field
2. **Expected**: Preview updates immediately
3. **Type** in Message field (multiline)
4. **Expected**: Preview updates with formatted text
5. **Add** button text
6. **Expected**: Button appears in preview
7. **Add** button link (e.g., "/menu")
8. **Expected**: Button shows in preview

#### Test: Trigger Selection
1. **Select** "À l'ouverture de l'app" from Déclencheur dropdown
2. **Expected**: Selection saved to model
3. **Select** "Au scroll sur l'accueil"
4. **Expected**: Selection changes

#### Test: Audience Selection
1. **Select** "Tous les utilisateurs"
2. **Expected**: Will show to all users
3. **Try** other options: "Nouveaux utilisateurs", "Utilisateurs fidèles"
4. **Expected**: Each selection saves correctly

#### Test: Date Pickers
1. **Click** "Date de début" button
2. **Expected**: Date picker opens
3. **Select** a future date
4. **Expected**: Date displays on button
5. **Repeat** for "Date de fin"
6. **Verify**: End date cannot be before start date (if implemented)

#### Test: Enable Toggle
1. **Toggle** "Popup actif" switch
2. **Expected**: Switch changes state
3. **Create/Save** the popup
4. **Expected**: Returns to list view

#### Test: Save Popup
1. **Fill** required fields (Title, Message)
2. **Click** "Créer" / "Enregistrer" button
3. **Expected**: 
   - Loading indicator appears
   - Returns to list on success
   - Snackbar shows "Popup créé"
4. **Try**: Save without title
5. **Expected**: Error "Le titre est requis"

#### Test: Edit Existing Popup
1. **In list view**, expand a popup
2. **Click** "Modifier" button
3. **Expected**: Opens EditPopupScreen with existing data
4. **Modify** some fields
5. **Save**
6. **Expected**: Changes reflected in list

#### Test: Delete Popup
1. **In list view**, expand a popup
2. **Click** "Supprimer" button
3. **Expected**: Confirmation dialog
4. **Click** "Supprimer" in dialog
5. **Expected**: 
   - Popup removed from list
   - Snackbar shows "Popup supprimé"

#### Test: Mobile Responsive
1. **Resize** browser to mobile width (< 800px)
2. **Expected**: Layout switches to tabbed interface
3. **Tabs**: "Configuration" and "Aperçu"
4. **Verify**: All features work in mobile layout

### 2. Client-Side Testing

#### Test: Popup Display on App Open
1. **Create** a popup with trigger "onAppOpen"
2. **Enable** the popup
3. **Logout** and **login** as regular user
4. **Expected**: Popup appears with fade-in and slide-up animation
5. **Verify**: 
   - Image displays (if added)
   - Button works (if added)
   - Close button (X) works

#### Test: Don't Show Again
1. **When popup appears**, click "Ne plus afficher"
2. **Reload** the app
3. **Expected**: Popup does NOT appear again
4. **Clear** SharedPreferences or use different user
5. **Expected**: Popup appears again

#### Test: Button Navigation
1. **Create** popup with buttonLink = "/menu"
2. **Display** popup to user
3. **Click** the button
4. **Expected**: Navigates to menu page

#### Test: Session-Based Display
1. **Create** popup with display condition "oncePerSession"
2. **Display** popup
3. **Navigate** away and back
4. **Expected**: Popup does NOT appear in same session
5. **Logout/login**
6. **Expected**: Popup appears in new session

---

## Part B: Testing Promotional Roulette

### 1. Admin Interface Testing

#### Test: Access Roulette Configuration
1. **Navigate to**: `/admin/studio/popups-roulette`
2. **Click** "Roulette" tab
3. **Expected**: Shows roulette configuration card

#### Test: Enable/Disable Roulette
1. **Toggle** "Activer la roulette" switch
2. **Expected**: State changes immediately
3. **Snackbar**: "Roulette activée" / "Roulette désactivée"

#### Test: Edit Roulette Configuration
1. **Click** Edit icon (✏️) on roulette card
2. **Expected**: Opens EditRouletteScreen
3. **Desktop**: Split-screen layout
4. **Mobile**: Tabbed layout

#### Test: Visual Wheel Preview
1. **In EditRouletteScreen**, observe right panel (desktop)
2. **Expected**: Custom-painted wheel with colored segments
3. **Verify**: 
   - Each segment has correct color
   - Labels are visible
   - Arrow indicator at top
   - Proportions match probabilities

#### Test: Add Segment
1. **Click** "Ajouter un segment" FAB
2. **Expected**: Segment editor dialog opens
3. **Fill** fields:
   - Libellé: "Test Reward"
   - ID de récompense: "test_reward"
   - Probabilité: "15.0"
4. **Click** color indicator
5. **Expected**: Color picker opens
6. **Select** a color
7. **Click** "Enregistrer"
8. **Expected**: 
   - New segment appears in list
   - Wheel preview updates
   - Probability total updates

#### Test: Probability Validation
1. **Add** segments until total ≠ 100%
2. **Expected**: 
   - Probability indicator turns red
   - Shows "⚠️ XX.X%" in red
   - Warning message below
3. **Adjust** probabilities to total 100%
4. **Expected**: 
   - Indicator turns green
   - Shows "✓ 100.0%" in green
5. **Try to save** with invalid total
6. **Expected**: Error "La somme des probabilités doit être égale à 100%"

#### Test: Edit Segment
1. **Click** edit icon (✏️) on a segment
2. **Expected**: Segment editor dialog with existing data
3. **Modify** probability
4. **Save**
5. **Expected**: 
   - Segment updates in list
   - Wheel preview updates
   - Probability total recalculates

#### Test: Delete Segment
1. **Click** delete icon (🗑️) on a segment
2. **Expected**: 
   - Segment removed immediately
   - Wheel preview updates
   - Probability total updates

#### Test: Reorder Segments
1. **Long press** (or drag) a segment
2. **Drag** to new position
3. **Expected**: 
   - Segments reorder
   - Wheel preview updates with new order

#### Test: Save Configuration
1. **Ensure** probabilities sum to 100%
2. **Click** Save button
3. **Expected**: 
   - Loading indicator
   - Returns to main screen
   - Snackbar "Configuration enregistrée"

#### Test: Responsive Layout
1. **Resize** to mobile width
2. **Expected**: Tabs for "Configuration" and "Aperçu"
3. **Verify**: All features work in mobile layout

### 2. Client-Side Testing

#### Test: Access Roulette
1. **Login** as regular user
2. **Navigate to**: `/roulette`
3. **Expected**: Roulette screen loads

#### Test: Unavailable State
1. **Disable** roulette in admin
2. **As user**, navigate to `/roulette`
3. **Expected**: 
   - Shows "La roue n'est pas disponible"
   - Casino icon (gray)
   - Message to come back later

#### Test: Daily Limit Check
1. **Enable** roulette (max 1 per day)
2. **Spin** once
3. **Try to spin again**
4. **Expected**: "Limite atteinte pour aujourd'hui" warning

#### Test: Wheel Spin
1. **Ensure** can spin (within daily limit)
2. **Click** center play button OR "Faire tourner" button
3. **Expected**: 
   - ✅ Haptic feedback (medium impact)
   - ✅ Wheel starts spinning (5 seconds)
   - ✅ Center button shows loading
   - ✅ Spin button disabled

#### Test: Win Animation
1. **Wait** for wheel to stop
2. **If win** (not "nothing"):
   - ✅ Haptic feedback (heavy impact)
   - ✅ Confetti starts from 3 sources
   - ✅ Particles fall with realistic physics
3. **Expected**: Navigates to RewardCelebrationScreen

#### Test: Celebration Screen - Win
1. **After winning**, verify:
   - ✅ Red gradient background
   - ✅ Icon bounces with scale animation
   - ✅ Multiple confetti sources
   - ✅ "Félicitations !" message
   - ✅ Reward description (e.g., "Pizza offerte")
   - ✅ Loading indicator "Ajout de votre récompense..."
   - ✅ Success message "✅ Récompense ajoutée à votre profil"
   - ✅ "Continuer" button enabled after processing

#### Test: Celebration Screen - Loss
1. **If lost** ("Raté !"):
   - Gray gradient background
   - Sad icon (no bounce)
   - No confetti
   - "Pas de chance cette fois !"
   - "Revenez demain pour retenter votre chance"
   - "Continuer" button immediately enabled

#### Test: Profile Update
1. **Win** bonus points (e.g., "+100 points")
2. **After** celebration, navigate to profile
3. **Expected**: Points added to user's loyalty balance
4. **Verify** in Firebase:
   - Check `users/{userId}/loyaltyPoints`
   - Check `user_roulette_spins` collection for record

#### Test: Spin History
1. **Spin** multiple times (across different days)
2. **Check** Firestore `user_roulette_spins` collection
3. **Expected**: Each spin recorded with:
   - userId
   - segmentId
   - segmentType
   - segmentLabel
   - value (if applicable)
   - spunAt (timestamp)

---

## Integration Testing

### Test: Popup Triggers
1. **Create** popup with "onAppOpen" trigger
2. **Restart** app
3. **Expected**: Popup appears on app open

### Test: Popup Audience Filtering
1. **Create** popup for "newUsers"
2. **Test** with new user account
3. **Expected**: Popup appears
4. **Test** with loyal user
5. **Expected**: Popup may not appear (based on audience logic)

### Test: Date-Based Filtering
1. **Create** popup with future startDate
2. **Expected**: Popup does NOT appear yet
3. **Create** popup with past endDate
4. **Expected**: Popup does NOT appear

### Test: Roulette Daily Limit
1. **Set** maxUsesPerDay = 1
2. **Spin** once
3. **Wait** until next day (or manually change date in Firestore)
4. **Expected**: Can spin again

### Test: Reward Distribution
1. **Spin** wheel 100 times (automation recommended)
2. **Record** results
3. **Compare** to configured probabilities
4. **Expected**: Results approximately match probabilities
   - Example: If "Pizza" is 5%, expect ~5 wins out of 100

---

## Edge Cases & Error Handling

### Popups
- ✅ Empty title → Error message
- ✅ Empty message → Error message
- ✅ Invalid image (> 10MB) → Error message
- ✅ Invalid date range → Handled gracefully
- ✅ Malformed buttonLink → User navigates to error page
- ✅ Network error during save → Error snackbar
- ✅ Popup deleted while being edited → Handle gracefully

### Roulette
- ✅ Probability sum ≠ 100% → Cannot save
- ✅ No segments → Cannot save
- ✅ Empty segment fields → Validation error
- ✅ Network error during spin → Error message
- ✅ Roulette disabled mid-spin → Handle gracefully
- ✅ Multiple rapid taps on spin → Prevent duplicate spins

---

## Performance Testing

### Popups
1. **Create** 50+ popups
2. **Load** admin list
3. **Expected**: Loads smoothly, paginated if needed
4. **Scroll** through list
5. **Expected**: No lag or jank

### Roulette
1. **Add** 20+ segments
2. **Check** wheel rendering
3. **Expected**: All segments visible, no overlap
4. **Spin** wheel
5. **Expected**: Smooth 60fps animation

### Images
1. **Upload** large image (< 10MB)
2. **Expected**: Upload completes, image compresses if needed
3. **Load** popup with image
4. **Expected**: Image loads quickly, uses caching

---

## Accessibility Testing

### Visual
- ✅ High contrast text
- ✅ Clear labels on all buttons
- ✅ Error messages visible
- ✅ Loading states indicated

### Interactive
- ✅ Keyboard navigation works
- ✅ Touch targets > 44x44 px
- ✅ Haptic feedback on supported devices
- ✅ Animations not too fast (300-500ms)

---

## Cross-Platform Testing

### Desktop (Web/Windows/Mac/Linux)
- ✅ Split-screen layouts work
- ✅ Mouse interactions smooth
- ✅ Keyboard shortcuts (if any)
- ✅ Window resizing handles responsive breakpoints

### Mobile (iOS/Android)
- ✅ Tabbed layouts work
- ✅ Touch gestures smooth
- ✅ Haptic feedback works (device-dependent)
- ✅ Confetti renders correctly

### Tablets
- ✅ Adaptive layouts (medium screen size)
- ✅ All interactions work with touch

---

## Security Testing

### Admin Routes
1. **Logout** from admin account
2. **Try to access**: `/admin/studio/popups-roulette`
3. **Expected**: Redirected to login (if auth rules enforced)

### Firestore Rules (Manual Check)
1. **Check** Firestore rules for:
   - `app_popups` collection → admin write only
   - `app_roulette_config` collection → admin write only
   - `user_roulette_spins` collection → user read own only

### Input Validation
1. **Try** SQL injection in text fields
2. **Expected**: Handled safely (Firestore is NoSQL)
3. **Try** XSS in popup message
4. **Expected**: Flutter escapes HTML automatically

---

## Regression Testing

After any changes:
1. ✅ Re-test all CRUD operations (popups, roulette)
2. ✅ Re-test animations
3. ✅ Re-test client-side display
4. ✅ Re-test responsive layouts
5. ✅ Re-test Firebase integration

---

## Automated Testing (Recommended)

### Unit Tests
```dart
// test/models/popup_config_test.dart
testPopupConfig_fromFirestore()
testPopupConfig_toMap()
testPopupConfig_copyWith()

// test/models/roulette_config_test.dart
testRouletteSegment_colorConversion()
testRouletteConfig_probabilitySum()

// test/services/roulette_service_test.dart
testSpinWheel_distribution()
```

### Widget Tests
```dart
// test/widgets/popup_dialog_test.dart
testPopupDialog_displaysCorrectly()
testPopupDialog_buttonNavigation()
testPopupDialog_dismissButton()

// test/screens/edit_popup_screen_test.dart
testEditPopupScreen_livePreview()
testEditPopupScreen_templates()
testEditPopupScreen_validation()
```

### Integration Tests
```dart
// integration_test/popup_flow_test.dart
testCreateAndDisplayPopup()
testPopupDismissal()

// integration_test/roulette_flow_test.dart
testRouletteSpinFlow()
testDailyLimitEnforcement()
```

---

## Checklist

### Before Release
- [ ] All manual tests passed
- [ ] No console errors
- [ ] Firebase rules configured
- [ ] Admin access restricted
- [ ] Images compressed/optimized
- [ ] Animations smooth (60fps)
- [ ] Haptic feedback works on devices
- [ ] Confetti renders correctly
- [ ] Probability math verified
- [ ] Reward distribution accurate
- [ ] Documentation complete
- [ ] User guide created (if needed)

---

## Troubleshooting

### "Image not uploading"
- Check Firebase Storage rules
- Verify image < 10MB
- Check network connection
- Verify file extension (jpg, png, webp)

### "Wheel not spinning"
- Check roulette isActive flag
- Verify daily limit not reached
- Check segment configuration (must have > 0 segments)
- Verify probabilities sum to 100%

### "Popup not appearing"
- Check trigger matches current context
- Verify dates are valid (within range)
- Check if popup was dismissed ("Don't show again")
- Verify isEnabled = true

### "Confetti not showing"
- Check device supports graphics
- Verify reward is not "nothing" type
- Check console for errors

---

## Support

If you encounter any issues:
1. Check console logs
2. Verify Firebase configuration
3. Review Firestore data structure
4. Check security rules
5. Test on different devices/platforms
6. Refer to MODULE_2_IMPLEMENTATION_SUMMARY.md

---

**Happy Testing! 🎉**

All features have been implemented with care and should work smoothly. Report any bugs or suggestions for improvement!
