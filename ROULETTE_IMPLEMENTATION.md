# RouletteScreen Implementation Documentation

## Overview
This document describes the implementation of the client-side `RouletteScreen` that uses the custom `PizzaRouletteWheel` widget and integrates with the cart system to apply rewards.

## Architecture

### Components

#### 1. PizzaRouletteWheel Widget (`lib/src/widgets/pizza_roulette_wheel.dart`)
- Custom Flutter widget that draws and animates a pizza-style roulette wheel
- Pure Flutter implementation using `CustomPaint` and `AnimationController`
- Probability-based segment selection
- Controlled externally via `GlobalKey<PizzaRouletteWheelState>`

**Usage:**
```dart
final GlobalKey<PizzaRouletteWheelState> wheelKey = GlobalKey();

PizzaRouletteWheel(
  key: wheelKey,
  segments: segments,
  onResult: (segment) {
    // Handle result
  },
)

// Trigger spin
wheelKey.currentState?.spin();
```

#### 2. RouletteScreen (`lib/src/screens/roulette/roulette_screen.dart`)
- Client-facing screen for the roulette wheel
- Fetches active segments from Firestore via `RouletteSegmentService`
- Manages spin state and user eligibility
- Applies rewards to cart via `CartProvider`
- Material 3 design system integration

**Features:**
- Spin availability checking (1 spin per day per user)
- Result display with celebration UI
- Automatic reward application to cart
- Disabled state when user has reached daily limit

#### 3. CartProvider Extensions (`lib/src/providers/cart_provider.dart`)
Enhanced with roulette reward support:

**New State Fields:**
- `discountPercent`: Percentage discount (e.g., 10 for 10%)
- `discountAmount`: Fixed amount discount (e.g., 5.0 for 5€)
- `pendingFreeItemId`: Product ID for free item
- `pendingFreeItemType`: Type of free item ('product' or 'drink')

**New Methods:**
- `applyPercentageDiscount(double percent)`: Apply percentage discount
- `applyFixedAmountDiscount(double amount)`: Apply fixed amount discount
- `setPendingFreeItem(String productId, String type)`: Set free item
- `clearDiscounts()`: Remove all discounts
- `clearPendingFreeItem()`: Remove pending free item
- `clearAllRewards()`: Clear all rewards

**New Calculated Properties:**
- `subtotal`: Total before discounts
- `discountValue`: Total discount amount
- `total`: Final total after discounts
- `hasDiscount`: Whether any discount is active
- `hasPendingFreeItem`: Whether free item is pending

## Reward Types

The system supports the following reward types (defined in `RewardType` enum):

1. **None** (`RewardType.none`): No reward
2. **Percentage Discount** (`RewardType.percentageDiscount`): Apply X% discount
3. **Fixed Amount Discount** (`RewardType.fixedAmountDiscount`): Apply X€ discount
4. **Free Product** (`RewardType.freeProduct`): Add free product to cart
5. **Free Drink** (`RewardType.freeDrink`): Add free drink to cart

## Data Flow

```
User clicks "Tourner la roue"
  ↓
RouletteScreen._onSpinPressed()
  ↓
PizzaRouletteWheel.spin() via GlobalKey
  ↓
Wheel animation plays (4 seconds)
  ↓
PizzaRouletteWheel.onResult() callback
  ↓
RouletteScreen._onResult(segment)
  ↓
Record spin in Firestore
  ↓
Apply reward to CartProvider
  ↓
Show result dialog
```

## Reward Application Logic

```dart
void _applyReward(RouletteSegment segment) {
  final cartNotifier = ref.read(cartProvider.notifier);
  
  switch (segment.rewardType) {
    case RewardType.percentageDiscount:
      cartNotifier.applyPercentageDiscount(segment.rewardValue!);
      break;
      
    case RewardType.fixedAmountDiscount:
      cartNotifier.applyFixedAmountDiscount(segment.rewardValue!);
      break;
      
    case RewardType.freeProduct:
      cartNotifier.setPendingFreeItem(segment.productId!, 'product');
      break;
      
    case RewardType.freeDrink:
      cartNotifier.setPendingFreeItem(segment.productId!, 'drink');
      break;
      
    case RewardType.none:
      // No reward to apply
      break;
  }
}
```

