# Android Configuration for Pizza Deli'Zza

## ✅ Android 13+ Back Gesture Support

The Android platform configuration has been added with support for the predictive back gesture introduced in Android 13.

### Key Configuration

**File**: `android/app/src/main/AndroidManifest.xml`

```xml
<application
    android:label="Pizza Deli'Zza"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher"
    android:enableOnBackInvokedCallback="true">
```

The `android:enableOnBackInvokedCallback="true"` attribute enables the new predictive back gesture on Android 13+ devices.

## Files Added

### Core Android Files
- `android/app/src/main/AndroidManifest.xml` - Main manifest with back gesture enabled
- `android/app/src/main/kotlin/com/delizza/pizza/MainActivity.kt` - Main activity
- `android/app/build.gradle` - App-level build configuration
- `android/app/build.gradle.kts` - App-level Kotlin build configuration
- `android/build.gradle` - Project-level build configuration
- `android/settings.gradle` - Gradle settings
- `android/gradle.properties` - Gradle properties
- `android/gradle/wrapper/gradle-wrapper.properties` - Gradle wrapper configuration

### Resources
- `android/app/src/main/res/values/styles.xml` - App themes
- `android/app/src/main/res/values/colors.xml` - Color definitions (splash color: #B00020)
- `android/app/src/main/res/drawable/launch_background.xml` - Launch splash screen

### Configuration
- Application ID: `com.delizza.pizza`
- Min SDK: Defined by Flutter (typically 21)
- Target SDK: Defined by Flutter (typically 33+)
- Compile SDK: Defined by Flutter

## Next Steps

To complete the Android setup:

1. **Add launcher icons** to the mipmap directories:
   - `android/app/src/main/res/mipmap-{density}/ic_launcher.png`

2. **Run the app** on an Android device or emulator:
   ```bash
   flutter run
   ```

3. **Test the back gesture** on Android 13+ device to verify the predictive back animation works correctly.

## Benefits

✅ **Predictive Back Gesture**: Users on Android 13+ can see a preview animation before completing the back navigation
✅ **Modern UX**: Aligns with Android's latest navigation patterns
✅ **Future-proof**: Ready for Android platform requirements
