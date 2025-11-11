// lib/src/utils/error_handler.dart
/// Centralized error handling utility
/// 
/// Provides consistent error handling and user-friendly error messages
/// throughout the application.
library;

import 'package:flutter/material.dart';
import 'logger.dart';

/// Custom exception for application-specific errors
class AppException implements Exception {
  /// Constructor
  AppException(this.message, {this.code, this.details});
  
  /// Human-readable error message
  final String message;
  
  /// Optional error code for categorization
  final String? code;
  
  /// Optional additional details
  final Object? details;

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Error handler utility class
class ErrorHandler {
  /// Handle and log an error, returning a user-friendly message
  /// 
  /// Usage:
  /// ```dart
  /// try {
  ///   await someOperation();
  /// } catch (e, stackTrace) {
  ///   final message = ErrorHandler.handle(e, stackTrace, context: 'Loading products');
  ///   // Show message to user
  /// }
  /// ```
  static String handle(
    Object error,
    StackTrace? stackTrace, {
    String context = 'Operation',
    bool logError = true,
  }) {
    if (logError) {
      AppLogger.error(
        'Error in $context',
        error: error,
        stackTrace: stackTrace,
        tag: 'ErrorHandler',
      );
    }

    // Return user-friendly message based on error type
    if (error is AppException) {
      return error.message;
    } else if (error is FormatException) {
      return 'Format de données invalide';
    } else if (error is TypeError) {
      return 'Erreur de type de données';
    } else if (error.toString().contains('SocketException')) {
      return 'Erreur de connexion réseau';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Délai d\'attente dépassé';
    } else {
      return 'Une erreur s\'est produite. Veuillez réessayer.';
    }
  }

  /// Show an error dialog to the user
  /// 
  /// Displays a user-friendly error dialog with the error message.
  static void showErrorDialog(
    BuildContext context,
    Object error,
    StackTrace? stackTrace, {
    String title = 'Erreur',
    String contextMessage = 'Operation',
  }) {
    final message = handle(error, stackTrace, context: contextMessage);

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show an error snackbar to the user
  /// 
  /// Displays a brief error message at the bottom of the screen.
  static void showErrorSnackBar(
    BuildContext context,
    Object error,
    StackTrace? stackTrace, {
    String contextMessage = 'Operation',
  }) {
    final message = handle(error, stackTrace, context: contextMessage);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