## UI/UX Design

The screen follows the Deli'Zza Material 3 design system:

- **Colors**: `AppColors.primary` (red), `AppColors.success`, `AppColors.warning`
- **Spacing**: `AppSpacing` constants (md, lg, xl, etc.)
- **Radius**: `AppRadius.card`, `AppRadius.button`
- **Typography**: `AppTextStyles` (displaySmall, titleLarge, bodyMedium, etc.)

### Screen States

1. **Loading**: Shows `CircularProgressIndicator`
2. **No Segments**: Shows empty state with message
3. **Can Spin**: Shows wheel with active spin button
4. **Cannot Spin**: Shows warning banner "Limite atteinte pour aujourd'hui"
5. **Spinning**: Disables button, shows spinning animation
6. **Result**: Shows celebration card with reward details

## Integration with Existing Code

### Services Used
- `RouletteSegmentService`: Fetch active segments from Firestore
- `RouletteService`: Check spin availability and record spins

### Providers Used
- `CartProvider`: Apply and manage rewards

### Models Used
- `RouletteSegment`: Segment configuration with reward data
- `RewardType`: Enum for reward types

## Testing

Comprehensive tests are provided in:
- `test/providers/cart_provider_roulette_test.dart`: Tests for cart reward functionality
- `test/widgets/pizza_roulette_wheel_test.dart`: Tests for wheel widget (existing)

### Test Coverage
- Discount application (percentage, fixed amount, combined)
- Free item management
- Discount calculations and caps
- State preservation across cart operations
- Edge cases (exceeding subtotal, empty cart, etc.)

## Future Enhancements

Potential improvements:
1. Add sound effects during spin
2. Add haptic feedback on segment selection
3. Implement reward expiration dates
4. Add reward usage tracking
5. Support multiple active rewards
6. Add reward history screen
7. Implement reward notifications

## Migration Notes

### Breaking Changes
- Old `roulette_screen.dart` backed up to `roulette_screen_old_backup.dart`
- Now uses custom `PizzaRouletteWheel` instead of `flutter_fortune_wheel`
- `CartState` now includes reward fields (backward compatible)

### Backward Compatibility
- All existing cart operations preserve reward state
- Old cart code works without modifications
- Reward fields default to `null` (no rewards)

## Usage Example

```dart
// Navigate to RouletteScreen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RouletteScreen(
      userId: currentUser.id,
    ),
  ),
);

// Check cart rewards
final cart = ref.watch(cartProvider);
if (cart.hasDiscount) {
  print('Discount: ${cart.discountValue}€');
}
if (cart.hasPendingFreeItem) {
  print('Free item: ${cart.pendingFreeItemId}');
}
```

## Dependencies

Required packages:
- `flutter_riverpod`: State management
- `cloud_firestore`: Firestore integration
- Core Flutter packages (material, widgets, etc.)

Optional (kept for other screens):
- `confetti`: Used by reward_celebration_screen
- `audioplayers`: Sound effects (not yet implemented)

## Files Modified/Created

### Modified
- `lib/src/providers/cart_provider.dart`: Extended with reward support
- `lib/src/screens/roulette/roulette_screen.dart`: Replaced implementation

### Created
- `test/providers/cart_provider_roulette_test.dart`: Test suite
- `ROULETTE_IMPLEMENTATION.md`: This documentation

### Archived
- `lib/src/screens/roulette/roulette_screen_old_backup.dart`: Old implementation

## Troubleshooting

### Wheel doesn't spin
- Check if segments are loaded (`_segments.isEmpty`)
- Verify user can spin (`_canSpin` is true)
- Ensure GlobalKey is properly attached

### Rewards not applied
- Check `RewardType` is correctly set in segment
- Verify `rewardValue` or `productId` is not null
- Check cart provider is accessible via ref

### UI issues
- Ensure design system imports are correct
- Verify Material 3 theme is applied
- Check for conflicting styles

## Support

For issues or questions:
1. Check Firestore segment configuration
2. Verify user hasn't exceeded daily limit
3. Review console logs for errors
4. Check cart state in debug mode
