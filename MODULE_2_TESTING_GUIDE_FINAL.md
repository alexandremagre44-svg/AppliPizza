# Module 2: Popups & Roulette - Complete Testing Guide

## 🎯 Testing Objectives

This guide provides step-by-step testing procedures to validate all Module 2 features meet the expert-level requirements specified in the problem statement.

---

## Part A: Popup Testing

### Test 1: Admin - Popup Creation with Live Preview

**Objective**: Verify live preview updates in < 300ms

**Steps**:
1. Navigate to `/admin/studio/popups`
2. Click "+" button to create new popup
3. Type in the "Titre" field
4. **Observe**: Preview on right (or Preview tab on mobile) updates immediately
5. Type in the "Message" field
6. **Observe**: Preview updates in real-time
7. Change "Déclencheur" dropdown
8. **Observe**: No visual change but setting is applied

**Expected Results**:
- ✅ Preview updates < 300ms after each keystroke
- ✅ Desktop: Split screen with form left, preview right
- ✅ Mobile: Tabs for "Configuration" and "Aperçu"
- ✅ All changes reflected instantly in preview

**Screenshots Needed**:
- [ ] Desktop split-screen view
- [ ] Mobile tabbed view
- [ ] Live preview updating

---

### Test 2: Admin - Image Upload (NOT Text Field)

**Objective**: Verify image upload uses button, not text input

**Steps**:
1. In popup editor, scroll to "Image (optionnelle)" section
2. **Verify**: No text input field for URL
3. Click "Ajouter une image" button
4. Select an image from device
5. **Observe**: Image preview appears
6. **Verify**: Close button (X) appears on preview
7. Save the popup
8. **Observe**: Upload progress indicator during save

**Expected Results**:
- ✅ NO text field for imageUrl
- ✅ Button labeled "Ajouter une image"
- ✅ Image picker opens on click
- ✅ Preview shows selected image immediately
- ✅ Image uploads to Firebase Storage on save
- ✅ Can remove image with X button

**Screenshots Needed**:
- [ ] Image upload button (not text field)
- [ ] Image preview with X button
- [ ] Upload progress indicator

---

### Test 3: Admin - Template Application

**Objective**: Verify one-click template application

**Steps**:
1. In popup editor, locate template chips at top
2. Click "Offre Spéciale" template
3. **Verify**: All fields populate instantly
4. Click "Nouveauté" template
5. **Verify**: Fields update to new template
6. **Observe**: Preview updates for each template

**Expected Results**:
- ✅ Three templates: "Offre Spéciale", "Nouveauté", "Fidélité"
- ✅ Clicking template fills all relevant fields
- ✅ Preview updates immediately
- ✅ Can be applied multiple times

---

### Test 4: Admin - Dashboard Toggle Switch

**Objective**: Verify direct enable/disable from list with instant save

**Steps**:
1. Navigate to `/admin/studio/popups` main screen
2. Locate any popup in the list
3. **Verify**: Toggle switch is visible in the popup card (trailing position)
4. Click the toggle switch to disable
5. **Observe**: Snackbar confirmation appears
6. Refresh the page
7. **Verify**: Toggle state persists (popup remains disabled)
8. Toggle back to enabled
9. **Observe**: Snackbar confirmation

**Expected Results**:
- ✅ Each popup card has a Switch widget
- ✅ Switch position matches popup's isEnabled state
- ✅ Clicking switch saves immediately to Firestore
- ✅ Snackbar shows "Popup activé" or "Popup désactivé"
- ✅ State persists after page refresh
- ✅ NO need to open editor to toggle

**Screenshots Needed**:
- [ ] Popup list with toggle switches visible
- [ ] Snackbar confirmation message

---

### Test 5: Admin - Statistics Placeholders

**Objective**: Verify statistics are displayed as placeholders

**Steps**:
1. In popup list, examine each popup card
2. Look at the subtitle area below the title
3. **Verify**: Text shows "Affichages: - • Clics: -"

**Expected Results**:
- ✅ Statistics displayed in subtitle
- ✅ Format: "Affichages: - • Clics: -"
- ✅ Italic or lighter color text style
- ✅ Visible for all popups

**Screenshots Needed**:
- [ ] Popup card showing statistics placeholders

---

