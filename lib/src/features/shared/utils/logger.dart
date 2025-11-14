// lib/src/utils/logger.dart
/// Utility class for logging throughout the application
/// 
/// Provides structured logging with different levels (debug, info, warning, error)
/// and emoji prefixes for better visual identification in console output.
library;

import 'dart:developer' as developer;

/// Application-wide logger utility
/// 
/// Usage:
/// ```dart
/// AppLogger.info('User logged in', tag: 'AuthService');
/// AppLogger.error('Failed to load products', tag: 'ProductRepository', error: e);
/// ```
class AppLogger {
  /// Log debug information (development only)
  /// 
  /// Used for detailed debugging information that helps during development.
  /// These logs can be disabled in production.
  static void debug(String message, {String tag = 'App', Object? data}) {
    developer.log(
      '🔍 $message${data != null ? '\nData: $data' : ''}',
      name: tag,
      level: 500, // Debug level
    );
  }

  /// Log general information
  /// 
  /// Used for general informational messages about the application flow.
  static void info(String message, {String tag = 'App', Object? data}) {
    developer.log(
      '📋 $message${data != null ? '\nData: $data' : ''}',
      name: tag,
      level: 800, // Info level
    );
  }

  /// Log warnings
  /// 
  /// Used for potentially problematic situations that don't prevent the app
  /// from functioning but should be investigated.
  static void warning(String message, {String tag = 'App', Object? data}) {
    developer.log(
      '⚠️ $message${data != null ? '\nData: $data' : ''}',
      name: tag,
      level: 900, // Warning level
    );
  }

  /// Log errors
  /// 
  /// Used for error conditions that require attention.
  /// Should include the error object and optionally a stack trace.
  static void error(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      '❌ $message${error != null ? '\nError: $error' : ''}',
      name: tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log with custom emoji prefix
  /// 
  /// Allows for custom logging with specific emoji indicators.
  /// Useful for domain-specific logging (e.g., 🔥 for Firestore, 🛒 for Cart).
  static void custom(
    String message, {
    required String emoji,
    String tag = 'App',
    Object? data,
  }) {
    developer.log(
      '$emoji $message${data != null ? '\nData: $data' : ''}',
      name: tag,
      level: 800,
    );
  }

  /// Log Firestore operations
  static void firestore(String message, {Object? data}) {
    custom(message, emoji: '🔥', tag: 'Firestore', data: data);
  }

  /// Log provider state changes
  static void provider(String message, {Object? data}) {
    custom(message, emoji: '🔄', tag: 'Provider', data: data);
  }

  /// Log repository operations
  static void repository(String message, {Object? data}) {
    custom(message, emoji: '📦', tag: 'Repository', data: data);
  }

  /// Log successful operations
  static void success(String message, {String tag = 'App', Object? data}) {
    custom(message, emoji: '✅', tag: tag, data: data);
  }
}
