# ============================================================================
# PROGUARD RULES - PIZZA DELI'ZZA
# ============================================================================
# Règles d'obfuscation pour le build release Android
# Ces règles préservent le code nécessaire pour Firebase et autres dépendances

# ============================================================================
# FLUTTER
# ============================================================================
# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dart VM
-keep class com.google.firebase.** { *; }

# ============================================================================
# FIREBASE CORE
# ============================================================================
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Authentication
-keep class com.google.firebase.auth.** { *; }
-keep interface com.google.firebase.auth.** { *; }

# Firebase Firestore
-keep class com.google.firebase.firestore.** { *; }
-keep interface com.google.firebase.firestore.** { *; }
-keepclassmembers class com.google.firebase.firestore.** {
    *;
}

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }
-keep interface com.google.firebase.storage.** { *; }

# Firebase Crashlytics
-keep class com.google.firebase.crashlytics.** { *; }
-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keep public class * extends java.lang.Exception

# Firebase App Check
-keep class com.google.firebase.appcheck.** { *; }
-keep interface com.google.firebase.appcheck.** { *; }

# ============================================================================
# GOOGLE PLAY SERVICES
# ============================================================================
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.safetynet.** { *; }

# Play Integrity API (App Check)
-keep class com.google.android.play.core.integrity.** { *; }

# ============================================================================
# KOTLIN
# ============================================================================
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Kotlin serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt

# ============================================================================
# MODÈLES DE DONNÉES (si utilisation de reflection/serialization)
# ============================================================================
# Préserver les classes de modèles pour Firestore serialization
-keep class com.example.pizza_delizza_clean.** { *; }

# Préserver les getters/setters pour la serialization JSON
-keepclassmembers class * {
    public <init>(...);
    public *** get*();
    public void set*(***);
}

# ============================================================================
# AUTRES DÉPENDANCES
# ============================================================================

# Riverpod (gestion d'état)
-keep class com.riverpod.** { *; }
-dontwarn com.riverpod.**

# Shared Preferences
-keep class android.content.SharedPreferences { *; }
-keep class androidx.preference.** { *; }

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Audio Players
-keep class xyz.luan.audioplayers.** { *; }

# ============================================================================
# OPTIMISATIONS
# ============================================================================
# Autoriser les optimisations standard
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-verbose

# Préserver les numéros de ligne pour les stack traces (important pour Crashlytics)
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Préserver les annotations
-keepattributes *Annotation*

# Préserver les signatures génériques (pour reflection)
-keepattributes Signature

# Préserver les exceptions
-keepattributes Exceptions

# ============================================================================
# WARNINGS À IGNORER (dépendances tierces)
# ============================================================================
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn javax.annotation.**