### Test 6: Client - Popup Animation (400ms MANDATORY)

**Objective**: Verify popup appears with 400ms fade + slide animation

**Steps**:
1. Create an active popup with trigger "onAppOpen"
2. Clear app data or use "Don't show again" reset
3. Launch the app
4. **Observe**: Popup appears with animation
5. **Time**: Count animation duration (should feel smooth, not instant)
6. Click outside or close button
7. **Observe**: Popup closes with reverse animation

**Expected Results**:
- ✅ Popup does NOT appear instantly/abruptly
- ✅ FadeIn animation (opacity 0 → 1)
- ✅ SlideTransition animation (slides from bottom)
- ✅ Animation duration exactly 400ms
- ✅ Smooth, professional entrance
- ✅ Closing animation also smooth

**Screenshots Needed**:
- [ ] Popup mid-animation (partial opacity/position)
- [ ] Popup fully displayed

---

### Test 7: Client - "Don't Show Again" Functionality

**Objective**: Verify permanent dismissal works

**Steps**:
1. Display a popup
2. Click "Ne plus afficher" button at bottom
3. Restart the app
4. **Verify**: Popup does NOT appear again
5. Use PopupManager.resetDismissedPopups() (if available in debug menu)
6. Restart app
7. **Verify**: Popup appears again

**Expected Results**:
- ✅ "Ne plus afficher" button visible at bottom
- ✅ Clicking it dismisses popup
- ✅ Popup never shows again (even after app restart)
- ✅ Stored in SharedPreferences
- ✅ Can be reset for testing

---

## Part B: Roulette Testing

### Test 8: Admin - Roulette Wheel Visual Editor

**Objective**: Verify graphical wheel preview updates in real-time

**Steps**:
1. Navigate to `/admin/studio/popups` and switch to "Roulette" tab
2. Click edit button for roulette configuration
3. **Verify**: Split screen or tabs with wheel preview
4. Click "Ajouter un segment" floating action button
5. Fill in segment details (label, reward ID, probability, pick color)
6. Save segment
7. **Observe**: Wheel preview updates immediately with new segment
8. Edit an existing segment (change color)
9. **Observe**: Wheel preview updates immediately
10. Delete a segment
11. **Observe**: Wheel redraws without that segment

**Expected Results**:
- ✅ Desktop: Form left, wheel preview right
- ✅ Mobile: Tabs for "Configuration" and "Aperçu"
- ✅ Wheel shows all segments with correct colors
- ✅ Segments sized according to probability
- ✅ Text labels visible on wheel
- ✅ Every change triggers instant redraw
- ✅ Arrow indicator at top of wheel

**Screenshots Needed**:
- [ ] Desktop split-screen with wheel preview
- [ ] Wheel showing multiple colored segments
- [ ] Mobile tabbed view

---

### Test 9: Admin - Color Picker Integration

**Objective**: Verify visual color picker (NOT hex input)

**Steps**:
1. In roulette editor, add or edit a segment
2. In segment dialog, locate "Couleur" field
3. **Verify**: Shows current color as circle/swatch
4. Click on the color field
5. **Verify**: Color picker dialog opens (NOT text input)
6. **Observe**: Visual color palette with hue, saturation controls
7. Select a bright color
8. Click "OK"
9. **Observe**: Segment preview updates with new color
10. Save segment and check wheel preview

**Expected Results**:
- ✅ NO hex code text field for color
- ✅ Visual color circle/swatch displayed
- ✅ Tapping opens flutter_colorpicker dialog
- ✅ Can select any color visually
- ✅ Segment and wheel update with chosen color
- ✅ Color persists after save

**Screenshots Needed**:
- [ ] Segment editor showing color swatch
- [ ] flutter_colorpicker dialog open
- [ ] Wheel with newly colored segment

---

### Test 10: Admin - Probability Validation

**Objective**: Verify probability sum must equal 100%

**Steps**:
1. In roulette editor, view existing segments
2. **Observe**: Total probability displayed at top
3. Edit a segment, change probability to create invalid sum (e.g., total = 95%)
4. **Verify**: 
   - Total shows in RED with warning icon
   - Alert text "La somme doit être égale à 100%"
