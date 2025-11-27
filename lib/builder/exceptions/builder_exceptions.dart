// lib/builder/exceptions/builder_exceptions.dart
// Custom exceptions for Builder B3 system

/// Exception thrown when a page cannot be found or loaded
class BuilderPageException implements Exception {
  final String message;
  final String? pageId;

  BuilderPageException(this.message, {this.pageId});

  @override
  String toString() => 'BuilderPageException: $message${pageId != null ? ' (pageId: $pageId)' : ''}';
}

/// Exception thrown when trying to configure less than 2 pages in bottom bar
class MinimumBottomNavItemsException implements Exception {
  final String message;

  MinimumBottomNavItemsException([
    this.message = 'Il doit y avoir au moins 2 pages dans la barre inférieure.',
  ]);

  @override
  String toString() => 'MinimumBottomNavItemsException: $message';
}

/// Exception thrown when trying to use a bottomNavIndex that's already taken
class BottomNavIndexConflictException implements Exception {
  final String message;
  final int conflictingIndex;
  final String? conflictingPageName;

  BottomNavIndexConflictException(
    this.conflictingIndex, [
    this.conflictingPageName,
  ]) : message = conflictingPageName != null
            ? 'Cette position est déjà utilisée par une autre page ($conflictingPageName).'
            : 'Cette position est déjà utilisée par une autre page.';

  @override
  String toString() => 'BottomNavIndexConflictException: $message';
}
