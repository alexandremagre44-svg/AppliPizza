# Click & Collect Module Integration Notes

## Point Selector Integration

The PointSelectorScreen widget has been created in:
`lib/white_label/widgets/runtime/point_selector_screen.dart`

### Checkout Integration

To integrate the point selector into the checkout flow:

1. **Add to checkout navigation flow**:
   ```dart
   // In checkout screen
   if (deliveryMode == DeliveryMode.clickAndCollect) {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => const PointSelectorScreen(),
       ),
     );
   }
   ```

2. **Pass selected point to order**:
   - Modify PointSelectorScreen to accept an onPointSelected callback
   - Store selected point in order/cart state
   - Display selected point in checkout summary

3. **Validate point selection**:
   - Ensure a pickup point is selected before allowing order completion
   - Show pickup point details on order confirmation

## Module Configuration

The Click & Collect module is configured through:
- `click_and_collect_module_config.dart` - Module settings
- `click_and_collect_module_definition.dart` - Module metadata

Module can be enabled/disabled per restaurant in RestaurantPlanUnified.

## Future Enhancements

- [ ] Implement actual pickup point selection UI
- [ ] Add map view for pickup points
- [ ] Show estimated pickup times
- [ ] Allow multiple pickup locations per restaurant
- [ ] Add pickup point availability/capacity management