5. Try to click Save button in app bar
6. **Verify**: Button is DISABLED (dimmed, unresponsive)
7. Hover over save button (desktop)
8. **Verify**: Tooltip shows "La somme des probabilités doit être égale à 100%"
9. Adjust probabilities to equal exactly 100%
10. **Verify**: 
    - Total shows in GREEN with checkmark
    - Save button becomes enabled (bright, clickable)
11. Click Save
12. **Verify**: Configuration saves successfully

**Expected Results**:
- ✅ Real-time probability sum calculation
- ✅ Display shows "X.X%" with color coding
- ✅ RED warning when sum ≠ 100%
- ✅ GREEN checkmark when sum = 100%
- ✅ Save button DISABLED when invalid (onPressed: null)
- ✅ Save button icon dimmed/grayed out
- ✅ Tooltip explains why disabled
- ✅ Save button ENABLED when valid
- ✅ Cannot save invalid configuration

**Screenshots Needed**:
- [ ] Probability sum showing RED (invalid)
- [ ] Disabled save button with tooltip
- [ ] Probability sum showing GREEN (valid)
- [ ] Enabled save button

---

### Test 11: Client - Roulette Wheel Spin

**Objective**: Verify complete sensory experience

**Steps**:
1. Navigate to `/roulette` screen
2. **Verify**: Fortune wheel visible with configured segments
3. **Verify**: Large play button in center
4. Tap play button
5. **Feel**: Initial haptic feedback (medium impact)
6. **Observe**: Wheel starts spinning
7. **Feel**: Periodic haptic clicks (every ~200ms) during spin
8. **Listen**: Tick sound should play in loop (if audio files present)
9. Wait 5 seconds for spin to complete
10. **Feel**: Strong haptic feedback (heavy impact) when stops
11. **Listen**: Win sound plays (if not "nothing" segment, if audio present)
12. **Observe**: Confetti animation if won reward

**Expected Results**:
- ✅ Wheel displays with all configured segments
- ✅ Smooth spinning animation
- ✅ Initial medium haptic on tap
- ✅ Periodic selection click haptics during spin (feels like wheel clicking)
- ✅ Heavy haptic when wheel stops
- ✅ Tick sound loops during spin (when MP3 added)
- ✅ Win sound plays on reward (when MP3 added)
- ✅ Confetti from 3 sources if won
- ✅ No confetti if "nothing" segment

**Screenshots/Video Needed**:
- [ ] Wheel mid-spin
- [ ] Confetti animation active
- [ ] Wheel stopped on winning segment

---

### Test 12: Client - Reward Distribution

**Objective**: Verify automatic coupon creation and profile update

**Steps**:
1. Spin wheel and win "bonus_points_100"
2. **Observe**: Celebration screen shows
3. **Verify**: Processing indicator appears briefly
4. **Verify**: Success message "Récompense ajoutée à votre profil"
5. Navigate to profile
6. **Verify**: Loyalty points increased by 100
7. Spin wheel again and win "free_pizza" (or similar item)
8. **Observe**: Celebration screen
9. Open Firestore console
10. Navigate to `user_coupons` collection
11. **Verify**: New document created with:
    - userId: (current user)
    - rewardId: "free_pizza"
    - rewardLabel: (segment label)
    - isUsed: false
    - createdAt: (current time)
    - expiresAt: (30 days from now)

**Expected Results**:
- ✅ Bonus points: Directly added to user profile
- ✅ Item rewards: Create coupon in user_coupons
- ✅ Processing indicator during save
- ✅ Success confirmation shown
- ✅ Coupon has 30-day expiration
- ✅ Coupon marked as unused (isUsed: false)
- ✅ Source field set to "roulette"

**Screenshots Needed**:
- [ ] Celebration screen with processing indicator
- [ ] Success confirmation message
- [ ] Firestore showing created coupon document
- [ ] Profile showing updated points

---

### Test 13: Client - Celebration Screen

**Objective**: Verify congratulations screen with confetti

**Steps**:
1. Win a reward on roulette
2. **Observe**: Celebration screen automatically appears
3. **Verify**: Multiple confetti sources (top, left, right)
4. **Observe**: Confetti particles fall with gravity
5. **Verify**: Large icon in center (animated entrance)
6. **Verify**: "Félicitations !" message
7. **Verify**: Reward description (e.g., "Vous avez gagné : Pizza offerte")
8. **Verify**: Processing indicator while saving
9. **Verify**: Green checkmark with "Récompense ajoutée à votre profil"
10. Click "Continuer" button
11. **Verify**: Returns to roulette or previous screen

