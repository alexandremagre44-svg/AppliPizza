// lib/src/features/content/application/content_provider.dart
// Riverpod providers for content management and localization

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/content_service.dart';
import '../data/models/content_string_model.dart';

/// Provider for ContentService singleton
final contentServiceProvider = Provider<ContentService>((ref) {
  return ContentService();
});

/// StreamProvider that watches all content strings from Firestore
/// This is the raw data source that other providers depend on
final allStringsProvider = StreamProvider<List<ContentString>>((ref) {
  final service = ref.watch(contentServiceProvider);
  return service.watchAllStrings();
});

/// Provider that transforms content strings into an optimized lookup map
/// This is the core of the localization system
/// 
/// Returns a Map<String, String> where:
/// - Key: content string key (e.g., "home_welcome_title")
/// - Value: the French translation from values['fr']
/// 
/// Properly exposes loading and error states from the parent StreamProvider
final localizationsProvider = Provider<AsyncValue<Map<String, String>>>((ref) {
  final stringsAsync = ref.watch(allStringsProvider);
  
  return stringsAsync.when(
    data: (strings) {
      // Transform List<ContentString> to Map<String, String>
      final map = <String, String>{};
      for (final contentString in strings) {
        // Get the French value, use empty string as fallback
        final frValue = contentString.values['fr'] ?? '';
        if (frValue.isNotEmpty) {
          map[contentString.key] = frValue;
        }
      }
      return AsyncValue.data(map);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Extension on WidgetRef for simplified localization access
/// Provides the tr() method for translating keys with optional parameter interpolation
extension LocalizationExtension on WidgetRef {
  /// Translate a key to its localized string
  /// 
  /// [key] - The content string key to translate
  /// [params] - Optional parameters for string interpolation (e.g., {'name': 'Alex'})
  /// 
  /// Returns:
  /// - The translated string if found
  /// - "..." while loading
  /// - "❌ Error" if an error occurred
  /// - "⚠️ {key}" if the key is not found (useful for development)
  /// 
  /// Uses select() to optimize rebuilds - only rebuilds when this specific key changes
  String tr(String key, {Map<String, String>? params}) {
    // Watch the entire localizationsProvider to handle loading/error states
    final localizationsAsync = watch(localizationsProvider);
    
    return localizationsAsync.when(
      data: (map) {
        // Use select to only rebuild when this specific key changes
        final value = watch(
          localizationsProvider.select((async) {
            return async.whenData((m) => m[key]).value;
          }),
        );
        
        if (value == null) {
          // Key not found - return warning emoji with key for dev visibility
          return '⚠️ $key';
        }
        
        // Apply parameter interpolation if params are provided
        if (params != null && params.isNotEmpty) {
          String result = value;
          params.forEach((paramKey, paramValue) {
            result = result.replaceAll('{$paramKey}', paramValue);
          });
          return result;
        }
        
        return value;
      },
      loading: () => '...', // Minimalist loading indicator
      error: (_, __) => '❌ Error', // Simple error indicator
    );
  }
}
