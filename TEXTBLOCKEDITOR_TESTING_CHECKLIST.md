# TextBlockEditor - Testing Checklist

## Pre-Testing Setup

### Firestore Requirements
- [ ] Ensure Firestore collection `app_texts_config` exists
- [ ] Ensure document `main` exists or can be created
- [ ] Verify Firestore rules allow read/write for admin users

### Firebase Setup
```dart
// Required Firestore structure
app_texts_config/
  main/
    - id: "main"
    - general: { appName, slogan, homeIntro }
    - orderMessages: { successMessage, failureMessage, noSlotsMessage }
    - errorMessages: { networkError, serverError, sessionExpired }
    - loyaltyTexts: { ... }
    - updatedAt: Timestamp
```

## Functional Testing

### 1. Screen Navigation ✓
- [ ] Navigate to TextBlockEditor from Studio Builder
- [ ] Screen loads without crashes
- [ ] AppBar displays correctly with title "Textes & Messages"
- [ ] Back button works and returns to previous screen

### 2. Data Loading ✓
- [ ] Loading indicator appears on first load
- [ ] Data loads from Firestore successfully
- [ ] All 9 text fields populate with correct values
- [ ] Loading indicator disappears after data loads

#### Test Case: Empty Firestore
```
Expected: Default values from AppTextsConfig.defaultConfig()
Actual: _______________
Status: [ ] Pass [ ] Fail
```

#### Test Case: Existing Data
```
Expected: Shows saved values from Firestore
Actual: _______________
Status: [ ] Pass [ ] Fail
```

### 3. Field Editing ✓
- [ ] All fields are editable
- [ ] Text can be typed in each field
- [ ] Multi-line fields (maxLines=2) work correctly
- [ ] Focus moves between fields correctly
- [ ] Keyboard appears/disappears properly

### 4. Validation ✓

#### Test: Empty Field Validation
```
Steps:
1. Clear a field completely
2. Click "Sauvegarder tous les textes"

Expected: Validation error "Ce champ ne peut pas être vide"
Actual: _______________
Status: [ ] Pass [ ] Fail
```

#### Test: Valid Data
```
Steps:
1. Fill all fields with valid text
2. Click "Sauvegarder tous les textes"

Expected: Save succeeds, SnackBar shows success
Actual: _______________
Status: [ ] Pass [ ] Fail
```

### 5. Save Functionality ✓

#### Test: Successful Save
```
Steps:
1. Modify one or more fields
2. Click "Sauvegarder tous les textes"
3. Wait for operation to complete

Expected:
- Button shows loading spinner
- SnackBar: "✓ Tous les textes ont été enregistrés"
- Data reloads from Firestore
- Modified values persist

Actual: _______________
Status: [ ] Pass [ ] Fail
```

#### Test: Save All Fields
```
Steps:
1. Modify all 9 fields
2. Save
3. Navigate away and back

Expected: All 9 changes persisted
Actual: _______________
Status: [ ] Pass [ ] Fail
```

### 6. Error Handling ✓

#### Test: Network Error
```
Steps:
1. Disable network
2. Try to save

Expected: Error SnackBar displayed
Actual: _______________
Status: [ ] Pass [ ] Fail
```

#### Test: Firestore Permission Error
```
Steps:
1. Use user without write permissions
2. Try to save

Expected: Error SnackBar with message
Actual: _______________
Status: [ ] Pass [ ] Fail
```

## UI/UX Testing

### 7. Visual Design ✓