**Expected Results**:
- ✅ Automatic navigation to celebration
- ✅ 3 confetti sources with realistic physics
- ✅ 5-second confetti duration
- ✅ Scale animation on icon (elastic bounce)
- ✅ Gradient background (red for wins)
- ✅ Dynamic icon based on reward type
- ✅ Clear reward message
- ✅ Processing indicator
- ✅ Success confirmation
- ✅ Continue button returns to previous screen

**Screenshots Needed**:
- [ ] Full celebration screen with confetti
- [ ] Animated icon
- [ ] Success confirmation message

---

### Test 14: Client - Daily Spin Limit

**Objective**: Verify spin limit enforcement

**Steps**:
1. Configure roulette with maxUsesPerDay: 1
2. Spin wheel once
3. Complete spin and celebration
4. Return to roulette screen
5. **Verify**: Warning message "Limite atteinte pour aujourd'hui"
6. **Verify**: Play button is DISABLED (grayed out)
7. **Verify**: Cannot spin again
8. Wait until next day (or manually adjust system date for testing)
9. Return to roulette screen
10. **Verify**: Can spin again

**Expected Results**:
- ✅ Spins tracked per user per day
- ✅ Warning displayed when limit reached
- ✅ Play button disabled after limit
- ✅ Limit resets at midnight
- ✅ Message shows max uses per day

**Screenshots Needed**:
- [ ] Warning message displayed
- [ ] Disabled play button

---

## Performance Testing

### Test 15: Preview Response Time

**Objective**: Measure preview update latency

**Tools**: Stopwatch or phone camera with slow motion

**Steps**:
1. Open popup editor
2. Position cursor in title field
3. Start timing/recording
4. Type one character
5. Stop when preview updates
6. **Measure**: Time should be < 300ms

**Expected Results**:
- ✅ Preview updates in < 300ms
- ✅ Feels instant to user
- ✅ No lag or stuttering

---

### Test 16: Animation Smoothness

**Objective**: Verify 60fps animations

**Steps**:
1. Enable performance overlay (Flutter DevTools)
2. Open popup with animation
3. **Observe**: Frame rate during animation
4. Spin roulette wheel
5. **Observe**: Frame rate during spin
6. Trigger confetti
7. **Observe**: Frame rate during confetti

**Expected Results**:
- ✅ Consistent 60fps during all animations
- ✅ No frame drops
- ✅ Smooth visual experience

---

## Responsive Design Testing

### Test 17: Desktop Experience

**Device**: Desktop browser or simulator (>800px width)

**Steps**:
1. Open popup editor
2. **Verify**: Split-screen layout (form | preview)
3. Open roulette editor
4. **Verify**: Split-screen layout (config | wheel)
5. Resize window to tablet size (~700px)
6. **Verify**: Layout still works appropriately

**Expected Results**:
- ✅ Desktop uses split-screen layouts
- ✅ Both panels visible simultaneously
- ✅ Responsive to window resizing

---

### Test 18: Mobile Experience

**Device**: Mobile device or simulator (<800px width)

**Steps**:
1. Open popup editor
2. **Verify**: Tabbed layout with "Configuration" and "Aperçu" tabs
3. Switch between tabs
4. **Verify**: Smooth tab transitions
5. Open roulette editor
6. **Verify**: Tabbed layout
7. Test all interactions
8. **Verify**: All features accessible on small screen

**Expected Results**:
- ✅ Mobile uses tabbed layouts
- ✅ Easy navigation between tabs
- ✅ All controls accessible
- ✅ No horizontal scrolling required

---

## Error Handling Testing

### Test 19: Image Upload Errors

**Steps**:
1. Try to upload an invalid image format (e.g., .txt file)
2. **Verify**: Error message displayed
3. Try to upload very large image (>10MB)
4. **Verify**: Error message displayed
5. Upload valid image but disconnect internet before save
6. **Verify**: Error handling with retry option

**Expected Results**:
- ✅ Validates image format
- ✅ Validates image size
- ✅ Clear error messages
- ✅ Graceful network error handling

---

### Test 20: Firestore Connection Errors

**Steps**:
1. Disable network connection
2. Try to load popups list
3. **Verify**: Error handling (empty state or error message)
4. Try to save popup
5. **Verify**: Error message displayed
6. Re-enable network
7. **Verify**: Retry works

**Expected Results**:
- ✅ Handles offline state gracefully
- ✅ Clear error messages
- ✅ Retry logic available

---

## Regression Testing

### Test 21: Backward Compatibility

**Steps**:
1. Load existing popups created before Module 2 enhancements
2. **Verify**: All fields load correctly
3. **Verify**: Legacy fields (type, ctaText, etc.) still work
4. Edit and save legacy popup
5. **Verify**: Saves successfully without data loss

**Expected Results**:
- ✅ Legacy popups load correctly
- ✅ Can edit without breaking
- ✅ No data loss on save
- ✅ New and old fields coexist

---

## Test Summary Checklist

Use this checklist to track testing progress:

### Popup Tests
- [ ] Test 1: Live preview < 300ms
- [ ] Test 2: Image upload button (not text field)
- [ ] Test 3: Template application
- [ ] Test 4: Dashboard toggle switch
- [ ] Test 5: Statistics placeholders
- [ ] Test 6: 400ms animation
- [ ] Test 7: "Don't show again"

### Roulette Tests
- [ ] Test 8: Wheel visual editor
- [ ] Test 9: Color picker integration
- [ ] Test 10: Probability validation
- [ ] Test 11: Wheel spin experience
- [ ] Test 12: Reward distribution
- [ ] Test 13: Celebration screen
- [ ] Test 14: Daily spin limit

### Performance Tests
- [ ] Test 15: Preview response time
- [ ] Test 16: Animation smoothness

### Responsive Tests
- [ ] Test 17: Desktop experience
- [ ] Test 18: Mobile experience

### Error Tests
- [ ] Test 19: Image upload errors
- [ ] Test 20: Firestore connection errors

### Regression Tests
- [ ] Test 21: Backward compatibility

---

## Test Results Template

For each test, document results using this format:

```
Test #: [Number and Name]
Date: [YYYY-MM-DD]
Tester: [Name]
Device: [Device/Browser]
Status: [ ] Pass [ ] Fail [ ] Blocked

Results:
- [Observation 1]
- [Observation 2]

Issues Found:
- [Issue 1 if any]

Screenshots: [Attached/Link]
```

---

## Bug Report Template

If issues are found:

```
Title: [Brief description]
Severity: [ ] Critical [ ] High [ ] Medium [ ] Low
Test: [Test number where found]

Steps to Reproduce:
1. [Step 1]
2. [Step 2]
3. [Step 3]

Expected Behavior:
[What should happen]

Actual Behavior:
[What actually happens]

Environment:
- Device: [Device/Browser]
- OS: [Operating System]
- App Version: [Version]

Screenshots/Video:
[Attach or link]

Additional Notes:
[Any other relevant information]
```

---

## Audio Assets Testing Note

For Tests 11 (sound effects), note the following:

**Current Status**: Audio code is implemented but waiting for MP3 files.

**When audio files are added**:
1. Place `tick.mp3` and `win.mp3` in `assets/sounds/`
2. Run `flutter pub get`
3. Uncomment audio lines in `roulette_screen.dart` (lines marked with comments)
4. Re-run Test 11 to verify sounds play correctly

**Until audio files are added**:
- ✅ All other roulette features work perfectly
- ✅ Haptic feedback provides tactile experience
- ✅ Visual animations are complete
- ⏳ Audio will enhance experience when files are provided

---

## Success Criteria

Module 2 is considered **successfully implemented** when:

✅ All 21 tests pass
✅ No critical or high-severity bugs
✅ Performance meets targets (< 300ms preview, 60fps animations)
✅ Responsive design works on desktop and mobile
✅ Error handling is graceful
✅ Backward compatibility maintained
✅ User experience feels professional and polished

---

## Contact

For questions about testing or to report issues:
- See MODULE_2_FINAL_IMPLEMENTATION.md for implementation details
- See assets/sounds/README.md for audio asset requirements