#### AppBar
- [ ] Background color is white (#FFFFFF)
- [ ] Elevation is 0
- [ ] Title text is "Textes & Messages"
- [ ] Title color is textPrimary (#323232)
- [ ] Back button visible and functional

#### Background
- [ ] Scaffold background is surfaceContainerLow (#F5F5F5)
- [ ] Visible and correct across entire screen

#### Cards
- [ ] 4 cards displayed (Accueil, Commandes, Paiements, Général)
- [ ] Each card has correct icon and color (primary red)
- [ ] Card radius is 16px (large)
- [ ] Card background is white
- [ ] Card padding is 16px all sides
- [ ] Elevation is 0 (flat design)

#### TextFields
- [ ] Border radius is 12px
- [ ] Normal border color is #BEBEBE (outline)
- [ ] Focused border color is #D32F2F (primary), width 2px
- [ ] Error border color is #C62828 (error)
- [ ] Background fill color is white
- [ ] Label style matches design system
- [ ] Text style matches design system

#### Save Button
- [ ] Full width
- [ ] Background color is #D32F2F (primary)
- [ ] Text color is white
- [ ] Border radius is 12px
- [ ] Padding vertical is 16px
- [ ] Text is "Sauvegarder tous les textes"

### 8. Spacing ✓
- [ ] Horizontal padding of ScrollView is 16px
- [ ] Vertical spacing between cards is 16px
- [ ] Vertical spacing between fields is 16px
- [ ] Spacing after save button is 32px

### 9. Typography ✓
- [ ] Card titles use AppTextStyles.titleLarge
- [ ] Field labels use AppTextStyles.labelMedium
- [ ] Field text uses AppTextStyles.bodyMedium
- [ ] Button text uses AppTextStyles.labelLarge
- [ ] All text colors from AppColors (no hardcoded)

### 10. Responsiveness ✓

#### Mobile (360x640)
- [ ] All cards fit width
- [ ] Text fields full width
- [ ] No horizontal scrolling
- [ ] Comfortable tap targets

#### Tablet (768x1024)
- [ ] Layout scales properly
- [ ] Cards expand to fill width
- [ ] Readable and comfortable

#### Landscape
- [ ] Vertical scrolling works
- [ ] No UI cutoff
- [ ] All elements accessible

## Integration Testing

### 11. Firestore Integration ✓

#### Test: Real-time Updates
```
Steps:
1. Open TextBlockEditor on two devices
2. Save changes on device 1
3. Close and reopen on device 2

Expected: Device 2 shows updated values
Actual: _______________
Status: [ ] Pass [ ] Fail
```

#### Test: Data Persistence
```
Steps:
1. Modify and save all fields
2. Close app completely
3. Reopen app and navigate to TextBlockEditor

Expected: All changes persisted
Actual: _______________
Status: [ ] Pass [ ] Fail
```

### 12. Studio Builder Integration ✓
- [ ] TextBlockEditor accessible from Studio Builder menu
- [ ] Navigation smooth with no crashes
- [ ] Can navigate back to Studio Builder
- [ ] State preserved when returning

## Performance Testing

### 13. Loading Performance ✓
- [ ] Initial load time < 2 seconds (good network)
- [ ] Loading indicator smooth (no jank)
- [ ] No memory leaks after multiple open/close

### 14. Save Performance ✓
- [ ] Save operation < 3 seconds (good network)
- [ ] UI remains responsive during save
- [ ] Progress indicator accurate

## Accessibility Testing

### 15. Screen Reader ✓
- [ ] All fields have proper labels
- [ ] Button announced correctly
- [ ] Navigation order is logical

### 16. Keyboard Navigation ✓
- [ ] Can tab between all fields
- [ ] Save button reachable via keyboard
- [ ] Enter key submits form

### 17. Color Contrast ✓
- [ ] Text readable on backgrounds
- [ ] Error states clearly visible
- [ ] Focus states prominent

## Edge Cases

### 18. Special Characters ✓
```
Test with:
- Accents: é, è, à, ç
- Apostrophes: '
- Quotes: " "
- Emojis: 🍕 🎉
- Numbers: 123
- Special: @#$%

Expected: All save and display correctly
Actual: _______________
Status: [ ] Pass [ ] Fail
```

### 19. Long Text ✓
```
Test with:
- 500 character strings
- Very long words
- Multiple lines

Expected: Text wraps properly, no overflow
Actual: _______________
Status: [ ] Pass [ ] Fail
```

### 20. Concurrent Edits ✓
```
Steps:
1. Open on two devices
2. Edit same field on both
3. Save from device 1
4. Save from device 2

Expected: Last save wins, no data corruption
Actual: _______________
Status: [ ] Pass [ ] Fail
```

## Sign-Off

### Test Summary
- Total Tests: 20
- Passed: ___
- Failed: ___
- Blocked: ___
- Not Tested: ___

### Critical Issues
```
None identified / List issues:
1. _______________
2. _______________
```

### Recommendations
```
Ready for production: [ ] Yes [ ] No

Comments:
_______________________________________________
_______________________________________________
```

### Tester Information
```
Tester Name: _______________
Date: _______________
Environment: _______________
Device: _______________
Signature: _______________
```

## Automated Testing Script (Optional)

### Widget Test Template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:pizza_delizza/src/screens/admin/studio/studio_texts_screen.dart';

void main() {
  testWidgets('TextBlockEditor loads and displays correctly', (tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: StudioTextsScreen(),
      ),
    );

    // Verify loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for data to load
    await tester.pumpAndSettle();

    // Verify all cards are displayed
    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Commandes'), findsOneWidget);
    expect(find.text('Paiements'), findsOneWidget);
    expect(find.text('Général'), findsOneWidget);

    // Verify save button exists
    expect(find.text('Sauvegarder tous les textes'), findsOneWidget);
  });

  testWidgets('Save button triggers validation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StudioTextsScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Clear a field
    final firstField = find.byType(TextFormField).first;
    await tester.enterText(firstField, '');

    // Tap save button
    await tester.tap(find.text('Sauvegarder tous les textes'));
    await tester.pumpAndSettle();

    // Verify error message appears
    expect(find.text('Ce champ ne peut pas être vide'), findsWidgets);
  });
}
```

## Notes
- Test in both debug and release modes
- Test with different Firestore security rules
- Test with different user permission levels
- Document any workarounds or known issues
